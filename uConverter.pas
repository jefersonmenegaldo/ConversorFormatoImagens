unit uConverter;

interface

uses
  System.SysUtils, System.IOUtils, Vcl.Graphics, Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage, Vcl.Imaging.GIFImg, uWebP, uHeic;

type
  TImageFormat = (ifUnknown, ifBMP, ifJPG, ifPNG, ifGIF, ifWEBP, ifHEIC);

  EConvertError = class(Exception);

function FormatFromExt(const FileName: string): TImageFormat;
function ExtFromFormat(Fmt: TImageFormat): string;
function FormatDisplayName(Fmt: TImageFormat): string;

procedure LoadAnyToBitmap(const FileName: string; Bmp: TBitmap);
procedure SaveBitmapAs(Bmp: TBitmap; const FileName: string; Fmt: TImageFormat; Quality: Integer);

procedure ConvertImage(const SrcFile: string; DestFormat: TImageFormat; const DestFile: string; Quality: Integer = 90);

implementation

function FormatFromExt(const FileName: string): TImageFormat;
var
  Ext: string;
begin
  Ext := LowerCase(TPath.GetExtension(FileName));
  if (Ext = '.bmp') then Result := ifBMP
  else if (Ext = '.jpg') or (Ext = '.jpeg') then Result := ifJPG
  else if (Ext = '.png') then Result := ifPNG
  else if (Ext = '.gif') then Result := ifGIF
  else if (Ext = '.webp') then Result := ifWEBP
  else if (Ext = '.heic') or (Ext = '.heif') then Result := ifHEIC
  else Result := ifUnknown;
end;

function ExtFromFormat(Fmt: TImageFormat): string;
begin
  case Fmt of
    ifBMP: Result := '.bmp';
    ifJPG: Result := '.jpg';
    ifPNG: Result := '.png';
    ifGIF: Result := '.gif';
    ifWEBP: Result := '.webp';
    ifHEIC: Result := '.heic';
  else
    Result := '';
  end;
end;

function FormatDisplayName(Fmt: TImageFormat): string;
begin
  case Fmt of
    ifBMP: Result := 'BMP';
    ifJPG: Result := 'JPG';
    ifPNG: Result := 'PNG';
    ifGIF: Result := 'GIF';
    ifWEBP: Result := 'WEBP';
    ifHEIC: Result := 'HEIC';
  else
    Result := 'Desconhecido';
  end;
end;

procedure LoadAnyToBitmap(const FileName: string; Bmp: TBitmap);
var
  Fmt: TImageFormat;
  Pic: TPicture;
begin
  Fmt := FormatFromExt(FileName);
  if not TFile.Exists(FileName) then
    raise EConvertError.CreateFmt('Arquivo nao encontrado: %s', [FileName]);

  case Fmt of
    ifWEBP:
      LoadWebPToBitmap(FileName, Bmp);
    ifHEIC:
      LoadHeicToBitmap(FileName, Bmp);
    ifBMP, ifJPG, ifPNG, ifGIF:
      begin
        Pic := TPicture.Create;
        try
          Pic.LoadFromFile(FileName);
          Bmp.PixelFormat := pf32bit;
          Bmp.SetSize(Pic.Width, Pic.Height);
          Bmp.Canvas.Draw(0, 0, Pic.Graphic);
        finally
          Pic.Free;
        end;
      end;
  else
    raise EConvertError.CreateFmt('Formato de origem nao suportado: %s', [FileName]);
  end;
end;

procedure SaveBitmapAs(Bmp: TBitmap; const FileName: string; Fmt: TImageFormat; Quality: Integer);
var
  Jpg: TJPEGImage;
  Png: TPngImage;
  Gif: TGIFImage;
begin
  case Fmt of
    ifBMP:
      Bmp.SaveToFile(FileName);
    ifJPG:
      begin
        Jpg := TJPEGImage.Create;
        try
          Jpg.CompressionQuality := Quality;
          Jpg.Assign(Bmp);
          Jpg.SaveToFile(FileName);
        finally
          Jpg.Free;
        end;
      end;
    ifPNG:
      begin
        Png := TPngImage.Create;
        try
          Png.Assign(Bmp);
          Png.SaveToFile(FileName);
        finally
          Png.Free;
        end;
      end;
    ifGIF:
      begin
        Gif := TGIFImage.Create;
        try
          Gif.Assign(Bmp);
          Gif.SaveToFile(FileName);
        finally
          Gif.Free;
        end;
      end;
    ifWEBP:
      SaveBitmapToWebP(Bmp, FileName, Quality);
  else
    raise EConvertError.CreateFmt('Formato de destino nao suportado: %s', [FileName]);
  end;
end;

procedure ConvertImage(const SrcFile: string; DestFormat: TImageFormat; const DestFile: string; Quality: Integer);
var
  Bmp: TBitmap;
begin
  Bmp := TBitmap.Create;
  try
    LoadAnyToBitmap(SrcFile, Bmp);
    SaveBitmapAs(Bmp, DestFile, DestFormat, Quality);
  finally
    Bmp.Free;
  end;
end;

end.
