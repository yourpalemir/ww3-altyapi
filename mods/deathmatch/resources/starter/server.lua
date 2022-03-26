Instance = {
	primary_resources = {'sqlite', 'fonts', 'auth', 'main'},

	start = function(self)
		for index, resource in ipairs(self.primary_resources) do
			getResourceFromName(resource):start()
		end
		--##
		for index, resource in ipairs(getResources()) do
			resource:start()
		end
	end,
}
addEventHandler('onResourceStart',resourceRoot,function() Instance:start() end)