#!/bin/bash

# Initialize an empty global.env file in the current directory
global_env_file="./.env.global"
echo "# Global environment variables" > "$global_env_file"

# Find all docker-compose.*.yml files recursively in subdirectories
find . -name 'docker-compose.*.yml' | while read -r compose_file; do
  # Get the directory of the docker-compose file
  dir=$(dirname "$compose_file")
  
  # Extract the directory name to use in the .env.<directory> filename
  dir_name=$(basename "$dir")
  
  # Create .env.<directory> file
  env_file="$dir/.env.$dir_name"
  echo "# Environment variables for $compose_file" > "$env_file"

  # Extract local variables and write to .env.<directory>
  grep '\${' "$compose_file" | sed "s/.*\${\(.*\)}.*/\1/g" | cut -d":" -f 1 | grep -v '^GLOBAL_' | sort -u | sort | xargs -I % echo "%=" >> "$env_file"

  echo ".env.$dir_name created in $dir with sorted local variables."
done

# Create global.env using the provided command
grep '\${' **/docker-compose.*.yml | sed "s/.*\${\(.*\)}.*/\1/g" | cut -d":" -f 1 | grep GLOBAL_ | sort -u | sort | xargs -I % echo "%=" >> "$global_env_file"

echo ".env.global created with unique and alphabetically sorted GLOBAL_* variables."
