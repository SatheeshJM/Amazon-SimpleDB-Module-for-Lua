--------------
--INITIALIZE--
--------------

local aKey = "" 	--ACCESS_KEY_ID
local sKey = ""		--SECRET_ACCESS_KEY 
local function listener(event)
	print(event.name)
	print(event.response)
	print(event.result)
	
	for i,v in pairs(event.result) do 
		print(i,v)
	end 
	
end

local simpleDB = require "simpleDB"
local DB = simpleDB.newDB(aKey,sKey,listener)


-------------------
--CREATE A DOMAIN--
-------------------
-- DB:createDomain("domainName")



--------------------
--LIST ALL DOMAINS--
--------------------
-- DB:listDomains()


-------------------
--DELETE A DOMAIN--
-------------------
-- DB:deleteDomain("domainName")



---------------------
-- DOMAIN META DATA--
---------------------
-- DB:domainMetaData("domainName")



---------------------
--PUT ATTRIBUTES-----
---------------------
local params = 
	{
	domain = "domainName",
	item = "itemName",
	attributes = {name1 = "value",name2 = "value"}
	}

-- DB:putAttributes(params)




------------------
--GET ATTRIBUTES--
------------------
local params = 
        {
        domain = "domainName",
        item = "itemName",
        attributes = {"name1","name2"},
        }

-- DB:getAttributes(params)



---------------------
--DELETE ATTRIBUTES--
---------------------
local params = 
        {
        domain = "domainName",
        item = "itemName",
        attributes = {name1 = "value",name2 = "value"}
        }

-- DB:deleteAttributes(params)
