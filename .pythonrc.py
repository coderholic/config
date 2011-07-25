# Most of these from http://sontek.net/tips-and-tricks-for-the-python-interpreter
import os

try:
    import readline
except ImportError:
    print("Module readline not available.")
else:
    import rlcompleter
    readline.parse_and_bind("tab: complete")

    # Enable a History
    HISTFILE="%s/.pyhistory" % os.environ["HOME"]

    # Read the existing history if there is one
    if os.path.exists(HISTFILE):
        readline.read_history_file(HISTFILE)

    # Set maximum number of items that will be written to the history file
    readline.set_history_length(300)

    def savehist():
        import readline
        global HISTFILE
        readline.write_history_file(HISTFILE)

    import atexit
    atexit.register(savehist)
finally:
    del rlcompleter
    del atexit

WELCOME=''
# Color Support
class TermColors(dict):
    """Gives easy access to ANSI color codes. Attempts to fall back to no color
    for certain TERM values. (Mostly stolen from IPython.)"""

    COLOR_TEMPLATES = (
        ("Black"       , "0;30"),
        ("Red"         , "0;31"),
        ("Green"       , "0;32"),
        ("Brown"       , "0;33"),
        ("Blue"        , "0;34"),
        ("Purple"      , "0;35"),
        ("Cyan"        , "0;36"),
        ("LightGray"   , "0;37"),
        ("DarkGray"    , "1;30"), ("LightRed"    , "1;31"),
        ("LightGreen"  , "1;32"),
        ("Yellow"      , "1;33"),
        ("LightBlue"   , "1;34"),
        ("LightPurple" , "1;35"),
        ("LightCyan"   , "1;36"),
        ("White"       , "1;37"),
        ("Normal"      , "0"),
    )

    NoColor = ''
    _base  = '\001\033[%sm\002'

    def __init__(self):
        if os.environ.get('TERM') in ('xterm-color', 'xterm-256color', 'linux',
                                    'screen', 'screen-256color', 'screen-bce'):
            self.update(dict([(k, self._base % v) for k,v in self.COLOR_TEMPLATES]))
        else:
            self.update(dict([(k, self.NoColor) for k,v in self.COLOR_TEMPLATES]))
_c = TermColors()



import sys
# Enable Color Prompts
sys.ps1 = '%s>>> %s' % (_c['Green'], _c['Normal'])
sys.ps2 = '%s... %s' % (_c['Red'], _c['Normal'])

# Enable Pretty Printing for stdout
def my_displayhook(value):
    if value is not None:
        try:
            import __builtin__
            __builtin__._ = value
        except ImportError:
            __builtins__._ = value

        import pprint
        pprint.pprint(value)
        del pprint

sys.displayhook = my_displayhook

if 'DJANGO_SETTINGS_MODULE' in os.environ:
    from django.db.models.loading import get_models
    from django.test.client import Client
    from django.test.utils import setup_test_environment, teardown_test_environment
    from django.conf import settings as S

    class DjangoModels(object):
        """Loop through all the models in INSTALLED_APPS and import them."""
        def __init__(self):
            for m in get_models():
                setattr(self, m.__name__, m)

    A = DjangoModels()
    C = Client()

    WELCOME += """%(Green)s
    Django environment detected.
* Your INSTALLED_APPS models are available as `A`.
* Your project settings are available as `S`.
* The Django test client is available as `C`.
%(Normal)s""" % _c
