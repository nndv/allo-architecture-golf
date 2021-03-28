local vec3 = require("modules.vec3")
local mat4 = require("modules.mat4")
local class = require('pl.class')
local FileSurface = require("FileSurface")

class.FileViewer(ui.View)

FileViewer.assets = {
    previousPage = Base64Asset("iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAKFSURBVHgB7ZsxbxNBEIXfRnRxonQonYNkWqiQK2ynR6FGCJogIQqSUICEEoKJaPG5TYUEfyAClxEJFVAES3REAncWVEg56mPG9kWbxeXe7uR2P2m15zk382bW0s54FAyyLGvSdpPWCq0qykF/stpKqcHUb5DjC7Q6WflhHxdyv1XuPG0faF1FGHA2tCgb/sxMDNsIx3mGfWWfoSj6Vdp/6m+Hw9/YaSc4Pv6Bk5O/OO9cb9Sx8WgVi4sXzVctFuA1PdzNLez8ndsPS+G4TmVuFm/edk0RunwEruiWzqvd0jnPpOTTTrtrmldYgDNn/+PhZ5SV73SkDaozCIh0SmYHJcA0ogAInCgAAicKgMCJAiBwogAInAuwyKcv7858rl+7AVvM0XV2c2sdTx6/hE2sClAUDSpobD5bH4lgG9EC5FFvNOsoCrECFBl1HXECuIi6jigBXEVdR4QArqOu410AH1HX8SaAz6jreBHAd9R1nAogJeo6zgSQFHUdZ5ehSmUWaZpCGs4E6PX28eD+U/Te70MSTq/Do67zi2TUeR4Of0ECXuoBkrLBW0FESjZ4rwj5zgYRJTGf2SCqJugjG8QVRV1ng9iqsKtsEF0Wd5EN56IqzNlwdPQNq/duwTb8N7lMN9is5UvE7F3E1hgCJwqAwIkCIHCiAAicKAACJwpgGqQ1LoqGBRjohlrtEsoKD08Z9FmAPd2ytS2vfWWD+fnKaHLMoM/X4SbGQ5OncCEi6ezi8MDP/JBSCrbgYNYuL1FTdm3a2NxSPjma0LaGsEhI6I1QR2e/0lo+HZ3lB9patLooN1z94mxfnviM/w7bZJT2OcYDla4yIkOxDDD+sd8jxw/0F/8AwW/MYvMHEacAAAAASUVORK5CYII="),
    nextPage = Base64Asset("iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAJ6SURBVHgB7Zu/b9NAFMe/V7ElqTqBsqVIYYUJdYKmjIDKH4BgYaYtM6GEVGIjzoJQYUACsVf8ATRMgaWZW6nNVqlTpbaz+15+VNert559Z7/7SKdzzlne933PvrP9FAziOF6k7hm1ZWo1FIPBpLWUUsPEf1Dgc9Q6cfHhGOemcatp8NT9oXYPMmA3NMgNxzOTgXXICZ7hWDlmKMp+jfoD/ezh4RHarQh7e/s4OTlD3nnwcAFrb16hWr1lnmqwAN/p4OV0hIN/8fx1IQLXKVdK+PGza4rQ5SlwVx/pfNosXPDMKcXUbnXN4WUW4NLc/9v7h6KyS1PaoDYDQZwmOFuUAEkEASCcIACEEwSAcIIAEE4QAMK5AYs0363i29dfoy21Lfr/f1/6vXD/KWxi1QGPnzzC5y8fR31esD4FqtWbIydw42PfSe0akBc3pHoRzIMbMrkL+OyGzG6Dvroh83WAb25wshDyyQ1OV4I+uMH5Uti1G7zZC7hyg1eboXK5lPjsPk2sboauQ2+7j412lPlrOecCcMAbHyL0en24wKkArrKu40QA11nXyVwAH7Kuk5kAPmVdJxMBfMu6TqoC+Jp1ndQE8DnrOtYFyEPWdawKkJes6/BncrE+YPu5u2+Y7xnCqzEIJwgA4QQBIJwgAIQTBIBwggDmQKVSgiRYgKE+UK/fRlHh4imDAQuwpY8011cL6YLZ2fKocsxgwNvhRYyLJi/gz9yizibt793UDymlYAtOZv3OPN42V5LK5uanlaMRdSuQRURCr0ktnd2htnRROssH1DWodVFs+OkXu31pEjOuTLZJKe17jAsqs3JEjHQZYnyx36LAt/UT5+KV2TiURS+aAAAAAElFTkSuQmCC"),
}

function FileViewer:_init(bounds, assetManager)
    self:super(bounds)

    self.assetManager = assetManager
    self.fileSurface = FileSurface(ui.Bounds{size=bounds.size}, assetManager)
    self:addSubview(self.fileSurface)

    self.half_width = self.fileSurface.bounds.size.width/2
    self.half_height = self.fileSurface.bounds.size.height/2
    self.BUTTON_SIZE = 0.2
    self.BUTTON_DEPTH = 0.05
    self.SPACING = 0.13;

    -- RESIZE HANDLE
    self.resizeHandle = ui.ResizeHandle(ui.Bounds(self.half_width-self.BUTTON_SIZE/2, self.half_height-self.BUTTON_SIZE/2, 0.01, self.BUTTON_SIZE, self.BUTTON_SIZE, 0.001), {1, 1, 0}, {0, 0, 0})
    self:addSubview(self.resizeHandle)

    self:layout()
end

function FileViewer:specification()
    return ui.View.specification(self)
end

function FileViewer:update()
    -- Looks at the resizeHandle's position (if it exists)
    if self.resizeHandle and self.resizeHandle.entity then
        local m = mat4.new(self.resizeHandle.entity.components.transform.matrix)
        local resizeHandlePosition = m * vec3(0,0,0)

        local newWidth = resizeHandlePosition.x*2 + self.BUTTON_SIZE
        local newHeight = resizeHandlePosition.y*2 + self.BUTTON_SIZE

        if newWidth <= 1 then newWidth = 1 end
        if newHeight <= 0.5 then newHeight = 0.5 end

        self:resize(newWidth, newHeight)
    end
end

function FileViewer:resize(newWidth, newHeight)
    self.fileSurface:resize(newWidth, newHeight)
    self:layout()
end

function FileViewer:goToNextPage()
    self.fileSurface:goToNextPage()
end

function FileViewer:goToPreviousPage()
    self.fileSurface:goToPreviousPage()
end

function FileViewer:layout()
    -- Sets the correct position of buttons & labels in relation to the size of the FileSurface

    self.half_width = self.fileSurface.bounds.size.width/2
    self.half_height = self.fileSurface.bounds.size.height/2

    if self.fileSurface then

        -- if the surface has a file(name)
        if self.fileSurface.sampleFileName then

        self.TITLE_LABEL_HEIGHT = 0.05
        if self.fileTitleLabel then
            self.fileTitleLabel:setBounds(ui.Bounds{pose=ui.Pose(0, self.half_height + self.TITLE_LABEL_HEIGHT, 0)})
        else
            self.fileTitleLabel = ui.Label{
            bounds= ui.Bounds(0, self.half_height + self.TITLE_LABEL_HEIGHT, 0,   self.fileSurface.bounds.size.width, self.TITLE_LABEL_HEIGHT, 0.025),
            text= self.fileSurface.sampleFileName
            }
            self.fileTitleLabel.color = {0,0,0,1}
            self:addSubview(self.fileTitleLabel)
        end
        end

        if self.fileSurface.pageCount > 1 then

        if self.nextPageButton and self.previousPageButton then
            self.nextPageButton:setBounds(ui.Bounds{pose=ui.Pose(self.half_width+self.SPACING, 0, 0), size=self.nextPageButton.bounds.size})
            self.previousPageButton:setBounds(ui.Bounds{pose=ui.Pose(-self.half_width-self.SPACING, 0, 0), size=self.previousPageButton.bounds.size})  
        else
            -- Create & add the next/prev buttons
            self.previousPageButton = ui.Button(ui.Bounds(-self.half_width-self.SPACING, 0, 0.05, self.BUTTON_SIZE, self.BUTTON_SIZE, self.BUTTON_DEPTH), {1, 1, 0}, {0, 0, 0})
            self.previousPageButton:setDefaultTexture(FileViewer.assets.previousPage)
            self.previousPageButton.onActivated = function()
            self:goToPreviousPage()
            end
            self:addSubview(self.previousPageButton)

            self.nextPageButton = ui.Button(ui.Bounds(self.half_width+self.SPACING, 0, 0.05, self.BUTTON_SIZE, self.BUTTON_SIZE, self.BUTTON_DEPTH), {1, 1, 0}, {0, 0, 0})
            self.nextPageButton:setDefaultTexture(FileViewer.assets.nextPage)
            self.nextPageButton.onActivated = function()
            self:goToNextPage()
            end
            self:addSubview(self.nextPageButton)
        end
        end

    end

end

return FileViewer
