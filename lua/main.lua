package.path = string.format(
    package.path..";"
    .."lib/cairo/?.lua"
)

local ArchitectureGolf = require("ArchitectureGolf")

-- a Client is used to connect this app to a Place. arg[2] is the URL of the place to
-- connect to, which Assist sets up for you.
local client = Client(
    arg[2],
    "allo-architecture-golf"
)

-- App manages the Client connection for you, and manages the lifetime of the
-- your app.
local app = App(client)

-- Assets are files (images, glb models, videos, sounds, etc...) that you want to use
-- in your app. They need to be published so that user's headsets can download them
-- before you can use them. We make `assets` global so you can use it throughout your app.
assets = {
    quit = ui.Asset.File("images/quit.png"),
    square = ui.Asset.File("images/square.png"),
    diamond = ui.Asset.File("images/diamond.png"),
    cylinder = ui.Asset.File("images/cylinder.png")
}
app.assetManager:add(assets)

local assetManager = app.assetManager
-- Tell the app that mainView is the primary UI for this app
local architectureGolf = ArchitectureGolf(ui.Bounds(0, 3, -2,   6, 3, 0.01), assetManager)
app.mainView = architectureGolf

app:scheduleAction(0.05, true, function()
    if app.connected then
        architectureGolf:update()
    end
end)

-- Connect to the designated remote Place server
app:connect()
-- hand over runtime to the app! App will now run forever,
-- or until the app is shut down (ctrl-C or exit button pressed).
app:run()
