with
     AdaM.Factory;


package body AdaM.a_Type.signed_integer_type
is
   --  Storage Pool
   --

   record_Version : constant := 1;
   max_Types      : constant := 5_000;

   package Pool is new AdaM.Factory.Pools (storage_Folder => ".adam-store",
                                           pool_Name      => "signed_integer_types",
                                           max_Items      => max_Types,
                                           record_Version => record_Version,
                                           Item           => signed_integer_type.item,
                                           View           => signed_integer_type.view);

   --  Forge
   --

   procedure define (Self : in out Item;   Name : in String)
   is
   begin
      Self.Name := +Name;
   end define;



   overriding
   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;



   function new_Type (Name : in String := "") return signed_integer_type.View
   is
      new_View : constant signed_integer_type.view := Pool.new_Item;
   begin
      define (signed_integer_type.item (new_View.all), Name);
      return new_View;
   end new_Type;



   procedure free (Self : in out signed_integer_type.view)
   is
   begin
      destruct (a_Type.item (Self.all));
      Pool.free (Self);
   end free;



   --  Attributes
   --

   overriding function Id   (Self : access Item) return AdaM.Id
   is
   begin
      return Pool.to_Id (Self);
   end Id;



   overriding
   function  to_Source   (Self : in Item) return text_Vectors.Vector
   is
      pragma Unreferenced (Self);
      the_Source : text_Vectors.Vector;
   begin
      raise Program_Error with "TODO";
      return the_Source;
   end to_Source;




   function  First    (Self : in     Item)     return Long_Long_Integer
   is
   begin
      return Self.First;
   end First;


   procedure First_is (Self : in out Item;   Now : in Long_Long_Integer)
   is
   begin
      Self.First := Now;
   end First_is;


   function  Last    (Self : in     Item)     return Long_Long_Integer
   is
   begin
      return Self.Last;
   end Last;


   procedure Last_is (Self : in out Item;   Now : in Long_Long_Integer)
   is
   begin
      Self.Last := Now;
   end Last_is;




   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end AdaM.a_Type.signed_integer_type;
