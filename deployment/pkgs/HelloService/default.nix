{stdenv, apacheAnt}:

stdenv.mkDerivation {
  name = "HelloService";
  src = ../../../services/HelloService;
  buildInputs = [ apacheAnt ];
  buildPhase = ''ant generate.service.aar'';
  installPhase = ''
    ensureDir $out/webapps/axis2/WEB-INF/services
    cp *.aar $out/webapps/axis2/WEB-INF/services
  '';
}