unit MoveFileThread;

interface

uses
  System.Classes, Windows, SysUtils, Vcl.Dialogs, ShellAPI;

type
  MoveFilesThread = class(TThread)
  private
    FProgressMax: Int64;
    FProgressPosition: Int64;
    procedure Processing;
    procedure Execute; override;
    //procedure UpdateProgressBar;
  protected
   // procedure Processing;
    //procedure Execute; override;

  end;

implementation
  uses Unit2;

procedure MoveFilesAndFolders(const SourceDir, DestDir: string);
var
SourcePath, DestPath: string;
SearchRec: TSearchRec;
ErrorCode: DWORD;
begin
  SourcePath := IncludeTrailingBackslash(SourceDir);
  DestPath := IncludeTrailingBackslash(DestDir);

// ����� ���� ������ � ��������� � �������� ��������
  if FindFirst(SourcePath + '*.*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          SourcePath := IncludeTrailingBackslash(SourceDir) + SearchRec.Name;
          DestPath := IncludeTrailingBackslash(DestDir) + SearchRec.Name;

// ���� ��������� ������ - �������, ���������� ���������� ���
          if (SearchRec.Attr and faDirectory) <> 0 then
          begin
            CreateDir(DestPath); // ������� ������� � ����� �����
            MoveFilesAndFolders(SourcePath, DestPath); // ���������� ���������� ����������
          end
        else
          begin
// ���� ��������� ������ - ����, ���������� ���
            if not MoveFile(PChar(SourcePath), PChar(DestPath)) then
            begin
              ErrorCode := GetLastError;
// ��������� ������, ���� �� ������� ����������� ����
// ����� �������� ��� ��������� ������ �����
            end;
          end;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end else GetLastError;
  ShowMessage('��� ����� � �������� ������� ���������� � �������  ' + DestDir);
end;



procedure MoveFilesThread.Processing;
begin
  FProgressMax := 0;
  //CountFiles(Form2.Edit1.Text, '*.*', FProgressMax);
  FProgressPosition := 0;
  //Synchronize(UpdateProgressBar);

  MoveFilesAndFolders(Form2.Edit1.Text, Form2.Edit2.Text);
  {if MoveFiles(Handle, Form2.Edit1.Text, Form2.Edit2.Text, True, True) = 0 then
    begin
     FProgressPosition := FProgressMax; // ��������� � �������� ����� �����������
     Synchronize(UpdateProgressBar);
     ShowMessage('���� ������� ���������');
    end
  else
    ShowMessage('������');}
end;



procedure MoveFilesThread.Execute;
begin
  Synchronize(Processing);
end;

end.
