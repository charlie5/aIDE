with
     AdaM.Any,

     Ada.Containers.Vectors,
     Ada.Streams;

private
with
     AdaM.subprogram_Declaration,
     AdaM.package_Declaration,
     AdaM.task_Unit,
     AdaM.protected_Unit,
     AdaM.Aspect;


package AdaM.body_Stub
is

   type Item is new Any.item with private;


   -- View
   --
   type View is access all Item'Class;

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);

   procedure View_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;


   --  Vector
   --
   package Vectors is new ada.Containers.Vectors (Positive, View);
   subtype Vector  is     Vectors.Vector;


   --  Forge
   --
   function  new_Subprogram         return body_Stub.view;
   procedure free           (Self : in out body_Stub.view);
   procedure destruct       (Self : in out body_Stub.item);


   -- Attributes
   --

   overriding
   function Id (Self : access Item) return AdaM.Id;



private

   type Kind is (of_Subprogram,
                 of_Package,
                 of_Task,
                 of_Protected);

   type library_Item_or_Subunit (Kind : body_Stub.Kind := of_Subprogram) is
      record
         Aspects : Aspect.view;

         case Kind
         is
            when of_Subprogram =>
               is_Overriding : Boolean;
               Subprogram    : subprogram_Declaration.view;

            when of_Package =>
               my_Package    : package_Declaration.view;

            when of_Task =>
               my_Task       : task_Unit.view;

            when of_Protected =>
               my_Protected  : protected_Unit.view;
         end case;
      end record;


   type Item is new Any.item with
      record
         null;
      end record;

end AdaM.body_Stub;
