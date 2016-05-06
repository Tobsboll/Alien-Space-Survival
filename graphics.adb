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
   begin
      
    
      if not Empty(L) then
	  Old_Text_Colour := Get_Foreground_Colour;
	 
	 --Om det är ett skott:
	 if L.Object_Type in ShotGraphics'Range then
	    if L.Object_Type not in 9..10 then -- Wall Shot
	    Goto_XY(L.XY_Pos(1) , L.XY_Pos(2));
	    
	    if L.Object_Type = 4 then --Speciallösning för String
	                              --Eftersom att î råkade vara det ty specialtecken
	       Put("î");
	    elsif L.Object_Type = 8 then --| Astroider
	                             
	       Put("╱╲"); Goto_XY(L.XY_Pos(1), L.XY_Pos(2)+1);
	       Put("╲╱");
	       
--	       Put("╭╮"); Goto_XY(L.XY_Pos(1), L.XY_Pos(2)+1);
--	       Put("╰╯");
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
	    Put(PowerUp(L.Object_Type));
	    
	    --Om det är en fiende:
	 elsif L.Object_Type in Enemy'Range then
	    
	    --Enemy type 1 only:
	    Goto_XY(L.XY_Pos(1), L.XY_Pos(2));
	    Put( Enemy_1(1) );
	    Goto_XY(L.XY_Pos(1), L.XY_Pos(2)+1);
	    Put( Enemy_1(2) );
	 
	 
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
