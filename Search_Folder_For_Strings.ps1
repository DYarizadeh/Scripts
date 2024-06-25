# Path to the folder containing the files to search
$folderPath = "file_path"

# List of strings to search for
$searchStrings = @("<>", "<>") # Update these strings as per your requirements

# Output file path
$outputFilePath = "FilePath\SearchResults.txt"

# Create or clear the output file
if (Test-Path $outputFilePath) {
    Clear-Content $outputFilePath
} else {
    New-Item -ItemType File -Path $outputFilePath
}

# Iterate through each file in the folder
Get-ChildItem -Path $folderPath -Recurse | ForEach-Object {
    $filePath = $_.FullName10.20.0.5"

    # Check if the item is a file
    if (Test-Path $filePath -PathType Leaf) {
        # Read the content of the file
        $fileContent = Get-Content $filePath -Raw

        # Search for each string in the current file's content
        foreach ($searchString in $searchStrings) {
            if ($fileContent -match [regex]::Escape($searchString)) {
                # If found, write the result to the output file and console
                $result = "Found '$searchString' in $filePath"
                $result | Out-File -FilePath $outputFilePath -Append
                Write-Host $result
            }
        }
    }
}

Write-Host "Search complete. Results have been written to $outputFilePath"
