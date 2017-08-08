with
     AdaM.Factory;


package body AdaM.Comment
is

   --  Storage Pool
   --

   record_Version : constant                := 1;
   max_Comments   : constant                := 5_000;
--     null_Comment   : constant Comment.item := (Entity.item with others => <>);

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "comments",
                                           max_Comments,
                                           record_Version,
                                           Comment.item,
                                           Comment.view);
--                                             null_Comment);

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


   function new_Comment return View
   is
      new_View : constant Comment.view := Pool.new_Item;
   begin
      define (Comment.item (new_View.all));
      return new_View;
   end new_Comment;


   procedure free (Self : in out Comment.view)
   is
   begin
      destruct (Comment.item (Self.all));
      Pool.free (Self);
   end free;




   --  Attributes
   --


   overriding
   function  Name      (Self : in     Item) return String
   is
      pragma Unreferenced (Self);
   begin
      return "a_Comment";
   end Name;



   overriding
   function Id   (Self : access Item) return AdaM.Id
   is
   begin
      return Pool.to_Id (Self);
   end Id;


   function Lines (Self : in Item) return text_Lines
   is
   begin
      return Self.Lines;
   end Lines;


   procedure Lines_are (Self : in out Item;   Now : in text_Lines)
   is
   begin
      Self.Lines := Now;
   end Lines_are;



   overriding
   function to_Source (Self : in Item) return text_Vectors.Vector
   is
      the_Source : text_Vectors.Vector;

--        procedure add (the_Line : in Text)
--        is
--        begin
--           the_Source.append (the_Line);
--        end add;

   begin
      for i in 1 .. Self.Lines.Length
      loop
         declare
            the_Line : Text renames Self.Lines.Element (Integer (i));
         begin
            the_Source.append ("--  " & the_Line);
         end;
      end loop;

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

end AdaM.Comment;
