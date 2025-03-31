{
  lib, buildPythonPackage, fetchFromGitHub,
  torch, torchvision, numpy, einops, typing-extensions, safetensors, ...
}:

buildPythonPackage rec {
  pname = "spandrel";
  version = "v0.4.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "chaiNNer-org";
    repo = pname;
    rev = "refs/tags/${version}";
    hash = "sha256-BiC4gmRsNkRAUonKHV7U/hvOP00pIPtm40ydmSlNDCI=";
  };

  # Point build to the correct directory
  sourceRoot = "source/libs/spandrel";

  nativeBuildInputs = [ ];

  propagatedBuildInputs = [
    torch
    torchvision
    numpy
    einops
    typing-extensions
    safetensors
  ];

  pythonImportsCheck = [
    "spandrel"
  ];

  meta = with lib; {
    description = "Support for a variety of PyTorch model architectures";
    homepage = "https://github.com/chaiNNer-org/spandrel";
    license = licenses.mit;
    maintainers = [];
  };
}

