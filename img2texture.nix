{
  lib, buildPythonPackage, fetchFromGitHub,
  mypy, pillow, ...
  # chkpkg, ...
  # click, pyinstaller, neatest, ...
}:

buildPythonPackage rec {
  pname = "img2texture";
  version = "d6159abea44a0b2cf77454d3d46962c8b21eb9d3";

  src = fetchFromGitHub {
    owner = "WASasquatch";
    repo = pname;
    rev = version;
    hash = "sha256-58me9Rng+hy1ntUBJ8cUVVrk+CEFgmW/ATnzYk7N8U4=";
  };

  # Point build to the correct directory
  # sourceRoot = "source/libs/spandrel";

  nativeBuildInputs = [ mypy pillow ];

  pythonImportsCheck = [
    "img2texture"
  ];

  meta = with lib; {
    description = "Programmable Module and CLI for converting images to seamless tiles";
    homepage = "https://github.com/WASasquatch/img2texture";
    license = licenses.mit;
    maintainers = [];
  };
}

