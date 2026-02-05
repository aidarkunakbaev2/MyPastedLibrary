# Celestial UI Library - Документация

![Celestial UI](https://img.shields.io/badge/Celestial-UI-purple)
![Roblox](https://img.shields.io/badge/Roblox-E42020)
![Version](https://img.shields.io/badge/Version-2.2-blue)

Celestial - это мощная и красивая библиотека пользовательского интерфейса для Roblox, разработанная для создания функциональных и стабильных GUI с минимальными усилиями.

## 📋 Оглавление

- [Установка](#установка)
- [Быстрый старт](#быстрый-старт)
- [Основные функции](#основные-функции)
- [Элементы UI](#элементы-ui)
- [Система конфигураций](#система-конфигураций)
- [Менеджер тем](#менеджер-тем)
- [Примеры использования](#примеры-использования)
- [API Reference](#api-reference)
- [Troubleshooting](#troubleshooting)
- [Лицензия](#лицензия)

## 🚀 Установка

Просто скопируйте всю библиотеку в свой скрипт:

```lua
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/aidarkunakbaev2/MyPastedLibrary/refs/heads/main/source.lua"))()
```

Или вставьте содержимое файла библиотеки напрямую.

## ⚡ Быстрый старт

```lua
-- Инициализация библиотеки
local library = require(путь_к_библиотеке)

-- Создание окна
local window = library:Window({
    Name = "Мой GUI"  -- Название окна
})

-- Создание вкладки
local page = window:Page({
    Name = "Основные настройки"
})

-- Создание секции
local section = page:Section({
    Name = "Настройки игры",
    Side = "left",      -- "left" или "right"
    Size = 250         -- Высота секции
})

-- Добавление элементов управления
local toggle = section:Toggle({
    Name = "Включить читы",
    Default = false,
    Callback = function(state)
        print("Читы:", state)
    end
})

-- Открытие вкладки
page:Turn(true)
```

## 🎯 Основные функции

### Создание окна
```lua
local window = library:Window({
    Name = string,      -- Название окна
    Theme = table       -- (Опционально) Кастомная тема
})
```

### Создание вкладки
```lua
local page = window:Page({
    Name = string       -- Название вкладки
})
```

### Управление вкладкой
```lua
page:Turn(state)        -- Открыть/закрыть вкладку
```

## 🎨 Элементы UI

### Метка (Label)
```lua
section:Label({
    Name = string,      -- Текст метки
    Offset = number     -- (Опционально) Отступ слева
})
```

### Переключатель (Toggle)
```lua
local toggle = section:Toggle({
    Name = string,      -- Название
    Default = boolean,  -- Начальное состояние
    Callback = function(state) end
})

-- Методы
toggle:Get()            -- Получить текущее состояние
toggle:Set(value)       -- Установить состояние
toggle:Remove()         -- Удалить элемент
```

### Кнопка (Button)
```lua
section:Button({
    Name = string,
    Callback = function() end
})
```

### Слайдер (Slider)
```lua
local slider = section:Slider({
    Name = string,      -- Название
    Default = number,   -- Начальное значение
    Minimum = number,   -- Минимальное значение
    Maximum = number,   -- Максимальное значение
    Decimals = number,  -- Количество знаков после запятой
    Suffix = string,    -- Суффикс (%, px и т.д.)
    Callback = function(value) end
})

-- Методы
slider:Get()            -- Получить текущее значение
slider:Set(value)       -- Установить значение
slider:Remove()         -- Удалить элемент
```

### Выпадающий список (Dropdown)
```lua
local dropdown = section:Dropdown({
    Name = string,      -- Название
    Default = string,   -- Значение по умолчанию
    Options = {table},  -- Список опций
    Callback = function(selected) end
})

-- Методы
dropdown:Get()          -- Получить выбранную опцию
dropdown:Set(value)     -- Выбрать опцию
dropdown:UpdateOptions(newOptions) -- Обновить список опций
dropdown:Remove()       -- Удалить элемент
```

## 💾 Система конфигураций

### Сохранение настроек
```lua
library.Config:Save("имя_конфига")
```

### Загрузка настроек
```lua
library.Config:Load("имя_конфига")
```

### Удаление конфига
```lua
library.Config:Delete("имя_конфига")
```

### Получение списка конфигов
```lua
local configs = library.Config:GetConfigs()
```

## 🎨 Менеджер тем

### Смена темы
```lua
library:SetTheme({
    Background = Color3.fromRGB(51, 51, 51),
    Primary = Color3.fromRGB(170, 85, 235),   -- Основной цвет
    Secondary = Color3.fromRGB(101, 51, 141), -- Вторичный цвет
    Text = Color3.fromRGB(142, 142, 142),     -- Цвет текста
    Dark = Color3.fromRGB(13, 13, 13),        -- Темный фон
    Light = Color3.fromRGB(142, 142, 142)     -- Светлый текст
})
```

### Получение текущей темы
```lua
local currentTheme = library:GetTheme()
```

## 📖 Примеры использования

### Полный пример GUI
```lua
local library = require(путь_к_библиотеке)

local window = library:Window({
    Name = "<font color=\"#92EAAA\">Celestial GUI</font>"
})

-- Основные настройки
local main = window:Page({Name = "Основные"})
local mainSection = main:Section({Name = "Настройки", Size = 200})

local aimbotToggle = mainSection:Toggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(state)
        -- Логика аимбота
    end
})

local fovSlider = mainSection:Slider({
    Name = "Field of View",
    Default = 90,
    Minimum = 60,
    Maximum = 120,
    Decimals = 0,
    Suffix = "°",
    Callback = function(value)
        -- Настройка FOV
    end
})

-- Визуальные эффекты
local visuals = window:Page({Name = "Визуалы"})
local visualsSection = visuals:Section({Name = "Эффекты", Side = "left", Size = 250})

local espDropdown = visualsSection:Dropdown({
    Name = "ESP Style",
    Default = "Box",
    Options = {"Box", "Skeleton", "Health Bar", "None"},
    Callback = function(style)
        -- Выбор стиля ESP
    end
})

local chamsToggle = visualsSection:Toggle({
    Name = "Chams",
    Default = true,
    Callback = function(state)
        -- Включение/выключение Chams
    end
})

-- Настройки конфигураций
local configPage = window:Page({Name = "Конфиги"})
local configSection = configPage:Section({Name = "Управление", Size = 150})

configSection:Button({
    Name = "Сохранить конфиг",
    Callback = function()
        library.Config:Save("current_config")
    end
})

configSection:Button({
    Name = "Загрузить конфиг",
    Callback = function()
        library.Config:Load("current_config")
    end
})

-- Включение первой вкладки
main:Turn(true)
```

### Пример смены темы
```lua
-- Темная тема
library:SetTheme({
    Primary = Color3.fromRGB(0, 170, 255),
    Background = Color3.fromRGB(30, 30, 30)
})

-- Светлая тема
library:SetTheme({
    Primary = Color3.fromRGB(255, 85, 85),
    Background = Color3.fromRGB(240, 240, 240),
    Text = Color3.fromRGB(50, 50, 50)
})

-- Зеленая тема
library:SetTheme({
    Primary = Color3.fromRGB(0, 255, 127),
    Secondary = Color3.fromRGB(0, 180, 90)
})
```

## 🔧 API Reference

### Утилиты (utility)
- `utility:Create(table)` - Создание Roblox инстанса
- `utility:Tween(object, tweenInfo, properties)` - Анимация через TweenService
- `utility:Connection(connectionInfo)` - Создание соединения
- `utility:RemoveConnection(connectionInfo)` - Удаление соединения
- `utility:Round(number, decimals)` - Округление числа

### Управление окном
- `window:RefreshTabs()` - Обновить размеры вкладок
- `window.Dragging` - Флаг перетаскивания окна

### Управление секцией
- `section:Update()` - Обновить скроллбар секции

## 🐛 Troubleshooting

### Проблемы и решения

**Проблема:** Ошибка при создании элементов
```lua
-- Решение: Убедитесь, что все обязательные параметры переданы
section:Toggle({
    Name = "Обязательное поле",
    Callback = function() end  -- Обязательный параметр
})
```

**Проблема:** Слайдер не обновляется при перетаскивании
```lua
-- Решение: Проверьте значения Minimum/Maximum
section:Slider({
    Minimum = 0,    -- Должно быть меньше Maximum
    Maximum = 100   -- Должно быть больше Minimum
})
```

**Проблема:** Dropdown не открывается
```lua
-- Решение: Убедитесь, что Options не пустой
section:Dropdown({
    Options = {"Option1", "Option2"}  -- Должен быть не пустой массив
})
```

**Проблема:** Конфиги не сохраняются
```lua
-- Решение: Проверьте права на запись файлов
if isfolder and writefile then
    library.Config:Save("config")
else
    print("Файловая система недоступна")
end
```

### Советы по производительности

1. **Используйте pcall для обработки ошибок:**
```lua
local success, error = pcall(function()
    library:SetTheme(customTheme)
end)
```

2. **Ограничьте количество элементов в секции:**
```lua
-- Слишком много элементов может вызвать лаги
section:Section({Size = 300}) -- Оптимальный размер
```

3. **Используйте вызовы Callback с осторожностью:**
```lua
-- Не делайте тяжелые вычисления в callback
toggle = section:Toggle({
    Callback = function(state)
        -- Легкая операция
        settingEnabled = state
    end
})
```

## 📝 Лицензия

Эта библиотека распространяется под лицензией MIT. Вы можете свободно использовать, модифицировать и распространять ее с указанием авторства.

## 🤝 Вклад в проект

Хотите улучшить библиотеку? Мы приветствуем пул-реквесты!

1. Форкните репозиторий
2. Создайте ветку для вашей функции (`git checkout -b feature/AmazingFeature`)
3. Закоммитьте изменения (`git commit -m 'Add AmazingFeature'`)
4. Запушьте в ветку (`git push origin feature/AmazingFeature`)
5. Откройте пул-реквест

## 📞 Поддержка

Если у вас есть вопросы или проблемы:

1. Проверьте [Issues](https://github.com/aidarkunakbaev2/MyPastedLibrary/issues)
2. Создайте новую issue с детальным описанием проблемы
3. Приложите код, который вызывает ошибку

---

**Celestial UI Library** - Сделано с ❤️ для Roblox сообщества

*Последнее обновление: Версия 2.2 - Добавлены Dropdown, Config Manager, Theme Changer*
