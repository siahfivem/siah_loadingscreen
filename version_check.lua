local http = require("socket.http")

-- Your current version
local current_version = "1.2.0"

-- URL where the latest version is stored (e.g., raw GitHub text file)
local version_url = "https://raw.githubusercontent.com/yourusername/yourrepo/main/version.txt"

-- Function to fetch remote version
local function get_latest_version(url)
    local body, code = http.request(url)
    if code == 200 and body then
        return body:match("^%s*(.-)%s*$") -- trim whitespace
    else
        return nil, "Failed to fetch version. HTTP code: " .. tostring(code)
    end
end

-- Function to compare version strings
local function is_update_available(current, latest)
    local function split_version(v)
        local parts = {}
        for part in v:gmatch("(%d+)") do
            table.insert(parts, tonumber(part))
        end
        return parts
    end

    local current_parts = split_version(current)
    local latest_parts = split_version(latest)

    for i = 1, math.max(#current_parts, #latest_parts) do
        local c = current_parts[i] or 0
        local l = latest_parts[i] or 0
        if c < l then return true end
        if c > l then return false end
    end

    return false
end

-- Run the version check
local latest, err = get_latest_version(version_url)
if latest then
    print("Current version: " .. current_version)
    print("Latest version: " .. latest)
    if is_update_available(current_version, latest) then
        print("🚨 Update available!")
    else
        print("✅ You are using the latest version.")
    end
else
    print("Error: " .. err)
end
