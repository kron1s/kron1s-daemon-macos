tell application "System Events" to set activeApplication to name of first process whose unix id is 3095

if (activeApplication = "Safari") or (activeApplication = "Webkit") then
    using terms from application "Safari"
        tell application activeApplication to set currentPath to URL of front document
        tell application activeApplication to set currentTitle to name of front document
    end using terms from
else if (activeApplication = "Google Chrome") or (activeApplication = "Google Chrome Canary") or (activeApplication = "Chromium") then
    using terms from application "Google Chrome"
        tell application activeApplication to set currentPath to URL of active tab of front window
        tell application activeApplication to set currentTitle to title of active tab of front window
    end using terms from
else
    return "Unsupported"
end if

return currentPath & "
" & currentTitle
