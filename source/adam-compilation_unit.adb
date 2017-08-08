with
     AdaM.Factory;


package body AdaM.compilation_Unit
is

   --  Storage Pool
   --

   record_Version : constant            := 1;
   max_Units      : constant            := 5_000;
--     null_Unit      : constant compilation_Unit.item := (others => <>);

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "compilation_Units",
                                           max_Units,
                                           record_Version,
                                           compilation_Unit.item,
                                           compilation_Unit.view);
--                                             null_Unit);

   --  Forge
   --

   procedure define (Self : in out Item;   Name    : in String;
                                           of_Kind : in unit_Kind)
   is
   begin
      Self.Name := +Name;

      case of_Kind
      is
         when library_unit_Kind =>
            Self.library_Item := (Kind         => library_unit_Kind,
                                  library_Item => null);
         when subunit_Kind =>
            Self.library_Item := (Kind    => subunit_Kind,
                                  Subunit => null);
      end case;
   end define;



   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;



   function  new_compilation_Unit (Name : in String := "") return compilation_Unit.view
   is
      new_Unit : constant compilation_Unit.view := Pool.new_Item;
   begin
      new_Unit.Name := +Name;
      return new_Unit;
   end new_compilation_Unit;



   function new_library_Unit (Name     : in String := "";
                              the_Item : in AdaM.library_Item.view) return compilation_Unit.view
   is
      new_View : constant compilation_Unit.view := Pool.new_Item;
   begin
      define (compilation_Unit.item (new_View.all), Name, library_unit_Kind);
      new_View.library_Item.library_Item := the_Item;

      return new_View;
   end new_library_Unit;


   function new_Subunit (Name     : in String := "";
                         the_Unit : in Subunit.view) return compilation_Unit.view
   is
      new_View : constant compilation_Unit.view := Pool.new_Item;
   begin
      define (compilation_Unit.item (new_View.all), Name, subunit_Kind);
      new_View.library_Item.Subunit := the_Unit;

      return new_View;
   end new_Subunit;



   procedure free (Self : in out compilation_Unit.view)
   is
   begin
      destruct (compilation_Unit.item (Self.all));
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




   function Kind         (Self : in Item) return unit_Kind
   is
   begin
      return Self.library_Item.Kind;
   end Kind;


   function library_Item (Self : in Item) return AdaM.library_Item.view
   is
   begin
      return Self.library_Item.library_Item;
   end library_Item;




--     procedure add (Self : in out Item;   Entity : in Source.Entity_View)
--     is
--        use type Source.Entity_View;
--     begin
--        if Entity = null
--        then
--           raise Program_Error with "Attempt to add a null entity";
--        end if;
--
--        Self.Entities.append (Entity);
--     end add;



--     procedure clear (Self : in out Item)
--     is
--     begin
--        Self.Entities.clear;
--     end clear;



--     function Length (Self : in Item) return Natural
--     is
--     begin
--        return Natural (Self.Entities.Length);
--     end Length;



--     function Entity   (Self : in Item;   Index : Positive) return Source.Entity_View
--     is
--     begin
--        return Self.Entities.Element (Index);
--     end Entity;



   function  Name    (Self : in     Item)     return String
   is
   begin
      return +Self.Name;
   end Name;


   procedure Name_is (Self : in out Item;   Now : in String)
   is
   begin
      Self.Name := +Now;
   end Name_is;








   function  Entity    (Self : in     Item)     return AdaM.Entity.view
   is
   begin
      return Self.Entity;
   end Entity;



   procedure Entity_is (Self : in out Item;   Now : in AdaM.Entity.view)
   is
   begin
      Self.Entity := Now;
   end Entity_is;




   -- Streams
   --

   procedure Item_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              Item)
   is
   begin
      Text'write (Stream, Self.Name);
--        Source.Entities'Output (Stream, Self.Entities);
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
--           Self.Entities := Source.Entities'Input (Stream);

      when others =>
         raise Program_Error with "Illegal version number during compilation unit restore.";
      end case;
   end Item_read;


   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;


end AdaM.compilation_Unit;
