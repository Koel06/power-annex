# Defines quick functionality for clearing terminals after messy outputs.

"Clears the full terminal screen of all text, similar to 'clear' in linux"
function clear()
    print("\033c")
end

macro clear()
    print("\033c")
end
