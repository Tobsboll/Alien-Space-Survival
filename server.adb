with TJa.Keyboard;                 use TJa.Keyboard;
with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;
with Ada.Command_Line;             use Ada.Command_Line;
with TJa.Sockets;                  use TJa.Sockets;
with TJa.Window.Text;              use TJa.Window.Text;
with Enemy_ship_handling;          use Enemy_Ship_handling;
with Ada.Numerics.Discrete_Random; 

with Object_Handling;              use Object_Handling;
with Graphics;                     use Graphics;
with Definitions;                  use Definitions;
with Game_Engine;                  use Game_Engine;
with Gnat.Sockets;

with Window_Handling;              use Window_Handling;
with Map_Handling;                 use Map_Handling;
with Player_Handling;              use Player_Handling;

procedure Server is
   
   
   ----------------------------------------------------------------------------------------------------
   --|
   --| DECLARATIONS
   --|
   ----------------------------------------------------------------------------------------------------				 
   
   Socket1, Socket2, Socket3, Socket4 : Socket_Type;
   Sockets : Socket_Array             := (Socket1, Socket2, Socket3, Socket4);
   Listener                           : Listener_Type;
   
   Num_Players            : Integer;
   Game                   : Game_Data;
   Loop_Counter           : Integer;
   Waves                  : Enemy_List_Array;
   Shot_List              : Object_List; --shot_handling.ads
   Obstacle_List          : Object_List;
   Powerup_List           : Object_List;
   Obstacle_Y             : Integer;
   
begin
   Set_Window_Title("Server");
   
   Set_Colours(Text_Colour_1, Background_Colour_1);  -- Ändrar färgen på terminalen
   Clear_Window;
   
   -- "öppna dörren". För tillfället endast lokalt, ändra sedan.
   Initiate(Listener, Integer'Value(Argument(1)), Localhost => true);
   
   Put_Line("Servern är igång, väntar på connection");
 
   -------------------------------------------------------------
   --| Player setup before the game ----------------------------
   -------------------------------------------------------------
   
   Add_All_Players(Listener, Sockets, Num_Players);   --| Adding Player
   
   Put_Line("The server are finished with adding players");
   
   for I in 1..Num_Players loop
      Get_Players_Nick_Colour(Sockets(I), Game.Players(I));
      
      for J in 1..Num_Players loop
	 Send_Players_Nick_Colour(Sockets(J), Game.Players(I));
      end loop;
   end loop;
   -------------------------------------------------------------
   --| Done with the player setup ------------------------------
   -------------------------------------------------------------
   
   
   
   Put_line("Spelet är igång!");
   --------------------------------------------------
   --------------------------------------------------
   
   
   ----------------------------------------------------------------------------------------------------
   --|
   --| Game loop
   --|
   ----------------------------------------------------------------------------------------------------
   Set_Default_Values(Num_Players, Game);
   --Waves := (Enemies1, Enemies2, Enemies3, Enemies4);
   Loop_Counter := 1;
   
   
   for I in 1..Num_Players loop
      Game.Ranking(I) := I;  -- Ställer bara in poängplaceringen.
      
      -- Skickar startbanan till alla klienter 
      Send_Map(Sockets(I), Game, Check_Update => False);     -- Map_Handling
   end loop;    
   
   Obstacle_Y := Obstacle_Y_Pos; --konstant från definitions, men kan varieras nedan. (Jag har en plan)
   
   
   --Testar att skapa olika typer av väggar
   --Create_Object(ObstacleType(1), 2, Obstacle_Y, Light, Obstacle_List);
   
   Create_Object(ObstacleType(2), 10, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 15, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 20, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 25, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 30, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 35, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 40, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 45, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 50, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 55, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 60, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 65, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 70, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 75, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 80, 20, Obstacle_Y, Obstacle_List);
   Create_Object(ObstacleType(2), 85, 20, Obstacle_Y, Obstacle_List);

   
    -- Create_Object(ObstacleType(3), 25, 20, Obstacle_Y, Obstacle_List);
    
   --for I in 1..6 loop
   --Create_Wall(Obstacle_List, Obstacle_Y-(I*2));
   -- end loop;
   --Create_Wall(Obstacle_List, Obstacle_Y);
   
   Create_Object(PowerUpType(2), 40, Obstacle_Y_Pos+3, 0, Powerup_List);
   Create_Object(PowerUpType(3), 50, Obstacle_Y_Pos+5, 0, Powerup_List);
   
   
   -----------------------------------
   -- SPAWN FIRST WAVE
   -----------------------------------
   
   Spawn_Wave(30, --Antal
   	      EnemyType(1), --Typ
   	      1,
   	      1,
   	      waves(1));
   
   Spawn_Wave(1, --Antal
   	      EnemyType(3), --Typ
   	      3,
   	      1,
	      waves(2));
   
   
   --  Spawn_Wave(2, --Antal
   --  	      EnemyType(1), --Typ
   --  	      4,
   --  	      1,
   --  	      waves(3));
   
   -----------------------------------
   -- end SPAWN FIRST WAVE
   -----------------------------------
   
   loop 
      
      
      --------------------------------------------------
      --| SCROLLING MAP 
      --| "Level 2" => därför ej nödvändig än
      --------------------------------------------------
      if Game.Settings.Generate_Map then       -- Bestämmer under spelet om banan ska börja genereras eller inte.
      	    if Loop_Counter > 50 and Loop_Counter < 100 then

      	       New_Top_Row(Game.Map, Close => True);  -- Banan blir mindre
	       

      	    elsif Loop_Counter > 150 and Loop_Counter < 225 then
	       
      	       New_Top_Row(Game.Map);                 -- Vanlig randomisering
      	    else

      	       New_Top_Row(Game.Map, Straigt => True);-- Raka väggar
	       
      	    end if;   
      	    Move_Rows_Down(Game.Map);       -- Flyttar ner hela banan ett steg.
      end if;
      
      -- Resetar så att banangenereringen börjar igen
      -- kan nog ersättas med mod.
      if Loop_Counter > 225 then
      	 Loop_Counter := 1;
      end if;
      
      
      -- Sorterar Scoreboard.
      Sort_Scoreboard(Game, Num_Players);
      
      --Uppdatera skottens position
      Shot_Movement(Shot_List);
      Shots_Collide_In_Objects(Shot_List, Obstacle_List, Game);
      for B in Waves'Range loop
	 Shots_Collide_In_Objects(Shot_List, Waves(B), Game);
      end loop;
      
      for I in World'first..World'Last-1 loop -- Väggskott
	 Create_Object(ShotType(9),GameBorder_X+Border_Left(Game.Map, I)-1, GameBorder_Y+I, Down, Shot_List);
	 Create_Object(ShotType(10),GameBorder_X+Border_Right(Game.Map, I)-1, GameBorder_Y+I, Down, Shot_List);
      end loop;

      
      -- Skickar information till klienterna. / Eric
      for I in 1..Num_Players loop
	 if Game.Players(I).Ship.Health <= 0 then
	    Game.Players(I).Playing := False;
	 end if;
	 
	--exit when Players_Are_Dead(Game.Players);  --detta ballar ur.
	 
	 if Game.Players(I).Playing then
	    Player_Collide_In_Object( Game.Players(I).Ship.XY(1),
				      Game.Players(I).Ship.XY(2),
				      Game.Players(I).Ship, --Uppdaterar ship_spec
				      Shot_List);           --Om spelare träffas
				                            --Av skott.
	    
	    for K in 1..4 loop
	       Player_Collide_In_Object( Game.Players(I).Ship.XY(1),
					 Game.Players(I).Ship.XY(2),
					 Game.Players(I).Ship, --Uppdaterar ship_spec
					 Waves(K));        -- Om spelare krashar i fiende
	    end loop;
	 end if;                                         

	 
	 Put(Sockets(I), Shot_List);
	 Put(Sockets(I), Obstacle_List);
	 Put(Sockets(I), Powerup_List);
	 Send_Map(Sockets(I), Game);      -- Map_Handling
      	 Put_Game_Data(Sockets(I),Game);

      end loop;
      
      
      -----------------------------------
      -- Update Enemy ships
      -----------------------------------
     Obstacle_y := Highest_Y(Obstacle_List);
     Update_Enemy_Position(Waves, Shot_List, Obstacle_Y, Game.Players);
  
      -----------------------------------
      -- PUT ENEMY SHIPS
      -----------------------------------
      
      for I in 1..Num_Players loop
	 for J in Waves'Range loop
	    Put_Enemy_ships(Waves(J), Sockets(I));
	 end loop;
      end loop;
      
      -----------------------------------
      -- end PUT ENEMY SHIPS
      -----------------------------------   
      
      Get_Player_Input(Sockets, Num_Players, Game, Shot_List, Obstacle_List, Powerup_List);
      
      Loop_Counter := Loop_Counter + 1;
      
   end loop;
   
   ----------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------GAME LOOP END----
   ----------------------------------------------------------------------------------------------------
   
   --Efter spelets slut.
   
   for I in 1..Num_Players loop
      
      Remove_Player(Sockets(I), I);
      
   end loop; 
exception
   when GNAT.SOCKETS.SOCKET_ERROR => 
      
      DeleteList(Shot_List);
      DeleteList(Obstacle_List);
      DeleteList(Powerup_List);
      New_Line;
      Put("Someone disconnected!");
   when STORAGE_ERROR =>
      DeleteList(Shot_List);
      DeleteList(Obstacle_List);
      DeleteList(Powerup_List);
      New_Line;
      Put("VI HAR EN MINNESLÄCKAA!");
      

end Server;

--gnatmake $(~TDDD11/TJa-lib/bin/tja_config)
