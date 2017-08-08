with
     AdaM.Factory;


package body AdaM.Declaration.of_renaming.a_subprogram
is

   --  Storage Pool
   --

   record_Version  : constant := 1;
   max_Subprograms : constant := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "Declarations.of_renaming.a_subprogram",
                                           max_Subprograms,
                                           record_Version,
                                           Declaration.of_renaming.a_subprogram.item,
                                           Declaration.of_renaming.a_subprogram.view);

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


   function new_Declaration return View
   is
      new_View : constant Declaration.of_renaming.a_subprogram.view := Pool.new_Item;
   begin
      define (Declaration.of_renaming.a_subprogram.item (new_View.all));
      return new_View;
   end new_Declaration;


   procedure free (Self : in out Declaration.of_renaming.a_subprogram.view)
   is
   begin
      destruct (Declaration.of_renaming.a_subprogram.item (Self.all));
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

end AdaM.Declaration.of_renaming.a_subprogram;
