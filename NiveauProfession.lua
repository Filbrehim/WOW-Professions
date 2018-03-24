function NP_optimum(expe,prof)
	if expe < 60 then return prof - 5 * expe end
	if expe < 80 then return ceil((prof - 300) - 7.5 * (expe - 60)) end
	if expe < 90 then return (prof - 450) - 15 * (expe - 80 ) end
	return (prof - 600 ) - 10 * ( expe - 90 ) ;
end

function alerte_maxi(profession,niveau) 
	local n15 = niveau+15 ;
	if (ceil(niveau/75) < ceil(n15/75)) and ( niveau < 550 ) then
		print(profession..":|cffff0000"..niveau.." proche du max !")
	end
end

SLASH_NIVEAUPROFESSION1 = "/np" ;
SLASH_RESETOBJECTIFDEMI1 = "/odn" ;
VERSION_NP = "v2.0 fevrier" ;
local frame = CreateFrame("Frame") ;

local monxp,monxpmax ;
local pourcent = 0 ;
local g_niveau = 0 ;
local spam_time_np = 0 ;
local niveau_maxi = {} ;
local np_jours = { CalendarGetWeekdayNames() ;}

function NiveauProfession_OnEvent(self, event, arg1, ...)
 local tmp_a = {} ;
 local parler = nil ;
 local rank,name= 0,nil ;
 
 if (event == "CHAT_MSG_SKILL" ) then 
   
   tmp_a = { strsplit(" ",arg1) };
   --print("le métier: " .. tmp_a[4] .. ", le niveau: " .. tmp_a[8]) ;
   
   name = tmp_a[4] ;
   rank = tonumber(tmp_a[8]) ;
   optimum = NP_optimum(g_niveau,rank) ;
   tmp_time = time () ;
   	if ( niveau_maxi[name] ~= nil ) then
		if ( niveau_maxi[name] - rank < 25 ) and (niveau_maxi[name] < 600 ) then
			print(name..":|cffff0000"..rank.." proche du max ("..niveau_maxi[name]..")!") ;
		end
	else
		alerte_maxi(name,rank) ;
    end
   if ((optimum < 0) and (( tmp_time - spam_time_np ) > 60 )) then
		spam_time_np = tmp_time ;
		print(name..":|cff00ff00"..rank.." |cffffffff[ il manque |cffff0000".. -optimum .." en " ..name.. " |cffffffff pour un niveau " .. g_niveau .. "! ]") ;
	end
 else
    -- print("NP " .. VERSION .. " event " .. event);
	if (event == "PLAYER_ENTERING_WORLD") then
		g_niveau = UnitLevel("player") ;
		spam_time_np = 0 ;
		tmp_time = time () ;
		monxp = UnitXP("player") ;
		
		monxpmax = UnitXPMax("player") ;
		if ( jusqua == nil ) then jusqua = 0 ; end
		if ( reste  == nil ) then jusqua = 0 ; end
		if ( jusqua < tmp_time ) then
			jusqua = tmp_time + 86400 ;
			reste = monxpmax/2 ;
			objectif = monxpmax/2 ;
			tmp_jour = np_jours[1+tonumber(date("%w",jusqua))]
			print(string.format("nouveau délai : %s %s pour %d XP",
			       tmp_jour,date("%Hh %M",jusqua),objectif))
		end 
		pourcent = floor(100-100*reste/objectif)
		
	end

	if (event == "PLAYER_XP_UPDATE" ) then
		if ( UnitXP("player") < monxp ) then
		-- un niveau 
			reste = reste - UnitXP("player")- (monxpmax-monxp)
		else
		-- pas niveau
			reste = reste - (UnitXP("player") - monxp) 
		end
		monxp = UnitXP("player") ;

		tmp_time = time () ;
		if (( tmp_time - spam_time_np ) > 120 ) then
			spam_time_np = tmp_time ;
			NP_print_demi_niveau() ;
		end
	end 
 	if (event == "PLAYER_LEVEL_UP") then
		g_niveau = UnitLevel("player") ;
		spam_time_np = 0 ;
		monxp = UnitXP("player") ;

	end
 end
end

function NP_print_demi_niveau() 
	tmp_pc = floor(100-100*reste/objectif) ;
	--print(string.format("%d = floor(100-100*%d/%d)",tmp_pc,reste,objectif)) 
	
	if ( (tmp_pc > 0) and (tmp_pc < 99) ) then
		tmp_clr = 255 * tmp_pc / 100 ;
		tmp_now = time() 
		temps_restant = "" 
		if ( jusqua > tmp_now ) then
			if ( ( jusqua - tmp_now ) > 7200 ) then 
				temps_restant = string.format("(%d hr)",( jusqua - tmp_now )/3600)
			else 
				temps_restant = string.format("(%d min)",( jusqua - tmp_now )/60)
			end
		end
		tmp_jour = np_jours[1+tonumber(date("%w",jusqua))]
		tmp_now  = np_jours[1+tonumber(date("%w"))]
		if ( tmp_jour == tmp_now ) then tmp_jour = "" ; end 
		print(string.format("il manque |cffff%02x%02x%d xp|r à %s avant %s %s %s",
			tmp_clr,tmp_clr,reste,
			UnitName("Player"),
			tmp_jour,date("%Hh %M",jusqua),temps_restant));
		if ( tmp_pc > pourcent ) then
			pourcent=tmp_pc ;
			print("on a fait "..pourcent.."%") ;
		end

	end
	

end

frame:RegisterEvent("CHAT_MSG_SKILL") ;
frame:RegisterEvent("PLAYER_ENTERING_WORLD") ;
frame:RegisterEvent("PLAYER_LEVEL_UP") ;
frame:RegisterEvent("PLAYER_XP_UPDATE") ;

frame:SetScript("OnEvent", NiveauProfession_OnEvent);

function NP_detail(index,niveau)
	if index ~= nil then
		name, texture, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier, specializationIndex, specializationOffset = GetProfessionInfo(index)
		optimum = NP_optimum(niveau,rank) ;
		if optimum < 0 then
			print(name..":|cffff0000"..rank.." |cffffffff[il manque ".. -optimum .." en " ..name.. "! ]") ;
		else
			if rank == 600 then
				print ("|cff00ff00" .. name .. " ... Zen !") 
			else
				print(name..":|cff00ff00" .. rank .. " Parfait ! (" .. optimum .. ")") 
			end
		end
		if (maxRank - rank < 15) and (maxRank < 600 ) then
			print(name..":|cffff0000"..rank.." proche de "..maxRank.."!")
		end
		niveau_maxi[name]=maxRank ;
	end
end	

function SlashCmdList.RESETOBJECTIFDEMI(msg,editbox) 
	niveau=UnitLevel("player");
	print("Niveau profession : |cffff0000 " .. VERSION_NP)
	print("mon niveau: " .. niveau) ;
	
	monxp = UnitXP("player") ;
	monxpmax = UnitXPMax("player") ;
	tmp_time = time () ;
	
	spam_time_np = tmp_time ;
	NP_print_demi_niveau()
	
	if ( msg == "--reset" ) then
		print("on reset les objectifs") 
		jusqua = tmp_time + 86400 ;
		reste = monxpmax/2 ;
		objectif = monxpmax/2 ;
		pourcent = floor(100-100*reste/objectif) ;
		NP_print_demi_niveau()
	end
end

function SlashCmdList.NIVEAUPROFESSION(msg,editbox)
  
	niveau=UnitLevel("player");
	print("Niveau profession : |cffff0000 " .. VERSION_NP)
	print("mon niveau: " .. niveau) ;

  --professions = GetProfessions()
  
  prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions() ;
  NP_detail(prof1,niveau) ;
  NP_detail(prof2,niveau) ;
  NP_detail(archaeology,niveau) ;
  NP_detail(fishing,niveau) ;
  NP_detail(cooking,niveau) ;
  NP_detail(firstAid,niveau) ;

end