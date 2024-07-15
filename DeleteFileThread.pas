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
  {if not RemoveDir(Directory) then                                        -- этого говна не надо
    raise Exception.Create('Ошибка при удалении каталога ' + Directory); }

  // Выводим уведомление об успешном удалении всех файлов и каталогов
  ShowMessage('Все файлы и каталоги успешно удалены из каталога ' + Directory);
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
