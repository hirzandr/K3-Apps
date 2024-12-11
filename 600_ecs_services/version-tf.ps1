# Function to replace specific lines in a Terraform tags block
function Replace-TerraformTags {
    param(
        [string]$rootPath,
        [string]$fileName
    )

    # Get all files with the specified name recursively
    $files = Get-ChildItem -Path $rootPath -Filter $fileName -Recurse -File

    foreach ($file in $files) {
        # Read all lines from the file
        $lines = Get-Content -Path $file.FullName

        # Join all lines into a single string
        $content = $lines -join "`n"

        # Define the replacement mappings
        $replacements = @{
            'Managed_Via = "TerraformManaged"' = 'Environment = "UAT"'
            'Environment = var.environment'   = 'Propose = "app-container"'
            '# Owner           = var.application_name' = 'map-migrated = "migXE6ORY1HAF"'
            'OwnerTeam          = "Kairos"' = 'OwnerTeam          = "kairos"'
            'DepartmentID       = "Kairos"' = 'DepartmentID       = "kairos"'
            'DataClassification = "clinical"' = 'DataClassification = "clinical"'
            'ManagedVia         = "Terraform"' = 'ManagedVia         = "Terraform"'
            'ProvisionedBy      = "Cipuy-ITSP"' = 'ProvisionedBy      = "Cipuy-ITSP"'
        }

        # Perform replacements
        foreach ($key in $replacements.Keys) {
            $content = $content -replace [regex]::Escape($key), $replacements[$key]
        }

        # Add Purpose = "app-container" if it doesn't already exist
        if ($lines -notcontains "Purpose = `"`app-container`"") {
            $lines += "Purpose = `"`app-container`""
        }

        # Split the content back into lines and save to the file
        $content -split "`n" | Set-Content -Path $file.FullName -Force
        Write-Host "Replacements complete for $($file.FullName)"
    }

    Write-Host "Replacements complete for all $fileName files in $rootPath and its subdirectories."
}

# Example usage: Replace specific lines in Terraform tags block recursively
$rootPath = "D:\Siloam-Kairos-IaC-main\Siloam-Kairos-IaC\700_ecs_services"
$fileName = "version.tf"

Replace-TerraformTags -rootPath $rootPath -fileName $fileName
