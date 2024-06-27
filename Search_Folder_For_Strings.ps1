# Define the directory to search and the list of strings to search for
$directoryPath = "C:\Path\To\Your\Directory"
$searchStrings = @("string1", "string2", "string3") # Add your search strings here

# Function to search for strings in a file
function Search-StringsInFile {
    param (
        [string]$filePath,
        [array]$strings
    )
    
    $fileContent = Get-Content -Path $filePath -ErrorAction SilentlyContinue
    if ($null -ne $fileContent) {
        foreach ($string in $strings) {
            if ($fileContent -match [regex]::Escape($string)) {
                Write-Output "String '$string' found in file: $filePath"
            }
        }
    }
}

# Function to search for strings in all files in a directory recursively
function Search-StringsInDirectory {
    param (
        [string]$directory,
        [array]$strings
    )
    
    Get-ChildItem -Path $directory -Recurse -File | ForEach-Object {
        Search-StringsInFile -filePath $_.FullName -strings $strings
    }
}

# Start the search
Search-StringsInDirectory -directory $directoryPath -strings $searchStrings
