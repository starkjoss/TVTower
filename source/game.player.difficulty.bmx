SuperStrict
Import "game.gameobject.bmx"
Import "Dig/base.util.data.bmx"
Import "Dig/base.util.data.xmlstorage.bmx"


Type TPlayerDifficultyCollection Extends TGameObjectCollection
	Field _initializedDefaults:int = False {nosave} 'initialize each time
	Global _instance:TPlayerDifficultyCollection


	Function GetInstance:TPlayerDifficultyCollection()
		if not _instance then _instance = new TPlayerDifficultyCollection

		return _instance
	End Function


	Method InitializeDefaults:int()
		Local dataLoader:TDataXmlStorage = New TDataXmlStorage
		dataLoader.setRootNodeKey("difficulties")
		local difficultyConfig:TData = dataLoader.Load("config/gamesettings/default.xml")

		local easy:TPlayerDifficulty = ReadDifficultyData("easy", difficultyConfig)
		local normal:TPlayerDifficulty = ReadDifficultyData("normal", difficultyConfig)
		local hard:TPlayerDifficulty = ReadDifficultyData("hard", difficultyConfig)
		Add(easy)
		Add(normal)
		Add(hard)

		_initializedDefaults = True

		Function ReadDifficultyData:TPlayerDifficulty(level:String, data:TData)
			local result:TPlayerDifficulty = new TPlayerDifficulty
			local spec:TData=data.getData(level)
			local def:TData=data.getData("defaults")
			if not spec then spec = def 'level info may be empty -> spec=null

			result.SetGUID(level)
			result.startMoney = ReadInt("startMoney", spec, def, 0, 5000000)
			result.startCredit = ReadInt("startCredit", spec, def, 0, 5000000)
			result.creditMaximum = ReadInt("creditMaximum", spec, def, 0, 10000000)
			result.programmePriceMod = ReadFloat("programmePriceMod", spec, def, 0.1, 5.0)
			result.roomRentMod = ReadFloat("roomRentMod", spec, def, 0.1, 5.0)
			result.adContractPricePerSpotMax = ReadInt("adContractPricePerSpotMax", spec, def, 500000, 50000000)
			result.adcontractPriceMod = ReadFloat("adcontractPriceMod", spec, def, 0.1, 5.0)
			result.adcontractProfitMod = ReadFloat("adcontractProfitMod", spec, def, 0.1, 5.0)
			result.adcontractPenaltyMod = ReadFloat("adcontractPenaltyMod", spec, def, 0.1, 5.0)
			result.adcontractInfomercialProfitMod = ReadFloat("adcontractInfomercialProfitMod", spec, def, 0.1, 5.0)
			result.adcontractLimitedTargetgroupMod = ReadFloat("adcontractLimitedTargetgroupMod", spec, def, 0.1, 5.0)
			result.adcontractLimitedGenreMod = ReadFloat("adcontractLimitedGenreMod", spec, def, 0.1, 5.0)
			result.adcontractLimitedProgrammeFlagMod = ReadFloat("adcontractLimitedProgrammeFlagMod", spec, def, 0.1, 5.0)
			result.adcontractRawMinAudienceMod = ReadFloat("adcontractRawMinAudienceMod", spec, def, 0.1, 5.0)

			result.antennaBuyPriceMod = ReadFloat("antennaBuyPriceMod", spec, def, 0.1, 5.0)
			result.antennaConstructionTime = ReadInt("antennaConstructionTime", spec, def, 0, 10)
			result.antennaDailyCostsMod = ReadFloat("antennaDailyCostsMod", spec, def, 0.1, 5)
			result.antennaDailyCostsIncrease = ReadFloat("antennaDailyCostsIncrease", spec, def, 0.0, 0.5)
			result.antennaDailyCostsIncreaseMax = ReadFloat("antennaDailyCostsIncreaseMax", spec, def, 0.0, 5.0)
			result.cableNetworkBuyPriceMod = ReadFloat("cableNetworkBuyPriceMod", spec, def, 0.1, 5.0)
			result.cableNetworkConstructionTime = ReadInt("cableNetworkConstructionTime", spec, def, 0, 10)
			result.cableNetworkDailyCostsMod = ReadFloat("cableNetworkDailyCostsMod", spec, def, 0.1, 5)
			result.satelliteBuyPriceMod = ReadFloat("satelliteBuyPriceMod", spec, def, 0.1, 5.0)
			result.satelliteConstructionTime = ReadInt("satelliteConstructionTime", spec, def, 0, 10)
			result.satelliteDailyCostsMod = ReadFloat("satelliteDailyCostsMod", spec, def, 0.1, 5)
			result.broadcastPermissionPriceMod = ReadFloat("broadcastPermissionPriceMod", spec, def, 0.1, 5.0)
			result.adjustRestartingPlayersToOtherPlayersMod = ReadFloat("adjustRestartingPlayersToOtherPlayersMod", spec, def, 0.1, 2.0)
			return result
		End Function
		Function ReadInt:Int(key:String, spec:TData, def:TData, minValue:Int, maxValue:Int)
			local result:Int = spec.getInt(key, def.getInt(key))
			result = Min(Max(minValue,result),maxValue)
			return result
		End Function
		Function ReadFloat:Float(key:String, spec:TData, def:TData, minValue:Float, maxValue:Float)
			local result:Float = spec.getFloat(key, def.getInt(key))
			result = Min(Max(minValue,result),maxValue)
			return result
		End Function
	End Method


	Method GetByGUID:TPlayerDifficulty(GUID:String)
		'setup easy/normal/hard with current-versions-data
		'this will override potentially "loaded" variants
		'from savegames
		if not _initializedDefaults then InitializeDefaults()

		local diff:TPlayerDifficulty = TPlayerDifficulty( Super.GetByGUID(GUID) )
		'fall back to "normal" if requested (maybe individual) was not found
		'-> eg. older savegames without difficulty stored
		if not diff then diff = TPlayerDifficulty( Super.GetByGUID("normal") )

		return diff
	End Method


	Method AddToPlayer:int(playerID:int, difficulty:TPlayerDifficulty)
		entries.Insert(string(playerID), difficulty)
	End Method
End Type

'===== CONVENIENCE ACCESSOR =====
'return collection instance
Function GetPlayerDifficultyCollection:TPlayerDifficultyCollection()
	Return TPlayerDifficultyCollection.GetInstance()
End Function


Function GetPlayerDifficulty:TPlayerDifficulty(GUID:string)
	Return TPlayerDifficultyCollection.GetInstance().GetByGUID(GUID)
End Function




Type TPlayerDifficulty extends TGameObject
	Field startMoney:int
	Field startCredit:int
	Field creditMaximum:int
	Field programmePriceMod:Float = 1.0
	Field roomRentmod:Float = 1.0
	Field adContractPricePerSpotMax:int
	Field adcontractPriceMod:Float
	Field adcontractProfitMod:Float
	Field adcontractPenaltyMod:Float
	Field adcontractInfomercialProfitMod:Float
	Field adcontractLimitedTargetgroupMod:Float
	Field adcontractLimitedGenreMod:Float
	Field adcontractLimitedProgrammeFlagMod:Float
	Field adcontractRawMinAudienceMod:Float
	Field antennaBuyPriceMod:Float
	Field antennaConstructionTime:int
	Field antennaDailyCostsMod:Float
	Field antennaDailyCostsIncrease:Float
	Field antennaDailyCostsIncreaseMax:Float
	Field cableNetworkBuyPriceMod:Float
	Field cableNetworkConstructionTime:int
	Field cableNetworkDailyCostsMod:Float
	Field satelliteBuyPriceMod:Float
	Field satelliteConstructionTime:int
	Field satelliteDailyCostsMod:Float
	Field broadcastPermissionPriceMod:Float
	Field adjustRestartingPlayersToOtherPlayersMod:Float = 1.0

	Method GenerateGUID:string()
		return "playerdifficulty-"+id
	End Method
End Type
