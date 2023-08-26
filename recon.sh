#!/bin/bash

# Domain Reconnaissance Script (which I used a few years ago for reconnaissance)
# Automates subdomain discovery and analysis using various tools.
# Designed for Linux environments with required tools installed.

# Features:
# - Subdomain discovery: Subfinder, Assetfinder, Findomain
# - Enhanced enumeration: Censys Subdomain Finder
# - HTTP probing: httprobe for validating active subdomains
# - Screenshots: Aquatone captures screenshots of active subdomains
# - Organized results: Results saved in dated directories

# Usage:
# 1. Clone script
# 2. Set API Credentials: For Censys API (CENSYS_API_ID, CENSYS_API_SECRET)
# 3. Run Script: Execute with target domain argument
#    ./recon.sh example.com

# Note:
# - Ensure permissions for script and directories.
# - Verify tool paths and dependencies.
# - Use responsibly and ethically, respecting authorized domains.

TARGET=$1
TARGET_FOLDER=${TARGET^^} # Make the name of the folder UPPERCASE
TARGET_FOLDER=${TARGET_FOLDER//\./_}  # Replace all the . chars with _
DATE=$(date +"%d_%m_%Y")

echo "++++++++++++++++++++++++++++++++++++"
echo "[+] Starting recon on ${TARGET}"

cd /home/kali/Documents/

if [ -d "/home/kali/Documents/${TARGET_FOLDER}" ]; then
    echo "++++++++++++++++++++++++++++++++++++"
    echo " "
    echo "[*] Directory /home/kali/Documents/${TARGET_FOLDER} exists."
    cd "${TARGET_FOLDER}"
else
    echo "++++++++++++++++++++++++++++++++++++"
    echo " "
    echo "[+] Creating directory for ${TARGET_FOLDER}"
    mkdir -p "${TARGET_FOLDER}"
    cd "${TARGET_FOLDER}"
fi

echo "++++++++++++++++++++++++++++++++++++"
echo " "
echo "[+] Starting Subfinder..."
subfinder -d "${TARGET}" -o "subfinder-${DATE}.txt"

echo "++++++++++++++++++++++++++++++++++++"
echo " "
echo "Starting Assetfinder..."
assetfinder -subs-only "${TARGET}" >> "assetfinder-${DATE}.txt"

echo "++++++++++++++++++++++++++++++++++++"
echo " "
echo "[+] Starting Findomain..."
findomain -t "${TARGET}" -o

if [ -s "/home/kali/Documents/${TARGET_FOLDER}/${TARGET}.txt" ]; then
    echo "[+] Renaming result from Findomain"
    mv "${TARGET}.txt" "findomain-${DATE}.txt"
else
    echo "[+] Can't find output file from Findomain."
fi

# Export CENSYS_API_ID and CENSYS_API_SECRET here if needed

echo " "
echo "++++++++++++++++++++++++++++++++++++"
echo "[+] Starting CensysSubdomainFinder..."
cd /home/kali/Downloads/tools/censys-subdomain-finder/ && python "./censys_subdomain_finder.py" "${TARGET}" -o "${TARGET}.txt"

if [ -s "/home/kali/Downloads/tools/censys-subdomain-finder/${TARGET}.txt" ]; then
    echo "[+] Renaming and moving result from CensysSubdomainFinder"
    mv "${TARGET}.txt" "CensysSubdomainFinder-${DATE}.txt"
    mv "CensysSubdomainFinder-${DATE}.txt" "/home/kali/Documents/${TARGET_FOLDER}/CensysSubdomainFinder-${DATE}.txt"
    cd "/home/kali/Documents/${TARGET_FOLDER}/"
else
    echo "[+] Can't find output file from CensysSubdomainFinder."
    cd "/home/kali/Documents/${TARGET_FOLDER}/"
fi

if [ -d "/home/kali/Documents/${TARGET_FOLDER}/subdomains" ]; then
    echo "++++++++++++++++++++++++++++++++++++"
    echo " "
    echo "[+] Directory /home/kali/Documents/${TARGET_FOLDER}/subdomains exists."
else
    echo "++++++++++++++++++++++++++++++++++++"
    echo " "
    echo "[+] Creating directory for subdomains"
    mkdir -p "subdomains"
fi

echo "++++++++++++++++++++++++++++++++++++"
echo " "
echo "[+] Exporting all the results to subdomains folder"
mv "/home/kali/Documents/${TARGET_FOLDER}"/*-"${DATE}".txt "/home/kali/Documents/${TARGET_FOLDER}/subdomains/"

echo " "
echo "++++++++++++++++++++++++++++++++++++"
echo "[+] RESULTS FROM THE RECON"
echo " "
echo "++++++++++++++++++++++++++++++++++++"
ls "/home/kali/Documents/${TARGET_FOLDER}/subdomains/"

cd "/home/kali/Documents/${TARGET_FOLDER}/subdomains/"
cat *-"${DATE}".txt | sort | uniq >> "final-${DATE}.txt"

NUMBER_OF_DOMAINS=$(cat "final-${DATE}.txt" | wc -l)
echo "[+] TOTAL NUMBER OF SUBDOMAINS IS ${NUMBER_OF_DOMAINS}"

echo "++++++++++++++++++++++++++++++++++++"
echo " "
echo "[+] Starting httprobe..."
echo " "
echo "++++++++++++++++++++++++++++++++++++"
cd "/home/kali/Documents/${TARGET_FOLDER}/subdomains/"
cat "final-"*.txt | httprobe | sort -u >> "httprobe-${DATE}.txt"

cat "httprobe-${DATE}.txt"

echo "++++++++++++++++++++++++++++++++++++"
echo " "
echo "[+] Starting Aquatone..."
echo " "
echo "++++++++++++++++++++++++++++++++++++"

cat "httprobe-${DATE}.txt" | aquatone -out screenshots

echo "++++++++++++++++++++++++++++++++++++"
echo " "
echo "[+] Finish! Results are saved here /home/kali/Documents/${TARGET_FOLDER}/"
echo " "
echo "++++++++++++++++++++++++++++++++++++"
