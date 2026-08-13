unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls, System.IOUtils, Vcl.FileCtrl, uConverter;

type
  TfrmMain = class(TForm)
    pnlTop: TPanel;
    btnAdd: TButton;
    btnClear: TButton;
    lvFiles: TListView;
    pnlBottom: TPanel;
    lblFormat: TLabel;
    cbFormat: TComboBox;
    lblQuality: TLabel;
    tbQuality: TTrackBar;
    lblQualityValue: TLabel;
    lblDestFolder: TLabel;
    edtDestFolder: TEdit;
    btnBrowseDest: TButton;
    chkSameFolder: TCheckBox;
    btnConvert: TButton;
    pbProgress: TProgressBar;
    lblStatus: TLabel;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnBrowseDestClick(Sender: TObject);
    procedure chkSameFolderClick(Sender: TObject);
    procedure tbQualityChange(Sender: TObject);
    procedure btnConvertClick(Sender: TObject);
  private
    FFiles: TStringList;
    function SelectedFormat: TImageFormat;
    procedure UpdateDestControlsEnabled;
  public
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FFiles := TStringList.Create;

  lvFiles.ViewStyle := vsReport;
  lvFiles.RowSelect := True;
  lvFiles.Columns.Add.Caption := 'Arquivo';
  lvFiles.Columns[0].Width := 340;
  lvFiles.Columns.Add.Caption := 'Formato';
  lvFiles.Columns[1].Width := 80;
  lvFiles.Columns.Add.Caption := 'Status';
  lvFiles.Columns[2].Width := 220;

  cbFormat.Style := csDropDownList;
  cbFormat.Items.Add('PNG');
  cbFormat.Items.Add('JPG');
  cbFormat.Items.Add('WEBP');
  cbFormat.Items.Add('BMP');
  cbFormat.Items.Add('GIF');
  cbFormat.ItemIndex := 0;

  tbQuality.Min := 1;
  tbQuality.Max := 100;
  tbQuality.Position := 90;
  lblQualityValue.Caption := '90';

  chkSameFolder.Checked := True;
  UpdateDestControlsEnabled;

  OpenDialog1.Filter :=
    'Imagens (*.bmp;*.jpg;*.jpeg;*.png;*.gif;*.webp)|*.bmp;*.jpg;*.jpeg;*.png;*.gif;*.webp|Todos os arquivos (*.*)|*.*';
  OpenDialog1.Options := OpenDialog1.Options + [ofAllowMultiSelect, ofFileMustExist];

  lblStatus.Caption := '';
end;

function TfrmMain.SelectedFormat: TImageFormat;
begin
  case cbFormat.ItemIndex of
    0: Result := ifPNG;
    1: Result := ifJPG;
    2: Result := ifWEBP;
    3: Result := ifBMP;
    4: Result := ifGIF;
  else
    Result := ifPNG;
  end;
end;

procedure TfrmMain.UpdateDestControlsEnabled;
begin
  edtDestFolder.Enabled := not chkSameFolder.Checked;
  btnBrowseDest.Enabled := not chkSameFolder.Checked;
end;

procedure TfrmMain.btnAddClick(Sender: TObject);
var
  FileName: string;
  Item: TListItem;
  Fmt: TImageFormat;
begin
  if OpenDialog1.Execute then
  begin
    for FileName in OpenDialog1.Files do
    begin
      if FFiles.IndexOf(FileName) >= 0 then
        Continue;
      FFiles.Add(FileName);
      Fmt := FormatFromExt(FileName);
      Item := lvFiles.Items.Add;
      Item.Caption := TPath.GetFileName(FileName);
      Item.SubItems.Add(FormatDisplayName(Fmt));
      Item.SubItems.Add('Pendente');
    end;
  end;
end;

procedure TfrmMain.btnClearClick(Sender: TObject);
begin
  FFiles.Clear;
  lvFiles.Items.Clear;
  pbProgress.Position := 0;
  lblStatus.Caption := '';
end;

procedure TfrmMain.btnBrowseDestClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := edtDestFolder.Text;
  if SelectDirectory('Selecione a pasta de destino', '', Dir) then
    edtDestFolder.Text := Dir;
end;

procedure TfrmMain.chkSameFolderClick(Sender: TObject);
begin
  UpdateDestControlsEnabled;
end;

procedure TfrmMain.tbQualityChange(Sender: TObject);
begin
  lblQualityValue.Caption := IntToStr(tbQuality.Position);
end;

procedure TfrmMain.btnConvertClick(Sender: TObject);
var
  I: Integer;
  SrcFile, DestFolder, DestFile, BaseName: string;
  DestFmt: TImageFormat;
  OkCount, ErrCount: Integer;
begin
  if FFiles.Count = 0 then
  begin
    ShowMessage('Adicione ao menos uma imagem.');
    Exit;
  end;

  if not chkSameFolder.Checked and (Trim(edtDestFolder.Text) = '') then
  begin
    ShowMessage('Selecione a pasta de destino.');
    Exit;
  end;

  DestFmt := SelectedFormat;
  OkCount := 0;
  ErrCount := 0;
  pbProgress.Min := 0;
  pbProgress.Max := FFiles.Count;
  pbProgress.Position := 0;

  btnConvert.Enabled := False;
  try
    for I := 0 to FFiles.Count - 1 do
    begin
      SrcFile := FFiles[I];

      if chkSameFolder.Checked then
        DestFolder := TPath.GetDirectoryName(SrcFile)
      else
        DestFolder := edtDestFolder.Text;

      BaseName := TPath.GetFileNameWithoutExtension(SrcFile);
      DestFile := TPath.Combine(DestFolder, BaseName + ExtFromFormat(DestFmt));

      if TFile.Exists(DestFile) and (SameFileName(DestFile, SrcFile)) then
        DestFile := TPath.Combine(DestFolder, BaseName + '_convertido' + ExtFromFormat(DestFmt));

      lblStatus.Caption := 'Convertendo: ' + TPath.GetFileName(SrcFile);
      Application.ProcessMessages;

      try
        ConvertImage(SrcFile, DestFmt, DestFile, tbQuality.Position);
        lvFiles.Items[I].SubItems[1] := 'OK';
        Inc(OkCount);
      except
        on E: Exception do
        begin
          lvFiles.Items[I].SubItems[1] := 'Erro: ' + E.Message;
          Inc(ErrCount);
        end;
      end;

      pbProgress.Position := I + 1;
      Application.ProcessMessages;
    end;
  finally
    btnConvert.Enabled := True;
  end;

  lblStatus.Caption := Format('Concluido: %d ok, %d com erro.', [OkCount, ErrCount]);
end;

end.
