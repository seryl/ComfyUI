{
  lib, buildPythonPackage, fetchFromGitHub,
  setuptools, pillow, numpy, ...
}:

buildPythonPackage rec {
  pname = "pilgram";
  version = "v1.2.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "akiomik";
    repo = pname;
    rev = "refs/tags/${version}";
    hash = "sha256-Z6hVLeq2uI/CWKRJ0wM1cjoube+g69mrOl40/7tGykw=";
  };

  # Point build to the correct directory
  # sourceRoot = "source/libs/spandrel";

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    pillow
    numpy
  ];

  pythonImportsCheck = [
    "pilgram"
  ];

  meta = with lib; {
    description = "A python library for instagram filters";
    homepage = "https://github.com/akiomik/pilgram";
    license = licenses.mit;
    maintainers = [];
  };
}

