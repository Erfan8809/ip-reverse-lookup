# 🔍 IP Reverse Lookup Tool

[![Python Version](https://img.shields.io/badge/python-3.7+-blue.svg)](https://python.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

A powerful, free, and beautiful command-line tool to find all domains hosted on a specific IP address. Perfect for network administrators, security researchers, and developers.

## ✨ Features

- 🚀 **5 Different Search Methods** - DNS PTR, ViewDNS, HackerTarget, Shodan, IP-API
- 🎨 **Beautiful Terminal UI** - Rich colors and professional formatting
- ⚡ **Parallel Processing** - Fast results using multi-threading
- 🌍 **IP Geolocation** - Get ISP, country, city, AS number
- 💾 **Export Results** - Save findings to formatted text files
- 📱 **Mobile Ready** - Works perfectly in Termux on Android
- 🆓 **100% Free** - No API keys required
- 🔒 **Privacy Focused** - All requests are anonymous

## 🚀 Quick Start

curl -fsSL https://raw.githubusercontent.com/Erfan8809/ip-reverse-lookup/main/install.sh | bash

### Installation


# Clone the repository
git clone https://github.com/Erfan8809/ip-reverse-lookup.git
cd ip-reverse-lookup

# Install dependencies
pip install -r requirements.txt

# Run the tool
python3 reverse_ip.py


On Android (Termux)


pkg update && pkg upgrade
pkg install python
git clone https://github.com/yourusername/ip-reverse-lookup.git
cd ip-reverse-lookup
pip install -r requirements.txt
python3 reverse_ip.py


📖 Usage

1. Run the tool:
   
   python3 reverse_ip.py
   
2. Enter an IP address when prompted:
   
   Enter IP address: 8.8.8.8
   
3. View results:
   · IP geolocation information
   · List of all domains found
   · Statistics from each search method
4. Save results (optional):
   · The tool will ask if you want to save results
   · Files are saved as reverse_ip_<IP>_<timestamp>.txt
5. Search another IP or exit

🎯 Search Methods

Method Source Description
DNS PTR Local DNS Standard reverse DNS lookup
ViewDNS viewdns.info Free reverse IP API
HackerTarget hackertarget.com Free API for reverse IP
Shodan internetdb.shodan.io Hostnames from Shodan database
IP-API ip-api.com Geolocation and ISP info

📦 Dependencies

· Python 3.7+
· rich - Beautiful terminal formatting
· dnspython - DNS queries
· requests - HTTP requests

All dependencies are listed in requirements.txt.

🛠️ Development

Project Structure


ip-reverse-lookup/
├── README.md          # This file
├── LICENSE            # MIT License
├── requirements.txt   # Dependencies
├── .gitignore        # Git ignore file
├── setup.py          # Package setup
├── reverse_ip.py     # Main application
└── examples/
    └── example_output.txt  # Sample output


Contributing

1. Fork the repository
2. Create a feature branch (git checkout -b feature/amazing-feature)
3. Commit changes (git commit -m 'Add amazing feature')
4. Push to branch (git push origin feature/amazing-feature)
5. Open a Pull Request

🤝 Contributing

Contributions are what make the open-source community amazing. Any contributions you make are greatly appreciated.

1. Bug Reports: Open an issue describing the bug
2. Feature Requests: Open an issue describing the feature
3. Pull Requests: Submit a PR with your changes

📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

🙏 Acknowledgments

· Rich for beautiful terminal formatting
· ViewDNS for free API
· HackerTarget for free API
· Shodan for internetdb API
· IP-API for geolocation data

⭐ Show Your Support

If you found this tool helpful, please give it a ⭐ on GitHub!

---

Made with ❤️ by [EMR group]

---
