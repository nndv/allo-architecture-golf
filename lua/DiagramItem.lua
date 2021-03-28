local Button = require("Button")

class.DiagramItem(ui.Surface)
function DiagramItem:_init(bounds, image, text)
    self:super(bounds)

    self:setTexture(image)
    self:setPointable(true)

    self:addDiagramPopup()

    local label = self:addSubview(ui.Label{
        bounds=ui.Bounds{size=ui.Size(0.5, 0.2, 0.06)},
        color={0,0,0, 1},
        text=text
    })

    label:setHalign("center")
end

function DiagramItem:addDiagramPopup()
    self.deletePopup = ui.Surface(ui.Bounds{size=ui.Size(1,0.5,0.05)})
    self.deletePopup:setPointable(true)

    local deleteButton = Button(
        ui.Bounds{size = ui.Size(self.deletePopup.bounds.size.width * 0.5,0.1,0.05), pose = ui.Pose(0, 0.1, 0.025)},
        function () self:handleDelete() end,
        {label="Delete"}
    )

    local cancelButton = Button(
        ui.Bounds{size = ui.Size(self.deletePopup.bounds.size.width * 0.5,0.1,0.05), pose = ui.Pose(0, -0.1, 0.025)},
        function() self.deletePopup:removeFromSuperview() end,
        {label="Cancel", color={0.4, 0.4, 0.3, 1.0}}
    )

    self.deletePopup:addSubview(cancelButton)
    self.deletePopup:addSubview(deleteButton)
end

function DiagramItem:handleDelete()
    self:removeFromSuperview()
    self.deletePopup:removeFromSuperview()
end

function DiagramItem:onTouchUp(pointer)
    self.app:openPopupNearHand(self.deletePopup, pointer.hand)
end

return DiagramItem
