(
// SuperDirt instrument matching Strudel/SuperDough's stock `sine` voice.
//
// Strudel's `.fm(x)` is a sine modulator at the carrier frequency whose
// deviation is `x * carrierFrequency`.  Its stock oscillator is attenuated
// by 0.3 before the event gain and uses a linear ADSR.  When attack and decay
// are supplied without an explicit amplitude-sustain level, Strudel falls to
// its minimum level (0.001) after decay.
SynthDef(\strudelSine, {
    |out = 0, freq = 440, sineHold = 1, pan = 0,
    sineAttack = 0.001, sineDecay = 0.05, sineRelease = 0.01, fm = 0|

    var gate = Trig1.kr(1, sineHold.max(0.001));
    var modulator = SinOsc.ar(freq) * (fm * freq);
    var carrier = SinOsc.ar(freq + modulator);
    var envelope = EnvGen.ar(
        Env.adsr(
            sineAttack.max(0.001),
            sineDecay.max(0.001),
            0.001,
            sineRelease.max(0.01),
            curve: \lin
        ),
        gate,
        doneAction: Done.freeSelf
    );

    OffsetOut.ar(out, DirtPan.ar(carrier * envelope * 0.3, ~dirt.numChannels, pan));
}).add;

// SuperDirt normally frees the whole event group at `sustain`, truncating a
// synth's release tail.  Preserve the legato-derived hold time for the synth,
// then keep the group alive until the release has completed.
~dirt.soundLibrary.addSynth(\strudelSine, (
    instrument: \strudelSine,
    play: { |dirtEvent|
        ~sineHold = ~sustain;
        ~sustain = ~sustain + (~sineRelease ? 0.01).max(0.01);
        dirtEvent.playSynths;
        true;
    }
));
"Strudel-compatible sine synth loaded as strudelSine".postln;
)
