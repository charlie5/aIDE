with
     interfaces.C.Pointers,

     ada.Streams.Stream_IO,
     ada.Containers.Vectors,
     ada.Containers.Hashed_Maps,
     ada.Unchecked_Conversion,
     ada.Directories,

     System.Parameters;
with Ada.Text_IO;


package body AdaM.Factory
is

   type   Storer is access procedure;
   type Restorer is access procedure;


   package   storer_Vectors is new ada.Containers.Vectors (Positive, Storer);
   package restorer_Vectors is new ada.Containers.Vectors (Positive, Restorer);

   all_Storers   :   storer_Vectors.Vector;
   all_Restorers : restorer_Vectors.Vector;


   procedure register_Storer (the_Storer : access procedure)
   is
   begin
      all_Storers.append (the_Storer);
   end register_Storer;


   procedure register_Restorer (the_Restorer : access procedure)
   is
   begin
      all_Restorers.append (the_Restorer);
   end register_Restorer;




   type to_View_function is access function (Id  : in AdaM.Id) return Any_view;

   function Hash is new ada.Unchecked_Conversion (ada.Tags.Tag, ada.Containers.Hash_Type);
   use type ada.Tags.Tag;

   package tag_Maps_of_to_View_function is new ada.Containers.Hashed_Maps (Key_Type        => ada.Tags.Tag,
                                                                           Element_Type    => to_View_function,
                                                                           Hash            => Hash,
                                                                           Equivalent_Keys => "=");

   tag_Map_of_to_View_function : tag_Maps_of_to_View_function.Map;

   procedure  register_to_view_Function (the_Tag      : in     ada.Tags.Tag;
                                         the_Function : access function (Id  : in AdaM.Id) return Any_view)
   is
   begin
      tag_Map_of_to_View_function.insert (the_Tag, the_Function);
   end register_to_view_Function;



   function to_View (Id : in AdaM.Id;   Tag : in ada.Tags.Tag) return Any_view
   is
      use tag_Maps_of_to_View_function;
      the_Function : constant to_View_function := Element (tag_Map_of_to_View_function.Find (Tag));
   begin
      return the_Function (Id);
   end to_View;



   --  Pools
   --


   package body Pools
   is
      use Interfaces.C;

      -- Arrays and Pointers for our Pool.
      --

      subtype item_Id is AdaM.Id range 1 .. AdaM.Id'Last;

--        type    Items   is array (item_Id range <>) of aliased Item;

--        package item_Pointers is new interfaces.C.Pointers (Index              => item_Id,
--                                                            Element            => Item,
--                                                            Element_Array      => Items,
--                                                            Default_Terminator => null_Item);
      type    Items   is array (item_Id range <>) of aliased Item;


      type Addr is mod 2 ** System.Parameters.ptr_bits;

--        function To_Pointer is new Ada.Unchecked_Conversion (Addr,      Pointer);
      function To_Addr    is new Ada.Unchecked_Conversion (View,   Addr);
--        function To_Addr    is new Ada.Unchecked_Conversion (Interfaces.C.ptrdiff_t, Addr);
      function To_Ptrdiff is new Ada.Unchecked_Conversion (Addr,      Interfaces.C.ptrdiff_t);

      Elmt_Size : constant ptrdiff_t :=   (Items'Component_Size + System.Storage_Unit - 1)
                                        / System.Storage_Unit;


      function "-" (Left  : in View;
                    Right : in View) return ptrdiff_t
      is
      begin
         if        Left  = null
           or else Right = null
         then
            raise constraint_Error;
         end if;

         return   To_Ptrdiff (To_Addr (Left) - To_Addr (Right))
                / Elmt_Size;
      end "-";




      --  The storage pool.
      --
      Pool      : Items (1 .. item_Id (max_Items));
      pool_Last : AdaM.Id                         := null_Id;

      stored_record_Version : Positive;

      function storage_record_Version return Positive
      is
      begin
         return stored_record_Version;
      end storage_record_Version;


      package view_Vectors is new ada.Containers.Vectors (Positive, View);

      freed_Views : view_Vectors.Vector;


      --  'View' to 'Id' Resolution.
      --

      function to_View (Id : in AdaM.Id) return View
      is
      begin
         return Pool (Id)'Access;
      end to_View;


      function to_View (Id : in AdaM.Id) return Any_view
      is
      begin
         declare
            the_View : constant View := Pool (Id)'Access;
         begin
            return Any_view (the_View);
         end;
      end to_View;



--        function to_Id (From : in View) return AdaM.Id
--        is
--           use item_Pointers;
--           Start : constant item_Pointers.Pointer := Pool (Pool'First)'Access;
--        begin
--           return AdaM.Id (item_Pointers.Pointer (From) - Start) + 1;
--        end to_Id;


      function to_Id (From : in View) return AdaM.Id
      is
--           use item_Pointers;
         Start : constant View := Pool (Pool'First)'Access;
      begin
         return AdaM.Id (From - Start) + 1;
      end to_Id;



--        function to_Id (From : in View) return AdaM.Id
--        is
--           use System;
--           Start : constant System.Address := Pool (Pool'First)'Address;
--        begin
--           return AdaM.Id (From.all'Address - Start) + 1;
--        end to_Id;


      function new_Item return View
      is
         new_View : View;
      begin
         if freed_Views.Is_Empty
         then
            pool_Last := pool_Last + 1;
            new_View  := Pool (pool_Last)'Access;
         else
            new_View  := freed_Views.last_Element;
            freed_Views.delete_Last;
         end if;

         return new_View;
      end new_Item;


      procedure free (Self : in out View)
      is
      begin
         freed_Views.append (Self);
         Self := null;
      end free;


      -- Persistence
      --

      procedure restore
      is
      begin
         ada.Text_IO.put ("Restoring pool " & pool_Name);

         if pool_Name = "subtypes"
         then
            ada.Text_IO.put ("SUBTYPES Restoring pool " & pool_Name);
         end if;

         --  Restore storage pool state.
         --
         declare
            use ada.Streams.Stream_IO;
            the_File   : File_Type;
            the_Stream : Stream_access;
         begin
            open (the_File, in_File, storage_Folder & "/" & pool_Name & ".pool-state");
            the_Stream := Stream (the_File);

            Positive           'read (the_Stream, stored_record_Version);
            AdaM.Id            'read (the_Stream, pool_Last);
            view_Vectors.Vector'read (the_Stream, freed_Views);

            close (the_File);
         exception
            when Name_Error =>
               null;
         end;

         --  Restore storage pool array.
         --
         declare
            use ada.Streams.Stream_IO;
            the_File   : File_Type;
            the_Stream : Stream_access;
         begin
            open (the_File, in_File, storage_Folder & "/" & pool_Name & ".pool-store");
            the_Stream := Stream (the_File);

            for i in 1 .. pool_Last
            loop
               declare
                  use view_Vectors;
                  Cursor : constant view_Vectors.Cursor := freed_Views.Find (to_View (i));
               begin
                  if not has_Element (Cursor)
                  then
                     Item'read (the_Stream, Pool (i));
                  end if;
               end;
            end loop;

            close (the_File);

         exception
            when Name_Error =>
               null;
         end;

         ada.Text_IO.put_Line ("... restored");
      end restore;


      procedure store
      is
      begin
         --  Store storage pool array.
         --
         declare
            use ada.Streams.Stream_IO;
            the_File   : File_Type;
            the_Stream : Stream_access;
         begin
            create (the_File, out_File, storage_Folder & "/" & pool_Name & ".pool-store");
            the_Stream := Stream (the_File);

            for i in 1 .. pool_Last
            loop
               declare
                  use view_Vectors;
                  Cursor : constant view_Vectors.Cursor := freed_Views.Find (to_View (i));
               begin
                  if not has_Element (Cursor)
                  then
                     Item'write (the_Stream, Pool (i));
                  end if;
               end;
            end loop;

            close (the_File);
         end;

         --  Store storage pool state.
         --
         declare
            use ada.Streams.Stream_IO;
            the_File   : File_Type;
            the_Stream : Stream_access;
         begin
            create (the_File, out_File, storage_Folder & "/" & pool_Name & ".pool-state");
            the_Stream := Stream (the_File);

            Positive           'write (the_Stream, record_Version);
            AdaM.Id            'write (the_Stream, pool_Last);
            view_Vectors.Vector'write (the_Stream, freed_Views);

            close (the_File);
         end;
      end store;


      --  View Streaming
      --

      procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                            Self   : in              View)
      is
         use Ada.Tags;
      begin
         if Self = null
         then
            AdaM.Id'write  (Stream,  null_Id);
            return;
         end if;

         AdaM.Id'write  (Stream,  Self.Id);
         String 'output (Stream,  external_Tag (Self.all'Tag));
      end View_write;



      procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                           Self   : out             View)
      is
         Id : AdaM.Id;
      begin
         AdaM.Id'read (Stream, Id);

         if Id = null_Id
         then
            Self := null;
            return;
         end if;

         declare
            use Ada.Tags;
            the_String : constant String := String'Input   (Stream);                  -- Read tag as string from stream.
            the_Tag    : constant Tag    := Descendant_Tag (the_String, Item'Tag);    -- Convert to a tag.
         begin
            Self := View (AdaM.Factory.to_View (Id, the_Tag));
         end;
      end View_read;

      use Ada.Directories;
   begin
      register_Storer   (  store'Access);
      register_Restorer (restore'Access);

      register_to_view_Function (Item'Tag, Pools.to_View'Access);

      if not Exists (storage_Folder)
      then
         create_Directory (storage_Folder);
      end if;
   end Pools;



   procedure close
   is
      use storer_Vectors;
      Cursor : storer_Vectors.Cursor := all_Storers.First;
   begin
      while has_Element (Cursor)
      loop
         Element (Cursor).all;
         next (Cursor);
      end loop;
   end close;



   procedure open
   is
      use restorer_Vectors;
      Cursor : restorer_Vectors.Cursor := all_Restorers.First;
   begin
      while has_Element (Cursor)
      loop
         Element (Cursor).all;
         next (Cursor);
      end loop;
   end open;


end AdaM.Factory;
