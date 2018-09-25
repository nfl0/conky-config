require 'cairo'

conky_start = 1
processor = ''
distribution = ''
mounted_media = ''
cpus = -1
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

function conky_processor()
    if processor == '' then
        local file = io.popen("lscpu | grep -Po '(?<=Model name:)(.*)'")
        processor = trim(file:read("*a"))
        file:close()
    end

    return processor
end

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

function trim(s)
   return s:gsub("^%s+", ""):gsub("%s+$", "")
end