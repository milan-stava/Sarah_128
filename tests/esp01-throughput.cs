using System;
using System.IO;
using System.IO.Ports;
using System.Net.Sockets;
using System.Text;
using System.Text.RegularExpressions;
using System.Diagnostics;
using System.Threading.Tasks;

// Exercises the existing AT firmware. No flash writes, firmware flashing or reset.
// PC connects OUTBOUND to the ESP's temporary TCP server; no PC firewall rule.
public static class Esp01Throughput {
    sealed class At : IDisposable {
        public SerialPort Port;
        public long RawRead;
        public volatile int Errors;
        byte[] buffer = new byte[65536]; int pos, len;
        public At(string name, int baud) {
            Port = new SerialPort(name, baud, Parity.None, 8, StopBits.One);
            Port.Handshake = Handshake.None; Port.DtrEnable = false; Port.RtsEnable = false;
            Port.ReadTimeout = 250; Port.WriteTimeout = 5000;
            Port.ReadBufferSize = 262144; Port.WriteBufferSize = 65536;
            Port.ErrorReceived += delegate(object sender, SerialErrorReceivedEventArgs e) { lock(this) { Errors |= (int)e.EventType; } };
            Port.Open();
        }
        public byte Read(Stopwatch clock, int timeout) {
            while (pos == len) {
                if (clock.ElapsedMilliseconds >= timeout) throw new TimeoutException("Serial receive timeout");
                try { len = Port.Read(buffer, 0, buffer.Length); RawRead += len; pos = 0; }
                catch (TimeoutException) { }
            }
            return buffer[pos++];
        }
        public string Until(string end, int timeout) {
            var clock = Stopwatch.StartNew(); var text = new StringBuilder();
            while (true) {
                text.Append((char)Read(clock, timeout));
                string s = text.ToString();
                if (s.EndsWith(end, StringComparison.Ordinal)) return s;
                if (s.EndsWith("\r\nERROR\r\n") || s.EndsWith("\r\nFAIL\r\n") || s.EndsWith("SEND FAIL\r\n"))
                    throw new IOException("ESP rejected operation: " + s.Trim());
                if (text.Length > 8192) throw new IOException("Unexpected oversized AT reply");
            }
        }
        public string Command(string command) {
            Port.Write(command + "\r\n"); return Until("OK\r\n", 5000);
        }
        public void Drain() {
            pos=len=0;var elapsed=Stopwatch.StartNew();var quiet=Stopwatch.StartNew();
            while(elapsed.ElapsedMilliseconds<5000){
                if(Port.BytesToRead>0){Port.Read(buffer,0,Math.Min(buffer.Length,Port.BytesToRead));quiet.Restart();}
                else if(quiet.ElapsedMilliseconds>200)return;
                else System.Threading.Thread.Sleep(10);
            }
        }
        public void Dispose() { Port.Dispose(); }
    }
    static void Check(byte[] got, byte[] expected, string direction) {
        if (got.Length != expected.Length) throw new IOException(direction + " length mismatch");
        for (int i=0;i<got.Length;i++) if(got[i]!=expected[i])
            throw new IOException(direction + " mismatch at byte " + i + ": " + got[i] + " != " + expected[i]);
    }
    static string Metric(string direction, int size, double seconds) {
        return String.Format(System.Globalization.CultureInfo.InvariantCulture,
            "{0}: {1} bytes, {2:F3} s, {3:F2} KiB/s, exact byte comparison OK", direction,size,seconds,size/1024.0/seconds);
    }
    public static string[] Run(string portName, string ip, int currentBaud, int testBaud, int size) {
        var results = new System.Collections.Generic.List<string>();
        byte[] data = new byte[size]; uint seed = 0x12345678;
        for(int i=0;i<size;i++){seed ^= seed<<13; seed ^= seed>>17; seed ^= seed<<5; data[i]=(byte)seed;}
        TcpClient client = null; Task<byte[]> reader = null; Task writer = null;
        bool dataMode = false, changedBaud = false, server = false, echoDisabled = false, muxChanged = false;
        int oldMux = 0; string oldUart = null;
        int downloaded = 0, firstMismatch = -1; string phase = "setup";
        using(var at = new At(portName, currentBaud)) {
            try {
                // Validate the driver BEFORE changing the ESP. This transmits no bytes.
                // Acceptance alone does not prove that a USB bridge produces the exact baud.
                phase = "host baud preflight";
                try { at.Port.BaudRate = testBaud; }
                finally { at.Port.BaudRate = currentBaud; }
                phase = "setup";
                at.Command("AT");
                oldUart = Regex.Match(at.Command("AT+UART_CUR?"), @"\+UART_CUR:([^\r\n]+)").Groups[1].Value;
                if(oldUart.Length==0)throw new IOException("No UART configuration returned");
                // Firmware reports rounded actual baud (e.g. 115273); restore the working requested baud.
                oldUart = currentBaud + oldUart.Substring(oldUart.IndexOf(','));
                oldMux = Int32.Parse(Regex.Match(at.Command("AT+CIPMUX?"), @"\+CIPMUX:(\d)").Groups[1].Value);
                string status = at.Command("AT+CIPSTATUS");
                if(!status.Contains("STATUS:2") && !status.Contains("STATUS:4"))
                    throw new IOException("ESP must be connected to Wi-Fi with no active TCP sessions: " + status.Trim());
                at.Command("ATE0"); echoDisabled = true;
                {
                    // AT acknowledgement is transmitted at the old baud by this firmware.
                    at.Command("AT+UART_CUR="+testBaud+",8,1,0,0");
                    changedBaud = true; at.Port.BaudRate = testBaud;
                    at.Command("AT");
                }
                results.Add("Requested baud="+testBaud+"; "+at.Command("AT+UART_CUR?").Trim().Replace("\r\n"," "));
                if(oldMux!=1){at.Command("AT+CIPMUX=1");muxChanged=true;}
                at.Command("AT+CIPSERVER=1,3333"); server = true;
                client = new TcpClient(); client.NoDelay=true;
                var connect=client.BeginConnect(ip,3333,null,null);
                if(!connect.AsyncWaitHandle.WaitOne(5000))throw new TimeoutException("PC cannot reach ESP TCP server");
                client.EndConnect(connect); connect.AsyncWaitHandle.Close();
                string connected=at.Until("CONNECT\r\n",5000);
                Match match=Regex.Match(connected,@"([0-4]),CONNECT");
                if(!match.Success)throw new IOException("No link ID: "+connected);
                int link=Int32.Parse(match.Groups[1].Value);
                NetworkStream stream=client.GetStream();stream.ReadTimeout=15000;stream.WriteTimeout=15000;
                reader=Task.Factory.StartNew<byte[]>(()=>{
                    byte[] received=new byte[size];int count=0;
                    while(count<size){int n=stream.Read(received,count,size-count);if(n==0)throw new IOException("TCP closed early");count+=n;}
                    return received;
                });
                var clock=Stopwatch.StartNew();
                phase = "UART -> Wi-Fi";
                for(int offset=0;offset<size;offset+=2048){
                    int count=Math.Min(2048,size-offset);
                    // Any failure after starting CIPSEND is treated as uncertain data mode.
                    dataMode=true;at.Port.Write("AT+CIPSEND="+link+","+count+"\r\n");
                    at.Until(">",5000);
                    at.Port.Write(data,offset,count);
                    at.Until("SEND OK\r\n",15000);dataMode=false;
                }
                if(!reader.Wait(15000))throw new TimeoutException("TCP receiver incomplete");
                clock.Stop();Check(reader.Result,data,"UART -> Wi-Fi");
                results.Add(Metric("UART -> Wi-Fi",size,clock.Elapsed.TotalSeconds));
                Console.WriteLine(results[results.Count-1]);
                clock.Restart();
                phase = "Wi-Fi -> UART";
                writer=Task.Factory.StartNew(()=>{
                    for(int offset=0;offset<size;offset+=2048)stream.Write(data,offset,Math.Min(2048,size-offset));
                    stream.Flush();
                });
                byte[] download=new byte[size];int total=0;
                while(total<size){
                    at.Until("+IPD,",15000);
                    string header=at.Until(":",5000).TrimEnd(':');
                    string[] fields=header.Split(',');
                    int frameLink,count;
                    if(fields.Length!=2 || !Int32.TryParse(fields[0],out frameLink) || frameLink!=link || !Int32.TryParse(fields[1],out count))
                        throw new IOException("Corrupted IPD header; prefix hex="+BitConverter.ToString(Encoding.GetEncoding(28591).GetBytes(header.Substring(0,Math.Min(32,header.Length)))));
                    if(count<1 || count>size-total)throw new IOException("Invalid IPD length: "+count);
                    var frameClock=Stopwatch.StartNew();
                    for(int i=0;i<count;i++){
                        byte value=at.Read(frameClock,15000);
                        if(value!=data[total] && firstMismatch<0)firstMismatch=total;
                        download[total++]=value; downloaded=total;
                    }
                }
                if(!writer.Wait(15000))throw new TimeoutException("TCP sender incomplete");
                clock.Stop();Check(download,data,"Wi-Fi -> UART");
                results.Add(Metric("Wi-Fi -> UART",size,clock.Elapsed.TotalSeconds));
                Console.WriteLine(results[results.Count-1]);
                at.Command("AT+CIPCLOSE="+link);client.Close();client=null;
                return results.ToArray();
            } catch(Exception ex) {
                Console.WriteLine("FAIL phase="+phase+" downloaded="+downloaded+"/"+size+" firstMismatch="+firstMismatch+" serialErrorFlags="+at.Errors+" rawSerialBytes="+at.RawRead+" reason="+ex.Message);
                throw;
            } finally {
                if(client!=null)client.Close();
                // Do not send AT commands into a possibly incomplete CIPSEND payload.
                if(!dataMode) {
                    try {at.Drain();}catch(Exception ex){Console.WriteLine("Cleanup drain: "+ex.Message);}
                    try {if(server)at.Command("AT+CIPSERVER=0");}catch(Exception ex){Console.WriteLine("Cleanup server: "+ex.Message);}
                    try {if(muxChanged)at.Command("AT+CIPMUX="+oldMux);}catch(Exception ex){Console.WriteLine("Cleanup mux: "+ex.Message);}
                    try {if(echoDisabled)at.Command("ATE1");}catch(Exception ex){Console.WriteLine("Cleanup echo: "+ex.Message);}
                    if(changedBaud)try {at.Command("AT+UART_CUR="+oldUart);at.Port.BaudRate=currentBaud;at.Command("AT");Console.WriteLine("Baud restored to "+currentBaud);}
                    catch(Exception ex){Console.WriteLine("BAUD RESTORE FAILED: "+ex.Message);}
                } else Console.WriteLine("Uncertain CIPSEND state: no further AT commands sent. Power-cycle ESP before further tests; runtime baud may be "+testBaud);
            }
        }
    }
}
