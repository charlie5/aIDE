with
     adam.Factory;


package body adam.a_Type.enumeration_type
is
   --  Storage Pool
   --

   record_Version : constant                       := 1;
   max_Types      : constant                       := 5_000;
   null_Type      : constant enumeration_Type.item := (a_Type.discrete_Type with others => <>);

   package Pool is new adam.Factory.Pools (storage_Folder => ".adam-store",
                                           pool_Name      => "enumeration_types",
                                           max_Items      => max_Types,
                                           record_Version => record_Version,
                                           Item           => enumeration_Type.item,
                                           View           => enumeration_Type.view,
                                           null_Item      => null_Type);


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

   overriding function Id   (Self : access Item) return adam.Id
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
   function  to_spec_Source   (Self : in Item) return text_Vectors.Vector
   is
      the_Source : text_Vectors.Vector;
   begin
      raise Program_Error with "TODO";
      return the_Source;
   end to_spec_Source;




   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end adam.a_Type.enumeration_type;
