// The regular SuperCollider startup file normally loads the repository first.
// Keep this fallback so the CLI also works on a machine not yet configured.
if(~scDotfilesLoaded != true) {
    "/Users/jumang4423/sc-dotfiles/startup.scd"
        .standardizePath
        .load;
};

// A command-line script exits at EOF even in daemon mode. Keep the language
// process alive; `make stop` terminates it, while `make check` calls 0.exit.
~scDotfilesKeepAlive = Condition.new;
~scDotfilesKeepAlive.hang;
