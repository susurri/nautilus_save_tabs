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
      @config.merge!(
        YAML.load_file("#{ENV['HOME']}/.config/nautilus/save_tabs")
      )
    end
  end
  # save tabs
  class SaveTabs
    def key(keys)
      p = 'xdotool key ' + keys
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

    def head_tail_match?(x, i)
      x.first(i) == x.last(i)
    end

    def rotate_match?(x, y, i)
      j = y.size - i
      x.first(j) == y.rotate(i).first(j) && head_tail_match?(x, i) &&
        y.rotate(i).last(i) == x.first(j).last(i) && head_tail_match?(y, i)
    end

    # Array -> Array -> Array
    def unwrap_around(x, y)
      y.reverse!
      0.upto(y.size.div(2)) do |i|
        j = y.size - i
        return(x.first(j).unrecur) if rotate_match?(x, y, i)
      end
      []
    end

    def save_tabs(obj)
      File.open(@config.config['save_tabs_path'], 'w') do |f|
        f.write obj.to_yaml
      end
    end

    def numbers_of_tabs(min, max)
      0.upto(Math.log2(max / min)).to_a.map { |i| min * 2**i } + [max]
    end

    def warn_if_mismatch(x, y)
      command = 'zenity --warning --text "forward and backward scan mismatch"'
      system(command) if x.size != y.size
    end

    def scan_tabs
      numbers_of_tabs(@config.config['min_tab'],
                      @config.config['max_tab']).each do |n|
        uris_forward = scan_forward(n)
        uris_backward = scan_backward(n)
        warn_if_mismatch(uris_forward, uris_backward)
        l = unwrap_around(uris_forward, uris_backward)
        return(l) unless l.empty?
      end
      system('zenity --warning --text "max_tab is too small"')
      uris_forward
    end

    def uris_to_s(uris)
      str = ''
      uris.each do |u|
        str += "'#{u[0]}' '" +
               (u[1].empty? ? '-' : u[1].chomp.tr("\n", ',')) + "' "
      end
      str
    end

    def show_results(uris)
      command = "zenity --list --title='Tabs saved' --text ''\
            --width=800 --height=600 --column='URIs' --column='Selected URIs' "
      command += uris_to_s(uris)
      system(command)
    end

    def run
      @config = Config.new
      uris = scan_tabs
      show_results(uris)
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
