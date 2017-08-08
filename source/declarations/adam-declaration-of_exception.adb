with
     AdaM.Factory,
     AdaM.Entity,
     AdaM.a_Package;


package body AdaM.Declaration.of_exception
is

   --  Storage Pool
   --

   record_Version  : constant := 1;
   max_Subprograms : constant := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "Declarations.of_exception",
                                           max_Subprograms,
                                           record_Version,
                                           Declaration.of_exception.item,
                                           Declaration.of_exception.view);

   --  Forge
   --

   procedure define (Self : in out Item;   Name : in String)
   is
   begin
      Self.Name := +Name;
   end define;


   overriding
   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;


   function  new_Declaration (Name : in     String) return Declaration.of_exception.view
   is
      new_View : constant Declaration.of_exception.view := Pool.new_Item;
   begin
      define (Declaration.of_exception.item (new_View.all), Name);
      return new_View;
   end new_Declaration;


   procedure free (Self : in out Declaration.of_exception.view)
   is
   begin
      destruct (Declaration.of_exception.item (Self.all));
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



   function  full_Name  (Self : in Item) return String
   is
      use type Entity.view;
   begin
      if Self.parent_Entity = null
      then
         return "Standard." & (+Self.Name);
      else
         return a_Package.view (Self.parent_Entity).full_Name & "." & (+Self.Name);
      end if;
   end full_Name;




   overriding
   function to_Source (Self : in Item) return text_Vectors.Vector
   is
      use ada.Strings.Unbounded;
      the_Line   : Text;
      the_Source : text_Vectors.Vector;

   begin
      append (the_Line, Self.Name);
      append (the_Line, " : exception;");

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

end AdaM.Declaration.of_exception;
