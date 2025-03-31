{
  pkgs,
  variant ? "CUDA",
  cstr,
  img2texture,
  pilgram,
  spandrel,
  spandrel_extra_arches,
  ...
}: let
  hardware_deps = with pkgs;
  #if variant == "CUDA" then [
    [
      cudatoolkit
      cudaPackages.cuda_nvcc
      cudaPackages.cuda_cuobjdump
      cudaPackages.cuda_nvdisasm
      cudaPackages.cuda_cudart
      cudaPackages.cuda_cupti
      linuxKernel.packages.linux_xanmod_latest.nvidia_x11_production_open
      xorg.libXi
      xorg.libXmu
      freeglut
      xorg.libXext
      xorg.libX11
      xorg.libXv
      xorg.libXrandr
      zlib

      # for xformers
      pkg-config
      gcc
    ];
  #else if variant == "ROCM" then [
  #  rocmPackages.rocm-runtime
  #  pciutils
  #] else if variant == "CPU" then [
  #] else throw "You need to specify which variant you want: CPU, ROCm, or CUDA.";
              #substituteInPlace python/setup.py \
              #  --replace "/usr/local/cuda/bin/ptxas" "${pkgs.cudaPackages.cuda_nvcc}/bin/ptxas"
              #mkdir -p $out/lib/python3.11/site-packages/triton/third_party/cuda/bin
              #ln -s ${pkgs.cudaPackages.cuda_nvcc}/bin/ptxas $out/lib/python3.11/site-packages/triton/third_party/cuda/bin/ptxas
in
  pkgs.mkShell rec {
    name = "stable-diffusion-webui";

    buildInputs = with pkgs;
      hardware_deps
      ++ [
        git # The program instantly crashes if git is not present, even if everything is already downloaded
        ncurses5
        binutils
        gitRepo
        gnupg
        autoconf
        curl
        procps
        gnumake
        util-linux
        m4
        gperf
        unzip
        libGLU
        libGL
        glibc
        ffmpeg
        freeglut

        (python311.withPackages (python-pkgs: with python-pkgs; [
          #python-pkgs.pytorch.override ({
          #  cudaSupport = true; # Enable CUDA support
          #})
          # python-pkgs.pytorch-bin
          # python-pkgs.torchWithCuda
          # python-pkgs.torchWithCuda.lib
          # python-pkgs.triton
          #python-pkgs.triton.override ({
          #  pythonRemoveDeps = [ "torch" ];
          #  cudaSupport = true;
          #})
          #python-pkgs.triton.override ({
          #  # patchPhase = ''
          #  #   substituteInPlace python/setup.py \
          #  #     --replace "/usr/local/cuda/bin/ptxas" "${pkgs.cudaPackages.cuda_nvcc}/bin/ptxas"
          #  #   mkdir -p $out/lib/python3.11/site-packages/triton/third_party/cuda/bin
          #  #   ln -sf ${pkgs.cudaPackages.cuda_nvcc}/bin/ptxas $out/lib/python3.11/site-packages/triton/third_party/cuda/bin/ptxas
          #  # '';
          #  # cudaPackages = {
          #  #   cuda_nvcc = pkgs.cudaPackages.cuda_nvcc;
          #  #   cuda_cudart = pkgs.cudaPackages.cuda_cudart;
          #  #   cuda_cupti = pkgs.cudaPackages.cuda_cupti;
          #  #   cuda_nvdisasm = pkgs.cudaPackages.cuda_nvdisasm;
          #  #   cuda_cuobjdump = pkgs.cudaPackages.cuda_cuobjdump;
          #  # };
          #  #cudaSupport = true; # Enable CUDA support
          #})
          # torch
          # triton
          torchvision
          torchaudio
          torchsde
          einops
          transformers
          safetensors
          aiohttp
          pyyaml
          pillow
          scipy
          tqdm
          psutil
          kornia
          numba
          # .override ({ version = "0.60.0"; })
          opencv4
          GitPython
          numexpr
          matplotlib
          pandas
          imageio-ffmpeg
          scikit-image
          pip
          simpleeval
          (pkgs.callPackage ./dynamicprompts.nix {
            buildPythonPackage = python-pkgs.buildPythonPackage;
            fetchFromGitHub = pkgs.fetchFromGitHub;
            setuptools = python-pkgs.setuptools;
            lib = pkgs.lib;  # if your file uses "with lib;"
            hatchling = python-pkgs.hatchling;
            pyparsing = python-pkgs.pyparsing;
            jinja2 = python-pkgs.jinja2;
          })

          spandrel
          # = (pkgs.callPackage ./spandrel.nix {
          # })

          spandrel_extra_arches
          # (pkgs.callPackage ./spandrel_extra_arches.nix {
          # })
          accelerate

          # WAS Nodes Deps
          fairscale
          cstruct
          joblib
          llvmlite
          opencv-python-headless
          ffmpy.override ({
            version = "0.3.0";
          })
          rpds-py
          scikit-learn
          timm
          cmake
          referencing
          platformdirs
          img2texture
          cstr
          pilgram
        ]))
      ];

    nativeBuildInputs = with pkgs; [
      stdenv.cc
      stdenv.cc.cc.lib
      pkg-config
    ];


    CUDA_PATH="${pkgs.cudatoolkit}";
    LD_LIBRARY_PATH="${with pkgs; lib.makeLibraryPath [
      stdenv.cc.cc.lib
      linuxKernel.packages.linux_xanmod_latest.nvidia_x11_production_open
      cudatoolkit
      libGL
      libGLU
      cudaPackages.cuda_nvcc
      cudaPackages.cuda_cuobjdump
      cudaPackages.cuda_nvdisasm
      cudaPackages.cuda_cudart
      cudaPackages.cuda_cupti
    ]}";
    EXTRA_LDFLAGS="-L/lib -L${pkgs.cudatoolkit}/lib:${pkgs.cudatoolkit}/lib64 -L${pkgs.linuxKernel.packages.linux_xanmod_latest.nvidia_x11_production_open}/lib";
    EXTRA_CCFLAGS="-I/usr/include";
  }
