with
     AdaM.Factory;


package body AdaM.component_Definition
is

   --  Storage Pool
   --

   record_Version  : constant := 1;
   pool_Size : constant := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "component_Definitions",
                                           pool_Size,
                                           record_Version,
                                           component_Definition.item,
                                           component_Definition.view);

   --  Forge
   --

   procedure define (Self : in out Item;   is_subtype_Indication : in Boolean)
   is
   begin
      if is_subtype_Indication
      then
         Self.subtype_Indication := AdaM.subtype_Indication.new_Indication;
      else
         Self.access_Definition  := AdaM.access_Definition.new_Definition;
      end if;
   end define;


   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;


   function  new_Definition (is_subtype_Indication : in Boolean) return component_Definition.view
   is
      new_View : constant component_Definition.view := Pool.new_Item;
   begin
      define (component_Definition.item (new_View.all),
             is_subtype_Indication);

      return new_View;
   end new_Definition;


   procedure free (Self : in out component_Definition.view)
   is
   begin
      destruct (component_Definition.item (Self.all));
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
   function  Name      (Self : in     Item) return Identifier
   is
   begin
      return "";
   end Name;



   procedure is_Aliased (Self : in out Item;   Now : in Boolean := True)
   is
   begin
      Self.is_Aliased := Now;
   end is_Aliased;


   function  is_Aliased (Self : in     Item) return Boolean
   is
   begin
      return Self.is_Aliased;
   end is_Aliased;



--     procedure subtype_Indication_is (Self :    out Item;   Now : in AdaM.subtype_Indication.view)
--     is
--        use type AdaM.access_Definition.view;
--     begin
--        if Self.access_Definition /= null
--        then
--           raise program_Error with "access_Definition is already set";
--        end if;
--
--        Self.subtype_Indication := Now;
--     end subtype_Indication_is;
--
--     procedure access_Definition_is  (Self :    out Item;   Now : in AdaM.access_Definition.view)
--     is
--        use type AdaM.subtype_Indication.view;
--     begin
--        if Self.subtype_Indication /= null
--        then
--           raise program_Error with "subtype_Indication is already set";
--        end if;
--
--        Self.access_Definition := Now;
--     end access_Definition_is;



   function  is_subtype_Indication (Self : in Item) return Boolean
   is
      use type AdaM.subtype_Indication.view;
   begin
      return Self.subtype_Indication /= null;
   end is_subtype_Indication;



   function  is_access_Definition  (Self : in Item) return Boolean
   is
      use type AdaM.access_Definition.view;
   begin
      return Self.access_Definition /= null;
   end is_access_Definition;


   function  subtype_Indication (Self : in Item) return AdaM.subtype_Indication.view
   is
   begin
      return Self.subtype_Indication;
   end subtype_Indication;


   function  access_Definition  (Self : in Item) return AdaM.access_Definition.view
   is
   begin
      return Self.access_Definition;
   end access_Definition;



--     procedure Type_is  (Self : in out Item;   Now : in AdaM.a_Type.view)
--     is
--     begin
--        Self.my_Type := Now;
--     end Type_is;
--
--
--     function  my_Type (Self : in     Item)     return AdaM.a_Type.view
--     is
--     begin
--        return Self.my_Type;
--     end my_Type;
--
--
--     function  my_Type (Self : access Item)     return access AdaM.a_Type.view
--     is
--     begin
--        return Self.my_Type'Access;
--     end my_Type;
--
--
--
--     procedure Initialiser_is (Self : in out Item;   Now : in String)
--     is
--     begin
--        Self.Initialiser := +Now;
--     end Initialiser_is;
--
--
--     function  Initialiser    (Self : in     Item)     return String
--     is
--     begin
--        return +Self.Initialiser;
--     end Initialiser;
--


   overriding
   function  to_Source (Self : in     Item) return text_Vectors.Vector
   is
      the_Source : text_Vectors.Vector;
   begin
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

end AdaM.component_Definition;
