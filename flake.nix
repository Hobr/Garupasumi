{
  inputs = {
    flakelight.url = "github:nix-community/flakelight";
  };

  outputs =
    { flakelight, ... }@inputs:
    flakelight ./. {
      inherit inputs;

      nixpkgs.config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };

      devShell =
        pkgs:
        let
          llvmPkgs = pkgs.llvmPackages_latest;

          androidSdk = pkgs.androidenv.composeAndroidPackages {
            platformVersions = [ "35" ];
            ndkVersions = [ "28.2.13676358" ];
            includeNDK = true;
            includeEmulator = false;
            includeSystemImages = false;
            includeSources = false;
          };
        in
        {
          stdenv = llvmPkgs.stdenv;

          packages =
            (with pkgs; [
              pre-commit
              cmake
              ninja
              coreutils
              androidSdk.androidsdk
            ])
            ++ (with llvmPkgs; [
              llvm
              clang-tools
              lldb
            ]);

          env = rec {
            ANDROID_HOME = "${androidSdk.androidsdk}/libexec/android-sdk/";
            ANDROID_SDK_ROOT = ANDROID_HOME;
          };

          shellHook = ''
            export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$PATH"
          '';
        };
    };
}
