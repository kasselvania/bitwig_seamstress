-- track object
-- contains grid draw functions

local Track = {}

function Track:new()
    local newObj = {
        track_arm = false,
        arm_received = false,
        arm_update = true,
        selected = false,
        selected_received = false,
        selected_update = true,
        solo = false,
        solo_received = false,
        solo_update = true,
        other_solo = false,
        other_solo_received = false,
        other_solo_update = true,
        mute = false,
        mute_received = false,
        mute_update = true,
        folder = false,
        folder_received = false,
        folder_update = true,
        clips = {},
        clips_received = false,
        clips_update = false,
        playing_clip = 0,
        playing_clip_recieved = false,
        playing_clip_update = true,
        alt_launch = false,
        firstBoot = true,
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

function Track:firstBootDraw()
    if self.firstBoot and self.arm_received and self.clips_received then
        print("track arm is", self.track_arm, "for track", self.trackNumber)
        self:setTrackState()
        self.firstBoot = false
    end
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

function Track:setClipState(clipIndex, value)
    if clipIndex >= 1 and clipIndex <=16 then
        self.clips[clipIndex].state = value
    end
    self.clips_received = true
    if self.firstBoot == true then
        self:firstBootDraw()
    else self:setTrackState()
    end
end

function Track:setTrackArm(value)
    self.arm_received = true
    self.track_arm_update = false
    self.track_arm = value
   -- print("a track was armed")
   if self.firstBoot == true then
    self:firstBootDraw()
   else 
    print("i've passed the first boot, and now doint the set track state")
    self:setTrackState()
   end
    --print("track no' are state", self.trackNumber, "is ", value)

end

function Track:clipsToDraw()
    for i = 1,16 do
    local clipLedValue = self.clips[i].state == 1 and 10 or 0
    clipDrawArray[i][self.trackNumber] = clipLedValue
    end
    self.clips_update = true
    self.clips_received = false
end


function Track:setTrackState ()
    print("running track state function")
    --     if self.clips_update == false then

    --     end
    --     gridDirty = true
    --     self.clips_update = true
    -- end
    -- if self.clips_received == true then
        self:clipsToDraw()
        print("i just drew the clips")
    -- end
    if self.clips_update == true and self.folder_update == false then
            if self.folder == true then
            print("I'm printing the folder for track", self.trackNumber)
                    self:fullTrackStatusDraw(6)
            end
        if self.track_arm == true and self.arm_update == false then
            self:armDrawUpdate()
        end
    end
    self.clips_update = false
    self.arm_update = false
    self.folder_update = false
    -- if self.clips_update == true then
    --     if self.folder == true then
    --         self:fullTrackStatusDraw(self.folder, self.folder_update, 6)
    --     end
    --     if self.track_arm == true then
    --     --print("I am being run in setTrackState")
    --     self:armDrawUpdate()
    -- end
-- end
gridDirty = true
end

function Track:fullTrackStatusDraw(value)
        for i = 1,16 do
                clipDrawArray[i][self.trackNumber] = value
         end
gridDirty = true
end

-- function Track:clipDrawUpdate(clipIndex, clipLedValue)
--     if clipIndex >= 1 and clipIndex <= 16 then
--             -- clipDrawArray[clipIndex][self.trackNumber] = clipLedValue
--     --print("in track", y, "clip No", x, "is ", clipLedValue)
--     end

        -- self.clips_update = true   
        -- gridDirty = true
-- end


-- function Track:setTrackArm(value)
--     self.arm_update = false
--     self.arm_received = true
--     self.track_arm = value
--    -- print("a track was armed")
--    if self.firstBoot == true then
--    else self:setTrackState()
--    end
--     --print("track no' are state", self.trackNumber, "is ", value)

-- end



function Track:printClipStates()
--     print("Clip States for Track:")
--     for i, clip in ipairs(self.clips) do
--         local state = clip.state
--         print("Clip " .. i .. ": " .. (state and 1 or 0))
--     end
end

function Track:armDrawUpdate()
    print("armDrawUpdate was started for track", self.trackNumber)
    -- if self.track_arm and self.clips_update then
    --     for i = 1,16 do
    --         local value = self.clips[i].state
    --         print(value)
    --     end
        for i = 1,16 do
            if self.clips[i].state == 0 then
                print("this is tracking that we have done the math...")
                clipDrawArray[i][self.trackNumber] = clipDrawArray[i][self.trackNumber] + 3
                print("Empty clip number", i, "has been brightened")
            end
        end
    -- end
    -- end
    self.arm_update = true
end




function Track:setSelected(value)
--     self.select = value
--    -- print("track select", self.trackNumber, "is", value)
--     -- self.selected_update = false
end


function Track:setMute(value)
--     self.mute = value
--     -- self.mute_update = false
--     -- self:fullTrackStatusDraw(self.mute, self.mute_update, -5)
end

-- -- Method to mark if track is a folder
function Track:setFolder(value)
    self.folder = value
    self.folder_update = false
--     -- self:fullTrackStatusDraw(self.folder, self.folder_update, 7)
end



function Track:setSolo(value)
--     self.solo = value
--    -- print("Received solo data", value, "for", self.trackNumber)
--     -- self.solo_update = true
end


-- -- Method to change the value of if clip is playing
function Track:setPlayingClip(value)
--     self.playing_clip = value
--    -- print(self.trackNumber, value)
-- --    self.playing_clip_update = true
end

-- -- Method to change the value of mute
function Track:setAltLaunch(value)
--     self.alt_launch = value
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
