unit Kraken.Service.Manager;

interface

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.WinSvc,
  Vcl.Forms,
  Vcl.SvcMgr;

type
  TInstallType = ( itInstall, itUninstall );

  TKrakenServiceManager = class
    constructor Create;
    destructor Destroy; override;
  private
    ServiceHandle: SC_Handle;
    ServiceControlManager: SC_Handle;

    function IsDesktopMode(AServiceName: PWideChar): Boolean;

    function ServiceGetStatus( sMachine, sService : string ) : DWord;

    function ServiceRunning( sMachine, sService : string ) : boolean;
    function ServiceStopped( sMachine, sService : string ) : boolean;

    procedure ExecProcess(AExeName: string; AType: TInstallType);

    function Connect: Boolean;
    procedure Start(NumberOfArgument: DWORD; ServiceArgVectors: PChar);
  public
    function TryRunAsService(AServiceName, ADisplayName: PWideChar): Boolean;

    procedure StartService;
    procedure ContinueService;
    procedure RestartService;
    procedure StopService;
    procedure ShutdownService;
    procedure DisableService;

    procedure Install;
    procedure Uninstall;
  end;

  function KrakenServiceManager: TKrakenServiceManager;

var
  FKrakenServiceManagerInstance: TKrakenServiceManager;

implementation

uses
  Kraken.Service,
  Kraken.Service.Instance;

function KrakenServiceManager: TKrakenServiceManager;
begin
  if FKrakenServiceManagerInstance = nil then
    FKrakenServiceManagerInstance := TKrakenServiceManager.Create;
  Result := FKrakenServiceManagerInstance;
end;

{ TKrakenServiceManager }

constructor TKrakenServiceManager.Create;
begin

end;

destructor TKrakenServiceManager.Destroy;
begin

  inherited;
end;

function TKrakenServiceManager.IsDesktopMode(AServiceName: PWideChar): Boolean;
begin
  Result := False;

  if
    (Win32Platform <> VER_PLATFORM_WIN32_NT) or
    FindCmdLineSwitch( 'P', ['-', '/'], True ) or
    (
      ( not FindCmdLineSwitch( 'INSTALL'    , ['-', '/'], True ) ) and
      ( not FindCmdLineSwitch( 'UNINSTALL'  , ['-', '/'], True ) ) and
      ( not FindCmdLineSwitch( 'RUNSERVICE' , ['-', '/'], True ) ) and
      ( not FindCmdLineSwitch( 'RESTART'    , ['-', '/'], True ) )
    )
  then
    Result := True
  else
  begin
    Result := not FindCmdLineSwitch( 'INSTALL'    , ['-', '/'], True ) and
              not FindCmdLineSwitch( 'UNINSTALL'  , ['-', '/'], True ) and
              not FindCmdLineSwitch( 'RUNSERVICE' , ['-', '/'], True ) and
              not FindCmdLineSwitch( 'RESTART'    , ['-', '/'], True ) ;
  end;
end;


//-------------------------------------
// get service status
//
// return status code if successful
// -1 if not
//
// return codes:
//   SERVICE_STOPPED
//   SERVICE_RUNNING
//   SERVICE_PAUSED
//
// following return codes
// are used to indicate that
// the service is in the
// middle of getting to one
// of the above states:
//   SERVICE_START_PENDING
//   SERVICE_STOP_PENDING
//   SERVICE_CONTINUE_PENDING
//   SERVICE_PAUSE_PENDING
//
// sMachine:
//   machine name, ie: \SERVER
//   empty = local machine
//
// sService
//   service name, ie: Alerter
//-------------------------------------
function TKrakenServiceManager.ServiceGetStatus(sMachine, sService : string ) : DWord;
var
  LservCtrlMngHndl : SC_HANDLE;
  LserviceHndl     : SC_Handle;
  LstatusService   : TServiceStatus;
  LdwStat          : DWord;
begin
  LdwStat := 0;

  // connect to the service control manager
  LServCtrlMngHndl := OpenSCManager( PChar(sMachine), Nil, SC_MANAGER_CONNECT );

  if ( LServCtrlMngHndl > 0 ) then
  begin
    // open a handle to the specified service
    LServiceHndl := OpenService( LServCtrlMngHndl, PChar(sService), SERVICE_QUERY_STATUS );

    if ( LServiceHndl > 0 ) then
    begin
      // retrieve the current status of the specified service
      if ( QueryServiceStatus( LServiceHndl, LStatusService ) ) then
        LdwStat := LStatusService.dwCurrentState;

      // close service handle
      CloseServiceHandle(LServiceHndl);
    end;

    // close service control manager handle
    CloseServiceHandle(LServCtrlMngHndl);
  end;

  Result := LdwStat;
end;

//-------------------------------------
// return TRUE if the specified
// service is running, defined by
// the status code SERVICE_RUNNING.
// return FALSE if the service
// is in any other state, including
// any pending states
//-------------------------------------
function TKrakenServiceManager.ServiceRunning(sMachine, sService : string) : boolean;
begin
  Result :=
    ( SERVICE_RUNNING          = ServiceGetStatus( sMachine, sService ) ) or
    ( SERVICE_CONTINUE_PENDING = ServiceGetStatus( sMachine, sService ) );
end;

//-------------------------------------
// return TRUE if the specified
// service was stopped, defined by
// the status code SERVICE_STOPPED.
//-------------------------------------
function TKrakenServiceManager.ServiceStopped(sMachine, sService : string) : boolean;
begin
  Result :=
    ( SERVICE_STOPPED      = ServiceGetStatus( sMachine, sService ) ) or
    ( SERVICE_STOP_PENDING = ServiceGetStatus( sMachine, sService ) );
end;

procedure TKrakenServiceManager.ExecProcess(AExeName: string; AType: TInstallType);
var
  sParams            : String;
  StartupInfo        : TStartupInfo;
  ProcessInformation : TProcessInformation;
begin
  case AType of
    TInstallType.itInstall  : sParams := ' /install';
    TInstallType.itUnInstall: sParams := ' /unInstall';
  end;

  FillChar(StartupInfo, SizeOf(StartupInfo), #0);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_HIDE;

  if CreateProcess( Nil, PChar( AExeName + sParams ), Nil, Nil, False,
                           NORMAL_PRIORITY_CLASS, Nil,
                           PChar( ExtractFileDir( AExeName ) ),
                           StartupInfo, ProcessInformation ) then
  begin
    try
      WaitForSingleObject( ProcessInformation.hProcess, INFINITE);
    finally
      CloseHandle( ProcessInformation.hProcess);
      CloseHandle( ProcessInformation.hThread);
    end;
  end
  else
    Raise Exception.Create(Format('The operation %s could not executed.', [sParams]));
end;

function TKrakenServiceManager.TryRunAsService(AServiceName, ADisplayName: PWideChar): Boolean;
begin
  Result := False;

  if not KrakenServiceManager.IsDesktopMode( AServiceName ) then
  begin
    if
      ( not Vcl.SvcMgr.Application.DelayInitialize ) or
      ( Vcl.SvcMgr.Application.Installing )
    then
      Vcl.SvcMgr.Application.Initialize;

    Vcl.SvcMgr.Application.Title := ADisplayName;
    Vcl.SvcMgr.Application.CreateForm( TKrakenInstance, KrakenInstance );
    Vcl.SvcMgr.Application.Run;

    Result := True;
  end;
end;

function TKrakenServiceManager.Connect: Boolean;
begin
  Result := False;

  ServiceControlManager := OpenSCManager('', nil, SC_MANAGER_CONNECT);
  ServiceHandle := OpenService(ServiceControlManager, KrakenService.ServiceName, SERVICE_ALL_ACCESS);
end;

procedure TKrakenServiceManager.Start(NumberOfArgument: DWORD; ServiceArgVectors: PChar);
begin
  Connect;
  Winapi.WinSvc.StartService(ServiceHandle, NumberOfArgument, ServiceArgVectors);
end;

procedure TKrakenServiceManager.StartService;
begin
  Start(0, '');
end;

procedure TKrakenServiceManager.ContinueService;
var
  ServiceStatus: TServiceStatus;
begin
  Connect;
  ControlService(ServiceHandle, SERVICE_CONTROL_CONTINUE, ServiceStatus);
end;

procedure TKrakenServiceManager.RestartService;
begin
  StopService;
  StartService;
end;

procedure TKrakenServiceManager.StopService;
var
  ServiceStatus: TServiceStatus;
begin
  Connect;
  ControlService(ServiceHandle, SERVICE_CONTROL_STOP, ServiceStatus);
end;

procedure TKrakenServiceManager.ShutdownService;
var
  ServiceStatus: TServiceStatus;
begin
  Connect;
  ControlService(ServiceHandle, SERVICE_CONTROL_SHUTDOWN, ServiceStatus);
end;

procedure TKrakenServiceManager.DisableService;
begin

end;

procedure TKrakenServiceManager.Install;
begin
  ExecProcess( ParamStr(0), TInstallType.itInstall );
  Sleep( 2000 );
end;

procedure TKrakenServiceManager.Uninstall;
begin
  ExecProcess( ParamStr(0), TInstallType.itUninstall );
  Sleep( 2000 );
end;

initialization

finalization
  if FKrakenServiceManagerInstance <> nil then
    FKrakenServiceManagerInstance.Free;

end.
