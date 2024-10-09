#!/usr/bin/env python

import os
import sys
import getpass
import socket
import jinja2
import i3_vars

try:
    sys.argv[2]
except IndexError:
    user = getpass.getuser()
else:
    user = str(sys.argv[2])

homedir = "/home/{}".format(user)
i3config = ".i3/config"
cwd = os.path.dirname(os.path.realpath(__file__))
hostname = socket.gethostname()
screenlayout = sys.argv[1]

def render(template_path, context):
    path, filename = os.path.split(template_path)
    return jinja2.Environment(
        loader=jinja2.FileSystemLoader(path or './')
    ).get_template(filename).render(context)

if __name__ == "__main__":
    context = i3_vars.vars(hostname, screenlayout)
    result = render(os.path.join(cwd, 'i3-conf/i3-config.j2'), context)

    with open(os.path.join(homedir, i3config), 'w') as conf:
        conf.write(result)
