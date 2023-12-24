let
  private = import /persist/etc/nixos/private;
in
  {
    config,
    pkgs,
    lib,
    home-manager,
    agenix,
    system,
    ...
  }: {
    imports = [
      home-manager.nixosModules.home-manager
    ];

    users.users.zacc = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable `sudo`
      ];
      # CLI packages
      packages = with pkgs; [
        agenix.packages.${system}.default
        alejandra
        bottom
        deadnix
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
        mpv
        neofetch
        nix-tree
        nixpkgs-fmt
        plantuml
        procs
        rclone
        restic
        ripgrep
        statix
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
        yt-dlp
      ];
      inherit (private) hashedPassword;
      shell = pkgs.fish;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.zacc = {
        home = {
          username = "zacc";
          homeDirectory = "/home/zacc";
          stateVersion = "22.11"; # Don't touch this, ever
          language.base = config.i18n.defaultLocale;
        };

        services.autorandr.enable = true;

        programs = {
          home-manager.enable = true;

          autorandr.enable = true;

          fish = {
            enable = true;
            shellAbbrs = {
              alejandra = "alejandra --quiet";
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
              deadnix = "deadnix --hidden";
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

          vim = {
            enable = true;
            defaultEditor = true;
            packageConfigurable = pkgs.vim;
          };

          starship = {
            enable = true;
            settings = {
              format = lib.concatStrings [
                "$username"
                "$hostname"
                "$directory"
                "$git_branch"
                "$time"
                "$rust"
                "$nodejs"
                "$dotnet"
                "$nix_shell"
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
              directory = {
                fish_style_pwd_dir_length = 1;
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

          ssh = {
            enable = true;
            matchBlocks = private.sshConfig;
          };

          tealdeer = {
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

          zoxide.enable = true;

          gpg.enable = true;

          git = let
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
              # https://git-scm.com/docs/git-config
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
                conflictStyle = "diff3";
                "exit-with-conflicts" = {
                  name = "Exit With Conflicts";
                  driver = "${exitWithConflicts}/bin/git-merge-exit-with-conflicts %O %A %B %L %P";
                };
              };
              push.gpgSign = "if-asked";
              tag.gpgSign = true;
            };
          };

          git-cliff.enable = true;

          direnv = {
            enable = true;
            nix-direnv.enable = true;
          };
        };
      };
    };
  }
