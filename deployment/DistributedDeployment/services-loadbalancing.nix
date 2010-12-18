/*
 * This Nix expression captures all the components of a distributed system that
 * can be installed on machines in a network.
 *
 * This model also captures the inter-dependencies of a service and its type
 * which is used to decide how to activate and deactive services. 
 */
 
{distribution, system}:

# Import the packages model of the Hello World example, which captures the intra-dependencies
let
  pkgs = import ../top-level/all-packages.nix { 
    inherit distribution; # Pass distribution model to the packages model, so that the lookup services can use them
    inherit services; # Pass services model to the packages model, so that the lookup services can use them
    inherit system;
  };
  
  services = rec {
    HelloService = {
      name = "HelloService";
      pkg = pkgs.HelloService;
      dependsOn = {};
      type = "tomcat-webapplication";
    };
    
    HelloWorldService2 = {
      name = "HelloWorldService2";
      pkg = pkgs.HelloWorldService2;
      dependsOn = {
        LookupService = LookupService2; # Use the advanced load balancing lookup service
        inherit HelloService;
      };
      type = "tomcat-webapplication";
    };
    
    LookupService2 = {
      name = "LookupService2";
      pkg = pkgs.LookupService2;
      dependsOn = {};
      type = "tomcat-webapplication";
    };
    
    HelloWorld2 = {
      name = "HelloWorld2";
      pkg = pkgs.HelloWorld2;
      dependsOn = {
        HelloWorldService = HelloWorldService2;
        LookupService = LookupService2; # Use the advanced load balancing lookup service
      };
      type = "tomcat-webapplication";
    };
  };
in
services