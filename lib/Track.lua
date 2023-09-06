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

function Track:firstBootDraw()
    --print("there is an attempt to firstBootDraw")
    if self.firstBoot and self.arm_received and self.clips_received and self.selected_received and self.mute_received and self.solo_received and self.other_solo_received then
        -- print("I have run the firstbootDraw")
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

function Track:clipsToDraw()
    for i = 1,16 do
    local clipLedValue = self.clips[i].state == 1 and 10 or 0
    clipDrawArray[i][self.trackNumber] = clipLedValue
    print(i,self.trackNumber,clipLedValue)
    end
    self.clips_update = true
    self.clips_received = false
end

function Track:setTrackState ()
        self:clipsToDraw()
       -- print("i just drew the clips")
    -- end
    if self.clips_update == true and self.folder_update == false then
            if self.folder == true then
            --print("I'm printing the folder for track", self.trackNumber)
                    self:folderTrackDraw(6)
            end
        if self.track_arm == true and self.arm_update == false then
            --self:armDrawUpdate()
            local change = "plus"
            self:adaptiveDrawUpdate(3, change)
        end
        if self.mute == true and self.mute_update == false then
           -- print("This track muted", self.trackNumber)
            local change = "minus"
            self:adaptiveDrawUpdate(6, change)
        end
        if self.selected == true and self.selected_update == false then
            --print("This track selected", self.trackNumber)
            local change = "all plus"
            self:adaptiveDrawUpdate(3, change)
        end
        if self.solo == false and self.other_solo == true then
            --print("I sense a solo")
            local change = "all minus"
            self:adaptiveDrawUpdate(6, change)
            -- if self.solo == false and self.solo_update == false then
            --     print("trying to add solo")
            --     local change = "all minus"
            --     self:adaptiveDrawUpdate(6, change)
            -- end
        end
        if self.playing_clip ~= 0 then
            -- g:led(self.playing_clip,self.trackNumber,playPulseValue)
            -- print(playPulseValue)
            clipPlayArray[self.playing_clip][self.trackNumber] = true
            -- clipDrawArray[self.playing_clip][self.trackNumber] = playPulseValue
        end
    end
    self.solo_update = false
    self.other_solo = false
    self.other_solo_update = false
    self.mute_update = false
    self.clips_update = false
    self.arm_update = false
    self.folder_update = false
    self.selected_update = false
    self.playing_clip_update = false
gridDirty = true
end

function Track:folderTrackDraw(value)
        for i = 1,16 do
                clipDrawArray[i][self.trackNumber] = value
         end
gridDirty = true
end




function Track:adaptiveDrawUpdate(value, calc)
   -- print("adaptiveDrawUpdate was started for track", self.trackNumber)
    if calc == "plus" then
        for i = 1,16 do
            if self.clips[i].state == 0 then
                -- print("this is tracking that we have done the math...")
                clipDrawArray[i][self.trackNumber] = self:addition(clipDrawArray[i][self.trackNumber], value)
               -- print("Empty clip number", i, "has been brightened")
                end
            end
        end
       if calc == "all plus" then
        for i = 1,16 do
            clipDrawArray[i][self.trackNumber] = self:addition(clipDrawArray[i][self.trackNumber], value)
        end
       end
       if calc == "minus" then
        for i = 1,16 do
            if self.clips[i].state == 1 then
                clipDrawArray[i][self.trackNumber] = self:subtraction(clipDrawArray[i][self.trackNumber], value)
            end
        end
       end
       if calc == "all minus" then
        for i = 1,16 do
            clipDrawArray[i][self.trackNumber] = self:subtraction(clipDrawArray[i][self.trackNumber], value)
        end
       end
    -- self.mute_update = true
    -- self.selected_update = true
    -- self.arm_update = true
end

function Track:addition(a,b)
    --print(a,b)
    return math.min(a + b,15)
end

function Track:subtraction(a,b)
    --print(a,b)
    return math.max(a - b,0)
end

function Track:setTrackArm(value)
    self.arm_received = true
    self.track_arm_update = false
    self.track_arm = value
   if self.firstBoot == true then
    self:firstBootDraw()
   else 
    self:setTrackState()
   end
end


function Track:setSelected(value)
    self.selected_received = true
    self.selected_update = false
    self.select = value
   if self.firstBoot == true then
    self:firstBootDraw()
   else 
    self:setTrackState()
   end
end


function Track:setMute(value)
    self.mute_received = true
    self.mute_update = false
    self.mute = value
   if self.firstBoot == true then
    self:firstBootDraw()
   else 
    self:setTrackState()
   end
end

-- -- Method to mark if track is a folder
function Track:setFolder(value)
    self.folder = value
    self.folder_update = false
end


function Track:setSolo(value)
    self.solo_received = true
    self.solo__update = false
    self.solo = value
    if self.firstBoot == true then
        self:firstBootDraw()
       else 
        self:setTrackState()
       end
end

function Track:setOtherSolo(value)
        self.other_solo_received = true
        self.other_solo_update = false
        self.other_solo = value
        if self.firstBoot == true then
            self:firstBootDraw()
           else 
            self:setTrackState()
           end
end



-- -- Method to change the value of if clip is playing
function Track:setPlayingClip(value)
    self.playing_clip_recieved = true
    self.playing_clip_update = false
    self.playing_clip = value
   --print(self.trackNumber, value)
   if self.firstBoot == true then
    self:firstBootDraw()
   else 
    self:setTrackState()
   end
end

-- -- Method to change the value of mute
function Track:setAltLaunch(value)
--     self.alt_launch = value
end

return Track
