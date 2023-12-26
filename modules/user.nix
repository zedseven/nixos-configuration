{
  config,
  pkgs,
  lib,
  home-manager,
  userInfo,
  ...
}: let
  cfg = config.custom.user;
in {
  imports = [
    home-manager.nixosModules.home-manager
    ./symlinks.nix
  ];

  options.custom.user = with lib; {
    type = mkOption {
      description = "The type of user configuration.";
      type = types.enum ["minimal" "full"];
      default = "minimal";
    };
  };

  config = let
    homeDirectory = "/home/${userInfo.username}";

    shellPromptCharacter =
      if cfg.type == "full"
      then "λ"
      else "μ";
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
            endlines
            eza
            fd
            file
            git
            home-manager
            neofetch
            nix-tree
            procs
            ripgrep
            tree
          ];
          hashedPasswordFile = config.age.secrets."user-password-hash".path;
          shell = pkgs.fish;
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
                  bottom = "btm --regex --tree";
                  btm = "btm --regex --tree"; # Maybe also include `--battery`?
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
                  nrb = "sudo nixos-rebuild boot";
                  nrs = "sudo nixos-rebuild switch";
                  nrt = "sudo nixos-rebuild test --impure --show-trace";
                  poweroff = "systemctl poweroff";
                  procs = "procs --tree";
                  ps = "procs --tree";
                  reboot = "systemctl reboot";
                  rg = "rg --pretty --smart-case --stats";
                  s = "sudo";
                  shutdown = "shutdown -h now";
                  top = "btm --regex";
                  w = "clear";
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
                    success_symbol = "[${shellPromptCharacter}](bold green)";
                    error_symbol = "[${shellPromptCharacter}](bold red)";
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
            };
          };
        };
      }

      # Full
      (lib.mkIf
        (cfg.type == "full")
        {
          # Set up symlinks so that the `agenix` CLI can find the system host keys automatically
          custom.symlinks = {
            "${homeDirectory}/.ssh/id_ed25519".source = "/etc/ssh/ssh_host_ed25519_key";
            "${homeDirectory}/.ssh/id_ed25519.pub".source = "/etc/ssh/ssh_host_ed25519_key.pub";
            "${homeDirectory}/.ssh/id_rsa".source = "/etc/ssh/ssh_host_rsa_key";
            "${homeDirectory}/.ssh/id_rsa.pub".source = "/etc/ssh/ssh_host_rsa_key.pub";
          };

          users.users.${userInfo.username} = {
            # CLI packages
            packages = with pkgs; [
              alejandra
              deadnix
              gcc
              gnumake
              libfaketime
              miniserve
              mpv
              nixpkgs-fmt
              openssh
              plantuml
              rclone
              restic
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
              viu
              yt-dlp
            ];
          };

          home-manager.users.${userInfo.username}.programs = {
            fish.shellAbbrs = {
              alejandra = "alejandra --quiet";
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
              deadnix = "deadnix --hidden";
              t = "tldr";
              tealdeer = "tldr";
              youtube-dl = "yt-dlp --format bestvideo+bestaudio/best --live-from-start --embed-metadata --embed-chapters --embed-subs --sub-langs all --embed-thumbnail --no-embed-info-json";
              yt-dlp = "yt-dlp --format bestvideo+bestaudio/best --live-from-start --embed-metadata --embed-chapters --embed-subs --sub-langs all --embed-thumbnail --no-embed-info-json";
              ytd = "yt-dlp --format bestvideo+bestaudio/best --live-from-start --embed-metadata --embed-chapters --embed-subs --sub-langs all --embed-thumbnail --no-embed-info-json";
            };

            direnv = {
              enable = true;
              nix-direnv.enable = true;
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