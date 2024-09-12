{ stdenv, lib, fetchFromGitHub, kernel }:

stdenv.mkDerivation {
  name = "msi_ec_patch-${kernel.version}";

  src = fetchFromGitHub {
    owner = "BeardOverflow";
    repo = "msi-ec";
    rev = "e5820a2b415e796db9dfb204250f7410b6662ac2";
    hash = "sha256-1nwIf5OWjJpLLRUKeSOcZ1yvBGE51rUAZLmZjkt8K04=";
  };

  sourceRoot = ".";
  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    # "INSTALL_MOD_PATH=$(out)"
  ];

  meta = with lib; {
    description = "Embedded Controller for MSI laptops";
    homepage = "https://github.com/BeardOverflow/msi-ec";
    license = licenses.gpl2;
    maintainers = [ maintainers.makefu ];
    platforms = platforms.linux;
  };
}
