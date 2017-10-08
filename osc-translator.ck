// chuck orchestral motion translator

OscOut out;

SerialIO serial;
string line;
string stringInts[3];
int data[3];

//Serial protocol
SerialIO.list() @=> string list[];
for( int i; i < list.cap(); i++ )
{
    chout <= i <= ": " <= list[i] <= IO.newline();
}
serial.open(1, SerialIO.B9600, SerialIO.ASCII);

(1.0/24.0)::second => dur RESOLUTION;

fun void serialPoller(){
    while( true )
    {
        // Grab Serial data
        serial.onLine() => now;
        serial.getLine() => line;
        if( line$Object == null ) continue;
        0 => stringInts.size;

        // Line Parser
        if (RegEx.match("\\[([0-9]+),([0-9]+),([0-9]+)\\]", line , stringInts))
        {
            for( 1=>int i; i<stringInts.cap(); i++)
            {
                // Convert string to Integer
                Std.atoi(stringInts[i])=>data[i-1];
                //<<< Std.atoi(stringInts[i]) >>>;
            }
        }
    }
}

spork ~ serialPoller();

// sends out audio in 512 sample blocks
fun void send(string addr, int data) {
    out.start(addr);
    out.add(data);
    out.send();
}

// loop it
while (true) {
    send("/x", data[0]);
    send("/y", data[1]);
    send("/z", data[2]);
    RESOLUTION => now;
}
