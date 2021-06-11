unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Grids{, RegExpr};

type

  { TfrMain }

  TfrMain = class(TForm)
    btStart: TButton;
    btGetType: TButton;
    edMask: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    mInput: TMemo;
    mOutput: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    sgTypes: TStringGrid;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    procedure btStartClick(Sender: TObject);
    procedure btGetTypeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public

  end;

var
  frMain: TfrMain;
  Line: TStringList;
  arTypes: array[1..30] of string;

implementation

{$R *.lfm}

{ TfrMain }

procedure TfrMain.FormCreate(Sender: TObject);
var
  i: integer;

begin

  //sgTypes.Cells[0, 0] := '№ поля';
  Line := TStringList.Create;

  // заполним sgTypes
  for i := 1 to sgTypes.RowCount - 1 do
    sgTypes.Cells[0, i] := IntToStr(i);

end;

{Основная процедура}

procedure TfrMain.btStartClick(Sender: TObject);
var
  nCnt: integer;  // кол-во полей
  i, j, k: integer;
  s: string;
  bErr: boolean;

//Количество вхождений подстроки в строку
function CountPos(const subtext: string; Text: string): Integer;
begin
  if (Length(subtext) = 0) or (Length(Text) = 0) or (Pos(subtext, Text) = 0) then
    Result := 0
  else
    Result := (Length(Text) - Length(StringReplace(Text, subtext, '', [rfReplaceAll]))) div
      Length(subtext);
end;

begin

  bErr := False;

  mOutput.Clear;

  // определили количество полей и их типы
  nCnt := 1;
  while sgTypes.Cells[1, nCnt] <> '' do
  begin
    arTypes[nCnt] := sgTypes.Cells[1, nCnt];

    if (arTypes[nCnt] = 'varchar') or
       (arTypes[nCnt] = 'number')  or
       (arTypes[nCnt] = 'date')
    then
    else
    begin
      ShowMessage('Ошибка в указании типа поля');
      exit;
    end;

    nCnt := nCnt + 1;

  end;
  nCnt := nCnt - 1;

  if nCnt < 1 then
  begin
    ShowMessage('Не найдены типы полей');
    exit;
  end;

  if mInput.Lines.Count = 0 then
  begin
    ShowMessage('Не найдены данные csv');
    exit;
  end;

  mOutput.Lines.Add('insert into {table_name}');

  for i := 0 to mInput.Lines.Count - 1 do
  begin

    try

      //ShowMessage(IntToStr(CountPos(';', mInput.Lines[i])));

      if CountPos(';', mInput.Lines[i]) + 1 <> nCnt then
      begin
        mOutput.Lines.Add('Error');
        bErr := True;
        continue;
      end;

      Line.Clear;

      Line.Delimiter := ';';
      Line.StrictDelimiter := True;
      Line.DelimitedText := mInput.Lines[i];

      // формируем один insert
      s := 'select ';
      for j := 1 to nCnt do
      begin
        if Line[j-1] = '' then
        begin
          s := s + 'null, ';
          continue;
        end;

        case arTypes[j] of
          'varchar' : s := s + '''' + Line[j-1] + ''', ';
          'number'  : s := s + StringReplace(Line[j-1], ',', '.', [rfReplaceAll, rfIgnoreCase]) + ', ';
          'date'    : s := s + 'to_date(''' + Line[j-1] + ''', '''+edMask.Text+'''), ';
        end;
      end;

      delete(s, length(s)-1, 2); // удалим последнюю запятую с пробелом

      if i = mInput.Lines.Count - 1 then // последняя строка
        s := s + ' from dual;'
      else
        s := s + ' from dual union all';

      mOutput.Lines.Add(s);

    except
      mOutput.Lines.Add('Error');
      bErr := True;
    end;

  end;

  if bErr then ShowMessage('При конвертировании были ошибки!');

end;

procedure TfrMain.btGetTypeClick(Sender: TObject);
var
  i: integer;
  //RegExp: TRegExpr;
  numb: double;
  dat: TDateTime;
  dec: string;
  decch: char;

begin

  if mInput.Lines.Count = 0 then
  begin
    ShowMessage('CSV пуст');
    exit;
  end;

  Line.Clear;
  Line.Delimiter := ';';
  Line.StrictDelimiter := True;
  Line.DelimitedText := mInput.Lines[0];

  //RegExp := TRegExpr.Create;
  //RegExp.Expression := '^[0-9]+$';

  for i := 0 to Line.Count - 1 do
  begin
    if Line[i] = '' then Line[i] := 'null';
      sgTypes.Cells[2, i + 1] := Line[i];

    try // число
      Line[i] := StringReplace(Line[i], ',', '.', [rfReplaceAll, rfIgnoreCase]);
      DecimalSeparator := '.';
      numb := StrToFloat(Line[i]);
      sgTypes.Cells[1, i + 1] := 'number';
    except
      try  // дата
        ShortDateFormat := edMask.Text;
        dec := StringReplace(StringReplace(StringReplace(edMask.Text, 'd', '', [rfReplaceAll, rfIgnoreCase]),
                                                                      'm', '', [rfReplaceAll, rfIgnoreCase]),
                                                                      'y', '', [rfReplaceAll, rfIgnoreCase]);
        decch := dec[1];
        DateSeparator := decch;
        dat := StrToDate(Line[i]);
        sgTypes.Cells[1, i + 1] := 'date';
      except // строка
        sgTypes.Cells[1, i + 1] := 'varchar';
      end;
    end;

  end;

end;

procedure TfrMain.FormDestroy(Sender: TObject);
begin
  Line.Free;
end;

end.

