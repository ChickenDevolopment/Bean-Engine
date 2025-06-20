local Core = require(script.Parent)
local Config = Core.Config.Loader


local loader = {}
-- attributes and variables

    
    local runservice = game:GetService("RunService")
    local OgRequire = require

    local ServerCustomConnects = {}
    local ClientCustomConnects = {}

    local ServerStarts = {}
    local ClientStarts = {}

    local ServerLoaded = false


    -- to prevent multi Loading
    local ServerLoading = false
    local ClientLoading = false

-- minor functions

    local function require(Module: ModuleScript) -- custom require stops errors when loading to save my brain when trying to play
        local success , err = pcall(function()
            return OgRequire(Module)
        end)

        if success then
            return err
        else
            warn("Error Loading ".. Module)
            return {}
        end
    end

    local function tryInit(Module: ModuleScript) -- trys to auto init a module during auto module loading
        if not Module.Parent:IsA("ModuleScript") then
            local mod = Module
            Module = require(Module)
    
            if Module.LoaderInfo then
                if Module.LoaderInfo.autoInit == true then -- module auto init
                    local success , err = pcall(function()
                        Module:Init()
                    end)

                    if not success then
                        warn("Error Init module" , mod , "Error Message: ".. err)
                    end
                end

                if Module.LoaderInfo.CustomTrigger then -- module custom triggers set up
                 
                    if runservice:IsClient() then
                        if ClientCustomConnects[Module.LoaderInfo.CustomTrigger] then
                            table.insert(ClientCustomConnects[Module.LoaderInfo.CustomTrigger] , mod)
                        else
                            ClientCustomConnects[Module.LoaderInfo.CustomTrigger] = {}
                            table.insert(ClientCustomConnects[Module.LoaderInfo.CustomTrigger] , mod)
                        end

                    elseif runservice:IsServer() then
                        if ServerCustomConnects[Module.LoaderInfo.CustomTrigger] then
                            table.insert(ServerCustomConnects[Module.LoaderInfo.CustomTrigger] , mod)
                        else
                            ServerCustomConnects[Module.LoaderInfo.CustomTrigger] = {}
                            table.insert(ServerCustomConnects[Module.LoaderInfo.CustomTrigger] , mod)
                        end
                    end

                end

                if typeof(Module:Start) == "function" then
                    if runservice:IsClient() then
                        table.insert(ClientStarts , mod)
                    elseif runservice:IsServer() then
                        table.insert(ServerStarts , mod)
                    end
                end
            end
        end
    end

    local function tryStart(Module: ModuleScript) -- trys to start up modules after Init
        Module = require(Module)
        local success , err = pcall(function()
             Module:Init()
        end)

        if not success then
            warn("Error Init module" , mod , "Error Message: ".. err)
        end
    end

    local function CustomTriggerLoop(tab , arg1 , arg2 , arg3) -- does the custom triggers
        for _,Mod in tab do
            task.spawn(function()
                pcall(function()
                    require(Mod):Trigger(arg1 , arg2 , arg3)
                end)
            end)
        end
    end

    local function GetModule(Start: Instance , Path: table) -- used to get to desired path
        if #Path = 1 then
            if Start:FindFirstChild(Path[1]) and Start:FindFirstChild(Path[1]):IsA("ModuleScript") then
                return Start:FindFirstChild(Path[1])
            end
        else
            if Start:FindFirstChild(Path[1]) then
                local nextInst = Start:FindFirstChild(Path[1])
                table.remove(Path, 1)
                return GetModule(nextInst , Path)
            end
        end
    end



-- major functions

    function loader:Load() -- used to auto load server and client modules
        if runservice:IsClient() and ClientLoading == false then
           

            ClientLoading = true

            if Config.ClientWaitForServer == true then
                while ServerLoaded == false do
                    task.wait()
                end
            end

             local Debug = Core.Debug.new("Client_Loading")


            for _ , Module in game:GetService("Players").LocalPlayer.PlayerScripts.Client.Modules:GetDescendants() do
                if Module:IsA("ModuleScript") then
                    task.spawn(function()
                        Debug:Log("Client Trying to Init " .. Module.Name)
                        tryInit(Module)
                    end)
                end
            end

            for _ , Module in ClientStarts do
                Debug:Log("Client Trying to Start " .. Module.Name)
                tryStart(Module)
            end


        elseif runservice:IsServer() and ServerLoading == false then

            ServerLoading = true
            local Debug = Core.Debug.new("Server_Loading")


            for _ , Module in game:GetService("ServerScriptService").Server.Modules:GetDescendants() do
                if Module:IsA("ModuleScript") then
                    task.spawn(function()
                        Debug:Log("Server Trying to Init " .. Module.Name)
                        tryInit(Module)
                    end)
                end
            end

            ServerLoaded = true

            for _ , Module in ServerStarts do
                Debug:Log("Server Trying to Start " .. Module.Name)
                tryStart(Module)
            end

        end
    end

    function loader:CustomTrigger(Action: string , arg1 , arg2 , arg3)
        if runservice:IsClient() then
            local tab = ClientCustomConnects[Action]

            if tab then
                CustomTriggerLoop(tab , arg1 , arg2 , arg3 )
            end

        elseif runservice:IsServer() then
            local tab = ServerCustomConnects[Action]

            if tab then
                CustomTriggerLoop(tab , arg1 , arg2 , arg3 )
            end
        end
    end

    function loader:GetModule(Path: string): table
        if not Path then return {} end
        Path = string.split(Path, Config.PathSeperator)

        if Path[1] == "Client" then
            table.remove(Path, 1)
            return GetModule(game:GetService("Players").LocalPlayer.PlayerScripts , Path)
        elseif Path[1] == "Shared" then
            table.remove(Path, 1)
            return GetModule(game:GetService("ReplicatedStorage") , Path)
        elseif Path[1] == "Server" then
            table.remove(Path, 1)
            return GetModule(game:GetService("ServerScriptService") , Path)
        end
    end

return loader