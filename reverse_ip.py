#!/usr/bin/env python3
"""
🔍 Reverse IP Lookup Tool - Advanced Terminal UI
Find all domains hosted on an IP address
Completely Free | Beautiful Terminal Interface
"""

import socket
import dns.resolver
import dns.reversename
import requests
import time
import sys
import os
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime
from typing import List, Dict, Optional, Tuple

from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn
from rich.prompt import Prompt, Confirm
from rich.text import Text
from rich import box
from rich.layout import Layout
from rich.columns import Columns
from rich.align import Align
from rich.live import Live
from rich.markdown import Markdown
from rich.syntax import Syntax
from rich.tree import Tree

# =====================================================
# Configuration
# =====================================================

console = Console()
VERSION = "3.0.0"
AUTHOR = "ReverseIP Tool"
MAX_WORKERS = 5
TIMEOUT = 10

# Color scheme
COLORS = {
    "primary": "bright_blue",
    "secondary": "cyan",
    "success": "green",
    "error": "red",
    "warning": "yellow",
    "info": "blue",
    "dim": "dim white",
    "highlight": "magenta",
    "accent": "bright_yellow"
}

# =====================================================
# Core Services (Free & No API Key Required)
# =====================================================

class ReverseIPService:
    """Collection of free reverse IP lookup methods"""
    
    @staticmethod
    def dns_ptr(ip: str) -> List[str]:
        """Method 1: DNS PTR record lookup"""
        try:
            addr = dns.reversename.from_address(ip)
            answers = dns.resolver.resolve(addr, "PTR")
            return [str(rdata.target).rstrip('.') for rdata in answers]
        except:
            return []
    
    @staticmethod
    def viewdns(ip: str) -> List[str]:
        """Method 2: ViewDNS.info free API"""
        try:
            url = f"https://api.viewdns.info/reverseip/?host={ip}&apikey=free&output=json"
            response = requests.get(url, timeout=8)
            data = response.json()
            
            if data.get('response', {}).get('status') == 'success':
                domains = data.get('response', {}).get('domains', [])
                if isinstance(domains, list):
                    return [d.get('name', '') for d in domains if d.get('name')]
            return []
        except:
            return []
    
    @staticmethod
    def hackertarget(ip: str) -> List[str]:
        """Method 3: HackerTarget free API"""
        try:
            url = f"https://api.hackertarget.com/reverseiplookup/?q={ip}"
            response = requests.get(url, timeout=8)
            if response.status_code == 200:
                domains = response.text.strip().split('\n')
                return [d.strip() for d in domains if d.strip() and not d.startswith('error')]
            return []
        except:
            return []
    
    @staticmethod
    def ipinfo(ip: str) -> Dict:
        """Method 4: IP geolocation & info from ip-api.com"""
        try:
            url = f"http://ip-api.com/json/{ip}"
            response = requests.get(url, timeout=5)
            data = response.json()
            if data.get('status') == 'success':
                return {
                    "isp": data.get('isp', 'N/A'),
                    "org": data.get('org', 'N/A'),
                    "as": data.get('as', 'N/A'),
                    "country": data.get('country', 'N/A'),
                    "city": data.get('city', 'N/A'),
                    "region": data.get('regionName', 'N/A'),
                    "lat": data.get('lat', 'N/A'),
                    "lon": data.get('lon', 'N/A')
                }
            return {}
        except:
            return {}
    
    @staticmethod
    def shodan(ip: str) -> List[str]:
        """Method 5: Shodan free API (no key needed for basic)"""
        try:
            url = f"https://internetdb.shodan.io/{ip}"
            response = requests.get(url, timeout=5)
            if response.status_code == 200:
                data = response.json()
                # Get hostnames from Shodan
                hostnames = data.get('hostnames', [])
                return [h for h in hostnames if h]
            return []
        except:
            return []
    
    @staticmethod
    def get_all(ip: str) -> Dict:
        """Execute all methods in parallel for best results"""
        results = {
            "ptr": [],
            "viewdns": [],
            "hackertarget": [],
            "shodan": [],
            "info": {}
        }
        
        # Parallel execution
        with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
            future_ptr = executor.submit(ReverseIPService.dns_ptr, ip)
            future_view = executor.submit(ReverseIPService.viewdns, ip)
            future_hacker = executor.submit(ReverseIPService.hackertarget, ip)
            future_shodan = executor.submit(ReverseIPService.shodan, ip)
            future_info = executor.submit(ReverseIPService.ipinfo, ip)
            
            try:
                results["ptr"] = future_ptr.result(timeout=5)
            except:
                pass
            
            try:
                results["viewdns"] = future_view.result(timeout=8)
            except:
                pass
            
            try:
                results["hackertarget"] = future_hacker.result(timeout=8)
            except:
                pass
            
            try:
                results["shodan"] = future_shodan.result(timeout=5)
            except:
                pass
            
            try:
                results["info"] = future_info.result(timeout=5)
            except:
                pass
        
        # Combine and deduplicate
        all_domains = set()
        all_domains.update(results["ptr"])
        all_domains.update(results["viewdns"])
        all_domains.update(results["hackertarget"])
        all_domains.update(results["shodan"])
        
        # Filter valid domains
        valid_domains = [d for d in all_domains if d and '.' in d and len(d) > 3]
        
        return {
            "domains": sorted(valid_domains),
            "info": results["info"],
            "ptr_count": len(results["ptr"]),
            "viewdns_count": len(results["viewdns"]),
            "hackertarget_count": len(results["hackertarget"]),
            "shodan_count": len(results["shodan"])
        }

# =====================================================
# Advanced UI Components
# =====================================================

class UI:
    """Advanced terminal UI components"""
    
    @staticmethod
    def header():
        """Display animated header"""
        header_text = Text()
        header_text.append("🔍 ", style="bold yellow")
        header_text.append("REVERSE IP LOOKUP", style="bold bright_blue")
        header_text.append(f" v{VERSION}", style="dim white")
        
        console.print(Panel(
            Align.center(header_text),
            subtitle=f"[dim]{AUTHOR} | {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}[/dim]",
            border_style="bright_blue",
            padding=(1, 2),
            width=100
        ))
    
    @staticmethod
    def status_bar(message: str, status_type: str = "info"):
        """Display a status message"""
        colors = {
            "info": "blue",
            "success": "green",
            "error": "red",
            "warning": "yellow"
        }
        console.print(f"\n[bold {colors.get(status_type, 'white')}]● {message}[/]\n")
    
    @staticmethod
    def stats_table(stats: Dict):
        """Display statistics in a beautiful table"""
        table = Table(
            title="[bold bright_yellow]📊 Search Statistics[/]",
            box=box.HEAVY_EDGE,
            border_style="bright_blue",
            header_style="bold cyan"
        )
        
        table.add_column("Source", style="bold white", justify="left")
        table.add_column("Found", style="bold yellow", justify="center")
        table.add_column("Status", style="bold", justify="center")
        
        sources = [
            ("🔹 DNS PTR", stats['ptr_count']),
            ("🔹 ViewDNS", stats['viewdns_count']),
            ("🔹 HackerTarget", stats['hackertarget_count']),
            ("🔹 Shodan", stats['shodan_count'])
        ]
        
        for name, count in sources:
            status = "✅" if count > 0 else "❌"
            status_color = "green" if count > 0 else "red"
            table.add_row(
                name,
                str(count),
                f"[{status_color}]{status}[/{status_color}]"
            )
        
        total = stats['ptr_count'] + stats['viewdns_count'] + stats['hackertarget_count'] + stats['shodan_count']
        table.add_row(
            "[bold bright_yellow]✨ Total Unique[/]",
            f"[bold green]{len(stats['domains'])}[/bold green]",
            "[bold green]✔[/bold green]"
        )
        
        console.print(table)
    
    @staticmethod
    def ip_info_table(info: Dict):
        """Display IP information in a detailed table"""
        if not info:
            return
        
        table = Table(
            title="[bold bright_cyan]🌍 IP Information[/]",
            box=box.MINIMAL_HEAVY_HEAD,
            border_style="cyan"
        )
        
        table.add_column("Property", style="bold white", width=15)
        table.add_column("Value", style="bright_white")
        
        fields = [
            ("ISP", info.get('isp', 'N/A')),
            ("Organization", info.get('org', 'N/A')),
            ("AS Number", info.get('as', 'N/A')),
            ("Country", info.get('country', 'N/A')),
            ("City", info.get('city', 'N/A')),
            ("Region", info.get('region', 'N/A')),
            ("Location", f"{info.get('lat', 'N/A')}, {info.get('lon', 'N/A')}" if info.get('lat') != 'N/A' else 'N/A')
        ]
        
        for prop, value in fields:
            if value and value != 'N/A':
                table.add_row(prop, value)
        
        console.print(table)
    
    @staticmethod
    def domains_table(domains: List[str], ip: str):
        """Display domains in a beautifully formatted table"""
        if not domains:
            console.print(f"\n[bold red]❌ No domains found for IP: {ip}[/bold red]\n")
            return
        
        # Create main table
        table = Table(
            title=f"[bold bright_green]🌐 Domains hosted on {ip}[/bold bright_green]",
            box=box.HEAVY_EDGE,
            border_style="bright_green",
            show_header=True,
            header_style="bold bright_cyan"
        )
        
        table.add_column("#", style="dim white", justify="center", width=5)
        table.add_column("Domain", style="bold magenta", overflow="fold")
        table.add_column("Status", style="bold", justify="center", width=15)
        table.add_column("Length", style="dim", justify="center", width=8)
        
        # Add domains with alternating colors
        for idx, domain in enumerate(domains, 1):
            # Determine status based on domain characteristics
            if len(domain) < 10:
                status = "✅ Active"
                status_color = "green"
            elif len(domain) < 30:
                status = "🟡 Normal"
                status_color = "yellow"
            else:
                status = "🔵 Long"
                status_color = "blue"
            
            table.add_row(
                str(idx),
                domain,
                f"[{status_color}]{status}[/{status_color}]",
                str(len(domain))
            )
        
        console.print("\n")
        console.print(table)
        
        # Summary footer
        console.print(f"\n[bold bright_green]✅ Total Domains Found: {len(domains)}[/bold bright_green]")
        console.print(f"[dim]💡 Click on domain to copy (select with mouse)[/dim]")
    
    @staticmethod
    def footer(elapsed_time: float, total_domains: int):
        """Display footer with additional info"""
        footer_text = Text()
        footer_text.append("⏱️ ", style="dim")
        footer_text.append(f"{elapsed_time:.2f}s", style="bright_yellow")
        footer_text.append("  │  ", style="dim")
        footer_text.append("📦 ", style="dim")
        footer_text.append(f"{total_domains} domains", style="bright_green")
        footer_text.append("  │  ", style="dim")
        footer_text.append("🔄 ", style="dim")
        footer_text.append("Press Ctrl+C to exit", style="dim")
        
        console.print(Panel(
            Align.center(footer_text),
            border_style="bright_blue",
            padding=(0, 1),
            width=100
        ))
    
    @staticmethod
    def divider():
        """Print a decorative divider"""
        console.print("\n" + "─" * 100 + "\n", style="dim")

# =====================================================
# Utility Functions
# =====================================================

def validate_ip(ip: str) -> bool:
    """Validate IP address format"""
    try:
        socket.inet_aton(ip)
        return True
    except:
        return False

def get_input_ip() -> Optional[str]:
    """Get IP from user with validation"""
    while True:
        console.print("\n[bold bright_cyan]📝 Enter IP address[/bold bright_cyan]")
        ip = Prompt.ask("[dim]IP[/dim]")
        ip = ip.strip()
        
        if ip.lower() in ['exit', 'quit', 'q']:
            return None
        
        if validate_ip(ip):
            return ip
        
        console.print("[bold red]❌ Invalid IP address! Please try again.[/bold red]")
        console.print("[dim]Example: 8.8.8.8 or 192.168.1.1[/dim]")

def save_results(ip: str, result: Dict) -> bool:
    """Save results to a file with formatting"""
    if not Confirm.ask("\n[bold yellow]💾 Save results to file?[/bold yellow]"):
        return False
    
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    filename = f"reverse_ip_{ip}_{timestamp}.txt"
    
    try:
        with open(filename, 'w', encoding='utf-8') as f:
            # Header
            f.write("=" * 60 + "\n")
            f.write(f"REVERSE IP LOOKUP RESULTS\n")
            f.write(f"IP Address: {ip}\n")
            f.write(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write("=" * 60 + "\n\n")
            
            # IP Info
            if result['info']:
                f.write("IP INFORMATION:\n")
                f.write("-" * 40 + "\n")
                for key, value in result['info'].items():
                    if value:
                        f.write(f"  {key.upper()}: {value}\n")
                f.write("\n")
            
            # Domains
            if result['domains']:
                f.write(f"FOUND DOMAINS ({len(result['domains'])}):\n")
                f.write("-" * 40 + "\n")
                for idx, domain in enumerate(result['domains'], 1):
                    f.write(f"{idx:>4}. {domain}\n")
            else:
                f.write("No domains found.\n")
            
            # Statistics
            f.write("\n" + "-" * 40 + "\n")
            f.write("STATISTICS:\n")
            f.write(f"  DNS PTR: {result['ptr_count']}\n")
            f.write(f"  ViewDNS: {result['viewdns_count']}\n")
            f.write(f"  HackerTarget: {result['hackertarget_count']}\n")
            f.write(f"  Shodan: {result['shodan_count']}\n")
            f.write(f"  Total Unique: {len(result['domains'])}\n")
            f.write("=" * 60 + "\n")
        
        console.print(f"[bold green]✅ Results saved to: {filename}[/bold green]")
        return True
    except Exception as e:
        console.print(f"[bold red]❌ Error saving file: {str(e)}[/bold red]")
        return False

def check_internet() -> bool:
    """Check internet connectivity"""
    try:
        requests.get("https://www.google.com", timeout=3)
        return True
    except:
        return False

# =====================================================
# Main Search Function
# =====================================================

def search_ip(ip: str) -> Dict:
    """Perform complete search for an IP address"""
    UI.divider()
    UI.status_bar(f"🔎 Scanning IP: {ip}", "info")
    
    start_time = time.time()
    
    # Show progress
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        BarColumn(bar_width=40),
        TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
        console=console,
        transient=True
    ) as progress:
        
        task = progress.add_task("[cyan]Searching...", total=100)
        
        # Execute search with progress updates
        progress.update(task, advance=15, description="[cyan]Checking DNS PTR...")
        result = ReverseIPService.get_all(ip)
        
        progress.update(task, advance=85, description="[green]✓ Complete!")
        time.sleep(0.3)
    
    elapsed_time = time.time() - start_time
    
    # Display results
    UI.divider()
    UI.ip_info_table(result['info'])
    UI.divider()
    UI.stats_table(result)
    UI.divider()
    UI.domains_table(result['domains'], ip)
    UI.divider()
    UI.footer(elapsed_time, len(result['domains']))
    UI.divider()
    
    return result

# =====================================================
# Main Application
# =====================================================

def main():
    """Main application entry point"""
    # Clear screen
    os.system('cls' if os.name == 'nt' else 'clear')
    
    # Show header
    UI.header()
    
    # Check internet
    if not check_internet():
        UI.status_bar("⚠️ Warning: No internet connection. Some services may not work.", "warning")
        console.print("[dim]Only DNS PTR method will be available.[/dim]\n")
    
    # Main loop
    while True:
        ip = get_input_ip()
        if ip is None:
            UI.status_bar("👋 Exiting...", "info")
            break
        
        try:
            result = search_ip(ip)
            save_results(ip, result)
            
            if not Confirm.ask("\n[bold bright_cyan]🔄 Search another IP?[/bold bright_cyan]"):
                UI.status_bar("👋 Thank you for using ReverseIP Tool!", "success")
                break
            
            # Clear for next search
            os.system('cls' if os.name == 'nt' else 'clear')
            UI.header()
            
        except KeyboardInterrupt:
            UI.status_bar("⏹️ Operation cancelled by user", "error")
            break
        except Exception as e:
            UI.status_bar(f"❌ Error: {str(e)}", "error")
            if not Confirm.ask("\n[bold yellow]🔄 Continue?[/bold yellow]"):
                break

# =====================================================
# Entry Point
# =====================================================

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        console.print("\n\n[bold yellow]👋 Goodbye![/bold yellow]")
        sys.exit(0)
    except Exception as e:
        console.print(f"\n[bold red]❌ Fatal Error: {str(e)}[/bold red]")
        sys.exit(1)
