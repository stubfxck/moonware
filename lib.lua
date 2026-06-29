local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local input = game:GetService("UserInputService")
local run = game:GetService("RunService")
local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new

local utility = {}

local objects = {}
local themes = {
	Background = Color3.fromRGB(24, 24, 24), 
	Glow = Color3.fromRGB(0, 0, 0), 
	Accent = Color3.fromRGB(10, 10, 10), 
	LightContrast = Color3.fromRGB(20, 20, 20), 
	DarkContrast = Color3.fromRGB(14, 14, 14),  
	TextColor = Color3.fromRGB(255, 255, 255)
}

do
	function utility:Create(instance, properties, children)
		local object = Instance.new(instance)
		
		for i, v in pairs(properties or {}) do
			object[i] = v
			
			if typeof(v) == "Color3" then
				local theme = utility:Find(themes, v)
				
				if theme then
					objects[theme] = objects[theme] or {}
					objects[theme][i] = objects[theme][i] or setmetatable({}, {_mode = "k"})
					
					table.insert(objects[theme][i], object)
				end
			end
		end
		
		for i, module in pairs(children or {}) do
			module.Parent = object
		end
		
		return object
	end
	
	function utility:Tween(instance, properties, duration, ...)
		tween:Create(instance, tweeninfo(duration, ...), properties):Play()
	end
	
	function utility:Wait()
		run.RenderStepped:Wait()
		return true
	end
	
	function utility:Find(table, value)
		for i, v in  pairs(table) do
			if v == value then
				return i
			end
		end
	end
	
	function utility:Sort(pattern, values)
		local new = {}
		pattern = pattern:lower()
		
		if pattern == "" then
			return values
		end
		
		for i, value in pairs(values) do
			if tostring(value):lower():find(pattern) then
				table.insert(new, value)
			end
		end
		
		return new
	end
	
	function utility:Pop(object, shrink)
		local clone = object:Clone()
		
		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.Size = clone.Size - UDim2.new(0, shrink, 0, shrink)
		clone.Position = UDim2.new(0.5, 0, 0.5, 0)
		
		clone.Parent = object
		clone:ClearAllChildren()
		
		object.ImageTransparency = 1
		utility:Tween(clone, {Size = object.Size}, 0.2)
		
		spawn(function()
			wait(0.2)
		
			object.ImageTransparency = 0
			clone:Destroy()
		end)
		
		return clone
	end
	
	function utility:InitializeKeybind()
		
		self.keybinds = {}
		self.ended = {}
		
		input.InputBegan:Connect(function(key)
		
			if self.keybinds[key.KeyCode] then
				for i, bind in pairs(self.keybinds[key.KeyCode]) do
					bind()
				end
			end
		end)
		
		input.InputEnded:Connect(function(key)
			if key.UserInputType == Enum.UserInputType.MouseButton1 then
				for i, callback in pairs(self.ended) do
					callback()
				end
			end
		end)
	end
	
	function utility:BindToKey(key, callback)
		 
		self.keybinds[key] = self.keybinds[key] or {}
		
		table.insert(self.keybinds[key], callback)
		
		return {
			UnBind = function()
				for i, bind in pairs(self.keybinds[key]) do
					if bind == callback then
						table.remove(self.keybinds[key], i)
					end
				end
			end
		}
	end
	
	function utility:KeyPressed()
		local key = input.InputBegan:Wait()
		
		while key.UserInputType ~= Enum.UserInputType.Keyboard	 do
			key = input.InputBegan:Wait()
		end
		
		wait()
		
		return key
	end
	
	function utility:DraggingEnabled(frame, parent)
	
		parent = parent or frame
		
		local dragging = false
		local dragInput, mousePos, framePos

		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				mousePos = input.Position
				framePos = parent.Position
				
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		frame.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				dragInput = input
			end
		end)

		input.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - mousePos
				parent.Position  = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
			end
		end)

	end
	
	function utility:DraggingEnded(callback)
		table.insert(self.ended, callback)
	end

	function utility:CreateCloseButton(parent)
	    local closeButton = utility:Create("ImageButton", {
	        Name = "CloseButton",
	        Parent = parent,
	        BackgroundTransparency = 0.3,
	        BackgroundColor3 = themes.DarkContrast,
	        BorderSizePixel = 0,
	        Size = UDim2.new(0, 22, 0, 22),
	        Position = UDim2.new(1, -28, 0, 6),
	        ZIndex = 10,
	        Image = "rbxassetid://5012538583",
	        ImageColor3 = themes.TextColor,
	        ImageTransparency = 0.2
	    }, {
	        utility:Create("UICorner", {
	            CornerRadius = UDim.new(0, 3)
	        })
	    })
	    
	    closeButton.MouseEnter:Connect(function()
	        utility:Tween(closeButton, {
	            BackgroundColor3 = Color3.fromRGB(220, 60, 60),
	            ImageColor3 = Color3.fromRGB(255, 255, 255),
	            Size = UDim2.new(0, 24, 0, 24),
	            Position = UDim2.new(1, -29, 0, 5)
	        }, 0.15)
	    end)
	    
	    closeButton.MouseLeave:Connect(function()
	        utility:Tween(closeButton, {
	            BackgroundColor3 = themes.DarkContrast,
	            ImageColor3 = themes.TextColor,
	            Size = UDim2.new(0, 22, 0, 22),
	            Position = UDim2.new(1, -28, 0, 6)
	        }, 0.15)
	    end)
	    
	    return closeButton
	end
	
	function utility:CreateMinimizeButton(parent)
		local minimizeButton = utility:Create("TextButton", {
			Name = "MinimizeButton",
			Parent = parent,
			BackgroundTransparency = 0.3,
			BackgroundColor3 = themes.DarkContrast,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 22, 0, 22),
			Position = UDim2.new(1, -52, 0, 6),
			ZIndex = 10,
			Text = "-",
			Font = Enum.Font.Gotham,
			TextColor3 = themes.TextColor,
			TextSize = 16,
			TextTransparency = 0.2
		}, {
			utility:Create("UICorner", {CornerRadius = UDim.new(0, 3)})
		})

		minimizeButton.MouseEnter:Connect(function()
			utility:Tween(minimizeButton, {
				BackgroundColor3 = Color3.fromRGB(255, 220, 0),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Size = UDim2.new(0, 24, 0, 24),
				Position = UDim2.new(1, -53, 0, 5)
			}, 0.15)
		end)

		minimizeButton.MouseLeave:Connect(function()
			utility:Tween(minimizeButton, {
				BackgroundColor3 = themes.DarkContrast,
				TextColor3 = themes.TextColor,
				Size = UDim2.new(0, 22, 0, 22),
				Position = UDim2.new(1, -52, 0, 6)
			}, 0.15)
		end)

		return minimizeButton
	end

	function utility:DisableKeybind()
		self.keybinds = {}
		self.ended = {}
	end
end


local library = {}
local page = {}
local section = {}

do
	library.__index = library
	page.__index = page
	section.__index = section
	
	function library.new(title, keybind)
		local container = utility:Create("ScreenGui", {
			Name = title,
			Parent = game.CoreGui
		}, {
			utility:Create("ImageLabel", {
				Name = "Main",
				BackgroundTransparency = 1,
				Position = UDim2.new(0.25, 0, 0.052435593, 0),
				Size = UDim2.new(0, 511, 0, 428),
				Image = "rbxassetid://4641149554",
				ImageColor3 = themes.Background,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(4, 4, 296, 296)
			}, {
				utility:Create("ImageLabel", {
					Name = "Glow",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, -15, 0, -15),
					Size = UDim2.new(1, 30, 1, 30),
					ZIndex = 0,
					Image = "rbxassetid://5028857084",
					ImageColor3 = themes.Glow,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(24, 24, 276, 276)
				}),
				utility:Create("ImageLabel", {
					Name = "Pages",
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					Position = UDim2.new(0, 0, 0, 38),
					Size = UDim2.new(0, 126, 1, -38),
					ZIndex = 3,
					Image = "rbxassetid://5012534273",
					ImageColor3 = themes.DarkContrast,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(4, 4, 296, 296)
				}, {
					utility:Create("ScrollingFrame", {
						Name = "Pages_Container",
						Active = true,
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 0, 0, 10),
						Size = UDim2.new(1, 0, 1, -20),
						CanvasSize = UDim2.new(0, 0, 0, 314),
						ScrollBarThickness = 0
					}, {
						utility:Create("UIListLayout", {
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, 10)
						})
					})
				}),
				utility:Create("ImageLabel", {
					Name = "TopBar",
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					Size = UDim2.new(1, 0, 0, 38),
					ZIndex = 5,
					Image = "rbxassetid://4595286933",
					ImageColor3 = themes.Accent,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(4, 4, 296, 296)
				}, {
					utility:Create("TextLabel", {
						Name = "Title",
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 12, 0, 19),
						Size = UDim2.new(1, -80, 0, 16),
						ZIndex = 5,
						Font = Enum.Font.GothamBold,
						Text = title,
						TextColor3 = themes.TextColor,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left
					})
				})
			})
		})

		utility:InitializeKeybind()
		utility:DraggingEnabled(container.Main.TopBar, container.Main)

		local lib = setmetatable({
			container = container,
			pagesContainer = container.Main.Pages.Pages_Container,
			pages = {},
			keybind = keybind
		}, library)

		local closeButton = utility:CreateCloseButton(container.Main.TopBar)
		lib.closeButton = closeButton
		closeButton.MouseButton1Click:Connect(function()
			utility:Tween(closeButton, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -27, 0, 7)}, 0.1)
			wait(0.1)
			if lib.Destroy then
				lib:Destroy()
			end
		end)

		local minimizeButton = utility:CreateMinimizeButton(container.Main.TopBar)
		local minimized = false
		local originalSize = container.Main.Size

		minimizeButton.MouseEnter:Connect(function()
			utility:Tween(minimizeButton, {BackgroundColor3 = Color3.fromRGB(255, 220, 0), Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -53, 0, 5)}, 0.15)
		end)
		minimizeButton.MouseLeave:Connect(function()
			utility:Tween(minimizeButton, {BackgroundColor3 = Color3.fromRGB(255, 200, 0), Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(1, -52, 0, 6)}, 0.15)
		end)

		minimizeButton.MouseButton1Click:Connect(function()
			minimized = not minimized
			if minimized then
				utility:Tween(container.Main, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 38)}, 0.3)
				for _, child in pairs(container.Main:GetChildren()) do
					if child ~= container.Main.TopBar then
						if child:IsA("Frame") or child:IsA("ImageLabel") then
							utility:Tween(child, {ImageTransparency = 1}, 0.2)
						elseif child:IsA("TextLabel") or child:IsA("TextBox") then
							utility:Tween(child, {TextTransparency = 1}, 0.2)
						end
					end
				end
			else
				utility:Tween(container.Main, {Size = originalSize}, 0.3)
				for _, child in pairs(container.Main:GetChildren()) do
					if child ~= container.Main.TopBar then
						if child:IsA("Frame") or child:IsA("ImageLabel") then
							utility:Tween(child, {ImageTransparency = 0}, 0.3)
						elseif child:IsA("TextLabel") or child:IsA("TextBox") then
							utility:Tween(child, {TextTransparency = 0}, 0.3)
						end
					end
				end
			end
		end)

		if keybind then
			utility:BindToKey(Enum.KeyCode[keybind] or keybind, function()
				lib:toggle()
			end)
		end

		return lib
	end

	function page.new(library, title, icon)
		local button = utility:Create("TextButton", {
			Name = title,
			Parent = library.pagesContainer,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 26),
			ZIndex = 3,
			AutoButtonColor = false,
			Font = Enum.Font.Gotham,
			Text = "",
			TextSize = 14
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 40, 0.5, 0),
				Size = UDim2.new(0, 76, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				TextTransparency = 0.65,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			icon and utility:Create("ImageLabel", {
				Name = "Icon", 
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0.5, 0),
				Size = UDim2.new(0, 16, 0, 16),
				ZIndex = 3,
				Image = "rbxassetid://" .. tostring(icon),
				ImageColor3 = themes.TextColor,
				ImageTransparency = 0.64,
				ScaleType = Enum.ScaleType.Fit
			}) or {}
		})
		
		local container = utility:Create("ScrollingFrame", {
			Name = title,
			Parent = library.container.Main,
			Active = true,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 134, 0, 46),
			Size = UDim2.new(1, -142, 1, -56),
			CanvasSize = UDim2.new(0, 0, 0, 466),
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = themes.DarkContrast,
			Visible = false
		}, {
			utility:Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 10)
			})
		})
		
		return setmetatable({
			library = library,
			container = container,
			button = button,
			sections = {}
		}, page)
	end
	
	function section.new(page, title)
		local container = utility:Create("ImageLabel", {
			Name = title,
			Parent = page.container,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -10, 0, 28),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.LightContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(4, 4, 296, 296),
			ClipsDescendants = true
		}, {
			utility:Create("Frame", {
				Name = "Container",
				Active = true,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 8, 0, 8),
				Size = UDim2.new(1, -16, 1, -16)
			}, {
				utility:Create("TextLabel", {
					Name = "Title",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20),
					ZIndex = 2,
					Font = Enum.Font.GothamSemibold,
					Text = title,
					TextColor3 = themes.TextColor,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTransparency = 1
				}),
				utility:Create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4)
				})
			})
		})
		
		return setmetatable({
			page = page,
			container = container.Container,
			colorpickers = {},
			modules = {},
			binds = {},
			lists = {},
		}, section) 
	end
	
	function library:addPage(...)
		local page = page.new(self, ...)
		local button = page.button
		
		table.insert(self.pages, page)

		button.MouseButton1Click:Connect(function()
			self:SelectPage(page, true)
		end)
		
		return page
	end
	
	function page:addSection(...)
		local section = section.new(self, ...)
		
		table.insert(self.sections, section)
		
		return section
	end
	
	function library:setTheme(theme, color3)
		themes[theme] = color3
		
		for property, objects in pairs(objects[theme]) do
			for i, object in pairs(objects) do
				if not object.Parent or (object.Name == "Button" and object.Parent.Name == "ColorPicker") then
					objects[i] = nil
				else
					object[property] = color3
				end
			end
		end
	end
	
	function library:toggle()
	    if self.toggling then return end
	    self.toggling = true
	    
	    local container = self.container.Main
	    local topbar = container.TopBar
	    local closeButton = self.closeButton
	    
	    if self.position then
	        utility:Tween(container, {Size = UDim2.new(0, 511, 0, 428), Position = self.position}, 0.2)
	        wait(0.2)
	        utility:Tween(topbar, {Size = UDim2.new(1, 0, 0, 38)}, 0.2)
	        if closeButton then
	            closeButton.Visible = true
	            utility:Tween(closeButton, {ImageTransparency = 0.2, BackgroundTransparency = 0.3}, 0.2)
	        end
	        wait(0.2)
	        container.ClipsDescendants = false
	        self.position = nil
	    else
	        self.position = container.Position
	        container.ClipsDescendants = true
	        if closeButton then
	            utility:Tween(closeButton, {ImageTransparency = 1, BackgroundTransparency = 1}, 0.2)
	        end
	        utility:Tween(topbar, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)
	        wait(0.2)
	        utility:Tween(container, {Size = UDim2.new(0, 511, 0, 0), Position = self.position + UDim2.new(0, 0, 0, 428)}, 0.2)
	        wait(0.2)
	        if closeButton then closeButton.Visible = false end
	    end
	    
	    self.toggling = false
	end
	
	function library:Notify(title, text, callback)
		title = title or "Notification"
		text = text or ""

		local notification = utility:Create("ImageLabel", {
			Name = "Notification",
			Parent = self.container,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0, 0),
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.Background,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(4, 4, 296, 296),
			ZIndex = 3,
			ClipsDescendants = true,
			AnchorPoint = Vector2.new(1, 0)
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 8),
				Size = UDim2.new(1, -40, 0, 16),
				ZIndex = 4,
				Font = Enum.Font.GothamSemibold,
				TextColor3 = themes.TextColor,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = title,
				TextWrapped = true
			}),
			utility:Create("TextLabel", {
				Name = "Text",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 28),
				Size = UDim2.new(1, -40, 0, 16),
				ZIndex = 4,
				Font = Enum.Font.Gotham,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = text,
				TextWrapped = true
			}),
			utility:Create("ImageButton", {
				Name = "Close",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -26, 0, 8),
				Size = UDim2.new(0, 16, 0, 16),
				Image = "rbxassetid://5012538583",
				ImageColor3 = themes.TextColor,
				ZIndex = 4
			})
		})

		local titleSize = game:GetService("TextService"):GetTextSize(notification.Title.Text, notification.Title.TextSize, notification.Title.Font, Vector2.new(500, math.huge))
		local textSize  = game:GetService("TextService"):GetTextSize(notification.Text.Text,  notification.Text.TextSize,  notification.Text.Font,  Vector2.new(500, math.huge))
		local width  = math.max(titleSize.X, textSize.X) + 40
		local height = titleSize.Y + textSize.Y + 28

		local yOffset = 10
		if library.activeNotifications == nil then library.activeNotifications = {} end
		for _, n in ipairs(library.activeNotifications) do
			yOffset = yOffset + n.AbsoluteSize.Y + 8
		end
		notification.Position = UDim2.new(1, -10, 0, yOffset)
		notification.Size = UDim2.new(0, 0, 0, 0)

		table.insert(library.activeNotifications, notification)
		utility:Tween(notification, {Size = UDim2.new(0, width, 0, height)}, 0.2)

		local function close()
			if not notification.Parent then return end
			notification:Destroy()
			for i, n in ipairs(library.activeNotifications) do
				if n == notification then table.remove(library.activeNotifications, i) break end
			end
			local yOff = 10
			for _, n in ipairs(library.activeNotifications) do
				utility:Tween(n, {Position = UDim2.new(1, -10, 0, yOff)}, 0.2)
				yOff = yOff + n.AbsoluteSize.Y + 8
			end
		end

		notification.Close.MouseButton1Click:Connect(close)
		delay(4, function() if notification.Parent then close() end end)
	end

	function library:Destroy()
	    if self.closeButton then self.closeButton:Destroy() self.closeButton = nil end
	    if self.container   then self.container:Destroy()   self.container = nil end
	    if self.pagesContainer then self.pagesContainer:ClearAllChildren() self.pagesContainer = nil end
	    if self.pages then for k in pairs(self.pages) do self.pages[k] = nil end end
	    if utility.DisableKeybind then utility:DisableKeybind() end
	end
	
	-- =========================================================
	-- addButton
	-- =========================================================
	function section:addButton(title, callback)
		local button = utility:Create("ImageButton", {
			Name = "Button",
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				TextTransparency = 0.10000000149012
			})
		})
		
		table.insert(self.modules, button)
		
		local text = button.Title
		local debounce
		
		button.MouseButton1Click:Connect(function()
			if debounce then return end
			utility:Pop(button, 10)
			debounce = true
			text.TextSize = 0
			utility:Tween(button.Title, {TextSize = 14}, 0.2)
			wait(0.2)
			utility:Tween(button.Title, {TextSize = 12}, 0.2)
			if callback then
				callback(function(...) self:updateButton(button, ...) end)
			end
			debounce = false
		end)
		
		return button
	end
	
	-- =========================================================
	-- addToggle(title, default, callback, disabled?)
	--   disabled = true  → visually rendered, no interaction
	-- =========================================================
	function section:addToggle(title, default, callback, disabled)
	    local toggle = utility:Create("ImageButton", {
	        Name = "Toggle",
	        Parent = self.container,
	        BackgroundTransparency = 1,
	        BorderSizePixel = 0,
	        Size = UDim2.new(1, 0, 0, 30),
	        ZIndex = 2,
	        Image = "rbxassetid://5028857472",
	        ImageColor3 = themes.DarkContrast,
	        ScaleType = Enum.ScaleType.Slice,
	        SliceCenter = Rect.new(2, 2, 298, 298)
	    },{
	        utility:Create("TextLabel", {
	            Name = "Title",
	            AnchorPoint = Vector2.new(0, 0.5),
	            BackgroundTransparency = 1,
	            Position = UDim2.new(0, 10, 0.5, 1),
	            Size = UDim2.new(0.5, 0, 1, 0),
	            ZIndex = 3,
	            Font = Enum.Font.Gotham,
	            Text = title,
	            TextColor3 = themes.TextColor,
	            TextSize = 12,
	            TextTransparency = disabled and 0.55 or 0.10000000149012,
	            TextXAlignment = Enum.TextXAlignment.Left
	        }),
	        utility:Create("ImageLabel", {
	            Name = "Button",
	            BackgroundTransparency = 1,
	            BorderSizePixel = 0,
	            Position = UDim2.new(1, -50, 0.5, -8),
	            Size = UDim2.new(0, 40, 0, 16),
	            ZIndex = 2,
	            Image = "rbxassetid://5028857472",
	            ImageColor3 = disabled and Color3.fromRGB(30, 30, 32) or themes.LightContrast,
	            ScaleType = Enum.ScaleType.Slice,
	            SliceCenter = Rect.new(2, 2, 298, 298)
	        }, {
	            utility:Create("ImageLabel", {
	                Name = "Frame",
	                BackgroundTransparency = 1,
	                Position = UDim2.new(0, 2, 0.5, -6),
	                Size = UDim2.new(1, -22, 1, -4),
	                ZIndex = 2,
	                Image = "rbxassetid://5028857472",
	                ImageColor3 = disabled and Color3.fromRGB(60, 60, 65) or themes.TextColor,
	                ScaleType = Enum.ScaleType.Slice,
	                SliceCenter = Rect.new(2, 2, 298, 298)
	            })
	        })
	    })

	    table.insert(self.modules, toggle)

	    local active = default or false
	    self:updateToggle(toggle, nil, active and 1 or 0)

	    -- Только если не disabled — подключаем клик
	    if not disabled then
		    toggle.MouseButton1Click:Connect(function()
		        active = not active
		        self:updateToggle(toggle, nil, active and 1 or 0)
		        if callback then
		            callback(active, function(...) self:updateToggle(toggle, ...) end)
		        end
		    end)
		end

	    return toggle
	end

	-- =========================================================
	-- addTextbox
	-- =========================================================
	function section:addTextbox(title, default, callback)
		local textbox = utility:Create("ImageButton", {
			Name = "Textbox",
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0.5, 1),
				Size = UDim2.new(0.5, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				TextTransparency = 0.10000000149012,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("ImageLabel", {
				Name = "Button",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -110, 0.5, -8),
				Size = UDim2.new(0, 100, 0, 16),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.LightContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("TextBox", {
					Name = "Textbox", 
					BackgroundTransparency = 1,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Position = UDim2.new(0, 5, 0, 0),
					Size = UDim2.new(1, -10, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.GothamSemibold,
					Text = default or "",
					TextColor3 = themes.TextColor,
					TextSize = 11
				})
			})
		})
		
		table.insert(self.modules, textbox)
		
		local button = textbox.Button
		local input = button.Textbox
		
		textbox.MouseButton1Click:Connect(function()
			if textbox.Button.Size ~= UDim2.new(0, 100, 0, 16) then return end
			utility:Tween(textbox.Button, {Size = UDim2.new(0, 200, 0, 16), Position = UDim2.new(1, -210, 0.5, -8)}, 0.2)
			wait()
			input.TextXAlignment = Enum.TextXAlignment.Left
			input:CaptureFocus()
		end)
		
		input:GetPropertyChangedSignal("Text"):Connect(function()
			if button.ImageTransparency == 0 and (button.Size == UDim2.new(0, 200, 0, 16) or button.Size == UDim2.new(0, 100, 0, 16)) then
				utility:Pop(button, 10)
			end
			if callback then callback(input.Text, nil, function(...) self:updateTextbox(textbox, ...) end) end
		end)
		
		input.FocusLost:Connect(function()
			input.TextXAlignment = Enum.TextXAlignment.Center
			utility:Tween(textbox.Button, {Size = UDim2.new(0, 100, 0, 16), Position = UDim2.new(1, -110, 0.5, -8)}, 0.2)
			if callback then callback(input.Text, true, function(...) self:updateTextbox(textbox, ...) end) end
		end)
		
		return textbox
	end
	
	function section:addKeybind(title, default, callback, changedCallback)
		local keybind = utility:Create("ImageButton", {
			Name = "Keybind",
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0.5, 1),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				TextTransparency = 0.10000000149012,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("ImageLabel", {
				Name = "Button",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -110, 0.5, -8),
				Size = UDim2.new(0, 100, 0, 16),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.LightContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("TextLabel", {
					Name = "Text",
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.GothamSemibold,
					Text = default and default.Name or "None",
					TextColor3 = themes.TextColor,
					TextSize = 11
				})
			})
		})
		
		table.insert(self.modules, keybind)
		
		local text = keybind.Button.Text
		local button = keybind.Button
		
		local animate = function()
			if button.ImageTransparency == 0 then utility:Pop(button, 10) end
		end
		
		self.binds[keybind] = {callback = function()
			animate()
			if callback then callback(function(...) self:updateKeybind(keybind, ...) end) end
		end}
		
		if default and callback then self:updateKeybind(keybind, nil, default) end
		
		keybind.MouseButton1Click:Connect(function()
			animate()
			if self.binds[keybind].connection then return self:updateKeybind(keybind) end
			if text.Text == "None" then
				text.Text = "..."
				local key = utility:KeyPressed()
				self:updateKeybind(keybind, nil, key.KeyCode)
				animate()
				if changedCallback then changedCallback(key, function(...) self:updateKeybind(keybind, ...) end) end
			end
		end)
		
		return keybind
	end

	-- =========================================================
	-- addSlider(title, default, min, max, callback, disabled?)
	--   disabled = true  → visually rendered, no interaction
	-- =========================================================
	function section:addSlider(title, default, min, max, callback, disabled)
		local DIM_FILL  = disabled and Color3.fromRGB(45, 45, 48)  or themes.TextColor
		local DIM_BAR   = disabled and Color3.fromRGB(25, 25, 27)  or themes.LightContrast
		local DIM_TEXT  = disabled and 0.55                        or 0.10000000149012

		local slider = utility:Create("ImageButton", {
			Name = "Slider",
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0.292817682, 0, 0.299145311, 0),
			Size = UDim2.new(1, 0, 0, 50),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 6),
				Size = UDim2.new(0.5, 0, 0, 16),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				TextTransparency = DIM_TEXT,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("TextBox", {
				Name = "TextBox",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -30, 0, 6),
				Size = UDim2.new(0, 20, 0, 16),
				ZIndex = 3,
				Font = Enum.Font.GothamSemibold,
				Text = default or min,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				TextTransparency = DIM_TEXT,
				TextXAlignment = Enum.TextXAlignment.Right
			}),
			utility:Create("TextLabel", {
				Name = "Slider",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 28),
				Size = UDim2.new(1, -20, 0, 16),
				ZIndex = 3,
				Text = "",
			}, {
				utility:Create("ImageLabel", {
					Name = "Bar",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0.5, 0),
					Size = UDim2.new(1, 0, 0, 4),
					ZIndex = 3,
					Image = "rbxassetid://5028857472",
					ImageColor3 = DIM_BAR,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 298, 298)
				}, {
					utility:Create("ImageLabel", {
						Name = "Fill",
						BackgroundTransparency = 1,
						Size = UDim2.new(0.8, 0, 1, 0),
						ZIndex = 3,
						Image = "rbxassetid://5028857472",
						ImageColor3 = DIM_FILL,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(2, 2, 298, 298)
					}, {
						utility:Create("ImageLabel", {
							Name = "Circle",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							ImageTransparency = 1.000,
							ImageColor3 = DIM_FILL,
							Position = UDim2.new(1, 0, 0.5, 0),
							Size = UDim2.new(0, 10, 0, 10),
							ZIndex = 3,
							Image = "rbxassetid://4608020054"
						})
					})
				})
			})
		})
		
		table.insert(self.modules, slider)
		
		local allowed = { [""] = true, ["-"] = true }
		local textbox = slider.TextBox
		local circle  = slider.Slider.Bar.Fill.Circle
		local value   = default or min
		local dragging

		local cb = function(v)
			if callback then callback(v, function(...) self:updateSlider(slider, ...) end) end
		end
		
		self:updateSlider(slider, nil, value, min, max)

		-- Только если не disabled — подключаем взаимодействие
		if not disabled then
			utility:DraggingEnded(function() dragging = false end)

			slider.MouseButton1Down:Connect(function()
				dragging = true
				while dragging do
					utility:Tween(circle, {ImageTransparency = 0}, 0.1)
					value = self:updateSlider(slider, nil, nil, min, max, value)
					cb(value)
					utility:Wait()
				end
				wait(0.5)
				utility:Tween(circle, {ImageTransparency = 1}, 0.2)
			end)

			textbox.FocusLost:Connect(function()
				if not tonumber(textbox.Text) then
					value = self:updateSlider(slider, nil, default or min, min, max)
					cb(value)
				end
			end)

			textbox:GetPropertyChangedSignal("Text"):Connect(function()
				local text = textbox.Text
				if not allowed[text] and not tonumber(text) then
					textbox.Text = text:sub(1, #text - 1)
				elseif not allowed[text] then
					value = self:updateSlider(slider, nil, tonumber(text) or value, min, max)
					cb(value)
				end
			end)
		end
		
		return slider
	end
	
	function section:addDropdown(title, list, callback)
		local dropdown = utility:Create("Frame", {
			Name = "Dropdown",
			Parent = self.container,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			ClipsDescendants = true
		}, {
			utility:Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4)
			}),
			utility:Create("ImageLabel", {
				Name = "Search",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 30),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.DarkContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("TextBox", {
					Name = "TextBox",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Position = UDim2.new(0, 10, 0.5, 1),
					Size = UDim2.new(1, -42, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.Gotham,
					Text = title,
					TextColor3 = themes.TextColor,
					TextSize = 12,
					TextTransparency = 0.10000000149012,
					TextXAlignment = Enum.TextXAlignment.Left
				}),
				utility:Create("ImageButton", {
					Name = "Button",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -28, 0.5, -9),
					Size = UDim2.new(0, 18, 0, 18),
					ZIndex = 3,
					Image = "rbxassetid://5012539403",
					ImageColor3 = themes.TextColor,
					SliceCenter = Rect.new(2, 2, 298, 298)
				})
			}),
			utility:Create("ImageLabel", {
				Name = "List",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, -34),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.Background,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("ScrollingFrame", {
					Name = "Frame",
					Active = true,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 4, 0, 4),
					Size = UDim2.new(1, -8, 1, -8),
					CanvasPosition = Vector2.new(0, 28),
					CanvasSize = UDim2.new(0, 0, 0, 120),
					ZIndex = 2,
					ScrollBarThickness = 3,
					ScrollBarImageColor3 = themes.DarkContrast
				}, {
					utility:Create("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 4)
					})
				})
			})
		})
		
		table.insert(self.modules, dropdown)
		
		local search = dropdown.Search
		local focused
		list = list or {}
		
		search.Button.MouseButton1Click:Connect(function()
			if search.Button.Rotation == 0 then self:updateDropdown(dropdown, nil, list, callback)
			else self:updateDropdown(dropdown, nil, nil, callback) end
		end)
		
		search.TextBox.Focused:Connect(function()
			if search.Button.Rotation == 0 then self:updateDropdown(dropdown, nil, list, callback) end
			focused = true
		end)
		
		search.TextBox.FocusLost:Connect(function() focused = false end)
		
		search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			if focused then
				local l = utility:Sort(search.TextBox.Text, list)
				l = #l ~= 0 and l
				self:updateDropdown(dropdown, nil, l, callback)
			end
		end)
		
		dropdown:GetPropertyChangedSignal("Size"):Connect(function() self:Resize() end)
		
		return dropdown
	end
	
	function section:addInfobox(title, text)
		local infobox = utility:Create("ImageLabel", {
			Name = "Infobox",
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 60),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298),
			ClipsDescendants = true
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 6),
				Size = UDim2.new(1, -20, 0, 16),
				ZIndex = 3,
				Font = Enum.Font.GothamSemibold,
				Text = title or "Info",
				TextColor3 = themes.TextColor,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("TextLabel", {
				Name = "Content",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 24),
				Size = UDim2.new(1, -20, 1, -28),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = text or "",
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				RichText = true
			})
		})

		local content = infobox.Content
		local textService = game:GetService("TextService")
		local size = textService:GetTextSize(content.Text, content.TextSize, content.Font, Vector2.new(content.AbsoluteSize.X, math.huge))
		infobox.Size = UDim2.new(1, 0, 0, size.Y + 32)

		content:GetPropertyChangedSignal("Text"):Connect(function()
			if string.match(content.Text, "https?://[%w%p]+") then
				content.TextColor3 = Color3.fromRGB(100, 200, 255)
				content.Text = "<u>"..content.Text.."</u>"
			end
		end)

		content.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local link = string.match(content.Text, "https?://[%w%p]+")
				if link then
					setclipboard(link)
					self.page.library:Notify("Copied", "Link copied to clipboard")
				end
			end
		end)

		table.insert(self.modules, infobox)
		return infobox
	end

	function library:SelectPage(page, toggle)
		if toggle and self.focusedPage == page then return end
		
		local button = page.button
		
		if toggle then
			button.Title.TextTransparency = 0
			button.Title.Font = Enum.Font.GothamSemibold
			if button:FindFirstChild("Icon") then button.Icon.ImageTransparency = 0 end
			
			local focusedPage = self.focusedPage
			self.focusedPage = page
			
			if focusedPage then self:SelectPage(focusedPage) end
			
			local existingSections = focusedPage and #focusedPage.sections or 0
			local sectionsRequired = #page.sections - existingSections
			
			page:Resize()
			for i, section in pairs(page.sections) do
				section.container.Parent.ImageTransparency = 0
			end
			
			if sectionsRequired < 0 then
				for i = existingSections, #page.sections + 1, -1 do
					local section = focusedPage.sections[i].container.Parent
					utility:Tween(section, {ImageTransparency = 1}, 0.1)
				end
			end
			
			wait(0.1)
			page.container.Visible = true
			if focusedPage then focusedPage.container.Visible = false end
			
			if sectionsRequired > 0 then
				for i = existingSections + 1, #page.sections do
					local section = page.sections[i].container.Parent
					section.ImageTransparency = 1
					utility:Tween(section, {ImageTransparency = 0}, 0.05)
				end
			end
			
			wait(0.05)
			for i, section in pairs(page.sections) do
				utility:Tween(section.container.Title, {TextTransparency = 0}, 0.1)
				section:Resize(true)
				wait(0.05)
			end
			
			wait(0.05)
			page:Resize(true)
		else
			button.Title.Font = Enum.Font.Gotham
			button.Title.TextTransparency = 0.65
			if button:FindFirstChild("Icon") then button.Icon.ImageTransparency = 0.65 end
			
			for i, section in pairs(page.sections) do
				utility:Tween(section.container.Parent, {Size = UDim2.new(1, -10, 0, 28)}, 0.1)
				utility:Tween(section.container.Title, {TextTransparency = 1}, 0.1)
			end
			
			wait(0.1)
			page.lastPosition = page.container.CanvasPosition.Y
			page:Resize()
		end
	end
	
	function page:Resize(scroll)
		local padding = 10
		local size = 0
		for i, section in pairs(self.sections) do
			size = size + section.container.Parent.AbsoluteSize.Y + padding
		end
		self.container.CanvasSize = UDim2.new(0, 0, 0, size)
		self.container.ScrollBarImageTransparency = (size > self.container.AbsoluteSize.Y) and 0 or 1
		if scroll then
			utility:Tween(self.container, {CanvasPosition = Vector2.new(0, self.lastPosition or 0)}, 0.2)
		end
	end
	
	function section:Resize(smooth)
		if self.page.library.focusedPage ~= self.page then return end
		
		local padding = 4
		local size = (4 * padding) + self.container.Title.AbsoluteSize.Y
		for i, module in pairs(self.modules) do
			size = size + module.AbsoluteSize.Y + padding
		end
		
		if smooth then
			utility:Tween(self.container.Parent, {Size = UDim2.new(1, -10, 0, size)}, 0.05)
		else
			self.container.Parent.Size = UDim2.new(1, -10, 0, size)
			self.page:Resize()
		end
	end
	
	function section:getModule(info)
		if table.find(self.modules, info) then return info end
		for i, module in pairs(self.modules) do
			if (module:FindFirstChild("Title") or module:FindFirstChild("TextBox", true)).Text == info then
				return module
			end
		end
		error("No module found under "..tostring(info))
	end
	
	function section:updateButton(button, title)
		button = self:getModule(button)
		button.Title.Text = title
	end
	
	function section:updateToggle(toggle, title, value)
		toggle = self:getModule(toggle)
		
		local position = { In = UDim2.new(0, 2, 0.5, -6), Out = UDim2.new(0, 20, 0.5, -6) }
		local frame = toggle.Button.Frame
		local boolValue = (value == true or value == 1)
		local state = boolValue and "Out" or "In"
		
		if title then toggle.Title.Text = title end
		
		utility:Tween(frame, {Size = UDim2.new(1, -22, 1, -9), Position = position[state] + UDim2.new(0, 0, 0, 2.5)}, 0.2)
		wait(0.1)
		utility:Tween(frame, {Size = UDim2.new(1, -22, 1, -4), Position = position[state]}, 0.1)
	end
	
	function section:updateTextbox(textbox, title, value)
		textbox = self:getModule(textbox)
		if title then textbox.Title.Text = title end
		if value then textbox.Button.Textbox.Text = value end
	end
	
	function section:updateKeybind(keybind, title, key)
		keybind = self:getModule(keybind)
		local text = keybind.Button.Text
		local bind = self.binds[keybind]
		if title then keybind.Title.Text = title end
		if bind.connection then bind.connection = bind.connection:UnBind() end
		if key then
			self.binds[keybind].connection = utility:BindToKey(key, bind.callback)
			text.Text = key.Name
		else
			text.Text = "None"
		end
	end
	
	function section:updateColorPicker(colorpicker, title, color)
		colorpicker = self:getModule(colorpicker)
		local picker   = self.colorpickers[colorpicker]
		local tab      = picker.tab
		local callback = picker.callback
		
		if title then colorpicker.Title.Text = title tab.Title.Text = title end
		
		local color3, hue, sat, brightness
		if type(color) == "table" then
			hue, sat, brightness = unpack(color)
			color3 = Color3.fromHSV(hue, sat, brightness)
		else
			color3 = color
			hue, sat, brightness = Color3.toHSV(color3)
		end
		
		utility:Tween(colorpicker.Button, {ImageColor3 = color3}, 0.5)
		utility:Tween(tab.Container.Color.Select, {Position = UDim2.new(hue, 0, 0, 0)}, 0.1)
		utility:Tween(tab.Container.Canvas, {ImageColor3 = Color3.fromHSV(hue, 1, 1)}, 0.5)
		utility:Tween(tab.Container.Canvas.Cursor, {Position = UDim2.new(sat, 0, 1 - brightness)}, 0.5)
		
		for i, container in pairs(tab.Container.Inputs:GetChildren()) do
			if container:IsA("ImageLabel") then
				local value = math.clamp(color3[container.Name], 0, 1) * 255
				container.Textbox.Text = math.floor(value)
			end
		end
	end
	
	function section:updateSlider(slider, title, value, min, max, lvalue)
		slider = self:getModule(slider)
		if title then slider.Title.Text = title end
		
		local bar     = slider.Slider.Bar
		local percent = (mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
		
		if value then percent = (value - min) / (max - min) end
		percent = math.clamp(percent, 0, 1)
		value = value or math.floor(min + (max - min) * percent)
		
		slider.TextBox.Text = value
		utility:Tween(bar.Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
		
		if value ~= lvalue and slider.ImageTransparency == 0 then utility:Pop(slider, 10) end
		
		return value
	end
	
	function section:updateDropdown(dropdown, title, list, callback)
		dropdown = self:getModule(dropdown)
		if title then dropdown.Search.TextBox.Text = title end
		
		local entries = 0
		utility:Pop(dropdown.Search, 10)
		
		for i, button in pairs(dropdown.List.Frame:GetChildren()) do
			if button:IsA("ImageButton") then button:Destroy() end
		end
		
		for i, value in pairs(list or {}) do
			local button = utility:Create("ImageButton", {
				Parent = dropdown.List.Frame,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 30),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.DarkContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0),
					Size = UDim2.new(1, -10, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.Gotham,
					Text = value,
					TextColor3 = themes.TextColor,
					TextSize = 12,
					TextXAlignment = "Left",
					TextTransparency = 0.10000000149012
				})
			})
			button.MouseButton1Click:Connect(function()
				if callback then callback(value, function(...) self:updateDropdown(dropdown, ...) end) end
				self:updateDropdown(dropdown, value, nil, callback)
			end)
			entries = entries + 1
		end
		
		local frame = dropdown.List.Frame
		utility:Tween(dropdown, {Size = UDim2.new(1, 0, 0, (entries == 0 and 30) or math.clamp(entries, 0, 3) * 34 + 38)}, 0.3)
		utility:Tween(dropdown.Search.Button, {Rotation = list and 180 or 0}, 0.3)
		
		if entries > 3 then
			for i, button in pairs(dropdown.List.Frame:GetChildren()) do
				if button:IsA("ImageButton") then button.Size = UDim2.new(1, -6, 0, 30) end
			end
			frame.CanvasSize = UDim2.new(0, 0, 0, (entries * 34) - 4)
			frame.ScrollBarImageTransparency = 0
		else
			frame.CanvasSize = UDim2.new(0, 0, 0, 0)
			frame.ScrollBarImageTransparency = 1
		end
	end
end

return library
