#!/bin/bash

# ============================================
# IP Reverse Lookup Tool - Installer v3.0.0
# برای ترموکس و سیستم‌های لینوکسی
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
CMD_NAME="ip-lookup"  # دستوری که کاربر تایپ می‌کنه
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
        print_info "Detected Termux environment"
        return 0
    else
        print_info "Detected Linux environment"
        return 1
    fi
}

# ============================================
# 1. بررسی و نصب پیش‌نیازها
# ============================================

install_prerequisites() {
    print_info "Checking prerequisites..."
    
    # بررسی وجود پایتون
    if ! command -v python3 &> /dev/null; then
        print_info "Python3 not found. Installing..."
        if check_termux; then
            pkg update -y && pkg install python -y
        else
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
    
    # بررسی وجود pip
    if ! command -v pip3 &> /dev/null; then
        print_info "pip3 not found. Installing..."
        if check_termux; then
            pkg install python-pip -y
        else
            python3 -m ensurepip --upgrade
        fi
    fi
    
    print_success "Prerequisites installed"
}

# ============================================
# 2. نصب وابستگی‌های پایتون
# ============================================

install_dependencies() {
    print_info "Installing Python dependencies..."
    
    pip3 install --upgrade pip
    pip3 install rich>=13.7.0 dnspython>=2.4.0 requests>=2.31.0
    
    if [ $? -eq 0 ]; then
        print_success "Dependencies installed successfully"
    else
        print_error "Failed to install dependencies"
        exit 1
    fi
}

# ============================================
# 3. نصب فایل اصلی
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
# 4. ساخت لینک سمبلیک برای اجرا از هر جا
# ============================================

create_symlink() {
    print_info "Creating symbolic link for command: $CMD_NAME"
    
    # لینک سمبلیک در مسیر سیستم
    if [ -d "/data/data/com.termux" ]; then
        # ترموکس
        ln -sf "$INSTALL_DIR/$SCRIPT_NAME" "$PREFIX/bin/$CMD_NAME"
        chmod +x "$PREFIX/bin/$CMD_NAME"
        print_success "Symbolic link created in $PREFIX/bin"
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
# 5. تنظیم PATH (در صورت نیاز)
# ============================================

setup_path() {
    # بررسی اینکه آیا INSTALL_DIR در PATH هست
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        print_info "Adding $INSTALL_DIR to PATH..."
        
        # تشخیص شل کاربر
        SHELL_NAME=$(basename "$SHELL")
        
        case $SHELL_NAME in
            bash)
                echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.bashrc"
                print_success "Added to ~/.bashrc"
                ;;
            zsh)
                echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.zshrc"
                print_success "Added to ~/.zshrc"
                ;;
            *)
                print_info "Please add $INSTALL_DIR to your PATH manually"
                ;;
        esac
        
        # برای نشست فعلی
        export PATH="$PATH:$INSTALL_DIR"
    fi
}

# ============================================
# 6. تست نصب
# ============================================

test_installation() {
    print_info "Testing installation..."
    
    if command -v "$CMD_NAME" &> /dev/null; then
        print_success "$CMD_NAME is ready to use!"
        echo -e "${GREEN}Try it: $CMD_NAME 8.8.8.8${NC}"
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
    echo -e "${YELLOW}📝 Usage Examples:${NC}"
    echo -e "  ${GREEN}$CMD_NAME 8.8.8.8${NC}      # Lookup a single IP"
    echo -e "  ${GREEN}$CMD_NAME${NC}               # Interactive mode"
    echo -e "  ${GREEN}python3 $CMD_NAME --help${NC}  # Show help"
    echo ""
    echo -e "${YELLOW}📌 Note:${NC}"
    echo -e "  • Open a new terminal or run: ${GREEN}source ~/.bashrc${NC}"
    echo -e "  • The script needs internet connection to work"
    echo -e "  • Output files are saved in the current directory"
    echo ""
    echo -e "${GREEN}🎉 Enjoy using $PROJECT_NAME v$VERSION!${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# ============================================
# اجرای اصلی
# ============================================

main() {
    print_header
    
    # بررسی اینکه کاربر root نباشه (برای امنیت)
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
