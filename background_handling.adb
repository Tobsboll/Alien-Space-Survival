
package body Object_Handling is
   
   --------------------------------------------------
   -- PUT IN SOCKET
   --------------------------------------------------OK
   procedure Put(Socket : in Socket_Type; L: in Object_List) is
      
   begin
      -- if not Empty(L) then
      
      if L /= null then
	 Put_Line(Socket, L.Object_Type);
	 Put_Line(Socket, L.XY_Pos(1));
	 Put_Line(Socket, L.XY_Pos(2));
	 Put_line(Socket, L.Attribute);
	 Put_Line(Socket, L.Direction);
	 Put(Socket, L.Next);
      else
	 Put_Line(Socket,0);
      end if;
      
   end Put;
   --------------------------------------------------
   
   --------------------------------------------------
   -- PUT X Y VALUES
   --------------------------------------------------OK
   procedure Put(L: in Object_List) is
      
   begin
      
      if L /= null then
	 New_Line;
	 Put(L.XY_Pos(1));
	 Put(L.XY_Pos(2));
	 Put(L.Next); 
      end if;
      
   end Put;
   --------------------------------------------------
   --------------------------------------------------
   
   
   --------------------------------------------------
   -- GET FROM SOCKET
   --------------------------------------------------
   procedure Get(Socket: in Socket_Type; L:in out Object_List) is
      Object : Integer;
      X      : Integer;
      Y      : Integer;
      Attr   : Integer;
      Dir    : Integer;
   begin
      Get(Socket, Object);
      if Object = 0 then
	 L := null;
	 
      else
	 Get(Socket, X);
	 Get(Socket, Y);
	 Get(Socket, Attr);
	 Get(Socket, Dir);
	 
	 Create_Object(Object, X, Y, Attr, L, 0 ,Dir);
	 
	 Get(Socket, L.Next);
      --  else
      --  	 Insert_First(Value,Value,L);
      end if;
      
      
   end Get;
   
   
   --------------------------------------------------
   --CREATE OBJECT
   --------------------------------------------------OK

   
   procedure Create_Object(Type_Of_Object : in Integer ;
			   X, Y           : in Integer ;
			   Attr           : in Integer ;
			   L              : in out Object_List;
			   Player         : in Integer := 0;
			   Dir            : in Integer := 0) is
      
      Temp : Object_List;
      
   begin
      
      Temp := new Object_Data_Type;
      Temp.Object_Type := Type_Of_Object;
      Temp.XY_Pos(1)   := X;
      Temp.XY_Pos(2)   := Y;
      Temp.Attribute   := Attr;
      Temp.Player      := Player;
      Temp.Direction   := Dir;
      Temp.Next        := L; 
      L := Temp; 
      
   end Create_Object;
   --------------------------------------------------
   
    --------------------------------------------------
   --INSERT LAST
   --------------------------------------------------OK

   
   procedure Insert_Last  (Type_Of_Object : in Integer ;
			   X, Y           : in Integer ;
			   Attr           : in Integer ;
			   L              : in out Object_List;
			   Player         : in Integer := 0;
			   Dir            : in Integer := 0) is
   begin
      
      if Empty(L) then
	 Create_Object (Type_Of_Object, 
			X, Y,          
			Attr,      
			L,
			Player,
		        Dir);
      else
	 Insert_Last (Type_Of_Object, 
		      X, Y,
		      Attr,
		      L.Next,  ---Rekursion
		      Player,
		      Dir);
      end if;
      end Insert_Last;
   


   --------------------------------------------------
   --| Highest Y Position in a list |----------------- // Eric
   --------------------------------------------------
   function Highest_Y_Position(List : in Object_List;
			     Y    : in Integer := GameBorder_Y+World_Y_Length-2) return Integer is
     
   begin
      if not Empty(List) then
	 if List.XY_Pos(2) < Y then
	    return Highest_Y_Position(List.Next, List.XY_Pos(2));
	 else
	    return Highest_Y_Position(List.Next, Y);
	 end if;
      else
	 return Y;
      end if;
   end Highest_Y_Position;
   --------------------------------------------------
   


   --------------------------------------------------
   --| Lowest Y Position in a list |----------------- // Eric
   --------------------------------------------------
   function Lowest_Y_Position(List : in Object_List;
			      Y    : in Integer := 0) return Integer is
     
   begin
      if not Empty(List) then
	 if List.XY_Pos(2) > Y then
	    return Lowest_Y_Position(List.Next, List.XY_Pos(2));
	 else
	    return Lowest_Y_Position(List.Next, Y);
	 end if;
      else
	 return Y;
      end if;
   end Lowest_Y_Position;
   --------------------------------------------------
   
   
   
   
   --------------------------------------------------
   --| Highest X Position in a list |----------------- // Eric
   --------------------------------------------------
   function Lowest_X_Position(List : in Object_List;
			      X    : in Integer := GameBorder_X+World_X_Length) return Integer is
     
   begin
      if not Empty(List) then
	 if List.XY_Pos(1) < X then
	    return Lowest_X_Position(List.Next, List.XY_Pos(1));
	 else
	    return Lowest_X_Position(List.Next, X);
	 end if;
      else
	 return X;
      end if;
   end Lowest_X_Position;
   --------------------------------------------------
   


   --------------------------------------------------
   --| Lowest X Position in a list |----------------- // Eric
   --------------------------------------------------
   function Highest_X_Position(List : in Object_List;
			       X    : in Integer := 0) return Integer is
      
   begin
      if not Empty(List) then
	 if List.XY_Pos(1) > X then
	    return Highest_X_Position(List.Next, List.XY_Pos(1));
	 else
	    return Highest_X_Position(List.Next, X);
	 end if;
      else
	 return X;
      end if;
   end Highest_X_Position;
   --------------------------------------------------



   --------------------------------------------------
   -- EMPTY
   --------------------------------------------------OK
   
   function Empty(L : in Object_List) return Boolean is
      
   begin
       return L = null;	
      
   end Empty;

   --------------------------------------------------
   -- DELETE ALL OBJECTS
   --------------------------------------------------OK

   procedure DeleteList(L : in out Object_List) is
      
   begin 
      if not Empty(L) then
	 Remove(L);
	 DeleteList(L); -- Rekursion
      end if;
   end DeleteList;
   
   --------------------------------------------------
   -- DELETE SELECTED OBJECTS
   --------------------------------------------------OK

   procedure Delete_Object_In_List(L  : in out Object_List;
				  Obj : in Integer) is
      
   begin 
      if not Empty(L) then
	 if L.Object_Type = Obj then
	    Remove(L);
	    Delete_Object_In_List(L, Obj); -- Rekursion
	 else
	    Delete_Object_In_List(L.Next, Obj); -- Rekursion	    
	 end if;
      end if;
   end Delete_Object_In_List;
   
   
   --------------------------------------------------
   --  -- REMOVE OBJECT
   --  -------------------------------------------------- OK
   
   procedure Remove (L   : in out Object_List) is
       Temp : Object_List;
   begin
   	    Temp := L;
   	    L := L.Next;
   	    Free(Temp);

   end Remove;
   
  




end Object_Handling;
