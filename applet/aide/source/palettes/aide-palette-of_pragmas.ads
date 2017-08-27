with
     aIDE.Editor,
     AdaM.Entity,

     Gtk.Widget;

private
with
     Gtk.Button,
     Gtk.Window,
     Gtk.Frame;


package aIDE.Palette.of_pragmas
is

   type Item is new Palette.item with private;
   type View is access all Item'Class;


   --  Forge
   --
   function to_source_entities_Palette return View;


   --  Attributes
   --
   function  top_Widget (Self : in     Item) return gtk.Widget.Gtk_Widget;


   --  Operations
   --

   type Filter is (declare_Region, begin_Region);

   procedure show (Self : in out Item;   Invoked_by   : in aIDE.Editor.view;
--                                           Target       : in AdaM.Source.Entities_view;
                                         Target       : in AdaM.Entity.Entities_view;
                   Allowed      : in Filter);
   procedure freshen (Self : in out Item);



private

   use gtk.Window,
       gtk.Frame,
       gtk.Button;


   type Item is new Palette.item with
      record
         Invoked_by : aIDE.Editor.view;
--           Target     : AdaM.Source.Entities_View;
         Target     : AdaM.Entity.Entities_View;

         Top                     : gtk_Window;

         all_calls_remote_Button              : gtk_Button;
         assert_Button                        : gtk_Button;
         assertion_policy_Button              : gtk_Button;
         asynchronous_Button                  : gtk_Button;
         atomic_Button                        : gtk_Button;
         atomic_components_Button             : gtk_Button;
         attach_handler_Button                : gtk_Button;
         convention_Button                    : gtk_Button;
         cpu_Button                           : gtk_Button;
         default_storage_pool_Button          : gtk_Button;
         detect_blocking_Button               : gtk_Button;
         discard_names_Button                 : gtk_Button;
         dispatching_domain_Button            : gtk_Button;
         elaborate_Button                     : gtk_Button;
         elaborate_all_Button                 : gtk_Button;
         elaborate_body_Button                : gtk_Button;
         export_Button                        : gtk_Button;
         import_Button                        : gtk_Button;
         independent_Button                   : gtk_Button;
         independent_components_Button        : gtk_Button;
         inline_Button                        : gtk_Button;
         inspection_point_Button              : gtk_Button;
         interrupt_handler_Button             : gtk_Button;
         interrupt_priority_Button            : gtk_Button;
         linker_options_Button                : gtk_Button;
         list_Button                          : gtk_Button;
         locking_policy_Button                : gtk_Button;
         no_return_Button                     : gtk_Button;
         normalize_scalars_Button             : gtk_Button;
         optimize_Button                      : gtk_Button;
         pack_Button                          : gtk_Button;
         page_Button                          : gtk_Button;
         partition_elaboration_policy_Button  : gtk_Button;
         preelaborable_initialization_Button  : gtk_Button;
         preelaborate_Button                  : gtk_Button;
         priority_Button                      : gtk_Button;
         priority_specific_dispatching_Button : gtk_Button;
         profile_Button                       : gtk_Button;
         pure_Button                          : gtk_Button;
         queuing_policy_Button                : gtk_Button;
         relative_deadline_Button             : gtk_Button;
         remote_call_interface_Button         : gtk_Button;
         remote_types_Button                  : gtk_Button;
         restrictions_Button                  : gtk_Button;
         reviewable_Button                    : gtk_Button;
         shared_passive_Button                : gtk_Button;
         storage_size_Button                  : gtk_Button;
         suppress_Button                      : gtk_Button;
         task_dispatching_policy_Button       : gtk_Button;
         unchecked_union_Button               : gtk_Button;
         unsuppress_Button                    : gtk_Button;
         volatile_Button                      : gtk_Button;
         volatile_components_Button           : gtk_Button;
         assertion_policy_2_Button            : gtk_Button;





         new_type_Frame          : gtk_Frame;
         raw_source_Button       : Gtk_Button;
         comment_Button          : Gtk_Button;
         enumeration_type_Button : Gtk_Button;
         close_Button            : gtk_Button;
      end record;

end aIDE.Palette.of_pragmas;
