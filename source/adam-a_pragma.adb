with
     AdaM.Factory;


package body AdaM.a_Pragma
is

   --  Storage Pool
   --

   record_Version : constant                 := 1;
   max_Pragmas    : constant                 := 5_000;
--     null_Pragma    : constant a_Pragma.item := (Entity.item with others => <>);

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "Pragmas",
                                           max_Pragmas,
                                           record_Version,
                                           a_Pragma.item,
                                           a_Pragma.view);
--                                             null_Pragma);

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


   function new_Pragma (Name : in String := "") return View
   is
      new_View : constant a_Pragma.view := Pool.new_Item;
   begin
      define (a_Pragma.item (new_View.all), Name);
      return new_View;
   end new_Pragma;


   procedure free (Self : in out a_Pragma.view)
   is
   begin
      destruct (a_Pragma.item (Self.all));
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



   procedure add_Argument (Self : in out Item;   Now : in String)
   is
   begin
      Self.Arguments.append (+Now);
   end add_Argument;

   function  Arguments    (Self : in     Item)     return text_Lines
   is
   begin
      return Self.Arguments;
   end Arguments;






   overriding
   function to_Source (Self : in Item) return text_Vectors.Vector
   is
      use ada.Strings.Unbounded;

      the_Line   : Text;
      the_Source : text_Vectors.Vector;
   begin
      append (the_Line, "pragma " & Self.Name & ";");
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

end AdaM.a_Pragma;
