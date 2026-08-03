(
var effectName = \dirt_disperser;
var numChannels = ~dirt.numChannels;
var stageLevels = #[8, 16, 32, 64, 128, 256, 512];

stageLevels.do { |stageCount|
    var synthName = effectName.asString
        ++ "_" ++ stageCount
        ++ "_" ++ numChannels;

    SynthDef(synthName, {
        |out, disperserFreq = 200|
        var signal = In.ar(out, numChannels);
        var frequency = disperserFreq.clip(20, 20000);
        var reciprocalQ = 2; // Fixed Q = 0.5.

        stageCount.do {
            signal = BAllPass.ar(
                signal,
                frequency,
                reciprocalQ
            );
        };

        ReplaceOut.ar(out, signal);
    }, [\ir]).add;
};

~dirt.addModule(\disperser, { |dirtEvent|
    var amount = ~disperser.clip(0, 1);
    var levelIndex = (amount * (stageLevels.size - 1)).round.asInteger;
    var stageCount = stageLevels[levelIndex];
    var frequency = ~disperserFreq ? 200;
    var synthName = effectName.asString
        ++ "_" ++ stageCount
        ++ "_" ++ numChannels;

    dirtEvent.sendSynth(synthName, [
        out: ~out,
        disperserFreq: frequency
    ]);
}, {
    ~disperser.notNil and: { ~disperser > 0 }
});

s.sync;
"disperser per-event phase rotation effect loaded".postln;
)
