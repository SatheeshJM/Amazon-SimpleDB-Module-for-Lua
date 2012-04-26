
--====================================================================--
-- Module: simpleDB   
-- 
--	Thanks to shane.lipscomb. This is a polished version of shane.lipscomb's code.
--  you can find the code here 
--  http://developer.anscamobile.com/forum/2012/02/26/questions-about-amazon-aws-integration#comment-96205
--
-- License:
--
--    Permission is hereby granted, free of charge, to any person obtaining a copy of 
--    this software and associated documentation files (the "Software"), to deal in the 
--    Software without restriction, including without limitation the rights to use, copy, 
--    modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
--    and to permit persons to whom the Software is furnished to do so, subject to the 
--    following conditions:
-- 
--    The above copyright notice and this permission notice shall be included in all copies 
--    or substantial portions of the Software.
-- 
--    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
--    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
--    PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
--    FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
--    OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
--    DEALINGS IN THE SOFTWARE.
--
-- Overview: 
--
--    This module supports access to the Amazon SimpleDB Service, a
--    popular cloud-based storage platform, from Corona SDK applications.
--
--
-- Version : 1.0 
--
-- Operations Available 
-- 		GetAttributes
--		PutAttributes
--		DeleteAttributes
--
--		CreateDomain 
--		ListDomains	
--		DeleteDomain
--		DomainMetadata
--
-- Operations Not Available
--		BatchDeleteAttributes
--		BatchPutAttributes	
--		Select
--	
--
--
--
-- Usage:
--
--
--------------
--INITIALIZE--
--------------

-- local aKey = "" 		--ACCESS_KEY_ID
-- local sKey = ""		--SECRET_ACCESS_KEY 
-- local function listener(event)
	-- print(event.name)
	-- print(event.response)
	-- print(event.result)
-- end

-- local simpleDB = require "simpleDB"
-- local DB = simpleDB.newDB(aKey,sKey,listener)


-------------------
--CREATE A DOMAIN--
-------------------
-- DB:createDomain("hello")



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


----------------------
--PUT ATTRIBUTES------
----------------------
-- local params = 
	-- {
	-- domain = "sample",
	-- item = "jmsatheesh",
	-- attributes = {email2 = "satheeshrulzz"}
	-- }

-- DB:putAttributes(params)




------------------
--GET ATTRIBUTES--
------------------
-- local params = 
	-- {
	-- domain = "sample",
	-- item = "jmsatheesh",
	-- attributes = {"email2","Hello","bye"},
	-- }

-- DB:getAttributes(parameters)



---------------------
--DELETE ATTRIBUTES--
---------------------
-- local params = 
	-- {
	-- domain = "sample",
	-- item = "jmsatheesh",
	-- attributes = {email2 = "satheeshrulzz"}
	-- }

-- DB:deleteAttributes(params)



--
--====================================================================--
--


local crypto = require("crypto")
local mime = require("mime")
local xml = require("xml").newParser()

local tostring = tostring 
local os = os 
local pairs = pairs
local setmetatable = setmetatable
local network = network



local function twoDigit(n)
    local r = tostring(n)
    if r:len() < 2 then
        r = "0"..r;
    end
    return r
end
 
local function getTime()
    local date = os.date("!*t")
    return date.year.."-"..twoDigit(date.month).."-"..twoDigit(date.day).."T"..twoDigit(date.hour).."%3A"..twoDigit(date.min).."%3A"..twoDigit(date.sec).."Z"
end

local function sha1_hmac( key, text )
    return crypto.hmac(crypto.sha1, text, key, true)
end


local function parse(xmlData)
	local response = xml:ParseXmlText(xmlData)
	local responseType = response.name 
	local final = {}
	
	if responseType == "ListDomainsResponse" then 
		local ListDomainsResponse = response
		local ListDomainsResult = ListDomainsResponse.child[1]
		local DomainNames = ListDomainsResult.child
		for i=1,#DomainNames do 
			local DomainName = DomainNames[i]
			if DomainName.name == "DomainName" then 
				final[#final+1] = DomainName.value 
			end 
		end 
	elseif responseType == "GetAttributesResponse" then 
		local GetAttributesResponse = response
		local GetAttributesResult = response.child[1]
		local Attributes = GetAttributesResult.child
		for i=1,#Attributes do 
			local Attribute = Attributes[i]
			if Attribute.name == "Attribute" then 
				local Name = Attribute.child[1].value 
				local Value = Attribute.child[2].value 
				final[Name] = Value 
			end 
		end
	elseif responseType == "DomainMetadataResponse" then 
		local DomainMetadataResponse = response 
		local DomainMetadataResult = response.child[1]
		local MetadataNames = DomainMetadataResult.child 
		for i=1,#MetadataNames do 
			local MetadataName = MetadataNames[i]
			local Name = MetadataName.name 
			local Value = MetadataName.value 
			final[Name] = Value 
		end 
	else 
		final = nil 
	end 
	
	return final 
end 









local DB = {}
DB.__index = DB



function DB.newDB(aKey,sKey,listener)
	
	local db = {}
	setmetatable(db,DB)
	db.aKey = aKey
	db.sKey = sKey
	db.listener = listener
	return db 
end 



function DB:createDomain(name)
	
	local aKey = self.aKey
	local sKey = self.sKey
	
    local timeStamp = getTime()
    local toSign = "GET\nsdb.amazonaws.com\n/\nAWSAccessKeyId="..aKey.."&Action=CreateDomain&DomainName="..name.."&SignatureMethod=HmacSHA1&SignatureVersion=2&Timestamp="..timeStamp.."&Version=2009-04-15"
    local signature = mime.b64(sha1_hmac(sKey, toSign))  
    local myURL = "https://sdb.amazonaws.com/?Action=CreateDomain&AWSAccessKeyId="..aKey.."&DomainName="..name.."&SignatureVersion=2&SignatureMethod=HmacSHA1&Timestamp="..timeStamp.."&Version=2009-04-15&Signature="..signature

    network.request( myURL, "GET", self.listener)
 
end


function DB:listDomains()
	
	local aKey = self.aKey
	local sKey = self.sKey
	
    local timeStamp = getTime()
    local toSign = "GET\nsdb.amazonaws.com\n/\nAWSAccessKeyId="..aKey.."&Action=ListDomains&SignatureMethod=HmacSHA1&SignatureVersion=2&Timestamp="..timeStamp.."&Version=2009-04-15"
    local signature = mime.b64(sha1_hmac(sKey, toSign))  
    local myURL = "https://sdb.amazonaws.com/?Action=ListDomains&AWSAccessKeyId="..aKey.."&SignatureVersion=2&SignatureMethod=HmacSHA1&Timestamp="..timeStamp.."&Version=2009-04-15&Signature="..signature

	
	local function 
	networkListener(event)
		if event.response then 
			event.result = parse(event.response)
		end 
		event.name = "LIST DOMAINS"
		self.listener(event)
	end 
    network.request( myURL, "GET", networkListener )
 
end


function DB:deleteDomain(domain)
	local aKey = self.aKey
	local sKey = self.sKey
	
    local timeStamp = getTime()
    local toSign = "GET\nsdb.amazonaws.com\n/\nAWSAccessKeyId="..aKey.."&Action=DeleteDomain&DomainName="..domain.."&SignatureMethod=HmacSHA1&SignatureVersion=2&Timestamp="..timeStamp.."&Version=2009-04-15"
    local signature = mime.b64(sha1_hmac(sKey, toSign))  
    local myURL = "https://sdb.amazonaws.com/?Action=DeleteDomain&AWSAccessKeyId="..aKey.."&DomainName="..domain.."&SignatureVersion=2&SignatureMethod=HmacSHA1&Timestamp="..timeStamp.."&Version=2009-04-15&Signature="..signature

    network.request( myURL, "GET", self.listener)
end 



function DB:domainMetaData(domain)
	local aKey = self.aKey
	local sKey = self.sKey
	
    local timeStamp = getTime()
    local toSign = "GET\nsdb.amazonaws.com\n/\nAWSAccessKeyId="..aKey.."&Action=DomainMetadata&DomainName="..domain.."&SignatureMethod=HmacSHA1&SignatureVersion=2&Timestamp="..timeStamp.."&Version=2009-04-15"
    local signature = mime.b64(sha1_hmac(sKey, toSign))  
    local myURL = "https://sdb.amazonaws.com/?Action=DomainMetadata&AWSAccessKeyId="..aKey.."&DomainName="..domain.."&SignatureVersion=2&SignatureMethod=HmacSHA1&Timestamp="..timeStamp.."&Version=2009-04-15&Signature="..signature

	
	local function 
	networkListener(event)
		if event.response then 
			event.result = parse(event.response)
		end 
		event.name = "DOMAIN META DATA"
		self.listener(event)
	end 
    network.request( myURL, "GET", networkListener)
end 




function DB:getAttributes(params)
 
	local aKey = self.aKey
	local sKey = self.sKey
	
	local domain = params.domain 
	local item = params.item 
	local attributes = params.attributes or {}
	local attributeString = ""
	
	for i=1,#attributes do
		local str = "&AttributeName."..i.."="..attributes[i]
		attributeString = attributeString..str 
	end 
	
    local timeStamp = getTime()
    local toSign = "GET\nsdb.amazonaws.com\n/\nAWSAccessKeyId="..aKey.."&Action=GetAttributes"..attributeString.."&DomainName="..domain.."&ItemName="..item.."&SignatureMethod=HmacSHA1&SignatureVersion=2&Timestamp="..timeStamp.."&Version=2009-04-15" 
    local signature = mime.b64(sha1_hmac(sKey, toSign))     
    local myURL = "https://sdb.amazonaws.com/?Action=GetAttributes&AWSAccessKeyId="..aKey..attributeString.."&DomainName="..domain.."&ItemName="..item.."&SignatureVersion=2&SignatureMethod=HmacSHA1&Timestamp="..timeStamp.."&Version=2009-04-15&Signature="..signature
    
	
	
	local function 
	networkListener(event)
		if event.response then 
			event.result = parse(event.response)
		end 
		event.name = "GET ATTRIBUTES"
		self.listener(event)
	end 
    network.request( myURL, "GET", networkListener )
 
end





function DB:putAttributes(params)

	local aKey = self.aKey
	local sKey = self.sKey
	
	local domain = params.domain 
	local item = params.item 
	local attributes = params.attributes or {}
	local attributeString = ""
	
	local i=0
	for name,value in pairs(attributes) do
		i=i+1 
		local str = "&Attribute."..i..".Name="..name.."&Attribute."..i..".Value="..value
		attributeString = attributeString..str 
	end 
	
	
	local timeStamp = getTime()
    local toSign = "GET\nsdb.amazonaws.com\n/\nAWSAccessKeyId="..aKey.."&Action=PutAttributes"..attributeString.."&DomainName="..domain.."&ItemName="..item.."&SignatureMethod=HmacSHA1&SignatureVersion=2&Timestamp="..timeStamp.."&Version=2009-04-15"
    local signature = mime.b64(sha1_hmac(sKey, toSign))       
    local myURL = "https://sdb.amazonaws.com/?Action=PutAttributes"..attributeString.."&AWSAccessKeyId="..aKey.."&DomainName="..domain.."&ItemName="..item.."&SignatureVersion=2&SignatureMethod=HmacSHA1&Timestamp="..timeStamp.."&Version=2009-04-15&Signature="..signature


    network.request( myURL, "GET", self.listener )


end 



function DB:deleteAttributes(params)
		local aKey = self.aKey
	local sKey = self.sKey
	
	local domain = params.domain 
	local item = params.item 
	local attributes = params.attributes or {}
	local attributeString = ""
	
	local i=0
	for name,value in pairs(attributes) do
		i=i+1 
		local str = "&Attribute."..i..".Name="..name.."&Attribute."..i..".Value="..value
		attributeString = attributeString..str 
	end 
	
	
	local timeStamp = getTime()
    local toSign = "GET\nsdb.amazonaws.com\n/\nAWSAccessKeyId="..aKey.."&Action=DeleteAttributes"..attributeString.."&DomainName="..domain.."&ItemName="..item.."&SignatureMethod=HmacSHA1&SignatureVersion=2&Timestamp="..timeStamp.."&Version=2009-04-15"
    local signature = mime.b64(sha1_hmac(sKey, toSign))       
    local myURL = "https://sdb.amazonaws.com/?Action=DeleteAttributes"..attributeString.."&AWSAccessKeyId="..aKey.."&DomainName="..domain.."&ItemName="..item.."&SignatureVersion=2&SignatureMethod=HmacSHA1&Timestamp="..timeStamp.."&Version=2009-04-15&Signature="..signature


    network.request( myURL, "GET", self.listener )

end 


return DB


