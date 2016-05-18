
package body Score_Handling is
   
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
   
   
   package Seq_IO is new Ada.Sequential_IO(Player_Type);
   use Seq_IO;
   
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
   
   procedure Put_Highscore(X     : in Integer;
			   Y     : in Integer;
			   Total : in Integer) is
      
      F1           : Seq_IO.File_Type;
      Saved_Player : Player_Type;
      Counter      : Integer := 1;
      
   begin
      Goto_XY(X,Y);
      Put("          HIGHSCORE            ");
      Goto_XY(X,Y+2);
      Put("Pos     Name              Score");
      if Does_File_Exist("HIGHSCORE.BIN") then
	 Open(F1, In_File, "HIGHSCORE.BIN");
	 
	 while not End_Of_File(F1) and Total > Counter loop
	    
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
	 Put("No Highscore yet!");
      end if;
   end Put_Highscore;
   
end Score_Handling;
