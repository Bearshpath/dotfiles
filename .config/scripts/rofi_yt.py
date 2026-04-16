#!/usr/bin/env python3
import json
import subprocess
import urllib.request
import sys

# --- CONFIGURATION ---
# Android client spoofing is the ONLY way to bypass the 2-minute buffering lag
MPV_OPTS = "--no-audio-display --hwdec=auto --panscan=1.0 --ytdl-format=best --ytdl-raw-options=extractor-args=youtube:player_client=android"

def rofi(prompt, options=None, lines=10, width="30%"):
    """Ultra-fast Rofi wrapper."""
    theme = f"window {{width: {width};}} listview {{lines: {lines};}}"
    cmd = ["rofi", "-dmenu", "-i", "-p", prompt, "-theme-str", theme]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
    out, _ = proc.communicate(input="\n".join(options) if options else "")
    return out.strip()

def search_innertube(query):
    """Directly queries YouTube's internal API. Returns results in ~200ms."""
    url = "https://www.youtube.com/youtubei/v1/search?key=AIzaSyAO8_V82-wK_PqE2y9n27nMvH0h-4P14"
    data = {
        "context": {"client": {"clientName": "WEB", "clientVersion": "2.20240210.01.00"}},
        "query": query
    }
    req = urllib.request.Request(url, data=json.dumps(data).encode(), headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req) as res:
            raw = json.loads(res.read().decode())
            # Drill down into the massive JSON response
            contents = raw['contents']['twoColumnSearchResultsRenderer']['primaryContents']['sectionListRenderer']['contents'][0]['itemSectionRenderer']['contents']
            results = []
            for item in contents:
                if 'videoRenderer' in item:
                    v = item['videoRenderer']
                    title = v['title']['runs'][0]['text']
                    vid_id = v['videoId']
                    author = v['shortBylineText']['runs'][0]['text']
                    results.append(f"{title} | {author} | {vid_id}")
            return results
    except Exception as e:
        subprocess.run(["notify-send", "YT Error", "API Throttled or Network Down"])
        return []

def main():
    # 1. Selection Mode Menu
    mode = rofi("Action:", ["🖥️ Wallpaper", "🎦 Window", "🛑 Stop Video"], lines=3, width="20%")
    if not mode: return

    if "Stop" in mode:
        subprocess.run(["pkill", "-f", "mpv"])
        return

    # 2. Search Query
    query = rofi("Search:", lines=0)
    if not query: return

    # 3. Instant Search
    results = search_innertube(query)
    if not results: return

    # 4. Pick Video
    pick = rofi("Select Video:", results, lines=12, width="60%")
    if not pick: return
    vid_id = pick.split(" | ")[-1]
    url = f"https://www.youtube.com/watch?v={vid_id}"

    # 5. Playback
    if "Wallpaper" in mode:
        subprocess.run(["pkill", "-f", "mpvpaper"])
        subprocess.Popen(f"mpvpaper -o '{MPV_OPTS} --loop-file=inf' '*' '{url}'", shell=True)
    else:
        subprocess.Popen(f"mpv {MPV_OPTS} '{url}'", shell=True)

if __name__ == "__main__":
    main()
