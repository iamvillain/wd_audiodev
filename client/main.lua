local is_frontend_sound_playing = false
local cached_createstream = {}
local cached_music_events = {}
local cached_frontend_soundsets = {}
local cached_audio_flags = {}
---------------------

local function play_ambient_speech_from_entity(entity_id,sound_ref_string,sound_name_string,speech_params_string,speech_line)
    local struct = DataView.ArrayBuffer(128)
    local sound_name = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", sound_name_string,Citizen.ResultAsLong())
    local sound_ref  = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING",sound_ref_string,Citizen.ResultAsLong())
    local speech_params = GetHashKey(speech_params_string)
    local sound_name_BigInt =  DataView.ArrayBuffer(16)
    sound_name_BigInt:SetInt64(0,sound_name)
    local sound_ref_BigInt =  DataView.ArrayBuffer(16)
    sound_ref_BigInt:SetInt64(0,sound_ref)
    local speech_params_BigInt = DataView.ArrayBuffer(16)
    speech_params_BigInt:SetInt64(0,speech_params)
    struct:SetInt64(0,sound_name_BigInt:GetInt64(0))
    struct:SetInt64(8,sound_ref_BigInt:GetInt64(0))
    struct:SetInt32(16, speech_line)
    struct:SetInt64(24,speech_params_BigInt:GetInt64(0))
    struct:SetInt32(32, 0)
    struct:SetInt32(40, 1)
	struct:SetInt32(48, 1)
	struct:SetInt32(56, 1)
	Citizen.InvokeNative(0x8E04FEDD28D42462, entity_id, struct:Buffer());
end

-- Function to play ambient speech from a position
local function play_ambient_speech_from_position(x,y,z,sound_ref_string,sound_name_string,speech_line)
    local struct = DataView.ArrayBuffer(128)
    local sound_name = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", sound_name_string,Citizen.ResultAsLong())
    local sound_ref  = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING",sound_ref_string,Citizen.ResultAsLong())
    local sound_name_BigInt =  DataView.ArrayBuffer(16)
    sound_name_BigInt:SetInt64(0,sound_name)
    local sound_ref_BigInt =  DataView.ArrayBuffer(16)
    sound_ref_BigInt:SetInt64(0,sound_ref)
    local speech_params_BigInt = DataView.ArrayBuffer(16)
    speech_params_BigInt:SetInt64(0,291934926)
    struct:SetInt64(0,sound_name_BigInt:GetInt64(0))
    struct:SetInt64(8,sound_ref_BigInt:GetInt64(0))
    struct:SetInt32(16, speech_line)
    struct:SetInt64(24,speech_params_BigInt:GetInt64(0))
    struct:SetInt32(32, 0)
    struct:SetInt32(40, 1)
	struct:SetInt32(48, 1)
	struct:SetInt32(56, 1)
	Citizen.InvokeNative(0xED640017ED337E45,x,y,z,struct:Buffer())
end

----------------
CreateThread(function()
    cached_createstream = createStream
    cached_music_events = categorizeMusicEvents(music_events)
    cached_frontend_soundsets = frontend_soundsets
    cached_audio_flags = audio_flags
end)
RegisterCommand('audiodev', function(source, args)
    openVoiceLineMenu()
end, false)

function openVoiceLineMenu()
    lib.registerContext({
        id = 'voiceline_menu',
        title = 'Audio Developer Tool',
        options = {
            {
                title = 'CreateStream',
                description = 'Start Audio using CreateStream',
                menu = 'createstream_menu'
            },
            {
                title = 'Music Events (MEDIUM LOAD)',
                description = 'Start, stop or mix OST from the game',
                menu = 'music_events_menu'
            },
            {
                title = 'Frontend Soundsets',
                description = 'Play or stop frontend soundsets',
                menu = 'frontend_soundsets_menu'
            },
            {
                title = 'Audio Banks (LONG LOAD)',
                description = 'Play ambient speech from audio banks',
                menu = 'audio_banks_menu'
            },
            {
                title = 'Audio Flags',
                description = 'Set or unset various audio flags',
                menu = 'audio_flags_menu'
            }
        }
    })

    -- CreateStream Menu
    local soundset_menu_options = {
        {
            title = 'Back',
            description = 'Go back to the CreateStream menu',
            menu = 'createstream_menu'
        },
    }

    for streamName, soundSets in pairs(cached_createstream) do
        local stream_menu_options = {
            {
                title = 'Back',
                description = 'Go back to the Select Soundset menu',
                menu = 'soundset_menu'
            },
        }

        for _, soundSet in ipairs(soundSets) do
            table.insert(stream_menu_options, {
                title = streamName .. ' (' .. soundSet .. ')',
                description = 'Play ' .. streamName .. ' with soundSet ' .. soundSet,
                event = 'wd_audiodev:playSound',
                args = {soundSet = soundSet, streamName = streamName}
            })
        end

        lib.registerContext({
            id = streamName .. '_menu',
            title = streamName,
            menu = 'soundset_menu',
            options = stream_menu_options
        })

        table.insert(soundset_menu_options, {
            title = streamName,
            description = 'Open ' .. streamName .. ' soundsets',
            menu = streamName .. '_menu'
        })
    end

    lib.registerContext({
        id = 'soundset_menu',
        title = 'Select Soundset',
        options = soundset_menu_options
    })

    lib.registerContext({
        id = 'createstream_menu',
        title = 'CreateStream',
        options = {
            {
                title = 'Back',
                description = 'Go back to the main menu',
                menu = 'voiceline_menu'
            },
            {
                title = 'Select Soundset',
                description = 'Choose a soundset from the list',
                menu = 'soundset_menu'
            }
        }
    })

    -- Music Events Menu
    local music_events_options = {
        {
            title = 'Back',
            description = 'Go back to the main menu',
            menu = 'voiceline_menu'
        },
    }

    for category, events in pairs(cached_music_events) do
        local category_menu_options = {
            {
                title = 'Back',
                description = 'Go back to the Music Events menu',
                menu = 'music_events_menu'
            },
        }

        for _, event in ipairs(events) do
            table.insert(category_menu_options, {
                title = event,
                description = 'Start ' .. event .. ' music event',
                event = 'wd_audiodev:musicEvent',
                args = {eventName = event}
            })
        end

        lib.registerContext({
            id = category .. '_menu',
            title = category,
            menu = 'music_events_menu',
            options = category_menu_options
        })

        table.insert(music_events_options, {
            title = category,
            description = 'Open ' .. category .. ' music events',
            menu = category .. '_menu'
        })
    end

    lib.registerContext({
        id = 'music_events_menu',
        title = 'Music Events',
        options = music_events_options
    })

    -- audio bank
    local audio_banks_options = {
        {
            title = 'Back',
            description = 'Go back to the main menu',
            menu = 'voiceline_menu'
        },
    }
    
    for bank_name, sounds in pairs(audiobanks) do
        local bank_menu_options = {
            {
                title = 'Back',
                description = 'Go back to the Audio Banks menu',
                menu = 'audio_banks_menu'
            },
        }
    
        for _, sound_hash in ipairs(sounds) do
            table.insert(bank_menu_options, {
                title = tostring(sound_hash),
                description = 'Play ' .. tostring(sound_hash) .. ' sound',
                event = 'wd_audiodev:playAudioBankSound',
                args = {bank_name = bank_name, sound_hash = sound_hash}
            })
        end
    
        lib.registerContext({
            id = bank_name .. '_menu',
            title = bank_name,
            menu = 'audio_banks_menu',
            options = bank_menu_options
        })
    
        table.insert(audio_banks_options, {
            title = bank_name,
            description = 'Open ' .. bank_name .. ' audio bank',
            menu = bank_name .. '_menu'
        })
    end
    
    lib.registerContext({
        id = 'audio_banks_menu',  
        title = 'Audio Banks',
        options = audio_banks_options
    })

    -- Audio Flags Menu
    local audio_flags_options = {
        {
            title = 'Back',
            description = 'Go back to the main menu',
            menu = 'voiceline_menu'
        },
    }

    for _, flagName in ipairs(cached_audio_flags) do
        table.insert(audio_flags_options, {
            title = flagName,
            description = 'Toggle ' .. flagName,
            event = 'wd_audiodev:toggleAudioFlag',
            args = {flagName = flagName}
        })
    end

    lib.registerContext({
        id = 'audio_flags_menu',
        title = 'Audio Flags',
        options = audio_flags_options
    })

    -- Frontend Soundsets Menu
    local frontend_soundsets_options = {
        {
            title = 'Back',
            description = 'Go back to the main menu',
            menu = 'voiceline_menu'
        },
    }

    for soundsetRef, soundsetNames in pairs(cached_frontend_soundsets) do
        local soundset_menu_options = {
            {
                title = 'Back',
                description = 'Go back to the Frontend Soundsets menu',
                menu = 'frontend_soundsets_menu'
            },
        }

        for _, soundsetName in ipairs(soundsetNames) do
            table.insert(soundset_menu_options, {
                title = soundsetName,
                description = 'Play or stop ' .. soundsetName .. ' soundset',
                event = 'wd_audiodev:playFrontendSoundset',
                args = {soundsetRef = soundsetRef, soundsetName = soundsetName}
            })
        end

        lib.registerContext({
            id = soundsetRef .. '_menu',
            title = soundsetRef,
            menu = 'frontend_soundsets_menu',
            options = soundset_menu_options
        })

        table.insert(frontend_soundsets_options, {
            title = soundsetRef,
            description = 'Open ' .. soundsetRef .. ' subcategory',
            menu = soundsetRef .. '_menu'
        })
    end

    lib.registerContext({
        id = 'frontend_soundsets_menu',
        title = 'Frontend Soundsets',
        options = frontend_soundsets_options
    })

    lib.showContext('voiceline_menu')
end

AddEventHandler('wd_audiodev:playSound', function(data)
    local soundSet = data.soundSet
    local streamName = data.streamName

    local timeout = 0
    while not LoadStream(soundSet, streamName) do
        Wait(1)
        timeout = timeout + 1
        if timeout > 200 then
            break
        end
    end
    local streamedMusic = Citizen.InvokeNative(0x0556C784FA056628, soundSet, streamName)
    PlayStreamFromPed(cache.ped, streamedMusic)

    lib.registerContext({
        id = 'sound_options_menu',
        title = 'Sound Options',
        menu = streamName .. '_menu',
        options = {
            {
                title = 'Stop Audio',
                description = 'Stop the currently playing soundset',
                event = 'wd_audiodev:stopAudio',
                args = {streamedMusic = streamedMusic}
            },
            {
                title = 'Copy To Clipboard',
                description = 'Copy the code snippet to the clipboard',
                event = 'wd_audiodev:copyToClipboard',
                args = {soundSet = soundSet, streamName = streamName}
            }
        }
    })
    lib.showContext('sound_options_menu')
end)

AddEventHandler('wd_audiodev:playAudioBankSound', function(data)
    local bank_name = data.bank_name
    local sound_hash = data.sound_hash

    if sound_hash then
        lib.registerContext({
            id = 'audio_bank_options_menu',
            title = 'Audio Bank Options',
            menu = bank_name .. '_menu',
            options = {
                {
                    title = 'Play Speech From Entity',
                    description = 'Play the sound from the player entity',
                    event = 'wd_audiodev:playSpeechFromEntity',
                    args = {bank_name = bank_name, sound_hash = sound_hash}
                },
                {
                    title = 'Play Speech From Location',
                    description = 'Play the sound from a specific location',
                    event = 'wd_audiodev:playSpeechFromLocation',
                    args = {bank_name = bank_name, sound_hash = sound_hash}
                },
            }
        })
        lib.showContext('audio_bank_options_menu')
    else
        print("Sound hash not found for bank: " .. tostring(bank_name))
    end
end)

AddEventHandler('wd_audiodev:playSpeechFromEntity', function(data)
    local bank_name = data.bank_name
    local sound_hash = data.sound_hash

    lib.registerContext({
        id = 'speech_params_menu',
        title = 'Select Speech Params',
        menu = 'audio_bank_options_menu',
        options = {
            {
                title = 'speech_params_allow_repeat',
                description = 'Allow the speech to repeat',
                event = 'wd_audiodev:playSpeechWithParams',
                args = {bank_name = bank_name, sound_hash = sound_hash, speech_params = 'speech_params_allow_repeat'}
            },
            {
                title = 'speech_params_force',
                description = 'Force the speech to play',
                event = 'wd_audiodev:playSpeechWithParams',
                args = {bank_name = bank_name, sound_hash = sound_hash, speech_params = 'speech_params_force'}
            },
            {
                title = 'speech_params_shouted',
                description = 'Play the speech as shouted',
                event = 'wd_audiodev:playSpeechWithParams',
                args = {bank_name = bank_name, sound_hash = sound_hash, speech_params = 'speech_params_shouted'}
            },
            -- Add more speech params options as needed
        }
    })
    lib.showContext('speech_params_menu')
end)

AddEventHandler('wd_audiodev:playSpeechWithParams', function(data)
    local bank_name = data.bank_name
    local sound_hash = data.sound_hash
    local speech_params = data.speech_params

    play_ambient_speech_from_entity(cache.ped, bank_name, sound_hash, speech_params, 0)
    lib.registerContext({
        id = 'speech_clipboard_menu',
        title = 'AudioBank Options',
        menu = 'audio_bank_options_menu',
        options = {
            {
                title = 'Copy To Clipboard',
                description = 'Copy the code snippet to the clipboard',
                event = 'wd_audiodev:copyToClipboard',
                args = {bank_name = bank_name, sound_hash = sound_hash, speech_params = speech_params}
            }
        }
    })
    lib.showContext('speech_clipboard_menu')
end)

AddEventHandler('wd_audiodev:playSpeechFromLocation', function(data)
    local bank_name = data.bank_name
    local sound_hash = data.sound_hash

    if sound_hash then
        local x, y, z = table.unpack(GetEntityCoords(cache.ped))
        print(bank_name, sound_hash)
        play_ambient_speech_from_position(x, y, z, bank_name, sound_hash, 0)
    else
        print("Sound hash not found for bank: " .. tostring(bank_name))
    end
    lib.registerContext({
        id = 'speech_clipboard_menu',
        title = 'AudioBank Options',
        menu = 'audio_bank_options_menu',
        options = {
            {
                title = 'Copy To Clipboard',
                description = 'Copy the code snippet to the clipboard',
                event = 'wd_audiodev:copyToClipboard',
                args = {bank_name = bank_name, sound_hash = sound_hash}
            }
        }
    })
    lib.showContext('speech_clipboard_menu')
end)

AddEventHandler('wd_audiodev:musicEvent', function(data)
    local eventName = data.eventName
    PrepareMusicEvent(eventName)
    Wait(100)
    TriggerMusicEvent(eventName)

    lib.registerContext({
        id = 'music_options_menu',
        title = 'Music Options',
        menu = 'music_events_menu',
        options = {
            {
                title = 'Stop Audio',
                description = 'Stop the currently playing music event',
                event = 'wd_audiodev:stopMusicEvent',
                args = {eventName = eventName}
            },
            {
                title = 'Copy To Clipboard',
                description = 'Copy the code snippet to the clipboard',
                event = 'wd_audiodev:copyToClipboard',
                args = {eventName = eventName}
            }
        }
    })
    lib.showContext('music_options_menu')
end)

AddEventHandler('wd_audiodev:toggleAudioFlag', function(data)
    local flagName = data.flagName

    
    lib.registerContext({
        id = 'audio_flag_options_menu_' .. flagName,
        title = 'Audio Flag Options',
        menu = 'audio_flags_menu',
        options = {
            {
                title = 'Back',
                description = 'Go back to the Audio Flags menu',
                menu = 'audio_flags_menu'
            },
            {
                title = 'State: True',
                description = 'Set the audio flag state to true',
                onSelect = function()
                    -- Set the audio flag state to true
                    Citizen.InvokeNative(0xB9EFD5C25018725A, flagName, true)
                    lib.notify({ title = 'Audio Flag', description = flagName .. ' set to True', type = 'inform' })
                    
                    -- Show copy to clipboard option after setting the state
                    showCopyToClipboardOption(flagName, true)
                end
            },
            {
                title = 'State: False',
                description = 'Set the audio flag state to false',
                onSelect = function()
                    -- Set the audio flag state to false
                    Citizen.InvokeNative(0xB9EFD5C25018725A, flagName, false)
                    lib.notify({ title = 'Audio Flag', description = flagName .. ' set to False', type = 'inform' })
                    
                    -- Show copy to clipboard option after setting the state
                    showCopyToClipboardOption(flagName, false)
                end
            }
        }
    })


    lib.showContext('audio_flag_options_menu_' .. flagName)
end)

-- Function to show the 'Copy To Clipboard' option
function showCopyToClipboardOption(flagName, flagState)
    lib.registerContext({
        id = 'copy_to_clipboard_' .. flagName,
        title = 'Copy to Clipboard',
        options = {
            {
                title = 'Copy State to Clipboard',
                description = 'Copy the ' .. tostring(flagState) .. ' state to the clipboard',
                onSelect = function()
                    TriggerEvent('wd_audiodev:copyToClipboard', {flagName = flagName, flagState = flagState})
                end
            }
        }
    })
    
    lib.showContext('copy_to_clipboard_' .. flagName)
end



AddEventHandler('wd_audiodev:playFrontendSoundset', function(data)
    local soundsetRef = data.soundsetRef
    local soundsetName = data.soundsetName

    if not is_frontend_sound_playing then
        if soundsetRef ~= 0 then
            Citizen.InvokeNative(0x0F2A2175734926D8, soundsetName, soundsetRef)
        end
        Citizen.InvokeNative(0x67C540AA08E4A6F5, soundsetName, soundsetRef, true, 0)
        is_frontend_sound_playing = true
        print("sound frontend is playing")

        
        Citizen.SetTimeout(3000, function()
            Citizen.InvokeNative(0x9D746964E0CF2C5F, soundsetName, soundsetRef)
            is_frontend_sound_playing = false
            print("sound frontend is stopped")
        end)
    else
        Citizen.InvokeNative(0x9D746964E0CF2C5F, soundsetName, soundsetRef)
        is_frontend_sound_playing = false
        print("sound frontend is stopped")
    end

    lib.registerContext({
        id = 'frontend_soundset_options_menu',
        title = 'Frontend Soundset Options',
        menu = 'frontend_soundsets_menu',
        options = {
            {
                title = 'Stop Audio',
                description = 'Stop the currently playing frontend soundset',
                event = 'wd_audiodev:stopFrontendSoundset',
                args = {soundsetName = soundsetName, soundsetRef = soundsetRef}
            },
            {
                title = 'Copy To Clipboard',
                description = 'Copy the code snippet to the clipboard',
                event = 'wd_audiodev:copyToClipboard',
                args = {soundsetName = soundsetName, soundsetRef = soundsetRef}
            }
        }
    })
    lib.showContext('frontend_soundset_options_menu')
end)

AddEventHandler('wd_audiodev:stopFrontendSoundset', function(data)
    local soundsetName = data.soundsetName
    local soundsetRef = data.soundsetRef
    Citizen.InvokeNative(0x9D746964E0CF2C5F, soundsetName, soundsetRef)
    is_frontend_sound_playing = false
    print("sound frontend is stopped")
end)

function categorizeMusicEvents(events)
    local categories = {}

    for _, event in ipairs(events) do
        local prefix = event:match("^(.+)_")
        if prefix then
            if not categories[prefix] then
                categories[prefix] = {}
            end
            table.insert(categories[prefix], event)
        end
    end

    return categories
end

AddEventHandler('wd_audiodev:stopAudio', function(data)
    local streamedMusic = data.streamedMusic
    StopStream(streamedMusic)
end)

AddEventHandler('wd_audiodev:stopMusicEvent', function(data)
    local eventName = data.eventName
    CancelMusicEvent(eventName)
    Citizen.InvokeNative(0x706D57B0F50DA710, "MC_MUSIC_STOP")
end)

AddEventHandler('wd_audiodev:copyToClipboard', function(data)
    local soundSet = data.soundSet
    local streamName = data.streamName
    local eventName = data.eventName
    local soundsetName = data.soundsetName
    local soundsetRef = data.soundsetRef
    local flagName = data.flagName
    local bank_name = data.bank_name
    local sound_hash = data.sound_hash
    local speech_params = data.speech_params
    
    if soundSet and streamName then
        local format = [[
            local soundSet = "%s"
            local streamName = "%s"
            local timeout = 0
            while not LoadStream(soundSet, streamName) do
                Wait(1)
                timeout = timeout + 1
                if timeout > 200 then
                    break
                end
            end
            local streamedMusic = Citizen.InvokeNative(0x0556C784FA056628, soundSet, streamName)
            PlayStreamFromPed(cache.ped, streamedMusic)
        ]]
        lib.setClipboard(string.format(format, soundSet, streamName))
        lib.notify({
            title = 'Success',
            description = 'Code snippet copied to clipboard!',
            type = 'success'
        })
    elseif eventName then
        local format = [[
            local eventName = "%s"
            PrepareMusicEvent(eventName)
            Wait(100)
            TriggerMusicEvent(eventName)
        ]]
        lib.setClipboard(string.format(format, eventName))
        lib.notify({
            title = 'Success',
            description = 'Code snippet copied to clipboard!',
            type = 'success'
        })
    elseif soundsetName and soundsetRef then
        local format = [[
            local is_frontend_sound_playing = false
            local frontend_soundset_ref = "%s"
            local frontend_soundset_name = "%s"

            if not is_frontend_sound_playing then
                if frontend_soundset_ref ~= 0 then
                    Citizen.InvokeNative(0x0F2A2175734926D8, frontend_soundset_name, frontend_soundset_ref)
                end
                Citizen.InvokeNative(0x67C540AA08E4A6F5, frontend_soundset_name, frontend_soundset_ref, true, 0)
                is_frontend_sound_playing = true
                print("sound frontend is playing")
            else
                Citizen.InvokeNative(0x9D746964E0CF2C5F, frontend_soundset_name, frontend_soundset_ref)
                is_frontend_sound_playing = false
                print("sound frontend is stopped")
            end
        ]]
        lib.setClipboard(string.format(format, soundsetRef, soundsetName))
        lib.notify({
            title = 'Success',
            description = 'Code snippet copied to clipboard!',
            type = 'success'
        })
    elseif flagName then
        local flagState = data.flagState
        local format = [[
            -- Set the audio flag to %s
            Citizen.InvokeNative(0xB9EFD5C25018725A, "%s", %s)
        ]]
        lib.setClipboard(string.format(format, tostring(flagState), flagName, tostring(flagState)))
        lib.notify({
            title = 'Success',
            description = 'Code snippet copied to clipboard!',
            type = 'success'
        })
    elseif bank_name and sound_hash and speech_params then
        local format = [[
            -- Play speech from entity with selected speech params
            play_ambient_speech_from_entity(cache.ped, "%s", "%s", "%s", 0)

        ]]
        lib.setClipboard(string.format(format, bank_name, sound_hash, speech_params))
        lib.notify({
            title = 'Success',
            description = 'Code snippet copied to clipboard!',
            type = 'success'
        })
    elseif bank_name and sound_hash then
            local format = [[
                -- Play speech from location
                local x, y, z = table.unpack(GetEntityCoords(cache.ped))
                play_ambient_speech_from_position(x, y, z, "%s", "%s", 0)
            ]]
            lib.setClipboard(string.format(format, bank_name, sound_hash))
            lib.notify({
                title = 'Success',
                description = 'Code snippet copied to clipboard!',
                type = 'success'
            })
    end
end)

