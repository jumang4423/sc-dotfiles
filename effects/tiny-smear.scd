(
var effectName = \dirt_tiny_smear;
var numChannels = ~dirt.numChannels;
var fftSize = 1024;
var levelCount = 16;
var durations = Array.series(
    levelCount,
    0.015,
    (0.2 - 0.015) / (levelCount - 1)
);
var spectraByDuration;

// Build two dense, decorrelated impulse responses for every duration level,
// then prepare them for low-latency partitioned convolution.
spectraByDuration = durations.collect { |duration, durationIndex|
    [0, 1].collect { |channelIndex|
        var frameCount = (s.sampleRate * duration).asInteger.max(64);
        var ir;
        var energy;
        var timeBuffer;
        var spectrumBuffer;

        thisThread.randSeed = 12000 + (durationIndex * 2) + channelIndex;

        ir = Signal.fill(frameCount, { |sampleIndex|
            var position = sampleIndex / (frameCount - 1);
            var attack = (position / 0.18).clip(0, 1).squared;
            var envelope = attack * exp(-4.5 * position);
            var density = position.linlin(0, 1, 0.25, 0.60);

            if(density.coin) {
                1.0.rand2 * envelope
            } {
                0
            };
        });

        // Equalise IR energy across duration levels without filtering it.
        energy = ir.collect { |sample| sample.squared }.sum.sqrt.max(0.000001);
        ir = ir * (0.72 / energy);

        timeBuffer = Buffer.loadCollection(s, ir);
        s.sync;

        spectrumBuffer = Buffer.alloc(
            s,
            PartConv.calcBufSize(fftSize, timeBuffer),
            1
        );
        spectrumBuffer.preparePartConv(timeBuffer, fftSize);
        s.sync;

        timeBuffer.free;
        spectrumBuffer;
    };
};

SynthDef(effectName.asString ++ numChannels, {
    |out, irLeft = 0, irRight = 0|

    var dry = In.ar(out, numChannels);
    var source = dry.asArray.sum / numChannels.sqrt;
    var wet = [
        PartConv.ar(source, fftSize, irLeft),
        PartConv.ar(source, fftSize, irRight)
    ];

    // Fixed active mix: dry 0%, wet 100%.
    ReplaceOut.ar(out, (dry * 0.0) + wet);
}, [\ir, \ir, \ir]).add;

~dirt.addModule(\tiny_smear, { |dirtEvent|
    var amount = ~tinySmear.clip(0, 1);
    var index = (amount * (spectraByDuration.size - 1)).round.asInteger;
    var spectra = spectraByDuration[index];

    dirtEvent.sendSynth(effectName.asString ++ numChannels, [
        out: ~out,
        irLeft: spectra[0].bufnum,
        irRight: spectra[1].bufnum
    ]);
}, {
    // Supplying tinySmear 0 means the smallest IR, not bypass.
    ~tinySmear.notNil
});

s.sync;
"tiny-smear dense PartConv effect loaded".postln;
)
