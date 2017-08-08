with
     AdaM.Factory;

package body AdaM.Block
is

   --  Storage Pool
   --

   record_Version : constant            := 1;
   max_Blocks     : constant            := 5_000;
--     null_Block     : constant Block.item := (Entity.item with others => <>);

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "blocks",
                                           max_Blocks,
                                           record_Version,
                                           Block.item,
                                           Block.view);
--                                             null_Block);


   --  Forge
   --

   procedure define (Self : in out Item;   Name : in String)
   is
   begin
      Self.Name := +Name;
--        Self.Declarations.append (Declaration.new_Declaration);
--        Self.Statements  .append (Statement.new_Statement ("null;"));
   end define;



   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;



   function new_Block (Name : in String := "") return View
   is
      new_View : constant Block.view := Pool.new_Item;
   begin
      define (Block.item (new_View.all), Name);
      return new_View;
   end new_Block;



   procedure free (Self : in out Block.view)
   is
   begin
      destruct (Block.item (Self.all));
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
   function Name (Self : in Item) return String
   is
   begin
      return +Self.Name;
   end Name;



--     function  my_Declarations (Self : access Item)     return Source.Entities_View
   function  my_Declarations (Self : access Item)     return Entity.Entities_View
   is
   begin
      return Self.my_Declarations'Access;
   end my_Declarations;


--     function  my_Statements (Self : access Item)     return Source.Entities_View
   function  my_Statements (Self : access Item)     return Entity.Entities_View
   is
   begin
      return Self.my_Statements'Access;
   end my_Statements;


--     function  my_Handlers (Self : access Item)     return Source.Entities_View
   function  my_Handlers (Self : access Item)     return Entity.Entities_View
   is
   begin
      return Self.my_Handlers'Access;
   end my_Handlers;



   procedure add (Self : in out Item;   the_Handler : in exception_Handler.view)
   is
   begin
      Self.my_Handlers.append (the_Handler.all'Access);
   end add;


   procedure rid (Self : in out Item;   the_Handler : in exception_Handler.view)
   is
   begin
      Self.my_Handlers.Delete (Self.my_Handlers.Find_Index (the_Handler.all'Access));
   end rid;



   overriding
   function to_Source (Self : in Item) return text_Vectors.Vector
   is
      use -- AdaM.Source,
          ada.Strings.Unbounded;

      the_Line   : Text;
      the_Source : text_Vectors.Vector;

      is_a_subprograms_main_Block : Boolean := False;
   begin
      --  Block Name
      --
      if Self.Name /= ""
      then
         is_a_subprograms_main_Block :=    Self.Name = "function"     -- Check to see if we are a subprograms 'main' block.
                                        or Self.Name = "procedure";   --
         if not is_a_subprograms_main_Block
         then
            the_Line := Self.Name & ":";
            the_Source.append (the_Line);
         end if;
      end if;

      if not is_a_subprograms_main_Block
      then
         the_Line := +("declare");
         the_Source.append (the_Line);
      end if;

--        the_Source.append (to_spec_Source (Self.my_Declarations));
      the_Source.append (Entity.to_spec_Source (Self.my_Declarations));

      the_Line := +("begin");
      the_Source.append (the_Line);

      if Self.my_Statements.Is_Empty
      then
         the_Line := +("null;");
         the_Source.append (the_Line);
      else
--           the_Source.append (Statement.to_Source (Self.Statements));
         the_Source.append (Entity.to_spec_Source (Self.my_Statements));
      end if;

      if not Self.my_Handlers.Is_Empty
      then
         the_Line := +("exception");
         the_Source.append (the_Line);

--           the_Source.append (exception_Handler.to_Source (Self.Handlers));
         the_Source.append (Entity.to_spec_Source (Self.my_Handlers));
      end if;

      if not is_a_subprograms_main_Block
      then
         if Self.Name /= ""
         then
            the_Line := +("end;");
            the_Source.append (the_Line);
         else
            the_Line := "end " & Self.Name & ";";
            the_Source.append (the_Line);
         end if;
      end if;

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

end AdaM.Block;
