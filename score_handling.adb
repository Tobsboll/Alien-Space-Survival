
package body Score_Handling is
   
   -------------------------------------------------------------------------------------
   
   procedure Swap(A, B : in out Integer) is
      
      C : Integer := A;
      
   begin
      A := B;
      B := C;
   end Swap;
   -------------------------------------------------------------------------------------
   procedure Sort_Scoreboard(Game : in out Game_Data;
			     Num_Players : in Integer) is
      
   begin 
      
      if Num_Players > 1 then
	 for I in reverse 2..Num_Players loop
	    for J in Game.Ranking'Range loop
	       if Game.Players(  Game.Ranking(I-1)  ).Score < Game.Players(  Game.Ranking(I)  ).Score then
		  Swap (Game.Ranking(I-1),Game.Ranking(I));
	       end if;
	    end loop;
	 end loop;
      end if;
      
   end Sort_Scoreboard;
   -------------------------------------------------------------------------------------
    procedure Put_Score(Data        : in Game_Data; 
		       NumPlayers  : in Integer;
		       X           : in Integer;
		       Y           : in Integer;
		       Back_Colour : in Colour_Type;
		       Text_Colour : in Colour_Type) is
      
      Old_Background  : Colour_Type;
      Old_Text_Colour : Colour_Type;
      
   begin
      Old_Text_Colour := Get_Foreground_Colour;           -- Sparar den tidigare textfärgen
      Old_Background  := Get_Background_Colour;           -- Sparar den tidigare bakgrundsfärgen
      Set_Background_Colour(Back_Colour);
      Goto_XY(X+2,Y);	 
      Set_Text_Modes(On,Off,Off);  -- Understreck på utskriften
      Put("Nickname");
      Goto_XY(X+13,Y);
      Put(" Health  ");
      Goto_XY(X+25,Y);
      Put("Score");
      Set_Text_Modes(Off,Off,Off); -- Återställer utskrift inställningarna
      
      for I in 1 .. NumPlayers loop
	 Goto_XY(X,Y+I);
	 Put(I, Width => 0);       -- Skriver ut placeringen
	 Put('.');
         Set_Foreground_Colour(Data.Players( Data.Ranking(I) ).Colour);                       -- Ställer in Spelarens färg.
	 Set_Text_Modes(Off,Off,On);  -- Fet stil på utskriften
	 Put(Data.Players( Data.Ranking(I) ).Name( 1..Data.Players( Data.Ranking(I) ).NameLength)); -- Skriver ut spelarens namn.
	 
	 Set_Foreground_Colour(Red);                             -- Ställer in färgen på hjärtan.
	 Goto_XY(X+13,Y+I);
	 
	 if Data.Players( Data.Ranking(I) ).Ship.Health < 1 then            -- Om död.
	    Put("R.I.P.");
	    
	 elsif Data.Players( Data.Ranking(I) ).Ship.Health > 0 then         -- annars lever
	    
	    for J in 1 .. Data.Players( Data.Ranking(I) ).Ship.Health loop
	       if J = Data.Players( Data.Ranking(I) ).Ship.Health and J mod 2 = 1 then
		  Set_Foreground_Colour(Dark_Grey);
		  Put("♥ ");                                -- Ställer in färgen på hjärtan.
	       else
		  if J mod 2 = 0 then
		     Set_Foreground_Colour(Red);                             -- Ställer in färgen på hjärtan.
		     Put("♥ ");   
		  end if;
	       end if;                                            -- Antal liv
	    end loop;
	 end if;
	 Set_Text_Modes(Off,Off,Off);
	 Set_Foreground_Colour(Old_Text_Colour);                    -- Ställer tillbaka till text färgen.
	 Goto_XY(X+25,Y+I);
	 Put(Data.Players( Data.Ranking(I) ).Score, Width => 5);    -- skriver ut spelarens poäng
	 Set_BackGround_Colour(Old_Background);                     -- Ställer tillbaka till bakgrunds färgen.
      end loop;
   end Put_Score;
   -------------------------------------------------------------------------------------
   
   function Does_File_Exist (Name : in String) return Boolean is
      
      F0 : File_Type;

   begin
      Open (F0,In_File,Name);
      Close (F0);
      return True;
   exception
      when Name_Error =>
         return False;
   end Does_File_Exist;
   
   -------------------------------------------------------------------------------------
   
   package Seq_IO is new Ada.Sequential_IO(Player_Type);
   use Seq_IO;
   
   -------------------------------------------------------------------------------------
   procedure Save_Score(Player : in Player_Type) is
      
      Filename     : String(1..13)  :="HIGHSCORE.BIN";
      F1, F2       : Seq_IO.File_Type;
      Saved_Player : Player_Type;
      Player_Saved : Boolean := False;
      
   begin
      
      if Does_File_Exist(Filename) then
	  Open(F1, In_File, Filename);
	 
	 if Does_File_Exist("TEMP.Bin") then
	     Open(F2, Out_File, "TEMP.Bin");
	 else
	     Create(F2, Out_File, "TEMP.Bin");
	 end if;
	 
	 while not End_Of_File(F1) loop      
	    Read(F1, Saved_Player);
	    
	    if Saved_Player.Score >= Player.Score or Player_Saved then
	       Write(F2, Saved_Player);
	    elsif Saved_Player.Name /= Player.Name then
	       Write(F2, Player);
	       Write(F2, Saved_Player);
	       Player_Saved := True;
	    else
	       Write(F2, Saved_Player);
	       Player_Saved := True;
	    end if;
	    
	 end loop;	 
	 
	 if not Player_Saved then -- If lowest score
	    Write(F2, Player);
	 end if;
	 
	 Reset(F1, Out_File);
	 Reset(F2, In_File);
	 
	 while not End_Of_File(F2) loop
	    Read(F2, Saved_Player);
	    Write(F1, Saved_Player);
	 end loop;
	 
	 Delete(F2);
	 
	 
      else
	 Create(F1, Out_File, Filename);
	 Write(F1, Player);
      end if;
      
      Close(F1);
      
   end Save_Score;
   
   -------------------------------------------------------------------------------------
   procedure Put_Highscore(X     : in Integer;
			   Y     : in Integer;
			   Total : in Integer) is
      
      F1           : Seq_IO.File_Type;
      Saved_Player : Player_Type;
      Counter      : Integer := 1;
      
   begin
      Set_Bold_Mode(On);
      Goto_XY(X,Y);
      Put("           HIGHSCORE            ");
      Goto_XY(X,Y+2);
      Set_Underlined_Mode(On);
      Put("Pos     Name              Score");
      Set_Underlined_Mode(Off);
      
      if Does_File_Exist("HIGHSCORE.BIN") then
	 Open(F1, In_File, "HIGHSCORE.BIN");
	 
	 while not End_Of_File(F1) and Total >= Counter loop
	    
	    Read(F1, Saved_Player);
	    
	    Goto_XY(X,Y+2+Counter);
	    Put("Nr.");
	    Put(Counter, Width => 1);
	    Goto_XY(X+8, Y+2+Counter);
	    Put(Saved_Player.Name(1..Saved_Player.Namelength));
	    Goto_XY(X+27, Y+2+Counter);
	    Put(Saved_Player.Score, Width => 4);
	    
	    Counter := Counter + 1;
	 end loop;
	 
	 Close(F1);
	 
      else
	 Goto_XY(X,Y+6);
	 Put("         No Highscore    ");
	 Goto_XY(X,Y+7);
	 Put("              or          ");
	 Goto_XY(X,Y+8);
	 Put("    You havent played yet!");
      end if;
      Set_Bold_Mode(Off);
   end Put_Highscore;
   
   
   
   
   -------------------------------------------------------------------------------------
   procedure Put_Score( Socket : in Socket_Type;
			Game   : in Game_Data) is
      
      F1           : Seq_IO.File_Type;
      Saved_Player : Player_Type;
      Count        : Integer := 1;
      
   begin
      if Does_File_Exist("HIGHSCORE.BIN") then
	 Open(F1, In_File, "HIGHSCORE.BIN");
	 
	 while not End_Of_File(F1) loop
	    Read(F1, Saved_Player);
	    Put(Socket, 'N');    -- New
	    Put_Line(Socket, Saved_Player.Name(1..Saved_Player.NameLength));
	    Put(Socket, Saved_Player.Score);
	    Count := Count + 1;
	 end loop;
	 
	 Close(F1);
	 
      end if;
      
      Put(Socket, 'Q');  -- quit
      
   end Put_Score;
   
   -------------------------------------------------------------------------------------
   procedure Get_Score(Socket : in Socket_Type) is
      
      F1           : Seq_IO.File_Type;
      Saved_Player : Player_Type;
      Check        : Character;
      
   begin
      if Does_File_Exist("HIGHSCORE.BIN") then
	 Open(F1, Out_File, "HIGHSCORE.BIN");
      else
	 Create(F1, Out_File, "HIGHSCORE.BIN");
      end if;
      
      loop
	 Check := 'a';
	 while Check /= 'Q' and Check /='N' loop  -- Quit/New
	    Get(Socket, Check);
	 end loop;
	 
	 exit when Check = 'Q';  -- Quit
	 
	 if Check = 'N' then     -- New
	    Get_Line(Socket, Saved_Player.Name, Saved_Player.NameLength);
	    Get(Socket, Saved_Player.Score);
	    
	    Write(F1, Saved_Player);
	 end if;
	 
	 
      end loop;
	 
      Close(F1);
   end Get_Score;
   -------------------------------------------------------------------------------------
   
end Score_Handling;
