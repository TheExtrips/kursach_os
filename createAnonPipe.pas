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
    // ����� ����������� ������
    //StrPCopy(lpszComLine2, 'F:\\DELPHI PROJECTS\\example\\Win32\\Debug\\example.exe');
    //StrPCopy(lpszComLine1, 'F:\\DELPHI PROJECTS\\client1\\Win32\\Debug\\client1.exe');
    //StrPCopy(lpszComLine2, 'F:\\DELPHI PROJECTS\\client2\\Win32\\Debug\\client2.exe');
    StrPCopy(lpszComLine1,filepath);
    filepath := extractfilepath(ParamStr(0));
    filepath := filepath + 'client2.exe';
    StrPCopy(lpszComLine2, filepath);

    // ������������� �������� ������ ������
    sa.nLength := SizeOf(SECURITY_ATTRIBUTES);
    sa.lpSecurityDescriptor := nil; // ������ �� ���������
    sa.bInheritHandle := True;      // ����������� �����������

    // ������� ��������� �����
    if not CreatePipe(hReadPipe, hWritePipe, @sa, 0) then
    begin
      Exit;
    end;

    // ������������� �������� ������ ��������
    ZeroMemory(@si, SizeOf(STARTUPINFO));
    si.cb := SizeOf(STARTUPINFO);
    // ������������ ����������� �����������
    si.dwFlags := STARTF_USESTDHANDLES;
    // ������������� ����������� �����������
    si.hStdInput := hReadPipe;
    si.hStdOutput := hWritePipe;
    si.hStdError := hWritePipe;

    // ��������� ������� �������
    if not CreateProcess(nil, lpszComLine1, nil, nil, True,  //5-�� �������� ������ ���� True (����������� �����������)
                         CREATE_NEW_CONSOLE, nil, nil, si, pi) then //�� � True ������� ��������
    begin
      Exit;
    end;

    // ��������� ����������� ������� �������
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);


    // ��������� ������� �������
    if not CreateProcess(nil, lpszComLine2, nil, nil, True,
                         CREATE_NEW_CONSOLE, nil, nil, si, pi) then
    begin
      Exit;
    end;

    // ��������� ����������� ������� �������
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);

    // ��������� ����������� ������
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

