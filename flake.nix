{
  inputs = {
    flakelight.url = "github:nix-community/flakelight";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    { flakelight, ... }@inputs:
    flakelight ./. {
      inherit inputs;

      nixpkgs.config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };

      withOverlays = [
        inputs.rust-overlay.overlays.default

        (final: prev: {
          rustToolchain =
            let
              rust = prev.rust-bin;
            in
            if builtins.pathExists ./rust-toolchain.toml then
              rust.fromRustupToolchainFile ./rust-toolchain.toml
            else if builtins.pathExists ./rust-toolchain then
              rust.fromRustupToolchainFile ./rust-toolchain
            else
              rust.stable."1.98.1".default.override {
                extensions = [
                  "rust-src"
                  "rustfmt"
                  "rust-analyzer"
                  "clippy"
                  "cargo"
                  "llvm-tools"
                ];
              };
        })
      ];

      devShell =
        pkgs:
        let
          jdk = pkgs.openjdk21_headless;

          maven = pkgs.maven.override {
            jdk_headless = jdk;
          };

          gradle = pkgs.gradle_8.override {
            java = jdk;
          };

          androidSdk = pkgs.androidenv.composeAndroidPackages {
            platformVersions = [
              "24"
              "35"
            ];
            buildToolsVersions = [ "35.0.0" ];
            includeEmulator = false;
            includeSystemImages = false;
            includeSources = false;
          };
        in
        {
          packages =
            with pkgs;
            [
              pkg-config
              openssl

              pre-commit
              just
              just-lsp

              rustToolchain
              cargo-binstall

              jdk
              gradle
              androidSdk.androidsdk

              python3

              (jdt-language-server.override {
                inherit jdk;
              })

              (kotlin-language-server.override {
                openjdk = jdk;
                inherit maven gradle;
              })
            ]
            ++ (with python3Packages; [
              venvShellHook
              pip
            ]);

          env = {
            venvDir = ".venv";
            RUST_SRC_PATH = "${pkgs.rustToolchain}/lib/rustlib/src/rust/library";
            ANDROID_HOME = "${androidSdk.androidsdk}/libexec/android-sdk/";
            ANDROID_SDK_ROOT = "${androidSdk.androidsdk}/libexec/android-sdk/";
          };

          shellHook = ''
            export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$PATH"

            export CARGO_HOME="$PWD/.cargo"
            export PATH="$CARGO_HOME/bin:$PWD/target/debug:$PATH"
          '';
        };
    };
}
