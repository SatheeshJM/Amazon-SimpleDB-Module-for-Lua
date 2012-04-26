--------------
--INITIALIZE--
--------------

local aKey = "" 						--ACCESS_KEY_ID
local sKey = ""							--SECRET_ACCESS_KEY 
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
-- DB:createDomain(domainName)



--------------------
--LIST ALL DOMAINS--
--------------------
-- DB:listDomains()


-------------------
--DELETE A DOMAIN--
-------------------
-- DB:deleteDomain(domainName)




---------------------
-- DOMAIN META DATA--
---------------------
-- DB:domainMetaData(domainname)



---------------------
--PUT ATTRIBUTES-----
---------------------
local params = 
	{
	domain = "sample",
	item = "jmsatheesh",
	attributes = {email2 = "satheeshrulzz"}
	}

-- DB:putAttributes(params)




------------------
--GET ATTRIBUTES--
------------------
local params = 
	{
	domain = "sample",
	item = "jmsatheesh",
	attributes = {"email2","Hello","bye"},
	}

-- DB:getAttributes(params)



---------------------
--DELETE ATTRIBUTES--
---------------------
local params = 
	{
	domain = "sample",
	item = "jmsatheesh",
	attributes = {email2 = "satheeshrulzz"}
	}

-- DB:deleteAttributes(params)




DB:domainMetaData("sample")