with
     AdaM.Entity,
     AdaM.Subprogram,
     AdaM.subtype_Indication,
     AdaM.a_Type,

     Ada.Streams;


package AdaM.a_Type.access_type
is

   type Item is new a_Type.item with private;
   type View is access all Item'Class;


   --  Forge
   --

   function  new_Type (is_access_to_Object : in Boolean) return access_Type.view;

   overriding
   procedure destruct (Self : in out Item);

   procedure free     (Self : in out access_Type.view);


   --  Attributes
   --

   overriding
   function  Id (Self : access Item) return AdaM.Id;

--     overriding
--     function  Name      (Self : in     Item) return Identifier;

   overriding
   function  to_Source (Self : in Item) return text_Vectors.Vector;


   function  has_not_Null (Self : in     Item)     return Boolean;            -- TODO: rename to has_null_Exclusion.
   procedure has_not_Null (Self : in out Item;   Now : in Boolean := True);   -- TODO: rename to has_null_Exclusion.

   function  is_access_to_Object (Self : in     Item) return Boolean;


   --- Access to Object
   --

   type general_access_Modifier is (None, all_Modifier, constant_Modifier);

   function  Modifier    (Self : in     Item)     return general_access_Modifier;
   procedure Modifier_is (Self : in out Item;   Now : in general_access_Modifier);

   function  Indication  (Self : in     Item)     return subtype_Indication.view;


   --- Access to Subprogram.
   --

   function  is_Protected (Self : in     Item)     return Boolean;
   procedure is_Protected (Self : in out Item;   Now : in Boolean := True);

   function  Subprogram  (Self : in     Item)      return Subprogram.view;



private

   type Definition (is_access_to_Object : Boolean := True) is
      record
         case is_access_to_Object
         is
            when True  =>
               Modifier   : general_access_Modifier := None;
               Indication : AdaM.subtype_Indication.view;

            when False =>
               is_Protected : Boolean := False;
               Subprogram   : AdaM.Subprogram.view;
         end case;
      end record;


   type Item is new a_Type.item with
      record
         has_not_Null : Boolean   := False;                 -- TODO: rename to has_null_Exclusion.
         Def          : Definition;
      end record;


   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;


end AdaM.a_Type.access_type;
