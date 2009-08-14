{stdenv, apacheAnt, axis2}:
{HelloWorldService2 ? null, LookupService ? null}:

stdenv.mkDerivation {
  name = "HelloWorld2";
  src = ../../../services/HelloWorld2;
  buildInputs = [ apacheAnt ];
  AXIS2_LIB = "${axis2}/share/java/axis2";
  buildPhase =
    (if LookupService == null then "" else ''
        # Write the connection settings of the LookupService to a properties file
        echo "lookupservice.targetEPR=http://${LookupService.target.hostname}:${toString LookupService.target.tomcatPort}/axis2/services/${LookupService.name}" > src/org/nixos/disnix/example/helloworld/helloworld2.properties
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