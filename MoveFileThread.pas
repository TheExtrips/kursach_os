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

// Поиск всех файлов и каталогов в исходном каталоге
  if FindFirst(SourcePath + '*.*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          SourcePath := IncludeTrailingBackslash(SourceDir) + SearchRec.Name;
          DestPath := IncludeTrailingBackslash(DestDir) + SearchRec.Name;

// Если найденный объект - каталог, рекурсивно перемещаем его
          if (SearchRec.Attr and faDirectory) <> 0 then
          begin
            CreateDir(DestPath); // Создаем каталог в новом месте
            MoveFilesAndFolders(SourcePath, DestPath); // Рекурсивно перемещаем содержимое
          end
        else
          begin
// Если найденный объект - файл, перемещаем его
            if not MoveFile(PChar(SourcePath), PChar(DestPath)) then
            begin
              ErrorCode := GetLastError;
// Обработка ошибки, если не удалось переместить файл
// Можно добавить код обработки ошибки здесь
            end;
          end;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end else GetLastError;
  ShowMessage('Все файлы и каталоги успешно перемещены в каталог  ' + DestDir);
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
     FProgressPosition := FProgressMax; // Обновляем с позицией после копирования
     Synchronize(UpdateProgressBar);
     ShowMessage('Файл успешно перемещен');
    end
  else
    ShowMessage('Ошибка');}
end;



procedure MoveFilesThread.Execute;
begin
  Synchronize(Processing);
end;

end.
