with
     AdaM.Factory;


package body AdaM.task_Unit
is

   --  Storage Pool
   --

   record_Version  : constant                := 1;
   max_Subprograms : constant                := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "task_Units",
                                           max_Subprograms,
                                           record_Version,
                                           task_Unit.item,
                                           task_Unit.view);

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
      new_View : constant task_Unit.view := Pool.new_Item;
   begin
      define (task_Unit.item (new_View.all));
      return new_View;
   end new_Subprogram;


   procedure free (Self : in out task_Unit.view)
   is
   begin
      destruct (task_Unit.item (Self.all));
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

end AdaM.task_Unit;
