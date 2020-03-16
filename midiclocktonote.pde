import controlP5.*;
import themidibus.*;
import java.util.*;

ControlP5 cp5;
MidiBus myBus;

String textValue = "";

boolean generalswitch = false;


//clock stuff
MidiBus myMidiClockBus;

int MidiClockFireChannel = 0;
int MidiClockFirePitch = 64;
int MidiClockFireVelocity = 127;

int MidiClockResetChannel = 0;
int MidiClockResetPitch = 65;
int MidiClockResetVelocity = 127;

int MidiClockTiming = 0;
float MidiClockLfo = 0;

List<String> li = new ArrayList<String>();
List<String> lo = new ArrayList<String>();


void setup() {
  size(700, 400);

  PFont font = createFont("arial", 20);

  cp5 = new ControlP5(this);

  myBus = new MidiBus(this, -1, "loopMIDI Port"); 

  myMidiClockBus = new MidiBus(this, -1, -1); 

  MidiBus.list(); 

  cp5.addButton("control")
    .setPosition(0, 0)
    .setSize(200, 40)
    .setValue(0)
    .addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent event) {
      if (event.getAction() == ControlP5.ACTION_RELEASED) {
        if (generalswitch == false) {
          generalswitch = true;
          cp5.getController("control").setColorBackground(#00FF00);
          cp5.getController("control").setColorForeground(#00FF00);
        } else {
          generalswitch = false;
          cp5.getController("control").setColorBackground(#FF0000);
          cp5.getController("control").setColorForeground(#FF0000);
        }
        println("new control stage: " + generalswitch);
      }
    }
  }
  )
  ;



  for (int i = 0; i<myBus.availableInputs().length; i++) {
    li.add(myBus.availableInputs()[i]);
  }

  /* add a ScrollableList, by default it behaves like a DropdownList */
  cp5.addScrollableList("inputs")
    .setPosition(250, 0)
    .setSize(200, 100)
    .setBarHeight(20)
    .setItemHeight(20)
    .setItems(li)
    // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    ;


  for (int i = 0; i<myBus.availableOutputs().length; i++) {
    lo.add(myBus.availableOutputs()[i]);
  }
  /* add a ScrollableList, by default it behaves like a DropdownList */
  cp5.addScrollableList("outputs")
    .setPosition(450, 0)
    .setSize(200, 100)
    .setBarHeight(20)
    .setItemHeight(20)
    .setItems(lo)
    // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    ;

  textFont(font);
}

void draw() {
  background(0);

  ellipse(50, 50, 10, 10);
}



void rawMidi(byte[] data) { 
  if (generalswitch == true) {
    midiClock(data);
  } else {
    resetClock();
  }
}

void midiClock(byte[] data) {
  if (data[0] == (byte)0xFC) {         // TRUE when MIDI clock stops.
    resetClock();
  } else if (data[0] == (byte)0xF8) {  // TRUE every MIDI clock pulse
    MidiClockTiming++;
    MidiClockLfo = (MidiClockTiming % 24 ) / 24.0;

    if (MidiClockLfo == 0) {
      fill(#FF0000);
      println("LFO: " + MidiClockLfo + " Timing: " + MidiClockTiming);
      myMidiClockBus.sendNoteOn(MidiClockFireChannel, MidiClockFirePitch, MidiClockFireVelocity); // Send a Midi noteOn
      myMidiClockBus.sendNoteOff(MidiClockFireChannel, MidiClockFirePitch, MidiClockFireVelocity); // Send a Midi nodeOff
    } else {
      fill(#000000);
    }
  }
}





void inputs(int n) {
  myMidiClockBus.clearInputs();
  myMidiClockBus.addInput(n);
}

void outputs(int n) {
  myMidiClockBus.clearOutputs();
  myMidiClockBus.addOutput(n);
}


void resetClock() {
  MidiClockTiming = 0;
  MidiClockLfo = 0;
  myMidiClockBus.sendNoteOn(MidiClockResetChannel, MidiClockResetPitch, MidiClockResetVelocity); // Send a Midi noteOn
  myMidiClockBus.sendNoteOff(MidiClockResetChannel, MidiClockResetPitch, MidiClockResetVelocity); // Send a Midi nodeOff
}
