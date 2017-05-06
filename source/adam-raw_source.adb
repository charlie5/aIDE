with
     AdaM.Factory;


package body adam.raw_source
is

   --  Storage Pool
   --

   record_Version : constant                 := 1;
   max_Sources    : constant                 := 5_000;
   null_Source    : constant raw_Source.item := (Source.Entity with others => <>);

   package Pool is new adam.Factory.Pools (".adam-store",
                                           "raw_source",
                                           max_Sources,
                                           record_Version,
                                           raw_Source.item,
                                           raw_Source.view,
                                           null_Source);

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



   function new_Source return View
   is
      new_View : constant raw_Source.view := Pool.new_Item;
   begin
      define (raw_Source.item (new_View.all));
      return new_View;
   end new_Source;



   procedure free (Self : in out raw_Source.view)
   is
   begin
      destruct (raw_Source.item (Self.all));
      Pool.free (Self);
   end free;



   --  Attributes
   --


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
   function to_spec_Source (Self : in Item) return text_Vectors.Vector
   is
      the_Source : text_Vectors.Vector;
   begin
      for i in 1 .. Self.Lines.Length
      loop
         declare
            the_Line : Text renames Self.Lines.Element (Integer (i));
         begin
            the_Source.append (the_Line);
         end;
      end loop;

      return the_Source;
   end to_spec_Source;



   overriding
   function to_body_Source (Self : in Item) return text_Vectors.Vector
   is
      the_Source : text_Vectors.Vector;
   begin
      raise Program_Error with "TODO";
      return the_Source;
   end to_body_Source;



   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end adam.raw_source;
