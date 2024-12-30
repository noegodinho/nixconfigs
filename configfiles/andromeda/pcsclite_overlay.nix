final: prev:
{
  pcsclite = prev.pcsclite.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "LudovicRousseau";
      repo = "PCSC";
      rev = "33a028a9750eb33fb2fb7463a9924852b474d633";
      hash = "";
    };
  });
}