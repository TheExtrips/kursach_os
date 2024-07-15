unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Unit2, Unit3, Vcl.Menus, createAnonPipe;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    MainMenu1: TMainMenu;
    FileMenu: TMenuItem;
    HelpMenu: TMenuItem;
    ExitMenuOption: TMenuItem;
    N3: TMenuItem;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ExitMenuOptionClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    {Private declarations}
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
procedure TForm1.Button2Click(Sender: TObject);
begin
Form3 := Tform3.Create(self);
Form3.Show;
Form1.Hide;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Button1.Enabled := false;
  Button1.Visible := false;
  Button2.Enabled := false;
  Button2.Visible := false;
  Button3.Enabled := false;
  Button3.Visible := false;
  Button4.Enabled := true;
  Button4.Visible := true;
  CreateAnonymousPipe;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Button1.Enabled := true;
  Button1.Visible := true;
  Button2.Enabled := true;
  Button2.Visible := true;
  Button3.Enabled := true;
  Button3.Visible := true;
  Button4.Enabled := false;
  Button4.Visible := false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
Form2 := nil;
Form3 := nil;
end;

procedure TForm1.ExitMenuOptionClick(Sender: TObject);
begin
close;
end;

procedure TForm1.Button1Click(Sender: TObject);
//var Form2: TForm;
begin
Form2 := Tform2.Create(self);
Form2.Show;
Form1.Hide;
end;


end.