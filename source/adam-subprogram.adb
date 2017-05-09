with
     AdaM.Factory;


package body AdaM.Subprogram
is

   --  Storage Pool
   --

   record_Version  : constant                 := 1;
   max_Subprograms : constant                 := 5_000;
   null_Subprogram : constant Subprogram.item := (Source.Entity with others => <>);

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "subprograms",
                                           max_Subprograms,
                                           record_Version,
                                           Subprogram.item,
                                           Subprogram.view,
                                           null_Subprogram);

   --  Profile
   --

   function to_Source (the_Profile : in Profile) return text_Vectors.Vector
   is
      use Parameter;
      the_Source : text_Vectors.Vector;
   begin
      for i in 1 .. Integer (the_Profile.Parameters.Length)
      loop
         the_Source.append (the_Profile.Parameters.Element (i).to_Source);
      end loop;

      return the_Source;
   end to_Source;



   --  Forge
   --

   procedure define (Self : in out Item;   Name : in String)
   is
   begin
      Self.Context := AdaM.Context.new_Context;
      Self.Name    := +Name;
      Self.Block   := AdaM.Block.new_Block (name => "procedure");
   end define;


   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;


   function new_Subprogram (Name : in String := "") return View
   is
      new_View : constant Subprogram.view := Pool.new_Item;
   begin
      define (Subprogram.item (new_View.all), Name);
      return new_View;
   end new_Subprogram;


   procedure free (Self : in out Subprogram.view)
   is
   begin
      destruct (Subprogram.item (Self.all));
      Pool.free (Self);
   end free;




   --  Attributes
   --

   overriding
   function Id   (Self : access Item) return AdaM.Id
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


   procedure Name_is (Self : in out Item;   Now : in String)
   is
   begin
      Self.Name := +Now;
   end Name_is;



   function Block     (Self : in Item) return AdaM.Block.view
   is
   begin
      return Self.Block;
   end Block;


   function Context (Self : in Item) return AdaM.Context.view
   is
   begin
      return Self.Context;
   end Context;


   function is_Function  (Self : in Item) return Boolean
   is
   begin
      return not Self.is_Procedure;
   end is_Function;


   function is_Procedure (Self : in Item) return Boolean
   is
      use type AdaM.Parameter.view;
   begin
      return Self.Profile.Result = null;
   end is_Procedure;



   overriding
   function to_spec_Source (Self : in Item) return text_Vectors.Vector
   is
      use ada.Strings.Unbounded;
      the_Line   : Text;
      the_Source : text_Vectors.Vector;

      has_Parameters : constant Boolean := not Self.Profile.Parameters.Is_Empty;

   begin
      the_Source.append (Self.Context.to_Source);

      if Self.is_Procedure
      then
         append (the_Line, "procedure ");
      else
         append (the_Line, "function ");
      end if;

      append (the_Line, Self.Name);

      if has_Parameters then
         the_Line := +"(";
         the_Source.append (the_Line);
      end if;

      the_Source.append (the_Line);

      the_Source.append (Self.Profile.to_Source);

      if has_Parameters then
         the_Line := +")";
         the_Source.append (the_Line);
      end if;

      the_Line := +"is";
      the_Source.append (the_Line);

      the_Source.append (Self.Block.to_Source);

      the_Line := +"end " & Self.Name & ";";
      the_Source.append (the_Line);

      return the_Source;
   end to_spec_Source;


   -- Streams
   --

   procedure View_write (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                         Self   : in              View)
                         renames Pool.View_write;

   procedure View_read (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
                        Self   : out             View)
                        renames Pool.View_read;

end AdaM.Subprogram;
