{ stdenv, fetchurl, jre
, fetchFromGitHub, cmake, ninja, pkgconfig, libuuid, darwin }:

let
  version = "4.7.2";
  source = fetchFromGitHub {
    owner = "antlr";
    repo = "antlr4";
    rev = version;
    sha256 = "1pl0zs6c6wx9nmq30s7ccpc3dl72az55i8vfp574fw9sywmvxmlj";
  };

  runtime = {
    cpp = stdenv.mkDerivation {
      pname = "antlr-runtime-cpp";
      inherit version;
      src = source;

      outputs = [ "out" "dev" "doc" ];

      nativeBuildInputs = [ cmake ninja pkgconfig ];
      buildInputs = stdenv.lib.optional stdenv.isLinux libuuid
        ++ stdenv.lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.CoreFoundation;

      postUnpack = ''
        export sourceRoot=$sourceRoot/runtime/Cpp
      '';

      meta = with stdenv.lib; {
        description = "C++ target for ANTLR 4";
        homepage = https://www.antlr.org/;
        license = licenses.bsd3;
        platforms = platforms.unix;
      };
    };
  };

  antlr = stdenv.mkDerivation {
    pname = "antlr";
    inherit version;

    src = fetchurl {
      url ="https://www.antlr.org/download/antlr-${version}-complete.jar";
      sha256 = "1d40nfkq3ws8g4ksx4gj6l6m2l9j4b605q6sf68z5vvmg5nkhlk8";
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p "$out"/{share/java,bin}
      cp "$src" "$out/share/java/antlr-${version}-complete.jar"

      echo "#! ${stdenv.shell}" >> "$out/bin/antlr"
      echo "'${jre}/bin/java' -cp '$out/share/java/antlr-${version}-complete.jar:$CLASSPATH' -Xmx500M org.antlr.v4.Tool \"\$@\"" >> "$out/bin/antlr"

      echo "#! ${stdenv.shell}" >> "$out/bin/grun"
      echo "'${jre}/bin/java' -cp '$out/share/java/antlr-${version}-complete.jar:$CLASSPATH' org.antlr.v4.gui.TestRig \"\$@\"" >> "$out/bin/grun"

      chmod a+x "$out/bin/antlr" "$out/bin/grun"
      ln -s "$out/bin/antlr"{,4}
    '';

    inherit jre;

    passthru = {
      inherit runtime;
      jarLocation = "${antlr}/share/java/antlr-${version}-complete.jar";
    };

    meta = with stdenv.lib; {
      description = "Powerful parser generator";
      longDescription = ''
        ANTLR (ANother Tool for Language Recognition) is a powerful parser
        generator for reading, processing, executing, or translating structured
        text or binary files. It's widely used to build languages, tools, and
        frameworks. From a grammar, ANTLR generates a parser that can build and
        walk parse trees.
      '';
      homepage = https://www.antlr.org/;
      license = licenses.bsd3;
      platforms = platforms.unix;
    };
  };
in antlr
