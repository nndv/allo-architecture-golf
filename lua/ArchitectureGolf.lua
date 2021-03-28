local class = require("pl.class")

local Canvas = require("Canvas")
local Button = require('Button')
local FileViewer = require('FileViewer')

class.ArchitectureGolf(ui.View)

function ArchitectureGolf:_init(bounds, assetManager)
    self:super(bounds)

    self.assetManager = assetManager

    self.canvas = Canvas(ui.Bounds{size=bounds.size})
    self:addSubview(self.canvas)

    self.half_width = self.canvas.bounds.size.width/2
    self.half_height = self.canvas.bounds.size.height/2
    self.BUTTON_SIZE = 0.2
    self.SMALL_BUTTON_SIZE = 0.12
    self.BUTTON_DEPTH = 0.05
    self.SPACING = 0.05
    self.FRAME_THICKNESS = 0.025
    self.FRAME_COLOR_RGBA = {0.3, 0.3, 0.3, 1}
    self.COLOR_BLACK = {0, 0, 0}
    self.COLOR_WHITE = {1, 1, 1}

    self.PI = 3.14159

    -- Frame
    self.frame = ui.Surface(
        ui.Bounds{size=ui.Size( self.canvas.bounds.size.width + self.FRAME_THICKNESS*2,
        self.canvas.bounds.size.height + self.FRAME_THICKNESS*2,
       0.05
    )}:move(0,0,-0.01))
    self.frame:setColor(self.FRAME_COLOR_RGBA)
    self:addSubview(self.frame)

    -- Control panel
    self.controlPanel = ui.Surface(
        ui.Bounds{size=ui.Size( self.canvas.bounds.size.width + self.FRAME_THICKNESS*2,
        self.BUTTON_SIZE + self.FRAME_THICKNESS*2,
        0.05
    )}:rotate(-self.PI/4, 1, 0, 0):move(0,-self.half_height-self.BUTTON_SIZE/2-self.FRAME_THICKNESS, self.BUTTON_SIZE/2-self.FRAME_THICKNESS))

    self.controlPanel:setColor(self.FRAME_COLOR_RGBA)
    self:addSubview(self.controlPanel)

    -- Mode button
    self.modeButton = Button(
        ui.Bounds(-self.BUTTON_SIZE - self.SPACING,0,0, self.BUTTON_SIZE * 2, self.BUTTON_SIZE, self.BUTTON_DEPTH),
        function()
            if self.canvas:isDrawingMode() then
                self.canvas:setInsertingMode()
            else
                self.canvas:setDrawingMode()
            end
        end,
        {label = "Draw"}
    )
    self.controlPanel:addSubview(self.modeButton)

    -- Clear button
    self.controlPanel:addSubview(Button(
        ui.Bounds(self.BUTTON_SIZE,0,0, self.BUTTON_SIZE * 2, self.BUTTON_SIZE, self.BUTTON_DEPTH),
        function()
            self.canvas:clearBoard()
        end,
        {label = "Clear"}
    ))

    self.controlPanel:addSubview(Button(
        ui.Bounds(self.BUTTON_SIZE * 4,0,0, self.BUTTON_SIZE, self.BUTTON_SIZE, self.BUTTON_DEPTH),
        function()
            self.canvas:setBrush(self.COLOR_BLACK, 2)
        end,
        {color = {0, 0, 0}}
    ))

    self.controlPanel:addSubview(Button(
        ui.Bounds(self.BUTTON_SIZE * 4 + self.BUTTON_SIZE + self.SPACING,0,0, self.BUTTON_SIZE, self.BUTTON_SIZE, self.BUTTON_DEPTH),
        function()
            self.canvas:setBrush(self.COLOR_WHITE, 8)
        end,
        {color = {1, 1, 1}}
    ))

    -- Quit button
    self:addSubview(Button(
        ui.Bounds{pose=ui.Pose(3, 1.5, 0), size=ui.Size(0.3,0.3,0.05)},
        function() self.app:quit() end,
        {texture=assets.quit}
    ))

    self.fileViewer = FileViewer(ui.Bounds{size=ui.Size(1, 0.2, 0.06)}, self.assetManager)
    self.fileViewer.bounds:rotate(-self.PI/4, 0, 1, 0):move(5, 0, 2)
    self:addSubview(self.fileViewer)
end

function ArchitectureGolf:update()
    self.canvas:sendIfDirty()

    if self.canvas:isDrawingMode() then
        self.modeButton.label:setText("Insert")
    else
        self.modeButton.label:setText("Draw")
    end

    self.fileViewer:update()
end

return ArchitectureGolf
