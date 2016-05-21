package body Print_Handling is
   
   procedure Put_All(Game          : in Game_Data;
		     Waves         : in Enemy_List_Array;
		     Powerup_List  : in Object_List;
		     Astroid_List  : in Object_List;
		     Obstacle_List : in Object_List;
		     Shot_List     : in Object_List;
		     Num_Players   : in Integer;
		     Klient_Number : in Integer;
		     Level         : in Integer;
		     Loop_Counter  : in Integer;
		     Choice        : in out Character) is
      
      Super_Missile : Boolean := Game.Players(Klient_Number).Ship.Super_Missile;
      Cooldown      : Integer := 0;
      Power_Time    : Integer := 0;
      
   begin
      Clear_Window;
      
      Put_Player_Ships(Game, Num_Players);
      
      for I in Waves'range loop
	 Put_Objects(Waves(I));
      end loop;
      
      Put_Objects(Powerup_List);
      Put_Objects(Astroid_List);
      --shot.prit ev här
      Put_Objects(Obstacle_List);
      Put_Objects(Shot_List);
      
      if Background then
	 Put_Background(Num_Players);
      end if;
      
      -------------------------------------------------
      --| Highscore fönster
      -------------------------------------------------
      Put_Block_Box(Highscore_Window_X, Highscore_Window_Y, Highscore_Window_Width, 
		    Highscore_Window_Height+Num_Players, HighScore_Background, HighScore_Border);     -- En låda runt scorelistan Eric
      
      Goto_XY(Highscore_Window_X+1, Highscore_Window_Y+1);
      Put_Space(Highscore_Window_Width-2, HighScore_Background);
      Goto_XY(Highscore_Window_X+1, Highscore_Window_Y+2);
      Put_Space(Highscore_Window_Width-2, HighScore_Background);
      Put_Score(Game, Num_Players, Highscore_X, Highscore_Y, 
		HighScore_Background, White);    -- Skriver ut den sorterade scorelistan / Eric
      
      -------------------------------------------------
      
      Put_World(Game.Map);
      
      if Game.Settings.Gameover = 1 then 
	 Get_Input(Navigate_Input);             -- Get Player navigation choice
	 
	 Put_Gameover_Box(Game, Klient_Number, Choice);
      end if;
      
      -----------------------------------------------------------------
      --| Level nr & Astroid Length
      -----------------------------------------------------------------
      Set_Colours(Red, Bottom_BG_Colour);
      Set_Bold_Mode(On);
      
      if Loop_Counter < 300 then
	 Goto_XY(GameBorder_X, GameBorder_Y+World_Y_Length+2);
	 Put("Start");
	 
	 for I in 1..3 loop
	    Goto_XY(GameBorder_X+6, GameBorder_Y+World_Y_Length+I);
	    Put('|');
	 end loop;
	 
	 for I in 1..3 loop
	    Goto_XY((GameBorder_X+7+Integer(Float(Loop_Counter)/3.5)), GameBorder_Y+World_Y_Length+I);
	    Put("▬▶");
	 end loop;
	 
	 for I in 1..3 loop
	    Goto_XY(GameBorder_X+World_X_Length-16, GameBorder_Y+World_Y_Length+I);
	    Put('|');
	 end loop;
	 
	 Goto_XY(GameBorder_X+World_X_Length-14, Gameborder_Y+World_Y_Length+2);
	 Put("New Level");
      else
	 Goto_XY(GameBorder_X+(World_X_Length/2)-7, GameBorder_Y+World_Y_Length+2);
	 Put("Level ");
	 Put(Level, Width => 2);
      end if;
      
      -----------------------------------------------------------------
      --| Weapons Status
      -----------------------------------------------------------------
      Goto_XY(Gameborder_X+World_X_Length+1, Gameborder_Y+Highscore_Window_Height+Num_Players+3);
      Set_Colours(White, Game_Wall_Background);
      Put("Missile Ammo: ");
      
      for I in 1.. Game.Players(Klient_Number).Ship.Missile_Ammo loop
	 
	 if not Super_Missile then
	    Put("î");
	 else
	    Set_Colours(Red, Game_Wall_Background);
	    Put("î");	  
	    Set_Colours(White, Game_Wall_Background);
	    Super_Missile := False;
	 end if;
	 exit when I = 10;	       
      end loop;
      
      if 10 < Game.Players(Klient_Number).Ship.Missile_Ammo then
	 Put('+');
      end if;
      
      Goto_XY(Gameborder_X+World_X_Length+1, Gameborder_Y+Highscore_Window_Height+Num_Players+4);
      Put("Weapon Type: ");
      Set_Foreground_Colour(Red);
      if Game.Players(Klient_Number).Ship.Hitech_Laser then
	 Put("Hitech Laser");
	 Power_Time := Game.Players(Klient_Number).Ship.Laser_Recharge/4;
      elsif Game.Players(Klient_Number).Ship.Laser_Type = Normal_Laser_Shot then
	 Put("Normal Laser");
	 Cooldown := Game.Players(Klient_Number).Ship.Laser_Recharge*5;
      elsif Game.Players(Klient_Number).Ship.Laser_Type = Laser_Upgraded_Shot then
	 Put("Upgraded Laser");
	 Cooldown := Game.Players(Klient_Number).Ship.Laser_Recharge*10;
      elsif Game.Players(Klient_Number).Ship.Laser_Type = Nitro_Shot then
	 Put("Nitro");
	 Cooldown := Game.Players(Klient_Number).Ship.Laser_Recharge*5;
      end if;
      
      if Game.Players(Klient_Number).Ship.Laser_Type in 1 .. 2 then
	 Goto_XY(Gameborder_X+World_X_Length+13, Gameborder_Y+Highscore_Window_Height+Num_Players+5);
	 if Game.Players(Klient_Number).Ship.Tri_Laser 
	   or Game.Players(Klient_Number).Ship.Diagonal_Laser then
	    Put(" with ");
	 end if;
	 if Game.Players(Klient_Number).Ship.Tri_Laser then
	    Put("Tri-Laser");
	 end if;
	 if Game.Players(Klient_Number).Ship.Tri_Laser 
	   and Game.Players(Klient_Number).Ship.Diagonal_Laser then
	    Goto_XY(Gameborder_X+World_X_Length+13, Gameborder_Y+Highscore_Window_Height+Num_PLayers+6);
	    Put(" & ");
	 end if;
	 if Game.Players(Klient_Number).Ship.Diagonal_Laser then
	    Put("Diagonal-Laser");
	 end if;
      end if;
      
      
      -----------------------------------------------------------------
      --| COOLDOWN BOX
      -----------------------------------------------------------------
      
      Set_Bold_Mode(Off); -- Måste stänga av annars är färgen Dark_Grey på boxen under
      Put_Double_Line_Box(Gameborder_X+World_X_Length+1, Gameborder_Y+Highscore_Window_Height+15, Highscore_Window_Width-1, 2, Game_Wall_Background, Black);

      
      Set_Foreground_Colour(Red);
      Goto_XY(Gameborder_X+World_X_Length+2, Gameborder_Y+Highscore_Window_Height+16);
      for I in 1 .. Cooldown loop
	 Put("▌");
      end loop;
      Set_Foreground_Colour(Black);
      Goto_XY(Gameborder_X+World_X_Length+11, Gameborder_Y+Highscore_Window_Height+15);
      Put("COOLDOWN");
      Set_Foreground_Colour(White);
      Set_Bold_Mode(On);
      
      -----------------------------------------------------------------
      --| Power TIME BOX
      -----------------------------------------------------------------
      Set_Bold_Mode(Off); -- Måste stänga av annars är färgen Dark_Grey på boxen under
      Put_Double_Line_Box(Gameborder_X+World_X_Length+1, Gameborder_Y+Highscore_Window_Height+18, Highscore_Window_Width-1, 2, Game_Wall_Background, Black);
      
      Goto_XY(Gameborder_X+World_X_Length+2, Gameborder_Y+Highscore_Window_Height+19);
      Set_Foreground_Colour(Red);
      for I in 1 .. Power_Time loop
	 Put("▌");
      end loop;
      Set_Foreground_Colour(Black);
      Goto_XY(Gameborder_X+World_X_Length+10, Gameborder_Y+Highscore_Window_Height+18);
      Put("POWER LEVEL");
      Set_Foreground_Colour(White);
      Set_Bold_Mode(On);
      
      
      -----------------------------------------------------------------
      --| Powerup info box
      -----------------------------------------------------------------
      Set_Foreground_Colour(White);
            Put_Box(Gameborder_X+World_X_Length+1, Gameborder_Y+Highscore_Window_Height+22, Highscore_Window_Width-1, 10, Game_Wall_Background, White);
      
      
      
      Goto_XY(Gameborder_X+World_X_Length+11, Gameborder_Y+Highscore_Window_Height+23); 
      Set_Underlined_Mode(On);
      Put("Powerup Info");
      Set_Underlined_Mode(Off);
      
      Goto_XY(Gameborder_X+World_X_Length+7, Gameborder_Y+Highscore_Window_Height+24); 
      Put("(♥) - +5 Health");
      Goto_XY(Gameborder_X+World_X_Length+7, Gameborder_Y+Highscore_Window_Height+25); 
      Put("(m) - Missile Ammo");
      Goto_XY(Gameborder_X+World_X_Length+7, Gameborder_Y+Highscore_Window_Height+26); 
      Put("(M) - Super Missile");
      Goto_XY(Gameborder_X+World_X_Length+7, Gameborder_Y+Highscore_Window_Height+27); 
      Put("(o) - Laser upgrade");
      Goto_XY(Gameborder_X+World_X_Length+7, Gameborder_Y+Highscore_Window_Height+28); 
      Put("(X) - Hitech Laser");
      Goto_XY(Gameborder_X+World_X_Length+7, Gameborder_Y+Highscore_Window_Height+29);
      Put("(3) - Tri-Laser");
      Goto_XY(Gameborder_X+World_X_Length+7, Gameborder_Y+Highscore_Window_Height+30); 
      Put("(D) - Diagonal-laser");
      Goto_XY(Gameborder_X+World_X_Length+7, Gameborder_Y+Highscore_Window_Height+31); 
      Put("(N) - Nitro-shot");
      -----------------------------------------------------------------
      
      
      
      Set_Bold_Mode(Off);
      
      
      Set_Colours(White, Black);
   end Put_All;
end Print_Handling;
