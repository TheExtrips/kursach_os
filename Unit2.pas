unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.FileCtrl, Vcl.Buttons,
  Vcl.ComCtrls, MoveFileThread, Vcl.Grids, System.IOUtils, System.Types, Clusters;

type
  TForm2 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Button3: TButton;
    SpeedButton1: TSpeedButton;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    Label3: TLabel;
    Label4: TLabel;
    ClearButton: TButton;
    Button4: TButton;
    Button5: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    MoveFile : MoveFilesThread;

  end;
 function GetDriveFileSystem(const APath: string): string;
var
  Form2: TForm2;

implementation

{$R *.dfm}

uses Unit1;

procedure TForm2.Button1Click(Sender: TObject);
var dir : string;
begin
if SelectDirectory('Выберите каталог', 'C:/', dir) then Edit1.Text := dir;
   dir:= '';
if Edit1.Text = Edit2.Text then
begin
 MessageDlg ('Нельзя выбрать одинаковые каталоги', mtError, [mbOK], 0);
 Edit1.Text := '';
end;
end;

procedure TForm2.Button2Click(Sender: TObject);
var dir : string;
begin
if SelectDirectory('Выберите каталог', 'C:/', dir) then Edit2.Text := dir;
   dir:= '';
if Edit2.Text = Edit1.Text then
begin
 MessageDlg ('Нельзя выбрать одинаковые каталоги', mtError, [mbOK], 0);
 Edit2.Text := '';
end;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
Form1.Show;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) OR WS_EX_APPWINDOW);

end;

procedure TForm2.SpeedButton1Click(Sender: TObject);
var buffer : string;
begin
 buffer:= Edit1.Text;
 Edit1.Text := Edit2.Text;
 Edit2.Text:= buffer;
 buffer := '';
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
  if (Edit1.Text = '') or (Edit2.Text = '') then exit;
       //перемещение файлов через поток
  MoveFile:= MoveFilesThread.Create(True);
  try
      MoveFile.FreeOnTerminate := True;
      MoveFile.Start;
  except
     on E: Exception do
     begin
        MoveFile.Free;
        ShowMessage(E.Message);
     end;
  end;
end;

procedure TForm2.Button4Click(Sender: TObject);
begin
  if GetDriveFileSystem(Edit1.Text) <> 'FAT32'then
    begin
      MessageDlg ('Невозможно получить цепочки кластеров файлов для этой файловой системы. Выберите директорию на диске с FAT32.', mtError, [mbOK], 0);
      exit;
    end;

  ClearStringGrid(StringGrid1);
  GetFATforFile(Edit1.Text, StringGrid1);
end;

procedure TForm2.Button5Click(Sender: TObject);
begin
  if GetDriveFileSystem(Edit2.Text) <> 'FAT32'then
    begin
      MessageDlg ('Невозможно получить цепочки кластеров файлов для этой файловой системы. Выберите директорию на диске с FAT32.', mtError, [mbOK], 0);
      exit;
    end;
  ClearStringGrid(StringGrid2);
  GetFATforFile(Edit2.Text, StringGrid2);
end;

procedure TForm2.ClearButtonClick(Sender: TObject);
begin
  ClearStringGrid(StringGrid1);
  ClearStringGrid(StringGrid2);
end;

function GetDriveFileSystem(const APath: string): string;
var drive:string;
FileSystemName: PChar;
MaxFileNameLen, FSFlags:DWORD;
begin
  if Length(APath) > 1 then
    begin
      drive := APath[1] + ':\';
      GetMem(FileSystemName,100);
      GetVolumeInformation(PChar(drive), NIL, 0, NIL, MaxFileNameLen,
                              FSFlags, FileSystemName, 100);
      Result := FileSystemName;
    end
  else
    Result := '';
end;

end.
