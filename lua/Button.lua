class.Button(ui.Button)
function Button:_init(bounds, onActivated, options)
    self:super(bounds)

    options = options or {}

    if options.label then
        self.label:setText(options.label)
    end

    if options.texture then
        self:setDefaultTexture(options.texture)
    end

    if options.color then
        self:setColor(options.color)
    end

    self.onActivated = function ()
        onActivated()
    end
end

return Button
