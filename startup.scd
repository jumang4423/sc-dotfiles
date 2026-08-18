(
var root = thisProcess.nowExecutingPath.dirname;
var synthdefs = root +/+ "synthdefs";
var effects = root +/+ "effects";
var samples = root +/+ "samples";
var thirdPartySamples = root +/+ "tp-samples";

~scDotfilesLoaded = true;

s.options.numBuffers = 1024 * 256;
s.options.memSize = 8192 * 32;
s.options.numWireBufs = 128;
s.options.maxNodes = 1024 * 32;
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;

s.waitForBoot {
    ~dirt = SuperDirt(2, s);

    // Load the standard Dirt-Samples banks (bd, sd, hh, and so on).
    ~dirt.loadSoundFiles;

    PathName(synthdefs).files
        .select { |file| file.extension == "scd" }
        .do { |file| file.fullPath.load };

    PathName(samples).folders.do { |bank|
        ~dirt.loadSoundFiles(bank.fullPath +/+ "*", true);
    };

    ~dirt.loadSoundFiles(thirdPartySamples +/+ "*", true);

    s.sync;
    ~dirt.start(57120, 0 ! 12);

    // Global effects need the Dirt orbits created by `start`.
    PathName(effects).files
        .select { |file| file.extension == "scd" }
        .do { |file| file.fullPath.load };

    s.sync;
    "sc-dotfiles ready".postln;

    // `make check` boots the complete environment, then shuts it down.
    if("SC_DOTFILES_CHECK".getenv == "1") {
        ~dirt.stop;
        s.quit;
        SystemClock.sched(1, {
            0.exit;
            nil;
        });
    };
};

s.boot;
)
