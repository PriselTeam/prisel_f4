 local mainPanel = nil
 local mainChilds = {}
 local categories = {}
 local detailsPanel = nil
 PriselHUD = PriselHUD or {}
 local P3F4Frame = nil
 
 local infosServ = {
   ["connect"] = 0,
   ["disconnect"] = 0,
   ["kill"] = 0,
   ["death"] = 0,
 }
 
 local function removeValidPanels()
   local validPanels = {}
   for k, v in pairs(mainChilds) do
     if IsValid(v) then
       table.insert(validPanels, v)
     end
   end
 
   for _, panel in ipairs(validPanels) do
     panel:AlphaTo(0, 0.2, 0, function()
       panel:Remove()
     end)
   end
 end
 
 local function openDetailsJob(jobTBL)
   if IsValid(detailsPanel) then detailsPanel:Remove() end
   detailsPanel = vgui.Create("Prisel.Frame")
   detailsPanel:SetSize(ScrW() * 0.5, ScrH() * 0.7)
   detailsPanel:Center()
   detailsPanel:MakePopup()
   detailsPanel:SetTitle("Détails du métier")
   detailsPanel:ShowCloseButton(true)
   
   local jobName = vgui.Create("DLabel", detailsPanel)
   jobName:SetSize(detailsPanel:GetWide() * 0.9, detailsPanel:GetTall() * 0.1)
   jobName:SetPos(DarkRP.ScrW * - 0.1, DarkRP.ScrH * 0.08)
   jobName:SetFont(DarkRP.Library.Font(10, 0, "Montserrat Bold"))
   jobName:SetText(jobTBL.name)
   jobName:SetTextColor(color_white)
   jobName:SetContentAlignment(5)
 
 
   local model = string.find(jobTBL.model[1], "models/") and jobTBL.model[1] or jobTBL.model
   local jobModel = nil
   if not util.IsValidModel(model) then
     jobModel = vgui.Create("DPanel", detailsPanel)
     jobModel:SetSize(detailsPanel:GetWide() * 0.4, detailsPanel:GetWide() * 0.4)
     jobModel:SetPos(detailsPanel:GetWide()*0.05, detailsPanel:GetTall() * 0.3)
 
     function jobModel:Paint(w,h)
       surface.SetDrawColor(color_white)
       surface.SetMaterial(DarkRP.Library.FetchCDN("prisel_main/404"))
       surface.DrawTexturedRect(0, 0, w, h)
     end
   else
     local jobModel = vgui.Create("DModelPanel", detailsPanel)
     jobModel:SetSize(detailsPanel:GetWide() * 0.6, detailsPanel:GetWide() * 0.6)
     jobModel:SetPos(detailsPanel:GetWide()*-0.05, detailsPanel:GetTall() * 0.14)

     local model = string.find(jobTBL.model[1], "models/") and jobTBL.model[1] or jobTBL.model
     jobModel:SetModel(model)
     jobModel:SetMouseInputEnabled(false)
     jobModel:SetFOV(60)

   end
 
   function detailsPanel:Think()
     if not IsValid(mainPanel) then
       self:Remove()
     end
   end
 
   local panelDescription = vgui.Create("DPanel", detailsPanel)
   panelDescription:SetSize(detailsPanel:GetWide() * 0.4, detailsPanel:GetTall() * 0.2)
   panelDescription:SetPos(detailsPanel:GetWide() * 0.55, detailsPanel:GetTall() * 0.12)
 
   function panelDescription:Paint(w, h)
     draw.RoundedBox(DarkRP.Config.RoundedBoxValue, 0, 0, w, h, DarkRP.Library.ColorNuance(DarkRP.Config.Colors["Secondary"], 15))
     draw.SimpleTextOutlined("Description", DarkRP.Library.Font(10, 0, "Montserrat Bold"), w/2, h * 0.12, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)
   end
 
   local description = vgui.Create("DLabel", panelDescription)
   description:SetSize(panelDescription:GetWide() * 0.9, panelDescription:GetTall() * 0.8)
   description:SetWrap(true)
   description:SetFont(DarkRP.Library.Font(9))
   description:SetText(jobTBL.description)
   description:SetTextColor(color_white)
   description:SetContentAlignment(7)
   description:SetPos(panelDescription:GetWide()/2 - description:GetWide()/2, panelDescription:GetTall() * 0.25)
 
   local infoJobs = vgui.Create("DPanel", detailsPanel)
   infoJobs:SetSize(detailsPanel:GetWide() * 0.4, detailsPanel:GetTall() * 0.5)
   infoJobs:SetPos(detailsPanel:GetWide() * 0.55, detailsPanel:GetTall() * 0.35)
 
   function infoJobs:Paint(w, h)
     draw.RoundedBox(DarkRP.Config.RoundedBoxValue, 0, 0, w, h, DarkRP.Library.ColorNuance(DarkRP.Config.Colors["Secondary"], 15))
     draw.SimpleTextOutlined("Informations", DarkRP.Library.Font(10, 0, "Montserrat Bold"), w/2, h * 0.05, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)
   end
 
   local labelSalary = vgui.Create("DLabel", infoJobs)
   labelSalary:SetSize(infoJobs:GetWide() * 0.9, infoJobs:GetTall() * 0.1)
   labelSalary:SetPos(infoJobs:GetWide()/2 - labelSalary:GetWide()/2, infoJobs:GetTall() * 0.15)
   labelSalary:SetFont(DarkRP.Library.Font(9))
   labelSalary:SetText("Salaire : "..DarkRP.formatMoney(jobTBL.salary))
   labelSalary:SetTextColor(color_white)
   labelSalary:SetContentAlignment(7)
 
   local labelMax = vgui.Create("DLabel", infoJobs)
   labelMax:SetSize(infoJobs:GetWide() * 0.9, infoJobs:GetTall() * 0.1)
   labelMax:SetPos(infoJobs:GetWide()/2 - labelMax:GetWide()/2, infoJobs:GetTall() * 0.25)
   labelMax:SetFont(DarkRP.Library.Font(9))
   local max = jobTBL.max == 0 and "Illimité" or jobTBL.max
   labelMax:SetText("Joueurs : "..team.NumPlayers(jobTBL.team).."/"..max)
   labelMax:SetTextColor(color_white)
   labelMax:SetContentAlignment(7)
 
   local labelCategory = vgui.Create("DLabel", infoJobs)
   labelCategory:SetSize(infoJobs:GetWide() * 0.9, infoJobs:GetTall() * 0.1)
   labelCategory:SetPos(infoJobs:GetWide()/2 - labelCategory:GetWide()/2, infoJobs:GetTall() * 0.35)
   labelCategory:SetFont(DarkRP.Library.Font(9))
   labelCategory:SetText("Catégorie : "..jobTBL.category)
   labelCategory:SetTextColor(color_white)
   labelCategory:SetContentAlignment(7)
 
   local chooseJob = vgui.Create("Prisel.Button", detailsPanel)
   chooseJob:SetSize(detailsPanel:GetWide() * 0.4, detailsPanel:GetTall() * 0.07)
   chooseJob:SetPos(detailsPanel:GetWide() * 0.55, detailsPanel:GetTall() * 0.87)
   chooseJob:SetText("Choisir ce métier")
 
   function chooseJob:DoClick()
     if LocalPlayer():Team() == jobTBL.team then
       notification.AddLegacy("Vous êtes déjà dans ce métier !", NOTIFY_ERROR, 2)
       return
     end
 
     if jobTBL.vote then
       LocalPlayer():ConCommand("say /vote" .. jobTBL.command)
     else
       LocalPlayer():ConCommand("say /" .. jobTBL.command)
     end
     P3F4Frame:Remove()
     detailsPanel:Remove()
   end
 
 end
 
 local function createJobsPanel(mainPanel)
   local jobsPanel = vgui.Create("DPanel", mainPanel)
   mainChilds["jobsPanel"] = jobsPanel
   jobsPanel:Dock(FILL)
   jobsPanel:SetAlpha(0)
   jobsPanel:AlphaTo(255, 0.2, 0)
   jobsPanel:DockMargin(mainPanel:GetWide() * 0.01, mainPanel:GetWide() * 0.01, mainPanel:GetWide() * 0.01, mainPanel:GetWide() * 0.01)
 
   function jobsPanel:Paint(w, h)
     draw.RoundedBox(0, 0, 0, w, h, DarkRP.Library.ColorNuance(DarkRP.Config.Colors["Secondary"], 15))
     draw.SimpleText("Métiers", DarkRP.Library.Font(12, 0, "Montserrat Bold"), w * 0.5, h * 0.035, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
   end
 
   local jobsScroll = vgui.Create("DScrollPanel", jobsPanel)
   jobsScroll:Dock(FILL)
   jobsScroll:DockMargin(jobsPanel:GetWide() * 0.4, jobsPanel:GetWide() * 0.85, jobsPanel:GetWide() * 0.4, jobsPanel:GetWide() * 0.4)
   jobsScroll:GetVBar():SetWide(0)
 
   function jobsScroll:Paint(w, h)
   end
 
   for k, v in pairs(DarkRP.getCategories().jobs) do
     local categoryPanel = vgui.Create("DPanel", jobsScroll)
     categoryPanel:Dock(TOP)
     categoryPanel:SetTall(ScrH() * 0.05)
     categoryPanel:DockMargin(jobsScroll:GetWide() * 0.05, jobsScroll:GetWide() * 0.05, jobsScroll:GetWide() * 0.05, jobsScroll:GetWide() * 0.05)
     categoryPanel.isExtend = false
     categoryPanel:SetCursor("hand")
 
     function categoryPanel:Paint(w, h)
       draw.RoundedBox(0, 0, 0, w, h, DarkRP.Config.Colors["Main"])
       draw.SimpleText(v.name, DarkRP.Library.Font(12, 0, "Montserrat Bold"), w / 2, DarkRP.ScrH * 0.025, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
       draw.SimpleText(self.isExtend and "-" or "+", DarkRP.Library.Font(12), DarkRP.ScrW * 0.545, DarkRP.ScrH * 0.025, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
     end
 
     local cooldown = 0
 
     local function toggleCategoryPanel()
       if not IsValid(categoryPanel) then return end
       if cooldown > CurTime() then return end
       categoryPanel.isExtend = not categoryPanel.isExtend
       cooldown = CurTime() + 0.2
       categoryPanel:SizeTo(categoryPanel:GetWide(), (categoryPanel.isExtend and categoryPanel:GetTall() * 8 or categoryPanel:GetTall() / 8), 0.2, 0, -1)
     end
 
     function categoryPanel:OnMousePressed()
       toggleCategoryPanel()
     end
 
     local jobsScroll = vgui.Create("DScrollPanel", categoryPanel)
     jobsScroll:Dock(FILL)
     jobsScroll:DockMargin(DarkRP.ScrW *0.005, categoryPanel:GetWide() * 0.8, DarkRP.ScrW *0.005, DarkRP.ScrW *0.005)
     local sbar = jobsScroll:GetVBar()
     sbar:SetHideButtons(true)
     sbar:SetWide(0)
 
     function sbar:Paint(w, h)
       draw.RoundedBox(0, 0, 0, w, h, DarkRP.Library.ColorNuance(DarkRP.Config.Colors["Secondary"], 30))
     end
 
     function sbar.btnGrip:Paint(w, h)
       draw.RoundedBox(0, 0, 0, w, h, DarkRP.Library.ColorNuance(DarkRP.Config.Colors["Secondary"], 10))
     end
 
     function jobsScroll:Paint(w, h)
       draw.RoundedBox(0, 0, 0, w, h, DarkRP.Library.ColorNuance(DarkRP.Config.Colors["Secondary"], 80))
     end
 
     local jobsLayout = vgui.Create("DIconLayout", jobsScroll)
     jobsLayout:Dock(FILL)
     jobsLayout:SetSpaceY(DarkRP.ScrW * 0.0028)
     jobsLayout:SetSpaceX(DarkRP.ScrW * 0.0028)
     jobsLayout:DockMargin(DarkRP.ScrW * 0.0028, DarkRP.ScrW * 0.0028, 0, 0)
 
     for u, o in ipairs(v.members) do
       if o.name == team.GetName(LocalPlayer():Team()) then continue end
       local jobPanel = vgui.Create("DPanel", jobsLayout)
       jobPanel:SetSize(257.9, 257.9)
       jobPanel:SetCursor("hand")
       
 
       function jobPanel:OnMousePressed()
         openDetailsJob(o)
       end
 
       function jobPanel:Paint(w, h)
         draw.RoundedBox(DarkRP.Config.RoundedBoxValue, 0, 0, w, h, DarkRP.Config.Colors["Main"])
         surface.SetDrawColor(DarkRP.Config.Colors["Secondary"])
         surface.DrawOutlinedRect(0, 0, w, h, 4)
 
         draw.SimpleText("Places : " .. team.NumPlayers(o.team) .. "/" .. (o.max == 0 and "∞" or o.max), DarkRP.Library.Font(6, 0, "Montserrat Bold"), w / 2, h * 0.16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
       end
 
       local jobName = vgui.Create("DLabel", jobPanel)
       jobName:SetText(o.name)
       jobName:SetFont(DarkRP.Library.Font(9, 0, "Montserrat Bold"))
       jobName:SetTextColor(color_white)
       jobName:SizeToContents()
       jobName:SetPos(jobPanel:GetWide() / 2 - jobName:GetWide() / 2, jobName:GetTall() * 0.2)
 
       local model = string.find(o.model[1], "models/") and o.model[1] or o.model
       local jobModel = nil
       if not util.IsValidModel(model) then
         jobModel = vgui.Create("DPanel", jobPanel)
         jobModel:SetSize(jobPanel:GetWide() * 0.5, jobPanel:GetWide() * 0.5)
         jobModel:SetPos(jobPanel:GetWide() / 2 - jobModel:GetWide() / 2, jobPanel:GetTall() * 0.2)
 
         function jobModel:Paint(w,h)
           surface.SetDrawColor(color_white)
           surface.SetMaterial(DarkRP.Library.FetchCDN("prisel_main/404"))
           surface.DrawTexturedRect(0, 0, w, h)
         end
       else
         jobModel = vgui.Create("SpawnIcon", jobPanel)
         jobModel:SetSize(jobPanel:GetWide() * 0.58, jobPanel:GetWide() * 0.58)
         jobModel:SetPos(jobPanel:GetWide() / 2 - jobModel:GetWide() / 2, jobPanel:GetTall() * 0.2)
         jobModel:SetModel(model)

         function jobModel:Paint()
            surface.SetDrawColor(DarkRP.Config.Colors["Secondary"])
            surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall(), 4)
            self:DrawModel()
         end
       end
 
 
       function jobModel:OnMousePressed()
         openDetailsJob(o)
       end
 
       local chooseButton = vgui.Create("Prisel.Button", jobPanel)
       chooseButton:SetText("Choisir")
       chooseButton:SetSize(jobPanel:GetWide() * 0.8, jobPanel:GetTall() * 0.15)
       chooseButton:SetPos(jobPanel:GetWide() / 2 - chooseButton:GetWide() / 2, jobPanel:GetTall() * 0.81)
 
       function chooseButton:DoClick()
         if LocalPlayer():Team() == o.team then
           notification.AddLegacy("Vous êtes déjà dans ce métier !", NOTIFY_ERROR, 2)
           return
         end
 
         if o.vote then
           LocalPlayer():ConCommand("say /vote" .. o.command)
         else
           LocalPlayer():ConCommand("say /" .. o.command)
         end
         P3F4Frame:Remove()
       end
     end
   end
 end
 
 local function createEntitiesPanel(mainPanel)
   local entitiesPanel = vgui.Create("DPanel", mainPanel)
   mainChilds["entitiesPanel"] = entitiesPanel
   entitiesPanel:Dock(FILL)
   entitiesPanel:SetAlpha(0)
   entitiesPanel:AlphaTo(255, 0.2, 0)
   entitiesPanel:DockMargin(mainPanel:GetWide() * 0.01, mainPanel:GetWide() * 0.01, mainPanel:GetWide() * 0.01, mainPanel:GetWide() * 0.01)
 
   function entitiesPanel:Paint(w, h)
     draw.RoundedBox(DarkRP.Config.RoundedBoxValue, 0, 0, w, h, DarkRP.Library.ColorNuance(DarkRP.Config.Colors["Secondary"], 15))
     draw.SimpleText("Entitées", DarkRP.Library.Font(12, 0, "Montserrat Bold"), w * 0.5, h * 0.035, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
   end
 
   local entitiesScc = vgui.Create("DScrollPanel", entitiesPanel)
   entitiesScc:Dock(FILL)
   entitiesScc:DockMargin(entitiesPanel:GetWide() * 0.4, entitiesPanel:GetWide() * 0.85, entitiesPanel:GetWide() * 0.4, entitiesPanel:GetWide() * 0.4)
   entitiesScc:GetVBar():SetWide(0)
 
   function entitiesScc:Paint(w, h)
   end
 
   local categ = {}
 
   for k, v in pairs(DarkRP.getCategories().entities) do
     if not v.members then continue end
     if v.canSee ~= nil and not v.canSee() then continue end
     local categoryPanel = vgui.Create("DPanel", entitiesScc)
     categoryPanel:Dock(TOP)
     categoryPanel:SetTall(ScrH() * 0.05)
     categoryPanel:DockMargin(entitiesScc:GetWide() * 0.05, entitiesScc:GetWide() * 0.05, entitiesScc:GetWide() * 0.05, entitiesScc:GetWide() * 0.05)
     categoryPanel.isExtend = false
     categoryPanel:SetCursor("hand")
 
     function categoryPanel:Paint(w, h)
       draw.RoundedBox(DarkRP.Config.RoundedBoxValue, 0, 0, w, h, DarkRP.Config.Colors["Main"])
       draw.SimpleText(v.name, DarkRP.Library.Font(12, 0, "Montserrat Bold"), w / 2, DarkRP.ScrH * 0.025, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
       draw.SimpleText(self.isExtend and "-" or "+", DarkRP.Library.Font(12), DarkRP.ScrW * 0.545, DarkRP.ScrH * 0.025, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
     end
 
     local cooldown = 0
 
     local function toggleCategoryPanel()
       if not IsValid(categoryPanel) then return end
       if cooldown > CurTime() then return end
       categoryPanel.isExtend = not categoryPanel.isExtend
       cooldown = CurTime() + 0.2
       categoryPanel:SizeTo(categoryPanel:GetWide(), (categoryPanel.isExtend and categoryPanel:GetTall() * 8 or categoryPanel:GetTall() / 8), 0.2, 0, -1)
     end
 
     function categoryPanel:OnMousePressed()
       toggleCategoryPanel()
     end
 
     local entitiesScroll = vgui.Create("DScrollPanel", categoryPanel)
     entitiesScroll:Dock(FILL)
     entitiesScroll:DockMargin(DarkRP.ScrW *0.005, categoryPanel:GetWide() * 0.8, DarkRP.ScrW *0.005, DarkRP.ScrW *0.005)
     local sbar = entitiesScroll:GetVBar()
     sbar:SetHideButtons(true)
     sbar:SetWide(0)
 
     function sbar:Paint(w, h)
       draw.RoundedBox(0, 0, 0, w, h, DarkRP.Library.ColorNuance(DarkRP.Config.Colors["Secondary"], 30))
     end
 
     function sbar.btnGrip:Paint(w, h)
       draw.RoundedBox(0, 0, 0, w, h, DarkRP.Library.ColorNuance(DarkRP.Config.Colors["Secondary"], 10))
     end
 
     function entitiesScroll:Paint(w, h)
       draw.RoundedBox(0, 0, 0, w, h, DarkRP.Library.ColorNuance(DarkRP.Config.Colors["Secondary"], 80))
     end
 
     local entitiesLayout = vgui.Create("DIconLayout", entitiesScroll)
     entitiesLayout:Dock(FILL)
     entitiesLayout:SetSpaceY(DarkRP.ScrW * 0.0028)
     entitiesLayout:SetSpaceX(DarkRP.ScrW * 0.0028)
     entitiesLayout:DockMargin(DarkRP.ScrW * 0.0028, DarkRP.ScrW * 0.0028, 0, 0)
 
     categ[categoryPanel] = 0
 
     for u, o in ipairs(v.members) do
       if istable(o.allowed) and not table.HasValue(o.allowed, LocalPlayer():Team()) then 
         continue
       end
       categ[categoryPanel] = categ[categoryPanel] + 1
 
       local entityPanel = vgui.Create("DPanel", entitiesLayout)
       entityPanel:SetSize(DarkRP.ScrW * 0.107, DarkRP.ScrW * 0.107)
       entityPanel:SetCursor("hand")
       
       function entityPanel:Paint(w, h)
         draw.RoundedBox(DarkRP.Config.RoundedBoxValue, 0, 0, w, h, DarkRP.Config.Colors["Main"])
         surface.SetDrawColor(DarkRP.Config.Colors["Secondary"])
         surface.DrawOutlinedRect(0, 0, w, h, 4)
       end
       
       local entitiesName = vgui.Create("DLabel", entityPanel)
       entitiesName:SetFont(DarkRP.Library.Font(7.3, 0, "Montserrat Bold"))
       entitiesName:SetText(o.name)
       entitiesName:SetTextColor(color_white)
       entitiesName:SizeToContents()
       entitiesName:SetPos(entityPanel:GetWide() / 2 - entitiesName:GetWide() / 2, entityPanel:GetTall() * 0.05)
       
       entityPanel.PerformLayout = function(self)
           entitiesName:SizeToContents()
           entitiesName:SetPos(entityPanel:GetWide() / 2 - entitiesName:GetWide() / 2, entityPanel:GetTall() * 0.05)
       end
 
       local entitiesModel = vgui.Create("DModelPanel", entityPanel)
       entitiesModel:SetSize(entityPanel:GetWide() * 0.95, entityPanel:GetTall() * 0.8)
       entitiesModel:SetModel(o.model)
       entitiesModel:SetPos(entityPanel:GetWide() / 2 - entitiesModel:GetWide() / 2, entityPanel:GetTall() / 2 - entitiesModel:GetTall() / 2)
       local mn, mx = entitiesModel.Entity:GetRenderBounds()
       local size = math.max(math.abs(mn.x) + math.abs(mx.x), math.abs(mn.y) + math.abs(mx.y), math.abs(mn.z) + math.abs(mx.z))
       entitiesModel:SetFOV(90)
       entitiesModel:SetCamPos(Vector(size, size, size))
       entitiesModel:SetLookAt((mn + mx) * 0.5)
 
       local buttonBuy = vgui.Create("Prisel.Button", entityPanel)
       buttonBuy:SetSize(entityPanel:GetWide() * 0.95, entityPanel:GetTall() * 0.18)
       buttonBuy:SetPos(entityPanel:GetWide() / 2 - buttonBuy:GetWide() / 2, entityPanel:GetTall()*0.805)
       buttonBuy:SetText(DarkRP.formatMoney(o.price))
       buttonBuy:SetFont(DarkRP.Library.Font(7.3, 0, "Montserrat Bold"))
       
       function buttonBuy:DoClick()
         if LocalPlayer():canAfford(o.price) then
           LocalPlayer():ConCommand("say /" .. o.cmd)
         else
           notification.AddLegacy("Vous n'avez pas assez d'argent pour acheter ceci !", NOTIFY_ERROR, 5)
           surface.PlaySound("buttons/button10.wav")
         end
       end
 
 
     end
 
     if categ[categoryPanel] == 0 then
       categoryPanel:Remove()
     end
   end
 end
 
 local lerps = {}
 lerps.currentMoney = 0
 lerps.totalMoney = 0
 
 local function showDashboard()
   local dashboardPanel = vgui.Create("DPanel", mainPanel)
   mainChilds["dashboardPanel"] = dashboardPanel
   dashboardPanel:Dock(FILL)
   dashboardPanel:SetAlpha(0)
   dashboardPanel:AlphaTo(255, 0.2, 0)
   dashboardPanel:DockMargin(mainPanel:GetWide() * 0.01, mainPanel:GetWide() * 0.01, mainPanel:GetWide() * 0.01, mainPanel:GetWide() * 0.01)
 
   function dashboardPanel:Paint(w, h)
     draw.RoundedBox(DarkRP.Config.RoundedBoxValue, 0, 0, w, h, DarkRP.Config.Colors["Secondary"])
     draw.SimpleText("Tableau de bord", DarkRP.Library.Font(12, 0, "Montserrat Bold"), w * 0.5, h * 0.035, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
   end
 
   local cardPlayers = vgui.Create("DPanel", dashboardPanel)
   cardPlayers:SetSize(DarkRP.ScrW * .12, DarkRP.ScrW * .12)
   cardPlayers:SetPos(DarkRP.ScrW*0.01, DarkRP.ScrH*0.05)
 
   function cardPlayers:Paint(w, h)
     draw.RoundedBox(0, 0, 0, w, h, DarkRP.Config.Colors["Main"])
   end
 
   local cardPlayersText = vgui.Create("DLabel", cardPlayers)
   cardPlayersText:SetText(LocalPlayer():Nick())
   cardPlayersText:SetFont(DarkRP.Library.Font(10, 0, "Montserrat Bold"))
   cardPlayersText:SetTextColor(color_white)
   cardPlayersText:SizeToContents()
   cardPlayersText:SetPos(cardPlayers:GetWide() / 2 - cardPlayersText:GetWide() / 2, cardPlayers:GetTall() * 0.05)
 
   local cardPlayersAvatar = vgui.Create("Prisel.AvatarRounded", cardPlayers)
   cardPlayersAvatar:SetSize(cardPlayers:GetWide() * 0.58, cardPlayers:GetWide() * 0.58)
   cardPlayersAvatar:SetPos(cardPlayers:GetWide() / 2 - cardPlayersAvatar:GetWide() / 2, cardPlayers:GetTall() * 0.2)
   cardPlayersAvatar:SetPlayer(LocalPlayer(), 128)
 
   local jobsPlayerText = vgui.Create("DLabel", cardPlayers)
   jobsPlayerText:SetText(team.GetName(LocalPlayer():Team()))
   jobsPlayerText:SetFont(DarkRP.Library.Font(8))
   jobsPlayerText:SetTextColor(color_white)
   jobsPlayerText:SizeToContents()
   jobsPlayerText:SetPos(cardPlayers:GetWide() / 2 - jobsPlayerText:GetWide() / 2, cardPlayers:GetTall() * 0.825)
 
   local cardPlayerWallet = vgui.Create("DPanel", dashboardPanel)
   cardPlayerWallet:SetSize(DarkRP.ScrW * .12, DarkRP.ScrW * .12)
   cardPlayerWallet:SetPos(DarkRP.ScrW*0.135, DarkRP.ScrH*0.05)
   
   function cardPlayerWallet:Paint(w, h)
     draw.RoundedBox(0, 0, 0, w, h, DarkRP.Config.Colors["Main"])
     surface.SetDrawColor(color_white)
     surface.SetMaterial(DarkRP.Library.FetchCDN("prisel_hud/portefeuille"))
     surface.DrawTexturedRect(w/2 - w*0.3, h/2-h*0.3, w * 0.6, h * 0.6)
   end
 
   local cardPlayerWalletText = vgui.Create("DLabel", cardPlayerWallet)
   cardPlayerWalletText:SetText("Porte-monnaie")
   cardPlayerWalletText:SetFont(DarkRP.Library.Font(10, 0, "Montserrat Bold"))
   cardPlayerWalletText:SetTextColor(color_white)
   cardPlayerWalletText:SizeToContents()
   cardPlayerWalletText:SetPos(cardPlayerWallet:GetWide() / 2 - cardPlayerWalletText:GetWide() / 2, cardPlayerWallet:GetTall() * 0.05)
   
   local cardPlayerWalletAmount = vgui.Create("DLabel", cardPlayerWallet)
   cardPlayerWalletAmount:SetText(DarkRP.formatMoney(LocalPlayer():getDarkRPVar("money")))
   cardPlayerWalletAmount:SetFont(DarkRP.Library.Font(8))
   cardPlayerWalletAmount:SetTextColor(color_white)
   cardPlayerWalletAmount:SizeToContents()
   cardPlayerWalletAmount:SetPos(cardPlayerWallet:GetWide() / 2 - cardPlayerWalletAmount:GetWide() / 2, cardPlayerWallet:GetTall() * 0.825)
 
   cardPlayerWalletAmount.Think = function()
     lerps.currentMoney = Lerp(FrameTime()*5, lerps.currentMoney, LocalPlayer():getDarkRPVar("money"))
     if lerps.currentMoney ~= LocalPlayer():getDarkRPVar("money") then
       cardPlayerWalletAmount:SetText(DarkRP.formatMoney(math.Round(lerps.currentMoney)))
       cardPlayerWalletAmount:SizeToContents()
       cardPlayerWalletAmount:SetPos(cardPlayerWallet:GetWide() / 2 - cardPlayerWalletAmount:GetWide() / 2, cardPlayerWallet:GetTall() * 0.825)
     end
   end
 
   local totalEco = 0
   for k, v in pairs(player.GetAll()) do
     totalEco = totalEco + v:getDarkRPVar("money")
   end
 
   local cardServerWallet = vgui.Create("DPanel", dashboardPanel)
   cardServerWallet:SetSize(DarkRP.ScrW * .12, DarkRP.ScrW * .12)
   cardServerWallet:SetPos(DarkRP.ScrW*0.26, DarkRP.ScrH*0.05)
 
   function cardServerWallet:Paint(w, h)
     draw.RoundedBox(0, 0, 0, w, h, DarkRP.Config.Colors["Main"])
     surface.SetDrawColor(color_white)
     surface.SetMaterial(DarkRP.Library.FetchCDN("prisel_hud/coffre-fort"))
     surface.DrawTexturedRect(w/2 - w*0.3, h/2-h*0.3, w * 0.6, h * 0.6)
   end
 
   local cardServerWalletText = vgui.Create("DLabel", cardServerWallet)
   cardServerWalletText:SetText("Économie Totale")
   cardServerWalletText:SetFont(DarkRP.Library.Font(10, 0, "Montserrat Bold"))
   cardServerWalletText:SetTextColor(color_white)
   cardServerWalletText:SizeToContents()
   cardServerWalletText:SetPos(cardServerWallet:GetWide() / 2 - cardServerWalletText:GetWide() / 2, cardServerWallet:GetTall() * 0.05)
 
   local cardServerWalletAmount = vgui.Create("DLabel", cardServerWallet)
   cardServerWalletAmount:SetText(DarkRP.formatMoney(totalEco))
   cardServerWalletAmount:SetFont(DarkRP.Library.Font(8))
   cardServerWalletAmount:SetTextColor(color_white)
   cardServerWalletAmount:SizeToContents()
   cardServerWalletAmount:SetPos(cardServerWallet:GetWide() / 2 - cardServerWalletAmount:GetWide() / 2, cardServerWallet:GetTall() * 0.825)
 
   checkEco = CurTime() + 2
 
   cardServerWalletAmount.Think = function()
     lerps.totalMoney = Lerp(FrameTime()*5, lerps.totalMoney, totalEco)
     if lerps.totalMoney ~= totalEco then
       cardServerWalletAmount:SetText(DarkRP.formatMoney(math.Round(lerps.totalMoney)))
       cardServerWalletAmount:SizeToContents()
       cardServerWalletAmount:SetPos(cardServerWallet:GetWide() / 2 - cardServerWalletAmount:GetWide() / 2, cardServerWallet:GetTall() * 0.825)
     end
     if checkEco < CurTime() then
       checkEco = CurTime() + 2
       totalEco = 0
       for k, v in pairs(player.GetAll()) do
         totalEco = totalEco + (v:getDarkRPVar("money") or 0)
       end
     end
   end
 
   local cardPlayerTime = vgui.Create("DPanel", dashboardPanel)
   cardPlayerTime:SetSize(DarkRP.ScrW * .194, DarkRP.ScrW * .12)
   cardPlayerTime:SetPos(DarkRP.ScrW*0.385, DarkRP.ScrH*0.05)
 
   function cardPlayerTime:Paint(w, h)
     draw.RoundedBox(0, 0, 0, w, h, DarkRP.Config.Colors["Main"])
     surface.SetDrawColor(color_white)
     surface.SetMaterial(DarkRP.Library.FetchCDN("prisel_hud/horloge"))
     surface.DrawTexturedRect(w/2 - h * 0.6/2, h/2-h * 0.6/2, h * 0.6, h * 0.6)
   end
 
   local cardPlayerTimeText = vgui.Create("DLabel", cardPlayerTime)
   cardPlayerTimeText:SetText("Temps de jeu")
   cardPlayerTimeText:SetFont(DarkRP.Library.Font(10, 0, "Montserrat Bold"))
   cardPlayerTimeText:SetTextColor(color_white)
   cardPlayerTimeText:SizeToContents()
   cardPlayerTimeText:SetPos(cardPlayerTime:GetWide() / 2 - cardPlayerTimeText:GetWide() / 2, cardPlayerTime:GetTall() * 0.05)
 
   local cardPlayerTimeAmount = vgui.Create("DLabel", cardPlayerTime)
   cardPlayerTimeAmount:SetText(sam.format_length((LocalPlayer():GetUTimeTotalTime() or 0)/60))
   cardPlayerTimeAmount:SetFont(DarkRP.Library.Font(8))
   cardPlayerTimeAmount:SetTextColor(color_white)
   cardPlayerTimeAmount:SizeToContents()
   cardPlayerTimeAmount:SetPos(cardPlayerTime:GetWide() / 2 - cardPlayerTimeAmount:GetWide() / 2, cardPlayerTime:GetTall() * 0.825)
 
   local cardGraph = vgui.Create("DPanel", dashboardPanel)
   cardGraph:SetSize(DarkRP.ScrW * .57, DarkRP.ScrW * .232)
   cardGraph:SetPos(DarkRP.ScrW*0.01, DarkRP.ScrH*0.28)
 
   function cardGraph:Paint(w, h)
     draw.RoundedBox(0, 0, 0, w, h, DarkRP.Config.Colors["Main"])
   end
 
   local cardGraphText = vgui.Create("DLabel", cardGraph)
   cardGraphText:SetText("Graphique du serveur")
   cardGraphText:SetFont(DarkRP.Library.Font(10, 0, "Montserrat Bold"))
   cardGraphText:SetTextColor(color_white)
   cardGraphText:SizeToContents()
   cardGraphText:SetPos(cardGraph:GetWide() / 2 - cardGraphText:GetWide() / 2, cardGraph:GetTall() * 0.05)
 
   local cardGraphAmount = vgui.Create("Prisel.GraphBarre", cardGraph)
   cardGraphAmount:SetSize(cardGraph:GetWide() * 0.9, cardGraph:GetTall() * 0.8)
   cardGraphAmount:SetPos(cardGraph:GetWide() * 0.05, cardGraph:GetTall() * 0.15)
   cardGraphAmount:AddData("Connexions", infosServ["connect"])
   cardGraphAmount:AddData("Déconnexions", infosServ["disconnect"])
   cardGraphAmount:AddData("Tués", infosServ["kill"])
   cardGraphAmount:AddData("Morts", infosServ["death"])
 end
 
 function createWeaponsPanel(mainPanel)
   local weaponPanel = vgui.Create("DPanel", mainPanel)
   mainChilds["weaponPanel"] = weaponPanel
   weaponPanel:Dock(FILL)
   weaponPanel:SetAlpha(0)
   weaponPanel:AlphaTo(255, 0.2, 0)
   weaponPanel:DockMargin(mainPanel:GetWide() * 0.01, mainPanel:GetWide() * 0.01, mainPanel:GetWide() * 0.01, mainPanel:GetWide() * 0.01)
 
   function weaponPanel:Paint(w, h)
     draw.RoundedBox(DarkRP.Config.RoundedBoxValue, 0, 0, w, h, DarkRP.Library.ColorNuance(DarkRP.Config.Colors["Secondary"], 15))
     draw.SimpleText("Armes", DarkRP.Library.Font(12, 0, "Montserrat Bold"), w * 0.5, h * 0.035, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
   end
 
   local weaponScroll = vgui.Create("DScrollPanel", weaponPanel)
   weaponScroll:Dock(FILL)
   weaponScroll:DockMargin(weaponPanel:GetWide() * 0.4, weaponPanel:GetWide() * 0.85, weaponPanel:GetWide() * 0.4, weaponPanel:GetWide() * 0.4)
   weaponScroll:GetVBar():SetWide(0)
 
   function weaponScroll:Paint(w, h)
   end
 
   local categ = {}
 
   for k, v in ipairs(DarkRP.getCategories().shipments) do
     if not v.members then continue end
     local categoryPanel = vgui.Create("DPanel", weaponScroll)
     categoryPanel:Dock(TOP)
     categoryPanel:SetTall(ScrH() * 0.05)
     categoryPanel:DockMargin(weaponScroll:GetWide() * 0.05, weaponScroll:GetWide() * 0.05, weaponScroll:GetWide() * 0.05, weaponScroll:GetWide() * 0.05)
     categoryPanel.isExtend = false
     categoryPanel:SetCursor("hand")
     categ[k] = 0
 
     function categoryPanel:Paint(w, h)
       draw.RoundedBox(DarkRP.Config.RoundedBoxValue, 0, 0, w, h, DarkRP.Config.Colors["Main"])
       draw.SimpleText(v.name, DarkRP.Library.Font(12, 0, "Montserrat Bold"), w / 2, DarkRP.ScrH * 0.025, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
       draw.SimpleText(self.isExtend and "-" or "+", DarkRP.Library.Font(12), DarkRP.ScrW * 0.545, DarkRP.ScrH * 0.025, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
     end
 
     local cooldown = 0
 
     local function toggleCategoryPanel()
       if not IsValid(categoryPanel) then return end
       if cooldown > CurTime() then return end
       categoryPanel.isExtend = not categoryPanel.isExtend
       cooldown = CurTime() + 0.2
       categoryPanel:SizeTo(categoryPanel:GetWide(), (categoryPanel.isExtend and categoryPanel:GetTall() * 8 or categoryPanel:GetTall() / 8), 0.2, 0, -1)
     end
 
     function categoryPanel:OnMousePressed()
       toggleCategoryPanel()
     end
 
     local weaponScroll = vgui.Create("DScrollPanel", categoryPanel)
     weaponScroll:Dock(FILL)
     weaponScroll:DockMargin(DarkRP.ScrW *0.005, categoryPanel:GetWide() * 0.8, DarkRP.ScrW *0.005, DarkRP.ScrW *0.005)
     local sbar = weaponScroll:GetVBar()
     sbar:SetHideButtons(true)
     sbar:SetWide(0)
 
     function sbar:Paint(w, h)
       draw.RoundedBox(0, 0, 0, w, h, DarkRP.Library.ColorNuance(DarkRP.Config.Colors["Secondary"], 30))
     end
 
     function sbar.btnGrip:Paint(w, h)
       draw.RoundedBox(0, 0, 0, w, h, DarkRP.Library.ColorNuance(DarkRP.Config.Colors["Secondary"], 10))
     end
 
     function weaponScroll:Paint(w, h)
       draw.RoundedBox(0, 0, 0, w, h, DarkRP.Library.ColorNuance(DarkRP.Config.Colors["Secondary"], 80))
     end
 
     local weaponsLayout = vgui.Create("DIconLayout", weaponScroll)
     weaponsLayout:Dock(FILL)
     weaponsLayout:SetSpaceY(DarkRP.ScrW * 0.0028)
     weaponsLayout:SetSpaceX(DarkRP.ScrW * 0.0028)
     weaponsLayout:DockMargin(DarkRP.ScrW * 0.0028, DarkRP.ScrW * 0.0028, 0, 0)
 
     for u, o in ipairs(CustomShipments) do
       if not o.category then continue end
       if o.category ~= v.name then continue end
       if o.customCheck and not o.customCheck(LocalPlayer()) then continue end
       if o.allowed and not table.HasValue(o.allowed, LocalPlayer():Team()) then continue end
       categ[k] = (categ[k] + 1) or 1
       local weaponPanel = vgui.Create("DPanel", weaponsLayout)
       weaponPanel:SetSize(257.9, 257.9)
 
       function weaponPanel:Paint(w, h)
         draw.RoundedBox(DarkRP.Config.RoundedBoxValue, 0, 0, w, h, DarkRP.Config.Colors["Main"])
         surface.SetDrawColor(DarkRP.Config.Colors["Secondary"])
         surface.DrawOutlinedRect(0, 0, w, h, 4)
       end
 
       local weaponLabel = vgui.Create("DLabel", weaponPanel)
       weaponLabel:SetFont(DarkRP.Library.Font(7.3, 0, "Montserrat Bold"))
       weaponLabel:SetText(o.name)
       weaponLabel:SetTextColor(color_white)
       weaponLabel:SizeToContents()
       weaponLabel:SetPos(weaponPanel:GetWide() / 2 - weaponLabel:GetWide() / 2, weaponPanel:GetTall() * 0.05)
       
       weaponPanel.PerformLayout = function(self)
           weaponLabel:SizeToContents()
           weaponLabel:SetPos(weaponPanel:GetWide() / 2 - weaponLabel:GetWide() / 2, weaponPanel:GetTall() * 0.05)
       end
 
       local weaponModel = vgui.Create("DModelPanel", weaponPanel)
       weaponModel:SetSize(weaponPanel:GetWide() * 0.95, weaponPanel:GetTall() * 0.8)
       weaponModel:SetModel(o.model)
       weaponModel:SetPos(weaponPanel:GetWide() / 2 - weaponModel:GetWide() / 2, weaponPanel:GetTall() / 2 - weaponModel:GetTall() / 2)
       local mn, mx = weaponModel.Entity:GetRenderBounds()
       local size = math.max(math.abs(mn.x) + math.abs(mx.x), math.abs(mn.y) + math.abs(mx.y), math.abs(mn.z) + math.abs(mx.z))
       weaponModel:SetFOV(50)
       weaponModel:SetCamPos(Vector(size, size, size))
       weaponModel:SetLookAt((mn + mx) * 0.5)
 
       local buttonBuy = vgui.Create("Prisel.Button", weaponPanel)
       buttonBuy:SetSize(weaponPanel:GetWide() * 0.95, weaponPanel:GetTall() * 0.18)
       buttonBuy:SetPos(weaponPanel:GetWide() / 2 - buttonBuy:GetWide() / 2, weaponPanel:GetTall()*0.805)
       buttonBuy:SetText(DarkRP.formatMoney(o.price))
       buttonBuy:SetFont(DarkRP.Library.Font(7.3, 0, "Montserrat Bold"))
       
       function buttonBuy:DoClick()
         if LocalPlayer():canAfford(o.price) then
           print(o.name)
           RunConsoleCommand("DarkRP", "buyshipment", o.name)
         else
           notification.AddLegacy("Vous n'avez pas assez d'argent pour acheter ceci !", NOTIFY_ERROR, 5)
           surface.PlaySound("buttons/button10.wav")
         end
       end
     end
 
     if categ[k] == 0 then
       categoryPanel:Remove()
     end
   end
 end
 
 local buttonsF4 = {
   { Name = "Acceuil", func = showDashboard },
   { Name = "Métiers", func = createJobsPanel },
   { Name = "Entités", func = createEntitiesPanel },
   { Name = "Commandes", func = function() print("ok") end},
   { Name = "Armes", func = createWeaponsPanel, customCheck = function()
     return (team.GetName(LocalPlayer():Team()) == "Vendeur d'armes") or (team.GetName(LocalPlayer():Team()) == "Marchand Noir")
   end },
 }
 
 local function openF4()
   if IsFirstTimePredicted() then return end
   PriselHUD.ActiveLogo = false
   P3F4Frame = vgui.Create("Prisel.Frame")
   P3F4Frame:SetSize(ScrW() * 0.8, ScrH() * 0.8)
   P3F4Frame:Center()
   P3F4Frame:MakePopup()
   P3F4Frame:SetTitle("Menu Principal - Prisel.fr")
   P3F4Frame:SetDescription("Le seul serveur géré par la communautée !")
   net.Start("PriselV3::F4:Graph:SendInfos")
   net.SendToServer()
 
 
   timer.Simple(0.5, function()
     function P3F4Frame:Think()
       if input.IsKeyDown(KEY_F4) then
         P3F4Frame:Close()
         PriselHUD.ActiveLogo = true
       end
     end
   end)
 
   function P3F4Frame:OnClose()
     PriselHUD.ActiveLogo = true
   end
 
   local leftPanel = vgui.Create("DPanel", P3F4Frame)
   leftPanel:Dock(LEFT)
   leftPanel:SetWide(P3F4Frame:GetWide() * 0.25)
   leftPanel:DockMargin(0, P3F4Frame:GetTall() * 0.092, 0, 0)
 
   function leftPanel:Paint(w, h)
     draw.RoundedBox(DarkRP.Config.RoundedBoxValue, 0, 0, w, h, DarkRP.Library.ColorNuance(DarkRP.Config.Colors["Secondary"], 15))
   end
 
   for k, v in pairs(buttonsF4) do
     if v.customCheck and not v.customCheck() then continue end
     local button = vgui.Create("Prisel.Button", leftPanel)
     button:Dock(TOP)
     button:DockMargin(leftPanel:GetWide() * 0.1, leftPanel:GetTall() * 0.5, leftPanel:GetWide() * 0.1, 0)
     button:SetText(v.Name)
     button:SetTall(ScrH() * 0.05)
     button:SetContentAlignment(4)
 
     function button:DoClick()
       removeValidPanels()
       v.func(mainPanel)
     end
   end
 
   local discordButton = vgui.Create("Prisel.Button", leftPanel)
   discordButton:Dock(BOTTOM)
   discordButton:DockMargin(leftPanel:GetWide() * 0.1, 0, leftPanel:GetWide() * 0.1, leftPanel:GetTall() * 0.5)
   discordButton:SetText("Discord")
   discordButton:SetTall(ScrH() * 0.05)
   discordButton:SetContentAlignment(4)
 
   function discordButton:DoClick()
     gui.OpenURL(DarkRP.Config.DiscordURL)
   end
 
   local collectionButton = vgui.Create("Prisel.Button", leftPanel)
   collectionButton:Dock(BOTTOM)
   collectionButton:DockMargin(leftPanel:GetWide() * 0.1, 0, leftPanel:GetWide() * 0.1, leftPanel:GetTall() * 0.5)
   collectionButton:SetText("Collection")
   collectionButton:SetTall(ScrH() * 0.05)
   collectionButton:SetContentAlignment(4)
 
   function collectionButton:DoClick()
     gui.OpenURL(DarkRP.Config.CollectionURL)
   end
 
   local boutiqueButton = vgui.Create("Prisel.Button", leftPanel)
   boutiqueButton:Dock(BOTTOM)
   boutiqueButton:DockMargin(leftPanel:GetWide() * 0.1, 0, leftPanel:GetWide() * 0.1, leftPanel:GetTall() * 0.5)
   boutiqueButton:SetText("Boutique")
   boutiqueButton:SetTall(ScrH() * 0.05)
   boutiqueButton:SetContentAlignment(4)
 
   function boutiqueButton:DoClick()
     gui.OpenURL(DarkRP.Config.BoutiqueURL)
   end
 
 
   mainPanel = vgui.Create("DPanel", P3F4Frame)
   mainPanel:Dock(FILL)
   mainPanel:DockMargin(0, P3F4Frame:GetTall() * 0.092, 0, 0)
 
   function mainPanel:Paint(w, h)
   end
 
   timer.Simple(0.1, function()
     removeValidPanels()
     showDashboard()
   end)
 
   return true
 end
 
 hook.Add("ShowSpare2", "Prisel:V3::OpenF4", openF4)
 
 net.Receive("PriselV3::F4:Graph:SendInfos", function()
   infosServ = net.ReadTable()
 end)