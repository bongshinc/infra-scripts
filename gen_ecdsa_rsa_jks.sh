#!/bin/bash

# =================================================================
# Winning Business - Keystore Auto Generation Script (v2.0)
# =================================================================
# Usage: ./gen_ecdsa_rsa_jks.sh [ec|rsa]
#   ec  - Generate ECDSA keystore (default, recommended)
#   rsa - Generate RSA keystore
# =================================================================

# [Common Environment Variables]
STOREPASS="changeME!"
KEYPASS="$STOREPASS"          # Usually set the same as store password
VALIDITY=365                 # 10 years validity

# [Distinguished Name (DNAME) Settings]
CN="192.168.10.10"            # Domain or service name
OU="Engineering"              # Organizational Unit
O="DEV"                       # Organization
L="Seoul"                     # Locality (City)
S="Seoul"                     # State/Province
C="KR"                        # Country Code

# [Color Definitions]
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# [Algorithm Selection]
ALGO="${1:-ec}"  # Default to 'ec' if no argument provided

case "$ALGO" in
    ec|EC|ecdsa|ECDSA)
        ALIAS="tomcat_ec"
        KEYSTORE="keystore_ec.jks"
        KEYALG_OPTS="-keyalg EC -groupname secp256r1"
        ALGO_DESC="ECDSA (secp256r1)"
        ;;
    rsa|RSA)
        ALIAS="tomcat_rsa"
        KEYSTORE="keystore_rsa.jks"
        KEYALG_OPTS="-keyalg RSA -keysize 2048"
        ALGO_DESC="RSA (2048-bit)"
        ;;
    *)
        echo -e "${RED}❌ [ERROR] Invalid algorithm: $ALGO${NC}"
        echo -e "${YELLOW}Usage: $0 [ec|rsa]${NC}"
        echo -e "  ${CYAN}ec${NC}  - Generate ECDSA keystore (recommended, lighter)"
        echo -e "  ${CYAN}rsa${NC} - Generate RSA keystore (legacy compatible)"
        exit 1
        ;;
esac

# [Pre-flight Check]
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  🔐 Java Keystore Generator${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  Algorithm  : ${GREEN}$ALGO_DESC${NC}"
echo -e "  Alias      : $ALIAS"
echo -e "  Keystore   : $KEYSTORE"
echo -e "  Validity   : $VALIDITY days ($(($VALIDITY / 365)) years)"
echo -e "  Subject DN : CN=$CN, OU=$OU, O=$O, L=$L, S=$S, C=$C"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# [Check if keystore already exists]
if [ -f "$KEYSTORE" ]; then
    echo -e "${YELLOW}⚠️  [WARN] Keystore '$KEYSTORE' already exists.${NC}"
    read -p "   Overwrite? (y/N): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo -e "${RED}❌ [ABORT] Operation cancelled.${NC}"
        exit 1
    fi
    rm -f "$KEYSTORE"
fi

# [Generate Keystore]
echo -e "\n🔧 Generating keystore..."

keytool -genkeypair \
  -alias "$ALIAS" \
  $KEYALG_OPTS \
  -keystore "$KEYSTORE" \
  -storepass "$STOREPASS" \
  -keypass "$KEYPASS" \
  -validity "$VALIDITY" \
  -dname "CN=$CN, OU=$OU, O=$O, L=$L, S=$S, C=$C"

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✅ [SUCCESS] Keystore has been generated: ${KEYSTORE}${NC}"
    
    # [Display Certificate Info]
    echo -e "\n📋 Certificate Details:"
    keytool -list -v -keystore "$KEYSTORE" -storepass "$STOREPASS" -alias "$ALIAS" 2>/dev/null | \
        grep -E "(Alias name|Creation date|Entry type|Owner|Issuer|Valid from|Signature algorithm)" | \
        sed 's/^/   /'
    
    echo -e "\n${CYAN}💡 [TIP] To view full details:${NC}"
    echo -e "   keytool -list -v -keystore $KEYSTORE -storepass $STOREPASS"
else
    echo -e "\n${RED}❌ [FAILED] Keystore generation failed.${NC}"
    exit 1
fi
