--[[

player_radar v0.1

Copyright (c) 2013 pandaro <padarogames@gmail.com>

Source Code:
License: GPLv3
pictures:WTFPl

add-RADAR


]]--

-- expose api
player_radar={}
player_radar.ABM=function(self)
  local meta= minetest.env:get_meta(self)
  local signal=""
  local connected= minetest.get_connected_players()
  local table_of_coordinates={}	
    for i,v in ipairs(connected) do	  
      local pos=v:getpos()	  
      local dist=math.sqrt(math.pow((self.x-pos.x),2)+math.pow((self.z-pos.z),2))
      if dist<=(self.y/2) then	    
	table_of_coordinates[i]=tostring(5.865+(((self.x-v:getpos().x)*12.32)/self.y))..","..tostring(6.005+(((self.z-v:getpos().z)*12.65)/self.y))    
	print("player "..tostring(i)..", position on screen "..tostring(table_of_coordinates[i]).." distanza reale "..tostring(dist).." distanza max "..tostring(self.y/2))
      end
    end
    
    local multiple=""
    for ii,vv in ipairs(table_of_coordinates) do
      local point="image["..vv..";0.1,0.1;player_radar_player.png]"
      multiple=multiple..point	  
    end	
  signal=multiple
  --print(dump(signal))
  meta:set_string("formspec","size[12,12]"..
  "image[-0.30,-0.32;15.5,14.65;radar13cmp2.png]"..
  "label[0,11;radar range= "..tostring(self.y/2).."]"..
  "label[9.5,11;center= "..tostring(self.x)..","..tostring(self.z).."]"..
  signal)	  
end	

minetest.register_node("player_radar:radar", {
	description = "radar ",
	inventory_image = ("radar_block.png"),
	tiles = {"player_radar_side.png","player_radar_side.png","player_radar_side.png","player_radar_side.png","player_radar_side.png","radar_block.png"},
	drawtype="normal",
	is_ground_content = true,
	groups = {cracky=1},
	walkable=true,
	pointable=true,
	diggable=true,
	paramtype2 = "facedir",
-- 	light_source = 1000,
	on_construct=function(pos)
		local meta=minetest.env:get_meta(pos)	
	  if pos.y<1 then
	    minetest.env:remove_node(pos)
	  end
		meta:set_string("infotext","radar rage"..tostring(pos.y/2)) 
	end,
	  
})
	
minetest.register_abm({
  nodenames={"player_radar:radar"},
  interval=1,
  chance=1,
  action=player_radar.ABM,
})
  
minetest.register_craft({
	output = 'player_radar:radar',
	recipe = {
		{'', '', ''},
		{'', 'default:mese_crystal', ''},
		{'default:steelblock', 'default:steelblock', 'default:steelblock'},
	}
})