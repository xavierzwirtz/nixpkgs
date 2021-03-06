{ stdenv, fetchFromGitHub, python3 }:

with python3.pkgs;

buildPythonApplication rec {
  pname = "thonny";
  version = "3.2.6";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "19krnxpp3i1n65zafazvdm9mvnjry5rml0y9imj4365q4bkj20g2";
  };

  propagatedBuildInputs = with python3.pkgs; [
    jedi
    pyserial
    tkinter
    docutils
    pylint
    mypy
    pyperclip
    asttokens
    send2trash
  ];

  preInstall = ''
    export HOME=$(mktemp -d)
  '';

  preFixup = ''
    wrapProgram "$out/bin/thonny" \
       --prefix PYTHONPATH : $PYTHONPATH:$(toPythonPath ${python3.pkgs.jedi})
  '';

  # Tests need a DISPLAY
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Python IDE for beginners";
    longDescription = ''
      Thonny is a Python IDE for beginners. It supports different ways
      of stepping through the code, step-by-step expression
      evaluation, detailed visualization of the call stack and a mode
      for explaining the concepts of references and heap.
    '';
    homepage = https://www.thonny.org/;
    license = licenses.mit;
    maintainers = with maintainers; [ leenaars ];
    platforms = platforms.linux;
  };
}
