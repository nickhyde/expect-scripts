#!/usr/bin/expect
set host "10.9.1.1"
set timeout 10
set proceed 1

proc  quoterange {line quote} {
  set range [expr {[string last $quote $line] -1}]
  return "[expr {[string last $quote [string range $line 0 $range]] +1}] $range"
}

proc mapkey {keyval line} {
  global keymap
  set action "\{send  -- \""
  set ubound [quoterange $line "\""]
  for {set lbound [lindex $ubound 0]; set ubound [lindex $ubound 1]} {$lbound <= $ubound} {incr lbound} {
    set char [string index $line $lbound]
    if {[lsearch -exact {\" \{ \[ \] \}} $char]  >= 0 && [string index $line [expr $lbound -1]] != "\\"} {
      append action "\\"
    }
    append action $char
  }
  if {[regexp {\\\"$} $line] && [regexp {[^\\](\\\\){0,2}\"$} $line] == 0} {;#end of line slash \must have even occurances
    append action "\\"
  }
  lappend keymap "$keyval $action\"\}"
}

proc lines2list {filedata} {
  set ltol ""
  lappend filedata [string map {\\ / " " "\\ "} [lindex ${filedata} 0]]
  if {[string match {?:*} [lindex ${filedata} 1]]} {
    lset filedata {1} "/cygdrive/[string map {\:/ / \: /} [lindex ${filedata} 1]]"
  }
  if {[catch {lappend filedata [file size [lindex ${filedata} 1]]}]} {
     puts "File error: [lindex ${filedata} 0]\n${::errorInfo}"
         flush stdout
  } else {
      lappend filedata 600000
      if {[lindex ${filedata} 2] <= [lindex ${filedata} 3]} {
        lappend filedata [open "[lindex ${filedata} 1]" r]
        set ltol [split [read [lindex ${filedata} 4]] "\n"]
            close [lindex ${filedata} 4]
      } else {
          puts "Unable to open file [lindex ${filedata} 0]\
                        because it's size [lindex ${filedata} 2] exceeds [lindex ${filedata} 3]."
              flush stdout
      }
  }
  return ${ltol}
}

while {${proceed} > 0} {
  set keymap {"interact \{"}
  lappend keymap "\"\\177\"        \{send -- \"\\010\"\}"
  lappend keymap "\"\\033\\\[3~\"  \{send -- \"\\004\"\}"
  lappend keymap "\"\\033\\\[24~\" \{exec cat /dev/clipboard | lpr\}"
  set line [lindex [set lines [lines2list [list "keymap.txt"]]] 0]
  if {[regexp -nocase {^( |)load(-|_| |)from.*\".+\"$} $line]} {;#open alternate file if listed eg: load-file,"file-to-load"
    set range [quoterange $line "\""]
    set lines [lines2list [list [string range ${line} [lindex $range 0] [lindex $range 1]]]]
  }
  foreach line $lines {
    switch -regexp -nocase -- $line {
      {^( +|)n.*vk_f10 .*\".+\"$}  {mapkey "\"\\033\\\[21~\""   $line}
      {^( +|)n.*vk_f11 .*\".+\"$}  {mapkey "\"\\033\\\[23~\""   $line}
      {^( +|)n.*vk_f12 .*\".+\"$}  {#Predefined for Printing mapkey "\"\\033\\\[24~\"" $line}
      {^( +|)n.*vk_f1 .*\".+\"$}   {mapkey "\"\\033\\OP\""      $line}
      {^( +|)n.*vk_f2 .*\".+\"$}   {mapkey "\"\\033\\OQ\""      $line}
      {^( +|)n.*vk_f3 .*\".+\"$}   {mapkey "\"\\033\\OR\""      $line}
      {^( +|)n.*vk_f4 .*\".+\"$}   {mapkey "\"\\033\\OS\""      $line}
      {^( +|)n.*vk_f5 .*\".+\"$}   {mapkey "\"\\033\\\[15~\""   $line}
      {^( +|)n.*vk_f6 .*\".+\"$}   {mapkey "\"\\033\\\[17~\""   $line}
      {^( +|)n.*vk_f7 .*\".+\"$}   {mapkey "\"\\033\\\[18~\""   $line}
      {^( +|)n.*vk_f8 .*\".+\"$}   {mapkey "\"\\033\\\[19~\""   $line}
      {^( +|)n.*vk_f9 .*\".+\"$}   {mapkey "\"\\033\\\[20~\""   $line}
      {^( +|)s.*vk_f10 .*\".+\"$}  {mapkey "\"\\033\\\[21;2~\"" $line}
      {^( +|)s.*vk_f11 .*\".+\"$}  {mapkey "\"\\033\\\[23;2~\"" $line}
      {^( +|)s.*vk_f12 .*\".+\"$}  {mapkey "\"\\033\\\[24;2~\"" $line}
      {^( +|)s.*vk_f1 .*\".+\"$}   {mapkey "\"\\033\\\[1;2P\""  $line}
      {^( +|)s.*vk_f2 .*\".+\"$}   {mapkey "\"\\033\\\[1;2Q\""  $line}
      {^( +|)s.*vk_f3 .*\".+\"$}   {mapkey "\"\\033\\\[1;2R\""  $line}
      {^( +|)s.*vk_f4 .*\".+\"$}   {mapkey "\"\\033\\\[1;2S\""  $line}
      {^( +|)s.*vk_f5 .*\".+\"$}   {mapkey "\"\\033\\\[15;2~\"" $line}
      {^( +|)s.*vk_f6 .*\".+\"$}   {mapkey "\"\\033\\\[17;2~\"" $line}
      {^( +|)s.*vk_f7 .*\".+\"$}   {mapkey "\"\\033\\\[18;2~\"" $line}
      {^( +|)s.*vk_f8 .*\".+\"$}   {mapkey "\"\\033\\\[19;2~\"" $line}
      {^( +|)s.*vk_f9 .*\".+\"$}   {mapkey "\"\\033\\\[20;2~\"" $line}
      {^( +|)c.*vk_f10 .*\".+\"$}  {mapkey "\"\\033\\\[21;5~\"" $line}
      {^( +|)c.*vk_f11 .*\".+\"$}  {mapkey "\"\\033\\\[23;5~\"" $line}
      {^( +|)c.*vk_f12 .*\".+\"$}  {mapkey "\"\\033\\\[24;5~\"" $line}
      {^( +|)c.*vk_f1 .*\".+\"$}   {mapkey "\"\\033\\\[1;5P\""  $line}
      {^( +|)c.*vk_f2 .*\".+\"$}   {mapkey "\"\\033\\\[1;5Q\""  $line}
      {^( +|)c.*vk_f3 .*\".+\"$}   {mapkey "\"\\033\\\[1;5R\""  $line}
      {^( +|)c.*vk_f4 .*\".+\"$}   {mapkey "\"\\033\\\[1;5S\""  $line}
      {^( +|)c.*vk_f5 .*\".+\"$}   {mapkey "\"\\033\\\[15;5~\"" $line}
      {^( +|)c.*vk_f6 .*\".+\"$}   {mapkey "\"\\033\\\[17;5~\"" $line}
      {^( +|)c.*vk_f7 .*\".+\"$}   {mapkey "\"\\033\\\[18;5~\"" $line}
      {^( +|)c.*vk_f8 .*\".+\"$}   {mapkey "\"\\033\\\[19;5~\"" $line}
      {^( +|)c.*vk_f9 .*\".+\"$}   {mapkey "\"\\033\\\[20;5~\"" $line}
      {^( +|)cs.*vk_f10 .*\".+\"$} {mapkey "\"\\033\\\[21;6~\"" $line}
      {^( +|)cs.*vk_f11 .*\".+\"$} {mapkey "\"\\033\\\[23;6~\"" $line}
      {^( +|)cs.*vk_f12 .*\".+\"$} {mapkey "\"\\033\\\[24;6~\"" $line}
      {^( +|)cs.*vk_f1 .*\".+\"$}  {mapkey "\"\\033\\\[1;6P\""  $line}
      {^( +|)cs.*vk_f2 .*\".+\"$}  {mapkey "\"\\033\\\[1;6Q\""  $line}
      {^( +|)cs.*vk_f3 .*\".+\"$}  {mapkey "\"\\033\\\[1;6R\""  $line}
      {^( +|)cs.*vk_f4 .*\".+\"$}  {mapkey "\"\\033\\\[1;6S\""  $line}
      {^( +|)cs.*vk_f5 .*\".+\"$}  {mapkey "\"\\033\\\[15;6~\"" $line}
      {^( +|)cs.*vk_f6 .*\".+\"$}  {mapkey "\"\\033\\\[17;6~\"" $line}
      {^( +|)cs.*vk_f7 .*\".+\"$}  {mapkey "\"\\033\\\[18;6~\"" $line}
      {^( +|)cs.*vk_f8 .*\".+\"$}  {mapkey "\"\\033\\\[19;6~\"" $line}
      {^( +|)cs.*vk_f9 .*\".+\"$}  {mapkey "\"\\033\\\[20;6~\"" $line}
    }
  }
  lappend keymap "\}"
  set keymap [join ${keymap} "\n"]
  while {${proceed} > 0 && [catch {exec timeout 0.5 bash -c "(< /dev/tcp/${host}/22)"}]} {
    puts [exec tput cuu1]
    puts -nonewline "Host ${host} can not be reached. Press any key to exit."
    flush stdout
    set proceed [exec bash -c "read -t1 -n1;e=\$?; \[\[ \$REPLY =~ x|X|a|A \]\] && echo -1 || echo \$e"]
  }
  if {${proceed} > 0} {
    set username ""
    puts -nonewline "\nUsername:"
    flush stdout
    gets stdin username
    if {[regexp -nocase {^e$|^ex$|^exi$|^exit$|^,0|^abort$|^bye$|^$} ${username}]} {
          set proceed  0
    } else {
            if {[string compare -nocase ${username} "admin"]} {
          if {[catch {spawn -noecho ssh -q -o StrictHostKeyChecking=no ${username}@${host}}]} {
            puts "\rTerminating connection in error. Error occured: ${::errorInfo}"
          } else {
                      set proceed 2
              while {${proceed} > 1} {
                expect {
                      "#" {
                         set proceed 1
                         eval ${keymap}
                       }
                  -nocase "password:" {
                            exec stty -echo
                            gets stdin pwd
                            exec stty echo
                            if {[regexp -nocase "^$" ${pwd}]} {
                              set proceed 1
                            } else {
                                      send "${pwd}\r"
                            }
                        unset pwd
                      }
                      timeout {
                        puts "timeout..."
                            flush stdout
                        set proceed 1
                      }
                      eof {
                            flush stdout
                        set proceed 1
                      }
                }
              }
              }
            } else {
              set proceed -1
            }
        }
  }
}
if {${proceed} == - 1} {exec /usr/bin/mintty}
