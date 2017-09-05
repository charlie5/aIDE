with
     AdaM.Factory;


package body AdaM.a_Type.floating_point_type
is
   --  Storage Pool
   --

   record_Version : constant := 1;
   pool_Size      : constant := 5_000;

   package Pool is new AdaM.Factory.Pools (storage_Folder => ".adam-store",
                                           pool_Name      => "floating_point_types",
                                           max_Items      => pool_Size,
                                           record_Version => record_Version,
                                           Item           => floating_point_type.item,
                                           View           => floating_point_type.view);

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



   function new_Type (Name : in String := "") return floating_point_type.View
   is
      new_View : constant floating_point_type.view := Pool.new_Item;
   begin
      define (floating_point_type.item (new_View.all), Name);
      return new_View;
   end new_Type;



   procedure free (Self : in out floating_point_type.view)
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
   function  to_Source (Self : in Item) return text_Vectors.Vector
   is
      pragma Unreferenced (Self);
      the_Source : text_Vectors.Vector;
   begin
      raise Program_Error with "TODO";
      return the_Source;
   end to_Source;



   function  my_Digits    (Self : in     Item)     return Positive
   is
   begin
      return Self.my_Digits;
   end my_Digits;


   procedure Digits_are (Self : in out Item;   Now : in Positive)
   is
   begin
      Self.my_Digits := Now;
   end Digits_are;



   function  First    (Self : in     Item)     return long_long_Float
   is
   begin
      return Self.First;
   end First;


   procedure First_is (Self : in out Item;   Now : in long_long_Float)
   is
   begin
      Self.First := Now;
   end First_is;


   function  Last    (Self : in     Item)     return long_long_Float
   is
   begin
      return Self.Last;
   end Last;


   procedure Last_is (Self : in out Item;   Now : in long_long_Float)
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

end AdaM.a_Type.floating_point_type;
