from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    draw_tab,
)
from datetime import datetime
import subprocess

def get_current_time():
    return datetime.now().strftime("%H:%M")

def get_battery_status():
    try:
        output = subprocess.check_output(["pmset", "-g", "batt"]).decode("utf-8")
        for line in output.split('\n'):
            if "InternalBattery" in line:
                percentage = line.split('\t')[1].split(';')[0]
                charging = "discharging" not in line.lower()
                icon = "🔌" if charging else "🔋"
                return f"{icon} {percentage}"
    except:
        return ""
    return ""

def draw_tab(
    draw_data: DrawData,
    screen: str,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    orig_draw_tab = draw_tab
    end = orig_draw_tab(draw_data, screen, tab, before, max_title_length, index, is_last, extra_data)
    
    # Draw custom elements on the right side
    time_str = get_current_time()
    battery_str = get_battery_status()
    right_status = f" {time_str} | {battery_str} "
    
    cells = draw_data.screen.columns
    right_start = cells - len(right_status)
    
    fg, bg = screen.cursor.fg, screen.cursor.bg
    screen.draw(right_start, 0, right_status, fg, bg)
    
    return end
