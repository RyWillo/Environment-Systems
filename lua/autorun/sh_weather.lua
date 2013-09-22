-----------------
--Weather Sytem--
---Shared File---
-----------------

if SERVER then
WeathMod = 1

Msg("===============Environment Systems Installed===============")
/*
util.PrecacheSound( "ambient/atmosphere/thunder3.wav" )
util.PrecacheSound( "ambient/atmosphere/thunder3.wav" )

util.PrecacheSound( "ambient/atmosphere/Thunder_02.mp3" )
util.PrecacheSound( "ambient/atmosphere/Thunder_03.mp3" )
util.PrecacheSound( "ambient/atmosphere/Thunder_04.mp3" )
util.PrecacheSound( "ambient/atmosphere/Thunder_05.mp3" )
util.PrecacheSound( "ambient/atmosphere/Thunder_06.mp3" )
util.PrecacheSound( "ambient/atmosphere/Thunder_07.mp3" )
util.PrecacheSound( "ambient/atmosphere/Thunder_08.mp3" )

util.PrecacheSound( "ambient/atmosphere/lightning_strike_01.mp3" )
util.PrecacheSound( "ambient/atmosphere/lightning_strike_01.mp3" )
util.PrecacheSound( "ambient/atmosphere/lightning_strike_01.mp3" )
*/



resource.AddFile( "ambient/atmosphere/Thunder_02.mp3" )
resource.AddFile( "ambient/atmosphere/Thunder_03.mp3" )
resource.AddFile( "ambient/atmosphere/Thunder_04.mp3" )
resource.AddFile( "ambient/atmosphere/Thunder_05.mp3" )
resource.AddFile( "ambient/atmosphere/Thunder_06.mp3" )
resource.AddFile( "ambient/atmosphere/Thunder_07.mp3" )
resource.AddFile( "ambient/atmosphere/Thunder_08.mp3" )

resource.AddFile( "ambient/atmosphere/lightning_strike_01.mp3" )
resource.AddFile( "ambient/atmosphere/lightning_strike_01.mp3" )
resource.AddFile( "ambient/atmosphere/lightning_strike_01.mp3" )

resource.AddFile( "materials/particle/128_VSmoke01B_A.vtf" )
resource.AddFile( "materials/particle/128_VSmoke01B_B.vtf" )
resource.AddFile( "materials/particle/128_VSmoke01B_C.vtf" )
resource.AddFile( "materials/particle/128_VSmoke01B_D.vtf" )
resource.AddFile( "materials/particle/128_VSmoke01B_E.vtf" )

resource.AddFile( "materials/entities/wm_lightning_killicon.vtf" )
resource.AddFile( "materials/entities/wm_tornado_killicon.vtf" )

resource.AddFile( "materials/particle/128_VSmoke01B_A.vmt" )
resource.AddFile( "materials/particle/128_VSmoke01B_B.vmt" )
resource.AddFile( "materials/particle/128_VSmoke01B_C.vmt" )
resource.AddFile( "materials/particle/128_VSmoke01B_D.vmt" )
resource.AddFile( "materials/particle/128_VSmoke01B_E.vmt" )

resource.AddFile( "materials/entities/es_lightning_killicon.vmt" )
resource.AddFile( "materials/entities/es_tornado_killicon.vmt" )

math.randomseed(os.time())

local Debugging = false

local MaxScale = 5

local particles = true

function WM_GetPart()
    return particles
end

function WMD_SetPart(b)
    particles = tobool(b)
end

function WM_GetMaxScale()
	return MaxScale
end

function WMD_SetMaxScale(num)
    MaxScale = num
end

local MaxTemp = 35
local MinTemp = 15

local MaxHum = 100
local MinHum = 25

--local Temperature 	= math.Rand(MinTemp,MaxTemp)
--local Humidity 		= math.Rand(MinHum,MaxHum)

local Temperature 	= 35
local Humidity 		= 100

local StormPower = ( ( ((Temperature/MaxTemp)*0.8) + ((Humidity/MaxHum)*0.2) ) / 1) * 100
local StormChance = (( (((Temperature/MaxTemp)^2.00)*0.25) + (((Humidity/MaxHum)^2.00)*0.75) )/1)^2 * 100

local ActiveStorm = true

--Required Storm Power 
local Storm_Super = 75
local Storm_Thunder = 50
local Storm_Rain = 0 

function WM_IsActiveStorm()
	return ActiveStorm
end

function WM_OneSecond()
end

function WM_TenSecond()
    WM_CalcConditions()
    
    if math.random(0,100) <= StormChance then
    
        WM_CreateStorm(Temperature, Humidity, StormChance)
        
    	if Debugging then
	    	print("HERE COMES A STORM!")
		end
	end
    
end

function WM_ThirtySecond()
end

function WM_SixtySecond()
end

function WM_CalcConditions()
	local MinMaxDiff_Temp = MaxTemp - MinTemp
	local MinMaxDiff_Hum = MaxHum - MinHum
	
	local CurMaxDiff_Temp = MaxTemp - Temperature
	local CurMaxDiff_Hum = MaxHum - Humidity
	
	local IncreaseTempChance = ((CurMaxDiff_Temp / MinMaxDiff_Temp)^0.7) * 100
	local IncreaseHumChance = ((CurMaxDiff_Hum / MinMaxDiff_Hum)^0.5) * 100
	
	if math.random(0,100) <= IncreaseTempChance then
	    if not (Temperature >= MaxTemp) then
            Temperature = math.Clamp(Temperature + (math.Rand(1,6) * (IncreaseTempChance/100)),MinTemp, MaxTemp )
	    end
	else --We're getting colder
	    Temperature = math.Clamp(Temperature + (math.Rand(-1,-4) * (IncreaseTempChance/100)),MinTemp, MaxTemp )
	end
	
	if math.random(0,100) <= IncreaseHumChance then
	    if not (Humidity >= MaxHum) then
            Humidity = math.Clamp(Humidity + (math.Rand(5,25) * (IncreaseHumChance/100)),MinHum, MaxHum )
	    end
	else --We're getting dryer
	    Humidity = math.Clamp(Humidity + (math.Rand(-5,-15) * (IncreaseHumChance/100)),MinHum, MaxHum )
	end
	
 	StormChance = (  ((((Temperature/MaxTemp)^2)/1)*0.2) + ((((Humidity/MaxHum)^2)/1)*0.8)  )^2 * 100
	
	if Debugging then
	    print("Temperature: "..(math.Round(Temperature*100)/100).."'C\tHumidity: "..(math.Round(Humidity*100)/100).."%\tStormChance: "..(math.Round(StormChance*100)/100).."%")
	end
	
end

timer.Create( "WM_OneSecond", 1, 0, WM_OneSecond )
timer.Create( "WM_TenSecond", 10, 0, WM_TenSecond )
timer.Create( "WM_ThirtySecond", 30, 0, WM_ThirtySecond )
timer.Create( "WM_SixtySecond", 60, 0, WM_SixtySecond )

/*---------------------------------------------------------
   Figure out what kind of storm to spawn.
   High Temperature = Lightning
   High Humidity = Rain
   Ect...
---------------------------------------------------------*/
function WM_CreateStorm()

	if WM_IsActiveStorm() then return false end

	StormPower = ( ( ((Temperature/MaxTemp)*0.75) + ((Humidity/MaxHum)*0.25) ) / 1) * 100

	if StormPower > Storm_Super then --Super Storm >:)
		local life = math.Rand(1, math.Clamp(StormPower - Storm_Super, 2, 6)) * 2
		local TorChan = ((StormPower - Storm_Super) / (100 - Storm_Super))^0.6
		
		print("Tornado Chance: "..(math.Round(TorChan*10000)/100).."%") 
	
		
		local rad = math.rad(math.Rand(0,360))
	    local radius = (math.Rand(0,4096))
	    local origin = radius * Vector(math.sin(rad), math.cos(rad), 0)
	    local e = ents.Create("wm_super_storm")
	        e:SetPos(Vector(0,0,5120-4250) + origin)
	        e:Spawn()
			e:Activate()
			
			e.TorChan = TorChan
	        
	    ActiveStorm = true
	end

    if Debugging then
	    print("Storm Severity: "..(math.Round(StormPower*100)/100))
	end
end

--Debugging version
function WMD_CreateStorm(T,H,F) -- F = true to stop it from spawning a stom and just print the values

	StormPower = ( ( ((T/MaxTemp)*0.75) + ((H/MaxHum)*0.25) ) / 1) * 100
	print("Storm Severity: "..(math.Round(StormPower*100)/100))

	if F then return false end

	if StormPower > Storm_Super then --Super Storm >:)
		local rad = math.rad(math.Rand(0,360))
	    local radius = (math.Rand(0,8192))
	    local origin = radius * Vector(math.sin(rad), math.cos(rad), 0)
	    local e = ents.Create("wm_super_storm")
	        e:SetPos(Vector(0,0,5120-4250) + origin)
	        e:Spawn()
			e:Activate()
	        
	    ActiveStorm = true
	end    
end

function WMD_ModStorm(Th, Li)
	local storms = ents.FindByClass("wm_super_storm")
	for k,v in pairs(storms) do
		v.ThunderChance = Th -- out of 1000 --250
		v.LightningChance = Li -- out of 1000 --200	
	end   	
end

function WMD_KillStorm()
	local a = ents.FindByClass("wm_super_storm")
	for k,v in pairs(a) do
		v:Remove()		
	end
	a = ents.FindByClass("wm_wall")
	for k,v in pairs(a) do
		v:Remove()
	end
	a = ents.FindByClass("wm_tornado")
	for k,v in pairs(a) do
		v:Remove()
	end
end

function WMD_ClearActive()
	ActiveStorm = false
end

function WMD_SetTH(T,H)
    Temperature = T
    Humidity = H
end
	AddCSLuaFile()
	AddCSLuaFile( "sh_weather_blacklist.lua" )
	AddCSLuaFile( "cl_weather.lua" )
	
	include( "sh_weather_blacklist.lua" )
	include( "sv_weather.lua" )
	
	resource.AddSingleFile( "sound/weathereffects/wind2.wav" )
	resource.AddSingleFile( "materials/weathereffects/cloud_storm.vtf" )
	resource.AddSingleFile( "materials/weathereffects/cloud_storm2.vtf" )
elseif CLIENT then
	include( "sh_weather_blacklist.lua" )
	include( "cl_weather.lua" )
end

Weather = Weather or {}

Weather.Effects = {}
Weather.Effects["sun"] = { Clouds = nil, CSize = nil, Sound = nil, RandomEffect = nil, RandomClientEffect = nil, HUD = nil, particle = nil, StartFunc = nil, EndFunc = nil}
Weather.Effects["snow"] = { Clouds = "weathereffects/cloud_storm", CSize = 4, Sound = "coast.windmill", HUD = "Effects/splashwake1", HUDMax = 20, HUDMin = 40, particle = "weathersystem_snow", LightMod = (-2) }
Weather.Effects["rain"] = { Clouds = "weathereffects/cloud_storm2", CSize = 4, Sound = "ambient/water/water_flow_loop1.wav", HUD = "Effects/splash1", HUDCol = {200,200,255}, particle = "weathersystem_rain", LightMod = (-1) }
Weather.Effects["storm"] = { Clouds = "weathereffects/cloud_storm2", CSize = 4, Sound = "ambient/water/water_flow_loop1.wav", HUD = "Effects/splash2", HUDCol = {200,200,255}, particle = "weathersystem_storm", LightMod = (-2), RandomSounds = {"ambient/atmosphere/thunder1.wav", "ambient/atmosphere/thunder2.wav", "ambient/atmosphere/thunder3.wav", "ambient/atmosphere/thunder4.wav"},
	RandomClientEffect = function( self )
		timer.Simple( math.Rand(0, 1.5), function() surface.PlaySound( table.Random( self.RandomSounds ) ) end )
	end, RandomEffect = function()
		Weather.SkyPaint:SetKeyValue( "topcolor", "1 1 1" )
		Weather.SkyPaint:SetKeyValue( "bottomcolor", "1 1 1" )
		Weather.SkyPaint:SetKeyValue( "duskcolor", "1 1 1" )
		timer.Simple(0.1, function() Weather.PaintSky() end)
	end}
Weather.Effects["fog"] = { Clouds = nil, CSize = nil, Sound = nil, HUD = nil, particle = nil, LightMod = -1,
	StartFunc = function( self ) hook.Add("SetupWorldFog", "Weather Systems Fog", self.DoFog) hook.Add("SetupSkyboxFog", "Weather Systems Sky Fog", self.DoFog) end,
	EndFunc = function( self ) hook.Remove("SetupWorldFog", "Weather Systems Fog") hook.Remove("SetupSkyboxFog", "Weather Systems Sky Fog") end,
	DoFog = function(scale) render.FogMode( 1 ) render.FogStart( 0 ) render.FogEnd( 1000*(scale or 1) ) render.FogMaxDensity(0.7) render.FogColor(140,140,150) return true end}


local function WeatherSystemInit()
	if Weather.Blacklisted and Weather.Blacklisted.time then return end
	
	RunConsoleCommand( "sv_skyname", "painted" )
end
hook.Add( "Initialize", "Weather System Initialise", WeatherSystemInit )