{
  config,
  pkgs,
  lib,
  inputs,
  userInfo,
  system,
  ...
}: let
  cfg = config.custom.user;
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./symlinks.nix
  ];

  options.custom.user = with lib; {
    type = mkOption {
      description = "The type of user configuration.";
      type = types.enum [
        "minimal"
        "full"
      ];
      default = "minimal";
    };
    shellPromptCharacter = mkOption {
      description = "The prompt character for the shell.";
      type = types.str;
      default =
        {
          "minimal" = "μ";
          "full" = "λ";
        }
        ."${cfg.type}";
    };
    hashedPasswordFile = mkOption {
      description = "The file that contains the hash of the user's password.";
      type = types.nullOr types.str;
      default = config.age.secrets."user-password-hash".path;
    };
  };

  config = let
    homeDirectory = "/home/${userInfo.username}";
  in
    lib.mkMerge [
      # Minimal
      {
        users.users.${userInfo.username} = {
          isNormalUser = true;
          extraGroups = [
            "wheel" # Enable `sudo`
          ];
          # CLI packages
          packages = with pkgs; [
            bottom
            du-dust
            eza
            fd
            file
            fzf
            libtree
            neofetch
            nix-tree
            procs
            ripgrep
            sd
            tree
          ];
          inherit (cfg) hashedPasswordFile;
          shell = pkgs.fish;

          # Set the user key as an authorised key
          openssh.authorizedKeys.keys = [
            inputs.private.unencryptedValues.users.${userInfo.username}.publicKey
          ];
        };

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${userInfo.username} = {
            home = {
              inherit (userInfo) username;
              inherit homeDirectory;
              stateVersion = "22.11"; # Don't touch this, ever
              language.base = config.i18n.defaultLocale;
            };

            programs = {
              home-manager.enable = true;

              fish = {
                enable = true;
                shellAbbrs = {
                  bottom = "btm --regex";
                  btm = "btm --regex";
                  cp = "cp --interactive";
                  du = "dust";
                  e = "exit";
                  h = "hx";
                  helix = "hx";
                  hibernate = "systemctl hibernate";
                  ifconfig = "ip addr";
                  ipconfig = "ip addr";
                  kill = "kill -9";
                  killall = "killall -9";
                  ldd = "libtree -v --path";
                  less = "less --raw-control-chars";
                  libtree = "libtree -v --path";
                  ll = "eza -lag --group-directories-first --git";
                  ls = "eza --group-directories-first --git";
                  mv = "mv --interactive";
                  n = "nix run nixpkgs#";
                  nflu = "nix flake lock --update-input";
                  nfluo = "nix flake lock --offline --update-input";
                  nfu = "nix flake update";
                  nrb = "git diff --quiet && nh os boot --ask"; # `git diff --quiet` is to prevent switching to a dirty configuration
                  nrs = "git diff --quiet && nh os switch --ask";
                  nrt = "nh os test --verbose -- --show-trace";
                  nrtd = "nh os test --verbose --dry -- --show-trace";
                  nvim = "hx";
                  poweroff = "systemctl poweroff";
                  procs = "procs --tree";
                  ps = "procs --tree";
                  reboot = "systemctl reboot";
                  rg = "rg --pretty --smart-case --stats";
                  s = "sudo";
                  shutdown = "shutdown -h now";
                  top = "btm --regex";
                  vi = "hx";
                  vim = "hx";
                  w = "clear";
                  y = "yazi";
                };
                interactiveShellInit = ''
                  set fish_greeting
                '';
              };

              helix = {
                enable = true;
                defaultEditor = true;
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
                    "$os"
                    "$line_break"
                    "$character"
                  ];
                  character = {
                    success_symbol = "[${cfg.shellPromptCharacter}](bold green)";
                    error_symbol = "[${cfg.shellPromptCharacter}](bold red)";
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
                  os = {
                    disabled = false;
                    style = "bold blue";
                    symbols = {
                      "NixOS" = "  "; # Use the Unicode Private Use character of the NixOS logo - PragmataPro supports this
                    };
                  };
                };
              };

              zoxide.enable = true;
            };
          };
        };
      }

      # Full
      (lib.mkIf (cfg.type == "full") {
        users.users.${userInfo.username} = {
          # CLI packages
          packages = with pkgs; [
            inputs.deploy-rs.packages.${system}.default
            inputs.self.packages.${system}.purefmt
            inputs.self.packages.${system}.tealdeer
            inputs.self.packages.${system}.wireguard-vanity-address
            deadnix
            dnsutils
            endlines
            gcc
            gnumake
            libfaketime
            nixpkgs-fmt
            nmap
            openssh
            plantuml
            rclone
            restic
            statix
            traceroute
            viu
            yt-dlp

            # Language Servers (LSP) and Debug Adapters (DAP)
            clang-tools # C, C++
            lldb # LLVM-based languages
            #rust-analyzer # Rust (installed on a per-project basis to match the toolchain, using `direnv`)
            nil # Nix
          ];
        };

        home-manager.users.${userInfo.username}.programs = {
          fish.shellAbbrs = {
            alejandra = "purefmt";
            b = "bat";
            bm = "batman";
            c = "cargo";
            cat = "bat";
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
            d = "batdiff";
            deadnix = "deadnix --hidden --fail";
            diff = "batdiff";
            fmt = "purefmt";
            g = "git";
            ga = "git add";
            gb = "git branch";
            gc = "git commit --gpg-sign --message";
            ge = "git checkout";
            geb = "git checkout -b";
            gf = "git fetch --all";
            gg = "git merge --no-ff";
            gh = "git cherry-pick -x --edit";
            git-chmod = "git update-index --chmod=+x";
            gl = "git log --show-signature --graph";
            gm = "git remote";
            go = "git clone";
            gp = "git push";
            gpu = "git push --set-upstream";
            gr = "git reset";
            grao = "git remote add origin";
            gs = "batdiff && git status";
            gu = "git pull";
            gx = "git update-index --chmod=+x";
            gy = "git apply";
            m = "batman";
            man = "batman";
            sc = "maim";
            scs = "maim --select";
            t = "tldr";
            tealdeer = "tldr";
            tracert = "traceroute";
            youtube-dl = "yt-dlp --format bestvideo+bestaudio/best --live-from-start --embed-metadata --embed-chapters --embed-subs --sub-langs all --embed-thumbnail --no-embed-info-json";
            yt-dlp = "yt-dlp --format bestvideo+bestaudio/best --live-from-start --embed-metadata --embed-chapters --embed-subs --sub-langs all --embed-thumbnail --no-embed-info-json";
            ytd = "yt-dlp --format bestvideo+bestaudio/best --live-from-start --embed-metadata --embed-chapters --embed-subs --sub-langs all --embed-thumbnail --no-embed-info-json";
          };

          bat = {
            enable = true;
            extraPackages = with pkgs.bat-extras; [
              (batdiff.override {withDelta = true;})
              batman
            ];
          };

          direnv = {
            enable = true;
            nix-direnv.enable = true;
          };

          yazi = {
            enable = true;
            enableFishIntegration = true;
            settings = {
              manager = {
                show_hidden = true;
                sort_dir_first = true;
              };
            };
          };

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
            userName = userInfo.name;
            userEmail = userInfo.email;
            signing = {
              key = userInfo.gpgKeyId;
              signByDefault = true;
            };
            extraConfig = {
              # https://git-scm.com/docs/git-config
              checkout.defaultRemote = "origin";
              commit.gpgSign = true;
              core = {
                autocrlf = "input";
                fileMode = false;
                editor = "nvim";
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
                custom_pages_dir = "${homeDirectory}/tealdeer";
              };
            };
          };
        };
      })
    ];
}
