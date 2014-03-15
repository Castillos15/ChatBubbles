class "ChatBubbles"

function ChatBubbles:__init ( )
	-- Settings
	self.canSeeOwn = false -- Defines whether the player can see his/her own messages above his head or not.
	self.maxBubbles = 5 -- Defines how much messages will be drawn at once for each player.
	self.timeout = 5 -- Defines for how long the message will be displayed ( in seconds ).
	self.distance = 30 -- Defines how close you must be to the player to see his chat bubbles.
	self.backgroundColor = Color ( 0, 0, 0, 150 ) -- Defines the rectangle background colour.
	self.textColor = Color ( 255, 255, 255 ) -- Defines the bubble text colour.

	-- Don't touch!
	self.bubbles = { }
	self.fontSize = TextSize.Default
	self.textScale = 1

	Events:Subscribe ( "PlayerChat", self, self.onPlayerChat )
	Events:Subscribe ( "PlayerQuit", self, self.onPlayerQuit )
	Events:Subscribe ( "Render", self, self.onBubblesRender )
end

function ChatBubbles:onPlayerChat ( args )
	if ( args.player == LocalPlayer and not self.canSeeOwn ) then
		return
	end

	self:addBubble ( args.player, args.text )
end

function ChatBubbles:onPlayerQuit ( args )
	self.bubbles [ args.player:GetId ( ) ] = nil
end

function ChatBubbles:onBubblesRender ( )
	local myPos = LocalPlayer:GetPosition ( )
	local angle = Angle ( Camera:GetAngle ( ).yaw, 0, math.pi ) * Angle ( math.pi, 0, 0 )
	for playerID, bubbles in pairs ( self.bubbles ) do
		local player = Player.GetById ( playerID )
		if IsValid ( player ) then
			if ( type ( bubbles ) == "table" ) then
				local position = player:GetPosition ( )
				local headPos = player:GetBonePosition ( "ragdoll_head" )
				local distance = position:Distance2D ( myPos )
				if ( distance <= self.distance ) then
					local height = 0.3
					for index = #bubbles, 1, -1 do
						local data = bubbles [ index ]
						if ( type ( data ) == "table" ) then
							if ( data.timer:GetSeconds ( ) >= self.timeout )then
								self.bubbles [ playerID ] [ index ] = nil
							else
								local headPos = ( headPos + Vector3 ( 0, height, 0 ) )
								local text_size = Render:GetTextSize ( data.msg, self.fontSize, self.textScale )
								local width = Render:GetTextWidth ( data.msg, self.fontSize, self.textScale )
								local position = Render:WorldToScreen ( headPos )
								Render:FillArea ( position - Vector2 ( width / 2, 0 ), Vector2 ( text_size.x + 1, text_size.y ), self.backgroundColor )
								Render:DrawText ( position - Vector2 ( width / 2, 0 ), data.msg, self.textColor, self.fontSize, self.textScale )
								height = ( height + 0.07 )
							end
						end
					end
				end
			end
		end
	end
end

function ChatBubbles:addBubble ( player, msg )
	if ( player and msg ) then
		local id = player:GetId ( )
		if ( not self.bubbles [ id ] ) then
			self.bubbles [ id ] = { }
		else
			if ( #self.bubbles [ id ] >= self.maxBubbles ) then
				self.bubbles [ id ] [ 1 ] = nil
			end
		end

		table.insert (
			self.bubbles [ id ],
			{
				player = player,
				msg = msg,
				timer = Timer ( )
			}
		)

		return true
	else
		return false
	end
end

cB = ChatBubbles ( )

Events:Subscribe ( "ModuleLoad",
	function ( )
		Events:Fire ( "HelpAddItem",
			{
				name = "Chat bubbles",
				text = [[
					Chat Bubbles by Castillo

					Displays the messages sent by the player above of his/her head.
				]]
			}
		)
	end
)

Events:Subscribe ( "ModuleUnload",
	function ( )
		Events:Fire ( "HelpRemoveItem",
			{
				name = "Chat bubbles"
			}
		)
	end
)