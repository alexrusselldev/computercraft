local args = {...}


-- Parse args

if #args < 2 then
    error("Missing arguments. Correct syntax is \"init [github user] [github repo]\"")
end

local githubUser = args[1]
local githubRepo = args[2]
term.setTextColor(colors.red)
print("Warning, running this script will completely reset and re-initialise the computer.")
print("Press ENTER to continue, or any other key to abort.")

while true do
    local event, key, isHeld = os.pullEvent("key")
    local keyName = keys.getName(key)
    if key == 257 then
        print("Executing initialisation.")
        break
 else
        term.setTextColor(colors.red)
        print("Aborting")

        return
    end
end

-- Clean filesystem
term.setTextColor(colors.orange)
print("Resetting filesystem")

if fs.exists("utility") then
    fs.delete("utility")
    fs.makeDir("utility")
    fs.makeDir("utility/init")
end

term.setTextColor(colors.green)
print("Success")

-- Get base config

term.setTextColor(colors.orange)
print("Fetching default config.")

local repoString = "https://raw.githubusercontent.com/" .. githubUser .. "/" .. githubRepo .. "/refs/heads/main/"

local baseConfigPath = repoString .. "base-config.json"

local baseConfigRes = http.get(baseConfigPath)

if  not baseConfigRes then
    error("Recieved error response from server. Please check args.")
end
local baseConfigData = baseConfigRes.readAll()

local baseConfig = textutils.unserialiseJSON(baseConfigData)

term.setTextColor(colors.green)
print("Success")

-- Update base config

term.setTextColor(colors.orange)
print("Creating local config.")

baseConfig.github.user = githubUser
baseConfig.github.repo = githubRepo

local configString = textutils.serialiseJSON(baseConfig)

local configFile = fs.open("utility/config.json", "w")
configFile.write(configString)
configFile.close()

term.setTextColor(colors.green)
print("Success")

-- Get github init script

term.setTextColor(colors.orange)
print("Fetching secondary init script from Github.")

local githubInitPath = repoString .. "github-init.lua"
local githubInitRes = http.get(githubInitPath)
if  not githubInitRes then
    error("Recieved error response from server. Please check repo structure.")
end

local githubInitData = githubInitRes.readAll()

local githubInitFile = fs.open("utility/init/github-init.lua", "w")
githubInitFile.write(githubInitData)
githubInitFile.close()

term.setTextColor(colors.green)
print("Success")

term.setTextColor(colors.green)
print("First stage initialisation successful, press ENTER to begin second stage, or any other key to exit.")
while true do
    local event, key, isHeld = os.pullEvent("key")
    local keyName = keys.getName(key)
    if key == 257 then
        term.setTextColor(colors.green)
        print("Proceeding to next stage")
        os.run({}, "utility/init/github-init.lua")
 else
        term.setTextColor(colors.orange)
        print("Exiting script. Finish initialisation later by running the script at utility/init/github-init.lua")

        return
    end
end