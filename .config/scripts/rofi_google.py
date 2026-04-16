#!/usr/bin/env python3
import urllib.request
import urllib.parse
import subprocess
import json
import re
import html
import sys

def rofi_input(prompt):
    """Spawns the search bar."""
    cmd =["rofi", "-dmenu", "-p", prompt, "-theme-str", "window {width: 40%;} listview {lines: 0;}"]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
    out, _ = proc.communicate()
    return out.strip()

def rofi_popup(title, content):
    """Spawns a pure text popup that is easy to read and left-aligned."""
    message = f"🔍 {title}\n\n{content}"
    # Left-aligning the textbox makes reading paragraphs much nicer
    theme = "window {width: 60%;} textbox {horizontal-align: 0.0; margin: 15px;}"
    cmd =["rofi", "-e", message, "-theme-str", theme]
    subprocess.run(cmd)

def search_ddg_lite(query):
    """
    The Open-Source Standard: Scrapes DDG Lite. 
    It is blazing fast, unblockable, and has a permanent HTML structure.
    """
    url = "https://lite.duckduckgo.com/lite/"
    data = urllib.parse.urlencode({'q': query}).encode('utf-8')
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    
    try:
        req = urllib.request.Request(url, data=data, headers=headers)
        with urllib.request.urlopen(req, timeout=4) as res:
            html_data = res.read().decode('utf-8', errors='ignore')
            
            # Extract the raw snippet blocks. This class never changes.
            snippets = re.findall(r'<td class=\'result-snippet\'[^>]*>(.*?)</td>', html_data, re.IGNORECASE | re.DOTALL)
            
            if snippets:
                results =[]
                # Grab the top 2 results
                for s in snippets[:2]:
                    # Remove all HTML tags (like <b> and <i>)
                    clean = re.sub(r'<[^>]+>', '', s).strip()
                    # Fix weird characters (like &amp; or &#39;)
                    clean = html.unescape(clean)
                    if clean:
                        results.append(f"• {clean}")
                
                if results:
                    return "\n\n".join(results)
        return None
    except Exception as e:
        return None

def search_wikipedia(query):
    """Fallback: Wikipedia API for deep definitions."""
    try:
        search_url = f"https://en.wikipedia.org/w/api.php?action=opensearch&format=json&limit=1&search={urllib.parse.quote(query)}"
        req = urllib.request.Request(search_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=3) as res:
            data = json.loads(res.read().decode())
            if not data[1]: return None
            title = data[1][0]
            
        summary_url = f"https://en.wikipedia.org/api/rest_v1/page/summary/{urllib.parse.quote(title)}"
        req2 = urllib.request.Request(summary_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req2, timeout=3) as res2:
            summary_data = json.loads(res2.read().decode())
            extract = summary_data.get("extract")
            if extract and "may refer to" not in extract: 
                return extract
        return None
    except:
        return None

def main():
    query = rofi_input("Web Assistant:")
    if not query: return
    
    # Optional: Send a notification so you know it's loading
    subprocess.run(["notify-send", "Assistant", f"Researching: {query}..."])
    
    # 1. Try DuckDuckGo Lite (Catches facts, math, mass of helium, current news)
    ddg_answer = search_ddg_lite(query)
    if ddg_answer:
        rofi_popup(query, ddg_answer)
        return
        
    # 2. Try Wikipedia API (Catches deep history and biographies)
    wiki_answer = search_wikipedia(query)
    if wiki_answer:
        rofi_popup(f"Wikipedia: {query}", wiki_answer)
        return
        
    rofi_popup("ERROR", "Could not find a direct answer. Please try rephrasing.")

if __name__ == "__main__":
    main()
