#!/usr/bin/env ruby

require 'socket'

SOCKET_PATH = '/tmp/nautilus_' + ENV['USER'] + '.socket'

uris = [ENV['NAUTILUS_SCRIPT_CURRENT_URI']]
selected_uris = [ENV['NAUTILUS_SCRIPT_SELECTED_URIS']]

UNIXSocket.open(SOCKET_PATH) do |sock|
  sock.write([uris, selected_uris])
end

# system("zenity --list \
#--title='Session saved' \
#--width=800 --height=600 \
#--column='Name' --column='Value' \
# 'uris' #{uris} \
# 'selected_uris' #{selected_uris}")
