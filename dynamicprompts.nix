{
  lib, buildPythonPackage, fetchFromGitHub, setuptools, hatchling, pyparsing, jinja2, ...
}:


buildPythonPackage rec {
  pname = "dynamicprompts";
  version = "v0.30.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "adieyal";
    repo = pname;
    rev = "refs/tags/${version}";
    hash = "sha256-qNQ0mLaukrf7+KLJD65GJ22tTkalHF6B/YJyIvv00EU=";
  };

  nativeBuildInputs = [ setuptools hatchling pyparsing jinja2 ];

  propogatedBuildInputs = [
    pyparsing
    jinja2
  ];

  #nativeCheckInputs = [ pytestCheckHook ];

  # pytestFlagsArray = [ "test_simpleeval.py" ];

  pythonImportsCheck = [ "dynamicprompts" ];

  meta = with lib; {
    description = "Templating language for generating prompts for text to image generators such as Stable Diffusion";
    homepage = "https://github.com/adieyal/dynamicprompts";
    changelog = "https://github.com/adieyal/dynamicprompts/releases/tag/${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ johbo ];
  };
}
