(
var outputDirectory = "/tmp/sc-dotfiles-recorder-synthdef";

File.mkdir(outputDirectory);

SynthDef(\sc_dotfiles_recorder_2, {
    |bufnum = 0, in = 0|
    DiskOut.ar(bufnum, In.ar(in, 2));
}).writeDefFile(outputDirectory);

0.exit;
)
