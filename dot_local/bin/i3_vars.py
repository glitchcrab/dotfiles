#!/usr/bin/env python

import subprocess

def vars(hostname, screenlayout):

    # get connected monitors
    xrandr_cmd = "xrandr | awk '/ connected/' | awk '{print $1}'"
    run_cmd = subprocess.Popen(xrandr_cmd,shell=True,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    monitors = run_cmd.communicate()[0].split()

    # ensure array always has three elements
    if len(monitors) == 1:
        monitors.append('dummy1')
        monitors.append('dummy2')

    if hostname.startswith("raleigh"):
        host_vars = {
            'primary_display': 'eDP-1',
            'left_display': 'HDMI-1',
            'right_display': 'DP-2'
        }
    elif hostname.startswith("phoenix"):
        host_vars = {
            'primary_display': 'eDP1',
            'left_display': 'DP3',
            'right_display': 'DP1'
        }
    elif hostname.startswith("cheyenne"):
        host_vars = {
            'primary_display': str(monitors[0]),
            'left_display': str(monitors[1]),
            'right_display': str(monitors[2])
        }

    bind_progs = {
        "[class=\"^Firefox$\"]": "1",
        "[class=\"^Chromium$\"]": "3",
        "[class=\"^code - oss\"]": "6",
        "[class=\"^[Ss]potify.*$\"]": "7",
        "[class=\"^[Ss]lack\"]": "4"
    }

    helper_progs = [
        "/usr/bin/numlockx on"
    ]

    i3_window_overrides= [
        "[class=\"^[Vv]irtual[Bb]ox*$\"] floating enable",
        "[class=\"^[Tt]ransmission*$\"] floating enable border normal",
        "[class=\"^qemu-system-x86_64*$\"] floating enable",
        "[class=\"^[Ff]ile-roller.*$\"] floating enable border normal",
        "[class=\"[Vv]irt-manager.*$\"] floating enable border normal",
        "[window_role=\"pop-up\"] floating enable border normal",
        "[class=\"^[Pp]avucontrol.*$\"] floating enable border normal",
        "[class=\"^[Bb]lueberry.py.*$\"] floating enable border normal",
        "[class=\"^[Gg]ufw.py.*$\"] floating enable border normal",
        "[class=\"^[Bb]itwarden.*$\"] floating enable border normal"
    ]

    if screenlayout == 'two_mon':
        layout_vars = {
            'gaps_inner': '20',
            'gaps_outer': '0'
        }
        move_workspace = {
            "Ctrl+Shift+1": host_vars['left_display'],
            "Ctrl+Shift+2": host_vars['right_display'],
            "Ctrl+Shift+3": host_vars['primary_display']
        }
        workspace_to_display = {
            "1": host_vars['left_display'],
            "2": host_vars['left_display'],
            "3": host_vars['right_display'],
            "4": host_vars['primary_display'],
            "5": host_vars['right_display'],
            "6": host_vars['right_display']
        }
    elif screenlayout == 'one_mon':
        layout_vars = {
            'gaps_inner': '20',
            'gaps_outer': '0'
        }
        move_workspace = {
            "Ctrl+Shift+1": "HDMI-1",
            "Ctrl+Shift+2": "eDP-1"
        }
        workspace_to_display = {
            "1": host_vars['left_display'],
            "2": host_vars['left_display'],
            "3": host_vars['left_display'],
            "4": host_vars['primary_display'],
            "5": host_vars['primary_display'],
            "6": host_vars['left_display']
        }
    elif screenlayout == 'no_mon':
        layout_vars = {
            'gaps_inner': '20',
            'gaps_outer': '0'
        }
        move_workspace = {}
        workspace_to_display = {}

    default_vars = {
        'mod_key': 'Mod4',
        'bar_font': "pango:SFNS Display 7, FontAwesome 7",
        'applications': helper_progs,
        'overrides': i3_window_overrides,
        'bind_progs': bind_progs,
        'move_workspace': move_workspace,
        'workspace_to_display': workspace_to_display
    }

    context = dict(default_vars)
    context.update(layout_vars)
    context.update(host_vars)

    return context
