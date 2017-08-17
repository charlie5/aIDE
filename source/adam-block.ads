with
     AdaM.Entity,
     AdaM.exception_Handler,

     Ada.Streams;


package AdaM.Block
is

   type Item is new Entity.Item with private;
   type View is access all Item'Class;


   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);
   procedure View_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : out             View);

   --  Forge
   --

   function  new_Block (Name : in     String := "") return Block.view;
   procedure free      (Self : in out Block.view);

   procedure destruct  (Self : in out Item);


   --  Attributes
   --

   overriding
   function  Id              (Self : access Item) return AdaM.Id;
   overriding
   function  Name            (Self : in     Item) return Identifier;
   overriding
   function  to_Source       (Self : in     Item) return text_Vectors.Vector;

   function  my_Declarations (Self : access Item) return Entity.Entities_View;
   function  my_Statements   (Self : access Item) return Entity.Entities_View;
   function  my_Handlers     (Self : access Item) return Entity.Entities_View;

   procedure add             (Self : in out Item;   the_Handler : in exception_Handler.view);
   procedure rid             (Self : in out Item;   the_Handler : in exception_Handler.view);



private

   type Item is new Entity.Item with
      record
         Name            :         Text;

         my_Declarations : aliased AdaM.Entity.Entities;
         my_Statements   : aliased AdaM.Entity.Entities;
         my_Handlers     : aliased AdaM.Entity.Entities;
      end record;



   -- Streams
   --

   for View'write use View_write;
   for View'read  use View_read;

end AdaM.Block;
