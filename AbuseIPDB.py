Take output, run through JSON to CSV convert, open in excel, deliminate on commas, then sort by Abuse Confidence score for quick wins 
########################################################################
import requests
import json

# Define the API endpoint and headers
url = 'https://api.abuseipdb.com/api/v2/check'
headers = {
    'Accept': 'application/json',
    'Key': 'API Key Here'
}

# Read the list of IP addresses from a file
with open(r"C:\Path\To\IPTextFile.txt", "r") as file:
    ip_list = file.read().splitlines()

# Prepare to store the results
results = []

# Loop through each IP and make a request to the AbuseIPDB API
for ip in ip_list:
    querystring = {
        'ipAddress': ip,
        'maxAgeInDays': '90'
    }
    response = requests.get(url, headers=headers, params=querystring)
    results.append(json.loads(response.text))

# Save the results to a JSON file
with open("results.json", "w") as outfile:
    json.dump(results, outfile, indent=4)

print("Results have been saved to results.json")
#################################################################
