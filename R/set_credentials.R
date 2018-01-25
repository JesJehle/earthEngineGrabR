set_credentials <- function() {
  
  if (Sys.info()["sysname"] == "Linux") {
    
    path = "./scripts/authenticate_linux.sh"
    command = "bash"
    system2(command, args = path)
  } 
  if (Sys.info()["sysname"] == "Windows") {
    print("I am sorry, no implementation on windows yet")
    #path = "~/Documents/Ms_Arbeit/test/authenticate_windows.sh"
    #command = "bash"
    #system2(command, args = path)
  }
}
