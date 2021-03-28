local cairo = require("cairo")
local class = require('pl.class')
local tablex = require('pl.tablex')
local ffi = require('ffi')

local PIXELS_PER_METER = 256

require 'poppler'

class.FileSurface(ui.View)

function FileSurface:_init(bounds, assetManager)
    self:super(bounds)

    self.assetManager = assetManager

    -- Pick the sample file to use
    self.sampleFileName = "AlloVR.pdf"

    self.pageCount = 1
    self.currentPage = 1
    self.assets = {}

    self.acceptedFileExtensions = {'pdf', 'jpg', 'jpeg', 'png'}

    local file = "files/" .. self.sampleFileName
    self:loadFile(file)
end


function FileSurface:_renderDoc(doc)
    -- Sets the size of the FileSurface to match the file's size
    local pageSizePx = doc:getPage(1):size()
    self.bounds.size.width = pageSizePx.width/PIXELS_PER_METER
    self.bounds.size.height = pageSizePx.height/PIXELS_PER_METER

    -- Load each page of the file into assets
    for i = 1, doc:pageCount() do
        local page = doc:getPage(i)
        local asset = self:_render(page)
        table.insert(self.assets, asset)
        self.assetManager:add(asset)
    end
    self.pageCount = doc:pageCount()
end

function FileSurface:loadAsset(asset, filename)
    local fileExtension = self:getFileExtension(filename)

    if (fileExtension == ".pdf") then
        -- Use poppler to load the pdf file and read info about it
        self.assets = {}
        self.currentPage = 1
        local doc = Document:load(asset.data)
        self:_renderDoc(doc)
    elseif (fileExtension == ".png" or fileExtension == ".jpg" or fileExtension == ".jpeg") then
        -- TODO: I don't know the width & height of the image, so I'm setting an arbitrary meter width/height of 1
        self.bounds.size.width = 1
        self.bounds.size.height = 1

        asset.name = filename
        self.assets = {asset}
        self.currentPage = #self.assets
        self.assetManager:add(asset)
    else
        print("Error: Unsupported file extension: (" .. fileExtension .. ")")
        return
    end
end

function FileSurface:loadFile(file)
    local fileExtension = self:getFileExtension(file)

    if (fileExtension == ".pdf") then
        -- Use poppler to load the pdf file and read info about it
        local doc = Document:open(file)
        self:_renderDoc(doc)
    elseif (fileExtension == ".png" or fileExtension == ".jpg" or fileExtension == ".jpeg") then
        -- TODO: I don't know the width & height of the image, so I'm setting an arbitrary meter width/height of 1
        self.bounds.size.width = 1
        self.bounds.size.height = 1

        local asset = ui.Asset.File(file)
        asset.name = self.sampleFileName
        table.insert(self.assets, asset)
        self.assetManager:add(asset)
    else
        print("Error: Unsupported file extension: (" .. fileExtension .. ")")
        return
    end
end

function FileSurface:onFileDropped(filename, asset_id)
    -- fetch the asset, give it to the fileSurface to load
    self.assetManager:load(asset_id, function (_, asset)
        if asset then
        self:loadAsset(asset, filename)
        else
        print("Could not reach asset for " .. filename)
        end
    end)
end

function FileSurface:getFileExtension(filename)
    return filename:match("^.+(%..+)$")
end

-- Render a page to an asset
function FileSurface:_render(page)
    local pageSizePx = page:size()

    -- Creates a cairo image surface matching the pixel size of the actual file
    local sr = cairo.image_surface(cairo.cairo_format("rgb24"), pageSizePx.width, pageSizePx.height)
    local cr = sr:context()
    cr:rgb(255, 255, 255)
    cr:paint()
    page:renderToCairoSurface(cr)

    local data = ""
    sr:save_png(function(_, bytes, len)
        data = data..ffi.string(bytes, len)
        return 0
    end, nil)
    return Asset(data)
end

function FileSurface:_material()
    return {
        asset_texture = self.assets[self.currentPage]:id()
    }
end

function FileSurface:specification()
    local s = self.bounds.size
    local w2 = s.width / 2.0
    local h2 = s.height / 2.0
    local mySpec = tablex.union(ui.View.specification(self), {
        geometry = {
            type = "inline",
            --          #tl?                #tr?              #bl?               #br?
            vertices=   {{-w2, h2, 0.0},    {w2, h2, 0.0},    {-w2, -h2, 0.0},   {w2, -h2, 0.0}},
            uvs=        {{0.0, 1.0},        {1.0, 1.0},       {0.0, 0.0},        {1.0, 0.0}},
            triangles=  {{0, 1, 3},         {3, 2, 0},        {0, 2, 3},         {3, 1, 0}},
        },
        collider= {
            type= "box",
            width= s.width, height= s.height, depth= s.depth
        },
        material = self:_material(),
        grabbable = {
            grabbable = true,
            actuate_on= "$parent"
        }
    })

    return mySpec
end

function FileSurface:update()
    self:updateComponents({material = self:_material()})
end


function FileSurface:resize(newWidth, newHeight)
    local oldWidth = self.bounds.size.width
    local oldHeight = self.bounds.size.height

    -- On proceed with resizing if a meaningful resize (more than 1cm) has been made
    if math.abs(oldWidth - newWidth) < 0.01 and math.abs(oldHeight - newHeight) < 0.01 then return end

    self.bounds.size.width = newWidth
    self.bounds.size.height = newHeight

    self:updateComponents(self:specification())
end

function FileSurface:goToNextPage()
    self.currentPage = self.currentPage + 1
    if self.currentPage < 1 then self.currentPage = #self.assets end
    if self.currentPage > #self.assets then self.currentPage = 1 end
    self:update()
end

function FileSurface:goToPreviousPage()
    self.currentPage = self.currentPage - 1
    if self.currentPage < 1 then self.currentPage = #self.assets end
    if self.currentPage > #self.assets then self.currentPage = 1 end
    self:update()
end

return FileSurface
