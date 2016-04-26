package body Input is
      --------------------------------------------------
   procedure Get_Input(Key_Board_Input : out Key_Type) is
      
      Input : Boolean;
      
   begin
      
      Input := True;
      
      while Input loop
	 
	 Get_Immediate(Key_Board_Input, Input);
	 
	 if Is_Up_Arrow(Key_Board_Input) 
	   or Is_Down_Arrow(Key_Board_Input) 
	   or Is_Left_Arrow(Key_Board_Input) 
	   or Is_Right_Arrow(Key_Board_Input) 
	   or Is_Return(Key_Board_Input) 
	   or Is_Esc(Key_Board_Input)  then 
	    exit;
	 end if;
       	 
      end loop;
      
   exception
      when Ada.Strings.INDEX_ERROR => null;
	 
   end Get_Input;
   --------------------------------------------------
   
   
   --------------------------------------------------
   procedure Get_Input is
      
      Input : Boolean;
      
   begin
      
      Input := True;
      
      while Input loop
	 
	 Get_Immediate(Keyboard_Input, Input);
	 
	 if (Is_Character(Keyboard_Input) and then To_Character(Keyboard_Input)=' ')
	   or (Is_Character(Keyboard_Input) and then To_Character(Keyboard_Input)='m')
	   or Is_Up_Arrow(Keyboard_input) 
	   or Is_Down_Arrow(Keyboard_input) 
	   or Is_Left_Arrow(Keyboard_input) 
	   or Is_Right_Arrow(Keyboard_input) 
	   or Is_Esc(Keyboard_input)  then 
	    exit;
	 end if;
       	 
      end loop;
      
   exception
      when Ada.Strings.INDEX_ERROR => null;
	 
   end Get_Input;
   --------------------------------------------------
   
   
   --------------------------------------------------
   procedure Send_Input(Socket         : in Socket_type) is
      
   begin
      
      if Is_Up_Arrow(Keyboard_input) then Put_Line(Socket, 'w'); 
      elsif Is_Down_Arrow(Keyboard_input) then Put_Line(Socket, 's');
      elsif Is_Left_Arrow(Keyboard_input) then Put_Line(Socket, 'a');
      elsif Is_Right_Arrow(Keyboard_input) then Put_Line(Socket, 'd');
      elsif (Is_Character(Keyboard_Input) and then To_Character(Keyboard_Input)='m') then 
	 Put_Line(Socket, 'm');
      elsif (Is_Character(Keyboard_Input) and then To_Character(Keyboard_Input)=' ') then 
	 Put_Line(Socket, ' '); 
	 
      else Put_Line(Socket, 'o'); -- betyder "ingen input" för servern.
      end if;
      
   exception
      when Ada.Strings.INDEX_ERROR => null;
	 
	 
   end Send_Input;
   --------------------------------------------------   
   
   
   
   -------------------------------------------------- 
   function Is_Up_Arrow return Boolean is
      
   begin
      if Is_Up_Arrow(Keyboard_Input) then
	 return True;
      else
	 return False;
      end if;
   end Is_Up_Arrow;
   -------------------------------------------------- 
   
   -------------------------------------------------- 
   function Is_Down_Arrow return Boolean is
      
   begin
      if Is_Down_Arrow(Keyboard_Input) then
	 return True;
      else
	 return False;
      end if;
   end Is_Down_Arrow;
   -------------------------------------------------- 
   
   -------------------------------------------------- 
   function Is_Left_Arrow return Boolean is
      
   begin
      if Is_Left_Arrow(Keyboard_Input) then
	 return True;
      else
	 return False;
      end if;
   end Is_Left_Arrow;
   -------------------------------------------------- 
   
   -------------------------------------------------- 
   function Is_Right_Arrow return Boolean is
      
   begin
      if Is_Right_Arrow(Keyboard_Input) then
	 return True;
      else
	 return False;
      end if;
   end Is_Right_Arrow;
   -------------------------------------------------- 
   
   -------------------------------------------------- 
   function Is_Return return Boolean is
      
   begin
      if Is_Return(Keyboard_Input) then
	 return True;
      else
	 return False;
      end if;
   end Is_Return;
   -------------------------------------------------- 
   
   -------------------------------------------------- 
   function Is_Esc return Boolean is
      
   begin
      if Is_Esc(Keyboard_Input) then
	 return True;
      else
	 return False;
      end if;
   end Is_Esc;
   -------------------------------------------------- 
   
   
   procedure Get_String(Text        : out String;
			Text_Length : out Integer;
			Max_Text    : in Integer;
			X, Y        : in Integer;
		        Text_Col    : in Colour_Type;
			Back_Col    : in Colour_Type) is
      
      Temp_Text : String(1..Max_Text);
      
   begin
      Text_Length := 0;
      
      loop
	 Set_Colours(Text_Col, Back_Col);
	 
	 Get_Immediate(Keyboard_Input);
	 
	 
	 if Text_Length > 0 or (Is_Character(Keyboard_Input)) then
	    
	    if Is_Return(Keyboard_Input) then 
	       exit;
	    elsif Is_Backspace(Keyboard_Input) then
	       Text_Length := Text_Length - 1;
	    elsif Text_Length < Max_Text then
	       Text_Length := Text_Length + 1;
	       Temp_Text(Text_Length) := To_Character(Keyboard_Input);
	    end if;
	    
	    Goto_XY(X,Y);
	    for I in 1 .. Max_Text loop
	       Put(' ');
	    end loop;
	    Goto_XY(X,Y);
	    
	    Put( Temp_Text (1..Text_Length) );
	 end if;
      end loop;
      
      Text := Temp_Text;
      
      
   exception
      when Ada.Strings.INDEX_ERROR => null;
	 
   end Get_String;
   
   
end Input;
