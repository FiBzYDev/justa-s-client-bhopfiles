-- "gamemodes\\bhop\\gamemode\\essential\\sh_utilities.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--[[-------------------------------------------------------------------------
	Bunny Hop 
		by: justa (www.steamcommunity.com/id/just_adam)

		file: essential/sh_utilities.lua
		desc: Functions that come in handy in most scenarios.
---------------------------------------------------------------------------]]

-- Globalize
UTIL = {}

-- Draw Zone 
local normal = Material( _C.MaterialID .. "/timer.png" )
function UTIL:DrawZone(min, max, colour, fill, pos)
	-- Our Sets
	local set1 = {Vector(min.x, min.y, min.z), Vector(min.x, max.y, min.z), Vector(max.x, max.y, min.z), Vector(max.x, min.y, min.z)}
	local set2 = {Vector(min.x, min.y, max.z), Vector(min.x, max.y, max.z), Vector(max.x, max.y, max.z), Vector(max.x, min.y, max.z)} 
	local width = 1

	-- Draw
	if (not fill) then 
		render.SetMaterial(normal)
		for i = 1, 4 do
			local i2 = (i == 4 and 1 or i + 1)

			render.DrawBeam(set1[i], set1[i2], width, 0, width, colour)
			render.DrawBeam(set2[i], set2[i2], width, 0, width, colour)
			render.DrawBeam(set1[i], set2[i], width, 0, width, colour)
		end 
	else 
		render.DrawBox(pos, Angle(0, 0, 0), min, max, colour)
	end
end

cache_player_names = {}
function UTIL:GetPlayerName(x)
	if type(x) == 'string' then 
		x = util.SteamIDTo64(x)
	end 

    if cache_player_names[x] then 
        return cache_player_names[x]
    else 
		cache_player_names[x] = "Loading..."
		
        steamworks.RequestPlayerInfo(x, function(name)
            cache_player_names[x] = name 
		end)
		
        return cache_player_names[x]
    end 
end 


if CLIENT then 
	NETWORK:GetNetworkMessage("ChatMessage", function(c, data)
		local pref = data[1]
		local msg = data[2]
		UTIL:AddMessage(pref, unpack(msg))
	end)

	NETWORK:GetNetworkMessage("ConsoleMessage", function(c, data)
		local pref = data[1]
		local msg = data[2]
		UTIL:AddConsoleMessage(pref, unpack(msg))
	end)
end

-- Add message
UTIL.Colour = {
	["Timer"] = Color(0, 132, 255),
	["General"] = Color( 52, 152, 219 ),
	["Admin"] = Color(244, 66, 66),
	["Notification"] = Color( 231, 76, 60 ),
	["Radio"] = Color( 230, 126, 34 ),
	["VIP"] = Color( 174, 0, 255 ),
	["Server"] = Color( 255, 101, 0 ),
	["jAntiCheat"] = Color(186, 85, 211)
}
function UTIL:AddMessage(prefix, ...)
	if not prefix then 
		chat.AddText(color_white, ...)
		return
	end

	local c = self.Colour[prefix]
	chat.AddText(c, prefix, Color(200, 200, 200), " | ", color_white, ...)
end

function UTIL:AddConsoleMessage(prefix, ...)
	if not prefix then 
		MsgC(color_white, ...)
		return
	end

	local c = self.Colour[prefix]
	MsgC(c, prefix, Color(200, 200, 200), " | ", color_white, ...)
end

if SERVER then 
	function UTIL:Print(target, prefix, ...)
		local msg = {...} 
		NETWORK:StartNetworkMessage(target, "ChatMessage", prefix, msg)
	end

	function UTIL:AddConsole(target, prefix, ...)
		local msg = {...} 
		NETWORK:StartNetworkMessage(target, "ConsoleMessage", prefix, msg)
	end
end

-- Drawing a blurred rectangle
local blur = Material("pp/blurscreen")
function UTIL:DrawBlurRect(x, y, w, h, rep, c)
	for i = 1, rep do 
		surface.SetMaterial(blur)	
		surface.SetDrawColor(c or Color(255, 255, 255, 255))
		blur:SetFloat("$blur", 3)
		render.UpdateScreenEffectTexture()
		surface.SetMaterial(blur)
		surface.DrawTexturedRect(x, y, w, h)
	end
end

function UTIL:Notify(c, p, m)
	MsgC(c, "[", p, "] ", color_white, m, "\n")
end

function UTIL:FindValueInTable(var, tab)
	for k, v in pairs(tab) do 
		if var == v then 
			return k 
		end 
	end 

	return false 
end 

local COUNTRY_CODE = {}
COUNTRY_CODE["AF"] = "Afghanistan"
COUNTRY_CODE["AX"] = "Åland Islands"
COUNTRY_CODE["AL"] = "Albania"
COUNTRY_CODE["DZ"] = "Algeria"
COUNTRY_CODE["AS"] = "American Samoa"
COUNTRY_CODE["AD"] = "Andorra"
COUNTRY_CODE["AO"] = "Angola"
COUNTRY_CODE["AI"] = "Anguilla"
COUNTRY_CODE["AQ"] = "Antarctica"
COUNTRY_CODE["AG"] = "Antigua and Barbuda"
COUNTRY_CODE["AR"] = "Argentina"
COUNTRY_CODE["AM"] = "Armenia"
COUNTRY_CODE["AW"] = "Aruba"
COUNTRY_CODE["AU"] = "Australia"
COUNTRY_CODE["AT"] = "Austria"
COUNTRY_CODE["AZ"] = "Azerbaijan"
COUNTRY_CODE["BS"] = "Bahamas"
COUNTRY_CODE["BH"] = "Bahrain"
COUNTRY_CODE["BD"] = "Bangladesh"
COUNTRY_CODE["BB"] = "Barbados"
COUNTRY_CODE["BY"] = "Belarus"
COUNTRY_CODE["BE"] = "Belgium"
COUNTRY_CODE["BZ"] = "Belize"
COUNTRY_CODE["BJ"] = "Benin"
COUNTRY_CODE["BM"] = "Bermuda"
COUNTRY_CODE["BT"] = "Bhutan"
COUNTRY_CODE["BO"] = "Bolivia, Plurinational State of"
COUNTRY_CODE["BQ"] = "Bonaire, Sint Eustatius and Saba"
COUNTRY_CODE["BA"] = "Bosnia and Herzegovina"
COUNTRY_CODE["BW"] = "Botswana"
COUNTRY_CODE["BV"] = "Bouvet Island"
COUNTRY_CODE["BR"] = "Brazil"
COUNTRY_CODE["IO"] = "British Indian Ocean Territory"
COUNTRY_CODE["BN"] = "Brunei Darussalam"
COUNTRY_CODE["BG"] = "Bulgaria"
COUNTRY_CODE["BF"] = "Burkina Faso"
COUNTRY_CODE["BI"] = "Burundi"
COUNTRY_CODE["KH"] = "Cambodia"
COUNTRY_CODE["CM"] = "Cameroon"
COUNTRY_CODE["CA"] = "Canada"
COUNTRY_CODE["CV"] = "Cape Verde"
COUNTRY_CODE["KY"] = "Cayman Islands"
COUNTRY_CODE["CF"] = "Central African Republic"
COUNTRY_CODE["TD"] = "Chad"
COUNTRY_CODE["CL"] = "Chile"
COUNTRY_CODE["CN"] = "China"
COUNTRY_CODE["CX"] = "Christmas Island"
COUNTRY_CODE["CC"] = "Cocos (Keeling) Islands"
COUNTRY_CODE["CO"] = "Colombia"
COUNTRY_CODE["KM"] = "Comoros"
COUNTRY_CODE["CG"] = "Congo"
COUNTRY_CODE["CD"] = "Congo, the Democratic Republic of the"
COUNTRY_CODE["CK"] = "Cook Islands"
COUNTRY_CODE["CR"] = "Costa Rica"
COUNTRY_CODE["CI"] = "Côte d'Ivoire"
COUNTRY_CODE["HR"] = "Croatia"
COUNTRY_CODE["CU"] = "Cuba"
COUNTRY_CODE["CW"] = "Curaçao"
COUNTRY_CODE["CY"] = "Cyprus"
COUNTRY_CODE["CZ"] = "Czech Republic"
COUNTRY_CODE["DK"] = "Denmark"
COUNTRY_CODE["DJ"] = "Djibouti"
COUNTRY_CODE["DM"] = "Dominica"
COUNTRY_CODE["DO"] = "Dominican Republic"
COUNTRY_CODE["EC"] = "Ecuador"
COUNTRY_CODE["EG"] = "Egypt"
COUNTRY_CODE["SV"] = "El Salvador"
COUNTRY_CODE["GQ"] = "Equatorial Guinea"
COUNTRY_CODE["ER"] = "Eritrea"
COUNTRY_CODE["EE"] = "Estonia"
COUNTRY_CODE["ET"] = "Ethiopia"
COUNTRY_CODE["FK"] = "Falkland Islands (Malvinas)"
COUNTRY_CODE["FO"] = "Faroe Islands"
COUNTRY_CODE["FJ"] = "Fiji"
COUNTRY_CODE["FI"] = "Finland"
COUNTRY_CODE["FR"] = "France"
COUNTRY_CODE["GF"] = "French Guiana"
COUNTRY_CODE["PF"] = "French Polynesia"
COUNTRY_CODE["TF"] = "French Southern Territories"
COUNTRY_CODE["GA"] = "Gabon"
COUNTRY_CODE["GM"] = "Gambia"
COUNTRY_CODE["GE"] = "Georgia"
COUNTRY_CODE["DE"] = "Germany"
COUNTRY_CODE["GH"] = "Ghana"
COUNTRY_CODE["GI"] = "Gibraltar"
COUNTRY_CODE["GR"] = "Greece"
COUNTRY_CODE["GL"] = "Greenland"
COUNTRY_CODE["GD"] = "Grenada"
COUNTRY_CODE["GP"] = "Guadeloupe"
COUNTRY_CODE["GU"] = "Guam"
COUNTRY_CODE["GT"] = "Guatemala"
COUNTRY_CODE["GG"] = "Guernsey"
COUNTRY_CODE["GN"] = "Guinea"
COUNTRY_CODE["GW"] = "Guinea-Bissau"
COUNTRY_CODE["GY"] = "Guyana"
COUNTRY_CODE["HT"] = "Haiti"
COUNTRY_CODE["HM"] = "Heard Island and McDonald Islands"
COUNTRY_CODE["VA"] = "Holy See (Vatican City State)"
COUNTRY_CODE["HN"] = "Honduras"
COUNTRY_CODE["HK"] = "Hong Kong"
COUNTRY_CODE["HU"] = "Hungary"
COUNTRY_CODE["IS"] = "Iceland"
COUNTRY_CODE["IN"] = "India"
COUNTRY_CODE["ID"] = "Indonesia"
COUNTRY_CODE["IR"] = "Iran, Islamic Republic of"
COUNTRY_CODE["IQ"] = "Iraq"
COUNTRY_CODE["IE"] = "Ireland"
COUNTRY_CODE["IM"] = "Isle of Man"
COUNTRY_CODE["IL"] = "Israel"
COUNTRY_CODE["IT"] = "Italy"
COUNTRY_CODE["JM"] = "Jamaica"
COUNTRY_CODE["JP"] = "Japan"
COUNTRY_CODE["JE"] = "Jersey"
COUNTRY_CODE["JO"] = "Jordan"
COUNTRY_CODE["KZ"] = "Kazakhstan"
COUNTRY_CODE["KE"] = "Kenya"
COUNTRY_CODE["KI"] = "Kiribati"
COUNTRY_CODE["KP"] = "Korea, Democratic People's Republic of"
COUNTRY_CODE["KR"] = "Korea, Republic of"
COUNTRY_CODE["KW"] = "Kuwait"
COUNTRY_CODE["KG"] = "Kyrgyzstan"
COUNTRY_CODE["LA"] = "Lao People's Democratic Republic"
COUNTRY_CODE["LV"] = "Latvia"
COUNTRY_CODE["LB"] = "Lebanon"
COUNTRY_CODE["LS"] = "Lesotho"
COUNTRY_CODE["LR"] = "Liberia"
COUNTRY_CODE["LY"] = "Libya"
COUNTRY_CODE["LI"] = "Liechtenstein"
COUNTRY_CODE["LT"] = "Lithuania"
COUNTRY_CODE["LU"] = "Luxembourg"
COUNTRY_CODE["MO"] = "Macao"
COUNTRY_CODE["MK"] = "Macedonia, the former Yugoslav Republic of"
COUNTRY_CODE["MG"] = "Madagascar"
COUNTRY_CODE["MW"] = "Malawi"
COUNTRY_CODE["MY"] = "Malaysia"
COUNTRY_CODE["MV"] = "Maldives"
COUNTRY_CODE["ML"] = "Mali"
COUNTRY_CODE["MT"] = "Malta"
COUNTRY_CODE["MH"] = "Marshall Islands"
COUNTRY_CODE["MQ"] = "Martinique"
COUNTRY_CODE["MR"] = "Mauritania"
COUNTRY_CODE["MU"] = "Mauritius"
COUNTRY_CODE["YT"] = "Mayotte"
COUNTRY_CODE["MX"] = "Mexico"
COUNTRY_CODE["FM"] = "Micronesia, Federated States of"
COUNTRY_CODE["MD"] = "Moldova, Republic of"
COUNTRY_CODE["MC"] = "Monaco"
COUNTRY_CODE["MN"] = "Mongolia"
COUNTRY_CODE["ME"] = "Montenegro"
COUNTRY_CODE["MS"] = "Montserrat"
COUNTRY_CODE["MA"] = "Morocco"
COUNTRY_CODE["MZ"] = "Mozambique"
COUNTRY_CODE["MM"] = "Myanmar"
COUNTRY_CODE["NA"] = "Namibia"
COUNTRY_CODE["NR"] = "Nauru"
COUNTRY_CODE["NP"] = "Nepal"
COUNTRY_CODE["NL"] = "Netherlands"
COUNTRY_CODE["NC"] = "New Caledonia"
COUNTRY_CODE["NZ"] = "New Zealand"
COUNTRY_CODE["NI"] = "Nicaragua"
COUNTRY_CODE["NE"] = "Niger"
COUNTRY_CODE["NG"] = "Nigeria"
COUNTRY_CODE["NU"] = "Niue"
COUNTRY_CODE["NF"] = "Norfolk Island"
COUNTRY_CODE["MP"] = "Northern Mariana Islands"
COUNTRY_CODE["NO"] = "Norway"
COUNTRY_CODE["OM"] = "Oman"
COUNTRY_CODE["PK"] = "Pakistan"
COUNTRY_CODE["PW"] = "Palau"
COUNTRY_CODE["PS"] = "Palestine, State of"
COUNTRY_CODE["PA"] = "Panama"
COUNTRY_CODE["PG"] = "Papua New Guinea"
COUNTRY_CODE["PY"] = "Paraguay"
COUNTRY_CODE["PE"] = "Peru"
COUNTRY_CODE["PH"] = "Philippines"
COUNTRY_CODE["PN"] = "Pitcairn"
COUNTRY_CODE["PL"] = "Poland"
COUNTRY_CODE["PT"] = "Portugal"
COUNTRY_CODE["PR"] = "Puerto Rico"
COUNTRY_CODE["QA"] = "Qatar"
COUNTRY_CODE["RE"] = "Réunion"
COUNTRY_CODE["RO"] = "Romania"
COUNTRY_CODE["RU"] = "Russian Federation"
COUNTRY_CODE["RW"] = "Rwanda"
COUNTRY_CODE["BL"] = "Saint Barthélemy"
COUNTRY_CODE["SH"] = "Saint Helena, Ascension and Tristan da Cunha"
COUNTRY_CODE["KN"] = "Saint Kitts and Nevis"
COUNTRY_CODE["LC"] = "Saint Lucia"
COUNTRY_CODE["MF"] = "Saint Martin (French part)"
COUNTRY_CODE["PM"] = "Saint Pierre and Miquelon"
COUNTRY_CODE["VC"] = "Saint Vincent and the Grenadines"
COUNTRY_CODE["WS"] = "Samoa"
COUNTRY_CODE["SM"] = "San Marino"
COUNTRY_CODE["ST"] = "Sao Tome and Principe"
COUNTRY_CODE["SA"] = "Saudi Arabia"
COUNTRY_CODE["SN"] = "Senegal"
COUNTRY_CODE["RS"] = "Serbia"
COUNTRY_CODE["SC"] = "Seychelles"
COUNTRY_CODE["SL"] = "Sierra Leone"
COUNTRY_CODE["SG"] = "Singapore"
COUNTRY_CODE["SX"] = "Sint Maarten (Dutch part)"
COUNTRY_CODE["SK"] = "Slovakia"
COUNTRY_CODE["SI"] = "Slovenia"
COUNTRY_CODE["SB"] = "Solomon Islands"
COUNTRY_CODE["SO"] = "Somalia"
COUNTRY_CODE["ZA"] = "South Africa"
COUNTRY_CODE["GS"] = "South Georgia and the South Sandwich Islands"
COUNTRY_CODE["SS"] = "South Sudan"
COUNTRY_CODE["ES"] = "Spain"
COUNTRY_CODE["LK"] = "Sri Lanka"
COUNTRY_CODE["SD"] = "Sudan"
COUNTRY_CODE["SR"] = "Suriname"
COUNTRY_CODE["SJ"] = "Svalbard and Jan Mayen"
COUNTRY_CODE["SZ"] = "Swaziland"
COUNTRY_CODE["SE"] = "Sweden"
COUNTRY_CODE["CH"] = "Switzerland"
COUNTRY_CODE["SY"] = "Syrian Arab Republic"
COUNTRY_CODE["TW"] = "Taiwan, Province of China"
COUNTRY_CODE["TJ"] = "Tajikistan"
COUNTRY_CODE["TZ"] = "Tanzania, United Republic of"
COUNTRY_CODE["TH"] = "Thailand"
COUNTRY_CODE["TL"] = "Timor-Leste"
COUNTRY_CODE["TG"] = "Togo"
COUNTRY_CODE["TK"] = "Tokelau"
COUNTRY_CODE["TO"] = "Tonga"
COUNTRY_CODE["TT"] = "Trinidad and Tobago"
COUNTRY_CODE["TN"] = "Tunisia"
COUNTRY_CODE["TR"] = "Turkey"
COUNTRY_CODE["TM"] = "Turkmenistan"
COUNTRY_CODE["TC"] = "Turks and Caicos Islands"
COUNTRY_CODE["TV"] = "Tuvalu"
COUNTRY_CODE["UG"] = "Uganda"
COUNTRY_CODE["UA"] = "Ukraine"
COUNTRY_CODE["AE"] = "United Arab Emirates"
COUNTRY_CODE["GB"] = "The United Kingdom"
COUNTRY_CODE["US"] = "The United States"
COUNTRY_CODE["UM"] = "United States Minor Outlying Islands"
COUNTRY_CODE["UY"] = "Uruguay"
COUNTRY_CODE["UZ"] = "Uzbekistan"
COUNTRY_CODE["VU"] = "Vanuatu"
COUNTRY_CODE["VE"] = "Venezuela, Bolivarian Republic of"
COUNTRY_CODE["VN"] = "Viet Nam"
COUNTRY_CODE["VG"] = "Virgin Islands, British"
COUNTRY_CODE["VI"] = "Virgin Islands, U.S."
COUNTRY_CODE["WF"] = "Wallis and Futuna"
COUNTRY_CODE["EH"] = "Western Sahara"
COUNTRY_CODE["YE"] = "Yemen"
COUNTRY_CODE["ZM"] = "Zambia"
COUNTRY_CODE["ZW"] = "Zimbabwe"

function UTIL:GetCountry(code)
	if not COUNTRY_CODE[code] then return "Unknown" end 
	return COUNTRY_CODE[code]
end

function UTIL:FindPlayer(name)
	name = string.lower(name)
	players = {}

	for player_id, player_ent in pairs(player.GetAll()) do 
		local player_name = string.lower(player_ent:Name())
		if string.match(player_name, string.PatternSafe(name)) ~= nil then 
			table.insert(players, player_ent)
		end
	end

	-- No players
	if (#players == 0) then 
		return false end 

	return (#players == 1 and players[1] or players)
end 