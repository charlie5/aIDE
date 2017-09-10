with
     AdaM.Factory;


package body AdaM.a_Type.array_type
is
   --  Storage Pool
   --

   record_Version : constant := 1;
   pool_Size      : constant := 5_000;

   package Pool is new AdaM.Factory.Pools (storage_Folder => ".adam-store",
                                           pool_Name      => "array_types",
                                           max_Items      => pool_Size,
                                           record_Version => record_Version,
                                           Item           => array_type.item,
                                           View           => array_type.view);

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



   function new_Type (Name : in String := "") return array_type.View
   is
      new_View : constant array_type.view := Pool.new_Item;
   begin
      define (array_type.item (new_View.all), Name);
      return new_View;
   end new_Type;



   procedure free (Self : in out array_type.view)
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



   function  index_Type      (Self : access Item)     return access AdaM.a_Type.view
   is
   begin
      return Self.index_Type'Access;
   end index_Type;


   function  index_Type      (Self : in Item)     return AdaM.a_Type.view
   is
   begin
      return Self.index_Type;
   end index_Type;


   procedure index_Type_is   (Self : in out Item;   Now : in AdaM.a_Type.view)
   is
   begin
      Self.index_Type := Now;
   end index_Type_is;



   function  element_Type      (Self : access Item)     return access AdaM.a_Type.view
   is
   begin
      return Self.element_Type'Access;
   end element_Type;


   function  element_Type    (Self : in Item)     return AdaM.a_Type.view
   is
   begin
      return Self.element_Type;
   end element_Type;


   procedure element_Type_is (Self : in out Item;   Now : in AdaM.a_Type.view)
   is
   begin
      Self.element_Type := Now;
   end element_Type_is;



   function  First    (Self : in     Item)     return String
   is
   begin
      return +Self.First;
   end First;


   procedure First_is (Self : in out Item;   Now : in String)
   is
   begin
      Self.First := +Now;
   end First_is;


   function  Last    (Self : in     Item)     return String
   is
   begin
      return +Self.Last;
   end Last;


   procedure Last_is (Self : in out Item;   Now : in String)
   is
   begin
      Self.Last := +Now;
   end Last_is;



   function  is_Constrained (Self : in     Item)     return Boolean
   is
   begin
      return Self.is_Constrained;
   end is_Constrained;


   procedure is_Constrained (Self : in out Item;   Now : in Boolean := True)
   is
   begin
      Self.is_Constrained := Now;
   end is_Constrained;




   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end AdaM.a_Type.array_type;