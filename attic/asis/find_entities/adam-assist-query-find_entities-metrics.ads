with
     AdaM.Environment,
     AdaM.Entity,
--       AdaM.Source,
     AdaM.compilation_Unit,
     AdaM.a_Package,
     AdaM.a_Type,

     AdaM.Declaration.of_package,

     ada.Strings.Unbounded.Hash,
     ada.Containers.Hashed_Maps;


package AdaM.Assist.Query.find_Entities.Metrics
is

   Environment      : AdaM.Environment.item;
   standard_Unit    : AdaM.compilation_Unit.item;

   compilation_Unit : AdaM.compilation_Unit.item;   -- Current
   current_Packages : AdaM.a_Package.Vector;

   all_Types        : AdaM.a_Type.Vector;


   use type a_Package.view;
   package name_Maps_of_package is new ada.Containers.Hashed_Maps (Key_Type        => ada.Strings.Unbounded.Unbounded_String,
                                                                   Element_Type    => a_Package.view,
                                                                   Hash            => ada.Strings.Unbounded.Hash,
                                                                   Equivalent_Keys => "=");
   all_Packages : name_Maps_of_package.Map;



   current_compilation_Unit    : AdaM.compilation_Unit.view;
   current_package_Declaration : AdaM.Declaration.of_package.view;



--     current_Parent : AdaM.Source.Entity_View;
   current_Parent : Entity.view;


   procedure dummy;

end AdaM.Assist.Query.find_Entities.Metrics;
