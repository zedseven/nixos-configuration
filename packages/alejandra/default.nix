{alejandra, ...}:
alejandra.overrideAttrs (
  oldAttrs: {
    patches = oldAttrs.patches ++ [./remove-ads.patch];
  }
)
