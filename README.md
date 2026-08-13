# Conversor de Imagens

Aplicativo desktop para Windows (Delphi/VCL) que converte imagens em lote entre os formatos **BMP, JPG, PNG, GIF e WEBP**.

## Recursos

- Seleção de múltiplas imagens de formatos diferentes de uma vez
- Escolha do formato de destino e da qualidade de compressão (JPG/WEBP)
- Conversão para a mesma pasta de origem ou para uma pasta de destino escolhida
- Suporte a WEBP via bindings diretos a `libwebp.dll` (Google)

## Como usar (executável pronto)

1. Baixe o `.zip` da última [Release](../../releases) (contém `ConversorImagens.exe` + as DLLs necessárias).
2. Extraia tudo em uma mesma pasta — **não mova o `.exe` sozinho**, ele depende das DLLs ao lado.
3. Execute `ConversorImagens.exe`.

> O Windows pode exibir um aviso do SmartScreen ("Editor desconhecido") por o executável não ser assinado digitalmente. Isso é esperado em projetos open source sem certificado de assinatura de código — o código-fonte completo está neste repositório para auditoria.

## Como compilar

Requisitos:
- Delphi / RAD Studio (testado na versão 12 Athens / 23.0)
- Sem dependências de pacotes de terceiros na IDE — o projeto usa apenas `rtl`, `vcl`, `vclx`

Passos:
1. Abra `ConversorImagens.dproj` no RAD Studio.
2. Copie o(s) `.dll` de `redist/win64/` (ou `redist/win32/`, se você gerar) para a pasta de saída do build (`Win64\Debug` ou `Win32\Debug`, conforme a plataforma escolhida).
3. Compile (F9).

## Estrutura do projeto

- `uMain.pas` / `uMain.dfm` — tela principal (VCL)
- `uConverter.pas` — camada de negócio: detecção de formato e conversão entre formatos
- `uWebP.pas` — bindings para `libwebp.dll` (decodificação/codificação WEBP)
- `redist/` — DLLs de runtime necessárias para distribuição (ver [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md))

## Licença

Código deste repositório sob [MIT License](LICENSE).

Este projeto redistribui `libwebp`/`libsharpyuv` (Google, licença BSD) — veja [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md) para detalhes e avisos sobre a procedência do binário atual.
