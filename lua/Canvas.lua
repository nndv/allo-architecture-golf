local cairo = require("cairo")
local class = require("pl.class")
local tablex = require("pl.tablex")
local vec3 = require("modules.vec3")
local mat4 = require("modules.mat4")
local Button = require("Button")
local DiagramItem = require('DiagramItem')

local BOARD_RESOLUTION = 128
local MODE_DRAWING = 0
local MODE_INSERTING = 1

class.Canvas(ui.View)

function Canvas:_init(bounds)
    self:super(bounds)

    self.mode = MODE_INSERTING
    self.isDirty = false
    self.brushSize = 2

    self.accessControlTable = {}

    self.backgroundColor = {1, 1, 1}
    self.brushColor = {0, 0, 0}

    self.sr = cairo.image_surface(cairo.cairo_format("rgb24"), bounds.size.width * BOARD_RESOLUTION, bounds.size.height * BOARD_RESOLUTION)
    self.cr = self.sr:context()

    self:clearBoard()
end

function Canvas:specification()
    self.sr:save_png("canvas.png")

    local fh = io.open("canvas.png", "rb")
    local image_to_convert = fh:read("*a")
    fh:close()
    local encoded_image = ui.util.base64_encode(image_to_convert)

    local s = self.bounds.size
    local w2 = s.width / 2.0
    local h2 = s.height / 2.0
    local mySpec = tablex.union(ui.View.specification(self), {
    geometry = {
        type = "inline",
        --          #tl?                #tr?              #bl?               #br?
        vertices=   {{-w2, h2, 0.0},    {w2, h2, 0.0},    {-w2, -h2, 0.0},   {w2, -h2, 0.0}},
        uvs=        {{0.0, 0.0},        {1.0, 0.0},       {0.0, 1.0},        {1.0, 1.0}},
        triangles=  {{0, 1, 3},         {3, 2, 0},        {0, 2, 3},         {3, 1, 0}},
    },
    collider= {
        type= "box",
        width= s.width, height= s.height, depth= s.depth
    },
    material= {
        texture= encoded_image
    },
    grabbable = {
        grabbable = true,
        actuate_on= "$parent"
    },
    cursor= {
        name= "brushCursor",
        size= self.brushSize
    }
    })

    return mySpec
end

function Canvas:onPointerMoved(pointer)
    if self.mode == MODE_DRAWING then
        local x, y, z = vec3.unpack(pointer.pointedTo)
        self:_attemptToDraw(pointer.hand, x, y, z)
    end
end

function Canvas:onPointerExited(pointer)
    local currentControlTable = self.accessControlTable[pointer.hand]

    if currentControlTable == nil then return end

    currentControlTable.previousCoord = {nil, nil}
end

function Canvas:onTouchDown(pointer)
    local currentControlTable = self.accessControlTable[pointer.hand]

    if currentControlTable == nil then
        self.accessControlTable[pointer.hand] = {allowedToDraw = true, allowedToInsert = true, previousCoord = {x = nil, y= nil}}
    else
        currentControlTable.allowedToDraw = true
        currentControlTable.previousCoord = {x = nil, y= nil}
    end
end

function Canvas:onTouchUp(pointer)
    local currentControlTable = self.accessControlTable[pointer.hand]

    if self.mode == MODE_INSERTING and currentControlTable.allowedToInsert then
        local x, y, z = vec3.unpack(pointer.pointedTo)
        self:_showNewDiagramPopup(pointer.hand, x, y, z)
        currentControlTable.allowedToInsert = false
    else
        currentControlTable.allowedToDraw = false
        currentControlTable.previousCoord = {nil, nil}
    end
end

function Canvas:_attemptToDraw(hand, worldX, worldY, worldZ)
    local currentControlTable = self.accessControlTable[hand]

    if (currentControlTable == nil or currentControlTable.allowedToDraw == false ) then return end

    local worldPoint = vec3(worldX, worldY, worldZ)
    local inverted = mat4.invert({}, self:transformFromWorld())

    local localPoint = vec3(mat4.mul_vec4({}, inverted, {worldPoint.x, worldPoint.y, worldPoint.z, 1}))
    local localPointBottomLeftOrigo = vec3(self.bounds.size.width/2 + localPoint.x, self.bounds.size.height/2 + localPoint.y, self.bounds.size.depth/2 + localPoint.z)

    self:_drawAt(hand, localPointBottomLeftOrigo.x * BOARD_RESOLUTION, localPointBottomLeftOrigo.y * BOARD_RESOLUTION)
end

function Canvas:_drawAt(hand, x, y)
    local currentControlTable = self.accessControlTable[hand]

    self.cr:move_to(x,y)
    self.cr:rgb(table.unpack(self.brushColor))

    if currentControlTable.previousCoord.x ~= nil then
        self.cr:line_cap("round")
        self.cr:line_to(currentControlTable.previousCoord.x, currentControlTable.previousCoord.y)
        self.cr:line_width(self.brushSize*2)
        self.cr:stroke()
    else
        self.cr:circle(x, y, self.brushSize)
        self.cr:fill()
    end

    currentControlTable.previousCoord.x = x
    currentControlTable.previousCoord.y = y

    self.isDirty = true
end

function Canvas:_showNewDiagramPopup(hand, worldX, worldY, worldZ)
    local worldPoint = vec3(worldX, worldY, worldZ)
    local inverted = mat4.invert({}, self:transformFromWorld())

    local localPoint = vec3(mat4.mul_vec4({}, inverted, {worldPoint.x, worldPoint.y, worldPoint.z, 1}))

    local popup = ui.Surface(ui.Bounds{size=ui.Size(1,0.5,0.05)})
    popup:setPointable(true)

    local input = popup:addSubview(ui.TextField{
        bounds= ui.Bounds{size=ui.Size(0.8,0.1,0.05)}:move(0, 0.15, 0.025)
    })

    local addShape = function(shape)
        self:_addDiagramItem(input.label.text, shape, hand, localPoint.x, localPoint.y)
        popup:removeFromSuperview()
    end

    local handleCancel = function()
        popup:removeFromSuperview()
        self.accessControlTable[hand] = nil
    end

    input.onReturn = function()
        return false
    end

    input:askToFocus(hand)

    popup:addSubview(Button(
        ui.Bounds{size=ui.Size(popup.bounds.size.width * 0.2,0.1,0.05),pose=ui.Pose(-popup.bounds.size.width * 0.3, 0, 0.025)},
        function() addShape(assets.square) end,
        {texture=assets.square}
    ))

    popup:addSubview(Button(
        ui.Bounds{size=ui.Size(popup.bounds.size.width * 0.2,0.1,0.05),pose=ui.Pose(0, 0, 0.025)},
        function() addShape(assets.diamond) end,
        {texture=assets.diamond}
    ))

    popup:addSubview(Button(
        ui.Bounds{size=ui.Size(popup.bounds.size.width * 0.2,0.1,0.05),pose=ui.Pose(popup.bounds.size.width * 0.3, 0, 0.025)},
        function() addShape(assets.cylinder) end,
        {texture=assets.cylinder}
    ))

    popup:addSubview(Button(
        ui.Bounds{size=ui.Size(popup.bounds.size.width*0.8,0.1,0.05), pose=ui.Pose(0, -0.15, 0.025)},
        handleCancel,
        {label="Cancel", color={0.4, 0.4, 0.3, 1.0}}
    ))

    self.app:openPopupNearHand(popup, hand)
end

function Canvas:_addDiagramItem(text, image, hand, x, y)
    local currentControlTable = self.accessControlTable[hand]

    self:addSubview(DiagramItem(ui.Bounds{
        size=ui.Size(0.8, 0.8, 0.05),
        pose=ui.Pose(x, y, 0.05)
    }, image, text))

    currentControlTable.allowedToInsert = true
end

function Canvas:broadcastTextureChange()
    if self.app == nil then return end

    local mat = self:specification().material
    self:updateComponents({material = mat})
    self.isDirty = false
end

function Canvas:sendIfDirty()
    if self.isDirty then
        self:broadcastTextureChange()
    end
end

function Canvas:clearBoard()
    self.cr:rgb(table.unpack(self.backgroundColor))
    self.cr:paint()

    self:broadcastTextureChange()
end

function Canvas:setDrawingMode()
    self.mode = MODE_DRAWING
end

function Canvas:setInsertingMode()
    self.mode = MODE_INSERTING
end

function Canvas:isDrawingMode()
    return self.mode == MODE_DRAWING
end

function Canvas:setBrush(color, size)
    self.brushColor = color
    self.brushSize = size

    local c = self:specification().cursor
    self:updateComponents({cursor = c})
end

return Canvas
