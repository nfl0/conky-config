# conky-config
Conky configurations for laptop with following features:
- Conky is displayed always on primary monitor (using resolution change events)
- with installation of config (installation tested  on ubuntu 18.04)
- Laptop-Desktop Mode Indicator
- battery indicator with capacity
- CPU, RAM, HDD, GPU, WLAN info
- top 5 cpu hungry processes
- all drives mounted in /media/$user/* are shown (default max 6)   

This is fork of [andrea-rosa/conky-config](https://github.com/andrea-rosa/conky-config) repository.
It is modified according to my needs for Dell Inspiron 5520 laptop.
Thanks to [andrea-rosa](https://github.com/andrea-rosa) for this beautiful configuration and [antoniocarelli](https://github.com/antoniocarelli) for icons.
Thanks [ritave](https://github.com/ritave/xeventbind) for xeventbind.

# Install
Make script executable
`sudo chmod +x install`
then install
`./install`
If asked password enter it. It is required to create autostart entry.
#### This script installs conky on ubuntu if not installed. On distroes other than debian-based, conky should be installed first.

# Demo
![gif](https://github.com/ajitjadhav28/conky-config/blob/master/demo.gif)
![Screenshot](https://github.com/ajitjadhav28/conky-config/blob/master/Screenshot%20from%202019-04-02%2022-07-37.png)
  
#### **Notes**:
You need to install following fonts
1. [Font Awesome](https://github.com/FortAwesome/Font-Awesome)
2. [Conky Icons by Carelli](https://github.com/antoniocarelli/conky/blob/master/Conky%20Icons%20by%20Carelli.ttf)
