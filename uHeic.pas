unit uHeic;
{ Decodificacao de imagens HEIC/HEIF usando o Windows Imaging Component (WIC).
  Requer que o sistema tenha um decoder HEIF instalado (extensao "HEIF Image
  Extensions" / "HEVC Video Extensions" da Microsoft Store, geralmente ja
  presente no Windows 10/11). Nao depende de nenhuma DLL adicional no projeto. }

interface

uses
  Winapi.Windows, Winapi.ActiveX, Winapi.WinCodec, System.SysUtils, System.IOUtils,
  System.Win.ComObj, Vcl.Graphics;

type
  EHeicError = class(Exception);

procedure LoadHeicToBitmap(const FileName: string; Bmp: TBitmap);
function IsHeicAvailable: Boolean;

implementation

const
  GUID_ContainerFormatHeif: TGUID = '{E1E62521-6787-405B-A339-500715B5763F}';
  GUID_NULL: TGUID = '{00000000-0000-0000-0000-000000000000}';

var
  WICFactory: IWICImagingFactory;

procedure EnsureFactory;
begin
  if WICFactory = nil then
    OleCheck(CoCreateInstance(CLSID_WICImagingFactory, nil, CLSCTX_INPROC_SERVER,
      IID_IWICImagingFactory, WICFactory));
end;

function IsHeicAvailable: Boolean;
var
  Decoder: IWICBitmapDecoder;
begin
  Result := False;
  try
    EnsureFactory;
    Result := Succeeded(WICFactory.CreateDecoder(GUID_ContainerFormatHeif, GUID_NULL, Decoder));
  except
    Result := False;
  end;
end;

procedure LoadHeicToBitmap(const FileName: string; Bmp: TBitmap);
var
  Decoder: IWICBitmapDecoder;
  Frame: IWICBitmapFrameDecode;
  Converter: IWICFormatConverter;
  W, H: Cardinal;
  Stride: Cardinal;
  Buffer: TBytes;
  Y: Integer;
  SrcRow, DstRow: PByte;
begin
  EnsureFactory;
  try
    OleCheck(WICFactory.CreateDecoderFromFilename(PWideChar(FileName), GUID_NULL,
      GENERIC_READ, WICDecodeMetadataCacheOnDemand, Decoder));
  except
    on E: Exception do
      raise EHeicError.CreateFmt('Nao foi possivel abrir o arquivo HEIC: %s'#13#10 +
        'Verifique se as "Extensoes de Imagem HEIF" estao instaladas (Microsoft Store).',
        [TPath.GetFileName(FileName)]);
  end;

  OleCheck(Decoder.GetFrame(0, Frame));

  OleCheck(WICFactory.CreateFormatConverter(Converter));
  OleCheck(Converter.Initialize(Frame, GUID_WICPixelFormat32bppBGRA,
    WICBitmapDitherTypeNone, nil, 0, WICBitmapPaletteTypeCustom));

  OleCheck(Converter.GetSize(W, H));
  if (W = 0) or (H = 0) then
    raise EHeicError.CreateFmt('Imagem HEIC invalida: %s', [FileName]);

  Stride := W * 4;
  SetLength(Buffer, Stride * H);
  OleCheck(Converter.CopyPixels(nil, Stride, Length(Buffer), @Buffer[0]));

  Bmp.PixelFormat := pf32bit;
  Bmp.SetSize(W, H);
  for Y := 0 to Integer(H) - 1 do
  begin
    SrcRow := @Buffer[Y * Integer(Stride)];
    DstRow := Bmp.ScanLine[Y];
    Move(SrcRow^, DstRow^, Stride);
  end;
  Bmp.AlphaFormat := afDefined;
end;

initialization
  CoInitialize(nil);

finalization
  WICFactory := nil;
  CoUninitialize;

end.
