#!/bin/bash

CHOCO="https://api.github.com/repos/Chocolate4U/Iran-v2ray-rules/contents/text"
# Anchored full-line match for an IPv4/IPv6 address or CIDR. Matching only the first
# character (the old check) still let non-empty-but-malformed responses (e.g. an HTML
# error page that happens to start with a digit) through and crash `geoip convert`
# with "invalid IP address" further down the pipeline.
CIDR_REGEX='^([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?$|^[0-9a-fA-F:]*:[0-9a-fA-F:]*(/[0-9]{1,3})?$'

mkdir ir-cdn

# Filter to well-formed CIDRs/addresses to discard HTML/error pages that Iranian CDNs
# serve to foreign IPs. The [[ -s ... ]] check then triggers the Chocolate4U fallback
# if nothing valid survived filtering.

curl --connect-timeout 15 -sSL https://www.arvancloud.ir/en/ips.txt 2>/dev/null \
  | grep -E "$CIDR_REGEX" > ir-cdn/arvancloud.txt || true
[[ -s ir-cdn/arvancloud.txt ]] \
  || gh api "$CHOCO/arvancloud.txt?ref=release" -H "Accept: application/vnd.github.raw" | grep -E "$CIDR_REGEX" > ir-cdn/arvancloud.txt

curl --connect-timeout 15 -sSL https://api.derak.cloud/public/ipv4 2>/dev/null \
  | grep -E "$CIDR_REGEX" > ir-cdn/derakcloud.txt || true
curl --connect-timeout 15 -sSL https://api.derak.cloud/public/ipv6 2>/dev/null \
  | grep -E "$CIDR_REGEX" >> ir-cdn/derakcloud.txt || true
[[ -s ir-cdn/derakcloud.txt ]] \
  || gh api "$CHOCO/derakcloud.txt?ref=release" -H "Accept: application/vnd.github.raw" | grep -E "$CIDR_REGEX" > ir-cdn/derakcloud.txt

gh api "$CHOCO/iranserver.txt?ref=release" -H "Accept: application/vnd.github.raw" | grep -E "$CIDR_REGEX" > ir-cdn/iranserver.txt

curl --connect-timeout 15 -sSL https://parspack.com/cdnips.txt 2>/dev/null \
  | grep -E "$CIDR_REGEX" > ir-cdn/parspack.txt || true
[[ -s ir-cdn/parspack.txt ]] \
  || gh api "$CHOCO/parspack.txt?ref=release" -H "Accept: application/vnd.github.raw" | grep -E "$CIDR_REGEX" > ir-cdn/parspack.txt
