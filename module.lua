local module = {}
--SETTINGS

local FireStoreProjectId = "" --Project ID
local AuthServer = "" --Auth Server URL providing the Bearer Token
local ServerTokenKey = "" --A key for your server
--END OF SETTINGS

--DEF
local baseurl =
	"https://firestore.googleapis.com/v1beta1/projects/" .. FireStoreProjectId .. "/databases/(default)/documents"
local parenturl = "https://firestore.googleapis.com/v1beta1/projects/" .. FireStoreProjectId .. "/databases/(default)"
local https = game:GetService("HttpService")
local translatetypes = {
	["string"] = "stringValue",
	["boolean"] = "booleanValue",
	["number"] = "doubleValue",
	["table"] = "mapValue"
}
local translateop = {
	["<"] = "LESS_THAN",
	["<="] = "LESS_THAN_OR_EQUAL",
	[">"] = "GREATER_THAN",
	[">="] = "GREATER_THAN_OR_EQUAL",
	["="] = "EQUAL",
	["~="] = "NOT_EQUAL"
}
--END DEF
function module.Auth()
	local http = game:GetService("HttpService")
	local success, err =
		pcall(
			function()
			local body = {
						["key"] = ServerTokenKey
							}
			local parsed = http:JSONEncode(body)
			res = http:PostAsync(AuthServer,parsed, Enum.HttpContentType.ApplicationJson, false)
		end
		)
	if success then
		module.token = res
		return res
	end
	if err then
		return err
	end
end

function module.Get(datastore, key) --See https://firebase.google.com/docs/firestore/reference/rest/v1beta1/projects.databases.documents/get
	if(module.token == nil) then
	warn("Auth Token is nil")
	return false,"token"
	end
	local response = nil
	local url = baseurl .. "/" .. datastore .. "/" .. key
	local success, err =
		pcall(
			function()
			response = https:GetAsync(url,false,{["Authorization"] = "Bearer ".. module.token})
		end
		)
	if success then
		local data = https:JSONDecode(response)
		return data
		--returns the data
	end
	if err then
		return err
	end
end

function module.Set(Datastore, key, data) --See https://firebase.google.com/docs/firestore/reference/rest/v1beta1/projects.databases.documents/patch
	if(module.token == nil) then
		warn("Auth Token is nil")
		return false,"token"
	end
	local response = nil
	local body = https:JSONEncode(data)
	local url = baseurl .. "/" .. Datastore .. "/" .. key
	local success, err =
		pcall(
			function()
			response =
				https:PostAsync(
					url,
					body,
					Enum.HttpContentType.ApplicationJson,
					false,
					{["X-HTTP-Method-Override"] = "PATCH",["Authorization"] = "Bearer ".. module.token
						}
				)
		end
		)
	if success then
		local rt = https:JSONDecode(response)
		return rt
		--returns the document that was updated
	end
	if err then
		return err
	end
end

function module.Delete(Datastore, key) --See https://firebase.google.com/docs/firestore/reference/rest/v1beta1/projects.databases.documents/delete
	if(module.token == nil) then
		warn("Auth Token is nil")
		return
	end
	local response = nil
	local url = baseurl .. "/" .. Datastore .. "/" .. key
	local success, err =
		pcall(
			function()
			response =
				https:PostAsync(
					url,
					{},
					Enum.HttpContentType.ApplicationJson,
					false,
					{["X-HTTP-Method-Override"] = "DELETE",["Authorization"] = "Bearer ".. module.token}
				)
		end
		)
	if success then
		return response --Will be empty if succes
	end
	if err then
		return err
	end
end

function module.BatchGet(Datastore, keysarray) --See https://firebase.google.com/docs/firestore/reference/rest/v1beta1/projects.databases.documents/batchGet
	if(module.token == nil) then
		warn("Auth Token is nil")
		return
	end
	local response = nil
	local pathsarray = {}
	for i, v in pairs(keysarray) do
		table.insert(
			pathsarray,
			"projects/" .. FireStoreProjectId .. "/databases/(default)/documents/" .. Datastore .. "/" .. v
		)
	end
	local body = {
		["documents"] = pathsarray
	}
	local data = https:JSONEncode(body)
	local url = parenturl .. "/documents:batchGet"
	local success, err =
		pcall(
			function()
			response = https:PostAsync(url, data,Enum.HttpContentType.ApplicationJson,false,{["Authorization"] = "Bearer ".. module.token})
		end
		)
	if success then
		return response --Returns a json object with an array of documents
	end
	if err then
		return err
	end
end

function module.query(Datastore, filterfield, filtervalue, op, orderdirection, orderfield)
	if(module.token == nil) then
		warn("Auth Token is nil")
		return
	end
	local opt = translateop[op]
	local ty = translatetypes[typeof(filtervalue)]
	if typeof(filtervalue) == "number" then
		if filtervalue == math.floor(filtervalue) then
			ty = "integerValue"
		else
			ty = "doubleValue"
		end
	end
	if orderdirection == nil or orderdirection == "" then
		orderdirection = "DIRECTION_UNSPECIFIED"
	end
	local url = parenturl .. "/documents/:runQuery"
	local body = {
		["structuredQuery"] = {
			["where"] = {
				["fieldFilter"] = {
					["field"] = {["fieldPath"] = filterfield},
					["op"] = opt,
					["value"] = {[ty] = filtervalue}
				}
			},
			["from"] = {{["collectionId"] = Datastore}, ["allDescendants"] = true},
			["orderBy"] = {{["field"] = {["fieldPath"] = orderfield}, ["direction"] = orderdirection}}
		}
	}

	local data = https:JSONEncode(body)
	local success, err =
		pcall(
			function()
			response = https:PostAsync(url, data,Enum.HttpContentType,false,{["Authorization"] = "Bearer ".. module.token})
		end
		)
	if success then
		local r = https:JSONDecode(response)
		return r --Returns a json object with an array of documents
	end
	if err then
		return err
	end
end

function module.UpdateFields(Datastore, key, data)
	if(module.token == nil) then
		warn("Auth Token is nil")
		return
	end
	local response = nil
	local body = https:JSONEncode(data)
	local fstr = ""
	for key2, _ in pairs(data.fields) do
		local str = "&updateMask.fieldPaths=" .. key2
		fstr = fstr .. str
	end
	local url = baseurl .. "/" .. Datastore .. "/" .. key .. "?currentDocument.exists=true" .. fstr
	local success, err =
		pcall(
			function()
			response =
				https:PostAsync(
					url,
					body,
					Enum.HttpContentType.ApplicationJson,
					false,
					{["X-HTTP-Method-Override"] = "PATCH",["Authorization"] = "Bearer ".. module.token}
				)
		end
		)
	if success then
		local rt = https:JSONDecode(response)
		return rt
		--returns the document that was updated
	end
	if err then
		return err
	end
end

return module
