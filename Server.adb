
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
   
      type Shot_Type is
      record
	 XY     : XY_Type;
	 Active : Boolean;
      end record;
   
   type Shot_array is array (1 .. 5) of Shot_Type;
   
   type Ship_spec is 
      record
  	 XY      : XY_Type; 
  	 Lives   : Integer; 
  	 S       : Shot_Array; --??
      end record;
   
   type Enemy_Ship_Spec is
      record
	 XY                 : XY_Type;
	 Lives              : Integer;
	 Shot               : Shot_Array;
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
	 
	 for I in Shot_Array'Range loop
	    Put_Line(Socket,Ship.S(I).XY(1));
	    Put_Line(Socket,Ship.S(I).XY(2));
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
	    
	    
	    for J in Shot_Array'Range loop
	       Put_Line(Socket,Data.Wave(I).Shot(J).XY(1));
	       Put_Line(Socket,Data.Wave(I).Shot(J).XY(2));
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
			 Movement_Selector : in Integer) is
      
      X_Position : Integer;
      Spacing    : constant Integer := World_X_Length/(Num_Spawning+1);
      
   begin
      
      X_Position := 0;
      
      for I in 1..Num_Spawning loop -- måste eventuellt senare lagra startsiffran så vi inte skriver över gamla fiender som fortfarande lever!!
	 
	 Enemy_Ship_Array(I).Active            := True;-- aktiverar ett skepp på den här platsen i arrayen
	 Enemy_Ship_Array(I).Lives             := Num_Lives; -- ger den ett antal liv
	 Enemy_Ship_Array(I).Shot_Difficulty   := Shot_Difficulty; -- ger skeppet en gräns att passera för skott
	 Enemy_Ship_Array(I).Movement_Selector := Movement_Selector; -- ger ett rörelsemönster.
	 
	 
	 Enemy_Ship_Array(I).XY(2)             := 1; -- sätter start y-värdet till 1.  
	 Enemy_Ship_Array(I).XY(1)             := X_Position + Spacing;
	 
	 Enemy_Ship_Array(I).Direction_Selector := 1; --Gör så att alla skepp börjar åt höger, vet
						      -- inte hur vi ska lösa det snyggt // Tobias
	 
	 X_Position := X_Position + Spacing;
	 
      end loop;
      
   end Spawn_Wave;
   --------------------------------------------------
   
   --------------------------------------------------
   procedure Update_Enemy_Position(Loop_Counter : in Integer;
			           Ship         : in out Enemies;
				   Num_Enemies  : in Integer;
				   Direction    : in out Integer) is
      
      -- Movement_selector:
      -- 1) stand still
      -- 2) move from side to side
      -- 3) move forwards
      -- 4) move zigzag, classic space invaders
      -- 5) move in circles
      -- 6) move down and spread out on line
      -- etc.
      
      Chance_For_Alien_shot  : Generator;
      Alien_Shot_Probability : Integer;
      
      
   begin -- procedure som tar input och uppdaterar 
      
      if Loop_Counter mod 5 = 0 then -- FRÅGA MAGNUS!!
	 
      	 Reset(Chance_For_Alien_shot); -- resetar generatorn för finedeskeppens skott
	 
      end if;
      
      
      
      if Loop_Counter mod 2 = 0 then
	 

	 
	 --  for I in 1..Num_Enemies loop -- loopar igenom alla skepp
	    
	 --     if Ship(I).XY(2) < 30 then -- om skeppet har lågt y-värde (vid start) flyger det först ner till y=30
	       
	 --        Ship(I).XY(2) := Ship(I).XY(2) + 1;
	       
	 --     elsif Ship(I).XY(2) = World_Y_Length-1 then -- ta bort skeppet om det är på väg att lämna banan 
	 --        Ship(I).Active := False;

	 --     end if;
	    
	       
	 --        -- om movement_selector är 1 så står skeppet still, vilket innebär att koden här helt enkelt hoppas över.
	       
	 --     elsif Ship(I).Movement_Selector = 2 and Ship(I).Direction_Selector = 1 then -- sida till sida
	       
	 --        -- move right
	       
	 --        if Ship(I).XY(1) < (World_X_Length-1) then          
	 --  	  Ship(I).XY(1) := Ship(I).XY(1) + 1;                         
        
	 --        elsif Ship(I).XY(1) = (World_X_Length-1) then
	 --  	  Ship(I).Direction_Selector := 2;   
	 --        end if;

	 --     elsif Ship(I).Direction_Selector = 2 and Ship(I).Direction_Selector = 2 then 
	       
	 --        -- move left
	       
	 --        if Ship(I).XY(1) > 2  then -- funktion för var vänsterväggen finns ska läggas in istälet för 2:an
	 --  	  Ship(I).XY(1) := Ship(I).XY(1) -1;
		  
	 --        elsif Ship(I).XY(1) = 2 then
	 --  	  Ship(I).Direction_Selector := 1;   
	 --        end if;
	       
	       
	       ----------------------------------
	       -- MOVE DOWN UNIFORMLY
	       ----------------------------------
	       
	    --  elsif Ship(I).Movement_Selector = 3 then 
	       
	    --     Ship(I).XY(2) := Ship(I).XY(2) + 1;
	       
	       -----------------------------------
	       -- CLASSIC SPACE INVADERS MOVEMENT
	       -----------------------------------
	       
	   -- elsif Ship(I).Movement_Selector = 4 and Ship(I).Direction_Selector = 1 then
	 
	 
	 if Direction = 1 then
	    
	    -- move towards right wall.
	    
	    if Ship(Num_Enemies).XY(1) < (World_X_Length-1) then    -- skeppet längst till höger triggar      
	       
	       for J in 1..Num_Enemies loop -- för alla skepp
		  Ship(J).XY(1) := Ship(J).XY(1) + 1;                         
	       end loop;
	       
	       
	    elsif Ship(Num_Enemies).XY(1) = (World_X_Length-1) then 
	       
	       for K in 1..Num_Enemies loop -- för alla skepp
		  
		  Ship(K).XY(2) := Ship(K).XY(2) + 1; --flytta ner ett steg
						      -- Ship(K).Direction_Selector := 2;    -- byt riktning till vänster.
		  Direction := 2;
		  
	       end loop;
	       
	    end if;
	    

	    -- elsif Ship(I).Movement_Selector = 4 and Ship(I).Direction_Selector = 2 then	     

	 elsif Direction = 2 then
	    
	    -- move towards left wall.
	    
	    if Ship(1).XY(1) > 2 then -- samma här, byt ut mot funktion för världens gräns, vänster skepp bestämmer          
	       
	       for L in 1..Num_Enemies loop
		  Ship(L).XY(1) := Ship(L).XY(1) - 1;                         
	       end loop;
	       
	    elsif Ship(1).XY(1) = 2 then 
	       
	       for M in 1..Num_Enemies loop
		  Ship(M).XY(2) := Ship(M).XY(2) + 1; --flytta ner ett steg
						      -- Ship(M).Direction_Selector := 1;    -- byt riktning till höger
		  Direction := 1;
	       end loop;
	       
	    end if;
	    
	 end if;
	 
	    ------------------------------
	    --***
	    ------------------------------
	    
	    
	    
	    --------------------------------------------------
	    -- SHOT GENERATOR!!!
	    --------------------------------------------------
	    -- En gång per runda får varje skepp chansen att skjuta, styrs av denna random process.
	    
	    
	    Alien_Shot_Probability := Random(Chance_For_Alien_shot); -- 1-20
	    
	    --  New_Line(2);
	    --  Put(Alien_Shot_Probability, 0);
	    --  New_Line(2);
	    
	    for I in 1..Num_Enemies loop
	       
	       if Alien_Shot_Probability >= Ship(I).Shot_Difficulty then
		  
		  for M in 1..5 loop
		     
		     if Ship(I).Shot(M).Active = false then
			
			--  New_Line(2);
			--  Put("FIRE!");
			
			-- Ship(I).Shot(M).Active := True; -- skottet aktiveras -- kommenteras ut tills vi får en mekanism för att sätta dem till inaktiva.
			-- Ship(I).Shot(M).XY     := (Ship(I).XY(1), Ship(I).XY(2)+ 1); -- skottet får samma koordinat som skeppet, men y +1.
			exit;
		     end if;
		  end loop;
		  
		  
	       end if;
	    end loop;
	    
	       --------------------------------------------------
	       --***
	       --------------------------------------------------
	       
	       for N in 1..Num_Enemies loop
		  
		  New_Line;
		  Put("Ship no. ");
		  Put(N, 0);
		  Put(".      ");
		  Put("X: ");
		  Put(Ship(N).XY(1),0);
		  Put("    Y:  ");
		  Put(Ship(N).XY(2),0);
		  
	       end loop;
	    
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
	       Data.Players(I).Ship.XY(2) := Integer'Max(1 , Data.Players(I).Ship.XY(2) - 1);
	    elsif Keyboard_Input = 's' then 
	       Data.Players(I).Ship.XY(2) := Integer'Min(World_Y_Length , Data.Players(I).Ship.XY(2) + 1);
	    elsif Keyboard_Input = 'a' then
	       Data.Players(I).Ship.XY(1) := Integer'Max(1 ,  Data.Players(I).Ship.XY(1) - 1);
	    elsif Keyboard_Input = 'd' then 
	       Data.Players(I).Ship.XY(1) := Integer'Min(World_X_Length , Data.Players(I).Ship.XY(1) + 1);
	    elsif Keyboard_input = ' ' then 
	       Data.Players(I).Playing := False;
	       
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
      Chance_For_Alien_Shot : Generator; -- /Tobias
      
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
      
      --------------------------------------------------
      -- Enemies
      --------------------------------------------------
      
      for L in Enemies'Range loop --settar alla fienders status till inaktiv i början.
      
	 Game.Wave(L).Active         := False;
	 
	 for M in 1..5 loop
	 Game.Wave(L).Shot(M).Active := False; -- sätter skotten till inaktiva.
	 end loop;
	 
	 
      end loop;
      
      Reset(Chance_For_Alien_shot); -- resetar generatorn för finedeskeppens skott
      
 
      
   end Set_Default_Values;

   ----------------------------------------------------------------------------------------------------
   --|
   --| DECLARATIONS
   --|
   ----------------------------------------------------------------------------------------------------				 
   Num_Players                        : Integer;
   
   Game                   : Game_Data;
   Loop_Counter           : Integer;

   Alien_Shot_Probability : Integer;
   Num_To_Spawn           : Integer;
   Num_Lives              : Integer;
   Shot_Difficulty        : Integer;
   Movement_Selector      : Integer;
   First_Wave_Limit       : constant Integer := 10;
   Second_Wave_Limit      : Integer;
   Direction              : Integer;

begin
   

   
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
   
   Direction := 1; --tillfälligt för att röreslerna ska fungera tills jag tänkt ut det bättre // Tobias
   
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
      
      
       if Loop_Counter = First_Wave_Limit then                             -- Vid vissa tidpunkter spawnas
      Num_To_Spawn := 6;  	 
      Spawn_Wave(Num_To_Spawn, Game.Wave, 3, 10, 4);      
      --  	 -- nya fiendewaves som rör sig på olika
      --  	 -- sätt och skjuter olika mycket och
      --  elsif Loop_Counter = Second_Wave_Limit then                         -- är olika svåra att döda. / Tobias
      --  	 Spawn_Wave(Num_To_Spawn, Game.Wave, Num_Lives, Shot_Difficulty, Movement_selector);
      
      end if; -- osv
      
      
      for I in Enemies'Range loop
	 
       	 if Game.Wave(I).Active = true  then -- bara om det finns levande skepp.
	    
	    Update_Enemy_position(Loop_counter, Game.Wave, 6, Direction); --/ Tobias 6:an har med 6:an ovan att göra.
	                                                          -- 1:an är riktning.
	    exit;
	 end if;
	 
      end loop;

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
