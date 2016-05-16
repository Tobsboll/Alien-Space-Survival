with TJa.Window.Text;         use TJa.Window.Text;

package body Graphics is
   
   --------------------------------------------------
   --| Put Player
   --|
   --| Ritar ut spelare
   --------------------------------------------------
   procedure Put_Player (X,Y : in Integer ) is
   begin
      
      Goto_XY(X, Y);
      Put(Ship_Top);
      Goto_XY(X, Y+1);
      Put(Ship_Bottom);
   end Put_Player;
   
   --------------------------------------------------
   --| Put Objects
   --|
   --| Allmän procedur som ritar ut objekt beroende på vad det är
   --------------------------------------------------
   procedure Put_Objects ( L : in Object_List) is
      
      Old_Text_Colour : Colour_Type;
      Old_Bg_Colour   : Colour_Type;
   begin
      
    
      if not Empty(L) then
	 Old_Text_Colour := Get_Foreground_Colour;
	 Old_Bg_Colour   := Get_Background_Colour;
	 
	 --Om det är ett skott:
	 if L.Object_Type in ShotGraphics'Range then
	    if L.Object_Type not in 9..10 then -- Wall Shot
	       Goto_XY(L.XY_Pos(1) , L.XY_Pos(2));
	       
	       if L.Object_Type = ShotType(Missile_Shot) then --Speciallösning för String
					 --Eftersom att î råkade vara det ty specialtecken
		  Put("î");
	       elsif L.Object_Type = ShotType(Asteroid) then --| Astroider
		  
		    Put("╱╲"); Goto_XY(L.XY_Pos(1), L.XY_Pos(2)+1); 
	            Put("╲╱"); 
	        
		--	       Put("╭╮"); Goto_XY(L.XY_Pos(1), L.XY_Pos(2)+1); 
	 	--	       Put("╰╯"); 

	       elsif L.Object_Type = ShotType(Explosion)
		 or L.Object_Type = ShotType(Ricochet) then -- explosion
		  Set_Background_Colour(Explosion_1);
		  Put(' ');
		  Set_Background_Colour(Old_Bg_Colour);
		  
	       elsif L.Object_Type = ShotType(Hitech_Laser_Shot) then 
		  for K in Gameborder_Y..L.XY_Pos(2) loop
		     Set_Background_Colour(Hitech_Laser_Colour);
		     Put(' ');
		     Goto_XY(L.XY_Pos(1), K);
		  end loop;
		  Set_Background_Colour(Old_Bg_Colour);
		  
	       elsif L.Object_Type = ShotType(Diagonal_Laser) then
		  Set_Foreground_Colour(Player_Laser_1);
		  if L.Direction = Left then
		     Put('\');
		  elsif L.Direction = Right then
		     Put('/');
		  else
		     Put('|');
		  end if;
		  Set_Foreground_Colour(Old_Text_Colour);
		  
	       elsif L.Object_Type = ShotType(Nitro_Shot) then
		  Set_Foreground_Colour(Nitro_Shot_Colour);
		  if L.XY_Pos(2) mod 2 = 0 then
		     Put('/');
		  else
		     Put('\');
		  end if;
		  Set_Foreground_Colour(Old_Text_Colour);
		  
	       else  
		  
		  if L.Attribute = Up then
		     Set_Foreground_Colour(Player_Laser_1);
		  elsif L.Attribute = Down then
		     Set_Foreground_Colour(Enemy_Laser_1);
		  end if;
		  
		  Put(ShotGraphics(L.Object_Type));
		  Set_Foreground_Colour(Old_Text_Colour);
		  
	       end if;
	    end if;
	    --Om det är ett hinder:
	 elsif L.Object_Type in Obstacle'Range then
	    
	    for I in 1..2 loop
	       Goto_XY(L.XY_Pos(1) , L.XY_Pos(2)+I-1);
	       Put(Obstacle(L.Object_Type));
	    end loop;
	    
	    --Om det är en powerup:
	 elsif L.Object_Type in PowerUp'Range then
	    Goto_XY(L.XY_Pos(1)-1 , L.XY_Pos(2));
	    if L.Object_Type = PowerUpType(Health) then
	       Put("(♥)");
	    else
	    Put(PowerUp(L.Object_Type));
	    end if;
	    
	    --Om det är en fiende:
	 elsif L.Object_Type in Enemy'Range then
	    
	     if L.XY_Pos(1) > 0 and L.XY_Pos(2) > 0 then
	    --Enemy type 1 only:
	    Goto_XY(L.XY_Pos(1), L.XY_Pos(2));
	    Put( Enemy_1(1) );
	    Goto_XY(L.XY_Pos(1), L.XY_Pos(2)+1);
	    Put( Enemy_1(2) );
	    end if;
	 
	 end if;
	 Put_Objects(L.Next);
      end if;

      
   end Put_Objects;
   
    --------------------------------------------------
   --| Put Enemies
   --|
   --| Allmän procedur som ritar ut fiender beroende på vilken typ det är 
   --------------------------------------------------
   --  procedure Put_Enemies (L : in Enemy_List) is
      
   --  begin
   --     if not Empty(L) then
   --        if L.XY(1) > 1 then        -- Hindrar koden från att gå utanför vänstra kanten på terminalen
   --  	 Goto_XY(L.XY(1), L.XY(2)); --Här blir det CONSTRAINT_ERROR lite då och då av någon anledning...
   --  	 Put( Enemy_1(1) );
   --  	 Goto_XY(L.XY(1), L.XY(2)+1);
   --  	 Put( Enemy_1(2) );
	 
   --  	 Put_Enemies(L.Next);
   --  	 end if;
   --     end if;
      
   --  end Put_Enemies;
   
   
end Graphics;
