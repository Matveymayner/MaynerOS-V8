local component = require("component")
local event = require("event")
local filesystem = require("filesystem")
local gpu = component.gpu
local computer = require("computer")
local shell = require("shell")
local os = require("os")

-- Функция для вывода сообщения на экран
local function message(str)
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
  gpu.fill(1, 1, 80, 25, " ")
  gpu.set(1, 1, str)
end

-- Функция для воспроизведения звукового эффекта
local function playSound(frequency, duration)
  computer.beep(frequency, duration)
end

-- Функция для вывода кнопки
local function drawButton(x, y, width, height, text, foreground, background)
  gpu.setForeground(foreground)
  gpu.setBackground(background)
  gpu.fill(x, y, width, height, " ")
  local textX = x + math.floor((width - #text) / 2)
  local textY = y + math.floor(height / 2)
  gpu.set(textX, textY, text)
end

-- Функция для обработки команд
local function handleCommand(command)
  if command == "1" then
    message("Shutting down...")
    os.sleep(2)
    computer.shutdown()
  elseif command == "2" then
    message("Rebooting...")
    os.sleep(2)
    computer.shutdown(true)
  elseif command == "3" then
    message("Random number: " .. tostring(math.random(1, 100)))
  elseif command == "4" then
    message("Are you sure you want to delete the OS? (y/n)")
    local _, _, _, _, _, response = event.pull("key_down")
    if response == 21 then
      os.execute("rm /MaynerOS-V7.lua")
      os.execute("rm /autorun.lua")
    else
      message("OS delete aborted.")
      os.sleep(2)
    end
  elseif command == "5" then
    gpu.setForeground(0xFFFFFF)
    gpu.setBackground(0x0000FF)
    gpu.fill(1, 1, 80, 25, " ")
    gpu.set(32, 12, ":( Your PC Dead Sorry")
    gpu.setBackground(0x000000)
  elseif command == "6" then
    message("Are you sure you want to shutdown the computer? (y/n)")
    while true do
      local _, _, _, _, _, response = event.pull("key_down")
      if response == 21 then
        message("Shutting down...")
        playSound(0.8, 0.3) -- Воспроизведение звукового эффекта при выключении
        os.sleep(2)
        computer.shutdown()
      elseif response == 49 then
        message("Shutdown aborted.")
        os.sleep(2)
        break
      end
    end
  elseif command == "Flappy Bird" then
    message("Starting Flappy Bird...")
    os.sleep(2)
    shell.execute("FlappyBird.lua")
  elseif command == "Snake" then
    message("Starting Snake...")
    os.sleep(2)
    shell.execute("Snake.lua")
  else
    message("Invalid command.")
    os.sleep(2)
  end
end

-- Очищаем экран
gpu.setForeground(0xFFFFFF)
gpu.setBackground(0x0000FF)
gpu.fill(1, 1, 80, 25, " ")

-- Выводим кнопки
drawButton(10, 2, 12, 3, "Shutdown", 0xFFFFFF, 0x555555)
drawButton(24, 2, 12, 3, "Reboot", 0xFFFFFF, 0x555555)
drawButton(38, 2, 15, 3, "Random Number", 0xFFFFFF, 0x555555)
drawButton(55, 2, 12, 3, "Delete OS", 0xFFFFFF, 0x555555)
drawButton(69, 2, 12, 3, "Blue Screen", 0xFFFFFF, 0x555555)
drawButton(69, 5, 12, 3, "Back to CMD", 0xFFFFFF, 0x555555)

-- Выводим кнопки игр
drawButton(10, 5, 12, 3, "Flappy Bird", 0xFFFFFF, 0x555555)
drawButton(24, 5, 12, 3, "Snake", 0xFFFFFF, 0x555555)

-- Выводим нижнюю полоску с надписью "Mayner OS"
gpu.setBackground(0xFFFFFF)
gpu.setForeground(0x000000)
gpu.fill(1, 23, 80, 2, " ")
gpu.set(34, 24, "Mayner OS")

-- Функция для создания папки
local function createFolder()
  message("Enter folder name:")
  local _, _, _, _, _, name = event.pull("key_down")
  if name and #name > 0 then
    local path = filesystem.getWorkingDirectory() .. "/" .. name
    local success, err = filesystem.makeDirectory(path)
    if success then
      message("Folder created: " .. path)
    else
      message("Failed to create folder: " .. err)
    end
    os.sleep(2)
  else
    message("Invalid folder name.")
    os.sleep(2)
  end
end

-- Функция для создания файла
local function createFile()
  message("Enter file name:")
  local _, _, _, _, _, name = event.pull("key_down")
  if name and #name > 0 then
    local path = filesystem.getWorkingDirectory() .. "/" .. name
    local file = io.open(path, "w")
    if file then
      file:close()
      message("File created: " .. path)
    else
      message("Failed to create file.")
    end
    os.sleep(2)
  else
    message("Invalid file name.")
    os.sleep(2)
  end
end

-- Функция для переименования папки или файла
local function renameItem()
  message("Enter current name:")
  local _, _, _, _, _, currentName = event.pull("key_down")
  if currentName and #currentName > 0 then
    message("Enter new name:")
    local _, _, _, _, _, newName = event.pull("key_down")
    if newName and #newName > 0 then
      local currentPath = filesystem.getWorkingDirectory() .. "/" .. currentName
      local newPath = filesystem.getWorkingDirectory() .. "/" .. newName
      local success, err = filesystem.rename(currentPath, newPath)
      if success then
        message("Renamed: " .. currentPath .. " to " .. newPath)
      else
        message("Failed to rename: " .. err)
      end
      os.sleep(2)
    else
      message("Invalid new name.")
      os.sleep(2)
    end
  else
    message("Invalid current name.")
    os.sleep(2)
  end
end

-- Функция для редактирования файла
local function editFile()
  message("Enter file name:")
  local _, _, _, _, _, name = event.pull("key_down")
  if name and #name > 0 then
    local path = filesystem.getWorkingDirectory() .. "/" .. name
    if filesystem.exists(path) and not filesystem.isDirectory(path) then
      gpu.fill(1, 1, 80, 25, " ")
      gpu.setForeground(0xFFFFFF)
      gpu.setBackground(0x000000)
      local file = io.open(path, "r")
      if file then
        local content = file:read("*a")
        file:close()
        gpu.set(1, 1, content)
        gpu.setForeground(0x00FF00)
        gpu.set(1, 24, "Press any key to save and exit.")
        local _, _, _, _, _, _ = event.pull("key_down")
        file = io.open(path, "w")
        if file then
          file:write(content)
          file:close()
          message("File saved: " .. path)
        else
          message("Failed to save file.")
        end
      else
        message("Failed to open file.")
      end
    else
      message("File not found.")
    end
    os.sleep(2)
  else
    message("Invalid file name.")
    os.sleep(2)
  end
end

-- Функция для открытия командной строки
local function openCommandLine()
  print "Print MaynerOS-V7.lua to start OS"
  while true do
    local _, _, _, _, _, command = event.pull("key_down")
    if command == 14 then
      break
    end
  end
end

-- Функция для запуска Flappy Bird
local function runFlappyBird()
  shell.execute("flappybird.lua")
end

-- Функция для запуска Snake
local function runSnake()
  shell.execute("snake.lua")
end

-- Ожидаем нажатия кнопки
while true do
  local _, _, x, y = event.pull("touch")
  if y == 2 then
    if x >= 10 and x <= 21 then
      handleCommand("1")
    elseif x >= 24 and x <= 35 then
      handleCommand("2")
    elseif x >= 38 and x <= 52 then
      handleCommand("3")
    elseif x >= 55 and x <= 66 then
      handleCommand("4")
    elseif x >= 69 and x <= 80 then
      handleCommand("5")
    end
  elseif y == 5 then
    if x >= 10 and x <= 21 then
      runFlappyBird()
    elseif x >= 24 and x <= 35 then
      runSnake()
    end
  elseif y == 24 and x >= 1 and x <= 9 then
    message("Choose an option:\n1. Create Folder\n2. Create File\n3. Rename Item\n4. Edit File")
    local _, _, _, _, _, option = event.pull("key_down")
    if option == 2 then
      createFolder()
    elseif option == 3 then
      createFile()
    elseif option == 4 then
      renameItem()
    elseif option == 5 then
      editFile()
    end
  elseif y == 24 and x >= 69 and x <= 80 then
    openCommandLine()
  end
end
