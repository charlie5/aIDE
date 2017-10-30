with
     AdaM.Factory;


package body AdaM.a_Type.access_type
is
   --  Storage Pool
   --

   record_Version : constant                := 1;
   pool_Size      : constant                := 5_000;

   package Pool is new AdaM.Factory.Pools (storage_Folder => ".adam-store",
                                           pool_Name      => "access_Types",
                                           max_Items      => pool_Size,
                                           record_Version => record_Version,
                                           Item           => a_Type.access_type.item,
                                           View           => a_Type.access_type.view);

   --  Forge
   --

   procedure define (Self : in out Item;   is_access_to_Object : in Boolean)
   is
      the_Definition : Definition (is_access_to_Object);
   begin
      if is_access_to_Object
      then
         the_Definition.Indication := AdaM.subtype_Indication.new_Indication;
      else
         the_Definition.Subprogram := AdaM.Subprogram.new_Subprogram (Name => "");
      end if;

      Self.Def := the_Definition;
   end define;



   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;



   function new_Type (is_access_to_Object : in Boolean) return access_Type.view
   is
      new_View : constant access_Type.view := Pool.new_Item;
   begin
      define (a_Type.access_type.item (new_View.all),
              is_access_to_Object);

      return new_View;
   end new_Type;



   procedure free (Self : in out access_Type.view)
   is
   begin
      destruct (access_Type.item (Self.all));
      Pool.free (Self);
   end free;



   --  Attributes
   --

   overriding function Id   (Self : access Item) return AdaM.Id
   is
   begin
      return Pool.to_Id (Self);
   end Id;


--     overriding
--     function  Name      (Self : in     Item) return Identifier
--     is
--        pragma Unreferenced (Self);
--     begin
--        return "";
--     end Name;


   overriding
   function  to_Source (Self : in Item) return text_Vectors.Vector
   is
      pragma Unreferenced (Self);
      the_Source : text_Vectors.Vector;
   begin
      raise Program_Error with "TODO";
      return the_Source;
   end to_Source;



   function  has_not_Null (Self : in     Item)     return Boolean
   is
   begin
      return Self.has_not_Null;
   end has_not_Null;


   procedure has_not_Null (Self : in out Item;   Now : in Boolean := True)
   is
   begin
      Self.has_not_Null := Now;
   end has_not_Null;


   function is_access_to_Object (Self : in Item) return Boolean
   is
   begin
      return Self.Def.is_access_to_Object;
   end is_access_to_Object;


   --- Access to Object
   --

   function  Modifier    (Self : in     Item)     return general_access_Modifier
   is
   begin
      return Self.Def.Modifier;
   end Modifier;

   procedure Modifier_is (Self : in out Item;   Now : in general_access_Modifier)
   is
   begin
      Self.Def.Modifier := Now;
   end Modifier_is;


   function  Indication  (Self : in     Item)     return subtype_Indication.view
   is
   begin
      return Self.Def.Indication;
   end Indication;


   --- Access to Subprogram.
   --

   function  is_Protected (Self : in     Item)     return Boolean
   is
   begin
      return Self.Def.is_Protected;
   end is_Protected;

   procedure is_Protected (Self : in out Item;   Now : in Boolean := True)
   is
   begin
      Self.Def.is_Protected := Now;
   end is_Protected;


   function  Subprogram  (Self : in     Item)      return AdaM.Subprogram.view
   is
   begin
      return Self.Def.Subprogram;
   end Subprogram;



   ----------
   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end AdaM.a_Type.access_type;
