with
     AdaM.Any,
     AdaM.Source,
     AdaM.exception_Handler,
     ada.Streams;

package AdaM.Block
is

   type Item is new Any.Item with private;
   type View is access all Item'Class;



   --  Forge
   --

   function  new_Block (Name : in     String := "") return Block.view;
   procedure free      (Self : in out Block.view);

   procedure destruct  (Self : in out Item);


   --  Attributes
   --

   overriding
   function  Id              (Self : access Item) return AdaM.Id;
   function  Name            (Self : in     Item) return String;
   function  to_Source       (Self : in     Item) return text_Vectors.Vector;

   function  my_Declarations (Self : access Item) return Source.Entities_View;
   function  my_Statements   (Self : access Item) return Source.Entities_View;
   function  my_Handlers     (Self : access Item) return Source.Entities_View;

   procedure add             (Self : in out Item;   the_Handler : in exception_Handler.view);
   procedure rid             (Self : in out Item;   the_Handler : in exception_Handler.view);



private

   type Item is new Any.Item with
      record
         Name            : Text;

         my_Declarations : aliased AdaM.Source.Entities;
         my_Statements   : aliased AdaM.Source.Entities;
         my_Handlers     : aliased AdaM.Source.Entities;
      end record;



   -- Streams
   --
   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);
   procedure View_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;

end AdaM.Block;
