module("L_EnergeniePMS2", package.seeall)

local url = require("socket.url")
local socket = require("socket")
local http = require("socket.http")
local ltn12 = require("ltn12")
local POLLING_INTERVAL = 30
local DEBUG_MODE = true
local OUTLET_START = 1
local OUTLET_END = 4
local PV = "0.3" -- plugin version number
local ipAddress -- http://192.168.102.193
local childDeviceIndex = {}
local EnergeniechildDevicelist = {}
local COM_SID = "urn:nodecentral-net:serviceId:EnergeniePMS2"
--  http://192.168.102.10:3480/data_request?id=lua&DeviceNum=1180
		
local function log(text, level)
	luup.log("E-geniePMS2: " .. text, (level or 1))
	end

local function debug(text)
	if (DEBUG_MODE == true) or (DEBUG_MODE == "true")then
		log("debug: " .. text, 50)
	end
end

function EnergeniePMSResponceProcessor(responseBody, command, page, child_ID)
	log("Processing response = " .. responseBody)
	debug("------------------------")
	debug("Command sent = " ..command)
	debug("Webpage called = " ..page)
	debug("Target Device_ID = " ..child_ID) 
	debug("------------------------")
	local loggedout = responseBody:match("<script>function PreSubmit()")
	local loggedin = responseBody:match("<script>var sockstates")
		if loggedout == nil then 
			debug("SUCCESS - You are logged in")
			debug("Processing response of all child devices")
			local socket1, socket2, socket3, socket4 = responseBody:match("<script>var sockstates = %[(%d),(%d),(%d),(%d)%];var mac=")
			log("Socket state = [" ..socket1.. " , " ..socket2.. " , " ..socket3.. " , " ..socket4.. "]")
			
			local EnergeniePMSStatusTable = {
				cte1 = socket1,cte2 = socket2,cte3 = socket3,cte4 = socket4}
			for k, v in pairs(EnergeniePMSStatusTable) do
				luup.variable_set("urn:upnp-org:serviceId:SwitchPower1", "Status", value, childDeviceIndex["cte"..v])
				--luup.variable_set("urn:upnp-org:serviceId:SwitchPower1", "Status", value, lul_device)
			end
		else 
			debug("ERROR, logging back in again")
			ipAddress = luup.devices[lul_device].ip
			debug("ipAddress = " ..ipAddress)
			debug("Loging in and resending command = " ..command)
			if EnergeniePMSLogin(ipAddress, lul_device) == "Logged In" then
				EnergeniePMSCommand(command, "status.html", lul_device)
			else log("XXX HELP HUSTON WE HAVE A PROBLEM XXX")
			end
		end
end

function EnergeniePMSCommand(Erequest, page, child_ID)
	log("Command Sent ...")
	local postBody = Erequest
	debug("postBody = " ..Erequest)
	local controlURL = "http://" .. ipAddress .. "/" ..page
	debug("controlURL = " ..controlURL)
	http.TIMEOUT = 5 -- 5 Second timeout
	local resultTable = {}
	local status, statusMsg = http.request{
		url = controlURL,
		sink = ltn12.sink.table(resultTable),
		method = "POST",
		headers = {
				["Accept"] = "*/*",
				["Content-Type"] = "application/x-www-form-urlencoded",
				["Content-Length"] = postBody:len()
					},
		source = ltn12.source.string(postBody),
											}
	debug("EnergeniePMSResponse = " .. tostring(statusMsg))
	local responseBody = table.concat( resultTable, "" )
		if (responseBody) then
			log("SUCCESS: Response received ")
			EnergeniePMSResponceProcessor(responseBody,Erequest, page, child_ID )
		else
			log("ERROR: Empty response returned")
		end
end


function OnOffCall(lul_device, settings)
	log("OnOffCall function requested")
	for k, v in pairs( settings) do
		luup.log("key = " ..k .. ", Value = " .. v)
	end
	
	log("-----------------------")
	luup.log(lul_device)
	log(tostring(settings.newTargetValue))
	log(tonumber(settings.DeviceNum))
	log(tostring(settings.serviceId))
	log("-----------------------")
	
	local DeviceAltID = luup.attr_get("altid", tonumber(settings.DeviceNum))
	luup.log(DeviceAltID)
	
	local postBody = DeviceAltID .. "=" .. tostring(settings.newTargetValue)
	log("PostBody to send = " ..postBody)
	
	debug("Update child device visual status")
	luup.variable_set("urn:upnp-org:serviceId:SwitchPower1", "Status", tostring(settings.newTargetValue), tonumber(settings.DeviceNum))
	
	EnergeniePMSCommand(postBody, "status.html", settings.DeviceNum)

end


function EnergeniePMSLogin(ipAddress, lul_device, existingChildren)
	log("Logging in to check socket states")
	luup.log(ipAddress)
	luup.log(lul_device)
	luup.log(existingChildren)
	debug("--- print parent-child table ---")
	luup.log("d.devnum, v.id, v.description")
	for k ,d in ipairs( existingChildren ) do
		local v = d.device
		luup.log(d.devnum..", "..v.id..", "..v.description)
	end
	
	local postBody = "server=EG Web&pw=1"
	local controlURL = "http://" .. ipAddress .. "/login.html"
	debug("URL called = " ..controlURL)
	http.TIMEOUT = 5 -- 5 Second timeout
	local resultTable = {}
	local status, statusMsg = http.request{
		url = controlURL,
		sink = ltn12.sink.table(resultTable),
		method = "POST",
		headers = {
				["Accept"] = "*/*",
				["Content-Type"] = "application/x-www-form-urlencoded",
				["Content-Length"] = postBody:len()
					},
		source = ltn12.source.string(postBody),
											}
	debug("Login Status Message = " .. tostring(statusMsg))
	local EnergeniePMSResponse = table.concat( resultTable, "" )
	debug("Response received " .. EnergeniePMSResponse)
	
	if (EnergeniePMSResponse) then
		local EnergeniePMSStateTable= {}
		
		local socket1, socket2, socket3, socket4 = EnergeniePMSResponse:match("<script>var sockstates = %[(%d),(%d),(%d),(%d)%];var mac=")
		log("Socket state = [" ..socket1.. " , " ..socket2.. " , " ..socket3.. " , " ..socket4.. "]")
		debug("Values to process via set_variable")
		local EnergeniePMSStatusTable = {
			cte1 = socket1,cte2 = socket2,cte3 = socket3,cte4 = socket4}
			
			debug("--- print parent-child table ---")
			luup.log("d.devnum, v.id, v.description")
				for k ,d in ipairs( existingChildren ) do
					for n, v in pairs(EnergeniePMSStatusTable) do
				if d.device.id == n then
					luup.log(d.devnum..", "..d.device.id..", "..d.device.description .. " - " .. n.. ", " .. v .. ", " .. lul_device)
					luup.variable_set("urn:upnp-org:serviceId:SwitchPower1", "Status", v, d.devnum)
				end
			end
		end
		
		debug("Logged In: Response processed")
		return "Logged In"
	else
		log("Error logging in: Empty response returned")
		return "Error logging in"
	end
end

local function populatechildtable(lul_device, ipAddress)
	debug("Parent device = " ..lul_device)
	debug("ipAddress = " ..ipAddress)
	debug("Build existing child device table")
	local existingChildren = {}
	for k,v in pairs( luup.devices ) do
		if v.device_num_parent == lul_device then
			local d = {}
			d.devnum = k
			d.device = v
			d.device_file = luup.attr_get( "device_file", k ) or ""
			d.device_json = luup.attr_get( "device_json", k ) or ""
			if d.device_file ~= "" then
				table.insert( existingChildren, d )
			end
		end
	end
	
	for k ,d in ipairs( existingChildren ) do
		--local v = d.device
		--luup.log(d.devnum..", "..v.id..", "..v.description)
		--luup.attr_set( "category_num", "3", d.devnum)
		luup.attr_set( "subcategory_num", "1", d.devnum)
	end
	
	debug("Login to EnergeniePMS")
	EnergeniePMSLogin(ipAddress, lul_device, existingChildren)
end


local function createEnergeniePMSChildOutlets(ipAddress, lul_device)
	log("Start up, Create Child device(s)...")
	child_devices = luup.chdev.start(lul_device) 
	
	-- Tells Luup to start enumerating children for this device based on it's dev_id
	debug("EnergeniePMS2 lul_device  = " ..lul_device)
	debug("EnergeniePMS2 Outlets : Start = " ..OUTLET_START.. " End = "..OUTLET_END)
	
	for v = OUTLET_START,OUTLET_END do
	luup.chdev.append(lul_device,child_devices, "cte" .. v, " Socket " .. v, "urn:schemas-upnp-org:device:BinaryLight:1", "D_BinaryLight1.xml", "", "", false)
		debug("cte" ..v.. " - Socket " .. v.." created")
	end
  
	luup.chdev.sync(lul_device, child_devices)
	populatechildtable(lul_device, ipAddress)
end


local function checkEnergeniePMSSetUp(lul_device)
	debug("Checking device is configured correctly...")
	log("DEBUG Variable is set to : " .. tostring(debugState))
	ipAddress = luup.devices[lul_device].ip -- check if an ip address assigned 
	if ipAddress == nil or ipAddress == "" then -- if not stop and present error message
		luup.task('ERROR: IP Address is missing',2,'EnergeniePMS',-1)
		log("ERROR: IP Address missing " ..ipAddress.. " unable to progress")
		luup.variable_set(COM_SID, "Icon", 2, lul_device)
		luup.set_failure(1,lul_device) --it's failing
	else -- if IP is provided, present success message
		luup.task('IP Address for EnergeniePMS present, setup continues',4,'EnergeniePMS',-1)
		log("SUCCESS: IP Address present " ..ipAddress.. " for #" .. lul_device )
		luup.set_failure(0,lul_device) --its working
		luup.variable_set(COM_SID, "Icon", 1, lul_device)
		luup.variable_set(COM_SID, "LastUpdate", os.time(), lul_device)
		createEnergeniePMSChildOutlets(ipAddress, lul_device)
	end 
end
			
-- Initialize plug-in
function EnergeniePMS2Startup(lul_device)
	-- set attributes for parent device
	log("Start up, Creating device..." ..lul_device)
	luup.variable_set(COM_SID, "PluginVersion", PV, lul_device)
	checkEnergeniePMSSetUp(lul_device)
end