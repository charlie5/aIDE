with
     AdaM.Factory;


package body AdaM.record_Component
is

   --  Storage Pool
   --

   record_Version  : constant := 1;
   pool_Size : constant := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "record_Components",
                                           pool_Size,
                                           record_Version,
                                           record_Component.item,
                                           record_Component.view);

   --  Forge
   --

   procedure define (Self : in out Item)
   is
   begin
      null;
   end define;


   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;


   function new_Component (Name : in String) return View
   is
      new_View : constant record_Component.view := Pool.new_Item;
   begin
      define (record_Component.item (new_View.all));
      new_View.Name_is (+Name);

      return new_View;
   end new_Component;


   procedure free (Self : in out record_Component.view)
   is
   begin
      destruct (record_Component.item (Self.all));
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



   overriding
   function  Name      (Self : in     Item) return Identifier
   is
   begin
      return +Self.Name;
   end Name;


   procedure Name_is (Self :    out Item;   Now : in Identifier)
   is
   begin
      Self.Name := +(String (Now));
   end Name_is;




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



   overriding
   function  to_Source (Self : in     Item) return text_Vectors.Vector
   is
      the_Source : text_Vectors.Vector;
   begin
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

end AdaM.record_Component;
