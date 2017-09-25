with
     AdaM.Factory;


package body AdaM.Declaration.of_object
is

   --  Storage Pool
   --

   record_Version  : constant := 1;
   pool_Size : constant := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "Declaration.of_objects",
                                           pool_Size,
                                           record_Version,
                                           Declaration.of_object.item,
                                           Declaration.of_object.view);

   --  Forge
   --

   procedure define (Self : in out Item)
   is
   begin
      null;
   end define;


   overriding
   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;


   function new_Declaration (Name : in String) return View
   is
      new_View : constant Declaration.of_object.view := Pool.new_Item;
   begin
      define (Declaration.of_object.item (new_View.all));
      new_View.Name_is (+Name);

      return new_View;
   end new_Declaration;


   procedure free (Self : in out Declaration.of_object.view)
   is
   begin
      destruct (Declaration.of_object.item (Self.all));
      Pool.free (Self);
   end free;



   --  Attributes
   --

   overriding
   function Id   (Self : access Item) return AdaM.Id
   is
   begin
      return Pool.to_Id (Self);
   end Id;


   procedure is_Aliased (Self : in out Item;   Now : in Boolean := True)
   is
   begin
      Self.is_Aliased := Now;
   end is_Aliased;


   function  is_Aliased (Self : in     Item) return Boolean
   is
   begin
      return Self.is_Aliased;
   end is_Aliased;


   procedure is_Constant (Self : in out Item;   Now : in Boolean := True)
   is
   begin
      Self.is_Constant := Now;
   end is_Constant;


   function  is_Constant (Self : in     Item) return Boolean
   is
   begin
      return Self.is_Constant;
   end is_Constant;



   procedure Type_is  (Self : in out Item;   Now : in AdaM.a_Type.view)
   is
   begin
      Self.my_Type := Now;
   end Type_is;


   function  my_Type (Self : in     Item)     return AdaM.a_Type.view
   is
   begin
      return Self.my_Type;
   end my_Type;


   function  my_Type (Self : access Item)     return access AdaM.a_Type.view
   is
   begin
      return Self.my_Type'Access;
   end my_Type;



   procedure Initialiser_is (Self : in out Item;   Now : in String)
   is
   begin
      Self.Initialiser := +Now;
   end Initialiser_is;


   function  Initialiser    (Self : in     Item)     return String
   is
   begin
      return +Self.Initialiser;
   end Initialiser;



   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end AdaM.Declaration.of_object;
