with
     AdaM.Factory;


package body AdaM.Context
is

   --  Storage Pool
   --

   record_Version : constant              := 1;
   max_Contexts   : constant              := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "contexts",
                                           max_Contexts,
                                           record_Version,
                                           Context.item,
                                           Context.view);


   --  Forge
   --

   procedure define (Self : in out Item;   Name : in String)
   is
   begin
      null;
   end define;


   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;



   function new_Context (Name : in String := "") return View
   is
      new_View : constant Context.view := Pool.new_Item;
   begin
      define (Context.item (new_View.all), Name);
      return new_View;
   end new_Context;



   procedure free (Self : in out Context.view)
   is
   begin
      destruct (Context.item (Self.all));
      Pool.free (Self);
   end free;




   --  Attributes
   --

   overriding function Id   (Self : access Item) return AdaM.Id
   is
   begin
      return Pool.to_Id (Self);
   end Id;



   function  Lines    (Self : in     Item)     return context_Line.Vector
   is
   begin
      return Self.Lines;
   end Lines;



   procedure add (Self : in out Item;   the_Line : in context_Line.view)
   is
   begin
      Self.Lines.append (the_Line);
   end add;


   procedure rid (Self : in out Item;   the_Line : in context_Line.view)
   is
   begin
      Self.Lines.delete (Self.Lines.find_Index (the_Line));
   end rid;




   function to_Source (Self : in Item) return text_Vectors.Vector
   is
      the_Source : text_Vectors.Vector;
   begin
      for i in 1 .. Integer (Self.Lines.Length)
      loop
         the_Source.append (Self.Lines.Element (i).to_Source);
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

end AdaM.Context;
