with
     AdaM.Factory;


package body AdaM.an_Exception
is

   --  Storage Pool
   --

   record_Version  : constant                   := 1;
   max_Subprograms : constant                   := 5_000;
   null_Exception  : constant an_Exception.item := (Source.Entity with others => <>);

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "exceptions",
                                           max_Subprograms,
                                           record_Version,
                                           an_Exception.item,
                                           an_Exception.view,
                                           null_Exception);


   --  Forge
   --

   procedure define (Self : in out Item;   Name : in String)
   is
   begin
      Self.Name := +Name;
   end define;


   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;


   function new_Subprogram (Name : in String := "") return View
   is
      new_View : constant an_Exception.view := Pool.new_Item;
   begin
      define (an_Exception.item (new_View.all), Name);
      return new_View;
   end new_Subprogram;


   procedure free (Self : in out an_Exception.view)
   is
   begin
      destruct (an_Exception.item (Self.all));
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





   overriding
   function to_spec_Source (Self : in Item) return text_Vectors.Vector
   is
      use ada.Strings.Unbounded;
      the_Line   : Text;
      the_Source : text_Vectors.Vector;

   begin
      append (the_Line, Self.Name);
      append (the_Line, " : exception;");

      the_Source.append (the_Line);

      return the_Source;
   end to_spec_Source;


   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end AdaM.an_Exception;
