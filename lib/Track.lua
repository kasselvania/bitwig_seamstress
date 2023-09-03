-- track object
-- contains grid draw functions

local Track = {}

function Track:new()
    local newObj = {
        track_arm = false,
        arm_update = true,
        selected = false,
        selected_update = true,
        solo = false,
        solo_update = true,
        other_solo = false,
        other_solo_update = true,
        mute = false,
        mute_update = true,
        folder = false,
        folder_update = true,
        clips = {},
        clips_update = true,
        playing_clip = 0,
        playing_clip_update = true,
        alt_launch = false,
        width = width,
    }

    for i = 1, 16 do
        newObj.clips[i] = {
            state = false -- Initialize each clip as empty, haveContent set to false, nil is empty, 1 is exists, 2 is playing
        }
    end

    setmetatable(newObj, self)
    self.__index = self
    return newObj
end

function Track:getClips()
    return self.clips
end

-- Initialize 16 track instances and return them in a table
function Track:initTracks()
    local tracks = {}
    for i = 1, 16 do
        local trackInstance = self:new(tracks)
        trackInstance.trackNumber = i
        tracks[i] = trackInstance
    end
    gridDirty = true
    return tracks
end


-- function Track:setClipstate(clipIndex, value)
--     if self.clips[clipIndex] then
--         self.clips[clipIndex].state = value
--         self.clips_update = false
--         self:clipDrawUpdate(clipIndex)
--     end
--     -- if self.arm_update == false then
--     -- end
--     self:trackStatusDraws()
-- end

function Track:setClipState(clipIndex, state)
    if clipIndex >= 1 and clipIndex <= 16 then
        self.clips[clipIndex] = { state = state }
    else
        print("Invalid clip index")
    end
    self:printclips()
end



-- function Track:clipDrawUpdate(clipIndex)
--     if self.folder == false and clipIndex <= 16 then
--         local clipLedValue = self.clips[clipIndex].state == 1 and 10 or 0
--         gridDrawArray[clipIndex][self.trackNumber] = clipLedValue
--         end
--         self.clips_update = true
-- end

-- function Track:printClipStates()
--     print("Clip States for Track:")
--     for i, clip in ipairs(self.clips) do
--         local state = clip.state
--         print("Clip " .. i .. ": " .. (state and 1 or 0))
--     end
-- end

-- function Track:armDrawUpdate()
--     if self.track_arm and self.clips_update then
--         for i,clip in ipairs(self.clips) do
--                 print("this is tracking that we have done the math...")
--                 gridDrawArray[i + 1][self.trackNumber] = gridDrawArray[i + 1][self.trackNumber] + 3
--                 gridDrawArray[i + 1][self.trackNumber] = gridDrawArray[i + 1][self.trackNumber] + 3
--                 print("Empty clip number", i, "has been brightened")
--             end
--         end
--     end
--     self.arm_update = true
-- end

-- function Track:checkClipValues()
--     for i, clip in ipairs(self.clips) do
--         local state = clip.state
--         print("Clip " .. i .. ": " .. (state and 1 or 0))
--     end
-- end

-- function Track:setTrackArm(value)
--     self.track_arm = value
--     self:checkClipValues()
--     self.arm_update = false
-- end

-- Track:armcheckingclips()




function Track:setSelected(value)
    self.select = value
   -- print("track select", self.trackNumber, "is", value)
    self.selected_update = false
end


function Track:setMute(value)
    self.mute = value
    self.mute_update = false
    self:fullTrackStatusDraw(self.mute, self.mute_update, -5)
end

-- Method to mark if track is a folder
function Track:setFolder(value)
    self.folder = value
    self.folder_update = false
    self:fullTrackStatusDraw(self.folder, self.folder_update, 7)
end


function Track:fullTrackStatusDraw(keystate, keystate_update, args)
    if keystate_update == false and keystate == true then
                for i = 1,16 do
                        gridDrawArray[i][self.trackNumber] = args
                 end
            end
        keystate_update = true
       -- print("I've updated the,", keystate, "gridArray Value for track ", self.trackNumber)
end

function Track:setSolo(value)
    self.solo = value
   -- print("Received solo data", value, "for", self.trackNumber)
    self.solo_update = true
end


-- Method to change the value of if clip is playing
function Track:setPlayingClip(value)
    self.playing_clip = value
   -- print(self.trackNumber, value)
   self.pplaying_clip_update = true
end

-- Method to change the value of mute
function Track:setAltLaunch(value)
    self.alt_launch = value
end









return Track



    --     for x = 1, 16 do
    --         for y = 1, 16 do
    --             print("gridDrawArray[" .. x .. "][" .. y .. "] = " .. gridDrawArray[x][y])
    --         end  
    -- end



    -- function Track:folderDrawUpdate()
--     if self.folder_update == false and self.folder == true then
--                 for i = 1,16 do
--                         gridDrawArray[i][self.trackNumber] = 7
--                  end
--             end
--         self.folder_update = true
--        -- print("I've updated the folder gridArray Value")
-- end

-- function Track:adaptiveTrackStatusDraw(args)
--     for i, clip in ipairs(self.clips) do
--         if clip.state == 0 and gridDrawArray[i + 1] then
--             gridDrawArray[i + 1][self.trackNumber] = gridDrawArray[i + 1][self.trackNumber] (args)
--             gridDrawArray[i + 1][self.trackNumber] = gridDrawArray[i + 1][self.trackNumber] (args)
--             --print("Empty clip number", i, "has been brightened")
--         end
--     end
-- end
