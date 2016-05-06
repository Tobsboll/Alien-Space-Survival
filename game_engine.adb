package body Game_Engine is

   --------------------------------------------------
   --|  DEFAULT VALUES
   --|  Här 
   --------------------------------------------------
   procedure Set_Default_Values (Num_Players : in Integer;
				 Game        : in out Game_Data
			        ) is
      Xpos : Integer;
      Interval : constant Integer := World_X_Length/(1+Num_Players);
   begin
      --------------------------------------------------
      --| Ships
      --------------------------------------------------
      Xpos := 0;
      
      for K in 1..Num_Players loop
	 --Spawning
	 Game.Players(K).Ship.XY(2) := World_Y_Length + GameBorder_Y - 2;
	 Game.Players(K).Ship.XY(1) := Xpos + Interval + GameBorder_X;
	 Game.Players(K).Playing := True; 
	 Game.Players(K).Score := 0;
	 Xpos := Xpos + Interval;
	 
	 --Equipment
	 Game.Players(K).Ship.Health := 10;
	 Game.Players(K).Ship.Laser_Type := 1;
	 Game.Players(K).Ship.Missile_Ammo := 5;
      end loop;
      
 
      for M in Num_Players+1..4 loop
	 Game.Players(M).Ship.Health := 0;
      end loop;
      

      --Banan
      Generate_World(Game.Map);  -- Genererar en helt ny bana med raka väggar. / Eric
      Game.Settings.Generate_Map := True; -- Sätter i början att banan inte ska genereras.   
      
      --------------------------------------------------
      
      
      
   end Set_Default_Values;
   
      --------------------------------------------------
   --|  SHOT MOVEMENT
   --|  uppdaterar skottens position i rätt riktning
   --------------------------------------------------
   procedure Shot_Movement ( L : in out Object_List ) is
      Direction : Integer; -- := L.Attribute;
      Ydiff     : constant Integer := 1;
   begin
      
      if not Empty(L) then
	 Direction := L.Attribute;
	 L.XY_Pos(2) := L.XY_Pos(2) + Ydiff*Direction;
	 if L.XY_Pos(2) <= GameBorder_Y or L.XY_Pos(2) >= World_Y_Length+GameBorder_Y then
	    Remove(L);
	    Shot_Movement(L);
	 else
	    Shot_Movement(L.Next);
	 end if;
      end if;
      
   end Shot_Movement; 
   
 
   --------------------------------------------------
   --| GET PLAYER INPUT                              |--===========|===|
   --------------------------------------------------
   procedure Get_Player_Input(Sockets : in Socket_Array;
			      Num_Players : in Integer;
			      Data : in out Game_Data;
			      Shot_List : in out Object_List;
			      Obstacle_List : in Object_List;
			      Powerup_List  : in out Object_List
			     ) is
      
      Keyboard_Input  : Character;
      
      X          : Integer;
      Y          : Integer;
      Laser_Type : Integer;
      Ammo       : Integer;
   begin
      
      for I in 1..Num_Players loop
	    X          := Data.Players(I).Ship.XY(1);
	    Y          := Data.Players(I).Ship.XY(2);
	    Laser_Type := Data.Players(I).Ship.Laser_Type;
	    Ammo       := Data.Players(I).Ship.Missile_Ammo;
	    
	    
	    Get(Sockets(I), Keyboard_Input); -- får alltid något, minst ett 'o'
	    Skip_Line(Sockets(I)); -- DETTA kan bli problem om server går långsammare än klienterna!! /Andreas
				   --------------------------------------------------
				   --| Movement tjafs 
				   --|
				   --| #Bruteforce
				   --------------------------------------------------
	    
	    if Keyboard_Input /= 'o' then -- = om det fanns nollskild, giltig input.        
	       
	       
	       if Keyboard_Input = 'w' and then not Player_Collide(X,Y-1, Obstacle_List) then 
		  Data.Players(I).Ship.XY(2) := Integer'Max(GameBorder_Y + 1 , Y-1);
		  
	       elsif Keyboard_Input = 's' and then not Player_Collide(X,Y+1, Obstacle_List) then 
		  Data.Players(I).Ship.XY(2) := Integer'Min(World_Y_Length+GameBorder_Y-2 , Y+1);
		  
	       elsif Keyboard_Input = 'a' and then not Player_Collide(X-Move_Horisontal,Y, Obstacle_List) then
		  Data.Players(I).Ship.XY(1) := Integer'Max(GameBorder_X+Border_Left(Data.Map, Data.Players(I).Ship.XY(2)-GameBorder_Y)-1 , X - Move_Horisontal);
		  
	       elsif Keyboard_Input = 'd' and then not Player_Collide(X+Move_Horisontal, Y , Obstacle_List) then
		  Data.Players(I).Ship.XY(1) := Integer'Min(GameBorder_X+Border_Right(Data.Map, Data.Players(I).Ship.XY(2)-GameBorder_Y) - Player_Width ,X + Move_Horisontal);
	       elsif Keyboard_input = ' ' then 
		  --Data.Players(I).Playing := False;  --Suicide
		  
		  Create_Object(ShotType(Laser_Type),
				X+2,
				Y,
				Up,
				Shot_List,
				I                           );
	       elsif Keyboard_input = 'm' and then Ammo > 0 then
		  
		  Create_Object(ShotType(4), -- 4 = Missile
				X+2,
				Y,
				Up,
				Shot_List,
				I                           );
		  Data.Players(I).Ship.Missile_Ammo := Ammo - 1;
		  
	       elsif Keyboard_Input = 'e' then exit; -- betyder "ingen input" för servern.
	       end if;
	       
	       --Kollar om man kan plocka upp power-up nu när spelaren har flyttats:
	       Player_Collide_In_Object(X,Y, Data.Players(I).Ship, Powerup_List);
	    end if;
      end loop;
      
   end Get_Player_Input;
   
     --------------------------------------------------
   --| PLAYER COLLIDE
   --------------------------------------------------
   function Player_Collide (X,Y : in Integer;
			    L   : in Object_List
			   ) return Boolean is
      Object_X : Integer; 
      Object_Y : Integer;
   begin
      if not Empty(L) then
	 Object_X := L.XY_Pos(1);
	 Object_Y := L.XY_Pos(2);
	 --------------------------------------------------
	 --Med hinder:
	 --------------------------------------------------
	 if L.Object_Type in 11..20 then
	    
	    --Jämför Hindrets koord. med hela ship top:
	    --------------------------------------------------
	    for A in 1..2 loop      --Obstacle height
	       for I in 1..3 loop      --Ship top
		  for K in 1..3 loop   --Obstacle width
		     
		     if X+I = Object_X+K-1 and Y = Object_Y+A-1 then
			return True;
		     end if;
		  end loop;
	       end loop;
	    end loop;
	    
	    --Jämför Hindrets koord. med hela ship bottom:
	    --------------------------------------------------
	    for A in 1..2 loop      --Obstacle height
	       for I in 1..5 loop      --Ship bottom
		  for K in 1..3 loop   --Obstacle width
		     
		     if X+I-1 = Object_X+K-1 and Y+1 = Object_Y+A-1 then
			return True;
		     end if;
		  end loop;
	       end loop;
	    end loop;
	    
	    
	    return Player_Collide(X,Y,L.Next);
	    --------------------------------------------------
	    --Med PowerUps:
	    --------------------------------------------------
	 elsif L.Object_Type in 21..30 then
	    
	    for I in 1..3 loop      --Ship top
	       for K in 1..3 loop   --Object width
		  
		  if X+I = Object_X+K-2 and Y = Object_Y then
		     return True;
		  end if;
	       end loop;
	    end loop;
	    
	    for I in 1..5 loop      --Ship bottom
	       for K in 1..3 loop   --Object width
		  
		  if X+I-1 = Object_X+K-2 and Y+1 = Object_Y then
		     return True;
		  end if;
	       end loop;
	    end loop;
	    
	    --return Player_Collide(X,Y,L.Next);
	    
	    --------------------------------------------------
	    --Med Skott:
	    --------------------------------------------------
	 elsif L.Object_Type in 1..7 or L.Object_Type in 9..10 then
	    for I in 1..3 loop      --Ship top
	       
	       if X+I = Object_X and Y = Object_Y then
		  return True;
	       end if;
	    end loop;
	    
	    
	    for I in 1..5 loop      --Ship bottom
	       
	       
	       if X+I-1 = Object_X and Y+1 = Object_Y then
		  return True;
	       end if;
	       
	    end loop;
	    --return Player_Collide(X,Y,L.Next);
	 elsif L.Object_Type = 8 then  --Astroid
	    for I in 1..3 loop      --Ship top
	       
	       if (X+I-1 = Object_X and Y+1 = Object_Y+1) or
		 (X+I-1 = Object_X+1 and Y+1 = Object_Y+1) then
		  return True;
	       end if;
	    end loop;
	    
	    
	    for I in 1..5 loop      --Ship bottom
	       
	       
	       if (X+I-1 = Object_X and Y+1 = Object_Y+1) or
		 (X+I-1 = Object_X+1 and Y+1 = Object_Y+1) then
		  return True;
	       end if;
	       
	    end loop;
	    
	    --------------------------------------------------
	    --Med Fiendeskepp:
	    --------------------------------------------------
	 elsif  L.Object_Type in 31..40 then
	    
	    --Jämför Hindrets koord. med hela ship top:
	    --------------------------------------------------
	    for A in 1..2 loop      --Obstacle height
	       for I in 1..3 loop      --Ship top
		  for K in 1..3 loop   --Obstacle width
		     
		     if X+I = Object_X+K-1 and Y = Object_Y+A-1 then
			return True;
		     end if;
		  end loop;
	       end loop;
	    end loop;
	    
	    --Jämför Hindrets koord. med hela ship bottom:
	    --------------------------------------------------
	    for A in 1..2 loop      --Obstacle height
	       for I in 1..5 loop      --Ship bottom
		  for K in 1..3 loop   --Obstacle width
		     
		     if X+I-1 = Object_X+K-1 and Y+1 = Object_Y+A-1 then
			return True;
		     end if;
		  end loop;
	       end loop;
	    end loop;
	    
	    
	 end if;
	 
      end if;
      
      --Vid listans slut: 
      return False;
      
   end Player_Collide;
   
   

   
    --------------------------------------------------
   --|  PLAYER COLLIDE IN OBJECT
   --|  
   --------------------------------------------------
      procedure Player_Collide_In_Object ( X,Y         : in Integer;
					--Data        : out Integer;
					Player_Ship : in out Ship_Spec;
					L           : in out Object_List) is
      
   begin
      if not Empty(L) then
	 
	 if Player_Collide (X, Y, L) then
	    
	    --------------------------------------------------
	    --Beskjuten?
	    --------------------------------------------------
	    if L.Object_Type in 1..10 then
	       if L.Object_Type = ShotType(1) then
		  Player_Ship.Health := Player_Ship.Health-1;
		  
	       elsif L.Object_Type = ShotType(2) then
		  Player_Ship.Health := Player_Ship.Health-1;
	       elsif L.Object_Type = ShotType(8) then --Astroid
		  Player_Ship.Health := Player_Ship.Health-1;
		  
	       elsif L.Object_Type = ShotType(9) then
		  Player_Ship.Health := Player_Ship.Health-3;
		  Player_Ship.XY(1) := Player_Ship.XY(1)+1;
	       elsif L.Object_Type = ShotType(10) then
		  Player_Ship.Health := Player_Ship.Health-3;
		  Player_Ship.XY(1) := Player_Ship.XY(1)-1;
		  
	       end if;
	       Remove(L);
	       
	       --------------------------------------------------
	       --PowerUp?
	       --------------------------------------------------
	    elsif L.Object_Type in 21..30 then
	       
	       if L.Object_Type = PowerUpType(1) then
		  null; --Öka Ship.Health
	       elsif L.Object_Type = PowerUpType(2) then
		  
		  Player_Ship.Missile_Ammo := Player_Ship.Missile_Ammo + 10;
		  
	       elsif L.Object_Type = PowerUpType(3) then
		  Player_Ship.Laser_Type := ShotType(2);
		  
		  
	       end if;
	       Remove(L);
	       
	       -------------------------------------------------
	       --Fiendeskepp?
	       --------------------------------------------------
	    elsif L.Object_Type in 31..40 then
	       
	       Player_Ship.Health := Player_Ship.Health - 5;
	       Remove(L);
	    end if;
	    
	    --Remove(L); --ersätter alla remove ovan
	 else
	    Player_Collide_In_Object(X,Y,Player_Ship, L.Next);
	 end if;
      end if;
      
      
   end Player_Collide_In_Object;
   
   --------------------------------------------------
   --| SHOT COLLIDE
   --------------------------------------------------
   function Shot_Collide (Shot, obj : in Object_List) return boolean is
      X, Object_X, Object_Y, Y : Integer;
      Diff : Integer;
   begin
       if not Empty(Obj) and not Empty(Shot) then
	 X := Shot.XY_Pos(1);
	 Y := Shot.XY_Pos(2);
	 
	 Object_X := Obj.XY_Pos(1);
	 Object_Y := Obj.XY_Pos(2);
	 
	 --------------------------------------------------
	 --Med hinder:
	 --------------------------------------------------
	 if Obj.Object_Type in 11..20 or Obj.Object_Type in 31..40 then
	    
	    --Jämför Hindrets koord.
	    --------------------------------------------------
	    Diff := 0;
	   for A in 1..2 loop
		  for K in 1..3 loop   --Obstacle width
		     
		     if X = Object_X+K-1 and Y = Object_Y+Diff then
			--Remove(Obj);
			--Remove(Shot);
			return True;
			--Shot_Collide(Shot, Obj);
		     end if;
		     
		     
		  end loop;
		  Diff := Diff +1;
	   end loop;
	   --Shot_Collide(Shot, Obj.Next);
	 elsif Obj.Object_Type = 8 then
	      --Jämför Hindrets koord.
	    --------------------------------------------------
	    Diff := 0;
	    for A in 1..2 loop
	       for K in 1..2 loop   --Obstacle width
		  
		  if X = Object_X+K-1 and Y = Object_Y+Diff then
		     return True;	
		  end if;
		  
	       end loop;
	       Diff := Diff +1;
	    end loop;
	    
	 end if;
	 
       end if;
       return False;
       
   end Shot_Collide;

   
      --------------------------------------------------
   --| (SINGLE) SHOT COLLIDE IN ANY OBJECT
   --| kommer att användas till skott främst tror jag
   --------------------------------------------------
   procedure A_Shot_Collide_In_Object (Shot, Obj2 : in out Object_List;
				      Game        : in out Game_Data) is


   begin
      if not Empty(Shot) then
	 if not Empty(Obj2) then
	    
	    if Shot_Collide(Shot,Obj2) then
	       
	       --Avgörandet:
	       if Obj2.Object_Type in 11..20 then --skott träffar hinder
		  Remove(Obj2);
	       elsif Obj2.Object_Type in 31..40 then --skott träffar fiende
		  
		  if Shot.Player > 0 then
		     Game.Players(Shot.Player).Score := Game.Players(Shot.Player).Score + 1;
		  end if;
		  
		  Remove(Obj2);
		  --alternativt fiende förlorar liv
	       elsif Obj2.Object_Type = 8 and Shot.Object_Type = 4 Then
		  Remove(Obj2);
	       end if;
	       
	       Remove(Shot); --skottet ska alltid dö
	    else
	       A_Shot_Collide_In_Object(Shot, Obj2.Next, Game);
	    end if;
	    
	 end if;
	 
      end if;
      
   end A_Shot_Collide_In_Object;
   
   
    --------------------------------------------------
   --| (MULTIPLE) SHOTS COLLIDE IN ANY OBJECT
   --| kommer att användas till skott främst tror jag
   --------------------------------------------------
   procedure Shots_Collide_In_Objects (Obj1, Obj2 : in out Object_List;
				      Game        : in out Game_Data) is
      
   begin
      if not Empty(Obj1) and not Empty(Obj2) then
	 A_Shot_Collide_In_Object(Obj1, Obj2, Game);

         if not Empty(Obj1) then
            Shots_Collide_In_Objects(Obj1.Next, Obj2, Game);
         end if;
      end if;
      
      
      
   end Shots_Collide_In_Objects;
   
   
   --------------------------------------------------
   --| PLAYERS ARE ALIVE
   --| BETA~
   --------------------------------------------------
   function Players_Are_Dead ( Player : in Player_Array) return Boolean is
      
   begin
      if not Player(1).Playing and
	not Player(2).Playing and
	not Player(3).Playing and
	not Player(4).Playing
      then
	 return True;
      else
	 return False;
      end if;
   end Players_Are_Dead;
   
   --
   
   procedure Create_Wall ( L : in out Object_List;
			     Ypos : in Integer) is
      Xdiff : Integer;
      Wall_Width : constant Integer := 3;
   begin
      Xdiff := 0;
      while Xdiff < World_X_Length-Wall_Width loop
	 
	 Create_Object(ObstacleType(1), 2+Xdiff, Ypos, Light, L);
	 Xdiff := Xdiff + Wall_Width;
      end loop;
   end Create_Wall;
   
   --------------------------------------------------
   -- SET WAITING TIME
   --------------------------------------------------
   function Set_Waiting_Time(Loop_Counter, Rounds_To_Wait : in Integer) return Integer is
      
      -- funktion som bestämmer vid vilken looprunda 
      -- proceduren wait() ska bli klar
      
      When_Done : Integer;
      
   begin
      
      When_Done := Loop_Counter + Rounds_To_Wait;
      
      return When_Done;
      
   end Set_Waiting_Time;
   --------------------------------------------------
   -- end SET WATING TIME
   --------------------------------------------------
   
   --------------------------------------------------
   -- WAITING
   --------------------------------------------------
   function Waiting(Loop_Counter, When_Done : in Integer) return Boolean is
      
      -- Funktion Som returnerar sant om loop_counter
      -- är lika med det tal vi satte att vi skulle vänta till
      -- i set_waiting_time, och falskt annars.
      
   begin
      
      return Loop_Counter /= When_Done;
      
   end Waiting;
   --------------------------------------------------
   -- end WAITING
   --------------------------------------------------
   

end Game_Engine;
