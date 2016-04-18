
with TJa.Keyboard;                 use TJa.Keyboard;
with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;
with Ada.Command_Line;             use Ada.Command_Line;
with TJa.Sockets;                  use TJa.Sockets;
with Ada.Numerics.Discrete_Random; 
with Space_Map;


procedure Server is
   
   
   --------------------------------------------------
   --Tobias randomgenerator för fiendeskepp
   --------------------------------------------------
   subtype One_To_Twenty is Integer range 1..20;
   
   
   package One_To_Twenty_Random is
      new Ada.Numerics.Discrete_Random(Result_Subtype => One_To_Twenty);
   use One_To_Twenty_Random;
   
   
   --------------------------------------------------
   -- Slut
   --------------------------------------------------
   
   
   
   type Socket_Array is
     array (1..4) of Socket_Type;
   
   Socket1, Socket2, Socket3, Socket4 : Socket_Type;
   Sockets : Socket_Array             := (Socket1, Socket2, Socket3, Socket4);
   Listener                           : Listener_Type;
   --   Num_Players                        : Integer;
   Keyboard_Input                     : Character;
   
   --Flyttade variablerna till declarations längre ner        OBS!
   
   --------------------------------------------------
   World_X_Length : constant Integer := 62;
   World_Y_Length : constant Integer := 30;
   
   -- Paket som hanterar banan.
   package Bana is
      new Space_map(X_Width => World_X_Length,
		    Y_Height => World_Y_Length);
   use Bana;
   
   --   type X_Led is array(1 .. World_X_Length) of Character;
   --   type World is array(1 .. World_Y_Length) of X_Led;
   
   type XY_Type is array(1 .. 2) of Integer;
   type Shot_Type is array (1 .. 5) of XY_Type;
   
   type Ship_spec is 
      record
  	 XY      : XY_Type; 
  	 Lives   : Integer; 
  	 S       : Shot_Type; --??
      end record;
   
   type Enemy_Ship_Spec is
      record
	 XY                 : XY_Type;
	 Lives              : Integer;
	 Shot               : Shot_Type;
	 Shot_Difficulty    : Integer;
	 Movement_Selector  : Integer; -- så att jag kan hålla koll på vad varje skepp har för rörelsemönster
	                               --, då kan vi ha olika typer av fiender på skärmen samtidigt.
	 Direction_Selector : Integer; -- kanske inte behövs, men håller i nuläget koll på om skeppet är på väg
	                               -- åt höger eller vänster.
	 Active             : Boolean;  
      end record;
   
   
   type Player_Type is
      record
  	 Playing    : Boolean;
  	 Name       : String(1..24);
  	 NameLength : Integer;
  	 Ship       : Ship_Spec;
  	 Score      : Integer;
      end record;
   
   type Player_Array is array (1..4) of Player_Type;   
   
   type Enemies is array (1 .. 50) of Enemy_Ship_Spec;
   
   type Game_Data is
      record
  	 Layout   : World;          -- Banan är i packetet så att både klienten och servern 
	                            -- hanterar samma datatyp / Eric
  	 Players  : Player_Array;   -- Underlättade informationsöverföringen mellan klient och server. / Eric
  	 Wave     : Enemies;
      end record; 
   --------------------------------------------------
   
   
   
   
   ---------------------------------------------------------------
   -- Skickar all Spelinformation till klienterna. / Eric
   ----------------------------------------------------------------
   procedure Put_Game_Data(Socket : Socket_Type;
		           Data : in Game_Data) is
      
      
      -- Skickar spelarens skeppdata    
      -------------------------------------------------
      procedure Put_Ship_Data(Socket : in Socket_Type;
			      Ship   : in Ship_Spec) is
      begin
	 
	 Put_Line(Socket,Ship.XY(1));
	 Put_Line(Socket,Ship.XY(2));
	 Put_Line(Socket,Ship.Lives);
	 
	 for I in Shot_Type'Range loop
	    Put_Line(Socket,Ship.S(I)(1));
	    Put_Line(Socket,Ship.S(I)(2));
	 end loop;
	 
      end Put_Ship_Data;
      -------------------------------------------------
      
      
   begin
      -- Skickar Banan till klienterna
      for I in World'Range loop
	 for J in X_Led'Range loop
	    Put_line(Socket, Data.Layout(I)(J));
	 end loop;
      end loop;
      
      
      --------------------------------------------------------
      -- Skickar spelarnas Information
      --------------------------------------------------------
      for I in Player_Array'Range loop
	 -- Skickar om spelaren spelar eller inte.
	 if Data.Players(I).Playing = True then
	    
	    Put_Line(Socket,1);
	    
	    
	    -- Skickar Spelarens namn
	    Put_Line(Socket,Data.Players(I).Name(1..Data.Players(I).NameLength) );
	    
	    
	    -- Skickar spelarens skeppdata
	    Put_Ship_Data(Socket,Data.Players(I).Ship);
	    
	    
	    -- Skickar spelarens poäng
	    Put_Line(Socket,Data.Players(I).Score);
	    
	    
	    -- Skickar inget mer om spelaren inte spelar.
	 elsif Data.Players(I).Playing = False then
	    Put_Line(Socket,0);
	 end if;

      end loop;
      
      
      ---------------------------------------------------------
      -- Skickar Fiende vågen
      ----------------------------------------------------------
      for I in Enemies'Range loop
	 if Data.Wave(I).Active = True then
	    
	    Put_Line(Socket, 1);
	    
	    Put_Line(Socket,Data.Wave(I).XY(1));
	    Put_Line(Socket,Data.Wave(I).XY(2));
	    
	    Put_Line(Socket,Data.Wave(I).Lives);    -- Kanske inte behövs skicka/ta emot
	    
	    
	    for J in Shot_Type'Range loop
	       Put_Line(Socket,Data.Wave(I).Shot(J)(1));
	       Put_Line(Socket,Data.Wave(I).Shot(J)(2));
	    end loop;
	    
	    Put_Line(Socket, Data.Wave(I).Movement_Selector);    -- Kanske inte behövs skicka/ta emot
	    Put_Line(Socket, Data.Wave(I).Direction_Selector);    -- Kanske inte behövs skicka/ta emot
	    
	 elsif Data.Wave(I).Active = False then
	    
	    Put_Line(Socket, 0);
	    
	 end if;
      end loop;
      
      
   end Put_Game_Data;
   --------------------------------------------------
   
   --------------------------------------------------
   
   --------------------------------------------------
   procedure Add_Player(Listener : in Listener_Type;
			Socket   : in out Socket_Type;
		        Player_Num : in integer) is
      
   begin
      
      Wait_For_Connection(Listener, Socket);
      
      Put("Player ");
      Put(Player_Num, 0);
      Put(" joined the game.");
      New_Line;
      
   end Add_Player;
   --------------------------------------------------
   
   --------------------------------------------------
   procedure Remove_Player(Socket     : in out Socket_Type; 
			   Player_Num : in Integer) is
      
   begin
      
      Close(Socket);
      
      New_Line;
      Put("Player ");
      Put(Player_Num, 0);
      Put(" has left the game");
      
      
   end Remove_Player;
   --------------------------------------------------
   
   --------------------------------------------------
   function Active_Ship(Enemy_Ship : Enemy_Ship_spec) return Boolean is
      
   begin
      
      return Enemy_Ship.Active;
      
   end Active_Ship;
   --------------------------------------------------
   
   --------------------------------------------------
   procedure  Spawn_Wave(Num_Spawning      : in Integer;
			 Enemy_Ship_Array  : in out Enemies;
			 Num_Lives         : in Integer;
			 Shot_Difficulty   : in Integer;
			 Movement_Selector : in Integer;
			 Start_Position    : in Enemy_Spawn_Points) is
      
   begin
      
      for I in 1..Num_Spawning loop -- måste eventuellt senare lagra startsiffran så vi inte skriver över gamla fiender som fortfarande lever!!
	 
	 Enemy_Ship_Array(I).Active            := True; -- aktiverar ett skepp på den här platsen i arrayen
	 Enemy_Ship_Array(I).Lives             := Num_Lives; -- ger den ett antal liv
	 Enemy_Ship_Array(I).Shot_Difficulty   := Shot_Difficulty; -- ger skeppet en gräns att passera för skott
	 Enemy_Ship_Array(I).Movement_Selector := Movement_Selector; -- ger ett rörelsemönster.
	 
	 Enemy_Ship_Array(I).XY                := Start_Position(I); -- detta kan nog göras bättre, 
	                                                             -- ger en spawnpoint ur en array.
	                                                             -- det ger oss ganska lite kontroll.
	 Enemy_Ship_Array(I).Direction_Selector := 1; --Gör så att alla skepp börjar åt höger, vet
	                                              -- inte hur vi ska lösa det snyggt // Tobias
	 
      end loop;
     
   end Spawn_Wave;
   --------------------------------------------------
   
   --------------------------------------------------
   procedure Update_Enemy_Position(Loop_Counter : in Integer;
			           Ship         : in out Enemy_Ship_Spec) is
      
      -- Movement_selector:
      -- 1) stand still
      -- 2) move from side to side
      -- 3) move forwards
      -- 4) move zigzag forwards
      -- 5) move in circles
      -- 6) move down and spread out on line
      -- etc.
      
      Start_Position : constant XY_Type := (30,10);
      
   begin -- procedure som tar input och uppdaterar 
      
      
      if Loop_Counter = 0 then -- första gången spawnar skeppet på en angiven startposition.
	                       -- Kan senare ersättas med en startanimation att de flyger ner från
	                       -- toppen eller liknande.
	 
	 Ship.XY := Start_Position;
	 
      end if;
      
      
      -- om movement_selector är 1 så står skeppet still, vilket innebär att koden här helt enkelt hoppas över.
      
      if Ship.XY(2) = World_Y_Length-1 then -- ta bort skeppet om det är på väg att lämna banan 
	 Ship.Active := False;
      end if;
      
      
      if Ship.Movement_Selector = 2 then -- sida till sida
	 
	 if Ship.Direction_Selector = 1 then -- move right
	    
	    if Ship.XY(1) < (World_X_Length-1) then                  -- här måste sannolikt delay läggas
               Ship.XY(1) := Ship.XY(1) + 1;                         -- in, typ if Loop_Counter mod 5 = 0
	                                                             -- eller liknande
	    elsif Ship.XY(1) = (World_X_Length-1) then
	       Ship.Direction_Selector := 2;   
	    end if;
	    
	 elsif Ship.Direction_Selector = 2 then -- move left
	    
	    if Ship.XY(1) > 1  then
               Ship.XY(1) := Ship.XY(1) -1;
	       
	    elsif Ship.XY(1) = 1 then
	       Ship.Direction_Selector := 1;   
	    end if;
	    
	 end if;
      end if;
      
      
      
      if Ship.Movement_Selector = 3 then
	 
	 Ship.XY(2) := Ship.XY(2) + 1;
	 
      end if;
      
      
      
      
      
      
   end Update_Enemy_position;
   --------------------------------------------------
   
   --------------------------------------------------
   procedure Enemy_Shots(Shot_Probability : in One_To_Twenty;
			 Enemy_Ship  : in out Enemy_Ship_spec) is
      
   begin -- ska sköta uppdateringen av skeppens koordinater.
      
      null;
      
   end Enemy_Shots;
   --------------------------------------------------
   
   --------------------------------------------------
   procedure Get_Player_Input(Sockets : in Socket_Array;
			      Num_Players : in Integer; --Num_Players ej längre global
			      Data : in out Game_Data
			     ) is
      
   begin
      
      for I in 1..Num_Players loop
	 
	 Get(Sockets(I), Keyboard_Input); -- får alltid något, minst ett 'o'
	 Skip_Line(Sockets(I)); -- DETTA kan bli problem om server går långsammare än klienterna!! /Andreas
	 
	 if Keyboard_Input /= 'o' then -- = om det fanns nollskild, giltig input.        
	    
	    
	    if Keyboard_Input = 'w' then 
	       Data.Players(I).Ship.XY(2) := Data.Players(I).Ship.XY(2) - 1;
	    elsif Keyboard_Input = 's' then 
	       Data.Players(I).Ship.XY(2) := Data.Players(I).Ship.XY(2) + 1;
	    elsif Keyboard_Input = 'a' then
	       Data.Players(I).Ship.XY(1) := Data.Players(I).Ship.XY(1) - 1;
	    elsif Keyboard_Input = 'd' then 
	       Data.Players(I).Ship.XY(1) := Data.Players(I).Ship.XY(1) + 1;
	       -- elsif Keyboard_input = ' ' then Put("Fire"); 	                          NOOO SHOTING MAN..
	       
	    elsif Keyboard_Input = 'e' then exit; -- betyder "ingen input" för servern.
	    end if;
	 end if;
	 
      end loop;
      
   end Get_Player_Input;
   
   
   --------------------------------------------------
   --|  DEFAULT VALUES
   --------------------------------------------------
   procedure Set_Default_Values (Num_Players : in Integer;
				 Game        : in out Game_Data
				   --World_X_Length, World_Y_Length : in Integer   --GLOBALA VARIABLER
				) is
      Xpos : Integer;
      Interval : constant Integer := World_X_Length/(1+Num_Players);
   begin
      --------------------------------------------------
      --| Ships
      --------------------------------------------------
      Xpos := 0;
      
      for K in 1..Num_Players loop
	 Game.Players(K).Ship.XY(2) := World_Y_Length - 1;  -- + border_Length
	 Game.Players(K).Ship.XY(1) := Xpos + Interval; -- + border_Length;
	 Game.Players(K).Playing := True; 
	 Xpos := Xpos + Interval;
      end loop;
      
   end Set_Default_Values;

   ----------------------------------------------------------------------------------------------------
   --|
   --| DECLARATIONS
   --|
   ----------------------------------------------------------------------------------------------------				 
   Num_Players                        : Integer;
   
   Game                   : Game_Data;
   Loop_Counter           : Integer;
   Chance_For_Alien_shot  : Generator;
   Alien_Shot_Probability : Integer;
   Num_To_Spawn           : Integer;
   Num_Lives              : Integer;
   Shot_Difficulty        : Integer;
   Movement_Selector      : Integer;
   First_Wave_Limit       : Integer;
   Second_Wave_Limit      : Integer;
   
begin
   
   Reset(Chance_For_Alien_shot); -- resetar generatorn för finedeskeppens
   
   -- "öppna dörren". För tillfället endast lokalt, ändra sedan.
   Initiate(Listener, Integer'Value(Argument(1)), Localhost => true);
   
   Put_Line("Servern är igång, väntar på connection");
   
   --------------------------------------------------
   --PLAYER SETUP
   --------------------------------------------------
   
   -- vänta på spelare 1
   Add_Player(Listener, Sockets(1), 1);
   Get(Sockets(1), Num_Players); -- spelare 1 bestämmer hur många som ska spela.
   Put_line("Waiting for players...");
   
   -- lägg till wait_for_connections för så många spelare som angetts!
   for I in 2..Num_Players loop
      Add_Player(Listener, Sockets(I), I);
   end loop;
   
   New_Line;
   Put("All players have joined the game.");
   
   
   -- Skicka ut ett tecken till alla klienterna, så att de slutar vänta och börjar sin loop.
   for J in 1..Num_Players loop
      Put_Line(Sockets(J), Num_Players);
   end loop;
   
   Put("Spelet är igång!");
   --------------------------------------------------
   --------------------------------------------------
   
   
   -- Skip_Line;
   
   
   
   
   ----------------------------------------------------------------------------------------------------
   --|
   --| Game loop
   --|
   ----------------------------------------------------------------------------------------------------
   
   Set_Default_Values(Num_Players, Game);
   
   
   Loop_Counter := 0;
   
   Generate_World(Game.Layout);  -- Genererar en helt ny bana med raka väggar. / Eric
   
   Set_Buffer_Mode(Off);
   Set_Echo_Mode(Off);
   
   loop 
      
      
      
      --  for I in 1..Num_Players loop
      --  	 Put_Line(Sockets(I),Loop_Counter);  -- Skickar Serverns loop_Count till klienterna / Eric
      --  end loop;
      

      
      delay(0.01);      -- En delay så att servern inte fyller socket bufferten till klienterna. / Eric
      
      
      --------------------------------------------------
      --| SCROLLING MAP 
      --| "Level 2" => därför ej nödvändig än
      --------------------------------------------------
      --  if Loop_Counter mod 4 = 0 then
      --  	 New_Top_Row(Game.Layout);          -- Genererar två nya väggar längst upp på banan på var sida.
      --  	 Move_Rows_Down(Game.Layout);       -- Flyttar ner hela banan ett steg.
      --  end if;
      

      
      --      Print_Player_Input(Sockets); -- för test av input   -- Funkar inte än / Eric
      
      --update world /Andreas  // Fanns med i packetet som jag gjorde tidigare, 
      --  det är dom två procedurerna "New_Top_Row" & "Move_Rows_Down" / Eric
      --update ship /andreas
      
      
      --  if Loop_Counter = First_Wave_Limit then                             -- Vid vissa tidpunkter spawnas
      --  	 Spawn_Wave(Num_To_Spawn, Game.Wave, Num_Lives, Shot_Difficulty, Movement_selector);      
      --  	 -- nya fiendewaves som rör sig på olika
      --  	 -- sätt och skjuter olika mycket och
      --  elsif Loop_Counter = Second_Wave_Limit then                         -- är olika svåra att döda. / Tobias
      --  	 Spawn_Wave(Num_To_Spawn, Game.Wave, Num_Lives, Shot_Difficulty, Movement_selector);
      
      --  end if; -- osv
      
      
      --  for I in Enemies'Range loop
      --  	 -- för varje skepp i hela vågen
      
      --  	 if Active_Ship(Game.Wave(I)) then -- om det finns ett aktivt skepp på den här platsen
      --  					   -- i arrayen med fiendeskepp.
      
      --  	    Update_Enemy_position(Loop_counter, Game.Wave(I)); --/ Tobias
      
      --  	    Alien_Shot_Probability := Random(Chance_For_Alien_shot); --ska räkna ut sannolikheten
      --  								     -- för att en alien skjuter / Tobias
      
      --  	    --  Enemy_Shots(Alien_Shot_Probability, Game.Wave(I)); -- uppdaterar skott /Tobias
      
      --  	 end if;

      
      --  end loop;

      -- Hitbox_Procedure/compare_coordinates_procedure i en for loop för alla skepp/skott    //Andreas
      
      -- Skickar information till klienterna. / Eric
      
      
      for I in 1..Num_Players loop
	 Put_Game_Data(Sockets(I),Game);
      end loop;
      
      Get_Player_Input(Sockets, Num_Players, Game);

      
      Loop_Counter := Loop_Counter + 1;
      
   end loop;
   
   ----------------------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------GAME LOOP END----
   ----------------------------------------------------------------------------------------------------
   
   --Efter spelets slut.
   
   for I in 1..Num_Players loop
      
      Remove_Player(Sockets(I), I);
      
   end loop; 
   

end Server;

--gnatmake $(~TDDD11/TJa-lib/bin/tja_config)