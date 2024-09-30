import json
import csv

# Function to flatten nested dictionaries
def flatten_json(nested_json, parent_key='', sep='_'):
    """
    Flatten a nested json file. 
    nested_json: dictionary to flatten
    parent_key: string, key to prepend to new key names
    sep: string, separator between flattened keys
    """
    items = []
    for k, v in nested_json.items():
        new_key = f"{parent_key}{sep}{k}" if parent_key else k
        if isinstance(v, dict):
            items.extend(flatten_json(v, new_key, sep=sep).items())
        elif isinstance(v, list):
            for i, item in enumerate(v):
                items.extend(flatten_json({f"{new_key}_{i}": item}).items())
        else:
            items.append((new_key, v))
    return dict(items)

# Function to convert JSON to CSV
def json_to_csv(json_file, csv_file):
    try:
        # Open the JSON file and load the data
        with open(json_file, 'r') as f:
            data = json.load(f)

        # Flatten each JSON object in the list
        flattened_data = [flatten_json(record) for record in data]
        
        # Get all unique keys for the CSV header
        keys = set()
        for record in flattened_data:
            keys.update(record.keys())
        keys = sorted(list(keys))  # Sort keys for consistent column ordering

        # Write the data to the CSV file
        with open(csv_file, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=keys)
            writer.writeheader()
            writer.writerows(flattened_data)

        print(f"Data successfully written to {csv_file}")

    except Exception as e:
        print(f"An error occurred: {e}")

# Example usage
json_file = r'your\file\here'  # JSON file path
csv_file = r'your\output\here'    # Desired CSV output path

json_to_csv(json_file, csv_file)
