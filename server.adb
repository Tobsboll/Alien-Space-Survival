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
with Level_Handling;               use Level_Handling; 
with Score_Handling;               use Score_Handling;
with Task_Server_Communication;    use Task_Server_Communication;

procedure Server is
   
   
   ----------------------------------------------------------------------------------------------------
   --|
   --| DECLARATIONS
   --|
   ----------------------------------------------------------------------------------------------------				 
   
   Socket1, Socket2, Socket3, Socket4 : Socket_Type;
   Sockets : Socket_Array             := (Socket1, Socket2, Socket3, Socket4);
   Listener                           : Listener_Type;
   
   Num_Players            : Integer := 1;
   Obstacle_Y             : Integer;
   Level                  : Integer := 0;
   Loop_Counter           : Integer;
   Player_To_Revive       : Integer;
   Server_Waiting         : Character := 'o';
   
   Game                   : Game_Data;
   Waves                  : Enemy_List_Array;
   Players_Choice         : Players_Choice_Array :=('o', 'o', 'o', 'o');
   Shot_List              : Object_List;
   Astroid_List           : Object_List;
   Obstacle_List          : Object_List;
   Powerup_List           : Object_List;
   Wall_List              : Object_List;
   
   Level_Cleared          : Boolean := False;
   New_Level              : Boolean := True; 
   
begin
   Set_Window_Title("Server");
   
   Set_Colours(Text_Colour_1, Background_Colour_1);  -- Ändrar färgen på terminalen
   Clear_Window;
   
   -- "öppna dörren". För tillfället endast lokalt, ändra sedan.
   Initiate(Listener, Integer'Value(Argument(1)), Localhost => true);
   
   Put_Line("Servern är igång, väntar på connection");
   
   loop
      -------------------------------------------------------------
      --| Player setup before the game ----------------------------
      -------------------------------------------------------------
      if not Check_Players_Choice(Players_Choice, 'R', Num_Players) then
	 Add_All_Players(Listener, Sockets, Num_Players);   --| Adding Player
	 
	 Put_Line("The server are finished with adding players");
	 
	 for I in 1..Num_Players loop
	    Get_Players_Nick_Colour(Sockets(I), Game.Players(I));
	    
	    for J in 1..Num_Players loop
	       Send_Players_Nick_Colour(Sockets(J), Game.Players(I));
	    end loop;
	 end loop;
	 
      end if;
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
   Set_Default_Values(Num_Players, Game, Loop_Counter, Players_Choice, Level, Level_Cleared, New_Level);
   
   
   for I in 1..Num_Players loop
      Game.Ranking(I) := I;  -- Ställer bara in poängplaceringen.
      
      -- Skickar startbanan till alla klienter 
      Send_Map(Sockets(I), Game, Check_Update => False);     -- Map_Handling
   end loop;    
   
   Obstacle_Y := Obstacle_Y_Pos; --konstant från definitions, men kan varieras nedan. (Jag har en plan)
   
   --for I in 1..6 loop
   --Create_Wall(Obstacle_List, Obstacle_Y-(I*2));
   -- end loop;
   --Create_Wall(Obstacle_List, Obstacle_Y);
   
     Create_Object(PowerUpType(Missile_Ammo), 40, Obstacle_Y_Pos+3, 0, Powerup_List);
     Create_Object(PowerUpType(Hitech_Laser), 50, Obstacle_Y_Pos+5, 0, Powerup_List);
     Create_Object(PowerUpType(Tri_Laser), 60, Obstacle_Y_Pos+5, 0, Powerup_List);
     Create_Object(PowerUpType(Diagonal_Laser), 30, Obstacle_Y_Pos+5, 0, Powerup_List);
     Create_Object(PowerUpType(Nitro_Upgrade), 70, Obstacle_Y_Pos+2, 0, Powerup_List);
     Create_Object(PowerUpType(health), 80, Obstacle_Y_Pos+6, 0, Powerup_List);
     Create_Object(PowerUpType(Super_Missile), 90, Obstacle_Y_Pos+6, 0, Powerup_List);
     Create_Object(PowerUpType(Laser_Upgrade), 97, Obstacle_Y_Pos+6, 0, Powerup_List);
     Create_Object(PowerUpType(Hitech_Laser), 110, Obstacle_Y_Pos+6, 0, Powerup_List);
    
   loop 
      
      --| Syncing with Klient
      ---------------------------------------|
      while Server_Waiting /= '$' loop     --|
	 Get(Sockets(1), Server_Waiting);  --|
      end loop;                            --|
      Server_Waiting := 'o';               --|
      Put(Sockets(1), '$');                --|
      
      ---------------------------------------|
      
      -- Tar bort väggskotten
      DeleteList(Wall_List);
      
      -- Kontrollerar om leveln är avklarad:
      if All_Enemies_Dead(Waves) then
	 if not Level_Cleared then
	    Loop_Counter := 1;
	 end if;
	 Level_Cleared := True;    	    
      end if;
      
      
      -- Spawning The New Level
      if New_Level then
	 Spawn_Level(Level, Game.Settings.Difficulty, Waves, Level_Cleared, New_Level, Num_Players); 
      end if; 

      

      if Level_Cleared then
	 -- From CLEARED Level To NEW Level
	 Between_Levels(Loop_Counter, Game, Astroid_List, Obstacle_List, New_Level); 
	 
      else
	 -------------------------------------------------- 
	 --| SCROLLING MAP  
	 -------------------------------------------------- 
	 if Loop_Counter mod 8 = 0 then
	    if Highest_X_Position(Waves(1))-Lowest_X_Position(Waves(1))+20 <= Border_Difference(Game.Map) then 
	       New_Top_Row(Game.Map);                 -- Vanlig randomisering 
	       
	    else
	       if Loop_Counter mod 3 = 1 then 
		  New_Top_Row(Game.Map, Open => True); 
	       else
		  New_Top_Row(Game.Map); 
	       end if;
	    end if;
	    Move_Rows_Down(Game.Map);
	 end if;
      end if;   
      
      
      -----------------------------------
      -- Update Enemy ships
      -----------------------------------
      if not Empty(Obstacle_List) then
	 Obstacle_y := Highest_Y_Position(Obstacle_List);
      else
	 Obstacle_Y := Obstacle_Y_Pos; --definitions
      end if;
      
      Update_Enemy_Position(Waves, Shot_List, Obstacle_Y, Game.Players, Game.Map);
      
     
	 
      -- Uppdaterar astroidernas position.
      Shot_Movement(Astroid_List);
	 
      -- Sorterar Scoreboard.
      Sort_Scoreboard(Game, Num_Players);
      
      
      for I in World'first..World'Last-1 loop -- Väggskott
	 Create_Object(ShotType(9),GameBorder_X+Border_Left(Game.Map, I)-1, GameBorder_Y+I, Down, Wall_List);
	 Create_Object(ShotType(10),GameBorder_X+Border_Right(Game.Map, I)-1, GameBorder_Y+I, Down, Wall_List);
      end loop;
      
      -- Skickar information till klienterna. / Eric
      for I in 1..Num_Players loop
	 if Game.Players(I).Ship.Health <= 0 then
	    Game.Players(I).Playing := False;
	    Game.Players(I).Ship.Laser_Recharge := 1; --Nu kan man inte skjuta mera
	 end if;
	 
	 --------------------------------------------------
	 --Uppdaterar spelarna om de spelar:
	 --------------------------------------------------
	 if Game.Players(I).Playing then
	    Player_Collide_In_Object( Game.Players(I).Ship.XY(1),
				      Game.Players(I).Ship.XY(2),
				      Game.Players(I),      --Uppdaterar ship_spec
				      Shot_List,             --Om spelare träffas
				      Player_To_Revive           --Av skott.
				    );
				      
	    Player_Collide_In_Object( Game.Players(I).Ship.XY(1),
				      Game.Players(I).Ship.XY(2),
				      Game.Players(I),      --Uppdaterar ship_spec
				      Astroid_List,        --Om spelare träffas
				      Player_To_Revive	    --Av asteroid
				    );
							    
	   
							    
	   Player_Collide_In_Object( Game.Players(I).Ship.XY(1),
				      Game.Players(I).Ship.XY(2),
				      Game.Players(I),      --Uppdaterar ship_spec
				      Powerup_List,         --Om spelare träffas
				      Player_To_Revive      --Av powerup
				      );
							    
	   Revive_Player(Player_To_Revive, Game.Players);
	   
	   Player_Collide_In_Object( Game.Players(I).Ship.XY(1),
				     Game.Players(I).Ship.XY(2),
				     Game.Players(I),     --Uppdaterar ship_spec
				     Wall_List,           --Om spelare träffas
				     Player_To_Revive      --Av Vägg
				   );

	    for K in 1..4 loop
	       Player_Collide_In_Object( Game.Players(I).Ship.XY(1),
					 Game.Players(I).Ship.XY(2),
					 Game.Players(I), --Uppdaterar ship_spec
					 Waves(K),         -- Om spelare krashar i fiende
					 Player_To_Revive  
				       );
	       
	       Update_Player_Recharge(Game.Players(I));
	    end loop;
	 end if;                                         

      end loop;
      
      --Shot_Movement(Shot_List);
      Shots_Collide_In_Objects(Shot_List, Obstacle_List, Game);
      Shots_Collide_In_Objects(Shot_List, Astroid_List, Game);
      Shots_Collide_In_Objects(Shot_List, Wall_List, Game);
      Shots_Collide_In_Objects(Astroid_List, Obstacle_List, Game);
      Shots_Collide_In_Objects(Astroid_List, Wall_List, Game);
      Shots_Collide_In_Objects(Obstacle_List, Wall_List, Game);
      
      for B in Waves'Range loop
	 Shots_Collide_In_Objects(Shot_List, Waves(B), Game);
      end loop;
      
      if Players_Are_Dead (Game.Players) then
	 Game.Settings.Gameover := 1;
      end if;

      --------------------------------
      --| Skicka till klienterna
      --------------------------------
      
      --  for I in 1..Num_Players loop
      --  	 Put_Data(Sockets(I), Astroid_List, Shot_List, Obstacle_List, Powerup_List, Game, Waves);
      --  end loop;
      
      
      for I in 1..Num_Players loop
      	 Put(Sockets(I), Astroid_List);
	 Put(Sockets(I), Shot_List);
	 Put(Sockets(I), Obstacle_List);
	 Put(Sockets(I), Powerup_List);
	 Send_Map(Sockets(I), Game);      -- Map_Handling
	 Put_Game_Data(Sockets(I),Game);

	 for J in Waves'Range loop
	    Put(Sockets(I), Waves(J));
	 end loop;

	 Put_Line(Sockets(I), Level);
	 Put_Line(Sockets(I), Loop_Counter);

      end loop;
     
      Shot_Movement(Shot_List);
      for I in Waves'Range loop
	 Delete_Object_In_List(Waves(I), ShotType(Explosion) );
      end loop;
      	 
      -----------------------------------
      ---| Tar emot från klienterna
      -----------------------------------
      if Game.Settings.Gameover /= 1 then
      	 Get_Player_Input(Sockets, Num_Players, Game, 
      			  Shot_List, Obstacle_List, Powerup_List);
      else
	 delay(0.1);
	 Get_Players_Choice( Players_Choice , Sockets, Num_Players, Game);
	 Send_Players_Choice( Players_Choice, Sockets, Num_Players);
	 
      end if;

      exit when not Check_Players_Choice(Players_Choice, 'S', Num_Players) 
	and not Check_Players_Choice(Players_Choice, 'o', Num_Players);

      
      Loop_Counter := Loop_Counter + 1;
      
   end loop;
   
   
   ----------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------GAME LOOP END----
   ----------------------------------------------------------------------------------------------------
   
   
   for I in 1..Num_Players loop
      Put_Score(Sockets(I), Game);  -- Update highscore
      while Server_Waiting /= '$' loop
	 Get(Sockets(I), Server_Waiting);
      end loop;
   end loop;
   
   
   --Efter spelets slut.
   
      DeleteList(Shot_List);
      DeleteList(Obstacle_List);
      DeleteList(Powerup_List);
      DeleteList(Astroid_List);
      DeleteList(Wall_List);
      
      for I in Waves'Range loop
	 DeleteList(Waves(I));
      end loop;
      
      if Check_Players_Choice(Players_Choice, 'E', Num_Players) then
	 for J in 1..Num_Players loop
	    Remove_Player(Sockets(J), J);
	 end loop;
	 exit;
      end if;
      
      
   end loop;
   
   new_Line;
   Put("Precis innan end!!");
exception
   when GNAT.SOCKETS.SOCKET_ERROR => 
      
      DeleteList(Shot_List);
      DeleteList(Obstacle_List);
      DeleteList(Powerup_List);
      DeleteList(Astroid_List);
      DeleteList(Wall_List);
      
      for I in Waves'Range loop
	 DeleteList(Waves(I));
      end loop;
      
      New_Line;
      Put("Someone disconnected!");
   when STORAGE_ERROR =>
      DeleteList(Shot_List);
      DeleteList(Obstacle_List);
      DeleteList(Powerup_List);
      DeleteList(Astroid_List);
      DeleteList(Wall_List);
      
      for I in Waves'Range loop
	 DeleteList(Waves(I));
      end loop;
      
      New_Line;
      Put("VI HAR EN MINNESLÄCKAA!");
      

end Server;

--gnatmake $(~TDDD11/TJa-lib/bin/tja_config)
