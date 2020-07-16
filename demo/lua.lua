local awful = require 'awful'
local naughty = require 'naughty'

local FM0 = {}

local radio_stations = {
	['🇬🇧 👨🏿‍🎤\tBBC Radio 1Xtra'] = {
		'http://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/hls/uk/sbr_high/ak/bbc_1xtra.m3u8',
		'http://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/hls/nonuk/sbr_low/ak/bbc_1xtra.m3u8'
	},
	['🇦🇹 🥑\tRadio FM4'] = {
		'https://fm4shoutcast.sf.apa.at/listen.pls',
		'http://mp3stream1.apasf.apa.at'
	},
	['🇺🇸 🦄\tNightwave Plaza'] = {'http://radio.plaza.one/opus', 'http://radio.plaza.one/ogg'},
	['🇪🇸 🔥\tLos 40'] = {
		'https://21313.live.streamtheworld.com/LOS40AAC.aac',
		'https://20873.live.streamtheworld.com/LOS40AAC.aac'
	}
}

local function play(id, i)
	local i = i or 1
	if radio_stations[id][i] then
		awful.spawn.easy_async(
			{'mpv', '--mute=no', '--x11-name=FM0', '--force-window=yes', radio_stations[id][i]},
			function(_, _, _, exit)
				naughty.notify {
					title = string.format('Exitcode: %s, i: %s, Station: %s', exit, i, radio_stations[id][1])
				}
				if exit ~= 0 and exit ~= 4 and radio_stations[id][i + 1] then
					play(id, i + 1)
				end
			end
		)
	end
end

function FM0.start_radio()
	local stations = 'quit\n'
	for k in pairs(radio_stations) do
		stations = stations .. k .. '\n'
	end
	awful.spawn.easy_async_with_shell(
		'echo "' .. stations .. '" | rofi -dmenu -i -no-custom -p "Play …"',
		function(stdout)
			play(string.sub(stdout, 1, -2))
		end
	)
end

function FM0.get_menu()
	local menu = {}
	for k in pairs(radio_stations) do
		table.insert(
			menu,
			{
				k,
				function()
					play(k)
				end
			}
		)
	end
	return menu
end

return FM0
