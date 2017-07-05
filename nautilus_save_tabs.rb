#!/usr/bin/env ruby

## (1..30).select {|n| 60 % n == 0}
#
# array.each_slice
#

SLEEP_TIME = 0.15
MAX_TAB = 30
KEY_DELAY = 1000

def key_and_paste(keys)
  p = 'xdotool key ' + keys + ' control+l control+c'
  #  p = "xdotool --delay" + KEY_DELAY + keys + "control+l control+c"
  system(p)
  sleep(SLEEP_TIME)
  `xsel --clipboard`
  #  return(paste())
end

def first_tab
  key_and_paste('alt+1')
end

def next_tab
  key_and_paste('control+Page_Down')
end

def prev_tab
  key_and_paste('control+Page_Up')
end

def current_tab
  key_and_paste('F3 F3')
end

def nth_tab(n)
  n = [9, [0, n].max].min
  key_and_paste("alt+#{n} F3 F3")
end

def edge?
  c = current_tab
  next_tab
  c != prev_tab
end

def min_tabs
  uris = []
  0.upto(9) do |i|
    uris << nth_tab(i)
  end
  print(uris)
  uris.uniq.size
end

def onetab?
  min_tabs == 1
end

uris = [first_tab]
unless onetab?
  MAX_TAB.times do
    uris << next_tab
    break if edge?
  end
end

system("zenity --list \
              --title='Session saved' \
              --width=800 --height=600 \
              --column='Name' --column='Value' \
              'uris' #{uris}")
