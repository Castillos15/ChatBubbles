class "ChatBubbles"

function ChatBubbles:__init ( )
	Events:Subscribe ( "PlayerChat", self, self.onPlayerChat )
end

function ChatBubbles:onPlayerChat ( args )
	Network:Broadcast ( "chatBubbles.receiveMessage", args )
end

cB = ChatBubbles ( )
