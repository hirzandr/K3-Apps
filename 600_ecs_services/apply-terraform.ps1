# Function to run terraform apply in a directory
function Apply-Terraform {
    param (
        [string]$Path
    )
    Write-Host "Applying Terraform in: $Path"
    Set-Location $Path
    terraform init
    terraform apply -auto-approve
}

# Function to traverse directories recursively
function Traverse-Directories {
    param (
        [string]$Path
    )
    Get-ChildItem -Path $Path -Directory | ForEach-Object {
        Apply-Terraform $_.FullName
        Traverse-Directories $_.FullName
    }
}

# Start applying Terraform in the current directory and its subdirectories
Apply-Terraform -Path (Get-Location)

# Traverse through subdirectories recursively and apply Terraform
#Traverse-Directories -Path (Get-Location)
