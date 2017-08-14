with
     AdaM.Factory;


package body AdaM.library_Unit.declaration
is

   --  Storage Pool
   --

   record_Version  : constant                := 1;
   pool_Size : constant                := 5_000;
   null_Subprogram : constant library_Unit.declaration.item := (others => <>);

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "library_Units-declaration",
                                           pool_Size,
                                           record_Version,
                                           library_Unit.declaration.item,
                                           library_Unit.declaration.view,
                                           null_Subprogram);

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


   function new_Subprogram return View
   is
      new_unit_Declaration : constant library_Unit.declaration.view       := Pool.new_Item;
      new_Subprogram       : constant AdaM.Declaration.of_subprogram.view := AdaM.Declaration.of_subprogram.new_Declaration;
   begin
      define (library_Unit.declaration.item (new_unit_Declaration.all));
      new_unit_Declaration.Declaration := (a_Subprogram, new_Subprogram);

      return new_unit_Declaration;
   end new_Subprogram;


   function  new_Package      return library_Unit.declaration.view
   is
      new_unit_Declaration : constant library_Unit.declaration.view    := Pool.new_Item;
      new_Package          : constant AdaM.Declaration.of_package.view := AdaM.Declaration.of_package.new_Declaration;
   begin
      define (library_Unit.declaration.item (new_unit_Declaration.all));
      new_unit_Declaration.Declaration := (a_Package, new_Package);

      return new_unit_Declaration;
   end new_Package;


   function  new_Generic      return library_Unit.declaration.view
   is
      new_unit_Declaration : constant library_Unit.declaration.view    := Pool.new_Item;
      new_Generic          : constant AdaM.Declaration.of_generic.view := AdaM.Declaration.of_generic.new_Declaration;
   begin
      define (library_Unit.declaration.item (new_unit_Declaration.all));
      new_unit_Declaration.Declaration := (a_Generic, new_Generic);

      return new_unit_Declaration;
   end new_Generic;


   function  new_Intantiation return library_Unit.declaration.view
   is
      new_unit_Declaration : constant library_Unit.declaration.view          := Pool.new_Item;
      new_Instaniation     : constant AdaM.Declaration.of_instantiation.view := AdaM.Declaration.of_instantiation.new_Declaration;
   begin
      define (library_Unit.declaration.item (new_unit_Declaration.all));
      new_unit_Declaration.Declaration := (an_Instantiation, new_Instaniation);

      return new_unit_Declaration;
   end new_Intantiation;




   procedure free (Self : in out library_Unit.declaration.view)
   is
   begin
      destruct (library_Unit.declaration.item (Self.all));
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



   function my_Package (Self : in Item) return AdaM.Declaration.of_package.view
   is
   begin
      return Self.Declaration.of_Package;
   end my_Package;



   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end AdaM.library_Unit.declaration;
