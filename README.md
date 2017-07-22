# nautilus_save_tabs

Nautilus scripts to save/restore tabs

* SaveTabs saves URIs of tabs
* GetURIs is a sub script used by SaveTabs
* RestoreTabs restores saved tabs

## requirements
* nautilus
* ruby
* xdotool
* zenity

## Configuration

### save_tabs

`save_tabs` is a yaml file to configure the scripts.
if you need to use diffrent configuration from the default one,
`cp save_tabs.example save_tabs` and modify `save_tabs`

| variable | description | default value |
|:---------|:------------|:--------------|
| sleep_time_save | sleep time after each key input by xdotool (seconds) in SaveTabs | 0.03 |
| max_tab | maximum number of tabs to scan | 128 |
| min_tab | number of tabs to scan at the start of scanning | 4 |
| shortcut_geturis | shortcut key to invoke `GetURIs` script | "control+g" |
| sleep_time_restore | sleep time after each key input by xdotool (seconds) in RestoreTabs | 0.3 |
| select_uri_delay | delay between keystrokes to select uri in RestoreTabs (milliseconds) | 100 |
| save_tabs_path | file to save tabs | ENV['HOME'] + '/.local/share/nautilus/tabs' |
| socket_path | socket used by SaveTabs and GetURIs | '/tmp/nautilus_' + ENV['USER'] + '.socket' |

#### sleep and delay

increase `sleep_time_*` and/or `select_uri_delay` if the script is unstable.

### accels
modify scripts-accels to configure keyboard shortcuts for Nautilus >= 3.20

## Installation
`bundle install --path vendor/bundle` and `bundle exec rake install` will install everything.

## Usage
* to save tabs, invoke SaveTabs clicking right button of the mouse on the file or using
  keyboard shortcuts configured in the installation.
* to resotore tabs, invoke RestoreTabs when a tab is open. the current tab is
  replaced with the first one and the rest of tabs are inserted after the current tab.
* DO NOT touch mouse and keyboard while saving/restoring tabs.

## Development

scripts have been tested with Ubuntu 17.04 and Ruby 2.4.1.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/susurri/nautilus_save_tabs. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
