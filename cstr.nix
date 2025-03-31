{
  lib, buildPythonPackage, fetchFromGitHub, ...
}:

buildPythonPackage rec {
  pname = "cstr";
  version = "0520c29a18a7a869a6e5983861d6f7a4c86f8e9b";

  src = fetchFromGitHub {
    owner = "WASasquatch";
    repo = pname;
    rev = version;
    hash = "sha256-zQDnjUk7IFVkWujPxq8JfUH6XIPHoaEG+xrLOEwXoro=";
  };

  # Point build to the correct directory
  # sourceRoot = "source/libs/spandrel";

  nativeBuildInputs = [ ];

  pythonImportsCheck = [
    "cstr"
  ];

  meta = with lib; {
    description = "Provides a method for printing colored messages to console with preset tags.";
    homepage = "https://github.com/WASasquatch/cstr";
    license = licenses.mit;
    maintainers = [];
  };
}

