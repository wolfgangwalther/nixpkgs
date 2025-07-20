{
  pname,
  version,
  src,
  meta,
  stdenv,
  binaryName,
  desktopName,
  lib,
  undmg,
  makeWrapper,
  python3,
  runCommand,
  branch,
  updateScript,
  withOpenASAR ? false,
  openasar,
  withVencord ? false,
  vencord,
  withMoonlight ? false,
  moonlight,
  commandLineArgs ? "",
}:

assert lib.assertMsg (
  !(withMoonlight && withVencord)
) "discord: Moonlight and Vencord can not be enabled at the same time";

let
  disableBreakingUpdates =
    runCommand "disable-breaking-updates.py"
      {
        pythonInterpreter = "${python3.interpreter}";
        configDirName = lib.toLower binaryName;
        meta.mainProgram = "disable-breaking-updates.py";
      }
      ''
        mkdir -p $out/bin
        cp ${./disable-breaking-updates.py} $out/bin/disable-breaking-updates.py
        substituteAllInPlace $out/bin/disable-breaking-updates.py
        chmod +x $out/bin/disable-breaking-updates.py
      '';
in
stdenv.mkDerivation {
  inherit
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = [
    undmg
    makeWrapper
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r "${desktopName}.app" $out/Applications

    # wrap executable to $out/bin
    mkdir -p $out/bin
    makeWrapper "$out/Applications/${desktopName}.app/Contents/MacOS/${binaryName}" "$out/bin/${binaryName}" \
      --run ${lib.getExe disableBreakingUpdates} \
      --add-flags ${lib.escapeShellArg commandLineArgs}

    runHook postInstall
  '';

  postInstall =
    lib.strings.optionalString withOpenASAR ''
      cp -f ${openasar} $out/Applications/${desktopName}.app/Contents/Resources/app.asar
    ''
    + lib.strings.optionalString withVencord ''
      mv $out/Applications/${desktopName}.app/Contents/Resources/app.asar $out/Applications/${desktopName}.app/Contents/Resources/_app.asar
      mkdir $out/Applications/${desktopName}.app/Contents/Resources/app.asar
      echo '{"name":"discord","main":"index.js"}' > $out/Applications/${desktopName}.app/Contents/Resources/app.asar/package.json
      echo 'require("${vencord}/patcher.js")' > $out/Applications/${desktopName}.app/Contents/Resources/app.asar/index.js
    ''

    + lib.strings.optionalString withMoonlight ''
      mv $out/Applications/${desktopName}.app/Contents/Resources/app.asar $out/Applications/${desktopName}.app/Contents/Resources/_app.asar
      mkdir $out/Applications/${desktopName}.app/Contents/Resources/app.asar
      echo '{"name":"discord","main":"injector.js","private": true}' > $out/Applications/${desktopName}.app/Contents/Resources/app.asar/package.json
      echo 'require("${moonlight}/injector.js").inject(require("path").join(__dirname, "../_app.asar"));' > $out/Applications/${desktopName}.app/Contents/Resources/app.asar/injector.js
    '';

  passthru = {
    # make it possible to run disableBreakingUpdates standalone
    inherit disableBreakingUpdates updateScript;
  };
}
