with
     AdaM.compilation_Unit,
     AdaM.a_Package,
     AdaM.a_Type,
     Ada.Strings.Unbounded.Hash,
     ada.Containers.Hashed_Maps;

package AdaM.Environment
--
--
--
is

   type Item is tagged private;

   procedure add   (Self : in out Item;   Unit : in compilation_Unit.view);
   procedure clear (Self : in out Item);

   function  Length (Self : in Item) return Natural;
   function  Unit   (Self : in Item;   Index : Positive) return compilation_Unit.View;

   function  all_Types (Self : in Item) return AdaM.a_Type.Vector;

   procedure print          (Self : in Item);
   procedure print_Entities (Self : in Item);


   procedure standard_package_is (Self : in out Item;   Now : in AdaM.a_Package.view);
   function  standard_Package    (Self : in     Item)     return AdaM.a_Package.view;

   function  find  (Self : in Item;   Identifier : in String) return AdaM.a_Type.view;

   function  find  (Self : in Item;   Identifier : in String) return AdaM.a_Package.view;
   function  fetch (Self : in Item;   Identifier : in String) return AdaM.a_Package.view;


   function  parent_Name (Identifier : in String) return String;
   function  simple_Name (Identifier : in String) return String;


private
--     use type AdaM.a_Type.view;
--     package name_Maps_of_types is new ada.Containers.Hashed_Maps (Key_Type        => Text,
--                                                                   Element_Type    => AdaM.a_Type.view,
--                                                                   Hash            => Ada.Strings.Unbounded.Hash,
--                                                                   Equivalent_Keys => "=");
--     subtype name_Map_of_types is name_Maps_of_types.Map;


   type Item is tagged
      record
         Units            : Compilation_Unit.Vector;
         standard_Package : AdaM.a_Package.view;

--           all_Types        : name_Map_of_types;
      end record;


end AdaM.Environment;
