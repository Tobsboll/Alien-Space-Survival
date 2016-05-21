package body Game_Engine is

   --------------------------------------------------
   --|  DEFAULT VALUES
   --|  Här 
   --------------------------------------------------
   procedure Set_Default_Values (Num_Players    : in Integer;
				 Game           : in out Game_Data;
				 Loop_Counter   : out Integer;
				 Players_Choice : out Players_Choice_Array;
				 Level          : out Integer;
				 Level_Cleared  : out Boolean;
				 New_Level      : out Boolean
			        ) is
      Xpos : Integer;
      Interval : constant Integer := World_X_Length/(1+Num_Players);
   begin
      --------------------------------------------------
      --| Game settings
      --------------------------------------------------      
      Loop_Counter := 300;
      Players_Choice := ('o', 'o', 'o', 'o');
      Game.Settings.Gameover := 0;
      Game.Settings.Difficulty := 1;
      Level := 0;
      Level_Cleared := False;
      New_Level := True;
      Restore_Maps_Variables;
      
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
	 Game.Players(K).Ship.Health           := 10;
	 Game.Players(K).Ship.Laser_Type       := 1;
	 Game.Players(K).Ship.Missile_Ammo     := 5;
	 Game.Players(K).Ship.Laser_Recharge   := 0;
	 Game.Players(K).Ship.Hitech_Laser     := False;
	 Game.Players(K).Ship.Tri_Laser        := False;
	 Game.Players(K).Ship.Diagonal_Laser   := False;
	 Game.Players(K).Ship.Super_Missile    := False;
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
      Strafe    : Integer;
      Ydiff     : constant Integer := 1;
      Xdiff     : constant Integer := 1;
   begin
      
      if not Empty(L) and then (L.Object_Type in 1..15 or L.Object_Type in 21..30)  then
	 Direction := L.Attribute;
	 Strafe    := L.Direction;
	 L.XY_Pos(2) := L.XY_Pos(2) + Ydiff*Direction;
	 
	 
	 if L.Object_Type = ShotType(Missile_Shot) and L.Direction /= 0 then
	    if L.XY_Pos(2) mod 2 = 0 then
	       Create_Side_Thrust(L, L.XY_Pos(1), L.XY_Pos(2)+1);
	    end if;
	 else
	    L.XY_Pos(1) := L.Xy_Pos(1) + Xdiff*Strafe;
	 end if;
	 
	 if L.XY_Pos(2) <= GameBorder_Y or L.XY_Pos(2) >= World_Y_Length+GameBorder_Y or
	   L.Xy_Pos(1) <= GameBorder_X or L.XY_Pos(1) >= World_X_Length+GameBorder_X then
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
      Recharge   : Integer;
      Special    : Integer;
      
      Hitech_Active : Boolean;
      TriLaser_Active : Boolean;
      DiagLaser_Active : Boolean;
      SuperMissile_Active : Boolean;
   begin
      
      for I in 1..Num_Players loop
	    X          := Data.Players(I).Ship.XY(1);
	    Y          := Data.Players(I).Ship.XY(2);
	    Laser_Type := Data.Players(I).Ship.Laser_Type;
	    Ammo       := Data.Players(I).Ship.Missile_Ammo;
	    Recharge   := Data.Players(I).Ship.Laser_Recharge;
	    
	    Hitech_Active := Data.Players(I).Ship.Hitech_Laser;
	    TriLaser_Active :=  Data.Players(I).Ship.Tri_Laser;
	    DiagLaser_Active :=  Data.Players(I).Ship.Diagonal_Laser;
	    SuperMissile_Active :=  Data.Players(I).Ship.Super_Missile;
	    
	    
	    Get(Sockets(I), Keyboard_Input); -- får alltid något, minst ett 'o'
--	    Skip_Line(Sockets(I)); -- DETTA kan bli problem om server går långsammare än klienterna!! /Andreas
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
		  
		  if Hitech_Active then --hitech laser
		    if  Recharge /= 0 then 
		     
		     Create_Object(ShotType(Hitech_Laser_Shot),
				X+2,
				Y-1,
				Up*100,
				Shot_List,
				   I                           );
		    else 
		       Hitech_Active := False;
		    end if;
		    
		    --Return:
		    Data.Players(I).Ship.Hitech_Laser := Hitech_Active;
		    
		  elsif Recharge = 0 then
		  
		     Create_Object(ShotType(Laser_Type),
				   X+2,
				   Y-1,
				   Up,
				   Shot_List,
				   I                           );
		     --
		     if Laser_Type = ShotType(Nitro_Shot) then
		        Recharge := 6;
		     else
			Recharge := 3;
		  
			--Tri-Laser active?
			if TriLaser_Active then
			   Create_Object(ShotType(Laser_Type),
					 X,
					 Y,
					 Up,
					 Shot_List,
					 I                           );
			   Create_Object(ShotType(Laser_Type),
					 X+4,
					 Y,
					 Up,
					 Shot_List,
					 I                           );
			end if;
		       
			
			--Diagonal_Laser active?
			if DiagLaser_Active then
			   Create_Object(ShotType(Diagonal_Laser),
					 X+1,
					 Y-1,
					 Up,
					 Shot_List,
					 I,
					 Left);
			   Create_Object(ShotType(Diagonal_Laser),
					 X+3,
					 Y-1,
					 Up,
					 Shot_List,
					 I,
					 Right);
			end if;
			
		     end if;
		  end if;
		  
		  --Return:
		  Data.Players(I).Ship.Laser_Recharge := Recharge;
		  
	       elsif Keyboard_input = 'm' and then Ammo > 0 then
		  
		  if SuperMissile_Active then
		     Special := 1;
		  else 
		     Special := 0;
		  end if;
		  
		  Create_Object(ShotType(Missile_Shot), -- 4 = Missile
				X+2,
				Y-1,
				Up,
				Shot_List,
				I,
				Special );
		  Data.Players(I).Ship.Missile_Ammo := Ammo - 1;
		  
		  --Return:
		  SuperMissile_Active := False;
		  Data.Players(I).Ship.Super_Missile := SuperMissile_Active;
		  
	       elsif Keyboard_Input = 'e' then exit; -- betyder "ingen input" för servern.
	       end if;
	       
	       --Kollar om man kan plocka upp power-up nu när spelaren har flyttats:
	       --Player_Collide_In_Object(X,Y, Data.Players(I).Ship, Powerup_List);
	    end if;
      end loop;
      
   end Get_Player_Input;
   --------------------------------------------------
   --| OVERLAPPING X
   --------------------------------------------------
   function Overlapping_X (X1, X2 : in Integer;
			   X1_Width, X2_Width : in Integer;
			   X1_Offset : in Integer := 0) return Boolean is
      
   begin
      for B in 1..X1_Width loop
	 for A in 1..X2_Width loop
	    if X1+X1_Offset + B-1  = X2 + A-1 then
	       return True;
	    end if;
	 end loop;
      end loop;
      
      return False;
      
   end Overlapping_X;
   
   --------------------------------------------------
   --| OVERLAPPING Y
   --------------------------------------------------
   function Overlapping_Y (Y1, Y2 : in Integer;
			   Y1_Length, Y2_Length : in Integer;
			   Y1_Offset : in Integer := 0) return Boolean is
   begin
      return Overlapping_X(Y1, Y2, Y1_Length, Y2_Length, Y1_Offset);
   end Overlapping_Y;
   
   --------------------------------------------------
   --| OVERLAPPING XY
   --------------------------------------------------
   function Overlapping_XY (XY1, XY2 : in XY_Type;
			    X1_Width, Y1_Length, X2_Width, Y2_Length : in Integer;
			    X1_Offset : in Integer := 0; 
			    Y1_Offset : in Integer := 0
			   ) return Boolean is
      X1 : Integer := XY1(1);
      X2 : Integer := XY2(1); 
      Y1 : Integer := XY1(2);
      Y2 : Integer := XY2(2);
   begin
      
      if Overlapping_X(X1, X2, X1_Width, X2_Width, X1_Offset)
	and Overlapping_Y(Y1, Y2, Y1_Length, Y2_Length, Y1_Offset) then
	 return True;
      else
	   return False;
      end if;
      
   end Overlapping_XY;
   
   --------------------------------------------------
   --| SHIP OVERLAPPING
   --------------------------------------------------
   function Ship_Overlapping (X1,Y1, X2,Y2, X2_Width,Y2_Length: in Integer
			   ) return Boolean is
      XY1, XY2 : XY_Type;
      
   begin
      
      XY1(1) := X1;
      XY1(2) := Y1;
      
      XY2(1) := X2;
      XY2(2) := Y2;
      
      if Overlapping_XY(XY1, XY2,
			--Mått på Skeppets topp [x,y]:
			3,1,
			
			--Objektets mått [x,y]:
			X2_Width,Y2_Length,
			
			--Förskjutning[x,y]:
			1,0
		       )
	
	or Overlapping_XY(XY1, XY2,
			--Mått på Skeppets botten [x,y]:
			5,1,
			
			--Objektets mått [x,y]:
			X2_Width,Y2_Length,
			
			--Förskjutning[x,y]:
			0,1
			 )
      then
	 return True;
      else
	 return False;
      end if;
      
   end Ship_Overlapping;
   
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
	 if L.Object_Type in 16..20 then
	    
	    
	    if Ship_Overlapping(X,Y, Object_X,Object_Y,
				
				--Objektets mått [x,y]:
				3,2)  then
	       return True;
	       
	    else
	       return Player_Collide(X,Y,L.Next); --Rekursion för att Player_Collide
						  --används i sin råa form gällande 
						  --hinder i get_player_input
	    end if;
	    --------------------------------------------------
	    --Med PowerUps:
	    --------------------------------------------------
	 elsif L.Object_Type in 21..30 then
	    
	    return  Ship_Overlapping(X,Y, Object_X,Object_Y,
				     
				     --Objektets mått [x,y]:
				     3,1);
	    

	    --  --  return Player_Collide(X,Y,L.Next);
	    
	    --------------------------------------------------
	    --Med Skott:
	 elsif L.Object_Type in 1..7 or L.Object_Type in 9..15 then
	    if L.Object_Type = ShotType(Hitech_Laser_Shot) then
	       
	       --  Overlapping_X (X1, X2 : in Integer;
	       --  		   X1_Width, X2_Width : in Integer;
	       --  		      X1_Offset : in Integer := 0) 
	       
	       return (Overlapping_X(X, Object_X, 
				    3, -- width
				     1)
		       and
			 Y < Object_Y);
	    else
	    
	       return Ship_Overlapping(X,Y, Object_X,Object_Y,
				       
				       --Skottets mått [x,y]:
				       1,1);
	    end if;
	    
	    --return Player_Collide(X,Y,L.Next);
	    
	    --------------------------------------------------
	    --| Med Astroid:
	 elsif L.Object_Type = 8 then 
	    
	    return Ship_Overlapping(X,Y, Object_X,Object_Y,
				     
				     --Astroidens mått [x,y]:
				    2,2);
	    
	    --------------------------------------------------
	    --| Med Fiendeskepp:
	 elsif  L.Object_Type in 31..40 then
	    
	    return Ship_Overlapping(X,Y, Object_X,Object_Y,
				    
				    --Fiendens mått [x,y]:
				    3,2);
	    
	    
	    
	 end if;
	 
      end if;
      
      --Vid listans slut: 
      return False;
      
   end Player_Collide;
   
   

   
    --------------------------------------------------
   --|  PLAYER COLLIDE IN OBJECT
   --|  
   --------------------------------------------------
      procedure Player_Collide_In_Object ( X,Y              : in Integer;
					--Data              : out Integer;
					Player              : in out Player_Type;
					L                   : in out Object_List;
					Player_To_Revive    : out Integer
					) is
      Player_Ship : Ship_Spec := Player.Ship;
   begin
      Player_To_Revive := 0;
      if not Empty(L) then
	 
	 if Player_Collide (X, Y, L) then
	    
	    --------------------------------------------------
	    --Beskjuten?
	    --------------------------------------------------
	    if L.Object_Type in 1..15 then
	       if L.Object_Type = ShotType(Normal_Laser_Shot) then
		  Player_Ship.Health := Player_Ship.Health-1;
		  
	       elsif L.Object_Type = ShotType(Laser_Upgraded_Shot) or
		 L.Object_Type = ShotType(Explosion) Then
		  Player_Ship.Health := Player_Ship.Health-2;
		  
	       elsif L.Object_Type = ShotType(Diagonal_Laser) then
		  Player_Ship.Health := Player_Ship.Health-1;
		    
	       elsif L.Object_Type = ShotType(Hitech_Laser_Shot) then
		  Player_Ship.Health := 0;
		  
	       elsif L.Object_Type = ShotType(Asteroid) then --Astroid
		  Player_Ship.Health := Player_Ship.Health-1;
		  Create_Ricochet(L, L.XY_Pos(1)+1, L.XY_Pos(2)); --Extra ricochet
		  
	       elsif L.Object_Type = ShotType(L_Wall) then
		  Player_Ship.Health := Player_Ship.Health-3;
		  Player_Ship.XY(1) := Player_Ship.XY(1)+1;
		  
	       elsif L.Object_Type = ShotType(R_Wall) then
		  Player_Ship.Health := Player_Ship.Health-3;
		  Player_Ship.XY(1) := Player_Ship.XY(1)-1;
		  
	       elsif L.Object_Type = ShotType(Missile_Shot) then
		  Create_Explosion_Big(L, L.XY_Pos(1), L.XY_Pos(2));
		  Player_Ship.Health := Player_Ship.Health-3;
		  
	       elsif L.Object_Type = ShotType(Nitro_Shot) then
		  Create_Nitro_Explosion(L, L.XY_Pos(1), L.XY_Pos(2));
		  
	       
	       end if;
	       Create_Ricochet(L, L.XY_Pos(1), L.XY_Pos(2));
	       
	       if L.Object_Type /= ShotType(Hitech_Laser_Shot) then
		  Remove(L);
	       end if;
	       
	      
				  
	       --------------------------------------------------
	       --PowerUp?
	       --------------------------------------------------
	    elsif L.Object_Type in 21..30 then
	       
	       if L.Object_Type = PowerUpType(Health) then
		  Player_Ship.Health := Integer'Min(10,Player_Ship.Health +5);
		  
	       elsif L.Object_Type = PowerUpType(Missile_Ammo) then
		  Player_Ship.Missile_Ammo := Player_Ship.Missile_Ammo + 10;
		  
	       elsif L.Object_Type = PowerUpType(Laser_Upgrade) then --laser upgrade
		  Player_Ship.Laser_Type := ShotType(Laser_Upgraded_Shot);
		  
	       elsif L.Object_Type = PowerUpType(Hitech_Laser) then --hitech laser
		  Player_Ship.Hitech_Laser := True;
		  Player_Ship.Laser_Recharge := 120;
		  
	       elsif L.Object_Type = PowerUpType(Tri_Laser) then 
		  Player_Ship.Tri_Laser := True;
		  
	       elsif L.Object_Type = PowerUpType(Diagonal_Laser) then
		  Player_Ship.Diagonal_Laser := True;
		  
	       elsif L.Object_Type = PowerUpType(Nitro_Upgrade) then
		  Player_Ship.Laser_Type := ShotType(Nitro_Shot);
		  
	       elsif L.Object_Type = PowerUpType(Super_Missile) then
		  Player_Ship.Super_Missile := True;
		  
	       elsif L.Object_Type = PowerUpType(Revive_Friend) then
		  Player_To_Revive := L.Attribute;
		  Player.Score := Player.Score + 10;
	      
		  
		  
	       end if;
	       Remove(L);
	       
	       -------------------------------------------------
	       --Fiendeskepp?
	       --------------------------------------------------
	    elsif L.Object_Type in 31..40 then
	       
	       Player_Ship.Health := Player_Ship.Health - 5;
	       Create_Explosion_Medium(L, L.XY_Pos(1), L.XY_Pos(2));
	       Remove(L);
	    end if;
	    
	    Player.Ship := Player_Ship; --return
	    
	    --Remove(L); --ersätter alla remove ovan
	 else
	    Player_Collide_In_Object(X,Y,Player, L.Next, Player_To_Revive);
	 end if;
      end if;
      
      
   end Player_Collide_In_Object;
   
   --------------------------------------------------
   --| SHOT COLLIDE
   --------------------------------------------------
   function Shot_Collide (Shot, obj : in Object_List) return boolean is
      X, Object_X, Object_Y, Y : Integer;
      --Diff : Integer;
   begin
      if (not Empty(Obj) and not Empty(Shot) )and then Shot.Object_Type /= ShotType(Ricochet) then
	 X := Shot.XY_Pos(1);
	 Y := Shot.XY_Pos(2);
	 
	 Object_X := Obj.XY_Pos(1);
	 Object_Y := Obj.XY_Pos(2);
	 
	 --------------------------------------------------
	 --Med hinder och fiendeskepp (Object)
	 --------------------------------------------------
	 if Obj.Object_Type in 16..20 or Obj.Object_Type in 31..40
	   or Obj.Object_Type = ShotType(Asteroid)
	   or Obj.Object_Type = ShotType(L_Wall)
	   or Obj.Object_Type = ShotType(R_Wall)
	 then
	    
	    --------------------------------------------------
	    --| HITECH LASER:
	    if Shot.Object_Type = ShotType(Hitech_Laser_Shot) then
	       if Object_Y > 1 then -- Spawnar annars explosion utanför skärmen = crash
		  return Overlapping_X(X, Object_X, 
				    
				       --skottets bredd:
				       1,
				    
				       --objektets bredd:
				       3);
	       else
		  return False;
	       end if;
	       --------------------------------------------------
	       --| ASTROID:
	    elsif Shot.Object_Type = ShotType(Asteroid) then
	       return Overlapping_XY(Shot.XY_Pos, Obj.XY_Pos,
				     --Skottets mått [x,y]:
				     2,2,
				     
				     --Objektets mått [x,y]:
				     3,2);
	          
	       --------------------------------------------------
	       --| OBSTACLE:
	    elsif Shot.Object_Type = ShotType(Asteroid) then
	       return Overlapping_XY(Shot.XY_Pos, Obj.XY_Pos,
				     --Skottets mått [x,y]:
				     2,3,
				     
				     --Objektets mått [x,y]:
				     1,1);
	       --------------------------------------------------
	       --| VANLIGA SKOTT:
	    else
	       if Obj.Object_Type = ShotType(Asteroid) then
		  return Overlapping_XY(Shot.XY_Pos, Obj.XY_Pos,
					--Skottets mått [x,y]:
					1,1,
					
					--Objektets mått [x,y]:
					2,2);
		  
	       elsif Obj.Object_Type = ShotType(L_Wall)
		 or Obj.Object_Type = ShotType(R_Wall) Then
		  return Overlapping_XY(Shot.XY_Pos, Obj.XY_Pos,
					--Skottets mått [x,y]:
					1,1,
					
					--Objektets mått [x,y]:
					1,1);
	       else
		  return Overlapping_XY(Shot.XY_Pos, Obj.XY_Pos,
					--Skottets mått [x,y]:
					1,1,
					
					--Objektets mått [x,y]:
					3,2);
	       end if;
	       

	    end if;

	    
	 end if;
      end if;
      
      return False;
      
   end Shot_Collide;

   
      --------------------------------------------------
   --| (SINGLE) SHOT COLLIDE IN ANY OBJECT
   --| kommer att användas till skott främst tror jag
   --------------------------------------------------
   procedure A_Shot_Collide_In_Object (Shot, Obj2   : in out Object_List;
				       Game         : in out Game_Data;
				       Powerup_List : in out Object_List) is

      X, Y : Integer;
   begin
      if not Empty(Shot) then
	 X := Shot.XY_Pos(1);
	 Y := Shot.XY_Pos(2);
	 
	 if not Empty(Obj2) then
	    
	    if Shot_Collide(Shot,Obj2) then
	      
	       --Create_Nitro_Explosion(Shot, X, Y);  --[NITRO MODE]
	       
	       --------------------------------------------------
	       --| VAD FÖR NÅGOT TRÄFFADE?
	       if Shot.Object_Type = ShotType(Missile_Shot) then --Om det är en missil
		  if Shot.Direction = 1 then
		     Create_Nuke(Shot, X, Y);                    --Super missile skapar nuke
		  else
		     Create_Explosion_Big(Shot, X, Y);              --vanlig missile Skapar en explosion
		  end if;
		  
	       elsif Shot.Object_Type = ShotType(Nitro_Shot)            --Om det är en nitrobomb
		 or Shot.Object_Type = ShotType(Special_Explosion) then -- Eller om det är en explosion från
									--nuke (för kedjereaktion).
		  Create_Nitro_Explosion(Shot,X ,Y);                    --Skapa en nitroexplosion
		  
		  
	       elsif Shot.Object_Type = ShotType(Hitech_Laser_Shot) then
		  Create_Hitech_Explosion(Shot, Obj2.XY_Pos(1)+1, Obj2.XY_Pos(2)+1 );
	       end if;
	       
	       --------------------------------------------------
	       --| WHAT IS HIT?:
	       
	       if Obj2.Object_Type in 16..18 then --skott träffar hinder
		  Obj2.Attribute := Obj2.Attribute - 1;
		  if Obj2.Attribute <= 0 then
		     Remove(Obj2);
		  end if;
		  
	       elsif Obj2.Object_Type in 31..40 then --skott träffar fiende
		  
		  --------------------------------------------------
		  --| Score
		  if Shot.Player > 0 then
		     Game.Players(Shot.Player).Score := Game.Players(Shot.Player).Score + 1;
		   
		  end if;
		  
		  --------------------------------------------------
		  --| Fiende förlorar liv:
		  if Shot.Object_Type = ShotType(Laser_Upgraded_Shot) then
		     Obj2.Attribute := Obj2.Attribute - 2;
		     
		  elsif Shot.Object_Type = ShotType(Missile_Shot) then
		     Obj2.Attribute := Obj2.Attribute - 3;
		     
		  elsif Shot.Object_Type = ShotType(Nitro_Shot) then
		     Obj2.Attribute := Obj2.Attribute - 5;
		     
		  else
		     Obj2.Attribute := Obj2.Attribute - 1;
		     
		  end if;
		  
		  --Ta bort fiende:
		  if Obj2.Attribute <= 0 or Shot.Object_Type = ShotType(Hitech_Laser_Shot) then
		     Create_Explosion_Medium(Shot, Obj2.XY_Pos(1), Obj2.XY_Pos(2) );
		     Spawn_Powerup(Obj2.XY_Pos(1), Obj2.XY_Pos(2), Powerup_List);
		     Remove(Obj2);
		  end if;
		  
		  --------------------------------------------------
		  --| skott träffar asteroid:
		  --| bara vissa skott förstör en asteroid:
	       elsif Obj2.Object_Type = ShotType(Asteroid) and 
		 ( Shot.Object_Type = ShotType(Missile_Shot)
		     or Shot.Object_Type = ShotType(Nitro_Shot)
		     or Shot.Object_Type = ShotType(Hitech_Laser_Shot)
		     or Shot.Object_Type = ShotType(L_Wall)
		     or Shot.Object_Type = ShotType(R_Wall)
		     or Shot.Object_Type = ShotType(Explosion)   
		 )then
		  --Create_Ricochet(Shot, X+1, Y) --Extra ricochet
		  Remove(Obj2);
	       end if;
	       

	       --------------------------------------------------
	       --| TA BORT SKOTT
	       if Shot.Object_Type = ShotType(Hitech_Laser_Shot) then
		  if not Empty(Obj2) then
		     A_Shot_Collide_In_Object(Shot, Obj2.Next, Game, Powerup_List); --Rekursion så att hitech laser
	       							   --träffar fler fiender med
		  end if;						   --ett skott
	       end if;
	       
	       if --Shot.Object_Type /= ShotType(Explosion) and
		 Shot.Object_Type /= ShotType(Hitech_Laser_Shot) then

		 if Shot.Object_Type not in 16..20 then --obstacles
		  Create_Ricochet(Shot, X, Y);
		 end if;

		 Remove(Shot); --skottet ska alltid dö
	       end if;
	       
	       
	       --Create_Explosion_Small(Shot, X, Y);
	    else
	       A_Shot_Collide_In_Object(Shot, Obj2.Next, Game, Powerup_List);
	    end if;
	    
	 end if;
	 
      end if;
      
   end A_Shot_Collide_In_Object;
   
   
    --------------------------------------------------
   --| (MULTIPLE) SHOTS COLLIDE IN ANY OBJECT
   --| kommer att användas till skott främst tror jag
   --------------------------------------------------
   procedure Shots_Collide_In_Objects (Obj1, Obj2  : in out Object_List;
				      Game         : in out Game_Data;
				      Powerup_List : in out Object_List) is
      
   begin
      if not Empty(Obj1) and not Empty(Obj2) then
	 A_Shot_Collide_In_Object(Obj1, Obj2, Game, Powerup_List);

         if not Empty(Obj1) then
            Shots_Collide_In_Objects(Obj1.Next, Obj2, Game, Powerup_List);
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
	 
	 Create_Object(ObstacleType(1), 2+Xdiff, Ypos, Hard, L);
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
   --Update Player recharge
   --------------------------------------------------
   procedure Update_Player_Recharge (Player : in out Player_Type) is
      Recharge : Integer := Player.Ship.Laser_Recharge;
      
   begin
      --Recharge := Player.Ship.Laser_Recharge;
      
      if Recharge /= 0 then
	 Recharge := Recharge - 1;
	 
	 if Recharge = 0 then
	    Player.Ship.Hitech_Laser := False;
	 end if;
	 
      end if;
      
      --  if Recharge < 0 then  --borde aldrig hända
      --  	 Recharge := 0;
      --  end if;
      
      Player.Ship.Laser_Recharge := Recharge; --out
      
   end Update_Player_Recharge;
   
   --------------------------------------------------
   --Kill_Player
   --------------------------------------------------
   procedure Kill_Player (Player : in out Player_Type;
			  Player_Number : in Integer;
			  Explosion_List : in out Object_List;
			  PowerUp_List   : in out Object_List) is
      
   begin
      if Player.Playing = True then
	 ------------------------------------------------------------
	 --| Set Defaults:
	       Player.Playing               := False;
	       Player.Ship.Laser_Recharge   := 1; --Nu kan man inte skjuta mera
	       Player.Ship.Tri_Laser        := False;
	       Player.Ship.Diagonal_Laser   := False;
	       Player.Ship.Super_Missile    := False;
	       Player.Ship.Missile_Ammo     := 0;
	       Player.Ship.Laser_Type       := 1;
	       
	       ------------------------------------------------------
	       --| Explode
	       Create_Nitro_Explosion(Explosion_List,
	       			      Player.Ship.XY(1)+2,
	       			      Player.Ship.XY(2)+1
	       			     );
	       
	       -----------------------------------------------------
	       --| Drop Revive Item
	       Create_Object(PowerUpType(Revive_Friend),
			     Player.Ship.XY(1)+2,
			     Player.Ship.XY(2)+1,
			     Player_Number,
			     Powerup_List);
      
      end if;
   end Kill_Player;
   
   --------------------------------------------------
   --Revive Player
   --------------------------------------------------
   procedure Revive_Player(PlayerNumber : in Integer;
			   Player       : in out Player_Array) is
      
   begin
      if PlayerNumber /= 0 then
	 
	 Player(PlayerNumber).Ship.Health           := 5;
	 Player(PlayerNumber).Playing               := True;
	 Player(PlayerNumber).Ship.Laser_Recharge   := 0;
	 Put_Line("Friend has been revived!");
      end if;
      
   end Revive_Player;
   
   
   --------------------------------------------------
   --Explosions
   --------------------------------------------------
   procedure Create_Explosion_Big (L : in out Object_List;
				 X, Y : in Integer) is
      
   begin
      --
      --  YYY
      --XXXXXXX
      --  ZZZ
      --
      
      --för alla Y:
	 for B in -1..1 loop
	    Insert_Last  (ShotType(Explosion),
			  X+B,
			  Y-1,
			  Up*100,
			  L,
			  L.Player                      );
	 end loop;
     
      
	 --för alla X:
	 for A in -4..4 loop
	    if A/=0 then
	       Insert_Last  (ShotType(Explosion),
			     X+A,
			     Y,
			     Up*100,
			     L,
			     L.Player                      );
	    end if;
	 end loop;
	 
	 --for alla Z:
	 for C in -1..1 loop
	    Insert_Last  (ShotType(Explosion),
			  X+C,
			  Y+1,
			  Up*100,
			  L,
			  L.Player                      );
	 end loop;
	    
   end Create_Explosion_Big;
   
   procedure Create_Explosion_Medium (L : in out Object_List;
				      X, Y : in Integer) is
      
   begin
      -- spawnas i översta vänstra hörnet
      --
      --  YYY
      --  YYY
      --  
      
      
      
      --för alla Y:
      for A in 0..1 loop
	 for B in 0..2 loop
	    Insert_Last  (ShotType(Explosion),
			  X+B,
			  Y+A,
			  Up*100,
			  L,
			  L.Player                      );
	 end loop;
      end loop;
	    
   end Create_Explosion_Medium;
   

   procedure Create_Explosion_Small ( L : in out Object_List;
				      X , Y : in Integer) is
   begin
      Insert_Last  (ShotType(Explosion),
			  X,
			  Y,
			  Up*100,
			  L,
		    L.Player                      );
   end Create_Explosion_Small;
   
   procedure Create_Ricochet ( L : in out Object_List;
			       X , Y : in Integer) is
   begin
      Insert_Last  (ShotType(Ricochet),
			  X,
			  Y,
			  Up*100,
			  L,
		    L.Player                      );
   end Create_Ricochet;
   
   
   procedure Create_Nitro_Explosion (L : in out Object_List;
				     X, Y : in Integer) is
      Player : Integer;
   begin
      --
      --  \A/
      --  < >
      --  /V\
      --
      if Empty(L) then
	 --Om listan är tom måste player def enskilt.
	 Player := 0;
	 --Direction := 0;
      else
	 Player := L.Player;
      end if;
	 
      --------------------------------------------------
      
      for I in -1..1 loop
	 -- \A/ :
	 Insert_Last  (ShotType(Explosion),
		       X+I,
		       Y-1,
		       Up,
		       L,
		       Player,
		       Right*I);
	 --  < >  :
	 if I /= 0 then
	    Insert_Last  (ShotType(Explosion),
			  X+I,
			  Y,
			  0,
			  L,
			  Player,
			  Right*I);
	 end if;
	 
	 --  /V\  :
         Insert_Last  (ShotType(Explosion),
		       X+I,
		       Y+1,
		       Down,
		       L,
		       Player,
		       Right*I);
	 
      end loop;
      
      --------------------------------------------------
      
      
      
   end Create_Nitro_Explosion;
   
   procedure Create_Hitech_Explosion ( L  : in out Object_List;
   					 X , Y : in Integer) is
      Player : Integer;
   begin
      if Empty(L) then
	 Player := 0;
      else
	 Player := L.Player;
      end if;
      
      for B in -1..1 loop
	 for A in -1..1 loop
	    
	    if A /= 0 and B /= 0 then
	       Insert_Last (ShotType(Explosion),
			    X+A,
			    Y+B,
			    Down*B,
			    L,
			    Player,
			    Right*A);
	    end if;
	 end loop;
      end loop;
      
   end Create_Hitech_Explosion;
   
   procedure Create_Nuke (L : in out Object_List;
			  X, Y : in Integer) is
      Player : Integer;
   begin
      --
      --  \A/
      --  < >
      --  /V\
      --
      if Empty(L) then
	 --Om listan är tom måste player def enskilt.
	 Player := 0;
	 --Direction := 0;
      else
	 Player := L.Player;
      end if;
	 
      --------------------------------------------------
      
      for I in -1..1 loop
	 -- \A/ :
	 Insert_Last  (ShotType(Special_Explosion),
		       X+I,
		       Y-1,
		       Up,
		       L,
		       Player,
		       Right*I);
	 --  < >  :
	 if I /= 0 then
	    Insert_Last  (ShotType(Special_Explosion),
			  X+I,
			  Y,
			  0,
			  L,
			  Player,
			  Right*I);
	 end if;
	 
	 --  /V\  :
         Insert_Last  (ShotType(Special_Explosion),
		       X+I,
		       Y+1,
		       Down,
		       L,
		       Player,
		       Right*I);
	 
      end loop;
      
      --------------------------------------------------
      
      
      
   end Create_Nuke;
   
   procedure Activate_Thrusters (L : in out Object_List;
				 X, Y : in Integer) is
   begin
      Insert_Last  (ShotType(Thrust),
		    X,
		    Y+2,
		    Down,
		    L);
      
      Insert_Last  (ShotType(Thrust),
		    X+4,
		    Y+2,
		    Down,
		    L);
      
   end Activate_Thrusters;
   
   procedure Create_Side_Thrust ( L : in out Object_List;
				  X , Y : in Integer) is
   begin
      for I in -1..1 loop
	 if I /=0 then
	    Insert_Last  (ShotType(Thrust),
			  X+I,
			  Y,
			  0,
			  L,
			  L.Player,
			  Right*I);
	 end if;
      end loop;
   end Create_Side_Thrust;
   
   procedure Spawn_Powerup(X, Y         : in Integer;
			   Powerup_List : in out Object_List) is
      
      Spawn_Chance : Integer;
      Powerup_type : Integer;
      
      
      
   begin
      Reset(Gen);
      Spawn_Chance  := Random(Gen);
      Powerup_Type  := Random(Gen);
      
      if Spawn_Chance in 1..1 and Powerup_Type not in 9..10 -- and Powerup_Type /= 9
      then
	 Create_Object(PowerUpType(Powerup_Type), X, Y, Down, Powerup_List);
      end if;
      
      
   end Spawn_Powerup;
   

end Game_Engine;
