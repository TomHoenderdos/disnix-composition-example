{ nixpkgs ? /etc/nixos/nixpkgs
, nixos ? /etc/nixos/nixos
}:

let
  
  jobs = rec {
    tarball =
      { HelloWorldExample ? {outPath = ./.; rev = 1234;}
      , officialRelease ? false}:
    
      let
        pkgs = import nixpkgs {};
  
        disnixos = import "${pkgs.disnixos}/share/disnixos/testing.nix" {
          inherit nixpkgs nixos;
        };
      in
      disnixos.sourceTarball {
        name = "HelloWorldExample";
	version = builtins.readFile ./version;
	src = HelloWorldExample;
        inherit officialRelease;
      };
    
    doc =
      { tarball ? jobs.tarball {} }:
      
      with import nixpkgs {};
      
      releaseTools.nixBuild {
        name = "HelloWorldExample-doc";
	version = builtins.readFile ./version;
	src = tarball;
	buildInputs = [ libxml2 libxslt dblatex tetex ];
	
	buildPhase = ''
	  cd doc
	  make docbookrng=${docbook5}/xml/rng/docbook docbookxsl=${docbook5_xsl}/xml/xsl/docbook
	'';
	
	checkPhase = "true";
	
	installPhase = ''
	  make DESTDIR=$out install
	 
	  echo "doc manual $out/share/doc/HelloWorldExample/manual" >> $out/nix-support/hydra-build-products
	'';
      };

    build =
      { tarball ? jobs.tarball {}
      , system ? "x86_64-linux"
      }:
      
      let
        pkgs = import nixpkgs { inherit system; };
  
        disnixos = import "${pkgs.disnixos}/share/disnixos/testing.nix" {
          inherit nixpkgs nixos system;
        };
      in
      disnixos.buildManifest {
        name = "HelloWorldExample-composition";
	version = builtins.readFile ./version;
	inherit tarball;
	servicesFile = "deployment/DistributedDeployment/services-composition.nix";
	networkFile = "deployment/DistributedDeployment/network.nix";
	distributionFile = "deployment/DistributedDeployment/distribution-composition.nix";
      };
            
    tests = 
      let
        pkgs = import nixpkgs {};
  
        disnixos = import "${pkgs.disnixos}/share/disnixos/testing.nix" {
          inherit nixpkgs nixos;
        };
      in
      disnixos.disnixTest {
        name = "HelloWorldExample-composition";
        tarball = tarball {};
        manifest = build { system = "x86_64-linux"; };
	networkFile = "deployment/DistributedDeployment/network.nix";
	testScript =
	  ''
	    $test1->waitForFile("/var/tomcat/webapps/HelloWorld");
	    my $result = $test1->mustSucceed("sleep 30; curl --fail http://test1:8080/HelloWorld/index.jsp");
	    
	    # The entry page should contain Hello World
	    
	    if ($result =~ /Hello world/) {
	        print "Entry page contains: Hello world!\n";
	    }
	    else {
	        die "Entry page should contain Hello world!\n";
	    }
	    
	    $test3->mustSucceed("firefox http://test1:8080/HelloWorld &");
	    $test3->waitForWindow(qr/Aurora/);
	    $test3->mustSucceed("sleep 30");
	    $test3->screenshot("screen");
	  '';
      };
  };
in
jobs
