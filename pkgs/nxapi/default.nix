{ lib
, buildNpmPackage
, nodejs_22
, makeWrapper
, fetchurl
}:

let
  version = "1.6.1";

  # Le tarball npm contient dist/ (CLI precompilee) + bin/ + resources/
  # mais PAS package-lock.json (necessaire pour buildNpmPackage).
  srcTarball = fetchurl {
    url = "https://registry.npmjs.org/nxapi/-/nxapi-${version}.tgz";
    hash = "sha256-xDJ/s6jYgU4SCeqknCUm9avo5QHjExha1OZfWIXS7TU=";
  };

  # package-lock.json recupere depuis le tag git v1.6.1
  packageLock = fetchurl {
    url = "https://raw.githubusercontent.com/samuelthomas2774/nxapi/v${version}/package-lock.json";
    hash = "sha256-lnSDclqWoSJvXMmBjSLiPGNzvX7oSB/nFBn2UhDTS34=";
  };
in
buildNpmPackage rec {
  pname = "nxapi";
  inherit version;

  src = srcTarball;

  # Injecte le package-lock.json manquant dans le tarball npm
  postPatch = ''
    cp ${packageLock} package-lock.json
  '';

  # dist/ est deja present dans le tarball, pas besoin de tsc/rollup
  dontNpmBuild = true;

  # register-scheme est une dep git optionnelle (depuis discord-rpc)
  forceGitDeps = true;

  npmDepsHash = "sha256-5SORJHxpBLeje5XRPP36gesiary3qpnI8MdvTAsL8yM=";

  nodejs = nodejs_22;

  nativeBuildInputs = [ makeWrapper ];

  # Evite la recompilation native de sharp (utilise les prebuilt binaries)
  npmFlags = [ "--ignore-scripts" ];

  # Wrapper pour lancer via node
  postInstall = ''
    wrapProgram $out/bin/nxapi \
      --prefix PATH : ${lib.makeBinPath [ nodejs_22 ]}
  '';

  meta = {
    description = "Nintendo Switch Online/Parental Controls app APIs - CLI";
    homepage = "https://github.com/samuelthomas2774/nxapi";
    license = lib.licenses.agpl3Plus;
    mainProgram = "nxapi";
    platforms = lib.platforms.linux;
  };
}