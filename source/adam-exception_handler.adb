with
     adam.Block,
     adam.Factory;


package body adam.exception_Handler
is

   --  Storage Pool
   --

   record_Version : constant             := 1;
   max_Exceptions : constant             := 5_000;
   null_Exception : constant exception_Handler.item := (Source.Entity with others => <>);

   package Pool is new adam.Factory.Pools (".adam-store",
                                           "exceptions",
                                           max_Exceptions,
                                           record_Version,
                                           exception_Handler.item,
                                           exception_Handler.view,
                                           null_Exception);

   --  Vector
   --

   function to_Source (the_exception_Handlers : in Vector) return text_Vectors.Vector
   is
      the_Source : text_Vectors.Vector;
   begin
      for i in 1 .. the_exception_Handlers.Length
      loop
         the_Source.append (the_exception_Handlers.Element (Integer (i)).to_spec_Source);
      end loop;

      return the_Source;
   end to_Source;



   --  Forge
   --

   procedure define (Self : in out Item;   Name : in String)
   is
   begin
      Self.Exceptions.append (+Name);

      Self.Handler := adam.Block.new_Block ("");
   end define;



   procedure destruct (Self : in out Item)
   is
   begin
      Self.Parent.rid (Self'unchecked_Access);
   end destruct;



   function new_Handler (Name   : in String := "";
                         Parent : in adam.Block.view) return exception_Handler.view
   is
      new_Item : constant exception_Handler.view := Pool.new_Item;
   begin
      define (exception_Handler.item (new_Item.all),
              Name);

      new_Item.Parent := Parent;

      return new_Item;
   end new_Handler;



   procedure free (Self : in out exception_Handler.view)
   is
   begin
      destruct (exception_Handler.item (Self.all));
      Pool.free (Self);
   end free;




   --  Attributes
   --

   overriding function Id   (Self : access Item) return adam.Id
   is
   begin
      return Pool.to_Id (Self);
   end Id;


   function exception_Name (Self : in Item;   Id : in Positive) return String
   is
   begin
      return +(Self.Exceptions.Element (Id));
   end exception_Name;


   procedure exception_Name_is (Self : in out Item;   Id  : in Positive;
                                                      Now : in String)
   is
   begin
      Self.Exceptions.Replace_Element (Id, +Now);
   end exception_Name_is;


   function  is_Free   (Self : in     Item;   Slot : in Positive) return Boolean
   is
   begin
      return Self.Exceptions.Element (Slot) = "free";
   end is_Free;



   procedure add_Exception  (Self : in out Item;   Name : in String)
   is
   begin
      Self.Exceptions.Append (+Name);
   end add_Exception;


   function  exception_Count (Self : in     Item)     return Natural
   is
   begin
      return Natural (Self.Exceptions.Length);
   end exception_Count;



   function Handler   (Self : in     Item) return access adam.Block.item'Class
   is
   begin
      return Self.Handler;
   end Handler;



   overriding
   function to_spec_Source (Self : in Item) return text_Lines
   is
      use text_Vectors;
      Lines     : text_Lines;
      not_First : Boolean   := False;
   begin
      Lines.append (+"when ");

      for i in 1 .. Integer (Self.Exceptions.Length)
      loop
         if not Self.is_Free (i)
         then
            if not_First then
               Lines.append (+" | ");
            end if;

            Lines.append (+Self.exception_Name (i));
            not_First := True;
         end if;
      end loop;

      Lines.append (+" => ");
      Lines.append (Self.Handler.to_Source);

      return Lines;
   end to_spec_Source;



   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;
end adam.exception_Handler;