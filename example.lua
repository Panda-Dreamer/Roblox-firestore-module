FireStoreService = require(script.Parent.Firestore)

data1 = FireStoreService.Get("users","TestDocument")--Gets the data from the document named "TestDocument"

--"test-1" is the Datastore, "Test" the key

--Returns an object with the data

print(data1)

data2 = FireStoreService.BatchGet("users",{"TestDocument","Test2"}) --Gets the data from the documents named "TestDocument" and "Test2"

--"test-1" is the Datatstore and the second argument is an array of keys

--Returns an array of objects with the data

print(data2)

data3 = FireStoreService.Set("users","Test3",data1) --Creates a new document named "Test3" that will be a copy of the "TestDocument" as we are using the data from the GET

--"test-&" is the Datatsore, "Test3" the key and data1 the data that we got from the key "Test" at the first function

--Returns an object with the oebject created

print(data3)

data4 = FireStoreService.Delete("users","Test2") --Delete the document named "Test2"

--"test-1" is the Datastore, "Test2" is the key of the entry to delete

--Returns an empty object if the entry was deleted correctly

print(data4)

data5 = FireStoreService.query("test-1","Gold",1,">=","ASCENDING","Gold")

--"test-1" is the Datastore

--"Gold" is the field that have the value you filter

--1 is the value you are using to filter

--">=" means its filters all entries that have the field gold > or = to 1 (can be </<=/>/>=/=/~=)

--The order in what to return the query results (can be ASCENDING/DESCENDING)

--The field on what the ordering will be based

--The query will return every documents that have the field gold > or = to 1 ordered in ascending order based on the value of the gold field

--Returns an array of documents

print(data5)

local datatoupdate= {
	["fields"] = {
		["Golds"] = {
			["integerValue"] = "30",
		},
		["Banned"] = {
			["booleanValue"] = false,
		}
	}
}
Firebase.UpdateFields("users","Test1",datatoupdate) 
--Updates the value of specific fields, here Gold and banned fields.
