with
     AdaM.compilation_Unit,
     AdaM.a_Package,
     AdaM.a_Type;


package adam.Environment
--
--
--
is

   type Item is tagged private;

   procedure add   (Self : in out Item;   Unit : in compilation_Unit.view);
   procedure clear (Self : in out Item);

   function  Length (Self : in Item) return Natural;
   function  Unit   (Self : in Item;   Index : Positive) return compilation_Unit.View;

   function  all_Types (Self : in Item) return adam.a_Type.Vector;

   procedure print (Self : in Item);


   procedure standard_package_is (Self : in out Item;   Now : in AdaM.a_Package.view);
   function  standard_Package    (Self : in     Item)     return AdaM.a_Package.view;



private

   type Item is tagged
      record
         Units            : Compilation_Unit.Vector;
         standard_Package : AdaM.a_Package.view;
      end record;


end adam.Environment;
