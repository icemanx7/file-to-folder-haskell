{ mkDerivation, base, directory, filepath, hip, stdenv }:
mkDerivation {
  pname = "project0";
  version = "1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base directory filepath hip ];
  license = stdenv.lib.licenses.bsd3;
}
