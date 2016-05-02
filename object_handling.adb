
package body Object_Handling is
   
   --------------------------------------------------
   -- PUT IN SOCKET
   --------------------------------------------------OK
   procedure Put(Socket : in Socket_Type; L: in Object_List) is
      
   begin
      -- if not Empty(L) then
      
      if L /= null then
	 Put(Socket, L.Object_Type);
	 Put(Socket, L.XY_Pos(1));
	 Put(Socket, L.XY_Pos(2));
	 Put(Socket, L.Attribute);
	 Put(Socket, L.Next);
      else
	 Put(Socket,0);
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
   begin
      Get(Socket, Object);
      if Object = 0 then
	 L := null;
	 
      else
	 Get(Socket, X);
	 Get(Socket, Y);
	 Get(Socket, Attr);
	 
	 Create_Object(Object, X, Y, Attr, L);
	 
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
			   L              : in out Object_List) is
      
      Temp : Object_List;
      
   begin
      
      Temp := new Object_Data_Type;
      Temp.Object_Type := Type_Of_Object;
      Temp.XY_Pos(1)   := X;
      Temp.XY_Pos(2)   := Y;
      Temp.Attribute   := Attr;
      Temp.Next        := L; 
      L := Temp; 
      
   end Create_Object;
   --------------------------------------------------
   


   --------------------------------------------------
   --| Highest Y Position in a list |----------------- // Eric
   --------------------------------------------------
   function Highest_Y(List : in Object_List;
		     Y    : in Integer := GameBorder_Y+World_Y_Length) return Integer is
     
   begin
      if not Empty(List) then
	 if List.XY_Pos(2) < Y then
	    return Lowest_Y(List.Next, List.XY_Pos(2));
	 else
	    return Lowest_Y(List.Next, Y);
	 end if;
      else
	 return Y;
      end if;
   end Highest_Y;
   --------------------------------------------------
   


   --------------------------------------------------
   --| Lowest Y Position in a list |----------------- // Eric
   --------------------------------------------------
   function Lowest_Y(List : in Object_List;
		     Y    : in Integer := 0) return Integer is
     
   begin
      if not Empty(List) then
	 if List.XY_Pos(2) > Y then
	    return Lowest_Y(List.Next, List.XY_Pos(2));
	 else
	    return Lowest_Y(List.Next, Y);
	 end if;
      else
	 return Y;
      end if;
   end Lowest_Y;
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

