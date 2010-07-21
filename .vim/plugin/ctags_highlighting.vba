" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/ctags_highlighting.vim	[[[1
412
" ctags_highlighting
"   Author:  A. S. Budden
"## Date::   2nd March 2010          ##
"## RevTag:: r390                    ##

if &cp || exists("g:loaded_ctags_highlighting")
	finish
endif
let g:loaded_ctags_highlighting = 1

let s:CTagsHighlighterVersion = "## RevTag:: r390 ##"
let s:CTagsHighlighterVersion = substitute(s:CTagsHighlighterVersion, '## RevTag:: r390      ##', '\1', '')

if !exists('g:VIMFILESDIR')
	let g:VIMFILESDIR = fnamemodify(globpath(&rtp, 'mktypes.py'), ':p:h')
endif

let g:DBG_None        = 0
let g:DBG_Critical    = 1
let g:DBG_Error       = 2
let g:DBG_Warning     = 3
let g:DBG_Status      = 4
let g:DBG_Information = 5

if !exists('g:CTagsHighlighterDebug')
	let g:CTagsHighlighterDebug = g:DBG_None
endif

" These should only be included if editing a wx or qt file
" They should also be updated to include all functions etc, not just
" typedefs
let g:wxTypesFile = escape(globpath(&rtp, "types_wx.vim"), ' \,')
let g:qtTypesFile = escape(globpath(&rtp, "types_qt4.vim"), ' \,')
let g:wxPyTypesFile = escape(globpath(&rtp, "types_wxpy.vim"), ' \,')

" These should only be included if editing a wx or qt file
let g:wxTagsFile = escape(globpath(&rtp, 'tags_wx'), ' \,')
let g:qtTagsFile = escape(globpath(&rtp, 'tags_qt4'), ' \,')
let g:wxPyTagsFile = escape(globpath(&rtp, 'tags_wxpy'), ' \,')

" Update types & tags - called with a ! recurses
command! -bang -bar UpdateTypesFile silent call UpdateTypesFile(<bang>0, 0) | 
			\ let s:SavedTabNr = tabpagenr() |
			\ let s:SavedWinNr = winnr() |
			\ silent tabdo windo call ReadTypesAutoDetect() |
			\ silent exe 'tabn ' . s:SavedTabNr |
			\ silent exe s:SavedWinNr . "wincmd w"

command! -bang -bar UpdateTypesFileOnly silent call UpdateTypesFile(<bang>0, 1) | 
			\ let s:SavedTabNr = tabpagenr() |
			\ let s:SavedWinNr = winnr() |
			\ silent tabdo windo call ReadTypesAutoDetect() |
			\ silent exe 'tabn ' . s:SavedTabNr |
			\ silent exe s:SavedWinNr . "wincmd w"

" load the types_*.vim highlighting file, if it exists
autocmd BufRead,BufNewFile *.[ch]   call ReadTypes('c')
autocmd BufRead,BufNewFile *.[ch]pp call ReadTypes('c')
autocmd BufRead,BufNewFile *.p[lm]  call ReadTypes('pl')
autocmd BufRead,BufNewFile *.java   call ReadTypes('java')
autocmd BufRead,BufNewFile *.py     call ReadTypes('py')
autocmd BufRead,BufNewFile *.pyw    call ReadTypes('py')
autocmd BufRead,BufNewFile *.rb     call ReadTypes('ruby')
autocmd BufRead,BufNewFile *.vhd*   call ReadTypes('vhdl')
autocmd BufRead,BufNewFile *.php    call ReadTypes('php')
autocmd BufRead,BufNewFile *.cs     call ReadTypes('cs')

command! ReadTypes call ReadTypesAutoDetect()

function! ReadTypesAutoDetect()
	let extension = expand('%:e')
	let extensionLookup = 
				\ {
				\     '[ch]\(pp\)\?' : "c",
				\     'p[lm]'        : "pl",
				\     'java'         : "java",
				\     'pyw\?'        : "py",
				\     'rb'           : "ruby",
				\     'cs'           : "cs",
				\     'php'          : "php",
				\     'vhdl\?'       : "vhdl",
				\ }

	for key in keys(extensionLookup)
		let regex = '^' . key . '$'
		if extension =~ regex
			call ReadTypes(extensionLookup[key])
			"			echo 'Loading types for ' . extensionLookup[key] . ' files'
			continue
		endif
	endfor
endfunction

function! ReadTypes(suffix)
	let savedView = winsaveview()

	let file = '<afile>'
	if len(expand(file)) == 0
		let file = '%'
	endif

	if exists('b:NoTypeParsing')
		return
	endif
	if exists('g:TypeParsingSkipList')
		let basename = expand(file . ':p:t')
		let fullname = expand(file . ':p')
		if index(g:TypeParsingSkipList, basename) != -1
			return
		endif
		if index(g:TypeParsingSkipList, fullname) != -1
			return
		endif
	endif
	let fname = expand(file . ':p:h') . '/types_' . a:suffix . '.vim'
	if filereadable(fname)
		exe 'so ' . fname
	endif
	let fname = expand(file . ':p:h:h') . '/types_' . a:suffix . '.vim'
	if filereadable(fname)
		exe 'so ' . fname
	endif
	let fname = 'types_' . a:suffix . '.vim'
	if filereadable(fname)
		exe 'so ' . fname
	endif

	" Open default source files
	if index(['cpp', 'h', 'hpp'], expand(file . ':e')) != -1
		" This is a C++ source file
		call cursor(1,1)
		if search('^\s*#include\s\+<wx/', 'nc', 30)
			if filereadable(g:wxTypesFile)
				execute 'so ' . g:wxTypesFile
			endif
			if filereadable(g:wxTagsFile)
				execute 'setlocal tags+=' . g:wxTagsFile
			endif
		endif

		call cursor(1,1)
		if search('\c^\s*#include\s\+<q', 'nc', 30)
			if filereadable(g:qtTypesFile)
				execute 'so ' . g:qtTypesFile
			endif
			if filereadable(g:qtTagsFile)
				execute 'setlocal tags+=' . g:qtTagsFile
			endif
		else
		endif
	elseif index(['py', 'pyw'], expand(file . ':e')) != -1
		" This is a python source file

		call cursor(1,1)
		if search('^\s*import\s\+wx', 'nc', 30)
			if filereadable(g:wxPyTypesFile)
				execute 'so ' . g:wxPyTypesFile
			endif
			if filereadable(g:wxPyTagsFile)
				execute 'setlocal tags+=' . g:wxPyTagsFile
			endif
		endif
	endif

	" Restore the view
	call winrestview(savedView)
endfunction

func! s:Debug_Print(level, message)
	if g:CTagsHighlighterDebug >= a:level
		echomsg a:message
	endif
endfunc

func! s:FindExePath(file)
	if has("win32")
		let short_file = fnamemodify(a:file . '.exe', ':p:t')
		let path = substitute($PATH, '\\\?;', ',', 'g')

		call s:Debug_Print(g:DBG_Status, "Looking for " . short_file . " in " . path)

		let file_exe_list = split(globpath(path, short_file), '\n')
		if len(file_exe_list) > 0
			call s:Debug_Print(g:DBG_Status, "Success.")
			let file_exe = file_exe_list[0]
		else
			call s:Debug_Print(g:DBG_Status, "Not found.")
			let file_exe = ''
		endif

		" If file is not in the path, look for it in vimfiles/
		if !filereadable(file_exe)
			call s:Debug_Print(g:DBG_Status, "Looking for " . a:file . " in " . &rtp)
			let file_exe_list = split(globpath(&rtp, a:file . '.exe'))
			if len(file_exe_list) > 0
				call s:Debug_Print(g:DBG_Status, "Success.")
				let file_exe = file_exe_list[0]
			else
				call s:Debug_Print(g:DBG_Status, "Not found.")
			endif
		endif

		if filereadable(file_exe)
			call s:Debug_Print(g:DBG_Status, "Success.")
			let file_path = shellescape(fnamemodify(file_exe, ':p:h'))
		else
			call s:Debug_Print(g:DBG_Critical, "Could not find " . short_file)
			throw "Cannot find file " . short_file
		endif
	else
		let path = substitute($PATH, ':', ',', 'g')
		if has("win32unix")
			let short_file = fnamemodify(a:file . '.exe', ':p:t')
		else
			let short_file = fnamemodify(a:file, ':p:t')
		endif

		call s:Debug_Print(g:DBG_Status, "Looking for " . short_file . " in " . path)

		let file_exe_list = split(globpath(path, short_file))

		if len(file_exe_list) > 0
			call s:Debug_Print(g:DBG_Status, "Success.")
			let file_exe = file_exe_list[0]
		else
			call s:Debug_Print(g:DBG_Status, "Not found.")
			let file_exe = ''
		endif

		if filereadable(file_exe)
			call s:Debug_Print(g:DBG_Status, "Success.")
			let file_path = fnamemodify(file_exe, ':p:h')
		else
			call s:Debug_Print(g:DBG_Critical, "Could not find " . short_file)
			throw "Cannot find file " . short_file
		endif
	endif

	let file_path = substitute(file_path, '\\', '/', 'g')

	return file_path
endfunc


func! UpdateTypesFile(recurse, skiptags)
	let s:vrc = globpath(&rtp, "mktypes.py")

	call s:Debug_Print(g:DBG_Status, "Starting UpdateTypesFile revision " . s:CTagsHighlighterVersion)

	if type(s:vrc) == type("")
		let mktypes_py_file = s:vrc
	elseif type(s:vrc) == type([])
		let mktypes_py_file = s:vrc[0]
	endif

	let sysroot = 'python ' . shellescape(mktypes_py_file)
	let syscmd = ' --ctags-dir='

	let ctags_path = s:FindExePath('ctags')

	let syscmd .= ctags_path
	
	if exists('b:TypesFileRecurse')
		if b:TypesFileRecurse == 1
			let syscmd .= ' -r'
		endif
	else
		if a:recurse == 1
			let syscmd .= ' -r'
		endif
	endif

	if exists('b:TypesFileLanguages')
		for lang in b:TypesFileLanguages
			let syscmd .= ' --include-language=' . lang
		endfor
	endif

	if exists('b:TypesFileIncludeSynMatches')
		if b:TypesFileIncludeSynMatches == 1
			let syscmd .= ' --include-invalid-keywords-as-matches'
		endif
	endif

	if exists('b:TypesFileIncludeLocals')
		if b:TypesFileIncludeLocals == 1
			let syscmd .= ' --include-locals'
		endif
	endif

	if exists('b:TypesFileDoNotGenerateTags')
		if b:TypesFileDoNotGenerateTags == 1
			let syscmd .= ' --use-existing-tagfile'
		endif
	elseif a:skiptags == 1
		let syscmd .= ' --use-existing-tagfile'
	endif

	if exists('b:CheckForCScopeFiles')
		if b:CheckForCScopeFiles == 1
			let syscmd .= ' --build-cscopedb-if-cscope-file-exists'
			let syscmd .= ' --cscope-dir=' 
			let cscope_path = s:FindExePath('extra_source/cscope_win/cscope')
			let syscmd .= cscope_path
		endif
	endif

	let sysoutput = system(sysroot . syscmd) 
	echo sysroot . syscmd
	if sysoutput =~ 'python.*is not recognized as an internal or external command'
		let sysroot = g:VIMFILESDIR . '/extra_source/mktypes/dist/mktypes.exe'
		let sysoutput = sysoutput . "\nUsing compiled mktypes\n" . system(sysroot . syscmd)
	endif

	echo sysoutput

	if g:CTagsHighlighterDebug >= g:DBG_None
		echomsg sysoutput
		messages
	endif



	" There should be a try catch endtry
	" above, with the fall-back using the
	" exe on windows or the full system('python') etc
	" on Linux

endfunc

let tagnames = 
			\ [
			\ 		'CTagsAnchor',
			\ 		'CTagsAutoCommand',
			\ 		'CTagsBlockData',
			\ 		'CTagsClass',
			\ 		'CTagsCommand',
			\ 		'CTagsCommonBlocks',
			\ 		'CTagsComponent',
			\ 		'CTagsConstant',
			\ 		'CTagsCursor',
			\ 		'CTagsData',
			\ 		'CTagsDefinedName',
			\ 		'CTagsDomain',
			\ 		'CTagsEntity',
			\ 		'CTagsEntryPoint',
			\ 		'CTagsEnumeration',
			\ 		'CTagsEnumerationName',
			\ 		'CTagsEnumerationValue',
			\ 		'CTagsEnumerator',
			\ 		'CTagsEnumeratorName',
			\ 		'CTagsEvent',
			\ 		'CTagsException',
			\ 		'CTagsExtern',
			\ 		'CTagsFeature',
			\ 		'CTagsField',
			\ 		'CTagsFileDescription',
			\ 		'CTagsFormat',
			\ 		'CTagsFragment',
			\ 		'CTagsFunction',
			\ 		'CTagsFunctionObject',
			\ 		'CTagsGlobalConstant',
			\ 		'CTagsGlobalVariable',
			\ 		'CTagsGroupItem',
			\ 		'CTagsIndex',
			\ 		'CTagsInterface',
			\ 		'CTagsInterfaceComponent',
			\ 		'CTagsLabel',
			\ 		'CTagsLocalVariable',
			\ 		'CTagsMacro',
			\ 		'CTagsMap',
			\ 		'CTagsMember',
			\ 		'CTagsMethod',
			\ 		'CTagsModule',
			\ 		'CTagsNamelist',
			\ 		'CTagsNamespace',
			\ 		'CTagsNetType',
			\ 		'CTagsPackage',
			\ 		'CTagsParagraph',
			\ 		'CTagsPattern',
			\ 		'CTagsPort',
			\ 		'CTagsProgram',
			\ 		'CTagsProperty',
			\ 		'CTagsPrototype',
			\ 		'CTagsPublication',
			\ 		'CTagsRecord',
			\ 		'CTagsRegisterType',
			\ 		'CTagsSection',
			\ 		'CTagsService',
			\ 		'CTagsSet',
			\ 		'CTagsSignature',
			\ 		'CTagsSingleton',
			\ 		'CTagsSlot',
			\ 		'CTagsStructure',
			\ 		'CTagsSubroutine',
			\ 		'CTagsSynonym',
			\ 		'CTagsTable',
			\ 		'CTagsTask',
			\ 		'CTagsTrigger',
			\ 		'CTagsType',
			\ 		'CTagsTypeComponent',
			\ 		'CTagsUnion',
			\ 		'CTagsVariable',
			\ 		'CTagsView',
			\ 		'CTagsVirtualPattern',
			\ ]

for tagname in tagnames
	let simplename = substitute(tagname, '^CTags', '', '')
	exe 'hi default link' tagname simplename
	exe 'hi default link' simplename 'Keyword'
endfor
mktypes.py	[[[1
849
#!/usr/bin/env python
#  Author:  A. S. Budden
## Date::   29th March 2010      ##
## RevTag:: r398                 ##

import os
import sys
import optparse
import re
import fnmatch
import glob
import subprocess

revision = "## RevTag:: r398 ##".strip('# ').replace('RevTag::', 'revision')

field_processor = re.compile(
r'''
	^                 # Start of the line
	(?P<keyword>.*?)  # Capture the first field: everything up to the first tab
	\t                # Field separator: a tab character
	.*?               # Second field (uncaptured): everything up to the next tab
	\t                # Field separator: a tab character
	(?P<search>.*?)   # Any character at all, but as few as necessary (i.e. catch everything up to the ;")
	;"                # The end of the search specifier (see http://ctags.sourceforge.net/FORMAT)
	(?=\t)            # There MUST be a tab character after the ;", but we want to match it with zero width
	.*\t              # There can be other fields before "kind", so catch them here.
	                  # Also catch the tab character from the previous line as there MUST be a tab before the field
	(kind:)?          # This is the "kind" field; "kind:" is optional
	(?P<kind>\w)      # The kind is a single character: catch it
	(\t|$)            # It must be followed either by a tab or by the end of the line
	.*                # If it is followed by a tab, soak up the rest of the line; replace with the syntax keyword line
''', re.VERBOSE)

field_keyword = re.compile(r'syntax keyword (?P<kind>CTags\w+) (?P<keyword>.*)')
field_const = re.compile(r'\bconst\b')

vim_synkeyword_arguments = [
		'contains',
		'oneline',
		'fold',
		'display',
		'extend',
		'contained',
		'containedin',
		'nextgroup',
		'transparent',
		'skipwhite',
		'skipnl',
		'skipempty'
		]

ctags_exe = 'ctags'
cscope_exe = 'cscope'

# Used for timing a function; from http://www.daniweb.com/code/snippet368.html
import time
def print_timing(func):
	def wrapper(*arg):
		t1 = time.time()
		res = func(*arg)
		t2 = time.time()
		print '%s took %0.3f ms' % (func.func_name, (t2-t1)*1000.0)
		return res
	return wrapper

def GetCommandArgs(options):
	Configuration = {}
	Configuration['CTAGS_OPTIONS'] = ''

	if options.recurse:
		Configuration['CTAGS_OPTIONS'] = '--recurse'
		if options.include_locals:
			Configuration['CTAGS_OPTIONS'] += ' --c-kinds=+l'
		Configuration['CTAGS_FILES'] = ['.']
	else:
		if options.include_locals:
			Configuration['CTAGS_OPTIONS'] = '--c-kinds=+l'
		Configuration['CTAGS_FILES'] = glob.glob('*')
	if not options.include_docs:
		Configuration['CTAGS_OPTIONS'] += r" --exclude=docs --exclude=Documentation"
	return Configuration

key_regexp = re.compile('^(?P<keyword>.*?)\t(?P<remainder>.*\t(?P<kind>[a-zA-Z])(?:\t|$).*)')

def ctags_key(ctags_line):
	match = key_regexp.match(ctags_line)
	if match is None:
		return ctags_line
	return match.group('keyword') + match.group('kind') + match.group('remainder')

def CreateCScopeFile(options):
	cscope_options = '-b'
	run_cscope = False

	if options.build_cscopedb:
		run_cscope = True
	
	if os.path.exists('cscope.files'):
		if options.build_cscopedb_if_file_exists:
			run_cscope = True
	else:
		cscope_options += 'R'

	if run_cscope:
		print "Spawning cscope"
		os.spawnl(os.P_NOWAIT, cscope_exe, 'cscope', cscope_options)

#@print_timing
def CreateTagsFile(config, languages, options):
	print "Generating Tags"
	
	ctags_languages = languages[:]
	if 'c' in ctags_languages:
		ctags_languages.append('c++')

	ctags_cmd = '%s %s %s %s' % (ctags_exe, config['CTAGS_OPTIONS'], "--languages=" + ",".join(ctags_languages), " ".join(config['CTAGS_FILES']))

#	fh = open('ctags_cmd.txt', 'w')
#	fh.write(ctags_cmd)
#	fh.write('\n')
#	fh.close()

	#os.system(ctags_cmd)
	subprocess.call(ctags_cmd, shell = (os.name != 'nt'))

	tagFile = open('tags', 'r')
	tagLines = [line.strip() for line in tagFile]
	tagFile.close()

	# Also sort the file a bit better (tag, then kind, then filename)
	tagLines.sort(key=ctags_key)

	tagFile = open('tags', 'w')
	for line in tagLines:
		tagFile.write(line + "\n")
	tagFile.close()

def GetLanguageParameters(lang):
	params = {}
	# Default value for iskeyword
	params['iskeyword'] = '@,48-57,_,192-255'
	if lang == 'c':
		params['suffix'] = 'c'
		params['name'] = 'c'
		params['extensions'] = r'[ch]\w*'
	elif lang == 'python':
		params['suffix'] = 'py'
		params['name'] = 'python'
		params['extensions'] = r'pyw?'
	elif lang == 'ruby':
		params['suffix'] = 'ruby'
		params['name'] = 'ruby'
		params['extensions'] = 'rb'
	elif lang == 'java':
		params['suffix'] = 'java'
		params['name'] = 'java'
		params['extensions'] = 'java'
	elif lang == 'perl':
		params['suffix'] = 'pl'
		params['name'] = 'perl'
		params['extensions'] = r'p[lm]'
	elif lang == 'vhdl':
		params['suffix'] = 'vhdl'
		params['name'] = 'vhdl'
		params['extensions'] = r'vhdl?'
	elif lang == 'php':
		params['suffix'] = 'php'
		params['name'] = 'php'
		params['extensions'] = r'php'
	elif lang == 'c#':
		params['suffix'] = 'cs'
		params['name'] = 'c#'
		params['extensions'] = 'cs'
	else:
		raise AttributeError('Language not recognised %s' % lang)
	return params

def GenerateValidKeywordRange(iskeyword):
	ValidKeywordSets = iskeyword.split(',')
	rangeMatcher = re.compile('^(?P<from>(?:\d+|\S))-(?P<to>(?:\d+|\S))$')
	falseRangeMatcher = re.compile('^^(?P<from>(?:\d+|\S))-(?P<to>(?:\d+|\S))$')
	validList = []
	for valid in ValidKeywordSets:
		m = rangeMatcher.match(valid)
		fm = falseRangeMatcher.match(valid)
		if valid == '@':
			for ch in [chr(i) for i in range(0,256)]:
				if ch.isalpha():
					validList.append(ch)
		elif m is not None:
			# We have a range of ascii values
			if m.group('from').isdigit():
				rangeFrom = int(m.group('from'))
			else:
				rangeFrom = ord(m.group('from'))

			if m.group('to').isdigit():
				rangeTo = int(m.group('to'))
			else:
				rangeTo = ord(m.group('to'))

			validRange = range(rangeFrom, rangeTo+1)
			for ch in [chr(i) for i in validRange]:
				validList.append(ch)

		elif fm is not None:
			# We have a range of ascii values: remove them!
			if fm.group('from').isdigit():
				rangeFrom = int(fm.group('from'))
			else:
				rangeFrom = ord(fm.group('from'))

			if fm.group('to').isdigit():
				rangeTo = int(fm.group('to'))
			else:
				rangeTo = ord(fm.group('to'))

			validRange = range(rangeFrom, rangeTo+1)
			for ch in [chr(i) for i in validRange]:
				for i in range(validList.count(ch)):
					validList.remove(ch)

		elif len(valid) == 1:
			# Just a char
			validList.append(valid)

		else:
			raise ValueError('Unrecognised iskeyword part: ' + valid)

	return validList


def IsValidKeyword(keyword, iskeyword):
	for char in keyword:
		if not char in iskeyword:
			return False
	return True
	
#@print_timing
def CreateTypesFile(config, Parameters, options):
	outfile = 'types_%s.vim' % Parameters['suffix']
	print "Generating " + outfile
	lineMatcher = re.compile(r'^.*?\t[^\t]*\.(?P<extension>' + Parameters['extensions'] + ')\t')

	#p = os.popen(ctags_cmd, "r")
	p = open('tags', "r")

	if options.include_locals:
		LocalTagType = ',ctags_l'
	else:
		LocalTagType = ''

	KindList = GetKindList()[Parameters['name']]
	ctags_entries = []
	while 1:
		line = p.readline()
		if not line:
			break

		if not lineMatcher.match(line):
			continue

		m = field_processor.match(line.strip())
		if m is not None:
			vimmed_line = 'syntax keyword ' + KindList['ctags_' + m.group('kind')] + ' ' + m.group('keyword')

			if options.parse_constants and (Parameters['suffix'] == 'c') and (m.group('kind') == 'v'):
				if field_const.search(m.group('search')) is not None:
					vimmed_line = vimmed_line.replace('CTagsGlobalVariable', 'CTagsConstant')

			if Parameters['suffix'] != 'c' or m.group('kind') != 'p':
				ctags_entries.append(vimmed_line)
	
	p.close()
	
	# Essentially a uniq() function
	ctags_entries = dict.fromkeys(ctags_entries).keys()
	# Sort the list
	ctags_entries.sort()

	if len(ctags_entries) == 0:
		print "No tags found"
		return
	
	keywordDict = {}
	for line in ctags_entries:
		m = field_keyword.match(line)
		if m is not None:
			if not keywordDict.has_key(m.group('kind')):
				keywordDict[m.group('kind')] = []
			keywordDict[m.group('kind')].append(m.group('keyword'))

	if options.check_keywords:
		iskeyword = GenerateValidKeywordRange(Parameters['iskeyword'])
	
	matchEntries = []
	vimtypes_entries = []

	clear_string = 'silent! syn clear '

	patternCharacters = "/@#':"
	charactersToEscape = '\\' + '~[]*.$^'

	if not options.include_locals:
		remove_list = []
		for key, value in KindList.iteritems():
			if value == 'CTagsLocalVariable':
				remove_list.append(key)
		for key in remove_list:
			try:
				del(KindList[key])
			except KeyError:
				pass

	UsedTypes = KindList.values()

	clear_string += " ".join(UsedTypes)

	vimtypes_entries.append(clear_string)


	# Specified highest priority first
	Priority = [
			'CTagsClass', 'CTagsDefinedName', 'CTagsType',
			'CTagsFunction', 'CTagsEnumerationValue',
			'CTagsEnumeratorName', 'CTagsConstant', 'CTagsGlobalVariable',
			'CTagsUnion', 'CTagsMember', 'CTagsStructure',
			]

	# Reverse the list as highest priority should be last!
	Priority.reverse()

	typeList = sorted(keywordDict.keys())

	# Reorder type list according to sort order
	allTypes = []
	for thisType in Priority:
		if thisType in typeList:
			allTypes.append(thisType)
			typeList.remove(thisType)
	for thisType in typeList:
		allTypes.append(thisType)
	#print allTypes

	for thisType in allTypes:
		if thisType not in UsedTypes:
			continue

		keystarter = 'syntax keyword ' + thisType
		keycommand = keystarter
		for keyword in keywordDict[thisType]:
			if options.check_keywords:
				# In here we should check that the keyword only matches
				# vim's \k parameter (which will be different for different
				# languages).  This is quite slow so is turned off by
				# default; however, it is useful for some things where the
				# default generated file contains a lot of rubbish.  It may
				# be worth optimising IsValidKeyword at some point.
				if not IsValidKeyword(keyword, iskeyword):
					matchDone = False

					for patChar in patternCharacters:
						if keyword.find(patChar) == -1:
							escapedKeyword = keyword
							for ch in charactersToEscape:
								escapedKeyword = escapedKeyword.replace(ch, '\\' + ch)
							if not options.skip_matches:
								matchEntries.append('syntax match ' + thisType + ' ' + patChar + escapedKeyword + patChar)
							matchDone = True
							break

					if not matchDone:
						print "Skipping keyword '" + keyword + "'"

					continue


			if keyword.lower() in vim_synkeyword_arguments:
				matchEntries.append('syntax match ' + thisType + ' /' + keyword + '/')
				continue

			temp = keycommand + " " + keyword
			if len(temp) >= 512:
				vimtypes_entries.append(keycommand)
				keycommand = keystarter
			keycommand = keycommand + " " + keyword
		if keycommand != keystarter:
			vimtypes_entries.append(keycommand)
	
	# Essentially a uniq() function
	matchEntries = dict.fromkeys(matchEntries).keys()
	# Sort the list
	matchEntries.sort()

	vimtypes_entries.append('')
	for thisMatch in matchEntries:
		vimtypes_entries.append(thisMatch)

	LanguageKinds = GetKindList()
	AddList = 'add='

	for thisType in allTypes:
		if thisType in UsedTypes:
			if AddList != 'add=':
				AddList += ','
			AddList += thisType;
	AddList += ' '

	if Parameters['suffix'] in ['c',]:
		vimtypes_entries.append('')
		vimtypes_entries.append("if exists('b:hlrainbow') && !exists('g:nohlrainbow')")
		vimtypes_entries.append('\tsyn cluster cBracketGroup ' + AddList + LocalTagType)
		vimtypes_entries.append('\tsyn cluster cCppBracketGroup ' + AddList + LocalTagType)
		vimtypes_entries.append('\tsyn cluster cCurlyGroup ' + AddList + LocalTagType)
		vimtypes_entries.append('\tsyn cluster cParenGroup ' + AddList + LocalTagType)
		vimtypes_entries.append('\tsyn cluster cCppParenGroup ' + AddList + LocalTagType)
		vimtypes_entries.append('endif')

	try:
		fh = open(outfile, 'wb')
	except IOError:
		sys.stderr.write("ERROR: Couldn't create %s\n" % (outfile))
		sys.exit(1)
	
	try:
		for line in vimtypes_entries:
			fh.write(line)
			fh.write('\n')
	except IOError:
		sys.stderr.write("ERROR: Couldn't write %s contents\n" % (outfile))
		sys.exit(1)
	finally:
		fh.close()

def main():
	import optparse
	parser = optparse.OptionParser(version=("Types File Creator (%%prog) %s" % revision))
	parser.add_option('-r','-R','--recurse',
			action="store_true",
			default=False,
			dest="recurse",
			help="Recurse into subdirectories")
	parser.add_option('--ctags-dir',
			action='store',
			default=None,
			dest='ctags_dir',
			type='string',
			help='CTAGS Executable Directory')
	parser.add_option('--include-docs',
			action='store_true',
			default=False,
			dest='include_docs',
			help='Include docs or Documentation directory (stripped by default for speed)')
	parser.add_option('--do-not-check-keywords',
			action='store_false',
			default=True,
			dest='check_keywords',
			help="Do not check validity of keywords (for speed)")
	parser.add_option('--include-invalid-keywords-as-matches',
			action='store_false',
			default=True,
			dest='skip_matches',
			help='Include invalid keywords as regular expression matches (may slow it loading)')
	parser.add_option('--do-not-analyse-constants',
			action='store_false',
			default=True,
			dest='parse_constants',
			help="Do not treat constants as separate entries")
	parser.add_option('--include-language',
			action='append',
			dest='languages',
			type='string',
			default=[],
			help='Only include specified languages')
	parser.add_option('--build-cscopedb',
			action='store_true',
			default=False,
			dest='build_cscopedb',
			help="Also build a cscope database")
	parser.add_option('--build-cscopedb-if-cscope-file-exists',
			action='store_true',
			default=False,
			dest='build_cscopedb_if_file_exists',
			help="Also build a cscope database if cscope.files exists")
	parser.add_option('--cscope-dir',
			action='store',
			default=None,
			dest='cscope_dir',
			type='string',
			help='CSCOPE Executable Directory')
	parser.add_option('--include-locals',
			action='store_true',
			default=False,
			dest='include_locals',
			help='Include local variables in the database')
	parser.add_option('--use-existing-tagfile',
			action='store_true',
			default=False,
			dest='use_existing_tagfile',
			help="Do not generate tags if a tag file already exists")

	options, remainder = parser.parse_args()

	if options.ctags_dir is not None:
		global ctags_exe
		ctags_exe = os.path.join(options.ctags_dir, 'ctags')


	if options.cscope_dir is not None:
		global cscope_exe
		cscope_exe = options.cscope_dir + '/' + 'cscope'

	Configuration = GetCommandArgs(options)

	CreateCScopeFile(options)

	full_language_list = ['c', 'java', 'perl', 'python', 'ruby', 'vhdl', 'php', 'c#']
	if len(options.languages) == 0:
		# Include all languages
		language_list = full_language_list
	else:
		language_list = [i for i in full_language_list if i in options.languages]

	if options.use_existing_tagfile and not os.path.exists('tags'):
		options.use_existing_tagfile = False

	if not options.use_existing_tagfile:
		CreateTagsFile(Configuration, language_list, options)

	for language in language_list:
		Parameters = GetLanguageParameters(language)
		CreateTypesFile(Configuration, Parameters, options)

def GetKindList():
	LanguageKinds = {}
	LanguageKinds['asm'] = \
	{
		'ctags_d': 'CTagsDefinedName',
		'ctags_l': 'CTagsLabel',
		'ctags_m': 'CTagsMacro',
		'ctags_t': 'CTagsType',
	}
	LanguageKinds['asp'] = \
	{
		'ctags_c': 'CTagsConstant',
		'ctags_f': 'CTagsFunction',
		'ctags_s': 'CTagsSubroutine',
		'ctags_v': 'CTagsVariable',
	}
	LanguageKinds['awk'] = \
	{
		'ctags_f': 'CTagsFunction',
	}
	LanguageKinds['basic'] = \
	{
		'ctags_c': 'CTagsConstant',
		'ctags_f': 'CTagsFunction',
		'ctags_l': 'CTagsLabel',
		'ctags_t': 'CTagsType',
		'ctags_v': 'CTagsVariable',
		'ctags_g': 'CTagsEnumeration',
	}
	LanguageKinds['beta'] = \
	{
		'ctags_f': 'CTagsFragment',
		'ctags_p': 'CTagsPattern',
		'ctags_s': 'CTagsSlot',
		'ctags_v': 'CTagsVirtualPattern',
	}
	LanguageKinds['c'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_d': 'CTagsDefinedName',
		'ctags_e': 'CTagsEnumerationValue',
		'ctags_f': 'CTagsFunction',
		'ctags_g': 'CTagsEnumeratorName',
		'ctags_k': 'CTagsConstant',
		'ctags_l': 'CTagsLocalVariable',
		'ctags_m': 'CTagsMember',
		'ctags_n': 'CTagsNamespace',
		'ctags_p': 'CTagsFunction',
		'ctags_s': 'CTagsStructure',
		'ctags_t': 'CTagsType',
		'ctags_u': 'CTagsUnion',
		'ctags_v': 'CTagsGlobalVariable',
		'ctags_x': 'CTagsExtern',
	}
	LanguageKinds['c++'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_d': 'CTagsDefinedName',
		'ctags_e': 'CTagsEnumerationValue',
		'ctags_f': 'CTagsFunction',
		'ctags_g': 'CTagsEnumerationName',
		'ctags_k': 'CTagsConstant',
		'ctags_l': 'CTagsLocalVariable',
		'ctags_m': 'CTagsMember',
		'ctags_n': 'CTagsNamespace',
		'ctags_p': 'CTagsFunction',
		'ctags_s': 'CTagsStructure',
		'ctags_t': 'CTagsType',
		'ctags_u': 'CTagsUnion',
		'ctags_v': 'CTagsGlobalVariable',
		'ctags_x': 'CTagsExtern',
	}
	LanguageKinds['c#'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_d': 'CTagsDefinedName',
		'ctags_e': 'CTagsEnumerationValue',
		'ctags_E': 'CTagsEvent',
		'ctags_f': 'CTagsField',
		'ctags_g': 'CTagsEnumerationName',
		'ctags_i': 'CTagsInterface',
		'ctags_l': 'CTagsLocalVariable',
		'ctags_m': 'CTagsMethod',
		'ctags_n': 'CTagsNamespace',
		'ctags_p': 'CTagsProperty',
		'ctags_s': 'CTagsStructure',
		'ctags_t': 'CTagsType',
	}
	LanguageKinds['cobol'] = \
	{
		'ctags_d': 'CTagsData',
		'ctags_f': 'CTagsFileDescription',
		'ctags_g': 'CTagsGroupItem',
		'ctags_p': 'CTagsParagraph',
		'ctags_P': 'CTagsProgram',
		'ctags_s': 'CTagsSection',
	}
	LanguageKinds['eiffel'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_f': 'CTagsFeature',
		'ctags_l': 'CTagsEntity',
	}
	LanguageKinds['erlang'] = \
	{
		'ctags_d': 'CTagsDefinedName',
		'ctags_f': 'CTagsFunction',
		'ctags_m': 'CTagsModule',
		'ctags_r': 'CTagsRecord',
	}
	LanguageKinds['fortran'] = \
	{
		'ctags_b': 'CTagsBlockData',
		'ctags_c': 'CTagsCommonBlocks',
		'ctags_e': 'CTagsEntryPoint',
		'ctags_f': 'CTagsFunction',
		'ctags_i': 'CTagsInterfaceComponent',
		'ctags_k': 'CTagsTypeComponent',
		'ctags_l': 'CTagsLabel',
		'ctags_L': 'CTagsLocalVariable',
		'ctags_m': 'CTagsModule',
		'ctags_n': 'CTagsNamelist',
		'ctags_p': 'CTagsProgram',
		'ctags_s': 'CTagsSubroutine',
		'ctags_t': 'CTagsType',
		'ctags_v': 'CTagsGlobalVariable',
	}
	LanguageKinds['html'] = \
	{
		'ctags_a': 'CTagsAnchor',
		'ctags_f': 'CTagsFunction',
	}
	LanguageKinds['java'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_e': 'CTagsEnumerationValue',
		'ctags_f': 'CTagsField',
		'ctags_g': 'CTagsEnumeratorName',
		'ctags_i': 'CTagsInterface',
		'ctags_l': 'CTagsLocalVariable',
		'ctags_m': 'CTagsMethod',
		'ctags_p': 'CTagsPackage',
	}
	LanguageKinds['javascript'] = \
	{
		'ctags_f': 'CTagsFunction',
		'ctags_c': 'CTagsClass',
		'ctags_m': 'CTagsMethod',
		'ctags_p': 'CTagsProperty',
		'ctags_v': 'CTagsGlobalVariable',
	}
	LanguageKinds['lisp'] = \
	{
		'ctags_f': 'CTagsFunction',
	}
	LanguageKinds['lua'] = \
	{
		'ctags_f': 'CTagsFunction',
	}
	LanguageKinds['make'] = \
	{
		'ctags_m': 'CTagsFunction',
	}
	LanguageKinds['pascal'] = \
	{
		'ctags_f': 'CTagsFunction',
		'ctags_p': 'CTagsFunction',
	}
	LanguageKinds['perl'] = \
	{
		'ctags_c': 'CTagsGlobalConstant',
		'ctags_f': 'CTagsFormat',
		'ctags_l': 'CTagsLabel',
		'ctags_p': 'CTagsPackage',
		'ctags_s': 'CTagsFunction',
		'ctags_d': 'CTagsFunction',
	}
	LanguageKinds['php'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_i': 'CTagsInterface',
		'ctags_d': 'CTagsGlobalConstant',
		'ctags_f': 'CTagsFunction',
		'ctags_v': 'CTagsGlobalVariable',
		'ctags_j': 'CTagsFunction',
	}
	LanguageKinds['python'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_f': 'CTagsFunction',
		'ctags_i': 'CTagsImport',
		'ctags_m': 'CTagsMember',
		'ctags_v': 'CTagsGlobalVariable',
	}
	LanguageKinds['rexx'] = \
	{
		'ctags_s': 'CTagsFunction',
	}
	LanguageKinds['ruby'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_f': 'CTagsMethod',
		'ctags_m': 'CTagsModule',
		'ctags_F': 'CTagsSingleton',
	}
	LanguageKinds['scheme'] = \
	{
		'ctags_f': 'CTagsFunction',
		'ctags_s': 'CTagsSet',
	}
	LanguageKinds['sh'] = \
	{
		'ctags_f': 'CTagsFunction',
	}
	LanguageKinds['slang'] = \
	{
		'ctags_f': 'CTagsFunction',
		'ctags_n': 'CTagsNamespace',
	}
	LanguageKinds['sml'] = \
	{
		'ctags_e': 'CTagsException',
		'ctags_f': 'CTagsFunction',
		'ctags_c': 'CTagsFunctionObject',
		'ctags_s': 'CTagsSignature',
		'ctags_r': 'CTagsStructure',
		'ctags_t': 'CTagsType',
		'ctags_v': 'CTagsGlobalVariable',
	}
	LanguageKinds['sql'] = \
	{
		'ctags_c': 'CTagsCursor',
		'ctags_d': 'CTagsFunction',
		'ctags_f': 'CTagsFunction',
		'ctags_F': 'CTagsField',
		'ctags_l': 'CTagsLocalVariable',
		'ctags_L': 'CTagsLabel',
		'ctags_P': 'CTagsPackage',
		'ctags_p': 'CTagsFunction',
		'ctags_r': 'CTagsRecord',
		'ctags_s': 'CTagsType',
		'ctags_t': 'CTagsTable',
		'ctags_T': 'CTagsTrigger',
		'ctags_v': 'CTagsGlobalVariable',
		'ctags_i': 'CTagsIndex',
		'ctags_e': 'CTagsEvent',
		'ctags_U': 'CTagsPublication',
		'ctags_R': 'CTagsService',
		'ctags_D': 'CTagsDomain',
		'ctags_V': 'CTagsView',
		'ctags_n': 'CTagsSynonym',
	}
	LanguageKinds['tcl'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_m': 'CTagsMethod',
		'ctags_p': 'CTagsFunction',
	}
	LanguageKinds['vera'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_d': 'CTagsDefinedName',
		'ctags_e': 'CTagsEnumerationValue',
		'ctags_f': 'CTagsFunction',
		'ctags_g': 'CTagsEnumeratorName',
		'ctags_l': 'CTagsLocalVariable',
		'ctags_m': 'CTagsMember',
		'ctags_p': 'CTagsProgram',
		'ctags_P': 'CTagsFunction',
		'ctags_t': 'CTagsTask',
		'ctags_T': 'CTagsType',
		'ctags_v': 'CTagsGlobalVariable',
		'ctags_x': 'CTagsExtern',
	}
	LanguageKinds['verilog'] = \
	{
		'ctags_c': 'CTagsGlobalConstant',
		'ctags_e': 'CTagsEvent',
		'ctags_f': 'CTagsFunction',
		'ctags_m': 'CTagsModule',
		'ctags_n': 'CTagsNetType',
		'ctags_p': 'CTagsPort',
		'ctags_r': 'CTagsRegisterType',
		'ctags_t': 'CTagsTask',
	}
	LanguageKinds['vhdl'] = \
	{
		'ctags_c': 'CTagsGlobalConstant',
		'ctags_t': 'CTagsType',
		'ctags_T': 'CTagsTypeComponent',
		'ctags_r': 'CTagsRecord',
		'ctags_e': 'CTagsEntity',
		'ctags_C': 'CTagsComponent',
		'ctags_d': 'CTagsPrototype',
		'ctags_f': 'CTagsFunction',
		'ctags_p': 'CTagsFunction',
		'ctags_P': 'CTagsPackage',
		'ctags_l': 'CTagsLocalVariable',
	}
	LanguageKinds['vim'] = \
	{
		'ctags_a': 'CTagsAutoCommand',
		'ctags_c': 'CTagsCommand',
		'ctags_f': 'CTagsFunction',
		'ctags_m': 'CTagsMap',
		'ctags_v': 'CTagsGlobalVariable',
	}
	LanguageKinds['yacc'] = \
	{
		'ctags_l': 'CTagsLabel',
	}
	return LanguageKinds

	
if __name__ == "__main__":
	main()
extra_source/mktypes/setup.py	[[[1
5
from distutils.core import setup
import py2exe

# for console program use 'console = [{"script" : "scriptname.py"}]
setup(console=[{"script" : "../../mktypes.py"}])
doc/ctags_highlighting.txt	[[[1
415
*ctags_highlighting.txt*       Tag Highlighting

Author:	    A. S. Budden <abuddenNOSPAM@NOSPAMgmail.com>
	    Remove NOSPAM.

## RevTag:: r398                                                           ##

Copyright:  (c) 2009 by A. S. Budden            *ctags_highlighting-copyright*
	    The VIM LICENCE applies to ctags_highlighting.vim, mktypes.py and
	    ctags_highlighting.txt (see |copyright|) except use
	    "ctags_highlighting" instead of "Vim".
	    NO WARRANTY, EXPRESS OR IMPLIED. USE AT-YOUR-OWN-RISK.

==============================================================================
1. Contents	    *ctags_highlighting* *ctags_highlighting-contents*    {{{1

    1.    Contents	                     |ctags_highlighting-contents|
    
    2.    CTAGS Highlighting Manual	     |ctags_highlighting-manual|
    2.1   Introduction                       |ctags_highlighting-intro|
    2.2   Commands                           |ctags_highlighting-commands|
    2.3   Colouring                          |ctags_highlighting-colours|
    2.4   Configuration                      |ctags_highlighting-config|
    2.5   Installation                       |ctags_highlighting-install|
    
    3.    CTAGS Highlighting Customisation   |ctags_highlighting-custom|
    3.1   Adding More Languages              |ctags_highlighting-adding|
    3.1.1 Example                            |ctags_highlighting-add-example|
    
    4.    Feature Wishlist                   |ctags_highlighting-wishlist|
    
    5.    CTAGS Highlighting History         |ctags_highlighting-history|

==============================================================================
2. CTAGS Highlighting Manual		 *ctags_highlighting-manual*      {{{1

2.1 Introduction                         *ctags_highlighting-intro*       {{{2

    This set of scripts is designed to increase the number of highlighting
    groups used by Vim.  This makes it quicker and easier to spot errors in
    your code.  By using ctags and parsing the output, the typedefs, #defines,
    enumerated names etc are all clearly highlighted in different colours.
    
    The idea was based on the comments in |tag-highlight|, but I wanted to
    take it a little further.
    
    This is achieved through a little python script to interact with ctags and
    to parse the result and a small Vim script that makes Vim read the
    resulting files.  Finally, a new command (:UpdateTypesFile) is added (with
    optional !  for recursive operation) to keep the generated files up to
    date.
    
    At present, the highlighter supports the following languages:
    
        * C/C++
        * Java
        * Perl
        * PHP
        * Python
        * Ruby (largely untested)
        * VHDL (if your version of ctags supports it)
    
    It should also work correctly with Charles Campbell's rainbow.vim bracket
    highlighter.
    
    The vast majority of the testing has been with C source code, so I'd be
    very interested in any feedback on the use with C++ and the various other
    languages.
    
    Adding more languages is extremely simple, see
    |ctags_highlighting-adding|.
    
                                         *ctags_highlighting-website*
    
    Screenshots of the highlighter in operation are available at the website:
>
    http://sites.google.com/site/abudden/contents/Vim-Scripts/ctags-highlighting
<

2.2 Commands                             *ctags_highlighting-commands*    {{{2

    The following commands are provided by this plugin:

	:UpdateTypesFile                 *UpdateTypesFile*

	    This command creates the syntax highlighting file used to show the
	    extra colouring.  It then updates all of the open files
	    automatically.  By default, it only looks for source files in the
	    current directory.  However, see |UpdateTypesFile!| and
	    |b:TypesFileRecurse|.

	:UpdateTypesFile!                *UpdateTypesFile!*
    
	    This command operates in the same way as |UpdateTypesFile| except
	    that it looks for source files recursively into subdirectories.
	    It automatically excludes directories named either "docs" or
	    "Documentation".  See also |b:TypesFileRecurse|.

	:UpdateTypesFileOnly             *UpdateTypesFileOnly*

	    This command operates in the same manner as |UpdateTypesFile|, but
	    it uses the current tags file rather than generating a new one
	    (useful if you're generating tags files as part of your build
	    process.

2.3 Colouring                            *ctags_highlighting-colours*     {{{2

    The ctags highlighter uses a number of additional highlighting groups to
    differentiate between different types of tag.  These are not supported as
    standard by many colour schemes.  You can either download the "bandit"
    colour scheme from:
>
    http://sites.google.com/site/abudden/contents/Vim-Scripts/bandit-colour-scheme
<
    (screenshots of C source code on the |ctags_highlighting-website|) or you
    can configure the extra highlighting groups yourself.  The following
    highlight groups should be defined:

	ClassName       : Class
    	DefinedName     : Define
    	Enumerator      : Enumerator
    	Function        : Function or method
    	EnumerationName : Enumeration name
    	Member          : Member (of structure or class)
    	Structure       : Structure Name
    	Type            : Typedef
    	Union           : Union Name
    	GlobalConstant  : Global Constant
    	GlobalVariable  : Global Variable
    	LocalVariable   : Local Variable

    An example of how to highlight one of these would be to include the
    following line in your colour scheme (see |:highlight|):
>
	hi Enumerator guifg="c000c0"
<
    You can, of course, also link the groups to another highlighting group
    using something like:
>
        hi link Type Keyword
<
    However, this probably defies the point of having the ctags highlighter in
    the first place!

2.4 Configuration                        *ctags_highlighting-config*      {{{2

    There are a number of options that allow customisation of the operation of
    the highlighter.  Currently, they are all implemented as buffer-local
    variables.  This is largely due to the fact that I use the project plugin
    (|project.txt|).  This includes the ability to customise buffer settings
    automatically using the "in=" part of the project configuration (see
    |project-syntax| if you have the plugin installed).  Anyway, I hope to
    change this soon to support global variables as well.
    
        b:TypesFileRecurse               *b:TypesFileRecurse*
    	
	    If this (buffer-local) variable is set to 1, |UpdateTypesFile|
	    recurses into subdirectories even if the ! is not appended.
>
		let b:TypesFileRecurse = 1
<
        b:TypesFileDoNotGenerateTags     *b:TypesFileDoNotGenerateTags*
    
	   If this (buffer-local) variable is set to 1, running
	   |UpdateTypesFile| is equivalent to running |UpdateTypesFileOnly|.
>
		let b:TypesFileDoNotGenerateTags = 1
<
        b:TypesFileIncludeLocals         *b:TypesFileIncludeLocals*
    	
	   If this (buffer-local) variable is set to 1, local variables are
	   included in the syntax highlighting.  Note however that no scope is
	   applied to these variables, so they will be highlighted even if
	   they are used in the wrong function.
>
		let b:TypesFileIncludeLocals = 1
<
        b:TypesFileIncludeSynMatches     *b:TypesFileIncludeSynMatches*
    	
	   If this (buffer-local) variable is set to 1, more obscure matches
	   are included in the syntax highlighter.  The standard highlighter
	   only highlights tags that are made up of keyword characters (see
	   |'iskeyword'|).  If this option is enabled, other tags are
	   highlighted using |:syn-match|.  Note however that this can
	   seriously slow your Vim down if there are a lot of matches
	   (|:syn-match| is much slower than |:syn-keyword|).
    
        b:TypesFileLanguages             *b:TypesFileLanguages*
    
	   This (buffer-local) variable can be used to limit the number of
	   languages searched for by the generation script.  This can speed up
	   tag generation somewhat.  For example, if you are working on C/C++
	   source code, use:
>
		let b:TypesFileLanguages = ['c']
<
	   If you're working on Ruby and Python code, use:
>
		let b:TypesFileLanguages = ['ruby', 'python']
<

2.5 Installation                         *ctags_highlighting-install*     {{{2

    The highlighter is distributed as a |vimball|.  To install, open it in Vim
    and run: >
	    source %
<
    Additional components are available on the |ctags_highlighting-website|.
    These include a Windows binary version of the python component and a set
    of pregenerated types files for wxWidgets, wxPython and Qt 4.  The Windows
    binary should be unzipped into your |vimfiles| directory.  The
    pregenerated types files are distributed as another |vimball|.

==============================================================================
3. CTAGS Highlighting Customisation      *ctags_highlighting-custom*      {{{1

3.1 Adding More Languages                *ctags_highlighting-adding*      {{{2

    1. Run ctags --list-languages and check that the required language is
       present
       
    2. Add an entry to GetLanguageParameters() with the following components:
    
	   - lang:       The "friendly" name used to refer to the language in
	                 the list of languages
    
	   - suffix:     The distinguishing name for the output file name,
	                 e.g.  "py" for "types_py.vim"
    
	   - extensions: A regular expression describing the extensions for
	                 relevant files (e.g. "p[lm]" for *.pl and *.pm)
    
	   - iskeyword:  What Vim thinks is a keyword for this file type: open
			 a source file and enter ":echo &iskeyword" (not
			 required for most languages: there is a sensible
			 default).  See |'iskeyword'| for more information.
    
    3. Add the lang entry to the list of languages at the bottom of mktypes.py

    4. Recompile the py2exe executable (if required).

    5. Add the new language autocmd to ctags_highlighting.vim (the argument to
       ReadTypes is the suffix)
    6. Add the extension to the lookup table in ReadTypesAutoDetect in
       ctags_highlighting.vim

3.1.1 Example                            *ctags_highlighting-add-example* {{{3

    When PHP support was added to the highlighter, the following lines were
    added:
    
    To mktypes.py, in the GetLanguageParameters function, the following lines
    were added: >

	elif lang == 'php':
		params['suffix'] = 'php'
		params['extensions'] = r'php'
<

    In the main() function, the full_language_list was changed from: >

	full_language_list = ['c', 'java', 'perl', 'python', 'ruby', 'vhdl']
<
    To: >

	full_language_list = ['c', 'java', 'perl', 'python', 'ruby', 'vhdl', 'php']
<
    The following line was added to ctags_highlighting.vim: >

	autocmd BufRead,BufNewFile *.php    call ReadTypes('php')
<
    Finally, the ReadTypesAutoDetect function in ctags_highlighting.vim was
    modified so that the extensionLookup dictionary included the following
    entry:
>
				\     'php'          : "php",
<

==============================================================================
4. Feature Wishlist                      *ctags_highlighting-wishlist*    {{{1

    - Highlighting of local variables (could be useful for checking your
      variable is defined in the correct function)?  Not currently possible as
      "ctags --c-kinds=+l" doesn't provide the scope of the local variable, so
      a lot of complicated parsing of the source would be required.
    
    - Option to update the types files whenever :make is run.
    
    - Option to update the types files whenever specific files are written
      (would need to make :UpdateTypesFile! much faster for this to be
      practical).
    
    - Move most of the functionality into an autoload script.
    
    - Abstract the language specific parts so that adding a new language
      doesn't involve too many changes.
    
    - Simplify the options, in particular, allow global variables as well as
      buffer-local variables.
    
    - Tidy up the types files for wxWidgets, Qt and wxPython.

    - Make it work when Vim is installed in a path with spaces.

==============================================================================
5. CTAGS Highlighting History            *ctags_highlighting-history*     {{{1

r398 : 29th March 2010     : Added support for python import in the listing.

r396 : 29th March 2010     : Factored out old ctags_[a-z] types to improve
                             language support.

r394 : 26th March 2010     : Fix for python use.

r391 : 2nd March 2010      : Fix for ctags names.

r390 : 2nd March 2010      : Attempted improvements to code including support
                             for C# (thanks to Aleksey Baibarin).

r387 : 20th February 2010  : Fixed VIMFILESDIR typo.

r384 : 19th February 2010  : Improvements to VIMFILESDIR identification.
                             Re-architecture of type definitions to make
                             them more sensitive to different ctags "kinds"
                             for different languages.  Note that Enumerator
                             has been renamed to EnumerationValue: the latest
                             Bandit Colour Scheme supports this.

r382 : 13th February 2010  : Fixed escaping of paths and operation of
                             ReadTypes when not in an autocommand.

r340 : 2nd November 2009   : Added missing winrestview().

r330 : 16th September 2009 : Minor Documentation update.

r329 : 16th September 2009 : Added revision output to mktypes.

r328 : 16th September 2009 : Fix for bug with path finding on Windows where
                             directories in the path end in a backslash.

r326 : 15th September 2009 : Added revision number to debug output.

r324 : 14th September 2009 : Fixed Linux bugs with new implementation.

r321 : 14th September 2009 : Fixed bug with returning to the correct window
			     after use, added debugging statements and moved
			     executable search to a separate function.  Also
			     added preliminary work towards more explicit
			     type names.

r309 : 17th August 2009    : Added documentation.

r302 : 10th August 2009    : Added experimental PHP support.

r301 : 7th August 2009     : Made GUI tags and types files optional and added
			     shellescape to protect paths (thanks to Mikhail
			     Stepura again). The gui_tags_and_types.vba file
			     contains the tags and highlighting definitions
			     for Qt, wxWidgets and wxPython (used to be
			     included in the main distribution).

r292 : 3rd August 2009     : Fixed bug with cscope option.

r285 : 27th July 2009      : Added support for ctags being stored in a path
			     with spaces and other odd characters (thanks to
			     Mikhail Stepura).

r261 : 23rd May 2009       : Changed some of the defaults to the python script
			     (so fewer options need to be passed by
			     UpdateTypesFile).  It should now be possible to
			     generate the types file simply by running
			     "mktypes.py" or "mktypes.py -r" in the project
			     directory.  Of course, UpdateTypesFile works too.
			     Added UpdateTypesFileOnly command for projects in
			     which the tags file is updated externally (e.g.
			     the Linux kernel source).  Removed regular
			     expression matches by default: this is much
			     quicker for large projects.

r252 : 21st May 2009       : Added (optional) support for highlighting of
			     local variables (not scope-specific: just
			     recognises names).  Tidied up tag generation.

r173 : 17th November 2008  : Added automatic reloading of types file whenever
			     :UpdateTypesFile is run.  Also runs cscope (in
			     the background) if cscope.files is present in the
			     current working directory.

r132 : 17th September 2008 : Updated to support limiting the languages checked
			     for (intended to be used with the project plugin
			     and it's in= option) in order to speed it up a
			     bit. Also added project option for recursion (so
			     you don't have to bother with the exclamation
			     mark) and parsing of local enumerations.
			     Finally, added sorting of tags file such that
			     function implementations come before function
			     declarations, regardless of the alphabetic order
			     of the file names in which they are stored.
			     Finally, added zipfile version in case of
			     problems with vba.

r129 : 9th September 2008  : Updated to only add to the various rainbow.vim
			     related groups if b:hlrainbow is set.

r126 : 5th September 2008  : This has now been updated to run considerably
			     quicker (with only one pass by ctags and
			     excluding directories named "docs" to avoid
			     spending a long time searching through all the
			     files that doxygen creates).  On the project I
			     used to benchmark it, the running time reduced
			     from about two minutes to about seven seconds!

==============================================================================
Modelines: {{{1
 vim:tw=78:ts=8:ft=help:fdm=marker:
