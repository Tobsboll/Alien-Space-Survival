with TJa.Window.Text;         use TJa.Window.Text;

package Definitions is
   
   World_X_Length : constant Integer := 100;
   World_Y_Length : constant Integer := 40;
   
   Up              : constant Integer := -1;
   Down            : constant Integer := 1;
   Light           : constant Integer := 1;
   Hard            : constant Integer := 5;
   Unbreakable     : constant Integer := 999;
   
   Move_Horisontal : constant Integer := 2;
   
   type XY_Type is array(1 .. 2) of Integer;
   
    --Types represented by integerz
   type Shot_Array_Type is array (1..10) of Integer;
   ShotType : Shot_Array_Type := (1, 2, 3, 4, 5, 6, 7, 8, 9, 10); 
     
   type Obstacle_Array_Type is array (1..10) of Integer;
   ObstacleType : Obstacle_Array_Type := (11, 12, 13, 14, 15, 16, 17, 18, 19, 20);
   type PowerUp_Array_Type is array (1..10) of Integer;
   PowerUpType : PowerUp_Array_Type := (21, 22, 23, 24, 25, 26, 27, 28, 29, 30);
   
   
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
  	 Playing    : Boolean;
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
	 Generate_Map   : Boolean;     -- Generering av banan Activ/Inaktiv
	 Astroid_Active : Boolean;     -- Generering av astroider Activ/Inaktiv
      end record;
   ---------------------------------------------------
   
   ---------------------------------------------------
   --| X,Y Koordinater för alla fönster
   ---------------------------------------------------
   Gameborder_X : constant Integer := 1; 
   Gameborder_Y : constant Integer := 1;
   
   World_Box_X      : constant Integer := Gameborder_X;
   World_Box_Y      : constant Integer := Gameborder_Y;
   World_Box_Length : constant Integer := World_X_Length;
   World_Box_Heigth : constant Integer := World_Y_Length;
   
   Highscore_Window_X      : constant Integer := Gameborder_X+world_X_Length;
   Highscore_Window_Y      : constant Integer := Gameborder_Y;
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
   Background_Colour_2   : constant Colour_Type := Black;     -- Scorewindow
   Text_Colour_2         : constant Colour_Type := White;     -- Scorewindow
   Menu_Background       : constant Colour_Type := Dark_Grey; -- Startmenu
   Menu_Selected         : constant Colour_Type := Blue;      -- Startmenu
   Menu_Non_Selected     : constant Colour_Type := Green;     -- Startmenu
   Nickname_Border_Box   : constant Colour_Type := Green;     -- Enter Nickname
   Nickname_Write_Box    : constant Colour_Type := Blue;      -- Enter Nickname
   Alien_Body            : constant Colour_Type := Green;     -- Background
   Alien_Eyes            : constant Colour_Type := Yellow;    -- Background
   ---------------------------------------------------
   
   
   ---------------------------------------------------
   --| Animation
   ---------------------------------------------------   
   Background_Battle_Bigship         : constant Boolean := True;
   Background_Battle_Bigship_Shot    : constant Boolean := True;
   Background_Battle_Smallship       : constant Boolean := True;
   Background_Battle_Earth           : constant Boolean := True;
   Background_Battle_Alien           : constant Boolean := False;
   ---------------------------------------------------
   
   
end Definitions;
