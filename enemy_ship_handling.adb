



package body Enemy_Ship_Handling is
   
   --------------------------------------------------
   -- INSERT SHIP FIRST
   --------------------------------------------------
   procedure Insert_Ship_first(Ship : in out Enemy_Ship_Type;
			       Enemies : in out Enemy_List) is
      
      --en vanlig insert first
      
      New_Ship : Enemy_List;
      
   begin
      
      New_Ship := new Enemy_Ship_Type;
      New_Ship.Enemy_Type := Ship.Enemy_Type;
      New_Ship.XY := Ship.XY;
      New_Ship.Difficulty := Ship.Difficulty;
      New_Ship.Num_Lives := Ship.Num_Lives;
      New_Ship.Direction := Ship.Direction;
      New_Ship.Movement_Type := Ship.Movement_Type;
      
      
      New_Ship.Next      := Enemies;
      Enemies            := New_Ship;
      
   end Insert_Ship_first;
   --------------------------------------------------
   --end INSERT SHIP FIRST
   --------------------------------------------------
   
   --------------------------------------------------
   -- INSERT SHIP ORDERED
   --------------------------------------------------
   procedure Insert_Ship_ordered(Ship    : in out Enemy_Ship_Type;
			         Enemies : in out Enemy_list) is
      
   
      --en vanlig insert sorted, högre koordinater hamnar längst ner i listan.
   begin
      
      
      if Enemies /= null then -- listan inte tom
	 
	 if Enemies.XY(2) >= Ship.XY(2) and Enemies.XY(1) >= Ship.XY(1) then
	    
	    --sätt in element om koordinaterna framför är större eller lika.
	    
	    Insert_Ship_First(Ship, Enemies);
	    
	 else Insert_Ship_Ordered(Ship, Enemies.Next); -- rekursion
	 
	 end if;

	 
      else -- listan är tom
	 
	 Insert_Ship_First(Ship, Enemies);
	 
      end if;
      
   end Insert_Ship_ordered;
   --------------------------------------------------
   -- end INSERT SHIP ORDERED
   --------------------------------------------------
   
   --------------------------------------------------
   -- SPAWN SHIP
   --------------------------------------------------
   procedure Spawn_Ship(Enemy_Type, X, Y, Difficulty, Num_Lives, Direction, Movement_Type : in Integer;
		       Enemies_List : in out Enemy_list) is
            
      -- Types:
      -- 1) Ordinary ship
      -- 2) Interceptor ship
      -- 3) Destroyer ship
      
      New_Ship : Enemy_Ship_type;
      
   begin
      
    --  New_Ship := new Enemy_Ship_Type;
      New_Ship.Enemy_Type    := Enemy_Type;
      New_Ship.XY(1)         := X;
      New_Ship.XY(2)         := Y;
      New_Ship.Difficulty    := Difficulty;
      New_Ship.Num_Lives     := Num_Lives;
      New_Ship.Direction     := Direction;
      New_Ship.Movement_Type := Movement_Type; 
      
      Insert_Ship_Ordered(New_Ship, Enemies_List);

      
      
   end Spawn_Ship;
   --------------------------------------------------
   -- end SPAWN SHIP
   --------------------------------------------------
   
   
   --------------------------------------------------
   -- NEXT TO WALL
   --------------------------------------------------
   
   function Next_To_Wall(Enemies : in Enemy_List) return Boolean is
      
   begin -- förrvirrad ordning här eftersom listan är sorterad baklänges (sist in - först ut).
      
      
      if Enemies /= null then

	 if Enemies.Direction = 1 then -- höger 
	    
	    if Enemies.XY(1) >= World_X_Length + GameBorder_X -1 - 3 then return True;
	    else return Next_To_Wall(Enemies.Next);
	    end if;
	    
	 elsif Enemies.Direction = -1 then -- vänster 
	    
	    if Enemies.XY(1) <= GameBorder_X + 1 then return True;
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
   -- CHANGE MOVEMENT TYPE
   --------------------------------------------------
   
   procedure Change_Movement_Type(Enemies  : in out Enemy_List;
				  New_Type : in Integer) is
      
   begin
      
      if Enemies /= null then
	 
	 Enemies.Movement_Type := 2;
	 Change_Movement_Type(Enemies.Next, New_type);
	 
      end if;
      
   end Change_Movement_Type;
   
   --------------------------------------------------
   -- end CHANGE MOVEMENT TYPE
   --------------------------------------------------
   
   
   --------------------------------------------------
   -- MOVE ONE DOWN
   --------------------------------------------------
   
   procedure Move_One_Down(Enemies : in out Enemy_List;
			   Obstacle_Y: in Integer) is
      
   begin
      
      if Enemies /= null then 
	 
	 Enemies.XY(2) := Enemies.XY(2) + 1;
	 
	 Move_One_Down(Enemies.Next, Obstacle_Y); -- rekursion
	 
	 if Enemies.XY(2) >= (Obstacle_Y - 2) then -- vågen sätts till att stå stilla i y
						   -- Enemies.Movement_Type := 2;
	    Change_Movement_Type(Enemies, 2);
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
      
      Create_Object(ShotType(1), X+1, Y+1, Down, Shot_List); --nummer?
      
   end Create_Enemy_Shot;
   --------------------------------------------------
   -- end CREATE SHOT
   --------------------------------------------------
   
   --------------------------------------------------
   -- SHOT GENERATOR
   --------------------------------------------------
   
   procedure Shot_Generator(Enemies : in out Enemy_List;
			    Waves   : in out Enemy_List_Array;
   			    Chance_For_Shot : in out Generator;
			    Shot_List : in out Object_list) is
      
      Alien_Shot_Probability : Integer;
      
   begin
      
      Alien_Shot_Probability := Random(Chance_For_shot); -- 1-100
						        
      --  New_Line;
      --  Put("Shot prob:  ");
      --  Put(Alien_Shot_Probability);
      --  New_Line;
      
      if Enemies /= null then
	 
   	 if Alien_Shot_Probability <= Enemies.Difficulty then
	    
	    if Enemies.Enemy_Type = EnemyType(4) then
	       
	       for I in (-1)..1 loop
	       Create_enemy_Shot(Enemies.Enemy_type, Enemies.XY(1)+(2*I), Enemies.XY(2), Shot_List);
	       end loop;
	       
	    else
	       
	    
	    if Ok_To_Shoot(Enemies.XY(1), Enemies.XY(2), 3, Waves) then
	    Create_enemy_Shot(Enemies.Enemy_type, Enemies.XY(1), Enemies.XY(2), Shot_List);
	    end if;
	    end if;
	    
   	 end if;
	 
   	 Shot_Generator(Enemies.Next, Waves, Chance_For_Shot, Shot_list); -- rekursion
	 
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
   -- GET_CLOSEST_PLAYER
   --------------------------------------------------
   function Get_Closest_Player(Enemy_X : in Integer;
			       Players : in Player_Array) return Integer is
      -- funktion som räknar ut vilken spelare som är närmast.
      Distance : Integer;
      Next_Distance : Integer;
      Player_Num : Integer;
      
   begin
      
      Player_Num := 1; 
      -- vi antar tills vidare att spelare 1 är närmast
      Distance := abs(Players(1).Ship.XY(1) - Enemy_X);
      -- räknar ut hur långt bort första spelarskeppet är
      
      for I in 2..Players'Last loop
	 
	 if Players(I).Playing then
	    
	    Next_Distance := abs(Players(1).Ship.XY(1) - Enemy_X);
	    -- räkna samma för nästa skepp
	    
	    if Next_Distance < Distance then
	       --om närmare, så byt till det, och den spelaren, istället
	       Distance := Next_Distance;
	       Player_Num := I;
	    end if;
	    
	 end if;

      end loop;
      
      return Player_Num;
      
   end Get_Closest_Player;
   --------------------------------------------------
   -- end GET_CLOSEST_PLAYER
   --------------------------------------------------
   
   --------------------------------------------------
   -- CHASE
   --------------------------------------------------
   procedure Chase(Player_X : in Integer; 
		   Enemies  : in out Enemy_List;
		   Waves    : in out Enemy_List_Array;
		   Shot_List : in out Object_list) is
   begin

      
      if Player_X - Enemies.XY(1) < 0 then

	 Enemies.Direction := -1;
	 Move_To_Side(Enemies);
	 
      elsif Player_X - Enemies.XY(1) > 0 then
	 
	 Enemies.Direction := 1;
	 Move_To_Side(Enemies);
	 
      elsif Ok_To_Shoot(Enemies.XY(1), Enemies.XY(2), 10, Waves) then
	 

	 --wait()

	    Create_Enemy_shot(Enemies.Enemy_Type, Enemies.XY(1)+1, Enemies.XY(2)+2, Shot_list);

	 
      end if;
   
   end Chase;
   --------------------------------------------------
   -- end CHASE
   --------------------------------------------------
   
   --------------------------------------------------
   --UPDATE ENEMY POSITION
   --------------------------------------------------
   
   procedure Update_Enemy_Position(Waves : in out Enemy_List_array;
				   Shot_List : in out Object_List;
				   Obstacle_Y: in Integer;
				   Players : in Player_array) is
      
      -- Movement_selector:
      -- 0) stand still
      -- 1) move zigzag, classic space invaders
      -- 2) move only zigzag, don't go downwards
      -- 3) Interceptor movement (chase and shoot) 
      -- 4) Destroyer movement
      
      Closest_Player  : Integer;
      Chance_For_Shot : Generator;
      
   begin 
      
      for I in Waves'Range loop -- loopar igenom alla fiendelistor.
	 
	 if Waves(I) /= null then
	    
	    -- if Wave.Movement_selector = 0 så står vi still = skippar koden.
	    
	    ----------------------------------
	    -- Classic space invaders movement
	    ----------------------------------
	    
	    if Waves(I).Movement_Type = 1 then -- alla till en pekare har samma movement selector.
	       
	       if not Next_To_Wall(Waves(I)) then
		  Move_To_Side(Waves(I)); 
	       elsif not At_Lower_Limit(Waves(I)) then
		  Move_One_Down(Waves(I), Obstacle_Y);
		  Change_Direction(Waves(I));
	       else
		  Change_Direction(Waves(I));
	       end if;
	       
	       -- if Ok_To_Shoot() then
	       Reset(Chance_For_shot);
	       Shot_Generator(Waves(I), Waves, Chance_For_Shot, Shot_List);
	       
	       ---------------------------------
	       -- Only zig-zag
	       ---------------------------------
	       
	    elsif Waves(I).Movement_Type = 2 then
	       
	       if not Next_To_Wall(Waves(I)) then
		  Move_To_Side(Waves(I)); 
	       else
		  Change_Direction(Waves(I));
	       end if;
	       
	       -- skriv in så att de går ner om gränsen neråt sjunker!
	       
	       Reset(Chance_For_shot);
	       Shot_Generator(Waves(I), Waves, Chance_For_Shot, Shot_List);
	       
	       --------------------
	       if Waves(I).Enemy_Type = EnemyType(3) then
		  Waves(I).Movement_type := 3;
	       end if;
	       -- ser till så att en interceptor som väntar på lucka
	       -- ställs tillbaka till att kolla efter spelare
	       --------------------
	       
	       
	       
	       ---------------------------------
	       -- Interceptor movement
	       ---------------------------------

	    elsif Waves(I).Movement_Type = 3 then
	       
	       --här blir det så att jag måste skicka in alla
	       --fiendelistor om interceptor ska undvika att skjuta på
	       --vågen...
	       
	       if Ok_To_Shoot(Waves(I).XY(1), Waves(I).XY(2), 4, Waves) then
		 Closest_Player := Get_Closest_Player(Waves(I).XY(1), Players);
		 Chase(Players(Closest_player).Ship.XY(1), Waves(I), Waves, Shot_List);
		 
		 if Waves(I).XY(2) < 3 then
		    Move_One_Down(Waves(I), 5); -- får ej gå lägre än våg.
		 end if;
		 
		 
	       else
		  Waves(I).Movement_Type := 2;
		  -- ställer interceptorn på att zickzacka tills tills vidare.
		  
	       end if;
	       
	       --------------------------------
	       -- Destroyer movement
	       --------------------------------
	       
	       -- här behövs wait(), så se till att skicka in
	       -- loop_counter så småningom.
	       
	    elsif Waves(I).Movement_Type = 4 then
	       
	       if Waves(I).XY(2) = World_Y_Length  then
		  Delete_Enemy_List(Waves(I));
		  
	       else
		  
		  
		  Move_One_Down(Waves(I), 60);
	       for I in 1..4 loop
		  
		  Shot_Generator(Waves(I), Waves, Chance_For_Shot, Shot_List);
		  
	       end loop;
	    end if;
	       
	    end if;
	    
	 end if;
	 
	    
      end loop;
     
   end Update_Enemy_position;

   
   --------------------------------------------------
   --end UPDATE ENEMY POSITION
   --------------------------------------------------
   
   --------------------------------------------------
   -- SPAWN WAVE
   -------------------------------------------------- Ä
   procedure Spawn_Wave(Num_To_Spawn  : in Integer;
			Enemy_Type    : in Integer;
			Movement_Type : in Integer;
			Direction     : in Integer;
			Enemies_List  : in out Enemy_List) is
      
      Min_X_Interval : constant Integer := 4;
      Y_Interval     : constant Integer := 3;
      X, X_Interval, Y : Integer; 
      Difficulty : Integer;
      Num_Lives  : Integer;  
      Num_Rows   : Integer;
      Ships_Per_Row : Integer;
      Spaces_Per_Row : Integer;
      
   begin
      
      X := GameBorder_X + 1;
      Y := GameBorder_Y + 2; -- ingen aning.
      
      -----------------------------------
      -- Egenskaper för fiendetyper
      -----------------------------------
      --Behövs kanske ej
      
      if Enemy_Type = EnemyType(1) then
	 Difficulty := 1;
	 Num_Lives  := 2;
      elsif Enemy_Type = EnemyType(2) then
	 Difficulty := 10;
	 Num_Lives := 3;
      elsif Enemy_Type = EnemyType(3) then
	 Difficulty := 15;
	 Num_Lives := 5;
      elsif Enemy_Type = EnemyType(4) then
	 Difficulty := 15;
	 Num_Lives := 5;
      end if;
      
      
      -----------------------------------
      -- end egenskaper för fiendetyper
      -----------------------------------
      
      Num_Rows := 1; -- vi tänker oss först en rad.
      Ships_Per_Row := Num_To_Spawn;
   
      X_Interval := World_X_Length/(Num_To_Spawn + 1);
      -- räkna ut spacing primärt.
      
      
      while X_Interval <  Min_X_Interval loop -- om det blir för tight
	 Num_Rows := Num_Rows + 1; --lägg till en rad
	 Ships_Per_Row := Num_To_Spawn/Num_Rows; -- räkna ut antal skepp/rad
	 Spaces_Per_Row := Ships_Per_Row + 1; -- mellanrum/rad
	 
	 X_Interval := World_X_Length/Spaces_Per_Row;
	 
      end loop;
      
      for I in 1..Num_Rows loop
	 
	 for J in 1..Ships_Per_Row loop
	    
	    Spawn_Ship(Enemy_Type, X+X_Interval, Y, Difficulty, Num_Lives, Direction, Movement_Type, Enemies_List);
	    
	    X := X + X_Interval; -- stega upp X
	    
	 end loop;
	 
	 X := Gameborder_X + 1; -- ställ tillbaka x
	 Y := Y+Y_Interval; -- stega upp y för ny rad
	 

	 
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
      --if not Empty(Enemies) then
	 
	 Put_line(Socket, Enemies.Enemy_Type); -- skickar fiendens typ
	 Put_line(Socket, Enemies.XY(1)); --skickar fiendens koordinater.
	 Put_line(Socket, Enemies.XY(2));	 
	 Put_line(Socket, Enemies.Num_Lives); -- skickar över antal liv för ev print eller 
					      -- olika print beroende på skada	 
					      ------------------------------ TEST
					      -- New_Line;
					      --Put("Ship Cordinates: ");
					      --Put(Enemies.XY(1), 0);
					      --Put(",      ");
					      -- Put(Enemies.XY(2), 0);
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
   	 --Create_Object(Enemy_Type, X, Y, 0, Enemies);
	 
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
   
   --------------------------------------------------
   -- EMPTY
   --------------------------------------------------OK
   
   function Empty(L : in Enemy_List) return Boolean is
      
   begin
      return L = null;	
      
   end Empty;
   
   --------------------------------------------------
   -- end EMPTY
   --------------------------------------------------
   
   --------------------------------------------------
   -- OK TO SHOOT
   --------------------------------------------------
   function Ok_To_Shoot(X, Y, Delta_X : in Integer;
				  Waves : in Enemy_List_Array) return Boolean is
      
      -- funktion som kollar igenom ALLA LISTOR med fiender,
      -- kollar så att ingen är under, se ok_to_shoot_single_list.
      -- Krånglet är till för att rekursionen ska fungera i den.
      
   begin
      
      for I in Waves'Range loop
	 
	 if not Ok_To_Shoot_Single_List(X, Y, Delta_X, Waves(I)) then
	    return False;
	 end if;
	 
      end loop;
      
      return True;
      
   end Ok_To_Shoot;
   --------------------------------------------------
   -- end OK TO SHOOT
   -------------------------------------------------- 
   
   --------------------------------------------------
   -- OK_TO_SHOOT_single_list
   --------------------------------------------------
   
   function Ok_To_Shoot_Single_list(X, Y, Delta_X : in Integer;
			Enemies : in Enemy_List) return Boolean is
      -- funktion som kollar om ett skepp i fiendelistan 
      -- har samma x-koordinat (inom ett intervall delta_X) och 
      -- större y-koordinat än inparameterar X och Y.
     
   begin
      
      
	 if Enemies /= null then -- om listan inte tom

	    
	    if Enemies.XY(2) > Y then 
	       -- om på rad nedanför
	       
	       for J in (-Delta_X)..Delta_X loop
		  
		  if Enemies.XY(1) = (X + J) then -- om x-koordinat inom intervall.
		     return False; -- får inte skjuta
		  end if;
		  
	       end loop;

	    end if;
	    
	    return Ok_To_Shoot_Single_list(X, Y, Delta_X, Enemies.Next); -- rekursion

	 end if;
	 
--	 return Ok_To_Shoot(X, Y, Delta_X, Waves(Counter+1), Counter+1); -- rekursion för ny lista.
	 -- end loop;
--	 end if;
      
      return True; -- har vi kommit hit finns inga fiender ivägen.

      
   end Ok_To_Shoot_Single_list;
   --------------------------------------------------
   -- end OK_TO_SHOOT_single_list
   --------------------------------------------------
   
   --------------------------------------------------
   -- GREATEST_Y_VALUE
   --------------------------------------------------
   function Greatest_Y_Value(Y : in Integer;
			     Enemies : in Enemy_List) return Boolean is
      
   --funktion som returnerar sant om skeppet har största 
   --y-värdet, alltså är längst ner. Kan ev användas som en 
   -- mer beräkningsekonomisk version av ok_to_shoot
   --för wave-skepp.
      
   begin
      
      if Enemies /= null then -- om listan är tom
	 
	 if Enemies.XY(2) > Y then 
	 --om skeppets
	 -- y-värde är större än inparameter.
	    return False;
	 else
	    return Greatest_Y_Value(Y, Enemies.Next);--rekursion
	 end if;
	 
	 
      end if;
      
      return True;
      
   end Greatest_Y_Value;   
   --------------------------------------------------
   -- end GREATEST_Y_VALUE
   --------------------------------------------------
   
   

   
end Enemy_Ship_Handling;
