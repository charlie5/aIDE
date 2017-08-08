with
     AdaM.Factory;


package body AdaM.Declaration
is

   --  Storage Pool
   --

   record_Version  : constant := 1;
   max_Subprograms : constant := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "Declarations",
                                           max_Subprograms,
                                           record_Version,
                                           Declaration.item,
                                           Declaration.view);

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
      new_View : constant Declaration.view := Pool.new_Item;
   begin
      define (Declaration.item (new_View.all));
      return new_View;
   end new_Subprogram;


   procedure free (Self : in out Declaration.view)
   is
   begin
      destruct (Declaration.item (Self.all));
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
   function Name (Self : in Item) return String
   is
   begin
      return +Self.Name;
   end Name;


   procedure Name_is (Self : in out Item;   Now : in String)
   is
   begin
      Self.Name := +Now;
   end Name_is;


--     function full_Name (Self : in Item) return String
--     is
--     begin
--        return Self.parent_Entity.full_Name & "." & Self.Name;
--     end full_Name;


   overriding
   function  to_Source (Self : in     Item) return text_Vectors.Vector
   is
      pragma Unreferenced (Self);
      the_Source : text_Vectors.Vector;
   begin
      raise Program_Error with "TODO";
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

end AdaM.Declaration;
