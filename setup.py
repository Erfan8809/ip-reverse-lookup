cat > setup.py << 'EOF'
#!/usr/bin/env python3
"""
Setup configuration for IP Reverse Lookup Tool
"""

from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="ip-reverse-lookup",
    version="3.0.0",
    author="Your Name",
    author_email="your.email@example.com",
    description="Find all domains hosted on an IP address",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/yourusername/ip-reverse-lookup",
    packages=find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Topic :: Security",
        "Topic :: Internet",
        "Topic :: System :: Networking",
    ],
    python_requires=">=3.7",
    install_requires=[
        "rich>=13.7.0",
        "dnspython>=2.4.0",
        "requests>=2.31.0",
    ],
    entry_points={
        "console_scripts": [
            "reverse-ip=reverse_ip:main",
        ],
    },
)
EOF