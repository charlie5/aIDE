with
     aIDE,
     AdaM.Factory;

procedure launch_AIDE
is
begin
   AdaM.Factory.open;
   aIDE.start;
   aIDE.stop;
   AdaM.Factory.close;
end launch_AIDE;

