unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Grids;

type

  { TfrMain }

  TfrMain = class(TForm)
    btStart: TButton;
    edDDL: TEdit;
    edMask: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    mInput: TMemo;
    mOutput: TMemo;
    sgTypes: TStringGrid;
    procedure btStartClick(Sender: TObject);
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

  sgTypes.Cells[0, 0] := '№ поля';
  Line := TStringList.Create;

  // заполним sgTypes
  for i := 1 to sgTypes.RowCount - 1 do
    sgTypes.Cells[0, i] := IntToStr(i);

end;

{Основная процедура}

procedure TfrMain.btStartClick(Sender: TObject);
var
  nCnt: integer;  // кол-во полей
  i, j: integer;
  s: string;

begin

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

  for i := 0 to mInput.Lines.Count - 1 do
  begin

    try
      Line.Clear;

      Line.Delimiter := ';';
      Line.StrictDelimiter := True;
      Line.DelimitedText := mInput.Lines[i];

      s := edDDL.Text + '(';
      for j := 1 to nCnt do
      begin
        if Line[j-1] = '' then
        begin
          s := s + 'null, ';
          continue;
        end;

        case arTypes[j] of
          'varchar' : s := s + '''' + Line[j-1] + ''', ';
          'number'  : s := s + Line[j-1] + ', ';
          'date'    : s := s + 'to_date(''' + Line[j-1] + ''', '''+edMask.Text+'''), ';
        end;
      end;

      delete(s, length(s)-1, 2); // удалим последнюю запятую с пробелом
      s := s + ');';
      mOutput.Lines.Add(s);

    except
      mOutput.Lines.Add('Error');
    end;

  end;


end;

procedure TfrMain.FormDestroy(Sender: TObject);
begin
  Line.Free;
end;

end.

