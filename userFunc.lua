require 'cairo'

conky_start = 1
processor = ''
distribution = ''
mounted_media = ''
cpus = -1
active_network_interface = false

-- Main call
function conky_main()
    if conky_window == nil then
        return
    end
    local cs = cairo_xlib_surface_create(conky_window.display,
                                         conky_window.drawable,
                                         conky_window.visual,
                                         conky_window.width,
                                         conky_window.height)
    cr = cairo_create(cs)
    
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
    cr=nil
end

-- Return processor name
function conky_processor()
    if processor == '' then
        local file = io.popen("lscpu | grep -Po '(?<=Model name:)(.*)'")
        processor = trim(file:read("*a"))
        file:close()
    end

    return processor
end

-- Returs distribution name
function conky_distribution()
    if distribution == '' then
        local file = io.popen('cat /etc/lsb-release | grep -Po --regexp "(?<=DISTRIB_ID=).*$"')
        distribution = trim(file:read("*a"))
        file = io.popen('cat /etc/lsb-release | grep -Po --regexp "(?<=DISTRIB_RELEASE=).*$"')
        distribution = distribution .. " " .. trim(file:read("*a"))
        file:close()
    end

    return distribution
end

-- Draw max 'n' mounted media stats 
function conky_mountmedia(n)
    if tonumber(conky_parse("$updates")) % 2 == 0 then
        local file = io.popen("lsblk | grep -oE '(/media/.*)$'")
        local count = 1
        local media = ''
        for line in file:lines() do
            local short_name = string.sub(string.sub(trim(line), string.find(trim(line), '/[^/]*$')), 2)
            if count <= tonumber(n) then
                media = media
                        .. "${goto 20}".. short_name .. "${goto  150}${fs_bar 7,70 " .. trim(line)
                        .. "}${goto 255}${fs_used " .. trim(line) .. "}/${fs_size " .. trim(line) .. "}"
                        .. "\n"
            else
                break
            end
            count = count + 1
        end
        file:close()
        mounted_media = media
        return media
    end 
        return mounted_media
end

-- draw all cpu cores
function conky_drawcpus()
    if cpus == -1 then
        local file = io.popen("lscpu -a -p='cpu' | tail -n 1")
        cpus = trim(file:read("*a"))
        file:close()
    end
    local conky_cpus = ''
    for c = 1, tonumber(cpus)  do
        if c % 2 ~= 0 then
            conky_cpus = conky_cpus
                         .. "${goto 20}" .. c ..": ${goto 42}${cpu cpu".. c
                         .."}%${goto 90}${cpubar 7,30 cpu".. c
                         .."}${goto 130}${freq_g ".. c
                         .."}GHz${goto 200}| ".. c+1 
                         ..":${goto 240}${cpu cpu".. c+1
                         .."}%${goto 285}${cpubar 7,30 cpu".. c+1 .."}${goto 325}${freq_g ".. c+1 .."}GHz"
                         .. "\n"
        end
    end
    return conky_cpus   
end

-- Draw max 'n' network stats
function conky_drawnetworks(n)
    local active_ifaces = {}
    if active_network_interface == false or tonumber(conky_parse("$updates")) % 2 == 0 then
        local ifaces = io.popen('ip link | grep -Po --regexp "(?<=[0-9]: ).*"')
        for line in ifaces:lines() do
            if string.find(line, "<BROADCAST") then
                local iface = string.gsub(string.match(line, "^.*:"), ":", "")
                table.insert( active_ifaces, iface)
            end
        end
        ifaces:close()
        if table.maxn(active_ifaces) >= 1 then
            -- local wireless_ifaces = {}
            
            -- local other_ifaces = {}
            -- local nwl_fl = io.popen('iwconfig | grep "no wireless extensions"')
            -- for line in nwl_fl:lines() do
            --     local oiface = string.sub(line, 1, string.find(a, " "))
            --     if string.match(oiface, table.concat(active_if, ",")) then
            --         table.insert(other_ifaces,oiface)
            --     end
            -- end

            -- for i, iface in pairs(active_ifaces) do
            --     if not string.match(iface, table.concat(other_ifaces, ",")) then
            --         table.insert(wireless_ifaces, iface)
            --     end
            -- end

            -- local draw_wlans = ''
            -- for i, wlan in pairs(wireless_ifaces) do
            --     draw_wlans = draw_wlans
            --                     .. "${goto 20}${font Conky Icons by Carelli}E${font}${color #00FF00} "
            --                     .. wlan .." $color channel: ${wireless_channel " .. wlan ..  "}, freq: ${wireless_freq "
            --                     .. wlan .."}" .. "\n"
            --                     .. "${goto 20}${font FontAwesome} ${font}${voffset 0} ${addrs " .. wlan ..  "} MAC: ${wireless_ap "
            --                     .. wlan ..  "}" .. "\n"
            --                     .. "${goto 20}${upspeedgraph " .. wlan ..  " 30,250 00ffff 00ff00}${goto 202}${downspeedgraph "
            --                     .. wlan ..  " 30,175 FFFF00 DD3A21}" .. "\n"
            --                     .. "${font FontAwesome}${goto 20}${font} ${upspeed "
            --                     .. wlan ..  "}${font FontAwesome}${goto 202}${font} ${downspeed " .. wlan ..  "}" .. "\n"
            --     if i < table.maxn( wireless_ifaces ) or i < table.maxn( active_ifaces ) then
            --         draw_wlans = draw_wlans .. "${goto 20}${stippled_hr 1}\n"
            --     end
            -- end

            local draw_other_ifaces = '${goto 10}${font Conky Icons by Carelli}E${font} ${color #00FF00}Network Interfaces $color \n'
            for i, iface in pairs(active_ifaces) do
                if i <= tonumber(n) then
                    draw_other_ifaces = draw_other_ifaces
                                        .. "${goto 20}".. i ..". "
                                        .. iface .." "..  "${font FontAwesome} ${font}${voffset 0} ${addrs " .. iface ..  "}" .. "\n"
                                        .. "${goto 20}${upspeedgraph " .. iface ..  " 20,175 00ffff 00ff00}${goto 202}${downspeedgraph "
                                        .. iface ..  " 20,175 FFFF00 DD3A21}" .. "\n"
                                        .. "${font FontAwesome}${goto 50}${font} ${upspeed "
                                        .. iface ..  "}${font FontAwesome}${goto 250}${font} ${downspeed " .. iface ..  "}" .. "\n"
                    if i < table.maxn( active_ifaces ) and i ~= tonumber(n) then
                        draw_other_ifaces = draw_other_ifaces .. "${goto 20}${stippled_hr 1}\n"
                    end
                end
            end
            active_network_interface = draw_other_ifaces
            return active_network_interface
            -- active_network_interface = table.concat( active_ifaces, ",")
            -- return table.concat( active_ifaces, ",")
        else
            return '${goto 10}${font Conky Icons by Carelli}E${font} ${color #00FF00}Network Interfaces $color \n${goto 50} Device not connected.\n'
        end
    end
    return active_network_interface
end

--function to trim strings
function trim(s)
   return s:gsub("^%s+", ""):gsub("%s+$", "")
end