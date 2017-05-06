with
     adam.Factory;


package body adam.a_Type.enumeration_literal
is
   --  Storage Pool
   --

   record_Version : constant                          := 1;
   max_Types      : constant                          := 5_000;
   null_Type      : constant enumeration_Literal.item := (adam.a_Type.discrete_Type with others => <>);

   package Pool is new adam.Factory.Pools (storage_Folder => ".adam-store",
                                           pool_Name      => "enumeration_literals",
                                           max_Items      => max_Types,
                                           record_Version => record_Version,
                                           Item           => enumeration_Literal.item,
                                           View           => enumeration_Literal.view,
                                           null_Item      => null_Type);

   --  Forge
   --


   procedure define (Self : in out Item;   Name : in String)
   is
   begin
      Self.Name_is (Name);
   end define;



   overriding
   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;



   function new_Literal (Value : in String := "") return enumeration_Literal.View
   is
      new_View : constant enumeration_Literal.view := Pool.new_Item;
   begin
      define (enumeration_Literal.item (new_View.all), Value);
      return new_View;
   end new_Literal;



   procedure free (Self : in out enumeration_Literal.view)
   is
   begin
      destruct (enumeration_Literal.item (Self.all));
      Pool.free (Self);
   end free;



   --  Attributes
   --

   overriding
   function Id   (Self : access Item) return adam.Id
   is
   begin
      return Pool.to_Id (Self);
   end Id;



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

end adam.a_Type.enumeration_literal;
