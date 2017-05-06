with
     adam.Factory;


package body adam.a_Type.constrained_array_type
is
   --  Storage Pool
   --

   record_Version : constant                             := 1;
   max_Types      : constant                             := 5_000;
   null_Type      : constant constrained_array_type.item := (Source.Entity with others => <>);

   package Pool is new adam.Factory.Pools (storage_Folder => ".adam-store",
                                           pool_Name      => "constrained_array_types",
                                           max_Items      => max_Types,
                                           record_Version => record_Version,
                                           Item           => constrained_array_type.item,
                                           View           => constrained_array_type.view,
                                           null_Item      => null_Type);


   --  Forge
   --

   procedure define (Self : in out Item;   Name : in String)
   is
   begin
      Self.Name := +Name;
   end define;



   overriding
   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;



   function new_Type (Name : in String := "") return constrained_array_type.View
   is
      new_View : constant constrained_array_type.view := Pool.new_Item;
   begin
      define (constrained_array_type.item (new_View.all), Name);
      return new_View;
   end new_Type;



   procedure free (Self : in out constrained_array_type.view)
   is
   begin
      destruct (a_Type.item (Self.all));
      Pool.free (Self);
   end free;



   --  Attributes
   --

   overriding function Id   (Self : access Item) return adam.Id
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

end adam.a_Type.constrained_array_type;