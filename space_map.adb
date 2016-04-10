with Ada.Text_IO;                       use Ada.Text_IO;
with Ada.Integer_Text_IO;               use Ada.Integer_Text_IO;
with tja.window.Elementary;             use tja.window.Elementary;
with Ada.Numerics.Discrete_Random;

package body Space_Map is
   
   subtype One_To is Integer range -1 .. 1;

   package Random is
      new Ada.Numerics.Discrete_Random(Result_Subtype => One_To);
   --   use Random;
   
   G : Random.Generator;
   
   procedure Generate(Bana : out World) is
      
      
   begin  
      for I in World'Range loop
	 for J in X_Led'Range loop
	    if (J) = (X_Led'first) then
	       Bana(I)(J) := '|';
	    elsif (J) = (X_Led'Last) then
	       Bana(I)(J) := '|';
	    else
	       Bana(I)(J) := ' ';
	    end if;
	 end loop;
      end loop;
   end Generate;
   
   
   procedure Put_World(Map : World) is
      
   begin
      for I in World'Range loop
	 for J in X_Led'First .. X_Led'last loop
	    Put(Map(I)(J));
	 end loop;
	 New_Line;
      end loop;
      
      Goto_XY(1,1);
      if Left_Border /= 1 then
	 for I in 1 .. Left_Border-1 loop
	    Put(' ');
	 end loop;
      end if;
      for I in Left_Border .. Right_Border loop
	 Put('_');
      end loop;
      
      for I in Right_Border .. X_Led'Last loop
	 Put(' ');
      end loop;
      Goto_XY(1,World'Last+1);
      
   end Put_World;
   
   procedure New_Top_Row(Map : in out World) is
      
      A,R,O : Integer := 0;
      
      
   begin
      
      loop
	 Random.Reset(G);
	 if A = O then
	    A := Random.Random(G);
	 else
	    if A = 1 then
	       A := -1;
	    elsif A = -1 then
	       A := 0;
	    else
	       A := 1;
	    end if;
	 end if;
	 
	 if Left_Border = 1 then
	    if A = 1 then
	       Left_Border := Left_Border + A;
	       Map(1)(Left_Border) := '/';
	       Left_Border := Left_Border + A;
	       Map(1)(Left_Border-2) := ' ';
	    else 
	       Map(1)(Left_Border) := '|';
	       Map(1)(Left_Border+1) := ' ';
	    end if;
	    A := O;
	    exit;
	 elsif Left_Border > 2 and Left_Border < X_Led'Last/3 Then
	    if A = -1 and Map(2)(Left_Border) = '|' then 
	       Left_Border := Left_Border + A;
	       Map(1)(Left_Border) := '\';
	       Left_Border := Left_Border + A;
	       Map(1)(Left_Border - (2*A)) := ' ';
	       O := A;
	       exit;
	    elsif A = 0 and Map(2)(Left_Border-1) = '/' then 
	       Map(1)(Left_Border) := '|';
	       Map(1)(Left_Border-1) := ' ';
	       O := A;
	       exit;
	    elsif A = 0 and Map(2)(Left_Border+1) = '\'  then 
	       Map(1)(Left_Border) := '|';
	       Map(1)(Left_Border+1) := ' ';
	       O := A;
	       exit;
	    elsif A = 1 and Map(2)(Left_Border) = '|' then 
	       Left_Border := Left_Border + A;
	       Map(1)(Left_Border) := '/';
	       Left_Border := Left_Border + A;
	       Map(1)(Left_Border -(2*A)) := ' ';
	       O := A;
	       exit;
	    else
	       Map(1)(Left_Border) := '|';
	       Map(1)(Left_Border+1) := ' ';
	       Map(1)(Left_Border-1) := ' ';
	       exit;
	    end if;
	 else
	    Map(1)(Left_Border-1) := '\';
	    Left_Border := Left_Border -2;
	    exit;
	 end if;
      end loop;
      
      loop
	 Random.Reset(G);
	 -- Put(Right_Border);
	 if R = O then
	    R := Random.Random(G);
	 else
	    if R = 1 then
	       R := -1;
	    elsif R = -1 then
	       R := 0;
	    else
	       R := 1;
	    end if;
	 end if;
	 
	 Put(R);
	 
	 if Right_Border = X_Led'Last then
	    if R = -1 then
	       Right_Border := Right_Border + R;
	       Map(1)(Right_Border) := '\';
	       Right_Border := Right_Border + R;
	       Map(1)(Right_Border+2) := ' ';
	    else 
	       Map(1)(Right_Border) := '|';
	       Map(1)(Right_Border-1) := ' ';
	    end if;
	    R := O;
	    exit;
	 elsif Right_Border < X_Led'Last-1 and Right_Border > X_Led'Last-(X_Led'Last/3) Then
	    if R = -1 and Map(2)(Right_Border) = '|' then 
	       Right_Border := Right_Border + R;
	       Map(1)(Right_Border) := '\';
	       Right_Border := Right_Border + R;
	       Map(1)(Right_Border - (2*R)) := ' ';
	       O := R;
	       exit;
	    elsif R = 0 and Map(2)(Right_Border-1) = '/' then 
	       Map(1)(Right_Border) := '|';
	       Map(1)(Right_Border-1) := ' ';
	       O := R;
	       exit;
	    elsif R = 0 and Map(2)(Right_Border+1) = '\'  then 
	       Map(1)(Right_Border) := '|';
	       Map(1)(Right_Border+1) := ' ';
	       O := R;
	       exit;
	    elsif R = 1 and Map(2)(Right_Border) = '|' then 
	       Right_Border := Right_Border + R;
	       Map(1)(Right_Border) := '/';
	       Right_Border := Right_Border + R;
	       Map(1)(Right_Border - (2*R)) := ' ';
	       O := R;
	       exit;
	    else
	       Map(1)(Right_Border) := '|';
	       Map(1)(Right_Border+1) := ' ';
	       Map(1)(Right_Border-1) := ' ';
	       exit;
	    end if;
	 else
	    Map(1)(Right_Border+1) := '/';
	    Right_Border := Right_Border +2;
	    exit;
	 end if;
      end loop;
      
   end New_Top_Row;
   
   procedure Move_Rows_Down(Map : in out World) is
      
   begin
      for I in reverse World'First+1 .. World'last  loop
	 for J in X_Led'Range loop
	    
	    Map(I)(J) := Map(I-1)(J);	    

	 end loop;
      end loop;
   end Move_Rows_Down;
   
end Space_Map;

