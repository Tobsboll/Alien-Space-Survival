with TJa.Window.Text;         use TJa.Window.Text;
with TJa.Sockets;                  use TJa.Sockets;

package Definitions is
   
   World_X_Length : constant Integer := 110;
   World_Y_Length : constant Integer := 35;
   
   type X_Led is array(1 .. World_X_Length) of Character;
   type World is array(1 .. World_Y_Length) of X_Led;
   
   Up              : constant Integer := -1;
   Down            : constant Integer := 1;
   Light           : constant Integer := 1;
   Hard            : constant Integer := 5;
   Unbreakable     : constant Integer := 999;
   
   Move_Horisontal : constant Integer := 2;
   
   Obstacle_Y_Pos  : constant Integer := World_Y_Length*2/3;
   
   type XY_Type is array(1 .. 2) of Integer;
   
   type Socket_Array is
	array (1..4) of Socket_Type;
   
    --Types represented by integerz
   type Shot_Array_Type is array (1..10) of Integer;
   ShotType : Shot_Array_Type := (1, 2, 3, 4, 5, 6, 7, 8, 9, 10); 
     
   type Obstacle_Array_Type is array (1..10) of Integer;
   ObstacleType : Obstacle_Array_Type := (11, 12, 13, 14, 15, 16, 17, 18, 19, 20);
   type PowerUp_Array_Type is array (1..10) of Integer;
   PowerUpType : PowerUp_Array_Type := (21, 22, 23, 24, 25, 26, 27, 28, 29, 30);
   
   type Enemy_Array_Type is array (1..10) of Integer;
   EnemyType : Enemy_Array_Type := (31, 32, 33, 34, 35, 36, 37, 38, 39, 40);
   
   type Ranking_List is array (1 .. 4) of Integer;

   type Shot_Type is array (1 .. 5) of XY_Type;
   
   type Ship_spec is 
      record
  	 XY      : XY_Type; 
  	 Health   : Integer; 
  	 Laser_Type : Integer;
	 Missile_Ammo : Integer;
      end record;
   
   ------------------------------------------------
   --| Spelarnas Specifikationerna
   ------------------------------------------------
   type Player_Type is
      record
  	 Playing    : Boolean := false;
  	 Name       : String(1..10);
  	 NameLength : Integer;
  	 Ship       : Ship_Spec;
	 Colour     : Colour_Type;
  	 Score      : Integer;
      end record;
   
   type Player_Array is array (1..4) of Player_Type;
   ------------------------------------------------
   
   ---------------------------------------------------
   --| Inställningar
   ---------------------------------------------------
   type Setting_Type is
      record
	 Generate_Map    : Boolean;     -- Generering av banan Activ/Inaktiv
	 Astroid_Active  : Boolean;     -- Generering av astroider Activ/Inaktiv
	 Difficulty      : Integer;
      end record;
   ---------------------------------------------------
   
   ---------------------------------------------------
   --| Game_Data
   ---------------------------------------------------
   
      type Game_Data is
      record
   	 Map      : World;             -- Banan är i packetet så att både klienten och servern 
   	                               -- hanterar samma datatyp / Eric
   	 Players  : Player_Array;      -- Underlättade informationsöverföringen mellan klient och server.
	 
   	 Ranking  : Ranking_List;      -- Vem som har mest poäng
   	 Settings : Setting_Type;      -- Inställningar.
      end record; 
   
   ---------------------------------------------------
   --| X,Y Koordinater för alla fönster
   ---------------------------------------------------
   Gameborder_X : constant Integer := 4; 
   Gameborder_Y : constant Integer := 3;
   
   World_Box_X      : constant Integer := Gameborder_X-1;
   World_Box_Y      : constant Integer := Gameborder_Y;
   World_Box_Length : constant Integer := World_X_Length;
   World_Box_Heigth : constant Integer := World_Y_Length;
   
   Highscore_Window_X      : constant Integer := Gameborder_X+World_X_Length+1;
   Highscore_Window_Y      : constant Integer := Gameborder_Y+1;
   Highscore_Window_Width  : constant Integer := 33;
   Highscore_Window_Height : constant Integer := 2;
   
   Highscore_X : constant Integer := Highscore_Window_X+1;
   Highscore_Y : constant Integer := Highscore_Window_Y+1;
   
   Chatt_Window_X : constant Integer := Gameborder_X;
   Chatt_Window_Y : constant Integer := Gameborder_Y+World_Y_Length+1;
   ---------------------------------------------------
   
   ---------------------------------------------------
   --| Färginställningarna
   ---------------------------------------------------
   Background_Colour_1   : constant Colour_Type := Black;     -- Terminalen
   Text_Colour_1         : constant Colour_Type := White;     -- Terminalen
   HighScore_Background  : constant Colour_Type := Black;     -- Scorewindow
   HighScore_Border      : constant Colour_Type := Dark_Grey; -- Scorewindow
   Chatt_Background      : constant Colour_Type := Black;     -- Chatt
   Chatt_Border          : constant Colour_Type := Dark_Grey; -- Chatt
   Game_Wall_Background  : constant Colour_Type := Magenta;       -- Gameworld
   Game_Wall_Line        : constant Colour_Type := Bright_Magenta;-- Gameworld
   Game_Wall_Worm        : constant Colour_Type := Black;     -- Gameworld
   Menu_Background       : constant Colour_Type := Dark_Grey; -- Startmenu
   Menu_Selected         : constant Colour_Type := Blue;      -- Startmenu
   Menu_Non_Selected     : constant Colour_Type := Green;     -- Startmenu
   Nickname_Border_Box   : constant Colour_Type := Green;     -- Enter Nickname
   Nickname_Write_Box    : constant Colour_Type := Blue;      -- Enter Nickname
   Alien_Body            : constant Colour_Type := Green;     -- Background
   Alien_Eyes            : constant Colour_Type := Yellow;    -- Background
   Top_BG_Colour         : constant Colour_Type := Bright_Magenta; -- Game Terminal
   Bottom_BG_Colour      : constant Colour_Type := Bright_Magenta; -- Game Terminal
   
   Enemy_Laser_1         : constant Colour_Type := Bright_Green;
   Player_Laser_1        : constant Colour_Type := Bright_Red;
   ---------------------------------------------------
   
   
   ---------------------------------------------------
   --| Animation
   ---------------------------------------------------   
   Background_Battle_Bigship         : constant Boolean := True;
   Background_Battle_Bigship_Shot    : constant Boolean := True;
   Background_Battle_Smallship       : constant Boolean := True;
   Background_Battle_Earth           : constant Boolean := True;
   Background_Battle_Alien           : constant Boolean := False;
   Wall_Worm                         : constant Boolean := True;
   ---------------------------------------------------
   
   
   -- Justerar bakgrunden automatiskt efter vilka längder man väljer. (Bara för test)
   Auto_Background                   : constant Boolean := False;
   Background                        : constant Boolean := True;
   
   
end Definitions;
