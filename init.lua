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
player_radar.status={}
player_radar_hud={}
player_radar_obj={}
player_radar_detected={}
player_radar.hud_status={}

player_radar.ABM=function(self)
  local meta= minetest.env:get_meta(self)
  local signal=""
  local connected= minetest.get_objects_inside_radius(self,self.y/2)
  local table_of_coordinates={}	
    for i,v in ipairs(connected) do	  
      local pos=v:getpos()	  
      local dist=math.sqrt(math.pow((self.x-pos.x),2)+math.pow((self.z-pos.z),2)+math.pow((self.y-pos.y),2))
      if dist<=(self.y/2) then	    
	table_of_coordinates[i]=tostring(5.865+(((self.x-v:getpos().x)*12.32)/self.y))..","..tostring(6.005+(((self.z-v:getpos().z)*12.65)/self.y))    
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
	on_construct=function(pos)
		local meta=minetest.env:get_meta(pos)	
	  if pos.y<1 then
	    minetest.env:remove_node(pos)
	  end
		meta:set_string("infotext","radar rage"..tostring(pos.y/2)) 
	end,
	  
})

minetest.register_tool("player_radar:portable_radar",{
	description="portable radar",
	inventory_image = ("portable_radar.png"),
	tool_capabilities = {
		groupcaps={			
			snappy = {times={[2]=0.95}, uses=20, maxlevel=1},
		}
	},
	on_use=function(itemstack,user,pointed_thing)
		
		local owner = user:get_player_name()
		player_radar[owner].status=1
		local pos=user:getpos()
		local range=25
		player_radar:detect_formspec(data,owner,range,pos)
	end,

})

minetest.register_tool("player_radar:portable_receiver",{
	description="portable radar receiver for the radar block",
	inventory_image = ("portable_receiver.png"),
	tool_capabilities = {
		groupcaps={
			snappy = {times={[2]=0.95}, uses=20, maxlevel=1},			
		}
	},
	on_use=function(itemstack,user,pointed_thing)	
	local metastack=itemstack:to_table().metadata
	local range =nil
	if metastack=="" then
		if pointed_thing.type=="node" then				
			local node=minetest.get_node(pointed_thing.under)
			local name=node.name
			if name=="player_radar:radar" then				
				local pt=pointed_thing.under	
				range=(pt.y)/2
				print(tostring(range))
				local meta=minetest.pos_to_string(pt)
				itemstack:set_metadata(meta)
				return itemstack --NO return, No party
			end
		end
	end
	if itemstack:to_table().metadata~="" then
		local owner=user:get_player_name()
		local pos =minetest.string_to_pos(itemstack:to_table().metadata)
		range=(pos.y)/2
		player_radar:detect_formspec(data,owner,range,pos)
		player_radar[owner].status=1
	end		
end,
})

minetest.register_tool("player_radar:radar_hud",{
	description="radar hud",
	inventory_image = ("radar_hud.png"),
	tool_capabilities = {
		groupcaps={			
			snappy = {times={[2]=0.95}, uses=20, maxlevel=1},
		}
	},
	on_use=function(itemstack,user)		
		local owner=user:get_player_name()
		if player_radar[owner].hud_status~=1 then
			player_radar[owner].hud_status=1
			print(tostring(player_radar[owner].hud_status))
			player_radar[owner].hud_background = user:hud_add({
			hud_elem_type = "image",
			position = {x=0.1,y=0.1},
			scale = {x=0.1, y=0.1},
			text = "radar_background.png",
			number = 1,
			alignment = {x=0,y=0},
			offset = {
				x = 0;
				y = 0;
				},
			})	
			local range=25
			player_radar:detect_hud(data,owner,range)
		--elseif player_radar[owner].hud_status==1 then
		--	local range=25
		--	player_radar:detect_hud(data,owner,range)
			
		else 
			
			for i,v in pairs (player_radar[owner].detected) do
				user:hud_remove(player_radar[owner].detected[i])
			end
			player_radar[owner].detected={}
			player_radar[owner].hud_status=0
			user:hud_remove(player_radar[owner].hud_background)
		end
	end,
	on_place=function(itemstack,placer)
		local owner =placer:get_player_name()
		local range=25
		player_radar:detect_hud(data,owner,range)
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

minetest.register_craft({
	output = 'player_radar:portable_radar',
	recipe = {
		{'', 'default:mese_crystal', ''},
		{'', 'default:mese_crystal', ''},
		{'', 'player_radar:radar', ''},
	}
})

minetest.register_craft({
	output = 'player_radar:portable_receiver',
	recipe = {
		{'', 'default:mese_crystal', ''},
		{'', 'player_radar:radar', ''},
		{'', 'default:mese_crystal', ''},
	}
})

minetest.register_craft({
	output = 'player_radar:radar_hud',
	recipe = {
		{'', 'player_radar:radar', ''},
		{'', 'default:mese_crystal', ''},
		{'', 'default:mese_crystal', ''},
	}
})

minetest.register_on_joinplayer(function(ObjectRef)
	print(dump(ObjectRef:get_player_name()))
	player_radar[ObjectRef:get_player_name()]={}
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	print(dump(fields))
	print(dump(formname))
	if formname=="player_radar" then
		player_radar[player:get_player_name()].status=0
	end
	
end)

player_radar.detect_formspec=function(self,data,owner,range,pos)
	print(tostring("routine_formspec"))
	local table_of_coordinates={}
	local objects= minetest.get_objects_inside_radius(pos,range)
	local reowner=minetest.get_player_by_name(owner)
	for i,v in pairs(objects) do
		local obj_pos=v:getpos()
		table_of_coordinates[i]=tostring(5.865+(((pos.x-obj_pos.x)*12.32)/(range*2)))..","..tostring(6.005+(((pos.z-obj_pos.z)*12.65)/(range*2)))
	end
	local multiple=""
	for ii,vv in ipairs(table_of_coordinates) do
		local point="image["..vv..";0.1,0.1;player_radar_player.png]"
		multiple=multiple..point
	end	
	signal=multiple
	minetest.show_formspec(owner,"player_radar","size[12,12]"..
	"image[-0.30,-0.32;15.5,14.65;radar13cmp2.png]"..
	"button_exit[0,0;1,1;stop;STOP]"..signal)
	player_radar:show_formspec(self,data,owner,range,pos)
end

player_radar.show_formspec=function(self,reself,data,owner,range,pos)
	minetest.after(1,function(param)
		if player_radar[owner].status==1 then
			player_radar.detect_formspec(self,data,owner,range,pos)
		end
	end,{self=self,data=data,owner=owner,range=range,pos=pos})


  
end

player_radar.detect_hud=function(self,data,owner,range)
	print(tostring("routine_hud"))
	if player_radar[owner].hud_status~=1 then
		return
	end
	local table_of_coordinates={}
	local reowner=minetest.get_player_by_name(owner)
	local pos=reowner:getpos()
	local objects= minetest.get_objects_inside_radius(pos,range)
	for i,v in pairs(objects) do
		local obj_pos=v:getpos()
		table_of_coordinates[i]={0+((((pos.x-obj_pos.x)*120)/25)/2),0+((((pos.z-obj_pos.z)*120)/25)/2)}
	end
	local owner_ref=minetest.get_player_by_name(owner)
	player_radar[owner].detected={}
	for i,v in pairs (table_of_coordinates) do
		player_radar[owner].detected[table_of_coordinates[i]] =owner_ref:hud_add({
                hud_elem_type = "image",
                position = {x=0.1,y=0.1},
                scale = {x=2, y=2},
                text = "player_radar_player.png",
                number = 1,
                alignment = {x=0,y=0},
                offset = {
	                x = table_of_coordinates[i][1];
	 		y = table_of_coordinates[i][2];
			},
         })
	end
	local detected = player_radar[owner].detected
	 player_radar:show_hud(self,data,owner,range,player_radar[owner].detected)
	 player_radar[owner].detected={}
end

player_radar.show_hud=function(self,reself,data,owner,range,detected)
	local owner_ref=minetest.get_player_by_name(owner)
	if player_radar[owner].hud_status==1 then
	minetest.after(1,function(param)
		for i,v in pairs(detected) do
			owner_ref:hud_remove(detected[i])
		end
		player_radar[owner].detected={}
		player_radar.detect_hud(self,data,owner,range)
		end,{self=self,data=data,owner=owner,range=range,detected=detected})
	end	
end