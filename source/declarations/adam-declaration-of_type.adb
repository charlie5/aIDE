with
     AdaM.Factory;


package body AdaM.Declaration.of_type
is

   --  Storage Pool
   --

   record_Version  : constant                := 1;
   max_Subprograms : constant                := 5_000;
   null_Subprogram : constant Declaration.of_type.item := (Declaration.item with others => <>);

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "Declaration.of_types",
                                           max_Subprograms,
                                           record_Version,
                                           Declaration.of_type.item,
                                           Declaration.of_type.view,
                                           null_Subprogram);

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


   function new_Declaration return View
   is
      new_View : constant Declaration.of_type.view := Pool.new_Item;
   begin
      define (Declaration.of_type.item (new_View.all));
      return new_View;
   end new_Declaration;


   procedure free (Self : in out Declaration.of_type.view)
   is
   begin
      destruct (Declaration.of_type.item (Self.all));
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

end AdaM.Declaration.of_type;
