--------------
--INITIALIZE--
--------------

local aKey = "" 	--ACCESS_KEY_ID
local sKey = ""		--SECRET_ACCESS_KEY 
local function listener(event)
				
	print(event.response)		--Response from Amazon
	
	--Following parameters for listDomains(), getAttributes() and domainMetaData() only
	print(event.result)			--Data returned by Amazon.  If failure, event.response is nil
	print(event.name)			--"LIST DOMAINS", "DOMAIN META DATA" or "GET ATTRIBUTES"
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
