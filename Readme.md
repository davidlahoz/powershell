
# DL PowerShell README

[![Active Development](https://img.shields.io/badge/Maintenance%20Level-Actively%20Developed-brightgreen.svg)](https://gist.github.com/cheerfulstoic/d107229326a01ff0f333a1d3476e068d)


This repository contains various PowerShell scripts for automating tasks, mainly to manage M365/Azure environments but also for other local tasks. Each script may have specific requirements and usage instructions.

## Requirements

Before running any PowerShell script, ensure that you have the necessary PowerShell modules installed. If any module is required, it will be mentioned within the script file (`*.ps1`). You can install missing modules using the following command:

```powershell

Install-Module -Name "ModuleName" -Force -Scope CurrentUser

```

Replace `"ModuleName"` with the name of the required module.

## Usage

1\. **Prepare Input Files**: If the script requires any input files (e.g., CSV files), make sure to place them in a designated directory. The script will specify the expected location of input files. For example, input files may be stored in `C:\temp` directory.

2\. **Run the Script**: Execute the PowerShell script (`script_name.ps1`) in a PowerShell environment. Follow any on-screen instructions provided by the script.

3\. **Review Output**: After executing the script, review the output to ensure that the desired actions have been performed successfully.

## Additional Notes

- Make sure to replace placeholders such as `script_name.ps1` and any file paths with actual values as per your setup.

- Read the script's comments for any additional instructions or customization options.

## License

This project is licensed under the [MIT License](/LICENSE). Feel free to use, modify, and distribute the code as per the terms of the license.
