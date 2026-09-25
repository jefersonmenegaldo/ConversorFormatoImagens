program ConversorDeImagens;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  uConverter in 'uConverter.pas',
  uWebP in 'uWebP.pas',
  uHeic in 'uHeic.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
