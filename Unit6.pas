unit Unit6;

interface

uses
  System.Classes, Windows, SysUtils, Vcl.Dialogs, Grids;

type
  TClustersOfFileThread = class(TThread)
  private
  protected
    procedure Execute; override;
    procedure Processing;
  public
    Files : TStrings;
    Count : integer;     //byte - номер файла, word - номер цепочки
    FilesStartClusters : array of array of int64;
    FilesClustersCount : array of array of int64
  end;
  var CounterHeadColumn: integer = -1;
  CounterHeadRow: integer = 0;
  maxRowCount: Integer;

procedure GetFATforFile(file_name : string);

implementation
  uses Unit2;
//var
  //Sources : TStrings;

procedure TClustersOfFileThread.Processing;
  type
    RETRIEVAL_POINTERS_BUFFER =
      Record
        ExtentCount1:dword;
        StartOffset:int64;
        EndOffset:int64;
        CurrentOffset:int64;
      End;
  var
    hVolume: THandle;
    cbret: cardinal;
    bol1: longbool;
    rpb: RETRIEVAL_POINTERS_BUFFER;
    StartingLcn: int64;
    j,i: integer;
    current: int64;

  begin
    SetLength(FilesStartClusters, Count);
    SetLength(FilesClustersCount, Count);


     hVolume:= CreateFile(PChar(form2.label3.caption), GENERIC_READ, 0, nil, OPEN_EXISTING, 0, 0);
     if hVolume = INVALID_HANDLE_VALUE then ShowMessage('Ошибка! не удалось найти файл ')
  else try
    begin
    for i := 0 to (Count - 1) do
      begin
        j:= 0;
        current := 0;
        bol1:=true;
        StartingLcn:=0;

            repeat
              bol1:= DeviceIoControl(hVolume, FSCTL_GET_RETRIEVAL_POINTERS,
              @StartingLcn , 8, @rpb, sizeof(rpb), cbret, nil);
              if current <> rpb.CurrentOffset
                then
                  begin
                    current := rpb.CurrentOffset;
                    SetLength(FilesStartClusters[i], j+1);
                    SetLength(FilesClustersCount[i], j+1);
                    FilesStartClusters[i,j] := rpb.CurrentOffset;
                    FilesClustersCount[i,j] := rpb.EndOffset - rpb.StartOffset-1;   //  -1, чтоб не выходил из массива
                    inc(j);
                  end;
              inc(StartingLcn);
            until StartingLcn > rpb.EndOffset;
      end;
    end;
  finally
    CloseHandle(hVolume);
  end;

  end;

procedure TClustersOfFileThread.Execute;
  begin
    Synchronize(Processing);
  end;

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
        Exit;
      end;
    end;
  end;
end;

  procedure GetFATforFile(file_name : string);
  var
  k, i, j, old, oldest: Integer;
   ColumnHeaderText: string;
   ClusterInfo : TClustersOfFileThread; ///-----------------------------------

begin
  CounterHeadColumn := CounterHeadColumn + 1;

  if true then
  begin
    ColumnHeaderText := file_name;///-------------------------------
    ClusterInfo := TClustersOfFileThread.Create(True);
    ClusterInfo.Count := 1;
    ClusterInfo.Resume;
    ClusterInfo.WaitFor;
    Form2.StringGrid1.Cells[CounterHeadColumn, 0] := ColumnHeaderText;///////////-=-=-=-
    if CounterHeadColumn > Form2.StringGrid1.ColCount then
      Form2.StringGrid1.ColCount := CounterHeadColumn;
    if CounterHeadRow > Form2.StringGrid1.RowCount then
      Form2.StringGrid1.RowCount := CounterHeadRow;

    oldest := 0;

    for k := 0 to Length(ClusterInfo.FilesStartClusters) - 1 do
    begin
      if Length(ClusterInfo.FilesStartClusters) - 1 <> k then
        Form2.StringGrid1.ColCount := Form2.StringGrid1.ColCount + 1;

      old := 0;
      for i := 0 to Length(ClusterInfo.FilesStartClusters[k]) - 1 do
      begin
        for j := 0 to ClusterInfo.FilesClustersCount[k, i]  do
        begin
          if oldest < (old + j) then
            Form2.StringGrid1.RowCount := Form2.StringGrid1.RowCount + 1;
          Form2.StringGrid1.Cells[CounterHeadColumn, j + old + 1] :=
            IntToStr(ClusterInfo.FilesStartClusters[k, i] + j);
        end;
        old := old + j;
        if oldest < old then
          oldest := old;
      end;
    end;

    maxRowCount := GetMaxNonEmptyRow(Form2.StringGrid1) + 1;
    if maxRowCount < Form2.StringGrid1.RowCount then
    Form2.StringGrid1.RowCount := maxRowCount;

    FreeAndNil(ClusterInfo);
  end;
end;

end.
