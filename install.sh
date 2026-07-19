#!/bin/bash

# ============================================
# IP Reverse Lookup Tool - Installer v3.0.0
# مخصوص ترموکس - فقط نصب وابستگی‌ها
# ============================================

# رنگ‌ها
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}🚀 IP Reverse Lookup - Installer v3.0.0${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_error() {
    echo -e "${RED}❌ Error: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}📌 $1${NC}"
}

# ============================================
# 1. نصب پایتون (اگه نصب نباشه)
# ============================================

install_python() {
    print_info "Checking Python..."
    
    if ! command -v python3 &> /dev/null; then
        print_info "Python3 not found. Installing..."
        
        if [ -d "/data/data/com.termux" ]; then
            pkg update -y && pkg install python -y
        else
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install python3 python3-pip -y
            elif command -v yum &> /dev/null; then
                sudo yum install python3 python3-pip -y
            else
                print_error "Please install Python3 manually"
                exit 1
            fi
        fi
    fi
    
    print_success "Python3 is ready"
}

# ============================================
# 2. نصب pip (بدون خطا)
# ============================================

install_pip() {
    print_info "Checking pip..."
    
    if [ -d "/data/data/com.termux" ]; then
        # ترموکس - نصب pip از طریق pkg
        if ! command -v pip &> /dev/null; then
            print_info "Installing pip via pkg..."
            pkg install python-pip -y
        fi
    else
        # لینوکس معمولی
        if ! command -v pip3 &> /dev/null; then
            python3 -m ensurepip --upgrade
        fi
    fi
    
    print_success "pip is ready"
}

# ============================================
# 3. نصب وابستگی‌ها (بدون آپگرید pip)
# ============================================

install_dependencies() {
    print_info "Installing Python libraries..."
    
    if [ -d "/data/data/com.termux" ]; then
        # ترموکس - نصب با pip معمولی
        pip install rich 2>/dev/null
        pip install dnspython 2>/dev/null
        pip install requests 2>/dev/null
        
        # یا نصب یکجا (در صورت وجود خطا)
        if [ $? -ne 0 ]; then
            print_info "Trying alternative installation..."
            pip install --user rich dnspython requests 2>/dev/null
        fi
    else
        # لینوکس معمولی
        pip3 install rich dnspython requests 2>/dev/null
    fi
    
    print_success "Dependencies installed"
}

# ============================================
# 4. دانلود فایل پروژه
# ============================================

download_project() {
    print_info "Downloading reverse_ip.py..."
    
    # دانلود فایل از گیت‌هاب
    REPO_URL="https://raw.githubusercontent.com/Erfan8809/ip-reverse-lookup/main"
    
    if command -v curl &> /dev/null; then
        curl -fsSL "$REPO_URL/reverse_ip.py" -o "reverse_ip.py"
    elif command -v wget &> /dev/null; then
        wget -q "$REPO_URL/reverse_ip.py" -O "reverse_ip.py"
    else
        print_error "curl or wget not found. Please install one."
        exit 1
    fi
    
    if [ -f "reverse_ip.py" ]; then
        chmod +x reverse_ip.py
        print_success "File downloaded: reverse_ip.py"
    else
        print_error "Failed to download reverse_ip.py"
        exit 1
    fi
}

# ============================================
# 5. تست و نمایش پیام
# ============================================

show_final_message() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}✅ Installation Complete!${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo -e "${YELLOW}📁 Files in current directory:${NC}"
    ls -lh reverse_ip.py 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
    echo ""
    echo -e "${YELLOW}📝 Run the script:${NC}"
    echo -e "  ${GREEN}python3 reverse_ip.py${NC}"
    echo -e "  ${GREEN}python3 reverse_ip.py 8.8.8.8${NC}"
    echo ""
    echo -e "${YELLOW}📌 Note:${NC}"
    echo -e "  • Make sure you're in the same directory as the file"
    echo -e "  • The script needs internet connection"
    echo ""
    echo -e "${GREEN}🎉 Enjoy!${NC}"
}

# ============================================
# اجرای اصلی
# ============================================

main() {
    print_header
    
    # نصب پیش‌نیازها
    install_python
    install_pip
    install_dependencies
    
    # دانلود پروژه
    download_project
    
    # پیام نهایی
    show_final_message
}

# اجرا
main
