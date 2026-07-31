{ lib
, stdenv
, fetchFromGitHub
, buildNpmPackage
, nodejs_22
, electron_39
, python3
, pkg-config
, vips
, git
, makeBinaryWrapper
}:

let
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "samuelthomas2774";
    repo = "nxapi";
    rev = "v${version}";
    hash = "sha256-O2AN3eiZknwyI1SAInDck7ou79SpnWFWdFKoZeArVaY=";
    # rollup.config.js appelle `git rev-parse HEAD` -> .git necessaire
    leaveDotGit = true;
  };

  # package-lock.json deja present dans le repo git
in
buildNpmPackage rec {
  pname = "nxapi-electron";
  inherit version src;

  nodejs = nodejs_22;

  # register-scheme est une dep git optionnelle (depuis discord-rpc)
  forceGitDeps = true;

  npmDepsHash = "sha256-5SORJHxpBLeje5XRPP36gesiary3qpnI8MdvTAsL8yM=";

  nativeBuildInputs = [ python3 pkg-config makeBinaryWrapper git ];

  # sharp (module natif) doit etre compile contre libvips de nix
  buildInputs = [ vips ];

  # Build: tsc -> rollup (produit dist/bundle/ + dist/app/bundle/)
  dontNpmInstall = false;

  # Pas de script "build" dans package.json -> on desactive le build npm
  # et on lance tsc + rollup manuellement dans postConfigure
  dontNpmBuild = true;

  # Electron npm package tente de telecharger le binaire electron depuis GitHub
  # -> bloque en sandbox. On utilise electron_39 de nixpkgs au runtime.
  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  # Compile TS -> JS, puis bundle via rollup
  # rollup.config.js appelle `git rev-parse HEAD` (git dans nativeBuildInputs)
  postConfigure = ''
    export NODE_ENV=production
    npx tsc
    npx rollup --config
  '';

  # NE PAS lancer electron-builder : on assemble l'app manuellement
  # Utilise l'electron de nixpkgs au runtime
  postInstall = ''
    mkdir -p $out/lib/nxapi-app
    cp -r dist $out/lib/nxapi-app/
    cp -r resources/app $out/lib/nxapi-app/resources-app

    # Wrapper lance electron de nixpkgs sur le bundle
    makeBinaryWrapper ${electron_39}/bin/electron $out/bin/nxapi-app \
      --add-flags $out/lib/nxapi-app/dist/bundle/app-entry.cjs

    # .desktop + icone
    mkdir -p $out/share/applications
    cat > $out/share/applications/nxapi-app.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=Nintendo Switch Online
    Comment=nxapi Electron app
    Exec=nxapi-app
    Icon=nxapi-app
    Categories=Utility;
    EOF
  '';

  meta = {
    description = "Nintendo Switch Online/Parental Controls app APIs - Electron app";
    homepage = "https://github.com/samuelthomas2774/nxapi";
    license = lib.licenses.agpl3Plus;
    mainProgram = "nxapi-app";
    platforms = lib.platforms.linux;
  };
}