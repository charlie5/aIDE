with
     AdaM.Factory;


package body AdaM.with_Clause
is

   --  Storage Pool
   --

   record_Version  : constant                := 1;
   max_Subprograms : constant                := 5_000;
   null_Subprogram : constant with_Clause.item := (context_Item.item with others => <>);

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "with_Clauses",
                                           max_Subprograms,
                                           record_Version,
                                           with_Clause.item,
                                           with_Clause.view,
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


   function new_Subprogram return View
   is
      new_View : constant with_Clause.view := Pool.new_Item;
   begin
      define (with_Clause.item (new_View.all));
      return new_View;
   end new_Subprogram;


   procedure free (Self : in out with_Clause.view)
   is
   begin
      destruct (with_Clause.item (Self.all));
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

end AdaM.with_Clause;
