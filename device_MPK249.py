# name=MPK249
# url=https://github.com/parkovski/config

# import channels
import device
import midi

def OnInit():
    pass

def OnMidiMsg(e):
    e.handled = False

def OnMidiIn(e):
    if e.status == midi.MIDI_CONTROLCHANGE:
        msg = e.status | (e.data1 << 8) | (e.data2 << 16) | (1 << 24)
        device.forwardMIDICC(msg, 0)
        e.handled = True
    else:
        e.handled = False
