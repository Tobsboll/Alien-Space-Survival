
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
      
      
   begin
      
    
      if not Empty(L) then
	 --Om det är ett skott:
	 if L.Object_Type in ShotGraphics'Range then
	    Goto_XY(L.XY_Pos(1) , L.XY_Pos(2));
	    
	    if L.Object_Type = 4 then --Speciallösning för String
	                              --Eftersom att î råkade vara det ty specialtecken
	       Put("î");
	    else 
	       
	    --Färg på skott kommer att bero på L.Attribute senare
	    Put(ShotGraphics(L.Object_Type));
	    
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
	 end if;
	 Put_Objects(L.Next);
      end if;
      
   end Put_Objects;
   
   
end Graphics;
