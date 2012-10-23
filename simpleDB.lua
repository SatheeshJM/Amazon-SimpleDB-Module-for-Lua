
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
--    This module provides a Lua based API to access Amazon's SimpleDB service
--
--
-- Version : 1.1
--
--	Changelog
--		1.1  Breaking changes from 1.0. Added select operation. Also changed the way SimpleDB operations are performed
--
-- Operations Available 
-- 		GetAttributes
--		PutAttributes
--		DeleteAttributes
--		Select
--
--		CreateDomain 
--		ListDomains	
--		DeleteDomain
--		DomainMetadata
--		
--
-- Major Operations Not supported
--		BatchDeleteAttributes
--		BatchPutAttributes	
--
--	Minor operations not supported (Dunno how often these are used. Feel free to add these functions)
--		Expected parameter(Name,Values and Exists) of GetAttributes
--		Expected parameter(Name,Values and Exists) of PutAttributes
--		Replace in Attribute Parameter of PutAttributes
--		ConsistentRead and nextToken parameters of Select
--		ConsistentRead parameter of GetAttributes
--		
--	



local crypto = require("crypto")
local mime = require("mime")
local xml = require("xml").newParser()

local tostring = tostring 
local os = os 
local pairs = pairs
local string = string 
local setmetatable = setmetatable
local network = network


local MapOfResponseToOperationName = 
		{
		ListDomainsResponse = "LIST_ALL_DOMAINS",
		CreateDomainResponse = "CREATE_DOMAIN",
		DeleteDomainResponse = "DELETE_DOMAIN",
		DomainMetadataResponse = "DOMAIN_METADATA",
		
		PutAttributesResponse = "PUT_ATTRIBUTES",
		GetAttributesResponse = "GET_ATTRIBUTES",
		BatchPutAttributesResponse = "BATCH_PUT_ATTRIBUTES",
		BatchDeleteAttributesResponse = "BATCH_DELETE_ATTRIBUTES",
		DeleteAttributesResponse = "DELETE_ATTRIBTUES",
		
		SelectResponse = "SELECT",
		}
		


local function 
url_encode(str)
  if (str) then
    str = str:gsub("([^%w ])",
        function (c) return string.format ("%%%02X", c:byte()) end)
	str = str:gsub(" ","%%20")
  end
  return str	
end


local function 
twoDigit(n)
    local r = tostring(n)
    if r:len() < 2 then
        r = "0"..r;
    end
    return r
end
 
local function 
getTime()
    local date = os.date("!*t")
    return date.year.."-"..twoDigit(date.month).."-"..twoDigit(date.day).."T"..twoDigit(date.hour).."%3A"..twoDigit(date.min).."%3A"..twoDigit(date.sec).."Z"
end

local function 
sha1_hmac( key, text )
    return crypto.hmac(crypto.sha1, text, key, true)
end





local function parse(xmlData)
	local response = xml:ParseXmlText(xmlData)
	local responseType = response.name 
	
	local operationName = MapOfResponseToOperationName[responseType]
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
	elseif responseType == "SelectResponse" then 
		local SelectResponse = response 
		local SelectResult = response.child[1]
		local ItemNames = SelectResult.child 
		for i=1,#ItemNames do 
			local Item = ItemNames[i]
			local ItemName = Item.child[1].value
			final[ItemName] = {}
			
			for i=2,#Item.child do 
				local NameValuePair = Item.child[i]
				local name = NameValuePair.child[1].value
				local value = NameValuePair.child[2].value
				
				local pair = {name = name,value = value}
				final[ItemName][#final[ItemName]+1] = pair
			end 	
		end 
	else
		final = nil 
	end 
	
	return operationName,final 
end 









local function convertTableToListOfKeyValuePairs(tab,baseTable)
	
	--key may be Attribute or Expected
	
	
	local final = ""
	
	if baseTable == "Attribute" then 
		for i=1,#tab do 
			local order = {"Name","Value"}
			local element = tab[i]
			for j=1,#order do
				local key = order[j]
				local value = element[key]
				if value~=nil then 
					final = final..baseTable.."."..i.."."..key.."="..tostring(value).."&"
				end
			end 
		end 
	elseif baseTable == "AttributeName" then 
		for i=1,#tab do 
			local element = tab[i]
			final = final..baseTable.."."..i.."="..tostring(element).."&"
		end 
	end 
	
	return final 
end 


local function convertTableToKeyValuePairs(tab,type)
	local final = ""
	
	local order 
	if type ==1 then 
		order = {"AWSAccessKeyId","Action","SelectExpression","ConsistentRead","AttributeName","Attribute","DomainName","ItemName","MaxNumberOfDomains","NextToken","SignatureMethod","SignatureVersion","Timestamp","Version"}
	elseif type == 2 then 
		order = {"Action","Attribute","AWSAccessKeyId","SelectExpression","ConsistentRead","AttributeName","DomainName","ItemName","MaxNumberOfDomains","NextToken","SignatureMethod","SignatureVersion","Timestamp","Version"}
	end 
	
	for i=1,#order do 
		local key = order[i]
		local value = tab[key]

		if value~=nil then 
			if key == "Attribute" or key=="AttributeName" then 
				final = final .. convertTableToListOfKeyValuePairs(value,key)
			else
				final = final..key.."="..tostring(value).."&"
			end 
		end
	end 
	
	final = final:sub(1,-2)
	
	return final 
end 


local function generateURL(params)

	params.SignatureMethod = "HmacSHA1"
	params.SignatureVersion = 2
	params.Timestamp = getTime()
	params.Version = "2009-04-15"
	
		
	local sKey = params.AWSSecretKeyId

	--generate Key Value pairs 
	local keyValuePairs1 = convertTableToKeyValuePairs(params,1)
	local keyValuePairs2 = convertTableToKeyValuePairs(params,2)
	
	--generate signature
	local toSign = "GET\nsdb.amazonaws.com\n/\n"..keyValuePairs1
	local signature = mime.b64(sha1_hmac(sKey, toSign)) 
	
	
	--generate url
	local myURL = "https://sdb.amazonaws.com/?"..keyValuePairs2.."&Signature="..signature
	
	
	return myURL
end 












local DB = {}
DB.__index = DB



function DB.newDB(aKey,sKey,listener)
	
	local db = {}
	setmetatable(db,DB)
	
	db.aKey = aKey
	db.sKey = sKey
	db.listener = function(event)

			local isError = event.isError
			local listener = listener or 
								function() end 
			
			if isError then 
				listener{isError = true}
			else 
				event.name,event.result = parse(event.response)
				listener(event)
			end 
	end 
	
	
	return db 
end 




function DB:createDomain(params)

	local params = params or {}
	
	local myURL = generateURL
		{
		AWSAccessKeyId = self.aKey,
		AWSSecretKeyId = self.sKey,
		Action = "CreateDomain",
		DomainName = params.DomainName,
		}
 
    network.request( myURL, "GET", self.listener)
 
end


function DB:listDomains(params)
	
	local params = params or {}
	
	local myURL = generateURL
		{
		AWSAccessKeyId = self.aKey,
		AWSSecretKeyId = self.sKey,
		Action = "ListDomains",
		MaxNumberOfDomains = params.MaxNumberOfDomains,
		NextToken = params.NextToken,
		}
		
		
    network.request( myURL, "GET", self.listener )
 
end


function DB:deleteDomain(params)

	local params = params or {}
	
	local myURL = generateURL
		{
		AWSAccessKeyId = self.aKey,
		AWSSecretKeyId = self.sKey,
		Action = "DeleteDomain",
		DomainName = params.DomainName,
		}
		
    network.request( myURL, "GET", self.listener)
end 



function DB:domainMetaData(params)
	local params = params or {}
	
	local myURL = generateURL
		{
		AWSAccessKeyId = self.aKey,
		AWSSecretKeyId = self.sKey,
		Action = "DomainMetadata",
		DomainName = params.DomainName,
		}
		
    network.request( myURL, "GET", self.listener)
end 




function DB:getAttributes(params)
 
		
	local params = params or {}
	
	
	local myURL = generateURL
		{
		AWSAccessKeyId = self.aKey,
		AWSSecretKeyId = self.sKey,
		Action = "GetAttributes",
		DomainName = params.DomainName,
		ItemName = params.ItemName,
		AttributeName = params.AttributeName,
		ConsistentRead = params.ConsistentRead,
		}

    network.request( myURL, "GET", self.listener )
 
end





function DB:putAttributes(params)


	local params = params or {}
	
	
	local myURL = generateURL
		{
		AWSAccessKeyId = self.aKey,
		AWSSecretKeyId = self.sKey,
		Action = "PutAttributes",
		DomainName = params.DomainName,
		ItemName = params.ItemName,
		Attribute = params.Attribute,
		}
		
    network.request( myURL, "GET", self.listener )


end 



function DB:deleteAttributes(params)

	local params = params or {}
	
	
	local myURL = generateURL
		{
		AWSAccessKeyId = self.aKey,
		AWSSecretKeyId = self.sKey,
		Action = "DeleteAttributes",
		DomainName = params.DomainName,
		ItemName = params.ItemName,
		Attribute = params.Attribute,
		}
		
    network.request( myURL, "GET", self.listener )

end 

function DB:select(params)

	local params = params or {}
	
	local myURL = generateURL
		{
		AWSAccessKeyId = self.aKey,
		AWSSecretKeyId = self.sKey,
		Action = "Select",
		SelectExpression = url_encode(params.SelectExpression),
		ConsistentRead = params.ConsistentRead,
		NextToken = params.NextToken,
		}
		

    network.request( myURL, "GET", self.listener )
end 



return DB


