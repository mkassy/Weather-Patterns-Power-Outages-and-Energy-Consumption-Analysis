import os
import zipfile

# Define the directory containing the ZIP files and where to extract them
zip_dir = 'data/energy'
extract_dir = 'data/energy'

# List all ZIP files in the directory
for filename in os.listdir(zip_dir):
    if filename.endswith('.zip'):
        zip_path = os.path.join(zip_dir, filename)
        extract_path = os.path.join(extract_dir, filename.replace('.zip', ''))

        # Unzip the file
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(extract_path)

        # Optionally delete the ZIP file after extraction
        os.remove(zip_path)

        print(f'Unzipped and removed: {filename}')
