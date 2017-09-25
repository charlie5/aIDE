with
     AdaM.Factory;


package body AdaM.Statement
is

   --  Storage Pool
   --

   record_Version : constant                := 1;
   max_Statements : constant                := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "statements",
                                           max_Statements,
                                           record_Version,
                                           Statement.item,
                                           Statement.view);

   --  Forge
   --

   procedure define (Self : in out Item;   Line : in String)
   is
   begin
      if Line /= ""
      then
         Self.Lines.append (+Line);
      end if;
   end define;



   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;



   function new_Statement (Line : in String := "") return View
   is
      new_View : constant Statement.view := Pool.new_Item;
   begin
      define (Statement.item (new_View.all), Line);
      return new_View;
   end new_Statement;



   procedure free (Self : in out Statement.view)
   is
   begin
      destruct (Statement.item (Self.all));
      Pool.free (Self);
   end free;




   --  Attributes
   --

   overriding
   function Id (Self : access Item) return AdaM.Id
   is
   begin
      return Pool.to_Id (Self);
   end Id;



   overriding
   function Name      (Self : in     Item) return Identifier
   is
      pragma Unreferenced (Self);
   begin
      return "a_Statement";
   end Name;




   overriding
   function to_Source (Self : in Item) return text_Vectors.Vector
   is
   begin
      return Self.Lines;
   end to_Source;



   --  Operations
   --

   procedure add (Self : in out Item;   the_Line : in String)
   is
   begin
      Self.Lines.Append (+the_Line);
   end add;




   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end AdaM.Statement;
