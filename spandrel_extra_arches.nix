{ lib, buildPythonPackage, fetchFromGitHub,
  spandrel, torch, torchvision, numpy, einops, typing-extensions, ...
}:

buildPythonPackage rec {
  pname = "spandrel_extra_arches";
  version = "v0.4.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "chaiNNer-org";
    repo = "spandrel";
    rev = "refs/tags/v${version}";
    hash = "sha256-BiC4gmRsNkRAUonKHV7U/hvOP00pIPtm40ydmSlNDCI=";
  };

  # Point build to the correct directory
  sourceRoot = "source/libs/spandrel_extra_arches";


  propagatedBuildInputs = [
    spandrel
    torch
    torchvision
    numpy
    einops
    typing-extensions
  ];

  pythonImportsCheck = [
    "spandrel_extra_arches"
  ];

  meta = with lib; {
    description = "Extra model architectures for spandrel";
    homepage = "https://github.com/chaiNNer-org/spandrel";
    license = licenses.mit;
    maintainers = [];
  };
}

