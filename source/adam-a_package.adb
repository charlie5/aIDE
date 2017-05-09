with
     AdaM.Factory,
     AdaM.Source.utility;


package body AdaM.a_Package
is

   --  Storage Pool
   --

   record_Version : constant            := 1;
   max_Packages   : constant            := 5_000;
   null_Package   : constant a_Package.item := (others => <>);

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "packages",
                                           max_Packages,
                                           record_Version,
                                           a_Package.item,
                                           a_Package.view,
                                           null_Package);

   --  Forge
   --

   procedure define (Self : in out Item;   Name : in String)
   is
   begin
      Self.Name    := +Name;
      Self.Context := AdaM.Context.new_Context ("");
   end define;



   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;



   function new_Package (Name : in String := "") return View
   is
      new_View : constant a_Package.view := Pool.new_Item;
   begin
      define (a_Package.item (new_View.all), Name);
      return new_View;
   end new_Package;



   procedure free (Self : in out a_Package.view)
   is
   begin
      destruct (a_Package.item (Self.all));
      Pool.free (Self);
   end free;




   --  Attributes
   --

   overriding function Id   (Self : access Item) return AdaM.Id
   is
   begin
      return Pool.to_Id (Self);
   end Id;



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



   function Context (Self : in     Item) return AdaM.Context.view
   is
   begin
      return Self.Context;
   end Context;



   procedure add (Self : in out Item;   the_Declaration : in Source.Entity_View)
   is
   begin
      Self.public_Entities.append (the_Declaration);     -- Add the new attribute to current attributes.
   end add;


   procedure rid (Self : in out Item;   the_Declaration : in Source.Entity_View)
   is
   begin
      Self.public_Entities.delete (Self.public_Entities.find_Index (the_Declaration));     -- Remove the old attribute from current attributes.
   end rid;




   function  public_Entities (Self : access     Item) return access Source.Entities
   is
   begin
      return Self.public_Entities'Access;
   end public_Entities;


   procedure public_Entities_are (Self : in out Item;   Now : in Source.Entities)
   is
   begin
      Self.public_Entities := Now;
   end public_Entities_are;



   function to_spec_Source (Self : in Item) return text_Vectors.Vector
   is
      use ada.Strings.unbounded;

      the_Source : text_Vectors.Vector;

      procedure add (the_Line : in Text)
      is
      begin
         the_Source.append (the_Line);
      end add;

   begin
      the_Source.append (Self.Context.to_Source);

      add (+"");
      add ( "package " & Self.Name);
      add (+"is");

      add (+"");

      the_Source.append (Self.public_Entities.to_spec_Source);

      add (+"");
      add ( "end " & Self.Name & ";");

      return the_Source;
   end to_spec_Source;



   function to_body_Source (Self : in Item) return text_Vectors.Vector
   is
      use ada.Strings.unbounded;

      the_Source : text_Vectors.Vector;

      procedure add (the_Line : in Text)
      is
      begin
         the_Source.append (the_Line);
      end add;

   begin
      the_Source.append (Self.Context.to_Source);

      add (+"");
      add ( "package body " & Self.Name);
      add (+"is");

      add (+"");

      the_Source.append (Self.public_Entities.to_body_Source);

      add (+"");
      add ( "end " & Self.Name & ";");

      return the_Source;
   end to_body_Source;



   function requires_Body (Self : in Item) return Boolean
   is
      use AdaM.Source.utility;
   begin
      return contains_Subprograms (Self.public_Entities);
   end requires_Body;



   procedure Parent_is (Self : in out Item;   Now : in a_Package.View)
   is
   begin
      Self.Parent := Now;
   end Parent_is;



   function  Parent    (Self : in Item) return a_Package.view
   is
   begin
      return Self.Parent;
   end Parent;




   function  Children (Self : in Item'Class) return a_Package.Vector
   is
   begin
      return Self.Children;
   end Children;


   procedure add_Child (Self : in out Item;   Child : in a_Package.View)
   is
   begin
      Self.Children.append (Child);
   end add_Child;



   -- Streams
   --

   procedure Item_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              Item)
   is
   begin
      Text'write (Stream, Self.Name);

      a_Package.view  'write (Stream, Self.Parent);
      a_Package.Vector'write (Stream, Self.Progenitors);
      a_Package.Vector'write (Stream, Self.Children);

      AdaM.Context.view'write (Stream, Self.Context);

      Source.Entities'write (Stream, Self.public_Entities);
   end Item_write;



   procedure Item_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             Item)
   is
      Version : constant Positive := Pool.storage_record_Version;
   begin
      case Version
      is
      when 1 =>
         Text'read (Stream, Self.Name);

         a_Package.view  'read (Stream, Self.Parent);
         a_Package.Vector'read (Stream, Self.Progenitors);
         a_Package.Vector'read (Stream, Self.Children);

         AdaM.Context.view'read (Stream, Self.Context);
         Source.Entities  'read (Stream, Self.public_Entities);

      when others =>
         raise Program_Error with "Illegal version number during package restore.";
      end case;
   end Item_read;


   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end AdaM.a_Package;
