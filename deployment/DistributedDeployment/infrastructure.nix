/*
 * This Nix expression captures all the machines in the network and its properties
 */
{
  test1 = {
    hostname = "10.0.2.2";
    tomcatPort = 8081;
    targetEPR = http://10.0.2.2:8081/DisnixService/services/DisnixService;
    sshTarget = "localhost:2222";
  };
  
  test2 = {
    hostname = "10.0.2.2";
    tomcatPort = 8082;
    mysqlPort = 3307;
    mysqlUsername = "root";
    mysqlPassword = builtins.readFile ../configurations/mysqlpw;
    targetEPR = http://10.0.2.2:8082/DisnixService/services/DisnixService;
    sshTarget = "localhost:2223";
  }; 
}
