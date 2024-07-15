unit createAnonPipe;

interface
uses
  SysUtils, Windows;

procedure CreateAnonymousPipe;

implementation

procedure CreateAnonymousPipe;
var
  lpszComLine1, lpszComLine2: array [0..200] of Char;
  si: STARTUPINFO;
  pi: PROCESS_INFORMATION;
  hWritePipe, hReadPipe: THandle;
  sa: SECURITY_ATTRIBUTES;
  filepath : string;

begin
  try
    filepath := extractfilepath(ParamStr(0));
    filepath := filepath + 'client1.exe';
    // имена исполняемых файлов
    //StrPCopy(lpszComLine2, 'F:\\DELPHI PROJECTS\\example\\Win32\\Debug\\example.exe');
    //StrPCopy(lpszComLine1, 'F:\\DELPHI PROJECTS\\client1\\Win32\\Debug\\client1.exe');
    //StrPCopy(lpszComLine2, 'F:\\DELPHI PROJECTS\\client2\\Win32\\Debug\\client2.exe');
    StrPCopy(lpszComLine1,filepath);
    filepath := extractfilepath(ParamStr(0));
    filepath := filepath + 'client2.exe';
    StrPCopy(lpszComLine2, filepath);

    // устанавливаем атрибуты защиты канала
    sa.nLength := SizeOf(SECURITY_ATTRIBUTES);
    sa.lpSecurityDescriptor := nil; // защита по умолчанию
    sa.bInheritHandle := True;      // дескрипторы наследуемые

    // создаем анонимный канал
    if not CreatePipe(hReadPipe, hWritePipe, @sa, 0) then
    begin
      Exit;
    end;

    // устанавливаем атрибуты нового процесса
    ZeroMemory(@si, SizeOf(STARTUPINFO));
    si.cb := SizeOf(STARTUPINFO);
    // использовать стандартные дескрипторы
    si.dwFlags := STARTF_USESTDHANDLES;
    // устанавливаем стандартные дескрипторы
    si.hStdInput := hReadPipe;
    si.hStdOutput := hWritePipe;
    si.hStdError := hWritePipe;

    // запускаем первого клиента
    if not CreateProcess(nil, lpszComLine1, nil, nil, True,  //5-ый параметр должен быть True (наследуемые дескрипторы)
                         CREATE_NEW_CONSOLE, nil, nil, si, pi) then //но с True процесс зависает
    begin
      Exit;
    end;

    // закрываем дескрипторы первого клиента
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);


    // запускаем второго клиента
    if not CreateProcess(nil, lpszComLine2, nil, nil, True,
                         CREATE_NEW_CONSOLE, nil, nil, si, pi) then
    begin
      Exit;
    end;

    // закрываем дескрипторы второго клиента
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);

    // закрываем дескрипторы канала
    CloseHandle(hReadPipe);
    CloseHandle(hWritePipe);


  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
    end;
  end;
end;
end.

