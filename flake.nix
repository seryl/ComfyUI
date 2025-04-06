{
  description = "AUTOMATIC1111/stable-diffusion-webui flake";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: let
    isLinux = system: builtins.match ".*linux.*" system != null;
    linuxSystems = builtins.filter isLinux flake-utils.lib.defaultSystems;
  in
    flake-utils.lib.eachSystem linuxSystems (system: let
      # Define pkgs with overlays
      myOverlay = final: prev: {
        # Use CUDA 12.8 toolkit throughout
        cudaPackages = prev.cudaPackages_12_8;

        python311Packages = prev.python311Packages.override {
          overrides = pfinal: pprev: {
            # Create a custom PyTorch 2.7.0 nightly package from wheel
            torch-nightly = final.python311Packages.buildPythonPackage {
              pname = "torch";
              version = "2.8.0.dev20250320";
              format = "wheel";

              src = final.fetchurl {
                url = "https://download.pytorch.org/whl/nightly/cu128/torch-2.7.0.dev20250312%2Bcu128-cp311-cp311-manylinux_2_28_x86_64.whl";
                hash = "sha256-o6V/JQHiC1UONAMtdyERw8Cp5AhMxBLyN7dT0xrAHIE=";
              };

              propagatedBuildInputs = with final.python311Packages; [
                numpy
                typing-extensions
                sympy
                networkx
                jinja2
                filelock
              ];

              nativeBuildInputs = [
                final.autoPatchelfHook
              ];

              buildInputs = [
                final.cudaPackages.cudatoolkit
                final.cudaPackages.cudnn
              ];

              # Auto-detect runtime dependencies
              autoPatchelfIgnoreMissingDeps = true;

              meta = with prev.lib; {
                description = "PyTorch 2.8.0 nightly build with CUDA support";
                homepage = "https://pytorch.org/";
                license = licenses.bsd3;
              };
            };

            # Use the custom nightly package instead of the standard one
            torch = final.python311Packages.torch-nightly;

            # Create a compatible torchvision package (if needed)
            torchvision-nightly = final.python311Packages.buildPythonPackage {
              pname = "torchvision";
              version = "0.22.0.dev20250204";
              format = "wheel";

              src = final.fetchurl {
                url = "https://download.pytorch.org/whl/nightly/cu128/torchvision-0.22.0.dev20250204%2Bcu128-cp311-cp311-linux_x86_64.whl";
                hash = "sha256-PGy4covItvG4BqjsYfKTnWgvOfGYgzQ4eu5sMS+Y7Jc=";
              };

              propagatedBuildInputs = with final.python311Packages; [
                torch-nightly
                numpy
                pillow
                requests
              ];

              nativeBuildInputs = [
                final.autoPatchelfHook
              ];

              buildInputs = [
                final.cudaPackages.cudatoolkit
              ];

              autoPatchelfIgnoreMissingDeps = true;

              meta = with prev.lib; {
                description = "PyTorch vision library nightly build";
                homepage = "https://pytorch.org/";
                license = licenses.bsd3;
              };
            };

            # Use the custom nightly torchvision
            torchvision = final.python311Packages.torchvision-nightly;

            opencv4 = prev.python311Packages.opencv4.override {
              enablePython = true;
              pythonPackages = final.python311Packages;
              torch = pfinal.torch;
            };

            opencv-python-headless = prev.python311Packages.opencv-python-headless.override {
              enablePython = true;
              pythonPackages = final.python311Packages;
              torch = pfinal.torch;
            };
          };
        };
      };

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
        overlays = [myOverlay];
      };

      # Declare extra python packages
      cstr = pkgs.callPackage ./cstr.nix {
        buildPythonPackage = pkgs.python311Packages.buildPythonPackage;
        fetchFromGitHub = pkgs.fetchFromGitHub;
        lib = pkgs.lib;
      };

      img2texture = pkgs.callPackage ./img2texture.nix {
        buildPythonPackage = pkgs.python311Packages.buildPythonPackage;
        fetchFromGitHub = pkgs.fetchFromGitHub;
        lib = pkgs.lib;
        mypy = pkgs.python311Packages.mypy;
        pillow = pkgs.python311Packages.pillow;
      };

      pilgram = pkgs.callPackage ./pilgram.nix {
        buildPythonPackage = pkgs.python311Packages.buildPythonPackage;
        fetchFromGitHub = pkgs.fetchFromGitHub;
        lib = pkgs.lib;
        pillow = pkgs.python311Packages.pillow;
        numpy = pkgs.python311Packages.numpy;
        setuptools = pkgs.python311Packages.setuptools;
      };

      spandrel = pkgs.callPackage ./spandrel.nix {
        buildPythonPackage = pkgs.python311Packages.buildPythonPackage;
        fetchFromGitHub = pkgs.fetchFromGitHub;
        lib = pkgs.lib;
        torch = pkgs.python311Packages.torch;
        torchvision = pkgs.python311Packages.torchvision;
        numpy = pkgs.python311Packages.numpy;
        einops = pkgs.python311Packages.einops;
        typing-extensions = pkgs.python311Packages.typing-extensions;
        safetensors = pkgs.python311Packages.safetensors;
      };

      spandrel_extra_arches = pkgs.callPackage ./spandrel_extra_arches.nix {
        buildPythonPackage = pkgs.python311Packages.buildPythonPackage;
        fetchFromGitHub = pkgs.fetchFromGitHub;
        lib = pkgs.lib;
        torch = pkgs.python311Packages.torch;
        torchvision = pkgs.python311Packages.torchvision;
        numpy = pkgs.python311Packages.numpy;
        einops = pkgs.python311Packages.einops;
        typing-extensions = pkgs.python311Packages.typing-extensions;
        spandrel = spandrel;
      };
    in {
      # Define devShells
      devShells.default = import ./impl.nix {
        inherit pkgs cstr img2texture pilgram;
        # spandrel spandrel_extra_arches;
        variant = "CUDA";
      };
      devShells.rocm = import ./impl.nix {
        inherit pkgs cstr img2texture pilgram;
        # spandrel spandrel_extra_arches;
        variant = "ROCM";
      };
    });
}
