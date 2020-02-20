local IsAOPanelEnabled = GetConfig( "EnableAOPanel" ) or GetConfig( "EnableAOPanel" ) == nil
local infotable = {}
local itemtable = {}
local quat = 0
local day=1000*60*60*24
local wtCheck1 = nil
local wtText1 = nil
local wtInfoPanel =  mainForm:GetChildChecked( "InfoPanel", false )
local wtButton = mainForm:GetChildChecked( "Button", false )
local wtContainer = wtInfoPanel:GetChildChecked( "Container", false )
local wtHeader = wtInfoPanel:GetChildChecked( "Header", false )
wtButton:SetVal("button_label", userMods.ToWString("IQR"))
wtInfoPanel:Show(false)
wtHeader:SetVal("name", common.GetAddonName())

--[[
0 - WIDGET_ALIGN_LOW - по меньшему краю
1 - WIDGET_ALIGN_HIGH - по большему краю
2 - WIDGET_ALIGN_CENTER - по центру
3 - WIDGET_ALIGN_BOTH - растягивать на весь размер родительского виджета
4 - WIDGET_ALIGN_LOW_ABS - по абсолютным координатам в пределах экрана
]]

--DESC
local ItemPanelDesc = mainForm:GetChildChecked( "ItemPanel", true ):GetWidgetDesc()
local TextDesc = mainForm:GetChildChecked( "Text", true ):GetWidgetDesc()
local IconDesc = mainForm:GetChildChecked( "Icon", true ):GetWidgetDesc()
local ButtonDeleteDesc = mainForm:GetChildChecked( "ButtonDelete", true ):GetWidgetDesc()
local CheckBoxDesc = mainForm:GetChildChecked( "CheckBox", true ):GetWidgetDesc()

function SetPos(wt,posX,sizeX,posY,sizeY,highPosX,highPosY,alignX, alignY, addchild)
  if wt then
    local p = wt:GetPlacementPlain()
    if posX then p.posX = posX end
    if sizeX then p.sizeX = sizeX end
    if posY then p.posY = posY end
    if sizeY then p.sizeY = sizeY end
    if highPosX then p.highPosX = highPosX end
    if highPosY then p.highPosY = highPosY end
	if alignX then p.alignX = alignX end
	if alignY then p.alignY = alignY end
    wt:SetPlacementPlain(p) 
  end
  if addchild then addchild = addchild:AddChild( wt ) end
end

function wtSetPlace(w, place )
	local p=w:GetPlacementPlain()
	for k, v in pairs(place) do	
		p[k]=place[k] or v
	end
	w:SetPlacementPlain(p)
end

function CreateWG(desc, name, parent, show, place)
	local n
	n = mainForm:CreateWidgetByDesc( desc )
	if name then n:SetName( name ) end
	if parent then parent:AddChild(n) end
	if place then wtSetPlace( n, place ) end
	n:Show( show == true )
	return n
end

function ReactionButton()
if DnD:IsDragging() then return end
	if wtInfoPanel:IsVisible() then	
		wtInfoPanel:Show(false)
		wtContainer:RemoveItems()
	else
		wtInfoPanel:Show(true)	
		ShowInfo()
	end  
end

function TakedItems(params)
local found=false
local info=itemLib.GetItemInfo(params.itemObject:GetId())
local avatarName=object.GetName(avatar.GetId())
local now=math.floor((common.GetLocalDateTime().overallMs)/day)*day
	for _, un in pairs(UserTable) do
		if userMods.FromWString(info.name) == un.Name then
			for i, _ in pairs(infotable) do
				if (userMods.FromWString(infotable[i].ObjectName) == userMods.FromWString(info.name)) and (userMods.FromWString(infotable[i].AvatarName) == userMods.FromWString(avatarName) ) then
							infotable[i].Date = now
							Save()
							--LogInfo("upd taked item")
							found=true
						break
					end
				end
			if not found then 
				infotable[quat]={
				AvatarName=avatarName,
				ObjectName=info.name,
				Date=now,
				Type="TakeItem",
				Period = un.Period
				}
				quat=quat+1
				Save()
				--LogInfo("new taked item")
				break
			end
		end
	end
end

function CompleteQuest(params)
if wtInfoPanel:IsVisible() then wtContainer:RemoveItems() ShowInfo() end
local found=false
local avatarName=object.GetName(avatar.GetId())
local now=math.floor((common.GetLocalDateTime().overallMs)/day)*day
local qvname = userMods.FromWString(common.ExtractWStringFromValuedText( avatar.GetQuestInfo( params.questId ).name ))
	for _, name in pairs(UserTable) do
		if qvname == name.Name then
						for i, _ in pairs(infotable) do
				if (infotable[i].ObjectName == qvname) and (userMods.FromWString(infotable[i].AvatarName) == userMods.FromWString(avatarName) ) then
							infotable[i].Date = now
							Save()
							--LogInfo("upd quest")
							found=true
						break
					end
				end
			if not found then 
				infotable[quat]={
				AvatarName=avatarName,
				ObjectName=userMods.ToWString(qvname),
				Date=now,
				Type="Quest",
				Period = name.Period
				}
				quat=quat+1
				Save()
				--LogInfo("new quest")
				break
			end
		end
	end
end

function UsedItems(params)
if wtInfoPanel:IsVisible() then wtContainer:RemoveItems() ShowInfo() end
local found=false
local info=itemLib.GetItemInfo(params.itemObject:GetId())
local avatarName=object.GetName(avatar.GetId())
local now=math.floor((common.GetLocalDateTime().overallMs)/day)*day
	for _, un in pairs(UserTable) do
		if userMods.FromWString(info.name) == un.Name then
			for i, _ in pairs(infotable) do 
				if (userMods.FromWString(infotable[i].ObjectName) == userMods.FromWString(info.name)) and (userMods.FromWString(infotable[i].AvatarName) == userMods.FromWString(avatarName) ) then
							infotable[i].Date = now
							Save()
							--LogInfo("upd used item")
							found=true
						break
					end
				end
			if not found then 
				infotable[quat]={
				AvatarName=avatarName,
				ObjectName=info.name,
				Date=now,
				Type="UsedItem",
				Period = un.Period
				}
				quat=quat+1
				Save()
				--LogInfo("new used item")
				break
			end
		end
	end
end

function Load()
local tab = userMods.GetGlobalConfigSection( "SettingsDWIR" )
	if tab then
	infotable = userMods.GetGlobalConfigSection( "SettingsDWIR" )
	quat = GetTableSize(infotable) 
	end
end

function Save()
if infotable then
userMods.SetGlobalConfigSection( "SettingsDWIR", infotable )
	end
end 

function ShowInfo()
local avatarName=object.GetName(avatar.GetId())
wtText1:SetVal("name", GTL('Avatar'))
itemtable = nil itemtable = {}

if infotable then
for k, v in pairs(infotable) do
	local mday = common.GetDateTimeFromMs(infotable[k].Date)
	local mdayfull = mday.d..mday.m..mday.y
	local today = common.GetLocalDateTime()
	local todayfull = today.d..today.m..today.y
	if wtCheck1:GetVariant()==0 then
local wtItemSlot = CreateWG(ItemPanelDesc, "wtItemSlot", nil, true, {alignX=3, sizeX=nil, posX=5, highPosX=25, alignY=3, sizeY=35, posY=0, highPosY=0,})
local wtAvatarName = CreateWG(TextDesc, "wtAvatarName", wtItemSlot, true, {alignX=4, sizeX=400, posX=25, highPosX=0, alignY=3, sizeY=30, posY=5, highPosY=0,})
local wtType = CreateWG(IconDesc, "wtType", wtItemSlot, true, {alignX=4, sizeX=30, posX=170, highPosX=0, alignY=3, sizeY=30, posY=5, highPosY=0,})
local wtInfo = CreateWG(TextDesc, "wtInfo", wtItemSlot, true, {alignX=4, sizeX=400, posX=200, highPosX=0, alignY=3, sizeY=30, posY=5, highPosY=0,})
local wtDelete = CreateWG(ButtonDeleteDesc, tostring(k), wtItemSlot, true, {alignX=1, sizeX=20, posX=10, highPosX=10, alignY=2, sizeY=20, posY=0, highPosY=0,})
table.insert(itemtable, {wtItemSlot=wtItemSlot})
wtAvatarName:SetVal("name",  v.AvatarName)
wtInfo:SetVal("name", v.ObjectName ) 
wtAvatarName:SetClassVal("class",  "Golden")
wtType:SetBackgroundTexture( common.GetAddonRelatedTexture(v.Type))
		if userMods.FromWString(infotable[k].AvatarName) ~= userMods.FromWString(avatarName) then
		wtItemSlot:SetBackgroundColor( { r = 0.7; g = 0.7; b = 0.7; a = 1.0 } )
		wtAvatarName:SetClassVal("class",  "tip_white")
		end
		if tonumber(infotable[k].Period) == 1 then
				
		if mdayfull == todayfull then
		wtInfo:SetClassVal("class", "tip_green")
		else
		wtInfo:SetClassVal("class", "GrayQuestName")
		end
		elseif tonumber(infotable[k].Period) == 7 then
			local ms = today.overallMs
			local currentweek = math.floor(ms/day/7)
			local collectweek = math.floor(infotable[k].Date/day/7)
				if collectweek-currentweek >=0 then 
				wtInfo:SetClassVal("class", "tip_green")
				elseif collectweek-currentweek <0 then 
				wtInfo:SetClassVal("class", "GrayQuestName")
				end
		end
	wtContainer:PushFront( wtItemSlot)
	else 
	if userMods.FromWString(infotable[k].AvatarName) == userMods.FromWString(avatarName) then
	local wtItemSlot = CreateWG(ItemPanelDesc, "wtItemSlot", nil, true, {alignX=3, sizeX=nil, posX=5, highPosX=25, alignY=3, sizeY=35, posY=0, highPosY=0,})
	local wtAvatarName = CreateWG(TextDesc, "wtAvatarName", wtItemSlot, true, {alignX=4, sizeX=400, posX=25, highPosX=0, alignY=3, sizeY=30, posY=5, highPosY=0,})
	local wtType = CreateWG(IconDesc, "wtType", wtItemSlot, true, {alignX=4, sizeX=30, posX=170, highPosX=0, alignY=3, sizeY=30, posY=5, highPosY=0,})
	local wtInfo = CreateWG(TextDesc, "wtInfo", wtItemSlot, true, {alignX=4, sizeX=400, posX=200, highPosX=0, alignY=3, sizeY=30, posY=5, highPosY=0,})
	local wtDelete = CreateWG(ButtonDeleteDesc, tostring(k), wtItemSlot, true, {alignX=1, sizeX=20, posX=10, highPosX=10, alignY=2, sizeY=20, posY=0, highPosY=0,})
	table.insert(itemtable, {wtItemSlot=wtItemSlot})
	wtAvatarName:SetVal("name",  v.AvatarName)
	wtInfo:SetVal("name", v.ObjectName )
	wtAvatarName:SetClassVal("class",  "Golden")
	wtType:SetBackgroundTexture( common.GetAddonRelatedTexture(v.Type))
	if tonumber(infotable[k].Period) == 1 then
		if mdayfull == todayfull then
		wtInfo:SetClassVal("class", "tip_green")
		else
		wtInfo:SetClassVal("class", "GrayQuestName")
		end
		elseif tonumber(infotable[k].Period) == 7 then
			local ms = today.overallMs
			local currentweek = math.floor(ms/day/7)
			local collectweek = math.floor(infotable[k].Date/day/7)
				if collectweek-currentweek >=0 then 
				wtInfo:SetClassVal("class", "tip_green")
				elseif collectweek-currentweek <0 then 
				wtInfo:SetClassVal("class", "GrayQuestName")
				end
			end
				wtContainer:PushFront( wtItemSlot)
				end
			end
		end
	end
end

function Delete(params)
if params.widget:GetName()=="ButtonCornerCross" then 
	wtInfoPanel:Show(false)
	wtContainer:RemoveItems()
else
	params.widget:GetParent():DestroyWidget()
	infotable[tonumber(params.sender)]=nil
	Save()
	end
end

function CheckBoxReaction(pars)
if pars.sender == pars.widget:GetName() then
	if pars.widget:GetVariant()==0 then 
	pars.widget:SetVariant(1)
	wtContainer:RemoveItems()
	ShowInfo()
else 
	pars.widget:SetVariant(0)
	wtContainer:RemoveItems()
	ShowInfo()
		end
	end
end 

function onAOPanelStart( params )
	if IsAOPanelEnabled then
		local SetVal = { val1 = userMods.ToWString("IQR"), class1 = "Golden" }
		local params = { header = SetVal, ptype = "button", size = 32 }
		userMods.SendEvent( "AOPANEL_SEND_ADDON", { name = common.GetAddonName(), sysName = common.GetAddonName(), param = params } )
		wtButton:Show( false )
	end 
end

function OnAOPanelButtonLeftClick( params ) 
	if params.sender == common.GetAddonName() then 
	ReactionButton()
	end 
end

function onAOPanelChange( params )
	if params.unloading and params.name == "UserAddon/AOPanelMod" then
		wtButton:Show( true )
	end
end

function enableAOPanelIntegration( enable )
	IsAOPanelEnabled = enable
	SetConfig( "EnableAOPanel", enable )
	if enable then
		onAOPanelStart()
	else
		wtButton:Show( true )
	end
end

--[[local RemortNames =  stateMainForm:GetChildChecked( "RemortList", false ):GetChildChecked( "RemortList", false ):GetChildChecked( "Content", false )
local remorts
RemortNames:SetOnShowNotification( true )

function RemortListInfo()
local ldate=common.GetLocalDateTime()
local now = math.floor((ldate.overallMs+timezone)/day)*day
local dnw = userMods.GetGlobalConfigSection("LabCalendar_Data")
remorts = remort.GetRemortsList()
for num, _ in pairs(remorts) do
local wtcont = RemortNames:At( num )
local child = wtcont:GetNamedChildren()
for _, v in pairs(child) do
	if (common.GetApiType(v)=="TextViewSafe") and v:GetName() == "Name" then
		local txt = userMods.FromWString(common.ExtractWStringFromValuedText(v:GetValuedText()))
		local lens = string.len(txt)
		local conv = string.sub(txt, 1 ,lens-5)
			for _, val in pairs(dnw) do
				if val.Date <= now then
					if userMods.FromWString(val.Name) == conv then
						local ico = WCD("Icon","ico"..num, v, { alignX = 1, sizeX=30, posX = 0, highPosX = 0, alignY = 1, sizeY=30, posY=0, highPosY=0}, true)
						ico:SetPriority(50)
						end 
					end 
				end
			end
		end
	end
end

function ClearWG(params)
if params.widget:IsVisibleEx() == false and params.widget:GetName() == "Content" then
if remorts then
for num, _ in pairs(remorts) do
local wtcont = RemortNames:At( num )
local child = wtcont:GetNamedChildren()
	for _, v in pairs(child) do
	if (common.GetApiType(v)=="TextViewSafe") and v:GetName() == "Name" then
		local cld = v:GetNamedChildren()
			for _, vv in pairs(cld) do
				vv:DestroyWidget()
						end
					end
				end
			end
		end
	end
end]]

function Init()
	wtCheck1 = CreateWG(CheckBoxDesc, "CB1", wtInfoPanel, true, {alignX=4, sizeX=37, posX=30, highPosX=0, alignY=1, sizeY=37, posY=0, highPosY=44,})
	wtText1 = CreateWG(TextDesc, "TXT1", wtInfoPanel, true, {alignX=4, sizeX=400, posX=55, highPosX=0, alignY=1, sizeY=30, posY=0, highPosY=48,})
	Load()
	--common.RegisterEventHandler( TakedItems, "EVENT_AVATAR_ITEM_TAKEN")
	common.RegisterEventHandler( CompleteQuest, "EVENT_QUEST_COMPLETED")
	common.RegisterEventHandler( UsedItems, "EVENT_AVATAR_ITEM_DROPPED")
	common.RegisterReactionHandler( ReactionButton, "Button" )
	common.RegisterReactionHandler( Delete, "mouse_left_click" )
	common.RegisterReactionHandler( CheckBoxReaction, "checkbox" )
	common.RegisterEventHandler( onAOPanelStart, "AOPANEL_START" )
    common.RegisterEventHandler( OnAOPanelButtonLeftClick, "AOPANEL_BUTTON_LEFT_CLICK" )   
	common.RegisterEventHandler( onAOPanelChange, "EVENT_ADDON_LOAD_STATE_CHANGED" )
	DnD:Init( wtInfoPanel, wtInfoPanel, true )
	DnD:Init( wtButton, wtButton, true )
end

if (avatar.IsExist()) then Init()
else common.RegisterEventHandler(Init, "EVENT_AVATAR_CREATED")	
end