{ stdenv, lib, jdk, makeWrapper }:

stdenv.mkDerivation {
  pname = "papercut-user-client";
  version = "PaperCut NG 18.3.5 (Build 48033)"; # You can change this to your client version

  # This tells Nix to use the files you downloaded in Part 1
  src = ./papercut-client-files;

  # Add dependencies
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jdk ]; # The client requires Java [cite: 506]

  # Don't try to build anything, just install
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    # Create directories in the Nix store
    mkdir -p $out/lib/papercut
    mkdir -p $out/bin

    # Copy all the client files into the package
    cp -r $src/* $out/lib/papercut/
    chmod +x $out/lib/papercut/pc-client-linux.sh

    # Create a wrapper script in $out/bin.
    # This ensures the script can find the correct Java path.
    makeWrapper $out/lib/papercut/pc-client-linux.sh $out/bin/papercut-client \
      --set JAVA_HOME "${jdk.home}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "PaperCut User Client (DEI)";
    platforms = platforms.linux;
  };
}