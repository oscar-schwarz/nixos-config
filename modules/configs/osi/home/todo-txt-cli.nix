{ pkgs, lib, config, ... }:

with lib;


{
  options.programs.todo-txt-cli = {
    enable = mkEnableOption "todo-txt-cli";
    package = mkOption {
      type = types.package;
      default = pkgs.todo-txt-cli;
      defaultText = literalExample "todo-txt-cli";
      description = "The todo-txt-cli package to install";
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = ''
        # Define the path to your todo.txt file:                                      
        TODO_FILE=~/todo/todo.txt                                                     
                                                                                      
        # Define the path for the done.txt file (where completed tasks are archived): 
        DONE_FILE=~/todo/done.txt                                                     
                                                                                      
        # Optionally, define a path to the report file, if enabled:                   
        REPORT_FILE=~/todo/report.txt                                                 
                                                                                      
        # Enable colors (set to 1 to enable, 0 to disable):                           
        TODOTXT_FORCE_COLOR=1                                                         
                                                                                      
        # Default priority when adding new tasks without a specific priority:         
        # Uncomment and set to a priority if you wish, e.g., "A", "B", etc.           
        # TODOTXT_DEFAULT_PRIORITY=A                                                  
                                                                                      
        # Date format (Uncomment to use a specific format, e.g., "%Y-%m-%d"):         
        # TODOTXT_DATE_FORMAT="%Y-%m-%d"                                              
                                                                                      
        # Auto-archive completed tasks (set to 1 to enable, 0 to disable):            
        TODOTXT_AUTO_ARCHIVE=1                                                        
                                                                                      
        # Threshold age in days for tasks to be considered “old” for reporting:       
        # Uncomment and set to a value if you wish to enable age-based reporting.     
        # TODOTXT_AUTOREPORT_THRESHOLD=0                                              
                                                                                      
        # If using a different character encoding, set it here (e.g., "utf-8").       
        # TODO_TXT_ENCODING=utf-8
      '';
      description = ''
        Content of the todo.cfg config file.
      '';
    };
  };

  config = let cfg = config.programs.todo-txt-cli; in {
    home.packages =  [ cfg.package ];

    home.file.".todo/config".text = cfg.extraConfig;
  };
}
