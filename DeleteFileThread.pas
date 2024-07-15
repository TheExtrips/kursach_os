unit DeleteFileThread;

interface

uses
  System.Classes, Windows, SysUtils, Vcl.Dialogs, ShellAPI;

type
  DeleteFilesThread = class(TThread)
  private
    procedure Processing;
  protected
    procedure Execute; override;
  end;

implementation
uses Unit3;
procedure DeleteAllFilesAndDirectories(const Directory: string);
var
  SearchRec: TSearchRec;
  FilePath: string;
begin
  // ����� ���� ������ � ��������� � ��������� ��������
  if FindFirst(IncludeTrailingBackslash(Directory) + '*.*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        // ���������� ������� � ������������ ��������
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          // ��������� ������ ���� � ����� ��� ��������
          FilePath := IncludeTrailingBackslash(Directory) + SearchRec.Name;
          // ���� ��� �������, ���������� ������� ��� ����������
          if (SearchRec.Attr and faDirectory) <> 0 then
            DeleteAllFilesAndDirectories(FilePath)
          else
            // �����, ������� ����
            if not DeleteFile(FilePath) then
              raise Exception.Create('������ ��� �������� ����� ' + FilePath);
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;

  // ������� ��� ������� ����� �������� ���� ������ � ������������
  {if not RemoveDir(Directory) then                                        -- ����� ����� �� ����
    raise Exception.Create('������ ��� �������� �������� ' + Directory); }

  // ������� ����������� �� �������� �������� ���� ������ � ���������
  ShowMessage('��� ����� � �������� ������� ������� �� �������� ' + Directory);
end;

procedure DeleteFilesThread.Processing;
begin
  DeleteAllFilesAndDirectories(Form3.Edit1.Text);
end;

procedure DeleteFilesThread.Execute;
begin
  Synchronize(Processing);
end;

end.
