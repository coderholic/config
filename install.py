#!/usr/bin/env python
import os
import os.path
ignores = ['.git', 'README', 'install.py']
for file in os.listdir("."):
	if not file in ignores:
		original = os.path.abspath(file)
		new = os.path.join(os.environ['HOME'], file)
		os.symlink(original, new)
		print "Symlinked %s -> %s" % (original, new)
