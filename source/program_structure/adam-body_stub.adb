with
     AdaM.Factory;


package body AdaM.body_Stub
is

   --  Storage Pool
   --

   record_Version  : constant := 1;
   pool_Size : constant := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "body_Stubs",
                                           pool_Size,
                                           record_Version,
                                           body_Stub.item,
                                           body_Stub.view);

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


   function new_Subprogram return View
   is
      new_View : constant body_Stub.view := Pool.new_Item;
   begin
      define (body_Stub.item (new_View.all));
      return new_View;
   end new_Subprogram;


   procedure free (Self : in out body_Stub.view)
   is
   begin
      destruct (body_Stub.item (Self.all));
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


   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end AdaM.body_Stub;
