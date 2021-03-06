



package body Enemy_Ship_Handling is
   
   --------------------------------------------------
   -- INSERT SHIP FIRST
   --------------------------------------------------
   procedure Insert_Ship_first(Ship : in out Object_Data_Type;
			       Enemies : in out Object_List) is
      
      --en vanlig insert first
      
      New_Ship : Object_List;
      
   begin
      
      New_Ship := new Object_Data_Type;
      New_Ship.Object_Type := Ship.Object_Type;
      New_Ship.XY_Pos := Ship.XY_Pos;
      New_Ship.Difficulty := Ship.Difficulty;
      New_Ship.Attribute := Ship.Attribute;
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
   procedure Insert_Ship_ordered(Ship    : in out Object_Data_Type;
			         Enemies : in out Object_list) is
      
      
      --en vanlig insert sorted, högre koordinater hamnar längst ner i listan.
   begin
      
      
      if not Empty(Enemies) then -- listan inte tom
	 
	 if Enemies.XY_Pos(2) >= Ship.XY_Pos(2) and Enemies.XY_Pos(1) >= Ship.XY_Pos(1) then
	    
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
			Enemies_List : in out Object_list) is
      
      -- Types:
      -- 1) Ordinary ship
      -- 2) Interceptor ship
      -- 3) Destroyer ship
      
      New_Ship : Object_Data_type;
      
   begin
      
      --  New_Ship := new Enemy_Ship_Type;
      New_Ship.Object_Type    := Enemy_Type;
      New_Ship.XY_Pos(1)      := X;
      New_Ship.XY_Pos(2)      := Y;
      New_Ship.Difficulty     := Difficulty;
      New_Ship.Attribute      := Num_Lives;
      New_Ship.Direction      := Direction;
      New_Ship.Movement_Type  := Movement_Type; 
      
      Insert_Ship_Ordered(New_Ship, Enemies_List);

      
      
   end Spawn_Ship;
   --------------------------------------------------
   -- end SPAWN SHIP
   --------------------------------------------------
   
   
   --------------------------------------------------
   -- NEXT TO WALL
   --------------------------------------------------
   
   function Next_To_Wall(Enemies : in Object_List;
			 Map     : in World) return Boolean is
      
   begin -- förrvirrad ordning här eftersom listan är sorterad baklänges (sist in - först ut).
      
      
      if not Empty(Enemies) and then Enemies.XY_Pos(2) > 0 then

	 if Enemies.Direction = 1 then -- höger 
	    
	    if Enemies.XY_Pos(1) >= Border_Right(Map, Enemies.XY_Pos(2)) + GameBorder_X - 4 or
	      (Enemies.XY_Pos(2) > 1 and then Enemies.XY_Pos(1) >= GameBorder_X+Border_Right(Map, Enemies.XY_Pos(2)-1) -7) then 
	       return True;
	    else return Next_To_Wall(Enemies.Next, Map);
	    end if;
	    
	 elsif Enemies.Direction = -1 then -- vänster 
	    
	    if Enemies.XY_Pos(1) <= GameBorder_X + Border_Left(Map, Enemies.XY_Pos(2)) or
	      (Enemies.XY_Pos(2) > 1 and then Enemies.XY_Pos(1) <= GameBorder_X+Border_Left(Map, Enemies.XY_Pos(2)-1)+3) then 
	       return True;
	    else return Next_To_Wall(Enemies.Next, Map); --rekursion
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
   
   procedure Move_To_Side(Enemies : in out Object_List) is
      
   begin
      
      if not Empty(Enemies) then
	 
	 Enemies.XY_Pos(1) := Enemies.XY_Pos(1) + Enemies.Direction;
	 
	 Move_To_Side(Enemies.Next); 	 
	 
      end if;
      
   end Move_To_Side;
   
   --------------------------------------------------
   -- end MOVE TO SIDE
   --------------------------------------------------
   
   --------------------------------------------------
   -- CHANGE MOVEMENT TYPE
   --------------------------------------------------
   
   procedure Change_Movement_Type(Enemies  : in out Object_List;
				  New_Type : in Integer) is
      
   begin
      
      if not Empty(Enemies) then
	 
	 Enemies.Movement_Type := New_Type;
	 Change_Movement_Type(Enemies.Next, New_type);
	 
      end if;
      
   end Change_Movement_Type;
   
   --------------------------------------------------
   -- end CHANGE MOVEMENT TYPE
   --------------------------------------------------
   
   --------------------------------------------------
   -- MOVE ONE UP
   --------------------------------------------------
   
   procedure Move_One_Up(Enemies : in out Object_list) is
      
   begin
      
      if not Empty(Enemies) then 
	 
	 if Enemies.XY_Pos(2) > Gameborder_Y+1 then -- så de inte backar utanför banan.
	    
	    Enemies.XY_Pos(2) := Enemies.XY_Pos(2) - 1;
	    
	    Move_One_Up(Enemies.Next); -- rekursion
	    
	 end if;
	 
      end if;
      
      
   end Move_One_Up;
   --------------------------------------------------
   -- end MOVE ONE UP
   --------------------------------------------------
   
   
   --------------------------------------------------
   -- MOVE ONE DOWN
   --------------------------------------------------
   
   procedure Move_One_Down(Enemies : in out Object_List)
     -- Obstacle_Y: in Integer)
   is
      
   begin
      
      if not Empty(Enemies) then 
	 
	 Enemies.XY_Pos(2) := Enemies.XY_Pos(2) + 1;
	 
	 Move_One_Down(Enemies.Next); -- rekursion
	 
      end if;
      
   end Move_One_Down;
   --------------------------------------------------
   -- end MOVE ONE DOWN
   --------------------------------------------------
   
   --------------------------------------------------
   -- CHANGE DIRECTION
   --------------------------------------------------
   
   procedure Change_Direction(Enemies : in out Object_List) is
      
   begin
      
      if not Empty(Enemies) then
	 
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
      -- Låt shotType bero på antingen difficulty eller något annat som är i
      -- range 1..10 
      -- Enemy_Shot : Integer := Difficoulty;
      -- => ShotType(Enemy_Shot);
      -- man kan se i graphics.ads vilka shots som finns
   begin -- courtesy of Andreas ^^
      
      if Enemy_Type = Interceptor2 or Enemy_Type = Nitro_Bomber then
	 Create_Object(ShotType(Nitro_Shot), X+1, Y+2, Down, Shot_List);
      else
	 Create_Object(ShotType(Normal_Laser_Shot), X+1, Y+2, Down, Shot_List);
	 
	 --Extra lasers (Specialfall):
	 if Enemy_Type = Support then
	    Create_Object(ShotType(Diagonal_Laser), X-1, Y+1, Down, Shot_List, 0, Left);
	    Create_Object(ShotType(Diagonal_Laser), X+3, Y+1, Down, Shot_List, 0, Right);
	 end if;
      end if;
      
   end Create_Enemy_Shot;
   --------------------------------------------------
   -- end CREATE SHOT
   --------------------------------------------------
   
   --------------------------------------------------
   -- SHOT GENERATOR
   --------------------------------------------------
   
   procedure Shot_Generator(Enemies : in out Object_List;
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
      
      if not Empty(Enemies) then
	 
   	 if Alien_Shot_Probability <= Enemies.Difficulty then
	    
	    if Enemies.Object_Type = EnemyType(4) then
	       
	       for I in (-1)..1 loop
		  Create_enemy_Shot(Enemies.Object_type, Enemies.XY_Pos(1)+(2*I), Enemies.XY_Pos(2), Shot_List);
	       end loop;
	       
	    elsif Enemies.Object_Type = Support then
	       Create_enemy_Shot(Enemies.Object_type, Enemies.XY_Pos(1), Enemies.XY_Pos(2), Shot_List);
	       
	    else
	       
	       
	       if Ok_To_Shoot(Enemies.XY_Pos(1), Enemies.XY_Pos(2), 2, Waves) then
		  Create_enemy_Shot(Enemies.Object_type, Enemies.XY_Pos(1), Enemies.XY_Pos(2), Shot_List);
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
   
   function At_Lower_limit(Enemies : in Object_List; 
			   Obstacle_Y : in Integer) return Boolean is
      
      -- funktion som kollar om något skepp i listan
      -- har en y-koord nära obstacle_y, vilket är en gräns
      -- som ändras i takt med att barriärer skjuts
      -- sönder.
      
   begin
      
      
      if Enemies /= null then
	 if Enemies.XY_Pos(2) >= Obstacle_Y-4 then
	    return True;
	 end if;
	 
	 return At_Lower_Limit(Enemies.Next, Obstacle_Y); --rekursion
	 
      else
	 return False;
      end if;
      
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
	 
	 if not Empty(All_Enemies(I)) then
	    Num_Lists := Num_Lists + 1;
	 end if;

      end loop;
      
      return Num_Lists;	   
      
   end Last_List;
   
   --------------------------------------------------
   -- end LAST LIST
   --------------------------------------------------
   
   --------------------------------------------------
   -- HIGHEST PLAYER
   --------------------------------------------------
   function Highest_Player(Players : in Player_array) return Integer is
      
      Highest_Player : Integer;
      Y_Value        : Integer;
      New_Y_Value    : Integer;
      Player_Active  : Boolean := False;
      
   begin
      
      Y_Value := 1000; -- skönsvärde för jämförelse första gången
      
      for I in Players'range loop
	 
	 if Players(I).Playing then
	    
	    Player_Active := True;
	    
	    New_Y_Value := Players(I).Ship.XY(2);
	    
	    if New_Y_Value < Y_Value then
	       Y_Value := New_Y_Value;
	       Highest_Player := I;
	    end if;
	    
	 end if;
	 
      end loop;
      
      if not Player_Active then 
	 -- om ingen spelare lever så undviks krasch genom att 
	 -- skicka en nolla som i update_enemy_position
	 -- tolkas som att spelararrayen inte ska genomsökas
	 return 0;
	 
      else
	 
	 return Highest_Player;
	 
      end if;
      
      
   end Highest_Player;
   --------------------------------------------------
   -- end HIGHEST PLAYER
   --------------------------------------------------
   
   --------------------------------------------------
   -- GET_CLOSEST_PLAYER
   --------------------------------------------------
   function Get_Closest_Player(Enemy_X : in Integer;
			       Players : in Player_Array;
			       Waves   : in Enemy_List_array) return Integer is
      -- funktion som räknar ut vilken spelare som är närmast.
      Distance : Integer;
      Next_Distance : Integer;
      Player_Num : Integer;
      High_Player : Integer;
      Player_Active : Boolean := False;
      
   begin
      

      
      High_Player := Highest_Player(Players);
      
      if (Waves(1) /= null and High_Player /= 0) and then Above_Wave(Players(High_Player).Ship.XY(2), Waves(1)) then
	 -- vi kollar så att fiendelistan finns, att vi inte fick en nolla
	 -- från Highest_player (= alla spelare är döda, vilket leder till
         -- krasch när vi letar i player_array), samt om i så fall
	 -- spelaren är ovanför vågen. Denna spelare ska då prioriteras
	 -- av interceptorn.
	 
	 return High_Player;
	 
      else 

	 Distance := 1000; --skönsvärde för jämförelse första gången.
	 
	 for I in Players'range loop
	    
	    if Players(I).Playing then
	       
	       Player_Active := True;
	       
	       Next_Distance := abs(Players(I).Ship.XY(1) - Enemy_X);
	       -- räkna samma för nästa skepp
	       
	       if Next_Distance < Distance then
		  --om närmare, så byt till det, och den spelaren, istället
		  Distance := Next_Distance;
		  Player_Num := I;
	       end if;
	       
	    end if;

	 end loop;
      end if;
      
      if not Player_Active then
      	 -- om ingen spelare lever så undviks krasch genom att 
	 -- skicka en nolla som tolkas som i update_enemy_position
	 -- tolkas som att spelararrayen inte ska genomsökas
	 return 0;
	 
      else
	 
	 return Player_Num;
	 
      end if;
      
   end Get_Closest_Player;
   --------------------------------------------------
   -- end GET_CLOSEST_PLAYER
   --------------------------------------------------
   
   --------------------------------------------------
   -- ABOVE_WAVE
   --------------------------------------------------
   function Above_Wave(Player_Y : in Integer;
		       Enemies  : in Object_list) return Boolean is
      -- funktion som kollar om spelaren är ovanför vågen
      -- dvs så att exv interceptorn borde skjuta/jaga den.
      -- Har valt att lägga rekursion för att det ska trigga
      --redan när man passerar första fienden, dvs om man hittar 
      --någon lucka så kan interceptorn ändå se dig.
      
      -- en minussida med denna kod är att vi måste bestämma en fix lista
      --för vågen, nu satt till Waves(1).
      
   begin
      
      if Enemies /= null then
	 
	 if Player_Y <= Enemies.XY_Pos(2) then
	    return True;
	 else return Above_Wave(Player_Y, Enemies.Next);
	 end if;
	 
      else
	 return False;
      end if;

   end Above_Wave;
   --------------------------------------------------
   -- end ABOVE_WAVE
   --------------------------------------------------
   
   
   --------------------------------------------------
   -- CHASE
   --------------------------------------------------
   procedure Chase(Player_XY : in XY_Type; 
		   Enemies  : in out Object_List;
		   Waves    : in out Enemy_List_Array;
		   Shot_List : in out Object_list) is
   begin
      
      -------------- Y-LED
      
      
      if Above_Wave(Player_XY(2), Waves(1)) and then Player_XY(2) < Enemies.XY_Pos(2)+5 then
	 -- om spelaren är över vågen och för nära så backa
	 Move_One_Up(Enemies);
      elsif Waves(1) /= null and then Enemies.XY_Pos(2) < Waves(1).XY_Pos(2)-8 and then (Player_XY(2) > Enemies.XY_Pos(2)+6) then
	 -- annars, om vågen inte för nära, gå neråt
	 Move_One_Down(Enemies);
	 --  else
	 --  	 --sätt interceptorn på att zickzacka tills vidare
	 --  	 --om den inta kan gå uppåt eller neråt.
	 --  	 Enemies.Movement_Type := 2;
      end if;
      
      
      
      
      -------------- X-LED
      
      if (Player_XY(1)+1) - Enemies.XY_Pos(1) < 0 then

	 Enemies.Direction := -1;
	 Move_To_Side(Enemies);
	 
      elsif (Player_XY(1)+1) - Enemies.XY_Pos(1) > 0 then
	 
	 Enemies.Direction := 1;
	 Move_To_Side(Enemies);
	 
      elsif Ok_To_Shoot(Enemies.XY_Pos(1), Enemies.XY_Pos(2), 10, Waves) or (Waves(1) /= null and  Above_Wave(Player_XY(2), Waves(1))) then

	 Create_Enemy_shot(Enemies.Object_Type, Enemies.XY_Pos(1), Enemies.XY_Pos(2)+1, Shot_list);

      end if;
      
   end Chase;
   --------------------------------------------------
   -- end CHASE
   --------------------------------------------------
   
   --------------------------------------------------
   -- KAMIKAZEE_CHASE
   --------------------------------------------------
   procedure Kamikazee_Chase(Player_XY : in XY_Type; 
		             Enemies   : in out Object_List;
		             Waves     : in out Enemy_List_Array;
		             Shot_List : in out Object_list) is
      
   begin
      
      -------------- Y-LED
      
      Move_One_Down(Enemies);
      -- gå alltid neråt! Den får ha så mycket liv att den krossar sig igenom fiendernas linjer.
      
      
      
      
      -------------- X-LED
      
      if Player_XY(1) - Enemies.XY_Pos(1) < 0 then

	 Enemies.Direction := -1;
	 Move_To_Side(Enemies);
	 
      elsif Player_XY(1) - Enemies.XY_Pos(1) > 0 then
	 
	 Enemies.Direction := 1;
	 Move_To_Side(Enemies);
	 
      end if;
      
      
   end Kamikazee_Chase;
   --------------------------------------------------
   -- end KAMIKAZEE_CHASE
   --------------------------------------------------
   
   --------------------------------------------------
   --UPDATE ENEMY POSITION
   --------------------------------------------------
   
   
   procedure Update_Enemy_Position(Waves : in out Enemy_List_array;
				   Shot_List : in out Object_List;
				   Obstacle_Y: in Integer;
				   Players : in Player_Array;
				   Map     : in World) is
      
      -- Movement_selector:
      -- 0) stand still
      -- 1) move zigzag, classic space invaders
      -- 2) move only zigzag, don't go downwards
      -- 3) Interceptor movement (chase and shoot) 
      -- 4) Kamikazee movement
      
      Closest_Player  : Integer;
      Chance_For_Shot : Generator;
      
   begin 
      
      for I in Waves'Range loop -- loopar igenom alla fiendelistor.
	 
	 if not Empty(Waves(I)) then
	    
	    if Waves(I).Movement_Type = 0 then --Vi vill skjuta även om någon står still
	       Reset(Chance_For_shot);
	       Shot_Generator(Waves(I), Waves, Chance_For_Shot, Shot_List);
	       
	       ----------------------------------
	       -- Classic space invaders movement
	       ----------------------------------
	       
	    elsif Waves(I).Movement_Type = 1 then -- alla till en pekare har samma movement selector.
	       
	       if not Next_To_Wall(Waves(I), Map) then
		  Move_To_Side(Waves(I)); 
	       elsif not At_Lower_Limit(Waves(I), Obstacle_Y) then
		  Move_One_Down(Waves(I));
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
	       
	       if not Next_To_Wall(Waves(I), Map) then
		  Move_To_Side(Waves(I)); 
	       else
		  Change_Direction(Waves(I));
	       end if;
	       
	       -- skriv in så att de går ner om gränsen neråt sjunker!
	       
	       
	       if Waves(I).Object_Type /= Interceptor or
		 Waves(I).Object_Type /= Interceptor2 Then
		  -- så att inte interceptorn skjuter när den
		  -- patrullerar
		  Reset(Chance_For_shot);
		  Shot_Generator(Waves(I), Waves, Chance_For_Shot, Shot_List);
	       end if;
	       
	       --------------------
	       if Waves(I).Object_Type = Interceptor or
		 Waves(I).Object_Type = Interceptor2 Then
		  Waves(I).Movement_type := 3;
	       elsif Waves(I).Object_Type = Kamikazee then
		  Waves(I).Movement_Type := 4;
	       end if;
	       -- ser till så att ett skepp som tillfälligt patrullerar
	       -- ställs tillbaka till sitt egna beteende.
	       --------------------
	       
	       
	       
	       ---------------------------------
	       -- Interceptor movement
	       ---------------------------------

	    elsif Waves(I).Movement_Type = 3 then
	       

	       Closest_Player := Get_Closest_Player(Waves(I).XY_Pos(1), Players, Waves);
	       -- räknar ut vilken spelare som är närmast 
	       
	       if Closest_Player /= 0 then
		  -- om Closest_player returnerar en nolla så betyder 
		  -- det att alla spelare är döda, och vi undviker
		  -- därför att leta i spelararrayen då, annars kraschar
		  -- spelet
		  
		  if Ok_To_Shoot(Waves(I).XY_Pos(1), Waves(I).XY_Pos(2), 4, Waves)  or ((Waves(1) /= null and then Above_Wave(Players(Closest_player).Ship.XY(2), Waves(1)))) then
		     -- om skeppet har fri sikt eller om spelaren är 
		     -- ovanför vågen så jagar interceptorn spelaren, 
		     -- i chase-koden ingår skjutande.
		     
		     if Players(Closest_player).Playing then
			Chase(Players(Closest_player).Ship.XY, Waves(I), Waves, Shot_List);
		     end if;
		     
		  else
		     Waves(I).Movement_Type := 2;
		     --om den inte kan skjuta eller jaga så
		     --ställs interceptorn på att zickzacka tills tills vidare.
		     
		  end if;
	       else
		  -- om alla spelare döda så ska den patrullera nonchalant.
		  Waves(I).Movement_Type := 2;
		  
	       end if;
	       
	       
	       --------------------------------
	       -- Kamikazee movement
	       --------------------------------
	       

	       
	    elsif Waves(I).Movement_Type = 4 then
	       
	       if Waves(I).XY_Pos(2) = World_Y_Length  then
		  DeleteList(Waves(I));
	       else
		  
		  Closest_Player := Get_Closest_Player(Waves(I).XY_Pos(1), Players, Waves);
		  
		  if Closest_Player /= 0 then
		     -- om Closest_player returnerar en nolla så betyder 
		     -- det att alla spelare är döda, och vi undviker
		     -- därför att leta i spelararrayen då, annars kraschar
		     -- spelet
		     
		     if Ok_To_Shoot(Waves(I).XY_Pos(1), Waves(I).XY_Pos(2), 4, Waves)  or ((Waves(1) /= null and then Above_Wave(Players(Closest_player).Ship.XY(2), Waves(1)))) then
			-- om skeppet har fri sikt eller om spelaren är 
			-- ovanför vågen så jagar skeppet spelaren
			
			if Players(Closest_player).Playing then
			   Kamikazee_chase(Players(Closest_player).Ship.XY, Waves(I), Waves, Shot_List);
			end if;
			
		     else
			Waves(I).Movement_Type := 2;
			--om den inte kan skjuta eller jaga så
			--ställs interceptorn på att zickzacka tills vidare.
			
		     end if;

		  end if;
		  
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
			X_Value       : in Integer;
			Y_Value       : in Integer;
			Difficulty    : in Integer;
			Enemies_List  : in out Object_List) is
      
      Min_X_Interval : constant Integer := 4;
      Y_Interval     : constant Integer := 3;
      X, X_Interval, Y : Integer; 
      --Difficulty : Integer;
      Shot_Difficulty : Integer;
      Num_Lives  : Integer;  
      Num_Rows   : Integer;
      Ships_Per_Row : Integer;
      Spaces_Per_Row : Integer;
      
   begin
      
      Shot_Difficulty := 2 + Difficulty;
      
      X := X_Value;
      Y := Y_Value;
      if Y < Gameborder_Y +2 then
	 -- så vi inte spawnar fiender utanför kanten
	 Y := GameBorder_Y + 2;
      end if;
      
      -----------------------------------
      -- Egenskaper för fiendetyper
      -----------------------------------
      -- finns bara två typer i nuläget.
      if Enemy_Type = Minion or Enemy_Type = Nitro_Bomber Then

	 if Difficulty < 5 then
	    Num_Lives  := Difficulty;
	 else
	    Num_Lives := 4;
	 end if;

      elsif Enemy_Type = Interceptor then
	 
	 Num_Lives := 4 + Difficulty;
	 
      elsif Enemy_Type = Kamikazee then
	 
	 Num_Lives := 10;
	 
      end if;
      
      
      
      -----------------------------------
      -- end egenskaper för fiendetyper
      -----------------------------------
      
      Num_Rows := 1; -- vi tänker oss först en rad.
      Ships_Per_Row := Num_To_Spawn;
      
      X_Interval := 2*(World_X_Length/3)/(Num_To_Spawn + 1);
      -- räkna ut spacing primärt.
      
      
      while X_Interval <  Min_X_Interval loop -- om det blir för tight
	 Num_Rows := Num_Rows + 1; --lägg till en rad
	 Ships_Per_Row := Num_To_Spawn/Num_Rows; -- räkna ut antal skepp/rad
	 Spaces_Per_Row := Ships_Per_Row + 1; -- mellanrum/rad
	 
	 X_Interval := 2*(World_X_Length/3)/Spaces_Per_Row;
	 
      end loop;
      
      for I in 1..Num_Rows loop
	 
	 for J in 1..Ships_Per_Row loop
	    
	    Spawn_Ship(Enemy_Type, X+X_Interval, Y, Shot_Difficulty, Num_Lives, Direction, Movement_Type, Enemies_List);
	    
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
				    Enemies : in Object_List) return Boolean is
      -- funktion som kollar om ett skepp i fiendelistan 
      -- har samma x-koordinat (inom ett intervall delta_X) och 
      -- större y-koordinat än inparameterar X och Y.
      
   begin
      
      
      if not Empty(Enemies) then -- om listan inte tom

	 
	 if Enemies.XY_Pos(2) > Y then 
	    -- om på rad nedanför
	    
	    for J in (-Delta_X)..Delta_X loop
	       
	       if Enemies.XY_Pos(1) = (X + J) then -- om x-koordinat inom intervall.
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
			     Enemies : in Object_List) return Boolean is
      
      --funktion som returnerar sant om skeppet har största 
      --y-värdet, alltså är längst ner. Kan ev användas som en 
      -- mer beräkningsekonomisk version av ok_to_shoot
      --för wave-skepp.
      
   begin
      
      if not Empty(Enemies) then -- om listan är tom
	 
	 if Enemies.XY_Pos(2) > Y then 
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
   
   ---------------------------------------------------
   -- ALL_ENEMIES_DEAD
   --------------------------------------------------
   function All_Enemies_Dead(Waves : in Enemy_List_array) return Boolean is
      
   begin
      
      for I in Waves'Range loop
	 
	 if not Empty(Waves(I)) then
	    return False;
	 end if;
	 
      end loop;
      
      return True;
      
   end All_Enemies_Dead;
   --------------------------------------------------
   -- end ALL ENEMIES DEAD
   --------------------------------------------------


   
end Enemy_Ship_Handling;
