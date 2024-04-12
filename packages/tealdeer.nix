# Until https://github.com/dbrgn/tealdeer/issues/320 is resolved
{
  fetchFromGitHub,
  tealdeer,
  ...
}:
tealdeer.overrideAttrs (
  oldAttrs: let
    src = fetchFromGitHub {
      owner = "zedseven";
      repo = "tealdeer";
      rev = "3cf0e51dda80bf7daa487085cedd295920bbaf55";
      hash = "sha256-G/GOy0Imdd9peFbcDXqv+IKZc0nYszBY0Dk4DbbULAA=";
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
