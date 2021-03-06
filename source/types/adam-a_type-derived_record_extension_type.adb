with
     AdaM.Factory;


package body AdaM.a_Type.derived_record_extension_type
is
   --  Storage Pool
   --

   record_Version : constant := 1;
   pool_Size      : constant := 5_000;

   package Pool is new AdaM.Factory.Pools (storage_Folder => ".adam-store",
                                           pool_Name      => "derived_record_extension_types",
                                           max_Items      => pool_Size,
                                           record_Version => record_Version,
                                           Item           => derived_record_extension_type.item,
                                           View           => derived_record_extension_type.view);

   --  Forge
   --


   procedure define (Self : in out Item;   Name : in String)
   is
   begin
      Self.Name_is (Name);
   end define;



   overriding
   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;



   function new_Type (Name : in String := "") return derived_record_extension_type.View
   is
      new_View : constant derived_record_extension_type.view := Pool.new_Item;
   begin
      define (derived_record_extension_type.item (new_View.all), Name);
      return new_View;
   end new_Type;



   procedure free (Self : in out derived_record_extension_type.view)
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



   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end AdaM.a_Type.derived_record_extension_type;
