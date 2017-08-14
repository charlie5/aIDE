with
     AdaM.Factory;


package body AdaM.library_Item
is

   --  Storage Pool
   --

   record_Version  : constant := 1;
   pool_Size       : constant := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "library_items",
                                           pool_Size,
                                           record_Version,
                                           library_Item.item,
                                           library_Item.view);

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


   function new_Item (Unit : in AdaM.library_Unit.view) return library_Item.view
   is
      new_View : constant library_Item.view := Pool.new_Item;
   begin
      define (library_Item.item (new_View.all));
      new_View.library_Unit := Unit;

      return new_View;
   end new_Item;


   procedure free (Self : in out library_Item.view)
   is
   begin
      destruct (library_Item.item (Self.all));
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



   procedure Unit_is (Self : in out Item;   Now : AdaM.library_Unit.view)
   is
   begin
      Self.library_Unit := Now;
   end Unit_is;


   function  Unit    (Self : in     Item)  return AdaM.library_Unit.view
   is
   begin
      return Self.library_Unit;
   end Unit;



   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end AdaM.library_Item;
