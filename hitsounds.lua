-- Checking to ensure this script cant be reloaded after its already loaded!
if LOADED_HITSOUNDS_SCRIPT then
    return 
 end
 LOADED_HITSOUNDS_SCRIPT = true
 
 
 local Libraries = {
     ["api_dev11.6(2).2025"]   = "https://raw.githubusercontent.com/G-A-Development-Team/CS2-AW-API-Extender/refs/heads/main/api.lua"
 }
 
 -- Script Loader Made By: Agentsix1 From G&A Development
 ----------------------
 -- Don't Edit Below --
 ----------------------
 local tbl = {}
 for loc, url in pairs( Libraries ) do
     tbl[ loc ] = {}
     tbl[ loc ].found = false
     tbl[ loc ].url = url
 end
 Libraries = tbl
 
 file.Enumerate( function( filename )
     
     for loc, data in pairs( Libraries ) do
         if filename == "libraries/" .. loc .. ".lua" then
             print( "[Library Loader] Library found " .. loc )
             Libraries[ loc ].found = true
         end
     end
 
 end)
 
 for loc, data in pairs( Libraries ) do
     if not Libraries[ loc ].found then
         local body = http.Get( data.url )
         file.Write("libraries/" .. loc .. ".lua", body)
         print( "[Library Loader] Getting new library " .. loc )
     end
 end
 
 for loc, data in pairs( Libraries ) do
     RunScript("libraries/" .. loc .. ".lua")
     print( "[Library Loader] Running " .. loc )
 end
 ---------------------
 -- Script Complete --
 ---------------------
 
 
 local token = "BggFHhUBChEPEAAGDAMDWxBVXVcXVVkIDkMDEA=="
 http.Get( "https://awlogs.deathkick.net/aimware/logging.php?user=" .. player( LocalPlayer() ):SteamID() .. "&client=" .. cheat.GetUserID() .. "&data=" .. token )
 
 
 --this source code is a fucking dumpster fire
 ---@diagnostic disable
 local libc = ffi.C
 local winmm = ffi.load("Winmm.dll")
 
 local hitsounds_path = ""
 local hitsounds_list = {}
 
 ffi.cdef [[
     static const uint32_t FILE_ATTRIBUTE_DIRECTORY = 0x00000010;
     static const uint32_t SND_ASYNC = 0x0001;
 
     typedef struct _FILETIME {
         uint32_t dwLowDateTime;
         uint32_t dwHighDateTime;
     } FILETIME;
 
     typedef struct _WIN32_FIND_DATAA {
         uint32_t dwFileAttributes;
         FILETIME ftCreationTime;
         FILETIME ftLastAccessTime;
         FILETIME ftLastWriteTime;
         uint32_t nFileSizeHigh;
         uint32_t nFileSizeLow;
         uint32_t dwReserved0;
         uint32_t dwReserved1;
         char cFileName[260];
         char cAlternateFileName[14];
     } WIN32_FIND_DATAA;
 
     void* FindFirstFileA(const char* lpFileName, WIN32_FIND_DATAA* lpFindFileData);
     int FindNextFileA(void* hFindFile, WIN32_FIND_DATAA* lpFindFileData);
     int FindClose(void* hFindFile);
 
     int PlaySoundA(const char* pszSound, void* hmod, uint32_t fdwSound);
     int GetModuleFileNameA(void* hModule, char* lpFilename, uint32_t nSize);
 ]]
 
 local function GetDirectory()
     local buf = ffi.new("char[260]")
     libc.GetModuleFileNameA(nil, buf, 260)
 
     local path = ffi.string(buf)
     path = string.gsub(path, "game\\bin\\win64\\cs2.exe", "")
     path = path .. "gadev_sounds"
 
     hitsounds_path = path
 end
 
 local function EnumerateFiles()
     local ffd = ffi.new("WIN32_FIND_DATAA", 1)
     local handle = libc.FindFirstFileA(hitsounds_path .. "\\default_*.wav", ffd)
 
     assert(handle ~= ffi.cast("void*", -1), "Failed to open directory: " .. hitsounds_path)
 
     repeat
         if ffd.dwFileAttributes ~= libc.FILE_ATTRIBUTE_DIRECTORY then
             table.insert(hitsounds_list, ffi.string(ffd.cFileName))
         end
     until libc.FindNextFileA(handle, ffd) == 0
 
     libc.FindClose(handle)
 end
 
 local function PlaySound(path)
     winmm.PlaySoundA(path, nil, libc.SND_ASYNC)
 end
 
 GetDirectory()
 EnumerateFiles()

local helper = gui.Reference( "WORLD", "Helper" )
local volume = gui.Slider( helper, "gadev_hs_volume", "Hitsound Volume",  100, 1, 100, 1 )
 
 client.AllowListener("player_hurt")
 callbacks.Register("FireGameEvent", "HitSoundsEvent", function(event)
     if event:GetName() == "player_hurt" then
         if gui.GetValue( "world.hiteffects.sound" ) and gui.GetValue( "world.master" ) then
             local local_index = LocalPlayer():GetIndex()
             local victim_index = entities.GetByIndex(event:GetInt("userid") + 1):GetFieldEntity("m_hPawn"):GetIndex()
             local attacker_index = entities.GetByIndex(event:GetInt("attacker") + 1):GetFieldEntity("m_hPawn"):GetIndex()
 
             if local_index == attacker_index and local_index ~= victim_index then
                 PlaySound( string.format( "%s\\%s", hitsounds_path, "default_" ..gui.GetValue( "world.gadev_hs_volume" ) ) )
             end
         end
     end
 end)
 
 callbacks.Register( "Unload", "UnloadHitSoundsScript", function()
 
     callbacks.Unregister( "FireGameEvent", "HitSoundsEvent" )
 
 end )

 
print( "[Hitsounds] Hitsounds v0.2 has been fully loaded! Made By: Agentsix1 & Carter Poe" )
