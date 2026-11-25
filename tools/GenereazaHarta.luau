-- GenereazaHarta.luau
-- Construiește harta "Arhipelagul Comorilor" (vezi docs/harta.md) direct în Workspace.
-- Cum îl rulezi: în Roblox Studio -> View -> Command Bar, lipești TOT scriptul și apeși Enter.
-- Poți să-l rulezi de mai multe ori: șterge harta veche și o face din nou.
-- Ctrl+Z anulează generarea.

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Lighting = game:GetService("Lighting")

local rng = Random.new(42) -- aceeași hartă de fiecare dată; schimbă numărul pentru alte forme

-- curățenie: harta veche + piesele din template-ul Baseplate
for _, name in { "Harta", "Baseplate", "SpawnLocation" } do
	local old = workspace:FindFirstChild(name)
	if old then
		old:Destroy()
	end
end

local harta = Instance.new("Folder")
harta.Name = "Harta"
harta.Parent = workspace

local function folder(name, parent)
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end

local C = {
	Apa = Color3.fromRGB(38, 196, 196),
	Nisip = Color3.fromRGB(235, 214, 155),
	Iarba = Color3.fromRGB(86, 170, 72),
	Lemn = Color3.fromRGB(122, 82, 44),
	LemnInchis = Color3.fromRGB(90, 58, 30),
	Frunze = Color3.fromRGB(52, 140, 60),
	Piatra = Color3.fromRGB(120, 112, 104),
	Vulcan = Color3.fromRGB(92, 70, 58),
	Lava = Color3.fromRGB(255, 90, 30),
	Acoperis = Color3.fromRGB(196, 104, 52),
	Aur = Color3.fromRGB(255, 200, 40),
	Recif = Color3.fromRGB(150, 230, 220),
	ZonaSigura = Color3.fromRGB(76, 255, 122),
}

local UP = CFrame.Angles(0, 0, math.rad(90)) -- întoarce un Cylinder ca să stea "în picioare"
local SAND_TOP = 1.5
local GRASS_TOP = 2.5

local function part(props)
	local p = Instance.new(props.Class or "Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = props.Material or Enum.Material.SmoothPlastic
	if props.Shape then
		p.Shape = props.Shape
	end
	p.Size = props.Size
	p.CFrame = props.CFrame
	p.Color = props.Color or Color3.new(1, 1, 1)
	p.Name = props.Name or "Part"
	if props.Transparency then
		p.Transparency = props.Transparency
	end
	if props.CanCollide ~= nil then
		p.CanCollide = props.CanCollide
	end
	if props.CanCollide == false then
		p.CanTouch = props.CanTouch == true
		p.CanQuery = false
	end
	p.Parent = props.Parent
	return p
end

-- disc vertical (cilindru) cu partea de sus la înălțimea topY
local function disc(parent, x, z, radius, height, topY, color, material, name)
	return part({
		Name = name,
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(height, radius * 2, radius * 2),
		CFrame = CFrame.new(x, topY - height / 2, z) * UP,
		Color = color,
		Material = material,
		Parent = parent,
	})
end

---------------------------------------------------------------------------
-- Ocean + margini
---------------------------------------------------------------------------
local ocean = part({
	Name = "Ocean",
	Size = Vector3.new(2000, 2, 2000),
	CFrame = CFrame.new(0, -1, 0), -- suprafața apei la Y = 0
	Color = C.Apa,
	Material = Enum.Material.SmoothPlastic,
	Parent = harta,
})
ocean.Reflectance = 0.08

local margini = folder("Margini", harta)
for _, w in {
	{ Vector3.new(2000, 80, 4), Vector3.new(0, 40, -1002) },
	{ Vector3.new(2000, 80, 4), Vector3.new(0, 40, 1002) },
	{ Vector3.new(4, 80, 2000), Vector3.new(-1002, 40, 0) },
	{ Vector3.new(4, 80, 2000), Vector3.new(1002, 40, 0) },
} do
	part({
		Name = "PereteInvizibil",
		Size = w[1],
		CFrame = CFrame.new(w[2]),
		Transparency = 1,
		Parent = margini,
	})
end

---------------------------------------------------------------------------
-- Zone libere (fără palmieri): case, fort, vulcan, cufere
---------------------------------------------------------------------------
local zoneLibere = {}
local function liber(x, z, r)
	table.insert(zoneLibere, { x = x, z = z, r = r })
end
local function eLiber(x, z)
	for _, zl in zoneLibere do
		local dx, dz = x - zl.x, z - zl.z
		if dx * dx + dz * dz < zl.r * zl.r then
			return false
		end
	end
	return true
end

---------------------------------------------------------------------------
-- Palmier
---------------------------------------------------------------------------
local function palmier(parent, x, z)
	local m = Instance.new("Model")
	m.Name = "Palmier"
	local h = rng:NextNumber(12, 18)
	local tilt = CFrame.Angles(math.rad(rng:NextNumber(-8, 8)), 0, math.rad(rng:NextNumber(-8, 8)))
	local base = CFrame.new(x, GRASS_TOP, z) * tilt
	part({
		Name = "Trunchi",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(h, 1.6, 1.6),
		CFrame = base * CFrame.new(0, h / 2, 0) * UP,
		Color = C.Lemn,
		Material = Enum.Material.Wood,
		Parent = m,
	})
	local top = base * CFrame.new(0, h, 0)
	local rot0 = rng:NextNumber(0, 360)
	for i = 1, 6 do
		local yaw = math.rad(rot0 + i * 60)
		part({
			Name = "Frunza",
			Size = Vector3.new(2.4, 0.3, 9),
			CFrame = top * CFrame.Angles(0, yaw, 0) * CFrame.Angles(math.rad(-25), 0, 0) * CFrame.new(0, 0, -4.2),
			Color = C.Frunze,
			Material = Enum.Material.Grass,
			CanCollide = false,
			Parent = m,
		})
	end
	m.Parent = parent
end

---------------------------------------------------------------------------
-- Insulă cu formă neregulată (mai multe discuri suprapuse)
---------------------------------------------------------------------------
local insuleFolder = folder("Insule", harta)

local function insula(nume, x, z, r)
	local f = folder(nume, insuleFolder)
	local lobi = { { 0, 0, 1 } }
	for _ = 1, 5 do
		local a = rng:NextNumber(0, 2 * math.pi)
		local d = rng:NextNumber(0.35, 0.5) * r
		table.insert(lobi, { math.cos(a) * d, math.sin(a) * d, rng:NextNumber(0.45, 0.65) })
	end
	for _, l in lobi do
		disc(f, x + l[1], z + l[2], r * l[3], 6, SAND_TOP, C.Nisip, Enum.Material.Sand, "Nisip")
		disc(f, x + l[1] * 0.8, z + l[2] * 0.8, r * l[3] * 0.78, 6, GRASS_TOP, C.Iarba, Enum.Material.Grass, "Iarba")
	end
	local palmieri = folder("Palmieri", f)
	local n = math.floor(r / 6)
	local incercari = 0
	while n > 0 and incercari < 400 do
		incercari += 1
		local a = rng:NextNumber(0, 2 * math.pi)
		local d = math.sqrt(rng:NextNumber()) * r * 0.65
		local px, pz = x + math.cos(a) * d, z + math.sin(a) * d
		if eLiber(px, pz) then
			palmier(palmieri, px, pz)
			n -= 1
		end
	end
	return f
end

-- zonele libere trebuie declarate ÎNAINTE de insule (ca să nu crească palmieri acolo)
liber(-40, 730, 18) -- casa
liber(50, 750, 18) -- magazin
liber(0, 610, 30) -- debarcader
liber(600, -520, 42) -- fort
liber(-600, -640, 68) -- vulcan
local CUFERE = {
	{ -560, 260 }, { -150, -120 }, { 500, 230 }, { 640, -470 }, { -620, -560 }, { 820, 740 },
}
for _, c in CUFERE do
	liber(c[1], c[2], 9)
end

local insulaPortului = insula("Insula Portului", 0, 740, 150)
insula("Insula Palmierilor", -550, 300, 120)
insula("Insulita Pescarilor", 500, 250, 80)
insula("Insula Pescarusilor", -150, -150, 90)
local insulaCraniului = insula("Insula Craniului", 600, -500, 150)
local insulaVulcanului = insula("Insula Vulcanului", -600, -620, 165)
insula("Stanca Singuratica", 820, 750, 70)

---------------------------------------------------------------------------
-- Portul: debarcader + case
---------------------------------------------------------------------------
local port = folder("Port", insulaPortului)
-- debarcaderul principal (de la insulă spre nord, în apă)
part({ Name = "Debarcader", Size = Vector3.new(10, 1, 100), CFrame = CFrame.new(0, 1.5, 595), Color = C.Lemn, Material = Enum.Material.WoodPlanks, Parent = port })
part({ Name = "Debarcader", Size = Vector3.new(60, 1, 8), CFrame = CFrame.new(0, 1.5, 548), Color = C.Lemn, Material = Enum.Material.WoodPlanks, Parent = port })
for _, px in { -28, -14, 14, 28 } do
	part({ Name = "Stalp", Shape = Enum.PartType.Cylinder, Size = Vector3.new(8, 1.4, 1.4), CFrame = CFrame.new(px, -2, 548) * UP, Color = C.LemnInchis, Material = Enum.Material.Wood, Parent = port })
end
for pz = 560, 640, 20 do
	for _, px in { -5.5, 5.5 } do
		part({ Name = "Stalp", Shape = Enum.PartType.Cylinder, Size = Vector3.new(8, 1.4, 1.4), CFrame = CFrame.new(px, -2, pz) * UP, Color = C.LemnInchis, Material = Enum.Material.Wood, Parent = port })
	end
end

local function casa(nume, x, z, culoareZid)
	local m = Instance.new("Model")
	m.Name = nume
	local zidTop = GRASS_TOP + 10
	part({ Name = "Ziduri", Size = Vector3.new(16, 10, 14), CFrame = CFrame.new(x, GRASS_TOP + 5, z), Color = culoareZid, Material = Enum.Material.WoodPlanks, Parent = m })
	part({ Name = "Usa", Size = Vector3.new(3, 6, 0.4), CFrame = CFrame.new(x, GRASS_TOP + 3, z - 7.1), Color = C.LemnInchis, Material = Enum.Material.Wood, Parent = m })
	-- acoperiș în două ape
	part({ Name = "Acoperis", Size = Vector3.new(18, 0.8, 9), CFrame = CFrame.new(x, zidTop + 2.1, z - 3.7) * CFrame.Angles(math.rad(-30), 0, 0), Color = C.Acoperis, Parent = m })
	part({ Name = "Acoperis", Size = Vector3.new(18, 0.8, 9), CFrame = CFrame.new(x, zidTop + 2.1, z + 3.7) * CFrame.Angles(math.rad(30), 0, 0), Color = C.Acoperis, Parent = m })
	m.Parent = port
	return m
end
casa("Casa", -40, 730, Color3.fromRGB(214, 170, 110))
casa("Magazin", 50, 750, Color3.fromRGB(230, 190, 120))

-- punctul unde apare nava jucătorului (invizibil)
local spawnNava = part({
	Name = "SpawnNava",
	Size = Vector3.new(6, 1, 6),
	CFrame = CFrame.lookAt(Vector3.new(0, 0.5, 525), Vector3.new(0, 0.5, 0)), -- cu fața spre nord (−Z)
	Transparency = 1,
	CanCollide = false,
	Parent = harta,
})
spawnNava:SetAttribute("Descriere", "Aici apare nava jucatorului")

---------------------------------------------------------------------------
-- Vulcanul
---------------------------------------------------------------------------
local vulcan = folder("Vulcan", insulaVulcanului)
local vTop = GRASS_TOP
for i, r in { 60, 48, 37, 27, 19 } do
	vTop += 10
	disc(vulcan, -600, -640, r, 10 + (i == 1 and 4 or 0), vTop, C.Vulcan, Enum.Material.Basalt, "Munte")
end
local lava = disc(vulcan, -600, -640, 13, 1, vTop + 0.3, C.Lava, Enum.Material.Neon, "Lava")
local lumina = Instance.new("PointLight")
lumina.Color = C.Lava
lumina.Range = 40
lumina.Brightness = 3
lumina.Parent = lava

---------------------------------------------------------------------------
-- Fortul pirat de pe Insula Craniului
---------------------------------------------------------------------------
local fort = folder("Fort", insulaCraniului)
local FX, FZ, L, H = 600, -520, 50, 14
local zidY = GRASS_TOP + H / 2
part({ Name = "Zid", Size = Vector3.new(L, H, 3), CFrame = CFrame.new(FX, zidY, FZ - L / 2), Color = C.Piatra, Material = Enum.Material.Cobblestone, Parent = fort })
part({ Name = "Zid", Size = Vector3.new(3, H, L), CFrame = CFrame.new(FX - L / 2, zidY, FZ), Color = C.Piatra, Material = Enum.Material.Cobblestone, Parent = fort })
part({ Name = "Zid", Size = Vector3.new(3, H, L), CFrame = CFrame.new(FX + L / 2, zidY, FZ), Color = C.Piatra, Material = Enum.Material.Cobblestone, Parent = fort })
-- zidul de sud are o poartă la mijloc
part({ Name = "Zid", Size = Vector3.new(L / 2 - 5, H, 3), CFrame = CFrame.new(FX - L / 4 - 2.5, zidY, FZ + L / 2), Color = C.Piatra, Material = Enum.Material.Cobblestone, Parent = fort })
part({ Name = "Zid", Size = Vector3.new(L / 2 - 5, H, 3), CFrame = CFrame.new(FX + L / 4 + 2.5, zidY, FZ + L / 2), Color = C.Piatra, Material = Enum.Material.Cobblestone, Parent = fort })
for _, o in { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } } do
	part({ Name = "Turn", Size = Vector3.new(9, H + 8, 9), CFrame = CFrame.new(FX + o[1] * L / 2, GRASS_TOP + (H + 8) / 2, FZ + o[2] * L / 2), Color = Color3.fromRGB(100, 94, 88), Material = Enum.Material.Cobblestone, Parent = fort })
end
part({ Name = "Catarg", Shape = Enum.PartType.Cylinder, Size = Vector3.new(30, 0.8, 0.8), CFrame = CFrame.new(FX, GRASS_TOP + 15, FZ) * UP, Color = C.LemnInchis, Material = Enum.Material.Wood, Parent = fort })
part({ Name = "SteagPirat", Size = Vector3.new(8, 5, 0.2), CFrame = CFrame.new(FX + 4.4, GRASS_TOP + 27, FZ), Color = Color3.fromRGB(20, 20, 20), Material = Enum.Material.Fabric, Parent = fort })

---------------------------------------------------------------------------
-- Cufere cu comori
---------------------------------------------------------------------------
local cufereFolder = folder("Cufere", harta)
for i, c in CUFERE do
	local m = Instance.new("Model")
	m.Name = "Cufar" .. i
	local cutie = part({ Name = "Cutie", Size = Vector3.new(4, 2.6, 3), CFrame = CFrame.new(c[1], GRASS_TOP + 1.3, c[2]), Color = C.Lemn, Material = Enum.Material.Wood, Parent = m })
	part({ Name = "Capac", Size = Vector3.new(4.2, 0.8, 3.2), CFrame = CFrame.new(c[1], GRASS_TOP + 3, c[2]), Color = C.Aur, Material = Enum.Material.Metal, Parent = m })
	m.PrimaryPart = cutie
	m:SetAttribute("Cufar", true)
	m.Parent = cufereFolder
end

---------------------------------------------------------------------------
-- Recif (stânci decorative + zonă invizibilă care încetinește nava)
---------------------------------------------------------------------------
local recif = folder("Recif", harta)
for _ = 1, 16 do
	local s = rng:NextNumber(4, 10)
	part({
		Name = "Stanca",
		Size = Vector3.new(s, rng:NextNumber(1.5, 3), s * rng:NextNumber(0.6, 1)),
		CFrame = CFrame.new(250 + rng:NextNumber(-55, 55), 0.3, -150 + rng:NextNumber(-35, 35)) * CFrame.Angles(0, rng:NextNumber(0, math.pi), 0),
		Color = C.Recif,
		Material = Enum.Material.Rock,
		CanCollide = false,
		Parent = recif,
	})
end
local zonaRecif = disc(recif, 250, -150, 60, 4, 2, C.Recif, Enum.Material.SmoothPlastic, "ZonaRecif")
zonaRecif.Transparency = 1
zonaRecif.CanCollide = false
zonaRecif.CanQuery = false
zonaRecif:SetAttribute("Viteza", 0.5)

---------------------------------------------------------------------------
-- Zone de joc (pentru scripturile de mai târziu)
---------------------------------------------------------------------------
local zone = folder("Zone", harta)
local function zona(nume, x, z, r, culoare, vizibil)
	local p = disc(zone, x, z, r, 0.2, 0.1, culoare, Enum.Material.SmoothPlastic, nume)
	p.Transparency = vizibil and 0.85 or 1
	p.CanCollide = false
	p.CanQuery = false
	return p
end
zona("ZonaSigura", 0, 700, 320, C.ZonaSigura, true)
zona("ZonaMedie", 0, 700, 650, Color3.fromRGB(255, 210, 63), false)
local periculos = part({
	Name = "ApePericuloase", -- tot nordul: Z < -450
	Size = Vector3.new(2000, 0.2, 550),
	CFrame = CFrame.new(0, 0.05, -725),
	Color = Color3.fromRGB(255, 59, 59),
	Transparency = 1,
	CanCollide = false,
	Parent = zone,
})
periculos:SetAttribute("Pericol", "mare")

---------------------------------------------------------------------------
-- Trasee de patrulare (puncte invizibile, numerotate în ordine)
---------------------------------------------------------------------------
local patrule = folder("Patrule", harta)
local TRASEE = {
	PatrulaSlaba = { { -300, 0 }, { 150, -250 }, { 450, 0 }, { 100, 350 } },
	PatrulaCraniu = { { 250, -750 }, { 850, -650 }, { 850, -250 }, { 350, -300 } },
	PatrulaVulcan = { { -850, -300 }, { -300, -450 }, { -350, -850 }, { -850, -850 } },
}
for nume, puncte in TRASEE do
	local f = folder(nume, patrule)
	for i, p in puncte do
		part({ Name = tostring(i), Size = Vector3.new(2, 2, 2), CFrame = CFrame.new(p[1], 1, p[2]), Transparency = 1, CanCollide = false, Parent = f })
	end
end

---------------------------------------------------------------------------
-- Lumină de zi tropicală + camera deasupra hărții
---------------------------------------------------------------------------
Lighting.ClockTime = 13
Lighting.Brightness = 2.5
Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)

local cam = workspace.CurrentCamera
if cam then
	cam.CFrame = CFrame.lookAt(Vector3.new(0, 1100, 900), Vector3.new(0, 0, 0))
end

ChangeHistoryService:SetWaypoint("Harta generata")
print("✅ Harta 'Arhipelagul Comorilor' a fost generată în Workspace.Harta")
