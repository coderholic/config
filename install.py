#!/usr/bin/env python
import os
import os.path
ignores = ['.git', 'README', 'install.py', 'ssh_config']
# TODO: If 'file' is a directory don't symlink to it, instead create the dir (if it doesn't already exist) and symlink the files inside
for file in os.listdir("."):
    if not file in ignores:
        try:
            original = os.path.abspath(file)
            new = os.path.join(os.environ['HOME'], file)
            os.symlink(original, new)
            print "Symlinked %s -> %s" % (original, new)
        except Exception, e:
            print e, file

# Special case ssh config for now
new = os.path.join(os.environ['HOME'], '.ssh', 'config')
os.symlink(os.path.abspath('ssh_config'), new)
