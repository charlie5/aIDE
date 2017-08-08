with
     AdaM.Factory;


package body AdaM.Parameter
is

   --  Storage Pool
   --

   record_Version : constant                := 1;
   max_Parameters : constant                := 5_000;

   package Pool is new AdaM.Factory.Pools (".adam-store",
                                           "parameters",
                                           max_Parameters,
                                           record_Version,
                                           Parameter.item,
                                           Parameter.view);

   --  Vector
   --

   function to_Source (the_Parameters : in Vector) return text_Vectors.Vector
   is
      use ada.Containers;
      the_Source : text_Vectors.Vector;
   begin
      for i in 1 .. the_Parameters.Length
      loop
         the_Source.append (the_Parameters.Element (Integer (i)).to_Source);

         if i /= the_Parameters.Length
         then
            the_Source.append (+";");
         end if;

      end loop;

      return the_Source;
   end to_Source;



   --  Forge
   --

   procedure define (Self : in out Item;   Name : in String)
   is
   begin
      Self.Name := +Name;
   end define;


   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;


   function new_Parameter (Name : in String := "") return View
   is
      new_View : constant Parameter.view := Pool.new_Item;
   begin
      define (Parameter.item (new_View.all), Name);
      return new_View;
   end new_Parameter;


   procedure free (Self : in out Parameter.view)
   is
   begin
      destruct (Parameter.item (Self.all));
      Pool.free (Self);
   end free;



   --  Attributes
   --

   overriding function Id   (Self : access Item) return AdaM.Id
   is
   begin
      return Pool.to_Id (Self);
   end Id;


   function Name (Self : in Item) return String
   is
   begin
      return +Self.Name;
   end Name;


   procedure Name_is   (Self : in out Item;   Now : in String)
   is
   begin
      Self.Name := +Now;
   end Name_is;



   function  Mode      (Self : in     Item)     return a_Mode
   is
   begin
      return Self.Mode;
   end Mode;


   procedure Mode_is   (Self : in out Item;   Now : in a_Mode)
   is
   begin
      Self.Mode := Now;
   end Mode_is;


   function  my_Type (Self : access Item) return access a_Type.view -- access Text
   is
   begin
      return Self.my_Type'Access;
   end my_Type;



   function my_Type (Self : in Item) return a_Type.view
   is
   begin
      return Self.my_Type;
   end my_Type;


   procedure Type_is   (Self : in out Item;   Now : in a_Type.view)
   is
   begin
      Self.my_Type := Now;
   end Type_is;



   function Default (Self : in Item) return String
   is
   begin
      return +Self.Default;
   end Default;


   procedure Default_is   (Self : in out Item;   Now : in String)
   is
   begin
      Self.Default := +Now;
   end Default_is;



   function to_Source (Self : in Item) return text_Vectors.Vector
   is
      the_Source : text_Vectors.Vector;

      function mode_Text return String
      is
         use Parameter;
      begin
         if    Self.Mode =     in_Mode then    return "in";
         elsif Self.Mode =    out_Mode then    return "out";
         elsif Self.Mode = in_out_Mode then    return "in out";
         elsif Self.Mode = access_Mode then    return "access";
         end if;

         raise Program_Error;
      end mode_Text;

   begin
      the_Source.append (Self.Name & " : " & mode_Text & " " & Self.my_Type.Name);

      if Self.Default /= ""
      then
         the_Source.append  (+" := " & Self.Default);
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

end AdaM.Parameter;
