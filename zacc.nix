let
  private = import ./private;
in
  {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      <home-manager/nixos>
    ];

    users.users.zacc = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable `sudo` for the user.
      ];
      # CLI packages
      packages = with pkgs; [
        alejandra
        bottom
        cargo
        du-dust
        eza
        fd
        file
        gcc
        git
        gnumake
        home-manager
        libfaketime
        miniserve
        neofetch
        nixpkgs-fmt
        plantuml
        procs
        rclone
        restic
        ripgrep
        rustc
        (tealdeer.overrideAttrs (drv: rec {
          src = fetchFromGitHub {
            owner = "zedseven"; # Until https://github.com/dbrgn/tealdeer/issues/320 is resolved
            repo = "tealdeer";
            rev = "3cf0e51dda80bf7daa487085cedd295920bbaf55";
            sha256 = "sha256-G/GOy0Imdd9peFbcDXqv+IKZc0nYszBY0Dk4DbbULAA=";
          };
          doCheck = false;
          cargoDeps = drv.cargoDeps.overrideAttrs {
            inherit src;
            outputHash = "sha256-ULIBSuCyr5naXhsQVCR2/Z0WY3av5rbbg5l30TCjHDY=";
          };
        }))
        tree
        viu
      ];
      hashedPassword = private.hashedPassword;
      shell = pkgs.fish;
    };
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.zacc = {
      # Home Manager needs a bit of information about you and the paths it should
      # manage.
      home.username = "zacc";
      home.homeDirectory = "/home/zacc";

      # This value determines the Home Manager release that your configuration is
      # compatible with. This helps avoid breakage when a new Home Manager release
      # introduces backwards incompatible changes.
      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      home.stateVersion = "22.11"; # Please read the comment before changing.

      # The home.packages option allows you to install Nix packages into your
      # environment.
      home.packages = [
        # # Adds the 'hello' command to your environment. It prints a friendly
        # # "Hello, world!" when run.
        # pkgs.hello

        # # It is sometimes useful to fine-tune packages, for example, by applying
        # # overrides. You can do that directly here, just don't forget the
        # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
        # # fonts?
        # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

        # # You can also create simple shell scripts directly inside your
        # # configuration. For example, this adds a command 'my-hello' to your
        # # environment:
        # (pkgs.writeShellScriptBin "my-hello" ''
        #   echo "Hello, ${config.home.username}!"
        # '')
      ];

      # Home Manager is pretty good at managing dotfiles. The primary way to manage
      # plain files is through 'home.file'.
      home.file = {
        # # Building this configuration will create a copy of 'dotfiles/screenrc' in
        # # the Nix store. Activating the configuration will then make '~/.screenrc' a
        # # symlink to the Nix store copy.
        # ".screenrc".source = dotfiles/screenrc;

        # # You can also set the file content immediately.
        # ".gradle/gradle.properties".text = ''
        #   org.gradle.console=verbose
        #   org.gradle.daemon.idletimeout=3600000
        # '';
      };

      # You can also manage environment variables but you will have to manually
      # source
      #
      #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
      #
      # or
      #
      #  /etc/profiles/per-user/zacc/etc/profile.d/hm-session-vars.sh
      #
      # if you don't want to manage your shell through Home Manager.
      home.sessionVariables = {
        # EDITOR = "emacs";
      };

      home.language.base = "en_CA.utf8";

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;

      services.autorandr.enable = true;
      programs.autorandr.enable = true;

      programs.fish = {
        enable = true;
        shellAbbrs = {
          bottom = "btm --regex --tree";
          btm = "btm --regex --tree"; # Maybe also include `--battery`?
          c = "cargo";
          cb = "cargo build";
          cbr = "cargo build --release";
          cc = "cargo clippy";
          cd = "z";
          cdd = "cargo doc";
          cdda = "cargo doc --all-features";
          cddar = "cargo doc --all-features --release";
          cddars = "cargo doc --all-features --release --open";
          cddas = "cargo doc --all-features --open";
          cddr = "cargo doc --release";
          cddrs = "cargo doc --release --open";
          cdds = "cargo doc --open";
          ce = "cargo expand --color=always --theme=OneHalfDark";
          cf = "cargo fmt --all";
          cfc = "cargo fmt --all --check";
          cl = "cargo clean";
          cm = "cargo miri";
          cmr = "cargo miri run";
          cmrr = "cargo miri ruh --release";
          cmt = "cargo miri test";
          cmtr = "cargo miri test --release";
          cn = "cargo generate";
          cng = "cargo generate general --define username=zedseven --name";
          cql = "cargo license --color=always";
          cqla = "cargo license --color=always --authors";
          cqo = "cargo outdated --color=always --root-deps-only";
          cqof = "cargo outdated --color=always";
          cqu = "cargo update --color=always";
          cr = "cargo run";
          crr = "cargo run --release";
          ct = "cargo test";
          ctd = "cargo test --doc";
          ctns = "cargo nono check && cargo build --target wasm32-unknown-unknown";
          ctr = "cargo test --release";
          ctt = "cargo tree";
          cttd = "cargo tree --duplicates";
          d = "dust";
          du = "dust";
          e = "exit";
          g = "git";
          ga = "git add";
          gb = "git branch";
          gc = "git commit --gpg-sign --message";
          ge = "git checkout";
          geb = "git checkout -b";
          gf = "git fetch";
          gg = "git merge --no-ff";
          gh = "git cherry-pick -x --edit";
          gl = "git log --show-signature --graph";
          gm = "git remote";
          go = "git clone";
          gp = "git push";
          gpu = "git push --set-upstream";
          gr = "git reset";
          grao = "git remote add origin";
          gs = "git status";
          gu = "git pull";
          gy = "git apply";
          hibernate = "systemctl hibernate";
          ifconfig = "ip addr";
          ipconfig = "ip addr";
          less = "less --raw-control-chars";
          ll = "eza -lag --group-directories-first --git";
          ls = "eza --group-directories-first --git";
          poweroff = "systemctl poweroff";
          procs = "procs --tree";
          ps = "procs --tree";
          reboot = "systemctl reboot";
          rg = "rg --pretty --smart-case --stats";
          s = "sudo";
          shutdown = "shutdown -h now";
          t = "tldr";
          tealdeer = "tldr";
          top = "btm --regex";
          w = "clear";
          youtube-dl = "yt-dlp --format bestvideo+bestaudio/best --live-from-start --embed-metadata --embed-chapters --embed-subs --sub-langs all --embed-thumbnail --no-embed-info-json";
          yt-dlp = "yt-dlp --format bestvideo+bestaudio/best --live-from-start --embed-metadata --embed-chapters --embed-subs --sub-langs all --embed-thumbnail --no-embed-info-json";
          ytd = "yt-dlp --format bestvideo+bestaudio/best --live-from-start --embed-metadata --embed-chapters --embed-subs --sub-langs all --embed-thumbnail --no-embed-info-json";
        };
        interactiveShellInit = ''
          set fish_greeting
        '';
      };

      programs.starship = {
        enable = true;
        settings = {
          format = lib.concatStrings [
            "$username"
            "$hostname"
            "$directory"
            "$git_branch"
            "$time"
            "$rust"
            "$sudo"
            "$fill"
            "$cmd_duration"
            "$line_break"
            "$character"
          ];
          character = {
            success_symbol = "[λ](bold green)";
            error_symbol = "[λ](bold red)";
            vimcmd_symbol = "[ν](bold green)";
            vimcmd_replace_one_symbol = "[ν](bold purple)";
            vimcmd_replace_symbol = "[ν](bold purple)";
            vimcmd_visual_symbol = "[ν](bold yellow)";
          };
          time = {
            disabled = false;
          };
          sudo = {
            disabled = false;
            symbol = "🥄";
          };
          fill = {
            symbol = " ";
          };
        };
      };

      programs.ssh = {
        enable = true;
        matchBlocks = private.sshConfig;
      };

      programs.tealdeer = {
        enable = true;
        settings = {
          display = {
            compact = true;
            use_pager = false;
          };
          updates = {
            auto_update = true;
            auto_update_interval_hours = 720;
          };
          directories = {
            custom_pages_dir = "/home/zacc/tealdeer";
          };
        };
      };

      programs.zoxide.enable = true;

      programs.gpg.enable = true;

      programs.git = let
        exitWithConflicts = pkgs.writeShellScriptBin "git-merge-exit-with-conflicts" ''
          # https://stackoverflow.com/questions/5074452/git-how-to-force-merge-conflict-and-manual-merge-on-selected-file
          # https://git-scm.com/docs/gitattributes#_defining_a_custom_merge_driver
          ANCESTOR="$1"
          CURRENT="$2"
          OTHER="$3"
          CONFLICT_MARKER_SIZE="$4"
          RESULT_PATH="$5"
          ${pkgs.git}/bin/git merge-file "$CURRENT" "$ANCESTOR" "$OTHER"
          exit 1 # Always exit indicating a conflict
        '';
      in {
        enable = true;
        userName = "Zacchary Dempsey-Plante";
        userEmail = "zacc@ztdp.ca";
        signing = {
          key = "64FABC62F4572875";
          signByDefault = true;
        };
        extraConfig = {
          checkout.defaultRemote = "origin";
          commit.gpgSign = true;
          core = {
            autocrlf = "input";
            fileMode = false;
            editor = "vim";
          };
          credential.helper = "store";
          init.defaultBranch = "main";
          merge = {
            "exit-with-conflicts" = {
              name = "Exit With Conflicts";
              driver = "${exitWithConflicts}/bin/git-merge-exit-with-conflicts %O %A %B %L %P";
            };
          };
          push.gpgSign = "if-asked";
          tag.gpgSign = true;
        };
      };
    };
  }
