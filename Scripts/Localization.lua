Global("localization", nil)

Global("Locales", {
	["rus"] = { -- Russian, Win-1251
    ["Avatar"] = "Только объекты активного персонажа",
	},
		
	["eng_eu"] = { -- English, Latin-1
    ["Avatar"] = "Only objects of the active character",
	}
})

--We can now use an official method to get the client language
localization = common.GetLocalization()
function GTL( strTextName )
	return Locales[ localization ][ strTextName ] or Locales[ "eng_eu" ][ strTextName ] or strTextName
end
