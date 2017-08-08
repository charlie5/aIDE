with
     AdaM.Factory;


package body AdaM.use_Clause.for_type
is

   --  Storage Pool
   --

   record_Version  : constant                := 1;
   max_Subprograms : constant                := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "use_Clauses-for_type",
                                           max_Subprograms,
                                           record_Version,
                                           use_Clause.for_type.item,
                                           use_Clause.for_type.view);

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
      new_View : constant use_Clause.for_type.view := Pool.new_Item;
   begin
      define (use_Clause.for_type.item (new_View.all));
      return new_View;
   end new_Subprogram;


   procedure free (Self : in out use_Clause.for_type.view)
   is
   begin
      destruct (use_Clause.for_type.item (Self.all));
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

end AdaM.use_Clause.for_type;
