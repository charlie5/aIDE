with
     adam.Factory;


package body adam.context_Line
is

   --  Storage Pool
   --

   record_Version    : constant            := 1;
   max_context_Lines : constant            := 5_000;
   null_context_Line : constant context_Line.item := (others => <>);

   package Pool is new adam.Factory.Pools (".adam-store",
                                           "context_lines",
                                           max_context_Lines,
                                           record_Version,
                                           context_Line.item,
                                           context_Line.view,
                                           null_context_Line);

   --  Vector
   --

   function to_Source (the_Lines : in Vector) return text_Vectors.Vector
   is
      the_Source : text_Vectors.Vector;
   begin
      for i in 1 .. the_Lines.Length
      loop
         the_Source.append (the_Lines.Element (Integer (i)).to_Source);
      end loop;

      return the_Source;
   end to_Source;



   --  Forge
   --

   procedure define (Self : in out Item;   Name : in String)
   is
   begin
      Self.package_Name := +Name;
      Self.Used         := False;
   end define;



   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;



   function new_context_Line (Name : in String := "") return View
   is
      new_View : constant context_Line.view := Pool.new_Item;
   begin
      define (context_Line.item (new_View.all), Name);
      return new_View;
   end new_context_Line;



   procedure free (Self : in out context_Line.view)
   is
   begin
      destruct (context_Line.item (Self.all));
      Pool.free (Self);
   end free;




   --  Attributes
   --

   overriding function Id   (Self : access Item) return adam.Id
   is
   begin
      return Pool.to_Id (Self);
   end Id;


   function  Name (Self : access Item) return access Text
   is
   begin
      return Self.package_Name'Access;
   end Name;



   function  Name (Self : in     Item) return String
   is
   begin
      return +Self.package_Name;
   end Name;



   procedure Name_is   (Self : in out Item;   Now : in String)
   is
   begin
      Self.package_Name := +Now;
   end Name_is;



   function  is_Used   (Self : in     Item)     return Boolean
   is
   begin
      return Self.Used;
   end is_Used;


   procedure is_Used   (Self : in out Item;   Now : in Boolean)
   is
   begin
      Self.Used := Now;
   end is_Used;



   function to_Source (Self : in Item) return text_Vectors.Vector
   is
      use ada.Strings.unbounded;

      the_Line   : Text               := +"with " & Self.Name & ";";
      the_Source : text_Vectors.Vector;
   begin
      if Self.Used then
         append (the_Line, "   use " & Self.Name & ";");
      end if;

      the_Source.append (the_Line);

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
end adam.context_Line;
