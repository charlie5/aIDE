with
     AdaM.Factory;


package body AdaM.subtype_Indication
is
   --  Storage Pool
   --

   record_Version : constant                := 1;
   pool_Size      : constant                := 5_000;

   package Pool is new AdaM.Factory.Pools (storage_Folder => ".adam-store",
                                           pool_Name      => "subtype_Indications",
                                           max_Items      => pool_Size,
                                           record_Version => record_Version,
                                           Item           => subtype_Indication.item,
                                           View           => subtype_Indication.view);

   --  Forge
   --

   procedure define (Self : in out Item;   Name : in String)
   is
   begin
      null;
   end define;



   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;



   function new_Indication (Name : in String := "") return subtype_Indication.View
   is
      new_View : constant subtype_Indication.view := Pool.new_Item;
   begin
      define (subtype_Indication.item (new_View.all), Name);
      return new_View;
   end new_Indication;



   procedure free (Self : in out subtype_Indication.view)
   is
   begin
      destruct (subtype_Indication.item (Self.all));
      Pool.free (Self);
   end free;



   --  Attributes
   --

   overriding function Id   (Self : access Item) return AdaM.Id
   is
   begin
      return Pool.to_Id (Self);
   end Id;


   overriding
   function  to_Source (Self : in Item) return text_Vectors.Vector
   is
      pragma Unreferenced (Self);
      the_Source : text_Vectors.Vector;
   begin
      raise Program_Error with "TODO";
      return the_Source;
   end to_Source;



   function  First    (Self : in     Item)     return String
   is
   begin
      return +Self.First;
   end First;


   procedure First_is (Self : in out Item;   Now : in String)
   is
   begin
      Self.First := +Now;
   end First_is;


   function  Last    (Self : in     Item)     return String
   is
   begin
      return +Self.Last;
   end Last;


   procedure Last_is (Self : in out Item;   Now : in String)
   is
   begin
      Self.Last := +Now;
   end Last_is;


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



   function  main_Type    (Self : access Item)     return access AdaM.a_Type.view
   is
   begin
      return Self.main_Type'Access;
   end main_Type;



   function  main_Type    (Self : in     Item)  return AdaM.a_Type.view
   is
   begin
      return Self.main_Type;
   end main_Type;



   procedure main_Type_is (Self : in out Item;   Now : in AdaM.a_Type.view)
   is
   begin
      Self.main_Type := Now;
   end main_Type_is;


   overriding
   function  Name      (Self : in     Item) return Identifier
   is
      pragma Unreferenced (Self);
   begin
      return "";
   end Name;



   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end AdaM.subtype_Indication;
