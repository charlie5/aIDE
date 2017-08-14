with
     AdaM.Factory;


package body AdaM.a_Type.enumeration_type
is
   --  Storage Pool
   --

   record_Version : constant := 1;
   pool_Size      : constant := 5_000;

   package Pool is new AdaM.Factory.Pools (storage_Folder => ".adam-store",
                                           pool_Name      => "enumeration_types",
                                           max_Items      => pool_Size,
                                           record_Version => record_Version,
                                           Item           => enumeration_Type.item,
                                           View           => enumeration_Type.view);


   --  Forge
   --

   procedure define (Self : in out Item;   Name : in String)
   is
   begin
      Self.Name := +Name;
   end define;



   function new_Type (Name : in String := "") return enumeration_Type.View
   is
      new_View : constant enumeration_Type.view := Pool.new_Item;
   begin
      define (enumeration_Type.item (new_View.all), Name);
      return new_View;
   end new_Type;



   procedure free (Self : in out enumeration_Type.view)
   is
   begin
      Pool.free (Self);
   end free;



   --  Attributes
   --

   overriding function Id   (Self : access Item) return AdaM.Id
   is
   begin
      return Pool.to_Id (Self);
   end Id;



   function  Literals (Self : in     Item) return enumeration_literal.Vector
   is
   begin
      return Self.Literals;
   end Literals;


   procedure Literals_are (Self : in out Item;   Now : in enumeration_literal.Vector)
   is
   begin
      Self.Literals := Now;
   end Literals_are;



   procedure add_Literal (Self : in out Item;   Value : in String)
   is
      use enumeration_literal;
      the_Literal : constant enumeration_literal.view := new_Literal (Value);
   begin
--        the_Literal.Parent_is (Self.Literals'Access);
      Self.Literals.append (the_Literal);
   end add_Literal;


   procedure rid_Literal (Self : in out Item;   Value : in String)
   is
   begin
      for Each of Self.Literals
      loop
         if Each.Name = Value
         then
            Self.Literals.delete (Self.Literals.find_Index (Each));
            return;
         end if;
      end loop;

      raise Constraint_Error with "Enumeration type does not contain '" & Value & "'";
   end rid_Literal;



   overriding
   function  to_Source   (Self : in Item) return text_Vectors.Vector
   is
      use ada.Strings.unbounded;
      use type enumeration_literal.view;

      the_Source : text_Vectors.Vector;

      procedure add (the_Line : in Text)
      is
      begin
         the_Source.append (the_Line);
      end add;

   begin
      add (+"");
      add ( "type " & Self.Name & " is ");

      add (+"(");

      for Each of Self.Literals
      loop
         if Each /= Self.Literals.last_Element
         then
            add (+Each.Name & ",");
         else
            add (+Each.Name);
         end if;
      end loop;

      add (+");");

      return the_Source;
   end to_Source;




   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end AdaM.a_Type.enumeration_type;
