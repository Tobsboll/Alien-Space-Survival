package body Task_Printer is
   
   task body Print_all is
      
      Data          : Game_Data;
      Waves         : Enemy_List_array;
      Astroid_List  : Object_List;
      Shot_List     : Object_List;
      Obstacle_List : Object_List;
      Powerup_List  : Object_List;
      NumPlayers    : Integer;
      Klient_Number : Integer;
      Level         : Integer;
      Loop_Counter  : Integer;
      Choice        : Character := 'o';
      Stop_Task     : Boolean := False;
      
   begin
      loop
	 select
	    accept Print_Everything(D  : in Game_Data;
				    W  : in Enemy_List_array;
				    P  : in Object_List;
				    A  : in Object_List;
				    O  : in Object_List;
				    S  : in Object_List;
				    N  : in Integer;
				    K  : in Integer;
				    L  : in Integer;
				    LC : in Integer) do
	       
	       Data          := D;
	       Waves         := W;
	       Astroid_List  := A;
	       Shot_List     := S;
	       Obstacle_List := O;
	       Powerup_List  := P;
	       NumPlayers    := N;
	       Klient_Number := K;
	       Level         := L;
	       Loop_Counter := LC;
	       
	    end Print_Everything;
	    
	    Put_All(Data, Waves, Powerup_List, Astroid_List, Obstacle_List, Shot_List, NumPlayers, Klient_Number, Level, Loop_Counter, Choice);
	    
	 or
	    accept Get_Choice(C : out Character) do 
	       
	       C := Choice;
	       
	    end Get_Choice;
	 or
	    accept Stop do
	       Stop_Task := True;
	    end Stop;
	 end select;
	 
	 exit when Stop_Task;
      end loop;
       
   end Print_all;
   
end Task_Printer;
