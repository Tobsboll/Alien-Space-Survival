package body Task_Server_Communication is
   
   task body Send_Data_To_Player is
      
      Soc        : Socket_Type;
      A, S, O, P : Object_List;
      G          : Game_Data;
      W          : Enemy_List_Array;      
      
   begin
      loop
	 accept Send_Data(Socket        : in Socket_Type;
			  Astroid_List  : in Object_List;
			  Shot_List     : in Object_List;
			  Obstacle_List : in Object_List;
			  Powerup_List  : in Object_List;
			  Game          : in Game_Data;
			  Waves         : in Enemy_List_Array) do
	    
	    Soc := Socket;
	    A   := Astroid_List;
	    S   := Shot_List;
	    O   := Obstacle_List;
	    P   := Powerup_List;
	    G   := Game;
	    W   := Waves;
	    
	 end Send_Data;
	 
	 Put(Soc, A);
	 Put(Soc, S);
	 Put(Soc, O);
	 Put(Soc, P);
	 Send_Map(Soc, G);      -- Map_Handling
	 Put_Game_Data(Soc, G);
	 
	 for J in W'Range loop
	    Put_Enemy_ships(W(J), Soc);
	 end loop;      
	 
	 -- Game Over Check
	 Put_line(Soc, G.Settings.Gameover);
	 
      end loop;
   end Send_Data_To_Player;
   
   
end Task_Server_Communication;
