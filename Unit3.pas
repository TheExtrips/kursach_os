unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.FileCtrl, DeleteFileThread;

type
  TForm3 = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    DeleteFileThrd : DeleteFilesThread;
  end;

var
  Form3: TForm3;

implementation
uses Unit1;

{$R *.dfm}

procedure TForm3.Button1Click(Sender: TObject);
var dir: string;
begin
if SelectDirectory('�������� �������', 'C:/', dir) then Edit1.Text := dir;
   dir:= '';
end;



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
  {if not RemoveDir(Directory) then
    raise Exception.Create('������ ��� �������� �������� ' + Directory); }

  // ������� ����������� �� �������� �������� ���� ������ � ���������
  ShowMessage('��� ����� � �������� ������� ������� �� �������� ' + Directory);
end;

{procedure TForm3.Button2Click(Sender: TObject);
begin
 DeleteAllFilesAndDirectories (Edit1.Text);
end;}
procedure TForm3.Button2Click(Sender: TObject);
begin
  if MessageDlg('������������ �������� ���� ������ � ���� ����������. ����������?  ',
    mtConfirmation, [mbYes, mbNo], 0, TMsgDlgBtn.mbYes) <> mrYes then
    Exit;

  DeleteFileThrd := DeleteFilesThread.Create(True);
  try
    DeleteFileThrd.FreeOnTerminate := True;
    DeleteFileThrd.Start;
  except
    on E: Exception do
    begin
      DeleteFileThrd.Free;
      ShowMessage(E.Message);
    end;
  end;
end;

procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
begin
Form1.Show;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) OR WS_EX_APPWINDOW);

end;

end.
