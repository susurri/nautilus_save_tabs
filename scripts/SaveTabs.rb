#!/usr/bin/env ruby

require 'socket'
require 'yaml'
require 'English'

# Integer class
class Integer
  def divisors
    (1..self).select { |i| (self % i).zero? }
  end
end

# Array class
class Array
  def unrecur
    size.divisors.each do |i|
      u = each_slice(i).to_a.uniq
      return(u.first) if u.size == 1
    end
  end
end

# nautilus module
module Nautilus
  # configurations
  class Config
    attr_reader(:config)
    def initialize
      @config = {
        'sleep_time_save' => 0.03,
        'max_tab' => 128,
        'min_tab' => 4,
        'shortcut_geturis' => 'control+g',
        'save_tabs_path' => ENV['HOME'] + '/.local/share/nautilus/tabs',
        'socket_path' => '/tmp/nautilus_' + ENV['USER'] + '.socket'
      }
    end

    def load
      @config = @config.merge(YAML.load_file(
                                "#{ENV['HOME']}/.config/nautilus/save_tabs"
      ))
    end
  end
  # save tabs
  class SaveTabs
    def key(keys)
      p = 'xdotool key ' + keys
      #  p = "xdotool --delay" + KEY_DELAY + keys
      system(p)
      sleep(@config.config['sleep_time_save'])
    end

    def read_socket
      Thread.start do
        Socket
          .unix_server_loop(@config.config['socket_path']) do |sock, _addr|
          @uris = YAML.safe_load(sock.read)
          break
        end
      end
    end

    def read_tab
      thread = read_socket
      key(@config.config['shortcut_geturis'])
      thread.join
      @uris
    end

    def first_tab
      key('alt+1')
      read_tab
    end

    def next_tab
      key('control+Page_Down')
      read_tab
    end

    def prev_tab
      key('control+Page_Up')
      read_tab
    end

    def last_tab
      first_tab
      prev_tab
    end

    def scan_forward(n)
      uris = [first_tab]
      (n - 1).times do
        uris << next_tab
      end
      uris
    end

    def scan_backward(n)
      uris = [last_tab]
      (n - 1).times do
        uris << prev_tab
      end
      uris
    end

    # Array -> Array -> Array
    def unwrap_around(x, y)
      if x.size != y.size
        system('zenity --warning --text "forward and backward scan mismatch"')
        exit 1
      end
      0.upto(y.size.div(2)) do |i|
        j = y.size - i
        if x.first(j) == y.rotate(i).first(j) && x.first(i) == x.last(i) &&
           y.rotate(i).last(i) == x.first(j).last(i)
          return(x.first(j))
        end
      end
      []
    end

    def save_tabs(obj)
      File.open(@config.config['save_tabs_path'], 'w') do |f|
        f.write obj.to_yaml
      end
    end

    def tabs_array(min, max)
      0.upto(Math.log2(max / min)).to_a.map do |i|
        min * 2**i
      end + [max]
    end

    def scan_tabs
      tabs_array(@config.config['min_tab'],
                 @config.config['max_tab']).each do |tab|
        l = unwrap_around(scan_forward(tab), scan_backward(tab).reverse)
        return(l) unless l.empty?
      end
      system('zenity --warning --text "MAX_TAB is too small"')
      uris_forward
    end

    def run
      @config = Config.new
      uris = scan_tabs.unrecur
      system("zenity --list \
                    --title='Session saved' \
                    --width=800 --height=600 \
                    --column='Name' --column='Value' \
                    'uris' #{uris}")
      save_tabs(uris)
    end

    def initialize; end
  end
end

if $PROGRAM_NAME == __FILE__
  # sleep a second to ensure the key to invoke the script is released
  sleep(1)
  save_tabs = Nautilus::SaveTabs.new
  save_tabs.run
end
