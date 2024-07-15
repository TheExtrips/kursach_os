unit Clusters;

interface

uses
  System.Classes, Windows, SysUtils, Vcl.Dialogs, Grids, System.IOUtils, System.Types;

procedure GetFATforFile(Folder: string; StringGrid: TStringGrid);
procedure PutClustersInStringGrid(StringGrid: TStringGrid; NameColumn: String);
procedure ClearStringGrid(StringGrid: TStringGrid);

var
  CounterHeadColumn: integer;
  CounterHeadRow: integer;
  maxRowCount: Integer;
  files_array: TStringDynArray;
  FilesStartClusters: array of array of int64;
  FilesClustersCount: array of array of int64;
  s: string;

implementation
uses Unit2;

function GetMaxNonEmptyRow(StringGrid: TStringGrid): Integer;
var
  i, j: Integer;
begin
  Result := 0;
  for i := StringGrid.RowCount - 1 downto 0 do
  begin
    for j := 0 to StringGrid.ColCount - 1 do
    begin
      if Trim(StringGrid.Cells[j, i]) <> '' then
      begin
        Result := i;
        Exit; // Выйти из функции, если найдена непустая строка
      end;
    end;
  end;
end;

procedure ClearStringGrid(StringGrid: TStringGrid);
var
  i, j: Integer;
begin
  for i := 0 to StringGrid.RowCount - 1 do
  begin
    for j := 0 to StringGrid.ColCount - 1 do
    begin
      StringGrid.Cells[j, i] := ''; // Очищаем содержимое ячейки
    end;
  end;
  CounterHeadColumn := 0;
  CounterHeadRow := 0;
  maxRowCount := 0;
end;

procedure GetFATforFile(Folder: string; StringGrid: TStringGrid);
type
  RETRIEVAL_POINTERS_BUFFER =
    Record
      ExtentCount1: dword;
      StartOffset: int64;
      EndOffset: int64;
      CurrentOffset: int64;
    End;

var
  hVolume: THandle;
  cbret: cardinal;
  bol1: longbool;
  rpb: RETRIEVAL_POINTERS_BUFFER;
  StartingLcn: int64;
  i, j, counter: integer;
  current: int64;
  NameColumn: string;
  FilePath: string;
  Count: integer;

begin
  files_array := TDirectory.GetFiles(Folder, '*', TSearchOption.soAllDirectories);

  for counter := 0 to Length(files_array) - 1 do
  begin
    Count := 1;
    CounterHeadRow := 0; // Инициализируем переменную CounterHeadRow
    CounterHeadColumn := CounterHeadColumn + 1;

    FilePath := PChar(files_array[counter]);
    NameColumn := files_array[counter];
    SetLength(FilesStartClusters, Count);
    SetLength(FilesClustersCount, Count);

    hVolume := CreateFile(PChar(FilePath), GENERIC_READ, 0, nil,
                          OPEN_EXISTING, 0, 0);
    if hVolume = INVALID_HANDLE_VALUE then
    begin
      ShowMessage('Ошибка! Не удалось найти файл. Код ошибки: ' +
                  IntToStr(GetLastError()));
      Exit;
    end;

    try
      for i := 0 to Count - 1 do
      begin
        j := 0;
        current := 0;
        bol1 := true;
        StartingLcn := 0;

        repeat
          bol1 := DeviceIoControl(hVolume, FSCTL_GET_RETRIEVAL_POINTERS,
                                  @StartingLcn, 8, @rpb, sizeof(rpb), cbret, nil);
          if current <> rpb.CurrentOffset then
          begin
            current := rpb.CurrentOffset;
            SetLength(FilesStartClusters[i], j + 1);
            SetLength(FilesClustersCount[i], j + 1);
            FilesStartClusters[i, j] := rpb.CurrentOffset;
            FilesClustersCount[i, j] := rpb.EndOffset - rpb.StartOffset - 1;
            inc(j);
          end;
          inc(StartingLcn);
        until StartingLcn > rpb.EndOffset;
      end;
    finally
      CloseHandle(hVolume);
    end;
    PutClustersInStringGrid(StringGrid, NameColumn);
  end;
end;

procedure PutClustersInStringGrid(StringGrid: TStringGrid; NameColumn: String);
var
  k, j, i, old, oldest: integer;
begin
  StringGrid.Cells[CounterHeadColumn, 0] := NameColumn; //подготовка StringGrid
  if CounterHeadColumn > StringGrid.ColCount then
    StringGrid.ColCount := CounterHeadColumn;
  if CounterHeadRow > StringGrid.RowCount then
    StringGrid.RowCount := CounterHeadRow;

  oldest := 0; //начало вывода в StringGrid

  for k := 0 to Length(FilesStartClusters) - 1 do
  begin
    if Length(FilesStartClusters) - 1 <> k then
      StringGrid.ColCount := StringGrid.ColCount + 1;

    old := 0;
    for i := 0 to Length(FilesStartClusters[k]) - 1 do
    begin
      for j := 0 to FilesClustersCount[k, i] do
      begin
        if oldest < (old + j) then
          StringGrid.RowCount := StringGrid.RowCount + 1;
        StringGrid.Cells[CounterHeadColumn, j + old + 1] :=
          IntToStr(FilesStartClusters[k, i] + j);
      end;
      old := old + j;
      if oldest < old then
        oldest := old;
    end;
  end;

  maxRowCount := GetMaxNonEmptyRow(StringGrid) + 1; //подгон StringGrid под максимум кластеров
  if maxRowCount < StringGrid.RowCount then
    StringGrid.RowCount := maxRowCount;
end;

end.
