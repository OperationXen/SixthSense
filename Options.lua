-- getter and setter methods for options table

function SixthSense:GetMessage(info)
	return self.message
end

function SixthSense:SetMessage(info, newVal)
	self.message = newVal
end

-- options table for ace_config
SixthSense_options = { 
    name = "Sixth Sense Target Detection",
    handler = SixthSense,
    type = "group",
    args = {
        msg = {
            type = "input",
            name = "Message",
            desc = "The message to be displayed when you get home.",
            usage = "<Your message>",
			get = "GetMessage",
			set = "SetMessage",
        },
    },
}