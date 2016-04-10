generic
   
   X_Width  : Integer;
   Y_Height : Integer;

package Space_Map is
   
   type World is private;
   
   procedure Generate(Bana : out World);
   
   procedure Put_World(Map : in World);

   procedure New_Top_Row(Map : in out World);

   procedure Move_Rows_Down(Map : in out World);

private
   
   type X_Led is array(1 .. X_width) of Character;
   type World is array(1 .. Y_height) of X_Led;
   
   Left_Border  : Integer := X_Led'First;
   Right_Border : Integer := X_Led'Last;
   
   
end Space_Map;
