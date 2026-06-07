#!/bin/bash

CHOCO="https://api.github.com/repos/Chocolate4U/Iran-v2ray-rules/contents/text"

mkdir ir-cdn

# Pipe through grep to discard HTML/error pages that Iranian CDNs serve to foreign IPs.
# The [[ -s ... ]] check then triggers the Chocolate4U fallback if nothing valid was fetched.

curl --connect-timeout 15 -sSL https://www.arvancloud.ir/en/ips.txt 2>/dev/null \
  | grep -E '^[0-9a-fA-F]' > ir-cdn/arvancloud.txt || true
[[ -s ir-cdn/arvancloud.txt ]] \
  || gh api "$CHOCO/arvancloud.txt?ref=release" -H "Accept: application/vnd.github.raw" > ir-cdn/arvancloud.txt

curl --connect-timeout 15 -sSL https://api.derak.cloud/public/ipv4 2>/dev/null \
  | grep -E '^[0-9]' > ir-cdn/derakcloud.txt || true
curl --connect-timeout 15 -sSL https://api.derak.cloud/public/ipv6 2>/dev/null \
  | grep -E '^[0-9a-fA-F:]' >> ir-cdn/derakcloud.txt || true
[[ -s ir-cdn/derakcloud.txt ]] \
  || gh api "$CHOCO/derakcloud.txt?ref=release" -H "Accept: application/vnd.github.raw" > ir-cdn/derakcloud.txt

gh api "$CHOCO/iranserver.txt?ref=release" -H "Accept: application/vnd.github.raw" > ir-cdn/iranserver.txt

curl --connect-timeout 15 -sSL https://parspack.com/cdnips.txt 2>/dev/null \
  | grep -E '^[0-9]' > ir-cdn/parspack.txt || true
[[ -s ir-cdn/parspack.txt ]] \
  || gh api "$CHOCO/parspack.txt?ref=release" -H "Accept: application/vnd.github.raw" > ir-cdn/parspack.txt
