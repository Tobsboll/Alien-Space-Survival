



package body Enemy_Ship_Handling is
   
   --------------------------------------------------
   -- SPAWN SHIP
   --------------------------------------------------
   procedure Spawn_ship(Enemy_Type, X, Y, Difficulty, Num_Lives, Direction, Movement_Type : in Integer;
		        Enemies_List : in out Enemy_List) is
      
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
	    
	    return Enemies.XY(1) >= World_X_Length - 1;
	    
	 elsif Enemies.Direction = -1 and then Enemies.Next = null then -- vänster (i samma pekare har alla samma, räcker med att kolla första)
	    
	    return Enemies.XY(1) <= 2;
	    
	 else
	    
	    return Next_To_Wall(Enemies.Next); --rekursion
	    
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
	 
	 if (Enemies.XY(2) + 1) < 60 then -- sätter en nedre gräns
	 
	    Enemies.XY(2) := Enemies.XY(2) + 1;
	 
	    Move_One_Down(Enemies.Next); -- rekursion
	    
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
   -- SHOT GENERATOR
   --------------------------------------------------
   
   --  procedure Shot_Generator(Enemies : in out Enemy_List;
   --  			    Chance_For_Shot : in out Generator) is
      
   --     Alien_Shot_Probability : Integer;
      
   --  begin
      
   --     Alien_Shot_Probability := Random(Chance_For_shot); -- 1-20
      
   --     if Enemies /= null then
	 
   --  	 if Alien_Shot_Probability <= Enemies.Difficulty then
   --  	    -- Create_Shot(Enemy_Ships.XY(1), Enemy_Ships.XY(2));
   --  	    null;
   --  	 end if;
	 
   --  	 Shot_Generator(Enemies.next); -- rekursion
	 
   --     end if;
      
      
   --  end Shot_Generator;
   
   --------------------------------------------------
   -- end SHOT GENERATOR
   --------------------------------------------------
   
   
   --------------------------------------------------
   --UPDATE ENEMY POSITION
   --------------------------------------------------
 
   procedure Update_Enemy_Position(Enemies : in out Enemy_List) is
      
      -- Movement_selector:
      -- 0) stand still
      -- 1) move zigzag, classic space invaders
      
   begin 
      
      -- if Wave.Movement_selector = 0 så står vi still = skippar koden.
      
      ----------------------------------
      -- Classic space invaders movement
      ----------------------------------
      
      if Enemies.Movement_Type = 1 then -- alla till en pekare har samma movement selector.
	    
	    if not Next_To_Wall(Enemies) then
	       Move_To_Side(Enemies);
	    else -- if noone_below
	       Move_One_Down(Enemies);
	       Change_Direction(Enemies);
	       null;
	    end if; 
	 
      end if;
      
      
   end Update_Enemy_position;

   
   --------------------------------------------------
   --end UPDATE ENEMY POSITION
   --------------------------------------------------
   
   --------------------------------------------------
   -- DESTROY SHIP
   --------------------------------------------------
   
   procedure Destroy_Ship(Enemies   : in out Enemy_List;
			  Hit_Coord : in XY_Type) is
      
      
      ------------------------------------------------
      procedure Remove_Ship(Enemies : in out Enemy_List) is
	 
	 Temporary : Enemy_List; 
	 
      begin
	 
	 Temporary := Enemies;
	 Enemies   := Enemies.Next;
	 Free(Temporary);
	 
      end Remove_Ship;
      ------------------------------------------------
      
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
--	 New_Line;
--	 Put("Ship Cordinates: ");
--	 Put(Enemies.XY(1), 0);
--	 Put(",      ");
--	 Put(Enemies.XY(2), 0);
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
   
end Enemy_Ship_Handling;
