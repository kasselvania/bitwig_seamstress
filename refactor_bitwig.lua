-- test of grid controller

-- BitWig Controller Beta/Early
local util = require "util"
local lattice = require "lattice"




local Track = require ("lib/Track")
local tracks = Track:initTracks()


g = grid.connect()

dest = {"localhost", "6666"}

clipDrawArray = {}
clipPlayArray = {}

playPulseValue = 0





function init()

   solo_tracks = {}
   for x = 1,16 do
    solo_tracks[x] = {}
   end


    transporton = false
    arrangementView = true

    globalRecordArm = false

    mute_screen = false
    mute_counter = {}
    mute_held = false
    muted_track = {}

    solo_screen = false
    solo_counter = {}
    solo_held = false
    solod_track = {}

    for x = 1,16 do
      solod_track[x] = false
    end

    altLaunch_screen = false
    altLaunch_counter = {}
    altLaunch_held = false

for x = 1,16 do
  clipDrawArray[x] = {}
  clipPlayArray[x] = {}
    for y = 1,16 do
      clipDrawArray[x][y] = 0
      clipPlayArray[x][y] = false
    end
  end

    globalClock = lattice:new() -- lattice for quarter note based patterns
    globalClock:stop()
    playAnimation = globalClock:new_sprocket()
    playAnimation:set_division(1/64)
    playAnimation:set_action(function ()
      pulseLed(1, 16, globalClock.ppqn, true)
    end)
    playAnimation:stop()
    globalClock:start()
  
    gridDirty = true -- state that runs a grid.redraw()
  
    playAnimation:start()
  
    Grid_Redraw_Metro = metro.init() -- grid redraw instructions
    Grid_Redraw_Metro.event = function()
      if gridDirty then
        grid_redraw()
        gridDirty = false
      end
    end
    Grid_Redraw_Metro:start(1/60)

    osc.send(dest, "/refresh",{0})
    
    gridDirty = true
  end


--   function grid.add(newGrid)
--     g = grid.connect(newGrid.port)
--     print("New grid: " .. newGrid.name .. " plugged in.")
--     print("Columns: " .. g.cols .. " Rows: " .. g.rows)
--     width = g.cols
--     height = g.rows
-- end



function pulseLed(x, y, scale, direction) -- animation sprocket fun by lattice for identifying playing clips and play button
  local phase = globalClock.transport % scale
  startValue = 0
  endValue = 16

  if direction then
    startValue = 16
    endValue = 0
  end

  ledBrightness = util.round(util.linlin(0, scale, startValue, endValue, phase), 1)

  playPulseValue = ledBrightness
  --print(playPulseValue)
  gridDirty = true
end


  function osc_in(path, args, from)

    local playmsg = string.find(path, "/play") -- this is the function that runs the transport button and updates its state
    if playmsg then
        if args[1] == 1 then
            transporton = true
                elseif args[1] == 0 then
                    transporton = false
                end
end

      collectClipData(path, args)
      processTrackOSCMessage(path, args)
    end

  function collectClipData(path, args)
    local track, clip = path:match("/track/(%d+)/clip/(%d+)/hasContent")
    local trackNumber = tonumber(track)
    local clipNumber = tonumber(clip)

    if trackNumber and clipNumber then
      processClipStates(trackNumber, clipNumber, args)
  end
end

function processClipStates(trackNumber, clipNumber, args)
  if trackNumber <= 16 and clipNumber <= 16 then
    local clipState = args[1] == 1 and 1 or 0
    tracks[trackNumber]:setClipState(clipNumber, clipState)
end
    gridDirty = true
end
  
  
  function processTrackOSCMessage(path, args)

    local trackplay, clipplay = path:match("/track/(%d+)/clip/(%d+)/isPlaying")
    local folder = path:match("/track/(%d+)/type")
    local selected = path:match("/track/(%d+)/selected")
    local isArmed = path:match("/track/(%d+)/recarm")
    local muted = path:match("/track/(%d+)/mute")
    local solod = path:match("/track/(%d+)/solo")


    local trackgroup = tonumber(folder)
    local trackselectNumber = tonumber(selected)
    local armedTrackNumber = tonumber(isArmed)
    local trackplayNumber = tonumber(trackplay)
    local clipplayNumber = tonumber(clipplay)
    local mutedTrack = tonumber(muted)
    local solodTrack = tonumber(solod)

    

    if trackgroup then
      --print(args[1])
      local convertedValue = args[1] == "group" and 1 or nil
      --print(convertedValue)
        processTrackStates(trackgroup, {convertedValue}, "folder")
        --print("I see armed track:", armedTrackNumber, args[1])
    end

    if trackselectNumber then
        processTrackStates(trackselectNumber, args, "selected")
        -- print("I see armed track:", armedTrackNumber, args[1])
    end 

    if armedTrackNumber then
        processTrackStates(armedTrackNumber, args, "track_arm")
        -- print("I see armed track:", armedTrackNumber, args[1])
    end

    if mutedTrack then
        processTrackStates(mutedTrack, args, "mute")
        -- print("I see armed track:", armedTrackNumber, args[1])
    end

    if solodTrack then
        processTrackStates(solodTrack, args, "solo")
        updateGlobalSoloState(solodTrack, args)
        updateOtherSolo ()


        -- print("I see armed track:", armedTrackNumber, args[1])
    end


    if trackplayNumber and clipplayNumber then
        processPlayStates(trackplayNumber, clipplayNumber, args)
        if args[1] == 1 then
         --print("track number", trackplayNumber,"clip number", clipplayNumber, "is playing")
        end
    end
  end

  osc.event = osc_in

local globalSoloState = false



-- Function to update the global solo state based on any soloed track
function updateGlobalSoloState(trackplayNumber, args)
globalSoloState = false
  -- print("I'm checking solos")
  if trackplayNumber <= 16 and args[1] <=1 then
  local value = args[1]
    solo_tracks[trackplayNumber] = value
    --print(value)
  end
  for i = 1,16 do
    if solo_tracks[i] == 1 then
      globalSoloState = true
      --print(globalSoloState)
      return
  end
end
if not globalSoloState then
  globalSoloState = false
end
end

function updateOtherSolo ()
--print("the state of globalsolo is ")
  for i = 1, 16 do
    tracks[i]:setOtherSolo(globalSoloState)
  end
end

local statusFunctionNames = {
  track_arm = "setTrackArm",
  selected = "setSelected",
  solo = "setSolo",
  mute = "setMute",
  folder = "setFolder",
  alt_launch = "setAltLaunch",
  other_solo = "setOtherSolo"

}



function processTrackStates(trackNumber, args, stateKey)
  --print("Received OSC message for track " .. trackNumber .. " with args: " .. table.concat(args, ", ") .. " and stateKey: " .. stateKey)
  if trackNumber <= 16 and args[1] ~= nil then
    local track = tracks[trackNumber]
    local value = args[1] ~= 0
    track[stateKey] = value
    local methodName = statusFunctionNames[stateKey] -- Get the methodName from the predefined table
    if methodName and track[methodName] then
        track[methodName](track, value)
        --print("Track " .. trackNumber .. " updated for stateKey " .. stateKey .. " with value " .. tostring(value))
    --else print("Method not found for stateKey " .. stateKey)
    end
end
gridDirty = true
end



function processPlayStates(trackplayNumber, clipplayNumber, args)
  if trackplayNumber <= 16 and clipplayNumber <= 16 and args[1] == 1 then
      tracks[trackplayNumber]:setPlayingClip(clipplayNumber)
  end
  gridDirty = true
end

  function alternateView(x,y,z) -- alt view button function. Currently only toggles variable
    if x == 12 and y == 16. or x == 13 and y == 16 then
      if z == 1 then
          print(x,y)
          arrangementView = not arrangementView
            else
        end
    gridDirty = true
      end
  end



  
function g.key(x,y,z)

    if x == 1 and y == 1 and z == 1 then
        for i, track in ipairs(tracks) do
            print("Track", i, "Playing Clip:", track.playing_clip)
        end
        end

    if x == 2 and y == 1 and z == 1 then
        for i, track in ipairs(tracks) do
            print("Track", i, "is armed", track.track_arm)
        end
    end

    if x == 3 and y == 1 and z == 1 then
        for i, track in ipairs(tracks) do
            print("Track", i, "is solod", track.solo)
    end
end

if x == 4 and y == 1 and z == 1 then
  for i, track in ipairs(tracks) do
      print("Track", i, "Clips:")
      for j, clip in ipairs(track.clips) do
          print("  Clip", j, "State:", clip.state)
      end
  end
  if x == 16 and y == 16 and z == 1 then
    gridDirty = true
  end
end
end


-- function playingClips()
--   if transporton == true then -- clip playing drawing/animation
    -- for x = 1,16 do
    --     for y = 1,14 do
    --         if clipPlayArray[x][y] == true then
    --          print(clipPlay[x][y])
    --             g:led(x,y,playPulseValue)
    --         end
    --     end
    -- end
--     -- clock.sleep(0.2)
--      gridDirty = true
--   end
-- end
  

function grid_array_data()
  --print ("grid array data is getting updated")
  -- this is for drawing in the clips:
    if arrangementView == true then
        for x = 1, 16 do
            for y = 1, 16 - 2 do
                local brightness = clipDrawArray[x][y]
        --print("x:", x, "y:", y, "Brightness:", brightness)
                g:led(x, y, brightness)
                -- print(playPulseValue)
            end
        end
        if transporton == true then
        for x = 1,16 do
          for y = 1,16 - 2 do
            if clipPlayArray[x][y] == true then
              -- local brightness = playPulseValue
             -- print(playPulseValue)
              g:led(x,y, playPulseValue)
            end
          end
        end
      end
      gridDirty = true
end
  --print("grid brightness updated")
  gridDirty = true
  end
function grid_redraw()
        -- for x = 12, 13 do -- altView toggle button
        -- g:led(x,g.rows, arrangementView and 15 or 2)
        -- end

grid_array_data()

-- playingClips()

    g:refresh()
 end
