#!/bin/bash

# ============================================
# IP Reverse Lookup Tool - Installer v3.0.0
# مخصوص ترموکس
# ============================================

# رنگ‌ها برای خروجی زیبا
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# متغیرها
PROJECT_NAME="IP Reverse Lookup Tool"
VERSION="3.0.0"
SCRIPT_NAME="reverse_ip.py"
CMD_NAME="ip-lookup"
INSTALL_DIR="$HOME/.local/bin"
REPO_URL="https://raw.githubusercontent.com/Erfan8809/ip-reverse-lookup/main"

# ============================================
# توابع
# ============================================

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}🚀 $PROJECT_NAME - Installer v$VERSION${NC}"
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

check_termux() {
    if [ -d "/data/data/com.termux" ]; then
        return 0
    else
        return 1
    fi
}

# ============================================
# 1. بررسی و نصب پیش‌نیازها (مخصوص ترموکس)
# ============================================

install_prerequisites() {
    print_info "Checking prerequisites..."
    
    if check_termux; then
        print_info "Termux detected - using pkg manager"
        
        # آپدیت پکیج‌ها
        pkg update -y && pkg upgrade -y
        
        # نصب پایتون (که شامل pip هم هست)
        if ! command -v python3 &> /dev/null; then
            print_info "Installing Python..."
            pkg install python -y
        fi
        
        # نصب pip (از طریق pkg، نه pip خودش)
        if ! command -v pip &> /dev/null; then
            print_info "Installing pip via pkg..."
            pkg install python-pip -y
        fi
        
    else
        # لینوکس معمولی
        print_info "Linux detected - using system package manager"
        
        if ! command -v python3 &> /dev/null; then
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install python3 python3-pip -y
            elif command -v yum &> /dev/null; then
                sudo yum install python3 python3-pip -y
            else
                print_error "Could not install Python. Please install Python3 manually."
                exit 1
            fi
        fi
    fi
    
    print_success "Prerequisites installed"
}

# ============================================
# 2. نصب وابستگی‌های پایتون (با رعایت محدودیت ترموکس)
# ============================================

install_dependencies() {
    print_info "Installing Python dependencies..."
    
    if check_termux; then
        # در ترموکس از pip استفاده می‌کنیم اما بدون --upgrade pip
        # و با نصب جداگانه هر کتابخانه
        print_info "Installing packages for Termux..."
        
        pip install rich
        pip install dnspython
        pip install requests
        
        # بررسی نصب موفق
        if python3 -c "import rich, dnspython, requests" 2>/dev/null; then
            print_success "Dependencies installed successfully"
        else
            print_error "Failed to install dependencies. Trying alternative method..."
            pip install --user rich dnspython requests
        fi
    else
        # لینوکس معمولی
        pip3 install --upgrade pip
        pip3 install rich dnspython requests
    fi
    
    if [ $? -eq 0 ]; then
        print_success "Dependencies installed"
    else
        print_error "Failed to install dependencies"
        exit 1
    fi
}

# ============================================
# 3. نصب فایل اصلی (تک فایل)
# ============================================

install_script() {
    print_info "Installing $PROJECT_NAME..."
    
    # ساخت پوشه نصب
    mkdir -p "$INSTALL_DIR"
    
    # دانلود فایل اصلی
    print_info "Downloading $SCRIPT_NAME from GitHub..."
    
    if command -v curl &> /dev/null; then
        curl -fsSL "$REPO_URL/$SCRIPT_NAME" -o "$INSTALL_DIR/$SCRIPT_NAME"
    elif command -v wget &> /dev/null; then
        wget -q "$REPO_URL/$SCRIPT_NAME" -O "$INSTALL_DIR/$SCRIPT_NAME"
    else
        print_error "curl or wget not found. Please install one of them."
        exit 1
    fi
    
    if [ $? -eq 0 ] && [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        # قابل اجرا کردن فایل
        chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
        print_success "Script downloaded and installed to $INSTALL_DIR"
    else
        print_error "Failed to download script"
        exit 1
    fi
}

# ============================================
# 4. ساخت لینک سمبلیک و نمایش تک فایل در ls
# ============================================

create_symlink() {
    print_info "Creating symbolic link for command: $CMD_NAME"
    
    if check_termux; then
        # ترموکس - لینک در PREFIX/bin
        ln -sf "$INSTALL_DIR/$SCRIPT_NAME" "$PREFIX/bin/$CMD_NAME"
        chmod +x "$PREFIX/bin/$CMD_NAME"
        print_success "Symbolic link created in $PREFIX/bin"
        
        # برای نمایش تک فایل در ls
        print_info "To see the file: ls -l $PREFIX/bin/$CMD_NAME"
    else
        # لینوکس معمولی
        if [ -d "/usr/local/bin" ]; then
            sudo ln -sf "$INSTALL_DIR/$SCRIPT_NAME" "/usr/local/bin/$CMD_NAME"
        else
            ln -sf "$INSTALL_DIR/$SCRIPT_NAME" "$HOME/bin/$CMD_NAME"
            mkdir -p "$HOME/bin"
        fi
        print_success "Symbolic link created"
    fi
}

# ============================================
# 5. تنظیم PATH (با نمایش تک فایل)
# ============================================

setup_path() {
    # بررسی اینکه آیا INSTALL_DIR در PATH هست
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        print_info "Adding $INSTALL_DIR to PATH..."
        
        if check_termux; then
            # ترموکس از ~/.bashrc استفاده می‌کنه
            echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.bashrc"
            print_success "Added to ~/.bashrc"
            
            # برای نشست فعلی
            export PATH="$PATH:$INSTALL_DIR"
        else
            # لینوکس معمولی
            SHELL_NAME=$(basename "$SHELL")
            case $SHELL_NAME in
                bash)
                    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.bashrc"
                    ;;
                zsh)
                    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.zshrc"
                    ;;
                *)
                    print_info "Please add $INSTALL_DIR to your PATH manually"
                    ;;
            esac
        fi
    fi
}

# ============================================
# 6. تست نصب و نمایش اطلاعات فایل
# ============================================

test_installation() {
    print_info "Testing installation..."
    
    # نمایش اطلاعات فایل نصب شده
    if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        echo -e "${GREEN}📁 Installed file:${NC}"
        ls -lh "$INSTALL_DIR/$SCRIPT_NAME" | awk '{print "  " $9 " (" $5 ")"}'
    fi
    
    if command -v "$CMD_NAME" &> /dev/null; then
        print_success "$CMD_NAME is ready to use!"
        
        # نمایش مسیر دقیق فایل
        FILE_PATH=$(which "$CMD_NAME")
        echo -e "${GREEN}📍 Location: $FILE_PATH${NC}"
        
        echo ""
        echo -e "${YELLOW}📝 Try it:${NC}"
        echo -e "  ${GREEN}$CMD_NAME 8.8.8.8${NC}"
    else
        print_error "Installation test failed. Please run:"
        echo -e "${YELLOW}  source ~/.bashrc${NC}"
        echo -e "${YELLOW}  $INSTALL_DIR/$SCRIPT_NAME${NC}"
    fi
}

# ============================================
# 7. نمایش پیام نهایی
# ============================================

show_final_message() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}✅ Installation Complete!${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo -e "${YELLOW}📝 Usage:${NC}"
    echo -e "  ${GREEN}$CMD_NAME 8.8.8.8${NC}      # Lookup a single IP"
    echo -e "  ${GREEN}$CMD_NAME${NC}               # Interactive mode"
    echo ""
    echo -e "${YELLOW}📁 Files:${NC}"
    echo -e "  • Main script: ${GREEN}$INSTALL_DIR/$SCRIPT_NAME${NC}"
    
    if check_termux; then
        echo -e "  • Command link: ${GREEN}$PREFIX/bin/$CMD_NAME${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}💡 Tip:${NC}"
    echo -e "  • Run ${GREEN}source ~/.bashrc${NC} if command not found"
    echo -e "  • Use ${GREEN}ls -l $PREFIX/bin/$CMD_NAME${NC} to see the file"
    echo ""
    echo -e "${GREEN}🎉 Enjoy!${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# ============================================
# اجرای اصلی
# ============================================

main() {
    print_header
    
    # بررسی اینکه کاربر root نباشه
    if [ "$EUID" -eq 0 ]; then 
        print_error "Please don't run as root"
        exit 1
    fi
    
    install_prerequisites
    install_dependencies
    install_script
    create_symlink
    setup_path
    test_installation
    show_final_message
}

# اجرا
main
