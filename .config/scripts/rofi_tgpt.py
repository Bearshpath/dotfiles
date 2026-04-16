#!/usr/bin/env python3
import subprocess
import textwrap
import sys

def rofi_input(prompt):
    """Smallest possible input bar."""
    theme = "window {width: 22%;} listview {lines: 0;} inputbar {children: [prompt,entry];}"
    cmd = ["rofi", "-dmenu", "-p", prompt, "-theme-str", theme]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, text=True)
    out, _ = proc.communicate()
    return out.strip()

def rofi_popup(title, content):
    """Compact, small-width, and scrollable UI."""
    # 1. Clean markdown
    clean_content = content.replace('**', '').replace('__', '')
    
    # 2. Preparation & Header
    wrapped_lines = []
    wrapped_lines.append(f" ✨ {title}")
    wrapped_lines.append(" ────────────────────────────────")
    
    for line in clean_content.split('\n'):
        if line.strip() == "":
            wrapped_lines.append("")
        else:
            # SHRUNK width to 45 characters to prevent the "..." dots
            wrapped_lines.extend(textwrap.wrap(line, width=35, break_long_words=False))
            
    rofi_text = "\n".join(wrapped_lines)
    
    # 3. COMPACT SIZING
    line_count = len(wrapped_lines)
    # MAX LINES reduced to 10 for a much smaller height
    display_lines = min(max(line_count, 3), 10)
    
    # 4. MINI THEME
    # width: 30% (Much smaller)
    # entry/inputbar: disabled to remove UI clutter
    theme = f"""
    window {{ 
        width: 30%; 
        border-radius: 10px; 
    }} 
    listview {{ 
        lines: {display_lines}; 
        scrollbar: true; 
        fixed-height: false;
        dynamic: true;
    }} 
    element-text {{
        padding: 2px 5px;
    }}
    entry {{ enabled: false; }}
    inputbar {{ enabled: false; }}
    """
    
    cmd = ["rofi", "-dmenu", "-i", "-theme-str", theme]
    subprocess.run(cmd, input=rofi_text, text=True)

def main():
    query = rofi_input("AI")
    if not query: return
    
    subprocess.run(["notify-send", "AI Assistant", "Generating..."])
    
    try:
        proc = subprocess.Popen(["tgpt", "-q", "-w", query], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
        out, _ = proc.communicate()
        
        if out:
            rofi_popup(query, out.strip())
        else:
            subprocess.run(["notify-send", "Error", "No response"])
            
    except Exception:
        pass

if __name__ == "__main__":
    main()
