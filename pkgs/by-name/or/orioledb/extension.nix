{
  curl,
  fetchFromGitHub,
  lib,
  postgresql,
  postgresqlBuildExtension,
  postgresqlTestExtension,
  python3,
}:

postgresqlBuildExtension (finalAttrs: {
  pname = "orioledb";
  # SQL extension version is 1.7, official version is beta15
  version = "1.7-beta15-unstable-2026-05-11";

  src = fetchFromGitHub {
    owner = "orioledb";
    repo = "orioledb";
    rev = "d2994ba9b7901f01614c3086a86e1b8762363f3a";
    hash = "sha256-J21PIjT75iPNBJsTEBq+vL8MaaRSDfYTdnok/WslKyw=";
  };

  buildInputs = postgresql.buildInputs ++ [
    curl
  ];

  nativeBuildInputs = [
    python3
  ];

  makeFlags = [ "USE_PGXS=1" ];

  meta = {
    inherit (postgresql.meta) description maintainers;
    license = lib.licenses.OR [
      lib.licenses.asl20
      lib.licenses.postgresql
    ];
  };
})
