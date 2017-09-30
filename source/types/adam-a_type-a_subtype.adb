with
     AdaM.Factory;


package body AdaM.a_Type.a_subtype
is
   --  Storage Pool
   --

   record_Version : constant                := 1;
   pool_Size      : constant                := 5_000;

   package Pool is new AdaM.Factory.Pools (storage_Folder => ".adam-store",
                                           pool_Name      => "subtypes",
                                           max_Items      => pool_Size,
                                           record_Version => record_Version,
                                           Item           => a_subtype.item,
                                           View           => a_subtype.view);

   --  Forge
   --

   procedure define (Self : in out Item;   Name : in String)
   is
   begin
      Self.Name := +Name;
      Self.Indication := subtype_Indication.new_Indication;
   end define;



   overriding
   procedure destruct (Self : in out Item)
   is
   begin
      subtype_Indication.free (Self.Indication);
   end destruct;



   function new_Subtype (Name : in String := "") return a_subtype.View
   is
      new_View : constant a_subtype.view := Pool.new_Item;
   begin
      define (a_subtype.item (new_View.all), Name);
      return new_View;
   end new_Subtype;



   procedure free (Self : in out a_subtype.view)
   is
   begin
      destruct (a_Type.item (Self.all));
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



   function  Indication (Self : in    Item)        return AdaM.subtype_Indication.view
   is
   begin
      return Self.Indication;
   end;



--     function  First    (Self : in     Item)     return String
--     is
--     begin
--        return Self.Indication.First;
--     end First;
--
--
--     procedure First_is (Self : in out Item;   Now : in String)
--     is
--     begin
--        Self.Indication.First_is (Now);
--     end First_is;
--
--
--     function  Last    (Self : in     Item)     return String
--     is
--     begin
--        return Self.Indication.Last;
--     end Last;
--
--
--     procedure Last_is (Self : in out Item;   Now : in String)
--     is
--     begin
--        Self.Indication.Last_is (Now);
--     end Last_is;
--
--
--
--     function  main_Type    (Self : access Item)     return access AdaM.a_Type.view
--     is
--     begin
--        return Self.Indication.main_Type;
--     end main_Type;
--
--
--
--     function  main_Type    (Self : in     Item)  return AdaM.a_Type.view
--     is
--     begin
--        return Self.Indication.main_Type;
--     end main_Type;
--
--
--
--     procedure main_Type_is (Self : in out Item;   Now : in AdaM.a_Type.view)
--     is
--     begin
--        Self.Indication.main_Type_is (Now);
--     end main_Type_is;
--



   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end AdaM.a_Type.a_subtype;
