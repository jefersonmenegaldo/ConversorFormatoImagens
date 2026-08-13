unit uWebP;

{ Bindings diretos para libwebp.dll (WebPDecodeBGRA / WebPEncodeBGR / WebPEncodeLosslessBGR).
  A DLL precisa estar na mesma pasta do executavel (ou em um diretorio do PATH). }

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics;

type
  EWebPError = class(Exception);
  PPByte = ^PByte;

procedure LoadWebPToBitmap(const FileName: string; Bmp: TBitmap);
procedure SaveBitmapToWebP(Bmp: TBitmap; const FileName: string; Quality: Single = 90; Lossless: Boolean = False);
function IsWebPAvailable: Boolean;

implementation

const
  WEBP_DLL = 'libwebp.dll';

function WebPGetInfo(data: PByte; data_size: NativeUInt; width, height: PInteger): Integer; cdecl;
  external WEBP_DLL name 'WebPGetInfo';

function WebPDecodeBGRA(data: PByte; data_size: NativeUInt; width, height: PInteger): PByte; cdecl;
  external WEBP_DLL name 'WebPDecodeBGRA';

function WebPEncodeBGR(bgr: PByte; width, height, stride: Integer; quality_factor: Single; output: PPByte): NativeUInt; cdecl;
  external WEBP_DLL name 'WebPEncodeBGR';

function WebPEncodeLosslessBGR(bgr: PByte; width, height, stride: Integer; output: PPByte): NativeUInt; cdecl;
  external WEBP_DLL name 'WebPEncodeLosslessBGR';

procedure WebPFree(ptr: Pointer); cdecl;
  external WEBP_DLL name 'WebPFree';

function IsWebPAvailable: Boolean;
var
  Handle: HMODULE;
begin
  Handle := LoadLibrary(WEBP_DLL);
  Result := Handle <> 0;
  if Result then
    FreeLibrary(Handle);
end;

procedure LoadWebPToBitmap(const FileName: string; Bmp: TBitmap);
var
  Stream: TFileStream;
  Data: TBytes;
  W, H: Integer;
  Decoded: PByte;
  Y: Integer;
  SrcRow, DstRow: PByte;
  RowBytes: Integer;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    SetLength(Data, Stream.Size);
    if Stream.Size > 0 then
      Stream.ReadBuffer(Data[0], Stream.Size);
  finally
    Stream.Free;
  end;

  if (Length(Data) = 0) or (WebPGetInfo(@Data[0], Length(Data), @W, @H) = 0) then
    raise EWebPError.CreateFmt('Arquivo WEBP invalido: %s', [FileName]);

  Decoded := WebPDecodeBGRA(@Data[0], Length(Data), @W, @H);
  if Decoded = nil then
    raise EWebPError.CreateFmt('Falha ao decodificar WEBP: %s', [FileName]);
  try
    Bmp.PixelFormat := pf32bit;
    Bmp.SetSize(W, H);
    RowBytes := W * 4;
    for Y := 0 to H - 1 do
    begin
      SrcRow := Decoded + Y * RowBytes;
      DstRow := Bmp.ScanLine[Y];
      Move(SrcRow^, DstRow^, RowBytes);
    end;
    Bmp.AlphaFormat := afDefined;
  finally
    WebPFree(Decoded);
  end;
end;

procedure SaveBitmapToWebP(Bmp: TBitmap; const FileName: string; Quality: Single; Lossless: Boolean);
var
  Src: TBitmap;
  Output: PByte;
  OutSize: NativeUInt;
  Stride: NativeInt;
  Row0: PByte;
  Stream: TFileStream;
begin
  Src := TBitmap.Create;
  try
    Src.Assign(Bmp);
    Src.PixelFormat := pf24bit;

    Row0 := Src.ScanLine[0];
    if Src.Height > 1 then
      Stride := NativeInt(Src.ScanLine[1]) - NativeInt(Src.ScanLine[0])
    else
      Stride := ((Src.Width * 3 + 3) div 4) * 4;

    if Lossless then
      OutSize := WebPEncodeLosslessBGR(Row0, Src.Width, Src.Height, Stride, @Output)
    else
      OutSize := WebPEncodeBGR(Row0, Src.Width, Src.Height, Stride, Quality, @Output);

    if (OutSize = 0) or (Output = nil) then
      raise EWebPError.CreateFmt('Falha ao codificar WEBP: %s', [FileName]);
    try
      Stream := TFileStream.Create(FileName, fmCreate);
      try
        Stream.WriteBuffer(Output^, OutSize);
      finally
        Stream.Free;
      end;
    finally
      WebPFree(Output);
    end;
  finally
    Src.Free;
  end;
end;

end.
