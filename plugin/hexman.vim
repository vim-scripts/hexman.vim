"=============================================================================
"    Copyright: Copyright (C) 2003 Peter Franz
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               hexman.vim is provided *as is* and comes with no
"               warranty of any kind, either expressed or implied. In no
"               event will the copyright holder be liable for any damamges
"               resulting from the use of this software.
" Name Of File: hexman.vim
"  Description: HexManger: Simpler Hex viewing and editing - Vim Plugin
"
"		Hexmanger provides keymapping to view quickly your file
"		in hexmode (convertion is done over the program xxd).
"
"		Additional features:
"		- shows in statusline the current offset (hex and dec.)
"		- move to next/previous hex character with <TAB> and <S-TAB>
"         	  If you don't like this mapping - please set in your vimrc:
"	  	  let hex_movetab = 0
"		- staying on a hex character it marks the related ascii column
"		- Goto hex offset	
"		- Delete hex character under cursor	
"		- Insert ascii character before cursor	                      
"		- Show own hexman menu entry with hexman commands (gui version).
"         	  If you don't like the menu - please set in your vimrc:
"	  	  let hex_menu = 0
"
"   Maintainer: Peter Franz (Peter.Franz.muc@web.de)
"          URL: http://vim.sourceforge.net/scripts/...
"  Last Change: Mi 30.07.2003
"      Version: 0.1.0
"        Usage: Normally, this file should reside in the plugins
"               directory and be automatically sourced. If not, you must
"               manually source this file using ':source hexman.vim'.
"
"               If you want to edit a file in hexmode, start vim 
"               with the -b option - like:
"                     vim -b <file>
"               and then switch to hexmode with <leader>hm
"               (see Available functions).
"               The program xxd is needed to convert the file in hex (and
"               back).
"               Only changes in the hex part are used.  
"               Changes in the printable text part on the right are ignored.
"               
"               Additional help:
"               :help *23.4* 
"               :help xxd                                                    
"
"      History: 0.1.0 Show own hexman menu entry with hexman commands (gui version).
"		0.0.2 FIX: default moving to next hex character 
"		with <TAB> and <S-TAB> don't work on (LINUX/UNIX)
"		(see Additional Features).
"               0.0.1 Initial Release
"               Some Functions are derived from Robert Roberts
"               byteme.vim version 0.0.2
"               The original plugin can be found at:
"               http://www.vim.org/scripts/script.php?script_id=268
"               Thank you very much! 
"
"=============================================================================
"
"	Available functions:
"
"	<leader> hm	HexManager: Call/Leave Hexmode (using xxd)
"	<leader> hd  	HexDelete: delete hex character under cursor
"	<leader> hi  	HexInsert: Insert Ascii character before cursor
"	<leader> hg  	HexGoto: Goto hex offset. 
"	<leader> hn  	HexNext: Goto next hex offset. 
"	<leader> hp  	HexPrev: Goto previous hex offset. 
"	<leader> hs  	HexStatus: Show / Hide hexoffset infos in statusline
"			and related ascii colum	
"
" 	If you want, you can change the mapping in your vimrc:
"	Example (call with function key F6 the Hexmode:
"	map <F6>  <Plug>HexManager                                           
"
"	Additional Features in HexManger:
"	- show in statusline the current offset (hex and dec.)
"	- moving to next hex character with <TAB> and <S-TAB>
"         If you don't like this mapping - please set in your vimrc:
"	  let hex_movetab = 0
"	- staying on a hex character it marks the related ascii column
"	If something is wrong (I think there is) or we can do 
"	something better - please let me know...
"
"=============================================================================
"
" 	Define mapping:
"
if !hasmapto('<Plug>HexManager')
  map <unique> <Leader>hm <Plug>HexManager
endif
if !hasmapto('<Plug>HexDelete')
  map <unique> <Leader>hd <Plug>HexDelete
endif
if !hasmapto('<Plug>HexInsert')
  map <unique> <Leader>hi <Plug>HexInsert
endif
if !hasmapto('<Plug>HexGoto')
  map <unique> <Leader>hg <Plug>HexGoto
endif
if !hasmapto('<Plug>HexNext')
  map <unique> <Leader>hn <Plug>HexNext
endif
if !hasmapto('<Plug>HexPrev')
  map <unique> <Leader>hp <Plug>HexPrev
endif
if !hasmapto('<Plug>HexStatus')
  map <unique> <Leader>hs <Plug>HexStatus
endif

noremap <unique> <script> <Plug>HexManager <SID>Manager
noremap <unique> <script> <Plug>HexDelete  <SID>Delete
noremap <unique> <script> <Plug>HexInsert  <SID>Insert
noremap <unique> <script> <Plug>HexGoto    <SID>Goto
noremap <unique> <script> <Plug>HexNext    <SID>Next
noremap <unique> <script> <Plug>HexPrev    <SID>Prev
noremap <unique> <script> <Plug>HexStatus  <SID>Status

noremap <SID>Manager   :call <SID>HEX_Manager()<CR>
noremap <SID>Delete    :call <SID>HEX_Delete()<CR>
noremap <SID>Insert    :call <SID>HEX_Insert()<CR>
noremap <SID>Goto      :call <SID>HEX_Goto()<CR>
noremap <SID>Next      :call <SID>HEX_NextPrev(+1)<CR>
noremap <SID>Prev      :call <SID>HEX_NextPrev(-1)<CR>
noremap <SID>Status    :call <SID>HEX_Status()<CR>

"=============================================================================
" We first store the old value of 'cpoptions' in the s:save_cpo variable.  At
" the end of the plugin this value is restored.
let s:save_cpo = &cpo
set cpo&vim
" Not loading
if exists("loaded_hexman")
   finish
endif
let loaded_hexman = 1
"
"=============================================================================
" 30JUL03 FR Add menue
"=============================================================================
  if !exists("g:hex_menu")
    let g:hex_menu = 1	" Default
  endif
  if (g:hex_menu == 1 && has("gui_running"))
	an <silent> 9000.10 He&xman.&Convert\ to\ HEX\ (and\ back)<TAB><leader>hm
		\ :call <SID>HEX_Manager()<CR>
	an 9000.20 He&xman.-sep1-			<Nop>
	an <silent> 9000.30 He&xman.&Delete\ hex\ char\ under\ cursor<Tab><leader>hd
		\ :call <SID>HEX_Delete()<CR>
	an <silent> 9000.40 He&xman.&Insert\ ascii\ char\ before\ cursor<Tab><leader>hi
		\ :call <SID>HEX_Insert()<CR>
	an 9000.70 He&xman.-sep2-			<Nop>
	an <silent> 9000.90 He&xman.&Goto\ /Hex\ offset<Tab><leader>hg
		\ :call <SID>HEX_Goto()<CR>
	an <silent> 9000.90 He&xman.&Show/Hide\ infos<Tab><leader>hs
		\ :call <SID>HEX_Status()<CR>
   endif
"
"=============================================================================
" Toggle between Hexmode and Normalmode
"=============================================================================
"
function s:HEX_Manager()
"
  if g:HEX_active == 1
    " convert back to normal mode
    :silent call s:HEX_XxdBack()
    " clear offset infos
    echo ""			
  else
    " convert over xxd
    :silent call s:HEX_XxdConv()
  endif
endfun
"
" ============================================================================
" Author      : Robert Roberts (res02ot0@gte.net) 
" Dervied from: byteme.vim (VIM plugin)
" Get actual cursor position,  get new hex offset from user and move cursor to 
" new hex position.
" ============================================================================
"
function s:HEX_Goto()
"
  " if not in hexmode echo errmsg and return
  if g:HEX_active == 0
    call s:HEX_ErrMsg()
    return
  endif
  " where is the cursor now - get offset
  let offset = s:HEX_GetOffset()
  "
  let hexoffset = s:HEX_Nr2Hex(offset)
  " Get the new hex offset (the goto) from the user.
  let hexgoto = toupper(input("Enter New Hex Offset (" . toupper(hexoffset) . "): "))
  " If nothing is entered stay (move) to current position
  if hexgoto == ""
    let hexgoto = hexoffset
  endif
  " Convert the hex string to an integer.
  let intgoto=s:HEX_Hex2Nr(hexgoto)

  call s:HEX_ToOffset(intgoto)
  " echo " hexfrom: [" . toupper(hexoffset) . "]" . " intfrom: [" . offset ."] hexto: [" . hexgoto ."] intto: [" . intgoto ."]"
  return ""
endfun 
"
" =============================================================================
" Converts Hex to Number
" =============================================================================
"
function s:HEX_Hex2Nr(hx)
"
" Author      : Robert Roberts (res02ot0@gte.net) 
" Dervied from: byteme.vim (VIM plugin)
" Author Note : This actually works!  I amaze myself.  ...but to explain it...
  " Grab the passed in hex string.
  let h = a:hx
  " Initialize the result to zero.
  let nr = 0
  " Initialize the outside loop counter.
  let loopcntr=0
  " Grab the length of the hex string.
  let cntr = strlen(h)
  " Start the outside loop.
  while cntr > 0
    " Initialize the power base variable.
    let pwrbase=1
    " Initialize the power counter. The -1 was added after I found the
    " results to always be one power too high.
    let pwrcntr=cntr-1
    " Create my own pow() functionality (e.g. 16^x).
    while pwrcntr > 0
      " This will do powers of 16 only.
      let pwrbase=pwrbase*16
      " Decrement the power counter. E.g. for a HEX string with a length of
      " 4, this will do a 1*16*16*16
      let pwrcntr=pwrcntr-1
    endwhile
    " Start grabbing the chars off the left and work right.
    let xchr = strpart(h,loopcntr,1)
    " Find the char in the haystack and return its position which will equal
    " its single char value.
    let ichr = stridx("0123456789ABCDEF",xchr)
    " Multiply that single char value against the powerbase and add it to the total.
    let nr = nr + (ichr*pwrbase)
    " Tweak the counters.
    let cntr=cntr-1
    let loopcntr=loopcntr+1
  endwhile
  " return the interger value.
  return nr
endfunc
"
" =================================================================================================
" Found this function in the standard VIM :help documentation using :h eval-examples
" The function returns the Hex string of a number.
" =================================================================================================
"
function s:HEX_Nr2Hex(nr)
"
  let n = a:nr
  let r = ""
  while n
    let r = '0123456789ABCDEF'[n % 16] . r
    let n = n / 16
  endwhile
  " For display asthetics only.  When sitting at the very first char in the file,
  " the camefrom hex will be "" which naturally displays as nothing.
  if r == ""
    let r = "00"
  endif
  return r
endfunc
"
"=============================================================================
let g:HEX_active=0	" initialize - set hex mode off
"=============================================================================
" Found the xxd functions in menu.vim
" Use a function to do the conversion, so that it also works 
" with 'insertmode' set.
"=============================================================================
"
function s:HEX_XxdConv()
"
  " get cursor position
  let g:cc = line2byte(line("."))
  let g:cc = g:cc - 1	" hex view starts with zero
  let offset = s:HEX_Nr2Hex(g:cc)	" convert decimal to hex
  "
  let mod = &mod
  if has("vms")
    %!mc vim:xxd
  else
    call s:HEX_XxdFind()
    exe '%!"' . g:xxdprogram . '"' 
  endif
  if getline(1) =~ "^0000000:"		" only if it worked
    set ft=xxd
  else
    return				" can't start xxd
  endif
  let &mod = mod
  "
  " Nice mapping for TAB/Shift-TAB
  " Move from hex to hex field - with TAB / Shift-TAB
  " map <silent> <TAB> :call <SID>HEX_NextPrev(+1)<CR>
  " map <silent> <S-TAB> :call <SID>HEX_NextPrev(-1)<CR>
  " Map key variable to invoke the command
  " 14Jun03 If hex_movetab is not defines - default = 1
  if !exists("g:hex_movetab")
    let g:hex_movetab = 1	" Default
  endif
  if g:hex_movetab == 1
    let g:hex_tab = mapcheck("<TAB>")	" save mapping for TAB
    let g:hex_stab = mapcheck("<S-TAB>")	" save mapping for Shift-TAB
    let g:hex_stab = 0
    map <silent> <TAB> :silent call <SID>HEX_NextPrev(+1)<CR>
    map <silent> <S-TAB> :silent call <SID>HEX_NextPrev(-1)<CR>
    map <silent> ? :call <SID>HEX_Help()<CR>
  endif
  "
  " Show additional info in statusline (overwrite)
  " Maybe there is a better way to set this with rulerformat but
  " I don't know how I can do this... 
  if !exists("g:hex_showstatus")
    let g:hex_showstatus = 0	" no hex statusinfo
  endif
  call s:HEX_Status()
  :highlight AsciiPos guibg=Yellow cterm=reverse term=reverse
  :au! Cursorhold * exe 'match AsciiPos /\%' . s:HEX_ShowOffsets() . 'v'
  :set ut=100 
  "
  " remember we are in hex mode
  let g:HEX_active=1
  " put cursor to related position
  call s:HEX_ToOffset(offset)
  "
endfun
"
" ==============================================================================
" The function HexOff passes the file over xxd to view it in normal mode
" ==============================================================================
"
function s:HEX_XxdBack()
"
  let mod = &mod
  if has("vms")
    %!mc vim:xxd -r
  else
    call s:HEX_XxdFind()
    exe "%!" . g:xxdprogram . " -r"
  endif
  set ft=
  doautocmd filetypedetect BufReadPost
  let &mod = mod
  let g:HEX_active=0			" no hex mode
  if g:hex_movetab == 1
    " restore mapping
    exe "map <silent> <TAB> " . g:hex_tab
    exe "map <silent> <S-TAB> " . g:hex_stab
  endif
  " switch off Ascii pos highlighting
  :au! Cursorhold
  :match none
endfun
"
" ==============================================================================
" Find the convert utility xxd
" ==============================================================================
"
function s:HEX_XxdFind()
"
  if !exists("g:xxdprogram")
    " On the PC xxd may not be in the path but in the install directory
    if (has("win32") || has("dos32")) && !executable("xxd")
      let g:xxdprogram = $VIMRUNTIME . (&shellslash ? '/' : '\') . "xxd.exe"
    else
      let g:xxdprogram = "xxd"
    endif
  endif
endfun
"
" ==============================================================================
" Funtion to delete current hex character
" ==============================================================================
"
function s:HEX_Delete()
"
  if g:HEX_active == 0
    call s:HEX_ErrMsg()
  else
    " Start procedure...
    " Get Offset Set and s:HEX_GetOffset again to make shure we are on the first 
    " (left) hex character
    let offset = s:HEX_GetOffset()
    call s:HEX_ToOffset(offset)
    let offset = s:HEX_GetOffset()
    let gopos = offset + 1	" command go is the first character 1 (not 0)
    " the character we have to delete must be printable 
    " (e.g. with <LF> it is not the case- we set it to 'a'
    " 
    :norm! ra
    " go to normal Mode
    call s:HEX_XxdBack()
    " goto file position
    exe gopos"go"
    " delete character
    :norm! x
    " go to xxd mode
    :silent call s:HEX_XxdConv()
    " cursor back where it belong
    call s:HEX_ToOffset(offset)
  endif
endfun
"
" ==============================================================================
" Funtion to Insert a character before cursor
" ==============================================================================
"
function s:HEX_Insert()
"
  if g:HEX_active == 0
    call s:HEX_ErrMsg()
    return
  endif
  
  " Get the new hex offset (the goto) from the user.
  let insval = input("Enter New Ascii Character: ")
  " If nothing is entered do nothing
  if insval == ""
     return
  endif
  " Start procedure...
  " Get Offset Set and s:HEX_GetOffset again to make shure we are on the first 
  " (left) hex character
  let offset = s:HEX_GetOffset()
  call s:HEX_ToOffset(offset)
  let offset = s:HEX_GetOffset()
  let gopos = offset + 1	" command go is the first character 1 (not 0)
  " go to normal Mode
  call s:HEX_XxdBack()
  " goto file position
  exe gopos"go"
  " insert character
  exe ":norm! i" . insval
  " go to xxd mode
  :silent call s:HEX_XxdConv()
  " cursor back where it belong
  call s:HEX_ToOffset(offset)
endfun
"
" ==============================================================================
" Move to Offset position in Hex View
" ==============================================================================
"
function s:HEX_ToOffset(goto)
"
  " declare funtion local
  let intgoto = a:goto
  " Calculate the line number of the new offset.
  let newline = intgoto / 16 + 1
  " Calculate the column number within that new line. I could do it in one line,
  " but this is less obfuscated.
  let newcol = intgoto % 16
  let newcol = newcol * 5 / 2
  let newcol = newcol + 10
  " Go to that new line.
  exec ":" . newline
  " Go to that new column.
  exec "norm " . newcol . "|"
  return ""
endfun
"
" ==============================================================================
" Get Offset offen Current Position in Hex Mode
" ==============================================================================
"
function s:HEX_GetOffset()
"
" Get the current line number but -1 to use base 0 to make the *16 work right.
  let curline = line(".") - 1
  " Get the current column number.
  let curcol  = col(".")
  " If the curcol is greater than 48...
  if curcol > 47
      " Make it 47.  We don't care about the text to the right of the hex.
      let curcol = 47
  endif
  " Subtract 10 from the curcol.  We don't care about the line numbers on the left.
  let curcol = curcol - 11
  " Adjust for when the cursor was sitting off in the line numbers.
  if curcol < 0
    let curcol = 0
  endif
  " Initiaze this.  It will be set to 1 later on if we are sitting on the second byte of a word.
  let midwrd = 0
  " If column is greater than 0, we are sitting the actual hex code area (like we want).
  if curcol > 0
    " This colmod and midwrd stuff is just for calculating the camefrom hex when we
    " are mid hexword.
    let colmod = curcol % 5
    " If colmod is not 0, we are midword.
    if colmod > 0
      " Will add 1 to get midword hex char.
      let midwrd = 1
    endif
    " Divide the column by 5 and then multiply by two and it will give you the
    " proper integer column number for the first byte in each 2 byte group.
    let curcol = curcol * 2 / 5
  endif
  " There are 16 bytes in each line plus the current column calculation.
  let offset = (curline * 16) + curcol
  " Add the midword adjustment for being in the middle of a hexword if needed.
  let offset = offset + midwrd
  "if offset < 0
  "  let offset = 0
  "endif
  " Convert the integer offset to Hex.
  return offset
endfun
" 
" =======================================================================================
" Std. message if a fuction is called if we are not in hexmode 
" =======================================================================================
" 
function s:HEX_ErrMsg()
    " one day there comes a better error message ;-)
    echo "Sorry - not in Hexmode!!!"
endfun
"
" =======================================================================================
" Move to Next/Previous Hex field
" =======================================================================================
"
function s:HEX_NextPrev(n)
"
  let goto = a:n
  " Add/Subtract from current offset
  :silent let offset = s:HEX_GetOffset() + goto
  " Move cursor to new offset
  :silent call s:HEX_ToOffset(offset)
"
endfun
" =======================================================================================
function s:HEX_ShowOffsets()
" =======================================================================================
" Calculate from hex offset the corresponding ascii offset and shows the result
"
  " Get the current column number.
  let curcol  = col(".")
  "
  " calculate related ascii position (right part from xxd)
  " init newcol first ascii position is 51
  let newcol = 51
  " first hex part valid till position 12
  let colpos = 12
  " Add 3 than 2 than 3 than 2 and so on
  let coladd = 3
  while colpos <= curcol
      let colpos = colpos + coladd
      let newcol = newcol + 1
      if coladd > 2
	let coladd = 2
      else
	let coladd = 3
      endif
  endwhile
  " Show offsets
  let s:offset = s:HEX_GetOffset()         	" Next/Prev Hex Position
  let s:hexoff = s:HEX_Nr2Hex(s:offset)	 	" Calculate Number To Hex
  " calculate and show offsets and optional help
  " set help off for default

  " call s:HEX_Help(hexoff, offset)
  echo "Offset Hex:[" . s:hexoff ."] Dec:[" . s:offset ."]      Press ? for help"
  return newcol
"
endfun
"
" =======================================================================================
" Show / Stop Overwriting Statusline with Offset-Info
" =======================================================================================
function s:HEX_Status()
  if g:HEX_active == 0
    call s:HEX_ErrMsg()
    return
  endif
  if g:hex_showstatus == 1
    :au! Cursorhold
    :match none
    let g:hex_showstatus = 0
  else
    :highlight AsciiPos guibg=Yellow cterm=reverse term=reverse
    :silent au! Cursorhold * exe 'match AsciiPos /\%' . s:HEX_ShowOffsets() . 'v'
    :set ut=100 
    let g:hex_showstatus = 1
  endif
endfun
" =======================================================================================
" Show Hexoffset and Help Menue (if required)
" =======================================================================================
function s:HEX_Help()
" 
  echo "	Available functions:"
  echo ""
  echo "	<leader>hm		Hex(manager) toggle on / off"
  echo "	<leader>hd  		Delete hex character under cursor"
  echo "	<leader>hi  		Insert ascii character before cursor"
  echo "	<leader>hg  		Goto hex offset. "
  echo "	<leader>hn  		Goto next hex offset. "
  echo "	<leader>hp  		Goto previous hex offset. "
  echo "	<leader>hs  	        Show / Hide hexoffset infos in statusline"
  if !exists("g:mapleader")
	echo "	<leader> = '\\'"
  else
	echo "	<leader> = " . g:mapleader
  endif
endfun
" 
"=============================================================================
" restore cpoptions
let &cpo = s:save_cpo
"=============================================================================
" End off hexman.vim
"=============================================================================
