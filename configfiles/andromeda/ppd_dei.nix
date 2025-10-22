{ stdenv }:

stdenv.mkDerivation {
  pname = "dei-printer-ppds";
  version = "1.0";

  # Point to the directory containing your PPD files
  src = ./ppd;

  # We don't need to build, just install
  installPhase = ''
    runHook preInstall
    
    # CUPS looks for PPDs in .../share/cups/model/
    # We create a subdirectory 'dei' to keep them organized
    mkdir -p $out/share/cups/model/dei
    cp $src/*.ppd $out/share/cups/model/dei/
    
    runHook postInstall
  '';

  meta = {
    description = "DEI Konica Minolta PPD files";
  };
}