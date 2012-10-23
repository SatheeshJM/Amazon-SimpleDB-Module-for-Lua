
--AWS Security Credentials

local aKey = "ACCESS_KEY_ID_HERE" 	--ACCESS_KEY_ID
local sKey = "SECRET_ACCESS_KEY_HERE"	--SECRET_ACCESS_KEY 


--Listener Function 

local function listener(event)
				
	--event.response		-- The actual Response from Amazon
	--event.isError			-- Network error if any 
	--event.name			-- The name of the operation(nil if amazon throws an error)
	
	--event.result			
	--This parameter is for select(), listDomains(), getAttributes() and domainMetaData() operations only
	--XML data returned by Amazon is parsed by the lua library and is stored as a table 
	--use pairs to iterate through event result to see what values have been returned 	
	--this value is nil for other operations. It is also nil if the supported operations fail.
		
	print(event.name)
	if event.result then 
		for i,v in pairs(event.result) do print(i,v) end 
	end 	
end



local simpleDB = require "simpleDB"
local DB = simpleDB.newDB(aKey,sKey,listener)


-------------------
--CREATE A DOMAIN--
-------------------

-- DB:createDomain	
	-- {
	-- DomainName = "domain_name"	
	-- }
	


--------------------
--LIST ALL DOMAINS--
--------------------	
	
-- DB:listDomains
	-- {
	-- MaxNumberOfDomains = 100,	--[OPTIONAL]
	-- nextToken = "next_token"		--[OPTIONAL]
	-- }

	
	
	
-------------------
--DELETE A DOMAIN--
-------------------

-- DB:deleteDomain	
	-- {
	-- DomainName = "domain_name"	
	-- }

	
	
	
---------------------
-- DOMAIN META DATA--
---------------------

-- DB:domainMetaData
-- {
-- DomainName = "domain_name"
-- }



	
---------------------
--PUT ATTRIBUTES-----
---------------------


-- local Attribute = 
	-- {
	-- {Name = "name1",Value="value11"},
	-- {Name = "name2",Value="value21"},
	-- {Name = "name3",Value="value31"},
	-- {Name = "name4",Value="value41"},
	-- }


-- DB:putAttributes
	-- {
	-- DomainName = "domain_name",
	-- ItemName = "item_name",
	-- Attribute = Attribute,
	-- }
	

	
	
	
------------------
--GET ATTRIBUTES--
------------------

-- local AttributeName = 
	-- {
	-- "name1",
	-- "name2",
	-- "name3",
	-- "name4",
	-- }


-- DB:getAttributes
	-- {
	-- DomainName = "domain_name",
	-- ItemName = "item_name",
	-- AttributeName = AttributeName,--[OPTIONAL]
	-- }
	


	
	
	
	
---------------------
--DELETE ATTRIBUTES--
---------------------

-- local Attribute = 
	-- {
	-- {Name = "name1",Value="value1"},
	-- }


-- DB:deleteAttributes
	-- {
	-- DomainName = "domain_name",
	-- ItemName = "item_name",
	-- Attribute = Attribute,	--[OPTIONAL]
	-- }
	



	
------------------
--SELECT--------
----------------

-- local SelectExpression = "select * from domainName"
-- DB:select 
	-- {
	-- SelectExpression = SelectExpression,
	-- }

	


