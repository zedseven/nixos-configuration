{
  slstatus,
  lib,
  conf ? {
    updateIntervalMilliseconds = 1000;
    unknownValueString = "n/a";
    maximumOutputStringLength = 2048;
    argumentSeparator = " ";
    arguments = [
      {
        function = "datetime";
        displayFormat = "%s";
        functionArgument = "%F %T";
      }
    ];
  },
  extraConfigText ? "",
  extraLibs ? [],
  ...
}:
slstatus.overrideAttrs (oldAttrs: {
  buildInputs = oldAttrs.buildInputs ++ extraLibs;

  patches = oldAttrs.patches ++ [./configurable.patch];

  postPatch = let
    argumentsString = lib.concatStringsSep "\n" (
      lib.lists.imap0 (
        index: argumentEntry: "{ ${argumentEntry.function}, \"${
          (
            if index == 0
            then ""
            else conf.argumentSeparator
          )
        }${argumentEntry.displayFormat}\", \"${argumentEntry.functionArgument}\" },"
      )
      conf.arguments
    );
  in
    (oldAttrs.postPatch or "")
    + ''
      cp config.def.h config.h

      ARGUMENTS_TEXT=$(cat <<-END
        ${argumentsString}
      END
      )

      substituteInPlace config.h \
        --replace-fail "@UPDATE_INTERVAL_MILLISECONDS@" "${(builtins.toString conf.updateIntervalMilliseconds)}" \
        --replace-fail "@UNKNOWN_VALUE_STRING@" "${conf.unknownValueString}" \
        --replace-fail "@MAXIMUM_OUTPUT_STRING_LENGTH@" "${(builtins.toString conf.maximumOutputStringLength)}" \
        --replace-fail "@ARGUMENTS@" "''$ARGUMENTS_TEXT"

      echo "" >> config.h
      echo '''${extraConfigText}''' >> config.h
    '';

  meta.maintainers = with lib.maintainers; oldAttrs.meta.maintainers ++ [zedseven];
})
