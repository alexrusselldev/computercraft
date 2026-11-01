local args = {...}


-- Parse args

if #args < 2 then
    error("Missing arguments. Correct syntax is \"init [github user] [github repo]\"")
end

local githubUser = args[1]
local githubRepo = args[2]



-- Clean filesystem

if fs.exists("utility") then
    fs.delete("utility")
    fs.makeDir("utility")
    fs.makeDir("utility/init")
end


-- Get base config

local repoString = "https://raw.githubusercontent.com/" .. githubUser .. "/" .. githubRepo .. "/refs/heads/main/"

local baseConfigPath = repoString .. "base-config.json"

local baseConfigRes = http.get(baseConfigPath)

if  not baseConfigRes then
    error("Recieved error response from server. Please check args.")
end
local baseConfigData = baseConfigRes.readAll()

local baseConfig = textutils.unserialiseJSON(baseConfigData)


-- Update base config

baseConfig.github.user = githubUser
baseConfig.github.repo = githubRepo

local configString = textutils.serialiseJSON(baseConfig)

local configFile = fs.open("utility/config.json", "w")
configFile.write(configString)
configFile.close()


-- Get github init script

local githubInitPath = repoString .. "github-init.lua"
local githubInitRes = http.get(githubInitPath)
if  not githubInitRes then
    error("Recieved error response from server. Please check repo structure.")
end

local githubInitData = githubInitRes.readAll()

local githubInitFile = fs.open("utility/init/github-init.lua", "w")
githubInitFile.write(githubInitData)
githubInitFile.close()