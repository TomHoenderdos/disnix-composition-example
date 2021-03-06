{stdenv, apacheAnt, axis2}:
{HelloWorldService ? null}:

stdenv.mkDerivation {
  name = "HelloWorld";
  src = ../../../services/HelloWorld;
  buildInputs = [ apacheAnt ];
  AXIS2_LIB = "${axis2}/lib";
  buildPhase =
    (if HelloWorldService == null then "" else ''
        # Write the connection settings of the HelloService to a properties file
        echo "helloworldservice.targetEPR=http://${HelloWorldService.target.hostname}:${toString HelloWorldService.target.tomcatPort}/${HelloWorldService.name}/services/${HelloWorldService.name}" > src/org/nixos/disnix/example/helloworld/helloworld.properties
      '') +
    ''
      # Generate the webapplication archive
      ant generate.war
    '';
  installPhase = ''    
    ensureDir $out/webapps
    cp *.war $out/webapps
  '';
}
