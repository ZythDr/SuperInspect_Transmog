local SITransmog = CreateFrame("Frame", "SuperInspectTransmogFrame")
local SITransmogScan = CreateFrame("GameTooltip", "SITransmogScan", UIParent, "GameTooltipTemplate")
local SITransmogTooltipHook = CreateFrame("Frame", "SITransmogTooltipHook", GameTooltip)

SITransmog.requestDelay = nil
SITransmog.refreshDelay = nil
SITransmog.hooked = nil
SITransmog.originalInspectFrameShow = nil
SITransmog.originalPaperDollOnShow = nil
SITransmog.originalSlotOnEnter = nil
SITransmog.originalSlotUpdate = nil
SITransmog.indicatorTexture = "Interface\\AddOns\\SuperInspect_Transmog\\TransmogTexture"
SITransmog.indicatorSize = 51
SITransmog.indicatorOffsetX = 7
SITransmog.indicatorOffsetY = -7
SITransmog.indicatorFrameLevelOffset = 0
SITransmog.indicatorAlpha = 0.85
SITransmog.indicatorTexCoord = { 0, 1, 0, 1 }

local superInspectSlotFrames = {
	"SuperInspect_InspectHeadSlot",
	"SuperInspect_InspectShoulderSlot",
	"SuperInspect_InspectShirtSlot",
	"SuperInspect_InspectChestSlot",
	"SuperInspect_InspectWaistSlot",
	"SuperInspect_InspectLegsSlot",
	"SuperInspect_InspectFeetSlot",
	"SuperInspect_InspectWristSlot",
	"SuperInspect_InspectHandsSlot",
	"SuperInspect_InspectBackSlot",
	"SuperInspect_InspectMainHandSlot",
	"SuperInspect_InspectSecondaryHandSlot",
	"SuperInspect_InspectRangedSlot",
	"SuperInspect_InspectTabardSlot",
}

local function GetTransmogLabel()
	return TRANSMOG_CHANGED_TO or "Transmogrified to:"
end

local function GetSlotButton(index)
	return _G[superInspectSlotFrames[index]]
end

local function TooltipHasTransmogText(tooltip, label)
	local index
	local numLines
	local tooltipName

	if not tooltip or not label then
		return nil
	end

	numLines = tooltip:NumLines() or 0
	tooltipName = tooltip:GetName()
	if not tooltipName or numLines == 0 then
		return nil
	end

	for index = 1, numLines do
		local line = _G[tooltipName .. "TextLeft" .. index]
		if line then
			local text = line:GetText()
			if text and string.find(text, label, 1, true) then
				return true
			end
		end
	end
end

local function CacheItem(itemID)
	if not itemID or itemID == 0 then
		return
	end

	if Transmog and Transmog.CacheItem then
		Transmog:CacheItem(itemID)
		return
	end

	SITransmogScan:SetOwner(UIParent, "ANCHOR_NONE")
	SITransmogScan:SetHyperlink("item:" .. itemID)
	SITransmogScan:Hide()
	SITransmogScan:ClearLines()
end

local function GetInspectedUnit()
	if SuperInspect_InvFrame and SuperInspect_InvFrame.unit and UnitExists(SuperInspect_InvFrame.unit) then
		return SuperInspect_InvFrame.unit
	end

	if UnitExists("target") then
		return "target"
	end
end

function SITransmog:EnsureInspectUILoaded()
	if not IsAddOnLoaded("Blizzard_InspectUI") then
		LoadAddOn("Blizzard_InspectUI")
	end

	return IsAddOnLoaded("Blizzard_InspectUI") and InspectFrame and true or false
end

function SITransmog:SyncInspectUnit()
	local unit = GetInspectedUnit()
	if not unit then
		return nil
	end

	if not self:EnsureInspectUILoaded() then
		return nil
	end

	InspectFrame.unit = unit
	return unit
end

function SITransmog:GetTooltipOwner()
	local index
	for index = 1, getn(superInspectSlotFrames) do
		local button = GetSlotButton(index)
		if button and GameTooltip:IsOwned(button) then
			return button
		end
	end
end

function SITransmog:ApplyIndicatorLayout(button)
	local indicator
	local indicatorFrame
	local texCoord
	local coordCount

	if not button then
		return
	end

	indicatorFrame = button.SITransmogIndicatorFrame
	indicator = button.SITransmogIndicator
	if not indicatorFrame or not indicator then
		return
	end

	indicatorFrame:ClearAllPoints()
	indicatorFrame:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", self.indicatorOffsetX or 0, self.indicatorOffsetY or 0)
	indicatorFrame:SetWidth(self.indicatorSize or 20)
	indicatorFrame:SetHeight(self.indicatorSize or 20)
	indicatorFrame:SetFrameStrata(button:GetFrameStrata())
	indicatorFrame:SetFrameLevel(button:GetFrameLevel() + (self.indicatorFrameLevelOffset or 0))

	indicator:SetTexture(self.indicatorTexture)
	indicator:SetAllPoints(indicatorFrame)
	indicator:SetAlpha(self.indicatorAlpha or 1)

	texCoord = self.indicatorTexCoord
	coordCount = texCoord and getn(texCoord) or 0
	if coordCount == 8 then
		indicator:SetTexCoord(texCoord[1], texCoord[2], texCoord[3], texCoord[4], texCoord[5], texCoord[6], texCoord[7], texCoord[8])
	else
		indicator:SetTexCoord(0, 1, 0, 1)
	end
end

function SITransmog:ApplyIndicatorStyle(style)
	if not style then
		return
	end

	self.indicatorTexture = style.texture or self.indicatorTexture
	self.indicatorSize = style.size or self.indicatorSize
	self.indicatorOffsetX = style.offsetX or 0
	self.indicatorOffsetY = style.offsetY or 0
	self.indicatorFrameLevelOffset = style.frameLevelOffset or 0
	self.indicatorAlpha = style.alpha or 1
	self.indicatorTexCoord = style.texCoord

	self:RefreshSlotIndicators()
	self:InjectTooltipText()
end

function SITransmog:EnsureSlotIndicator(button)
	local indicator
	local indicatorFrame

	if not button then
		return nil
	end

	indicator = button.SITransmogIndicator
	if indicator then
		return indicator
	end

	indicatorFrame = CreateFrame("Frame", button:GetName() .. "SITransmogIndicatorFrame", button)

	indicator = indicatorFrame:CreateTexture(button:GetName() .. "SITransmogIndicator", "OVERLAY")
	indicator:SetVertexColor(1, 1, 1, 1)
	indicator:Hide()

	button.SITransmogIndicatorFrame = indicatorFrame
	button.SITransmogIndicator = indicator
	self:ApplyIndicatorLayout(button)
	return indicator
end

function SITransmog:UpdateSlotIndicator(button)
	local data
	local indicator
	local indicatorFrame

	if not button then
		return
	end

	indicator = self:EnsureSlotIndicator(button)
	if not indicator then
		return
	end
	self:ApplyIndicatorLayout(button)

	indicatorFrame = button.SITransmogIndicatorFrame

	if not SuperInspect_InvFrame or not SuperInspect_InvFrame:IsVisible() or not button.hasItem then
		if indicatorFrame then
			indicatorFrame:Hide()
		end
		indicator:Hide()
		return
	end

	data = INSPECT_TRANSMOG_DATA and INSPECT_TRANSMOG_DATA[button:GetID()]
	if data and data.transmogID then
		if indicatorFrame then
			indicatorFrame:Show()
		end
		indicator:Show()
		return
	end

	if indicatorFrame then
		indicatorFrame:Hide()
	end
	indicator:Hide()
end

function SITransmog:RefreshSlotIndicators()
	local index

	for index = 1, getn(superInspectSlotFrames) do
		self:UpdateSlotIndicator(GetSlotButton(index))
	end
end

function SITransmog:ClearSlotIndicators()
	local index

	for index = 1, getn(superInspectSlotFrames) do
		local button = GetSlotButton(index)
		if button and button.SITransmogIndicator then
			button.SITransmogIndicator:Hide()
			if button.SITransmogIndicatorFrame then
				button.SITransmogIndicatorFrame:Hide()
			end
		end
	end
end

function SITransmog:QueueUpdate()
	self:SetScript("OnUpdate", function()
		SITransmog:OnUpdate(arg1)
	end)
end

function SITransmog:ScheduleRequest(delay)
	self.requestDelay = delay or 0
	self:QueueUpdate()
end

function SITransmog:ScheduleTooltipRefresh(delay)
	self.refreshDelay = delay or 0
	self:QueueUpdate()
end

function SITransmog:RequestTransmogData()
	local unit = self:SyncInspectUnit()
	if not unit then
		return
	end

	local playerName = UnitName(unit)
	if not playerName then
		return
	end

	SendAddonMessage("TW_CHAT_MSG_WHISPER<" .. playerName .. ">", "INSShowTransmogs", "GUILD")
end

function SITransmog:InjectTooltipText()
	if not SuperInspect_InvFrame or not SuperInspect_InvFrame:IsVisible() then
		return
	end

	local button = self:GetTooltipOwner()
	if not button then
		return
	end

	local data = INSPECT_TRANSMOG_DATA and INSPECT_TRANSMOG_DATA[button:GetID()]
	if not data or not data.transmogID then
		return
	end

	local line2 = GameTooltipTextLeft2
	if not line2 or not line2:GetText() then
		return
	end

	local transmogLabel = GetTransmogLabel()
	if TooltipHasTransmogText(GameTooltip, transmogLabel) then
		return
	end

	local itemName = GetItemInfo(data.transmogID)
	if not itemName then
		CacheItem(data.transmogID)
		self:ScheduleTooltipRefresh(0.05)
		return
	end

	line2:SetText("|cfff471f5" .. transmogLabel .. "\n" .. itemName .. "|r\n" .. line2:GetText())
	GameTooltip:Show()
end

function SITransmog:OnUpdate(elapsed)
	if self.requestDelay then
		self.requestDelay = self.requestDelay - elapsed
		if self.requestDelay <= 0 then
			self.requestDelay = nil
			self:RequestTransmogData()
		end
	end

	if self.refreshDelay then
		self.refreshDelay = self.refreshDelay - elapsed
		if self.refreshDelay <= 0 then
			self.refreshDelay = nil
			self:InjectTooltipText()
		end
	end

	if not self.requestDelay and not self.refreshDelay then
		self:SetScript("OnUpdate", nil)
	end
end

function SITransmog:HookSuperInspect()
	if self.hooked then
		return
	end

	if type(SuperInspect_InspectFrame_Show) ~= "function" then
		return
	end

	if type(SuperInspect_InspectPaperDollItemSlotButton_OnEnter) ~= "function" then
		return
	end

	if type(SuperInspect_InspectPaperDollItemSlotButton_Update) == "function" then
		self.originalSlotUpdate = SuperInspect_InspectPaperDollItemSlotButton_Update
		SuperInspect_InspectPaperDollItemSlotButton_Update = function(button)
			SITransmog.originalSlotUpdate(button)
			SITransmog:UpdateSlotIndicator(button)
		end
	end

	self.originalInspectFrameShow = SuperInspect_InspectFrame_Show
	SuperInspect_InspectFrame_Show = function(unit)
		SITransmog.originalInspectFrameShow(unit)
		SITransmog:SyncInspectUnit()
		SITransmog:ClearSlotIndicators()
		SITransmog:ScheduleRequest(0.05)
	end

	if type(SuperInspect_InspectPaperDollFrame_OnShow) == "function" then
		self.originalPaperDollOnShow = SuperInspect_InspectPaperDollFrame_OnShow
		SuperInspect_InspectPaperDollFrame_OnShow = function()
			SITransmog.originalPaperDollOnShow()
			SITransmog:SyncInspectUnit()
			SITransmog:ClearSlotIndicators()
			SITransmog:RefreshSlotIndicators()
			SITransmog:ScheduleRequest(0.05)
		end
	end

	self.originalSlotOnEnter = SuperInspect_InspectPaperDollItemSlotButton_OnEnter
	SuperInspect_InspectPaperDollItemSlotButton_OnEnter = function()
		SITransmog.originalSlotOnEnter()
		SITransmog:SyncInspectUnit()
		SITransmog:UpdateSlotIndicator(this)
		SITransmog:InjectTooltipText()
		SITransmog:ScheduleRequest(0)
	end

	SITransmogTooltipHook:SetScript("OnShow", function()
		SITransmog:InjectTooltipText()
	end)
	SITransmogTooltipHook:Show()

	self.hooked = true
end

function SITransmog:HandleAddonMessage(prefix, message, sender)
	local isStart

	if prefix ~= "TW_CHAT_MSG_WHISPER" then
		return
	end

	if not message or not string.find(message, "INSTransmogs", 1, true) then
		return
	end

	if not self:SyncInspectUnit() then
		return
	end

	isStart = string.find(message, "INSTransmogs;start;", 1, true)
		or string.find(message, "INSTransmogs:start:", 1, true)

	if type(InspectPaperDollFrame_HandleMessage) == "function" then
		InspectPaperDollFrame_HandleMessage(message, sender)
		self:RefreshSlotIndicators()
		if not isStart then
			self:ScheduleTooltipRefresh(0)
		end
	end
end

function SITransmog:HandleEvent(eventName, firstArg, secondArg, thirdArg, fourthArg)
	if eventName == "PLAYER_LOGIN" then
		if IsAddOnLoaded("SuperInspect_UI") then
			self:HookSuperInspect()
		end
		return
	end

	if eventName == "ADDON_LOADED" then
		if firstArg == "SuperInspect_UI" then
			self:HookSuperInspect()
		end
		return
	end

	if eventName == "CHAT_MSG_ADDON" then
		self:HandleAddonMessage(firstArg, secondArg, fourthArg)
	end
end

SITransmog:RegisterEvent("PLAYER_LOGIN")
SITransmog:RegisterEvent("ADDON_LOADED")
SITransmog:RegisterEvent("CHAT_MSG_ADDON")
SITransmog:SetScript("OnEvent", function()
	SITransmog:HandleEvent(event, arg1, arg2, arg3, arg4)
end)