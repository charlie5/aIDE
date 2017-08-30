with
     AdaM.Entity,

     Ada.Containers.Vectors,
     Ada.Streams;


package AdaM.a_Pragma
is

   type Item is new Entity.item   with private;


   -- View
   --
   type View is access all Item'Class;

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View);

   procedure View_read  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : out             View);

   for View'write use View_write;
   for View'read  use View_read;


   --  Vector
   --
   package Vectors is new ada.Containers.Vectors (Positive, View);
   subtype Vector  is     Vectors.Vector;


   --  Forge
   --

   function  new_Pragma   (Name : in     String := "") return a_Pragma.view;
   procedure free         (Self : in out a_Pragma.view);
   procedure destruct     (Self : in out a_Pragma.item);


   --  Attributes
   --

   overriding
   function Id            (Self : access Item) return AdaM.Id;

   overriding
   function  Name         (Self : in     Item)     return Identifier;
   procedure Name_is      (Self : in out Item;   Now : in String);

   procedure add_Argument (Self : in out Item;   Now : in String);
   function  Arguments    (Self : in     Item)     return text_Lines;



   overriding
   function to_Source     (Self : in     Item) return text_Vectors.Vector;


   type Kind is (all_calls_remote,
                 assert,
                 assertion_policy,
                 asynchronous,
                 atomic,
                 atomic_components,
                 attach_handler,
                 convention,
                 cpu,
                 default_storage_pool,
                 detect_blocking,
                 discard_names,
                 dispatching_domain,
                 elaborate,
                 elaborate_all,
                 elaborate_body,
                 export,
                 import,
                 independent,
                 independent_components,
                 inline,
                 inspection_point,
                 interrupt_handler,
                 interrupt_priority,
                 linker_options,
                 list,
                 locking_policy,
                 no_return,
                 normalize_scalars,
                 optimize,
                 pack,
                 page,
                 partition_elaboration_policy,
                 preelaborable_initialization,
                 preelaborate,
                 priority,
                 priority_specific_dispatching,
                 profile,
                 pure,
                 queuing_policy,
                 relative_deadline,
                 remote_call_interface,
                 remote_types,
                 restrictions,
                 reviewable,
                 shared_passive,
                 storage_size,
                 suppress,
                 task_dispatching_policy,
                 unchecked_union,
                 unsuppress,
                 volatile,
                 volatile_components,
                 assertion_policy_2);


private

   type Item is new Entity.item with
      record
         Name      : Text;
         Arguments : text_Lines;
      end record;

end AdaM.a_Pragma;
