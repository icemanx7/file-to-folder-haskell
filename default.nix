{ mkDerivation, base, directory, filepath, stdenv }:
mkDerivation {
  pname = "filetofolder";
  version = "1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base directory filepath ];
  license = stdenv.lib.licenses.bsd3;
}
