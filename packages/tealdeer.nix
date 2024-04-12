# Until https://github.com/dbrgn/tealdeer/pull/322 is included in an official release
{
  fetchFromGitHub,
  tealdeer,
  ...
}:
tealdeer.overrideAttrs (
  oldAttrs: let
    src = fetchFromGitHub {
      owner = "dbrgn";
      repo = "tealdeer";
      rev = "ee6d2418f1b0b049d1b8b224b554af77dc9cc65e";
      hash = "sha256-41buRHyIqFNeWnJeUpcDAs0pelPQFPdx9O2nm/mgUwo=";
    };
  in {
    inherit src;
    doCheck = false;
    cargoDeps = oldAttrs.cargoDeps.overrideAttrs {
      inherit src;
      outputHash = "sha256-ULIBSuCyr5naXhsQVCR2/Z0WY3av5rbbg5l30TCjHDY=";
    };
  }
)
