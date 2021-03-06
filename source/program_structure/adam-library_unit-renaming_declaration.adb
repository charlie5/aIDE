with
     AdaM.Factory;


package body AdaM.library_Unit.renaming_declaration
is

   --  Storage Pool
   --

   record_Version : constant := 1;
   pool_Size      : constant := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "library_Units-renaming_declaration",
                                           pool_Size,
                                           record_Version,
                                           library_Unit.renaming_declaration.item,
                                           library_Unit.renaming_declaration.view);

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


   function new_Subprogram return View
   is
      new_View : constant library_Unit.renaming_declaration.view := Pool.new_Item;
   begin
      define (library_Unit.renaming_declaration.item (new_View.all));
      return new_View;
   end new_Subprogram;


   procedure free (Self : in out library_Unit.renaming_declaration.view)
   is
   begin
      destruct (library_Unit.renaming_declaration.item (Self.all));
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

end AdaM.library_Unit.renaming_declaration;
