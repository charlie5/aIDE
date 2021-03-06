with
     AdaM.Block,
     AdaM.Factory;


package body AdaM.exception_Handler
is

   --  Storage Pool
   --

   record_Version : constant             := 1;
   max_Exceptions : constant             := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "exception_handlers",
                                           max_Exceptions,
                                           record_Version,
                                           exception_Handler.item,
                                           exception_Handler.view);

   --  Vector
   --

   function to_Source (the_exception_Handlers : in Vector) return text_Vectors.Vector
   is
      the_Source : text_Vectors.Vector;
   begin
      for i in 1 .. the_exception_Handlers.Length
      loop
         the_Source.append (the_exception_Handlers.Element (Integer (i)).to_Source);
      end loop;

      return the_Source;
   end to_Source;



   --  Forge
   --

   procedure define (Self : in out Item)
   is
   begin
      Self.Handler := Block_view (AdaM.Block.new_Block (""));
   end define;



   procedure destruct (Self : in out Item)
   is
   begin
      Self.Parent.rid (Self'unchecked_Access);
   end destruct;



   function new_Handler (Parent : in AdaM.Block.view) return exception_Handler.view
   is
      new_Item : constant exception_Handler.view := Pool.new_Item;
   begin
      define (exception_Handler.item (new_Item.all));
      new_Item.Parent := Block_view (Parent);

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

   overriding
   function  Name      (Self : in     Item) return Identifier
   is
      pragma Unreferenced (Self);
   begin
      return "exception_Handler";
   end Name;



   overriding function Id   (Self : access Item) return AdaM.Id
   is
   begin
      return Pool.to_Id (Self);
   end Id;



   function my_Exception (Self : in Item;   Id : in Positive) return AdaM.Declaration.of_exception.view
   is
   begin
      return Self.Exceptions.Element (Id);
   end my_Exception;


   procedure my_Exception_is (Self : in out Item;   Id  : in Positive;
                                                    Now : in AdaM.Declaration.of_exception.view)
   is
   begin
      Self.Exceptions.Replace_Element (Id, Now);
   end my_Exception_is;



   function  is_Free   (Self : in     Item;   Slot : in Positive) return Boolean
   is
      use type Declaration.of_exception.view;
   begin
      return Self.Exceptions.Element (Slot) = null;
   end is_Free;




   procedure add_Exception   (Self : in out Item;   the_Exception : in AdaM.Declaration.of_exception.view)
   is
   begin
      Self.Exceptions.append (the_Exception);
   end add_Exception;



   function  exception_Count (Self : in     Item)     return Natural
   is
   begin
      return Natural (Self.Exceptions.Length);
   end exception_Count;




   function Handler   (Self : in     Item) return access AdaM.Block.item'Class
   is
   begin
      return Self.Handler;
   end Handler;



   overriding
   function to_Source (Self : in Item) return text_Lines
   is
      use text_Vectors;
      use type AdaM.Declaration.of_exception.view;

      Lines     : text_Lines;
      not_First : Boolean   := False;
   begin
      Lines.append (+"when ");

--        for i in 1 .. Integer (Self.Exceptions.Length)
      for i in 1 .. Integer (Self.Exceptions.Length)
      loop
         if not Self.is_Free (i)
         then
            if not_First then
               Lines.append (+" | ");
            end if;

            if Self.Exceptions.Element (i) = null
            then
               Lines.append (+"constraint_Error");
            else
               Lines.append (+String (Self.Exceptions.Element (i).full_Name));
            end if;

            not_First := True;
         end if;
      end loop;

      Lines.append (+" => ");
      Lines.append (Self.Handler.to_Source);

      return Lines;
   end to_Source;



   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;


   procedure Block_view_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                               Self   : in              Block_view)
   is
   begin
      Block.View_write (Stream, Block.view (Self));
   end Block_view_write;

   procedure Block_view_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                              Self   : out             Block_view)
   is
   begin
      Block.View_read (Stream, Block.view (Self));
   end Block_view_read;


end AdaM.exception_Handler;
