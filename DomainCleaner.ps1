# Define the path to the input file
# Update this path to point to your domains.txt file
$InputFile = "C:\temp\domains.txt"

# Checks if the file exists
if (-Not (Test-Path $InputFile)) {
    Write-Host "Error: The file '$InputFile' does not exist. Please check the file path." -ForegroundColor Red
    exit
}

# Defines allowed TLDs
$AllowedTLDs = @(".com", ".org", ".net")

# Initializes an array to store filtered domains
$FilteredDomains = @()

# Reads each line from the input file
Get-Content $InputFile | ForEach-Object {
    $Line = $_.Trim()

    # Skips any  empty lines
    if ($Line -ne "") {
        # Extracts the domain from URL or line
        if ($Line -match "^(?:https?://)?(?:www\.)?([^/]+)") {
            $FullDomain = $Matches[1]

            # Splits the domain into parts (subdomain.domain.tld)
            $DomainParts = $FullDomain -split '\.'

            # this is so it only processes domains with at least two parts (e.g., subdomain.domain.tld)
            if ($DomainParts.Length -ge 2) {
                # Combine the last two parts (base domain and TLD)
                $BaseDomain = "$($DomainParts[-2]).$($DomainParts[-1])"

                # Checks if the base domain ends with an allowed TLD and this list can be eddited at anytime 
                foreach ($TLD in $AllowedTLDs) {
                    if ($BaseDomain.EndsWith($TLD)) {
                        $FilteredDomains += $BaseDomain
                        break
                    }
                }
            }
        }
    }
}

# Remove duplicates, sort, and overwrite the input file with filtered domains
$FilteredDomains | Sort-Object -Unique | Out-File -Encoding utf8 $InputFile

Write-Host "Domains cleaned up and saved back to $InputFile" -ForegroundColor Green
