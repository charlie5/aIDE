--  This package contains routines for ASIS Elements processing.

with Asis;

package adam.Assist.Query.find_All.element_Processing is

   procedure Process_Construct (The_Element : Asis.Element);
   --  This is the template for the procedure which is supposed to
   --  perform the analysis of its argument Element (The_Element) based on
   --  the recursive traversing of the Element hierarchy rooted by
   --  The_Element. It calls the instantiation of the ASIS Traverse_Element
   --  generic procedure for The_Element.
   --
   --  This procedure should not be called for Nil_Element;
   --
   --  Note, that the instantiation of Traverse_Element and the way how it is
   --  called is no more then a template. It uses a dummy enumeration type
   --  as the actual type for the state of the traversal, and it uses
   --  dummy procedures which do nothing as actual procedures for Pre- and
   --  Post-operations. The Control parameter of the traversal is set
   --  to Continue and it is not changed by actual Pre- or Post-operations.
   --  All this things will definitely require revising when using this
   --  set of templates to build any real application. (At least you will
   --  have to provide real Pre- and/or Post-operation)
   --
   --  See the package body for more details.

end adam.Assist.Query.find_All.element_Processing;
