function plugindef()
    finaleplugin.RequireSelection = true
    finaleplugin.Author = "Carl Vine"
    finaleplugin.AuthorURL = "http://carlvine.com/lua/"
    finaleplugin.Copyright = "https://creativecommons.org/licenses/by/4.0/"
    finaleplugin.Version = "v1.53"
    finaleplugin.Date = "2023/04/29"
    finaleplugin.AdditionalMenuOptions = [[
        Staff Explode Pairs
        Staff Explode Pairs (Up)
        Staff Explode Split Pairs
        Staff Explode Layers
    ]]
    finaleplugin.AdditionalUndoText = [[
        Staff Explode Pairs
        Staff Explode Pairs (Up)
        Staff Explode Split Pairs
        Staff Explode Layers
    ]]
    finaleplugin.AdditionalDescriptions = [[
        Explode chords from one staff into pairs of notes on consecutive staves
        Explode chords from one staff into pairs of notes from Bottom-Up on consecutive staves
        Explode chords from one staff into "split" pairs of notes on consecutive staves
        Explode chords into independent layers across the current selection
    ]]
    finaleplugin.AdditionalPrefixes = [[
        action = "pairs"
        action = "pairs_up"
        action = "split"
        action = "layer"
    ]]
    finaleplugin.MinJWLuaVersion = 0.62
    finaleplugin.ScriptGroupName = "Staff Explode"
    finaleplugin.ScriptGroupDescription = "Explode chords from the selection onto consecutive staves"
    finaleplugin.Notes = [[
        This script "explodes" a set of chords on one staff into successive staves 
        either as single notes or pairs of notes. 
        Selected chords may contain different numbers of notes with 
        missing notes replaced by rests in the destination. 
        It also enables exploding chords on each staff into 
        different layers on the same staff. 

        Five menu items are provided:
        - Staff Explode Singles (single notes onto successive staves)
        - Staff Explode Pairs (pairs of notes, omitting odd notes from bottom staff)
        - Staff Explode Pairs Up (pairs, but omitting odd notes from top staff)
        - Staff Explode Split Pairs (pairs split: 1-3/2-4 | 1-4/2-5/3-6 | etc)
        - Staff Explode Layers (splitting chords to layers on each selected staff)
        
        "Staff Explode Layers" will work on any number of staves at once, and 
        markings from the original are not duplicated to the other layers. 
        As a special case, if a staff contains only single-note entries, Explode Layers 
        duplicates them in unison on layer 2 to create standard two-voice notation. 
        All other script actions require a single staff selection and 
        all markings from the original are copied to each destination. 

        The music isn't respaced after completion. 
        If you want automatic respacing, hold down the SHIFT or ALT (option) key when selecting the menu item. 

        Alternatively, if you want the default behaviour to include spacing then create a CONFIGURATION file ...  
        If it does not exist, create a subfolder called 'script_settings' in the folder containing this script. 
        In that folder create a plain text file  called 'staff_explode.config.txt' containing the line: 

        ```
        fix_note_spacing = true -- respace music when the script finishes
        ```
        
        If you subsequently hold down the SHIFT or ALT (option) key, spacing will NOT take place.
    ]]
    return "Staff Explode Singles", "Staff Explode Singles", "Explode chords from one staff into single notes on consecutive staves"
end

action = action or "single"
local configuration = require("library.configuration")
local clef = require("library.clef")
local mixin = require("library.mixin")
local note_entry = require("library.note_entry")
local layer = require("library.layer")

local config = { fix_note_spacing = false }
configuration.get_parameters("staff_explode.config.txt", config)

function show_error(error_code)
    local errors = {
        need_more_staves = "There are not enough empty\nstaves to explode onto",
        only_one_staff = "Please select only\none source staff!",
        empty_region = "Please select a region\nwith some notes in it!",
        three_or_more = "Exploding Pairs requires\nthree or more notes per chord",
        two_or_more = "Staff Exploder Single requires\ntwo or more notes per chord",
    }
    local msg = errors[error_code] or "Unknown Error"
    finenv.UI():AlertNeutral(msg, "ERROR")
    return -1
end

function should_overwrite_existing_music()
    local alert = finenv.UI():AlertOkCancel("Overwrite existing music?", "Are You Sure?")
    return (alert == 0)
end

function simple_note_count(region)
    local count = 0
    for entry in eachentry(region) do
        if entry.Count > count then
            count = entry.Count
        end
    end
    return count
end

function get_note_count(source_region)
    local note_count = simple_note_count(source_region)
    if note_count == 0 then
        return show_error("empty_region")
    end
    if action ~= "layer" then
        if action == "single" then
            if note_count < 2 then
                return show_error("two_or_more")
            end
        elseif note_count < 3 then
            return show_error("three_or_more")
        end
    end
    return note_count
end

function not_enough_staves(slot, staff_count)
    local staves = finale.FCStaves()
    staves:LoadAll()
    if staff_count > staves.Count - slot + 1 then
        return true
    end
    return false
end

function explode_layers(region)
    local rgn = mixin.FCMMusicRegion()
    rgn:SetRegion(region)

    for slot = region.StartSlot, region.EndSlot do
        rgn:SetStartSlot(slot):SetEndSlot(slot)
        local staff = rgn:CalcStaffNumber(slot)
        local note_count = simple_note_count(rgn)
        local unison_doubling = (note_count == 1) and 1 or 0

        local layers = {} -- copy original layer to [note_count] layers
        layers[1] = finale.FCNoteEntryLayer(0, staff, region.StartMeasure, region.EndMeasure)
        layers[1]:Load()

        for i = 2, (note_count + unison_doubling) do  -- copy to the other layers
            if i > layer.max_layers() then break end -- observe maximum layers
            layer.copy(rgn, 1, i)
        end

        if unison_doubling ~= 1 then  -- don't delete other layers if unison doubling
            for entry in eachentrysaved(rgn) do
                if entry:IsNote() then
                    local this_layer = entry.LayerNumber
                    local from_top = this_layer - 1   -- delete how many notes from top?
                    local from_bottom = entry.Count - this_layer -- how many from bottom?

                    if from_top > 0 then -- delete TOP notes
                        for _ = 1, from_top do
                            note_entry.delete_note(entry:CalcHighestNote(nil))
                        end
                    end
                    if from_bottom > 0 and this_layer < layer.max_layers() then -- delete BOTTOM notes
                        for _ = 1, from_bottom do
                            note_entry.delete_note(entry:CalcLowestNote(nil))
                        end
                    end
                end
            end
        end
    end
end

function staff_explode()
    if finenv.QueryInvokedModifierKeys and
    (finenv.QueryInvokedModifierKeys(finale.CMDMODKEY_ALT) or finenv.QueryInvokedModifierKeys(finale.CMDMODKEY_SHIFT))
        then
        config.fix_note_spacing = not config.fix_note_spacing
    end

    local source_region = mixin.FCMMusicRegion()
    source_region:SetCurrentSelection()
    if action ~= "layer" and source_region:CalcStaffSpan() > 1 then
        return show_error("only_one_staff")
    end
    local start_slot = source_region.StartSlot
    local regions = { source_region }
    local max_note_count = get_note_count(source_region)
    if max_note_count <= 0 then return end -- error was identified

    if action == "layer" then
        explode_layers(source_region)
        return -- all done here
    end
    local staff_count = max_note_count
    if action ~= "single" then -- half as many staves needed
        staff_count = math.floor((max_note_count / 2) + 0.5) -- allow for odd number of notes
    end
    if not_enough_staves(start_slot, staff_count) then
        show_error("need_more_staves")
        return
    end

    -- copy top staff to max_note_count lower staves
    local destination_is_empty = true
    for slot = 2, staff_count do
        regions[slot] = mixin.FCMMusicRegion()
        regions[slot]:SetRegion(regions[1]):CopyMusic()
        local this_slot = start_slot + slot - 1 -- "real" slot number, indexed[1]
        regions[slot]:SetStartSlot(this_slot):SetEndSlot(this_slot)
        
        if destination_is_empty then
            for entry in eachentry(regions[slot]) do
                if entry.Count > 0 then
                    destination_is_empty = false
                    break
                end
            end
        end
    end

    if destination_is_empty or should_overwrite_existing_music() then
        -- run through regions[1] copying the pitches in every chord
        local pitches_to_keep = {} -- compile an array of chords (for Split Pairs)
        local chord = 1 -- start at 1st chord (for Split Pairs)

        if action == "split" then -- collate chords for pairing
            for entry in eachentry(regions[1]) do -- check each entry chord
                if entry:IsNote() then
                    pitches_to_keep[chord] = {} -- create new pitch array for each chord
                    for note in each(entry) do -- index by ascending MIDI value
                        table.insert(pitches_to_keep[chord], note:CalcMIDIKey()) -- add to array
                    end
                    chord = chord + 1 -- next chord
                end
            end
        end

        -- run through all staves deleting requisite notes in each copy
        for slot = 1, staff_count do
            if slot > 1 then
                regions[slot]:PasteMusic() -- paste the newly copied source music
                regions[slot]:ReleaseMusic() -- clear the memory
                clef.restore_default_clef(regions[1].StartMeasure, regions[1].EndMeasure, regions[slot].StartStaff)
            end

            chord = 1  -- start over (for Split Pairs)
            local from_top, from_bottom = slot - 1, 0 -- (for Singles)

            for entry in eachentrysaved(regions[slot]) do    -- check each chord in the source
                if entry:IsNote() then
                    -- -----------
                    if action == "split" then
                        local hi_pitch = entry.Count + 1 - slot -- index of highest pitch
                        local lo_pitch = hi_pitch - staff_count -- index of paired lower pitch (SPLIT pair)

                        local overflow = -1     -- overflow counter
                        while entry.Count > 0 and overflow < max_note_count do
                            overflow = overflow + 1   -- don't get stuck!
                            for note in each(entry) do  -- check MIDI value
                                local pitch = note:CalcMIDIKey()
                                if pitch ~= pitches_to_keep[chord][hi_pitch] and pitch ~= pitches_to_keep[chord][lo_pitch] then
                                    note_entry.delete_note(note)
                                    break -- examine same entry again after note deletion
                                end
                            end
                        end
                        chord = chord + 1 -- next chord
                    -- -----------
                    else
                        if action == "single" then
                            from_bottom = entry.Count - slot -- how many from the bottom?
                        elseif action == "pairs_up" then -- strip missing notes from top staff, not bottom
                            from_bottom = (staff_count - slot) * 2
                            from_top = entry.Count - from_bottom - 2
                        else -- "pairs"
                            from_top = (slot - 1) * 2 -- delete how many notes from the top of the chord?
                            from_bottom = entry.Count - (slot * 2) -- how many from the bottom?
                        end
                        if from_top > 0 then
                            for _ = 1, from_top do
                                local high = entry:CalcHighestNote(nil)
                                if high then note_entry.delete_note(high) end
                            end
                        end
                        if from_bottom > 0 then
                            for _ = 1, from_bottom do
                                local low = entry:CalcLowestNote(nil)
                                if low then note_entry.delete_note(low) end
                            end
                        end
                    end
                end
            end
        end

        if config.fix_note_spacing then
            regions[1]:SetFullMeasureStack()
            regions[1]:SetInDocument()
            finenv.UI():MenuCommand(finale.MENUCMD_NOTESPACING)
            regions[1]:SetStartSlot(start_slot):SetEndSlot(start_slot)
        end
    end
    regions[1]:SetInDocument()
end

staff_explode()
