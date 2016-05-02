with Window_Handling;     use Window_Handling;
with Ada.Text_IO;         use Ada.Text_IO;
with Box_Hantering;       use Box_Hantering;
with TJa.Window.Text;     use TJa.Window.Text;
with Definitions;         use Definitions;

package body Background_Handling is
   
   procedure Put_Spacebattle(Move           : in out Ship_Move_Type;
			     Shot           : in out Ship_Shot_Type;
			     X, Y           : in Integer;
			     World_X_Length : in Integer;
			     World_Y_Length : in Integer) is
      
      procedure Put_Stars (X,Y, World_X_Length, World_Y_Length : in Integer)is
	 
	 Old_Background  : Colour_Type;
	 
      begin
	 Old_Background  := Get_Background_Colour; 
	 Set_Colours(Yellow, Old_Background);  
	 Goto_XY(3+X,2+Y);        Put("."); 
	 Goto_XY(9+X,10+Y);       Put("."); 
	 Goto_XY(17+X,5+Y);       Put(".");  
	 
	 if World_X_Length > 60 and World_Y_Length > 25 then
	   Goto_XY(2+X,21+Y);       Put(".");  
	   Goto_XY(15+X,26+Y);      Put(".");
	   Goto_XY(25+X,11+Y);      Put("."); 
	   Goto_XY(29+X,21+Y);      Put("."); 
	   Goto_XY(49+X,15+Y);      Put("."); 
	   Goto_XY(57+X,3+Y);       Put(".");  
	   Goto_XY(59+X,21+Y);      Put(".");
	 end if;
	 
	 if World_X_Length > 66 and World_Y_Length > 30 then
	   Goto_XY(35+X,27+Y);      Put(".");  
	   Goto_XY(61+X,27+Y);      Put(".");   
	   Goto_XY(65+X,11+Y);      Put("."); 
	 end if;
	 
	 
	 if World_X_Length > 80 and World_Y_Length > 37 then 
	   Goto_XY(39+X,36+Y);      Put(".");  
	   Goto_XY(79+X,10+Y);      Put(".");
	 end if;
	   
	 Set_Colours(Bright_Yellow, Old_Background); 
	 
	 if World_X_Length > 90 and World_Y_Length >38 then
	   Goto_XY(7+X,38+Y);       Put(".");
	   Goto_XY(89+X,25+Y);      Put("."); 
	   Goto_XY(84+X,14+Y);      Put("✶");
	   Goto_XY(79+X,31+Y);      Put("✶");
	 end if;
	   
	     
	 Goto_XY(40+X,20+Y);        Put("✶");  
	 Goto_XY(4+X,29+Y);         Put("✶"); 
	 
	 	 
	 --  Set_Colours(Cyan, Old_Background); 
	 --  Goto_XY(92+X,8+Y);      Put("o");  
	 --  Goto_XY(48+X,37+Y);      Put("o"); 
	 
	 if Background_Battle_Earth then
	 Goto_XY(X+15,1+Y);  Set_Colours(White, Old_Background); Put("_______");  Set_Colours(Blue, Old_Background);
	 Goto_XY(X,2+Y);  Put("            .-");  Set_Colours(White, Old_Background); Put("""*#####*""");  Set_Colours(Blue, Old_Background); Put("-.");
	 Goto_XY(X,3+Y);  Put("         .-'");	 Set_Colours(Green, Old_Background); Put("8888P8L  ##");  Set_Colours(Blue, Old_Background); Put("  `-.");
	 Goto_XY(X,4+Y);  Put("       ,' ");	 Set_Colours(Green, Old_Background); Put("88888b.J8L._");  Set_Colours(Blue, Old_Background); Put("      `.");
	 Goto_XY(X,5+Y);  Put("     ,' ");	 Set_Colours(Green, Old_Background); Put(",88888888888[´       Y`.");  Set_Colours(Blue, Old_Background);
	 Goto_XY(X,6+Y);  Put("    /   ");	 Set_Colours(Green, Old_Background); Put("8888888888            Y8\");  Set_Colours(Blue, Old_Background);
	 Goto_XY(X,7+Y);  Put("   /    ");	 Set_Colours(Green, Old_Background); Put("Y8888888P'             ]88\");  Set_Colours(Blue, Old_Background);
	 Goto_XY(X,8+Y);  Put("  :     ");	 Set_Colours(Green, Old_Background); Put("`Y88'   P              `888:");  Set_Colours(Blue, Old_Background);
	 Goto_XY(X,9+Y); Put("  :       ");	 Set_Colours(Green, Old_Background); Put("Y8.oP '               Y88:");  Set_Colours(Blue, Old_Background);
	 Goto_XY(X,10+Y); Put("  |          ");	 Set_Colours(Green, Old_Background); Put("`Yb  __             `'|");  Set_Colours(Blue, Old_Background);
	 Goto_XY(X,11+Y); Put("  :            ");	 Set_Colours(Green, Old_Background); Put("`'d8888bo.          :");  Set_Colours(Blue, Old_Background);
	 Goto_XY(X,12+Y); Put("  :             ");	 Set_Colours(Green, Old_Background); Put("d88888888ooo.");  Set_Colours(Blue, Old_Background); Put("      ;");
	 Goto_XY(X,13+Y); Put("   \            ");	 Set_Colours(Green, Old_Background); Put("Y88888888888P");  Set_Colours(Blue, Old_Background); Put("     /");
	 Goto_XY(X,14+Y); Put("    \            ");	 Set_Colours(Green, Old_Background); Put("`Y88888888P");  Set_Colours(Blue, Old_Background); Put("     /");
	 Goto_XY(X,15+Y); Put("     `.            ");	 Set_Colours(Green, Old_Background); Put("d88888P'");  Set_Colours(Blue, Old_Background); Put("    ,'");
	 Goto_XY(X,16+Y); Put("       `.          ");	 Set_Colours(Green, Old_Background); Put("888PP'");  Set_Colours(Blue, Old_Background); Put("    ,'");
	 Goto_XY(X,17+Y); Put("         `-.      ");	 Set_Colours(Green, Old_Background); Put("d8P'");  Set_Colours(Blue, Old_Background); Put("    ,-'");              --CJ- Art by Christian 'CeeJay' Jensen 
	 Goto_XY(X,18+Y); Put("            `-.,");	 Set_Colours(white, Old_Background); Put("______");  Set_Colours(Blue, Old_Background); Put(",.-'");
	 end if;
	 
	 
	 if Background_Battle_Alien then
	 Set_Foreground_Colour(Alien_Body);
	 
	 Goto_XY(World_X_Length+X-25,World_Y_Length+Y-24);           Put("___----------___");
	 Goto_XY(World_X_Length+X-28,World_Y_Length+Y-23);        Put("_-"".^ .^  ^.  '.. :""-_");
	 Goto_XY(World_X_Length+X-30,World_Y_Length+Y-22);      Put("_/:            . .^  :.:\_");
	 Goto_XY(World_X_Length+X-31,World_Y_Length+Y-21);     Put("/: .   .    .        . . .:\");
	 Goto_XY(World_X_Length+X-32,World_Y_Length+Y-20);    Put("/:               .  ^ .  . .:\");
	 Goto_XY(World_X_Length+X-33,World_Y_Length+Y-19);   Put("/.                        .  .:\");
	 Goto_XY(World_X_Length+X-34,World_Y_Length+Y-18);  Put("|:                    .  .  ^. .:|");
	 Goto_XY(World_X_Length+X-34,World_Y_Length+Y-17);  Put("|         .                . .  :|");
	 Goto_XY(World_X_Length+X-34,World_Y_Length+Y-16);  Put("|                                |");
	 Goto_XY(World_X_Length+X-34,World_Y_Length+Y-15);  Put("|. ");Set_Foreground_Colour(Alien_Eyes);Put("#####");Set_Foreground_Colour(Alien_Body);Put("            .");Set_Foreground_Colour(Alien_Eyes);Put("#######");Set_Foreground_Colour(Alien_Body);Put("   ::|");
	 Goto_XY(World_X_Length+X-34,World_Y_Length+Y-14);  Put("|. ");Set_Foreground_Colour(Alien_Eyes);Put("######");Set_Foreground_Colour(Alien_Body);Put("         ..");Set_Foreground_Colour(Alien_Eyes);Put("########");Set_Foreground_Colour(Alien_Body);Put("    :|");
	 Goto_XY(World_X_Length+X-33,World_Y_Length+Y-13);  Put("\ ");Set_Foreground_Colour(Alien_Eyes);Put("######");Set_Foreground_Colour(Alien_Body);Put("         :");Set_Foreground_Colour(Alien_Eyes);Put("########");Set_Foreground_Colour(Alien_Body);Put("    :/");
	 Goto_XY(World_X_Length+X-32,World_Y_Length+Y-12);   Put("\ ");Set_Foreground_Colour(Alien_Eyes);Put("#######");Set_Foreground_Colour(Alien_Body);Put("     . ");Set_Foreground_Colour(Alien_Eyes);Put("########");Set_Foreground_Colour(Alien_Body);Put("   .:/");
	 Goto_XY(World_X_Length+X-31,World_Y_Length+Y-11);    Put("\ ");Set_Foreground_Colour(Alien_Eyes);Put("######");Set_Foreground_Colour(Alien_Body);Put("     ");Set_Foreground_Colour(Alien_Eyes);Put("#######");Set_Foreground_Colour(Alien_Body);Put("   .._/");
	 Goto_XY(World_X_Length+X-30,World_Y_Length+Y-10);      Put("\           .   .   .._/");
	 Goto_XY(World_X_Length+X-29,World_Y_Length+Y-9);        Put("\     | |       . ._/");
	 Goto_XY(World_X_Length+X-28,World_Y_Length+Y-8);         Put("\             .._/");
	 Goto_XY(World_X_Length+X-27,World_Y_Length+Y-7);          Put("\           ._/");
	 Goto_XY(World_X_Length+X-26,World_Y_Length+Y-6);           Put("\  __ .  :_/");
	 Goto_XY(World_X_Length+X-25,World_Y_Length+Y-5);            Put("\      _/ |");
	 Goto_XY(World_X_Length+X-24,World_Y_Length+Y-4);             Put("\    /   |");
	 Goto_XY(World_X_Length+X-23,World_Y_Length+Y-3);              Put("\__/   :|");
	 Goto_XY(World_X_Length+X-22,World_Y_Length+Y-2);               Put("/     ..\");
	 Goto_XY(World_X_Length+X-23,World_Y_Length+Y-1);              Put("/  .   .::\");
	 
	 end if;
--    .     .  :     .    .. :. .___---------___.
--         .  .   .    .  :.:. _".^ .^ ^.  '.. :"-_. .
--      .  :       .  .  .:../:            . .^  :.:\.
--          .   . :: +. :.:/: .   .    .        . . .:\
--   .  :    .     . _ :::/:               .  ^ .  . .:\
--    .. . .   . - : :.:./.                        .  .:\
--    .      .     . :..|:                    .  .  ^. .:|
--      .       . : : ..||        .                . . !:|
--    .     . . . ::. ::\(                           . :)/
--   .   .     : . : .:.|. ######              .#######::|
--    :.. .  :-  : .:  ::|.#######           ..########:|
--   .  .  .  ..  .  .. :\ ########          :######## :/
--    .        .+ :: : -.:\ ########       . ########.:/
--      .  .+   . . . . :.:\. #######       #######..:/
--        :: . . . . ::.:..:.\           .   .   ..:/
--     .   .   .  .. :  -::::.\.       | |     . .:/
--        .  :  .  .  .-:.":.::.\             ..:/
--   .      -.   . . . .: .:::.:.\.           .:/
--  .   .   .  :      : ....::_:..:\   ___.  :/
--     .   .  .   .:. .. .  .: :.:.:\       :/
--       +   .   .   : . ::. :.:. .:.|\  .:/|
--       .         +   .  .  ...:: ..|  --.:|
--  .      . . .   .  .  . ... :..:.."(  ..)"
--     .   .       .      :  .   .: ::/  .  .::\
	 
	 
	 Set_Colours(White, Old_Background);
	 
      end Put_Stars;
      
      procedure Put_Small_Ship(Move_Count : in out Integer;
			       X          : in Integer;
			       Y          : in Integer;
			       X_Length   : in Integer) is
	 
      begin	 
	 
	 if Move_Count < 40 then
	    for I in Small_Ship_Y_Length'range loop
	       for J in Small_Ship_X_Length'last-Move_Count..Small_Ship_X_Length'last loop
		  if Small_Ship(I)(J) /= ' ' then
		     Goto_XY(J+X-40+Move_Count,I+Y);
		     if Small_Ship(I)(J) = 'X' then
			Put(' ');
		     else
			Put(Small_Ship(I)(J));
		     end if;
		  end if;
	       end loop;
	    end loop;
	    
	    
	 elsif Move_Count > X_Length-1 then
	    for I in Small_Ship_Y_Length'range loop
	       for J in Small_Ship_X_Length'first..Small_Ship_X_Length'Last-(Move_Count-(X_Length-1)) loop
		  if Small_Ship(I)(J) /= ' ' then
		     Goto_XY(J+X-40+Move_Count,I+Y);
		     if Small_Ship(I)(J) = 'X' then
			Put(' ');
		     else
			Put(Small_Ship(I)(J));
		     end if;
		  end if;
	       end loop;
	    end loop;
	    
	    
	 else
	    for I in Small_Ship_Y_Length'range loop
	       for J in Small_Ship_X_Length'range loop
		  if Small_Ship(I)(J) /= ' ' then
		     Goto_XY(J+X-40+Move_Count,I+Y);
		     if Small_Ship(I)(J) = 'X' then
			Put(' ');
		     else
			Put(Small_Ship(I)(J));
		     end if;
		  end if;
	       end loop;
	    end loop;
	 end if;
	 
	 if Move_Count-(X_Length-1) = Small_Ship_X_Length'Last then
	    Move_Count := 0;
	 end if;
	 
      end Put_Small_Ship;
      
      
      procedure Put_Big_Ship(Move_Count : in out Integer;
			   X          : in Integer;
			   Y          : in Integer;
			   X_Length   : in Integer) is
	 
      begin   
	 if Move_Count < 65 then
	    for I in Big_Ship_Y_Length'range loop
	      for J in Big_Ship_X_Length'last-Move_Count..Big_Ship_X_Length'last loop
		 if Big_Ship(I)(J) /= ' ' then
		    Goto_XY(J+X-64+Move_Count,I+Y);
		    if Big_Ship(I)(J) = 'X' then
		       Put(' ');
		    else
		       Put(Big_Ship(I)(J));
		    end if;
		 end if;
	      end loop;
	    end loop;
	    
	    
	 elsif Move_Count > X_Length-1 then
	    for I in Big_Ship_Y_Length'range loop
	      for J in Big_Ship_X_Length'first..Big_Ship_X_Length'Last-(Move_Count-(X_Length-1)) loop
		 if Big_Ship(I)(J) /= ' ' then
		    Goto_XY(J+X-64+Move_Count,I+Y);
		    if Big_Ship(I)(J) = 'X' then
		       Put(' ');
		    else
		       Put(Big_Ship(I)(J));
		    end if;
		 end if;
	      end loop;
	    end loop;
	 
	    
	 else
	    for I in Big_Ship_Y_Length'range loop
	      for J in Big_Ship_X_Length'range loop
		 if Big_Ship(I)(J) /= ' ' then
		    Goto_XY(J+X-64+Move_Count,I+Y);
		    if Big_Ship(I)(J) = 'X' then
		       Put(' ');
		    else
		       Put(Big_Ship(I)(J));
		    end if;
		 end if;
	      end loop;
	    end loop;
	 end if;
	 
	 if Move_Count-(X_Length-1) = Big_Ship_X_Length'Last then
	    Move_Count := 0;
	 end if;
	 
      end Put_Big_Ship;
      
      procedure Put_All_Shot(Shot           : in out Ship_Shot_Type;
			     Move           : in out Ship_Move_Type;
			     X ,Y           : in Integer;
			     World_X_Length : in Integer) is
	 
	 procedure Put_Shot(Shot           : in out Integer;
			    Move           : in out Integer;
			    X ,Y           : in Integer;
			    World_X_Length : in Integer) is
			      
      begin
	 if Shot <= World_X_Length+X+1 and Shot > X+1 
	   and Move-42 < Shot then
	    Goto_XY(Shot-2+X,Y);
	    Put("~");
	    if Shot = World_X_Length+X+1 then
	       Shot := 1;
	    end if;
	 end if;
	 
	 if Shot <= World_X_Length+X and Shot > X 
	   and Move-43 < Shot then
	    Goto_XY(Shot-1+X,Y);
	    Put("~");
	 end if;
	 
	 if Shot <= World_X_Length+X-1 and Shot > X-1 
	   and Move-44 < Shot then
	    Goto_XY(Shot+X,Y);
	    Put("~");
	 end if;
	 
      end Put_Shot;
      
      
      begin
	 Set_Foreground_Colour(Red);
	 
	 Put_Shot(Shot(1),Move(1),X,Y+5,World_X_Length);
	 
	 if Move(1) > World_X_Length then
	    Shot(1) := 0;
	 end if;
	 
      end Put_All_Shot;
      
   begin
      Set_Colours(White, Black);
      Clear_Window;
      
      Put_Stars(X,Y,World_X_Length, World_Y_Length);
      
      Put_Double_Line_Box(X,Y,World_X_Length+2,World_Y_Length,Black,Dark_Grey);
      
      if Loop_Counter > 5 and Background_Battle_Bigship then
	 Put_Big_Ship(Move(1),X,1+Y,World_X_Length);
	 
	 if Loop_Counter mod 8 = 0 then
	    Move(1) := Move(1) + 1 ;
	 end if;
      end if;
      
      if Background_Battle_Smallship then
	 if Loop_Counter > 200 then
	    Put_Small_Ship(Move(2),X+1,16+Y,World_X_Length);
	    
	    if Loop_Counter mod 3 = 0 then
	       Move(2) := Move(2) + 1 ;
	    end if;
	 end if;
	 
	 
	 if Loop_Counter > 500 then
	    Put_Small_Ship(Move(3),X+1,23+Y,World_X_Length);
	    
	    if Loop_Counter mod 2 = 0 then
	       Move(3) := Move(3) + 1 ;
	    end if;
	 end if;
	 
	 
	 if Loop_Counter > 5 then
	    Put_Small_Ship(Move(4),X+1,30+Y,World_X_Length);
	    
	    if Loop_Counter mod 4 = 0 then
	       Move(4) := Move(4) + 1 ;
	    end if;
	 end if;
      end if;
      
      
      if Background_Battle_Bigship_Shot then
	 Put_ALL_Shot(Shot,Move,X,Y,World_X_Length);
	 
	 if Loop_Counter mod 1 = 0 then
	    Shot(1) := Shot(1) + 1;
	 end if;
      end if;
      
      Loop_Counter := Loop_Counter + 1;
      
	 --  Goto_XY(3,5);        Put("____/|");
	 --  Goto_XY(2,6);       Put("|  /__|===--");
	 --  Goto_XY(2,7);       Put("|__|_____.----._ ");
	 --  Goto_XY(2,8);       Put("|\  `---.__:====}-----...,,_____");
	 --  Goto_XY(2,9);       Put("|[:-----|_______;----------_____;::===--");
	 --  Goto_XY(2,10);      Put("|/_____.....--------------´");
	 
	 
	 
	 --  Goto_XY(15,13);             Put("_");
	 --  Goto_XY(14,14);            Put("(_)");
	 --  Goto_XY(8,15);       Put("____.--'.");
	 --  Goto_XY(7,16);      Put("/:  /    |===--");
	 --  Goto_XY(6,17);     Put("/:  /-----´");
	 --  Goto_XY(5,18);    Put("/: __[\---`.___");
	 --  Goto_XY(4,19);   Put("/__|\ .-----´   `---..__");
	 --  Goto_XY(4,20);   Put("\   \|::::|-----.....___|===--");
	 --  Goto_XY(5,21);    Put("\ _\_----------:::::______.-----.____");
	 --  Goto_XY(6,22);     Put("[\  \  __  ==--    \       ==--     \_.---------...____");
	 --  Goto_XY(6,23);     Put("[=========================================================--");
	 --  Goto_XY(5,24);    Put("/         __/__ ==--  /__   ==--      /____....==------´");
	 --  Goto_XY(4,25);   Put("/  /   ==--         ____....===-------´");
	 --  Goto_XY(3,26);  Put("/____....===--------´");

      
      
      --     	   __
      --  	   \ \_____
      --          ###[==_____>
      --  	   /_/      
      --  	   __
      --  	   \ \_____
      --  	###[==_____>
      --  	   /_/
      
   end Put_Spacebattle;
   
   procedure Put_Background (NumPlayers : in Integer) is
      
      Game_Length : constant Integer := World_X_Length + Gameborder_X + HighScore_Window_Width;
      Game_Height : constant Integer := World_Y_Length + Gameborder_Y + 4;
   begin

      
      if Auto_Background then
	 -------------------------------------------------
	 --| Border around everything
	 -------------------------------------------------
	 Put_Space_Box(1, 1, Game_Length, Game_Height, Dark_Grey);
	 -------------------------------------------------
	 
	 
	 -------------------------------------------------
	 --| Game Colour Top
	 -------------------------------------------------
	 Goto_XY(2,2);
	 Put_Space(Game_Length-2, Top_BG_Colour);
	 Goto_XY(2,3);
	 Put_Space(Game_Length-2, Top_BG_Colour);
	 
	 
	 -------------------------------------------------
	 --| Game Colour Side
	 -------------------------------------------------
	 if GameBorder_X > 2 then
	    for I in 1 .. World_Y_Length-1 loop
	       Goto_XY(2, GameBorder_Y+I);
	       Put_Space(GameBorder_X-2, Game_Wall_Background);
	    end loop;
	    
	    for I in (GameBorder_Y+HighScore_Window_Height+NumPlayers) .. World_Y_Length loop
	       Goto_XY(GameBorder_X + World_X_Length, GameBorder_Y+I-1);
	       Put_Space(HighScore_Window_Width, Game_Wall_Background);
	    end loop;
	 end if;
	 
	 
	 
	 -------------------------------------------------
	 --| Game Colour Bottom
	 -------------------------------------------------
	 Goto_XY(2,GameBorder_Y+World_Y_Length);
	 Put_Space(Game_Length-2, Bottom_BG_Colour);
	 
	 Goto_XY(2,GameBorder_Y+World_Y_Length+1);
	 Put_Space(GameBorder_X-2, Bottom_BG_Colour);
	 Goto_XY(2,GameBorder_Y+World_Y_Length+2);
	 Put_Space(GameBorder_X-2, Bottom_BG_Colour);
	 Goto_XY(2,GameBorder_Y+World_Y_Length+3);
	 Put_Space(GameBorder_X-2, Bottom_BG_Colour);
	 
	 Goto_XY(GameBorder_X+World_X_Length,GameBorder_Y+World_Y_Length+1);
	 Put_Space(HighScore_Window_Width, Bottom_BG_Colour);
	 Goto_XY(GameBorder_X+World_X_Length,GameBorder_Y+World_Y_Length+2);
	 Put_Space(HighScore_Window_Width, Bottom_BG_Colour);
	 Goto_XY(GameBorder_X+World_X_Length,GameBorder_Y+World_Y_Length+3);
	 Put_Space(HighScore_Window_Width, Bottom_BG_Colour);
	 
	 Goto_XY(2,GameBorder_Y+World_Y_Length+4);
	 Put_Space(Game_Length-2, Bottom_BG_Colour);
	 -------------------------------------------------
      else
	 -------------------------------------------------
	 --| Border around everything
	 -------------------------------------------------
	 Set_Background_Colour(Dark_Grey);	 
	 Goto_XY(1,1);
	 Put("                                                                                                                                                    ");
	 
	 for I in 1 .. Game_Height-1 loop
	    Goto_XY(1,1+I);
	    Put(' ');
	    Goto_XY(1+Game_Length,1+I);
	    Put(' ');
	 end loop;
	 
	 
	 Goto_XY(1,Game_Height+1);
	 Put("                                                                                                                                                    ");
	 
	 -------------------------------------------------
	 --| Game Colour Top
	 -------------------------------------------------
	 Set_Background_Colour(Top_BG_Colour);
	 Goto_XY(2,2); 
	 Put("                                                                                                                                                  ");
	 Goto_XY(2,3);
	 Put("                                                                                                                                                  ");
	 
	 
	 -------------------------------------------------
	 --| Game Colour Side
	 -------------------------------------------------
	 Set_Background_Colour(Game_Wall_Background);
	 for I in 1 .. World_Y_Length-1 loop
	    Goto_XY(2,GameBorder_Y+I);
	    Put("   ");
	 end loop;
	 
	 for I in 1 .. GameBorder_Y+HighScore_Window_Height+NumPlayers-1 loop
	    Goto_XY(Gameborder_X+World_X_Length, GameBorder_Y+I);
	    Put(' ');
	 end loop;
	 
	 for I in GameBorder_Y+HighScore_Window_Height+NumPlayers .. World_Y_Length loop
	    Goto_XY(Gameborder_X+World_X_Length, GameBorder_Y+I-1);
	    Put("                                  ");
	 end loop;
	 
	 
	 
	 -------------------------------------------------
	 --| Game Colour Bottom
	 -------------------------------------------------
	 Set_Background_Colour(Bottom_BG_Colour);
	 Goto_XY(2,GameBorder_Y+World_Y_Length);
	 Put("                                                                                                                                                  ");
	 
	 for I in 1 .. 3 loop
	    Goto_XY(2,GameBorder_Y+World_Y_Length+I);
	    Put("   ");
	    Goto_XY(GameBorder_X+World_X_Length, GameBorder_Y+World_Y_Length+I);
	    Put("                                  ");
	 end loop;
	 
	 Goto_XY(2,GameBorder_Y+World_Y_Length+4);
	 Put("                                                                                                                                                  ");
	 
      end if;
   end Put_Background;

   
   
end Background_Handling;
