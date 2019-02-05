assert(item_helpers == nil)

item_helpers = {
	item_can_pick = function()
		return true
	end
}

local itemdef = minetest.registered_entities["__builtin:item"]
local old_on_punch = itemdef.on_punch
function itemdef.on_punch(self, player)
	if self.itemstring == "" then
		-- Item already picked or invalid
		return old_on_punch(self, player)
	end
	local item = ItemStack(self.itemstring)

	local def = minetest.registered_items[item:get_name()]
	if (def and def.item_helpers and def.item_helpers.can_pick
	and not def.item_helpers.can_pick(self, player, item))
	or not item_helpers.item_can_pick(self, player, item) then
		-- Picking disallowed, item definition can_pick is tested first
		return
	end
	return old_on_punch(self, player)
end






-- Example usages
minetest.override_item("default:stone", {
	-- The item_helpers wrap is used that the mod which adds can_pick can easily
	-- be found
	item_helpers = {
		can_pick = function(ent, player)
			-- Disallow picking stone items underground
			return player:get_pos().y > 0
		end
	}
})
local old_can_pick = item_helpers.item_can_pick
function item_helpers.item_can_pick(ent, player, item)
	-- Disallow picking an item object if it carries exactly three items
	if item:get_count() == 3 then
		minetest.chat_send_all"Cannot pick item object with three items"
		return false
	end
	return old_can_pick(ent, player, item)
end
