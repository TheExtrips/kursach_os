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
if SelectDirectory('Выберите каталог', 'C:/', dir) then Edit1.Text := dir;
   dir:= '';
end;



procedure DeleteAllFilesAndDirectories(const Directory: string);
var
  SearchRec: TSearchRec;
  FilePath: string;
begin
  // Поиск всех файлов и каталогов в указанном каталоге
  if FindFirst(IncludeTrailingBackslash(Directory) + '*.*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        // Игнорируем текущий и родительский каталоги
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          // Формируем полный путь к файлу или каталогу
          FilePath := IncludeTrailingBackslash(Directory) + SearchRec.Name;
          // Если это каталог, рекурсивно удаляем его содержимое
          if (SearchRec.Attr and faDirectory) <> 0 then
            DeleteAllFilesAndDirectories(FilePath)
          else
            // Иначе, удаляем файл
            if not DeleteFile(FilePath) then
              raise Exception.Create('Ошибка при удалении файла ' + FilePath);
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;

  // Удаляем сам каталог после удаления всех файлов и подкаталогов
  {if not RemoveDir(Directory) then
    raise Exception.Create('Ошибка при удалении каталога ' + Directory); }

  // Выводим уведомление об успешном удалении всех файлов и каталогов
  ShowMessage('Все файлы и каталоги успешно удалены из каталога ' + Directory);
end;

{procedure TForm3.Button2Click(Sender: TObject);
begin
 DeleteAllFilesAndDirectories (Edit1.Text);
end;}
procedure TForm3.Button2Click(Sender: TObject);
begin
  if MessageDlg('Произведется удаление всех файлов в этой директории. Продолжить?  ',
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
