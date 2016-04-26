



package body Enemy_Ship_Handling is
   
   --------------------------------------------------
   -- SPAWN SHIP
   --------------------------------------------------
   procedure Spawn_ship(Enemy_Type, X, Y, Difficulty, Num_Lives, Direction, Movement_Type : in Integer;
		        Enemies_List : in out Enemy_List) is
      
      -- Types:
      -- 1) Ordinary ship
      -- 2) Interceptor ship
      -- 3) Destroyer ship
      
      New_Ship : Enemy_List;
      
   begin
      
      New_Ship := new Enemy_Ship_Type;
      New_Ship.Enemy_Type    := Enemy_Type;
      New_Ship.XY(1)         := X;
      New_Ship.XY(2)         := Y;
      New_Ship.Difficulty    := Difficulty;
      New_Ship.Num_Lives     := Num_Lives;
      New_Ship.Direction     := Direction;
      New_Ship.Movement_Type := Movement_Type; 
      New_Ship.Next          := Enemies_List;
      Enemies_List           := New_Ship;
      
   end Spawn_Ship;
   --------------------------------------------------
   --end SPAWN SHIP
   --------------------------------------------------
   
   --------------------------------------------------
   -- NEXT TO WALL
   --------------------------------------------------
   
   function Next_To_Wall(Enemies : in Enemy_List) return Boolean is
      
   begin -- förrvirrad ordning här eftersom listan är sorterad baklänges (sist in - först ut).
      
      
      if Enemies /= null then

	 if Enemies.Direction = 1 then -- höger 
	    
	    if Enemies.XY(1) >= World_X_Length -1 then return True;
	    else return Next_To_Wall(Enemies.Next);
	    end if;
	    
	 elsif Enemies.Direction = -1 then -- vänster 
	    
	    if Enemies.XY(1) <= 2 then return True;
	    else return Next_To_Wall(Enemies.Next); --rekursion
	    end if;
	    
	 end if;
	 
      end if;
      
      return False;
      
   end Next_To_Wall;
      
   --------------------------------------------------
   -- end NEXT TO WALL
   --------------------------------------------------
   
   --------------------------------------------------
   -- MOVE TO SIDE
   --------------------------------------------------
   
   procedure Move_To_Side(Enemies : in out Enemy_List) is
      
   begin
      
      if Enemies /= null then
	 
	 Enemies.XY(1) := Enemies.XY(1) + Enemies.Direction;
	 
	 Move_To_Side(Enemies.Next); 	 
	 
      end if;
      
   end Move_To_Side;
   
   --------------------------------------------------
   -- end MOVE TO SIDE
   --------------------------------------------------
   
   --------------------------------------------------
   -- MOVE ONE DOWN
   --------------------------------------------------
   
   procedure Move_One_Down(Enemies : in out Enemy_List) is
      
   begin
      
      if Enemies /= null then 
	 
	 Enemies.XY(2) := Enemies.XY(2) + 1;
	 
	 Move_One_Down(Enemies.Next); -- rekursion
	 
	 if Enemies.XY(2) >= 60 then -- vågen sätts till att stå stilla i y
	    Enemies.Movement_Type := 2;
	 end if;
     
      end if;
      
   end Move_One_Down;
   
   --------------------------------------------------
   -- end MOVE ONE DOWN
   --------------------------------------------------
   
   --------------------------------------------------
   -- CHANGE DIRECTION
   --------------------------------------------------
   
   procedure Change_Direction(Enemies : in out Enemy_List) is
      
   begin
      
      if Enemies /= null then
	 
	 if Enemies.Direction = 1 then
	    Enemies.Direction := -1;
	 else
	    Enemies.Direction := 1;
	 end if;
	 
	 Change_Direction(Enemies.Next); -- rekursion

      end if;
      
   end Change_Direction;
   
   --------------------------------------------------
   -- end CHANGE DIRECTION
   --------------------------------------------------
   
   --------------------------------------------------
   -- CREATE SHOT
   --------------------------------------------------
   procedure Create_Enemy_Shot(Enemy_Type, X, Y : in Integer;
			       Shot_List : in out Object_List) is
      
      -- beroende på type kan vi skjuta olika sorter så småningom.
      
   begin -- courtesy of Andreas ^^
      
      Create_Object(ShotType(1), X, Y, Down, Shot_List); --nummer?
      
   end Create_Enemy_Shot;
   --------------------------------------------------
   -- end CREATE SHOT
   --------------------------------------------------
   
   --------------------------------------------------
   -- SHOT GENERATOR
   --------------------------------------------------
   
   procedure Shot_Generator(Enemies : in out Enemy_List;
   			    Chance_For_Shot : in out Generator;
			    Shot_List : in out Object_list) is
      
      Alien_Shot_Probability : Integer;
      
   begin
      
      Alien_Shot_Probability := Random(Chance_For_shot); -- 1-20
      
      if Enemies /= null then
	 
   	 if Alien_Shot_Probability <= Enemies.Difficulty then
	    Create_enemy_Shot(Enemies.Enemy_type, Enemies.XY(1), Enemies.XY(2), Shot_List);
	    Put("SKOTTJÄVEL!");
    
   	 end if;
	 
   	 Shot_Generator(Enemies.Next, Chance_For_Shot, Shot_list); -- rekursion
	 
      end if;
      
   end Shot_Generator;
   
   --------------------------------------------------
   -- end SHOT GENERATOR
   --------------------------------------------------
   
   --------------------------------------------------
   -- AT LOWER LIMIT
   --------------------------------------------------
   
   function At_Lower_limit(Enemies : in Enemy_List) return Boolean is
      
   begin
      
      return Enemies.Movement_Type = 2;
      
   end At_Lower_Limit;
   --------------------------------------------------
   -- end AT LOWER LIMIT
   --------------------------------------------------
	
   --------------------------------------------------
   -- LAST_LIST
   --------------------------------------------------
   
   function Last_List(All_Enemies : in Enemy_List_Array) return Integer is
      
      Num_Lists : Integer;
      
   begin
      
      Num_Lists := 0;
      
      for I in All_Enemies'Range loop
	 
	 if All_Enemies(I) /= null then
	    Num_Lists := Num_Lists + 1;
	 end if;

      end loop;
      
      return Num_Lists;	   
      
   end Last_List;
   
   --------------------------------------------------
   -- end LAST LIST
   --------------------------------------------------
   
   --------------------------------------------------
   --UPDATE ENEMY POSITION
   --------------------------------------------------
 
   procedure Update_Enemy_Position(Enemies : in out Enemy_List;
				   Shot_List : in out Object_List) is
      
      -- Movement_selector:
      -- 0) stand still
      -- 1) move zigzag, classic space invaders
      -- 2) move only zigzag, don't go downwards
      -- 3) Interceptor movement
      
      Chance_For_Shot : Generator;
      
   begin 
      
      if Enemies /= null then
      
      -- if Wave.Movement_selector = 0 så står vi still = skippar koden.
      
      ----------------------------------
      -- Classic space invaders movement
      ----------------------------------
      
      if Enemies.Movement_Type = 1 then -- alla till en pekare har samma movement selector.
	 
	 if not Next_To_Wall(Enemies) then
	    Move_To_Side(Enemies); 
	 elsif not At_Lower_Limit(Enemies) then
	    Move_One_Down(Enemies);
	    Change_Direction(Enemies);
	 else
	    Change_Direction(Enemies);
	 end if;
	 
	 Reset(Chance_For_shot);
	 Shot_Generator(Enemies, Chance_For_Shot, Shot_List);
	 
	 ---------------------------------
	 -- Only zig-zag
	 ---------------------------------
	 
      elsif Enemies.Movement_Type = 2 then
	 
	 if not Next_To_Wall(Enemies) then
	    Move_To_Side(Enemies); 
	 else
	    Change_Direction(Enemies);
	 end if;
	 
	 Reset(Chance_For_shot);
	 Shot_Generator(Enemies, Chance_For_Shot, Shot_List);
	 
	 ---------------------------------
	 -- Interceptor movement
	 ---------------------------------
	 
      elsif Enemies.Movement_Type = 3 then
	 null;
      end if;
      
      end if;
      
      
   end Update_Enemy_position;

   
   --------------------------------------------------
   --end UPDATE ENEMY POSITION
   --------------------------------------------------
   
--------------------------------------------------
-- SPAWN WAVE
--------------------------------------------------
procedure Spawn_Wave(Num_To_Spawn  : in Integer;
                     Enemy_Type    : in Integer;
		     Movement_Type : in Integer;
		     Direction     : in Integer;
		     Enemies_List  : in out Enemy_List) is
   
   Num_Ships : Integer;
   Min_X_Interval : constant Integer := 6;
   Y_Interval     : constant Integer := 3;
   X, X_Interval, Y : Integer; 
   Difficulty : Integer;
   Num_Lives  : Integer;
   Counter    : Integer;  
   
begin
   
   Num_Ships := Num_To_Spawn;
   X := 0;
   Y := 0; -- ingen aning.
   
   if Enemy_Type = 1 then
      Difficulty := 10;
      Num_Lives  := 2;
   elsif Enemy_Type = 2 then
     Difficulty := 15;
     Num_Lives := 3;
   elsif Enemy_Type = 3 then
     Difficulty := 3;
     Num_Lives := 5;
   end if;
   
   Counter := 0;
   
--  for I in 1..8 loop 
   while Num_Ships > 8 loop
     
     for I in 1..8 loop
      
      Spawn_Ship(Enemy_Type, X+Min_X_Interval, Y, Difficulty, Num_Lives, Direction, Movement_Type, Enemies_List);
      
      X := X + Min_X_Interval;
      Num_Ships := Num_Ships - 1;
      Counter := Counter + 1;

     end loop;
 
      Y := Y + Y_Interval;
      X := 0;
     
   end loop;

   X_Interval := World_X_Length/(Num_Ships + 1);
   X := 0;
   
   for I in 1..Num_Ships loop
      
      Spawn_Ship(Enemy_Type, X + X_Interval, Y, Difficulty, Num_Lives, Direction, Movement_Type, Enemies_List);
      
   end loop;
   
end Spawn_Wave;
--------------------------------------------------
-- end SPAWN WAVE
--------------------------------------------------


--------------------------------------------------
-- REMOVE SHIP
--------------------------------------------------
procedure Remove_Ship(Enemies : in out Enemy_List) is
   
   Temporary : Enemy_List; 
   
begin
   
   Temporary := Enemies;
   Enemies   := Enemies.Next;
   Free(Temporary);
   
end Remove_Ship;
--------------------------------------------------
-- end REMOVE SHIP
--------------------------------------------------

   --------------------------------------------------
   -- DESTROY SHIP
   --------------------------------------------------
   
   procedure Destroy_Ship(Enemies   : in out Enemy_List;
			  Hit_Coord : in XY_Type) is
      
      
   begin
      
      if Enemies/=null then
	 
	 if Hit_Coord = Enemies.XY then
	    
	    Remove_ship(Enemies);
	    --Enemy_Explosion(Enemies.Enemy_Type, Hit_Coord);
	
	 else
	    
	    Destroy_Ship(Enemies.Next, Hit_Coord);
	    
	 end if;
	 
      end if;
      
      
   end Destroy_Ship;
   
   --------------------------------------------------
   -- end DESTROY SHIP
   --------------------------------------------------
   
   --------------------------------------------------
   -- PUT_ENEMY_SHIPS
   --------------------------------------------------
   
   procedure Put_Enemy_Ships(Enemies : in Enemy_List;
			     Socket  : in Socket_Type) is
      
   begin
      
      -- Skicka över koordinater, liv, typ, mer behövs ej?

      if Enemies /= null then
	 
	 Put_line(Socket, Enemies.Enemy_Type); -- skickar fiendens typ
	 Put_line(Socket, Enemies.XY(1)); --skickar fiendens koordinater.
	 Put_line(Socket, Enemies.XY(2));	 
	 Put_line(Socket, Enemies.Num_Lives); -- skickar över antal liv för ev print eller 
					      -- olika print beroende på skada	 
	 ------------------------------ TEST
	 New_Line;
	 Put("Ship Cordinates: ");
	 Put(Enemies.XY(1), 0);
	 Put(",      ");
	 Put(Enemies.XY(2), 0);
	 ------------------------------
	 
	 Put_Enemy_Ships(Enemies.Next, Socket); --rekursion
	 
      else
	 
	 Put_line(Socket, 0);
	 
      end if;  
      
   end Put_Enemy_Ships;
   
   --------------------------------------------------
   --end PUT_ENEMY_SHIPS
   --------------------------------------------------
   
   --------------------------------------------------
   -- GET_ENEMY_SHIPS
   --------------------------------------------------
   
   procedure Get_Enemy_Ships(Enemies : in out Enemy_List;
			     Socket  : in Socket_Type) is
      
      Input : Integer;
      Enemy_Type : Integer;
      X : Integer;
      Y: Integer;
      Num_Lives : Integer;
      
   begin

      Get(Socket, Input);
      
      if Input /= 0 then -- listan inte null.
	 
	 Enemy_Type := Input;
	 Get(Socket, X);
	 Get(Socket, Y);
	 Get(Socket, Num_Lives);
	 
	 Spawn_Ship(Enemy_Type, X, Y, 10, Num_Lives, 1, 1, Enemies);
	 
	 Get_Enemy_Ships(Enemies.Next, Socket); --rekursion
	 
      end if;
     
   end Get_Enemy_Ships;
   
   --------------------------------------------------
   --end GET_ENEMY_SHIPS 
   --------------------------------------------------
   
   --------------------------------------------------
   -- DELETE_ENEMY_LIST
   --------------------------------------------------
   
   procedure Delete_Enemy_list(Enemies : in out Enemy_List) is
      
   begin
      
      if Enemies /= null then
	 
	 Remove_Ship(Enemies);
	 Delete_Enemy_List(Enemies);
	 
      end if;
      
   end Delete_Enemy_List;
   --------------------------------------------------
   -- end DELETE_ENEMY_LIST
   --------------------------------------------------
   
end Enemy_Ship_Handling;
