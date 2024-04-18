### 1Password Scripts README

#### 1.CreateCommandsByGroupFromFile.ps1:
- **Purpose**: This script processes a set of email addresses stored in separate text files within the specified input directory. It formats these email addresses and generates commands to provision users and groups in 1Password using the 1Password CLI.
  
- **Instructions**:
  1. Set the `$inputDirectory` variable to the path containing your input text files.
  2. Set the `$outputDirectory` variable to the desired output directory for the generated commands.
  3. Ensure you have the 1Password CLI installed.
  4. Run the script. It will process each text file in the input directory, generate commands, and save them as text files in the output directory.
  
  Note: The intended usage was simple. The input files have the emails and the filename will be used as for Groups in 1Password.

#### 2.CreateAndAssignUsersFromFile.sp1:
- **Purpose**: This script checks for the presence of the 1Password CLI and executes commands from a the output files from the previous script using 1Password CLI (op.exe).
  
- **Instructions**:
  1. Ensure the 1Password CLI is installed. If not, the script will provide instructions to install it via 'winget'.
  2. Update the `$filePath` variable with the relative path to the text file containing commands to execute (Output files from `1.CreateCommandsByGroupFromFile.ps1`).
  3. Run the script. It will execute each command from the specified text file using the 1Password CLI.

  Note: it uses the following commands:
   - `op user provision --name "Name Lastname" --email "name.lastname@email.com"`
   - `op user confirm --all`
   - `op group provision --name "Group Name" --user "name.lastname@email.com"`

### Note:
- Make sure to update file paths and directories as per your system setup before running the scripts.
