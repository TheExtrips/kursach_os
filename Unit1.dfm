object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'kursachOS'
  ClientHeight = 211
  ClientWidth = 429
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu1
  OnCreate = FormCreate
  TextHeight = 15
  object Button1: TButton
    Left = 24
    Top = 32
    Width = 385
    Height = 33
    Caption = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100' '#1092#1072#1081#1083#1099' '#1080#1079' '#1074#1099#1073#1088#1072#1085#1085#1086#1075#1086' '#1082#1072#1090#1072#1083#1086#1075#1072
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 24
    Top = 96
    Width = 385
    Height = 33
    Caption = #1059#1076#1072#1083#1080#1090#1100' '#1092#1072#1081#1083#1099' '#1080#1079' '#1082#1072#1090#1072#1083#1086#1075#1072
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 24
    Top = 160
    Width = 385
    Height = 33
    Caption = #1054#1073#1084#1077#1085' '#1076#1072#1085#1085#1099#1084#1080' '#1084#1077#1078#1076#1091' '#1087#1088#1086#1094#1077#1089#1089#1072#1084#1080
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 128
    Top = 135
    Width = 177
    Height = 25
    Caption = #1053#1072#1078#1084#1080#1090#1077', '#1095#1090#1086#1073#1099' '#1074#1099#1081#1090#1080' '#1074' '#1084#1077#1085#1102
    Enabled = False
    TabOrder = 3
    Visible = False
    OnClick = Button4Click
  end
  object MainMenu1: TMainMenu
    Left = 336
    Top = 128
    object FileMenu: TMenuItem
      Caption = #1060#1072#1081#1083
      object ExitMenuOption: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = ExitMenuOptionClick
      end
    end
    object HelpMenu: TMenuItem
      Caption = #1055#1086#1084#1086#1097#1100
      object N3: TMenuItem
        Caption = #1055#1086#1084#1086#1097#1080' '#1085#1077' '#1073#1091#1076#1077#1090
      end
    end
  end
end
