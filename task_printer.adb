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
      Gameover      : Integer;
      Choice        : Character;
      
   begin
      loop
	 select
	    accept Print_Everything(D  : in Game_Data;
				    W  : in Enemy_List_array;
				    A  : in Object_List;
				    S  : in Object_List;
				    O  : in Object_List;
				    P  : in Object_List;
				    N  : in Integer;
				    G  : in Integer;
				    K  : in Integer;
				    C  : in Character) do
	       
	       Data          := D;
	       Waves         := W;
	       Astroid_List  := A;
	       Shot_List     := S;
	       Obstacle_List := O;
	       Powerup_List  := P;
	       NumPlayers    := N;
	       Klient_Number := K;
	       Gameover      := G;
	       Choice        := C;
	       
	    end Print_Everything;
	    Clear_Window;
	    Set_Echo(Off);
	    
	    Put_Player_Ships(Data, NumPlayers);
	    
	    for I in Waves'range loop
	       Put_Objects(Waves(I));
	    end loop;
	    
	    Astroid.Print(Astroid_List);
	    Shot.Print(Shot_List);
	    Obstacle.Print(Obstacle_List);
	    Powerup.Print(Powerup_List);
	    
	    if Background then
	       Put_Background(NumPlayers);
	    end if;
	    
	    -------------------------------------------------
	    --| Highscore fönster
	    -------------------------------------------------
	    Put_Block_Box(Highscore_Window_X, Highscore_Window_Y, Highscore_Window_Width, 
			  Highscore_Window_Height+NumPlayers, HighScore_Background, HighScore_Border);     -- En låda runt scorelistan Eric
	    
	    Goto_XY(Highscore_Window_X+1, Highscore_Window_Y+1);
	    Put_Space(Highscore_Window_Width-2, HighScore_Background);
	    Goto_XY(Highscore_Window_X+1, Highscore_Window_Y+2);
	    Put_Space(Highscore_Window_Width-2, HighScore_Background);
	    Put_Score(Data, NumPlayers, Highscore_X, Highscore_Y, 
		      HighScore_Background, White);    -- Skriver ut den sorterade scorelistan / Eric
	    
	    -------------------------------------------------
	    
	    -------------------------------------------------
	    --| Där man skriver för att chatta
	    -------------------------------------------------
	    Put_Block_Box(Chatt_Window_X, Chatt_Window_Y,                    -- Ett litet fönster för att skriva i. / Eric 
			  World_X_Length, 2, Chatt_Background, Chatt_Border); 
	    Goto_XY(Gameborder_X+1,Gameborder_Y+World_Y_Length+2);
	    Put("Här skriver man.");
	    -------------------------------------------------

	    Put_World(Data.Map);
	    
	    if Gameover = 1 then
	       Put_Gameover_Box(Data, Klient_Number, Choice);
	    end if;
	    
	    Set_Colours(White, Black);
	    
	 or
	    accept Get_Choice(C : out Character) do 
	       
	       C := Choice;
	       
	    end Get_Choice;
	 end select;
      end loop;
   end Print_all;
   
   task body Astroid is
   begin
      loop
	 select
	    accept Print(L:Object_List) do
	       Put_Objects(L);
	    end Print;
	 end select;
      end loop;
   end Astroid;
   
   task body Shot is
   begin
      loop
	 select
	    accept Print(L:Object_List) do
	       Put_Objects(L);
	    end Print;
	 end select;
      end loop;
   end Shot;
   
   task body Obstacle is
   begin
      loop
	 select
	    accept Print(L:Object_List) do
	       Put_Objects(L);
	    end Print;
	 end select;
      end loop;
   end Obstacle;
   
   task body Powerup is
   begin
      loop
	 select
	    accept Print(L:Object_List) do
	       Put_Objects(L);
	    end Print;
	 end select;
      end loop;
   end Powerup;
   
   
end Task_Printer;
