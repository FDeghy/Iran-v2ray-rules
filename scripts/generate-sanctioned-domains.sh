#!/bin/bash

set -euo pipefail

work_dir=$(mktemp -d domains/.sanctioned.XXXXXXXX)
trap 'rm -rf -- "$work_dir"' EXIT

gh api repos/FDeghy/DynX-AntiBan-Domains/contents/DynX-AntiBan-list.lst \
    -H "Accept: application/vnd.github.raw" > "$work_dir/dynx.txt"
gh api 'repos/DNSProIR/DNSPro/contents/domains.txt?ref=main' \
    -H "Accept: application/vnd.github.raw" > "$work_dir/dnspro.txt"

# Normalize both sources before checking coverage at DNS label boundaries.
sed -e 's/^\(|\|\*\|\.\|\-\|0\.0\.0\.0\|127\.0\.0\.1\)*//g' \
    -e 's/\^.*$//g' \
    -e '/!\|?\|@\|#\|:\|\*\|_\|\\\|\/\|\[\|]\|\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/d' \
    -e '/\.$/d' -e '/^\s*$/d' "$work_dir/dynx.txt" "$work_dir/dnspro.txt" |
    dos2unix |
    awk '{$1=$1};1' |
    perl -CSDA -pe 's/[\x{200C}\x{200D}]//g; $_ = lc' |
    idn2 --no-alabelroundtrip --no-tr46 |
    LC_ALL=C awk '
        { sub(/\r$/, "") }
        /^([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?$/ {
            domains[$0]
        }
        END {
            for (domain in domains) {
                parent = domain
                while (sub(/^[^.]+\./, "", parent)) {
                    if (parent in domains)
                        break
                }
                if (!(parent in domains))
                    print domain
            }
        }
    ' |
    LC_ALL=C sort > "$work_dir/sanctioned.txt"

mv -- "$work_dir/sanctioned.txt" domains/sanctioned.txt
