unit Kraken.Service;

interface

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.WinSvc,
  Vcl.Forms,
  Vcl.SvcMgr,
  Kraken.Service.Manager,
  Kraken.Service.Contract;

type
  iKrakenService   = Kraken.Service.Contract.iKrakenService;

  TKrakenService = class(TInterfacedObject, iKrakenService)
    constructor Create;
    destructor Destroy; override;
    class function New: iKrakenService;
  private
    FKrakenAfterInstall      : TKrakenServiceEvent;
    FKrakenBeforeInstall     : TKrakenServiceEvent;
    FKrakenAfterUninstall    : TKrakenServiceEvent;
    FKrakenBeforeUninstall   : TKrakenServiceEvent;
    FKrakenServiceOnStart    : TKrakenServiceEvent;
    FKrakenServiceOnStop     : TKrakenServiceEvent;
    FKrakenServiceOnPause    : TKrakenServiceEvent;
    FKrakenServiceOnContinue : TKrakenServiceEvent;
    FKrakenServiceOnExecute  : TKrakenServiceEvent;
    FKrakenServiceOnDestroy  : TKrakenServiceEvent;

    FKrakenStartType         : Vcl.SvcMgr.TStartType;
    FServiceName             : PWideChar;
    FDisplayName             : PWideChar;
    FServiceDetail           : PWideChar;
    FExecuteInterval         : Integer;
    FServiceStartName        : PWideChar;
    FServicePassword         : PWideChar;

    FGUIControl              : TComponentClass;
    FGUIRef                  : TComponent;
  public
    function StartType( AKrakenStartType: Vcl.SvcMgr.TStartType ): iKrakenService; overload;
    function StartType: Vcl.SvcMgr.TStartType; overload;

    function ServiceName( AServiceName: PWideChar ): iKrakenService; overload;
    function ServiceName: PWideChar; overload;

    function DisplayName( ADisplayName: PWideChar ): iKrakenService; overload;
    function DisplayName: PWideChar; overload;

    function ServiceDetail( AServiceDetail: PWideChar ): iKrakenService; overload;
    function ServiceDetail: PWideChar; overload;

    function ExecuteInterval( AExecuteInterval: Integer ): iKrakenService; overload;
    function ExecuteInterval: Integer; overload;

    function GUI( AForm: TComponentClass; var AReference ): iKrakenService;

    function ServiceStartName( const AServiceStartName: PWideChar ): iKrakenService; overload;
    function ServiceStartName: PWideChar; overload;

    function ServicePassword ( const AServicePassword: PWideChar ): iKrakenService; overload;
    function ServicePassword: PWideChar; overload;

    function AfterInstall( AKrakenServiceProc: TKrakenServiceEvent ): iKrakenService; overload;
    function AfterInstall: TKrakenServiceEvent; overload;

    function BeforeInstall( AKrakenServiceProc: TKrakenServiceEvent ): iKrakenService; overload;
    function BeforeInstall: TKrakenServiceEvent; overload;

    function AfterUninstall( AKrakenServiceProc: TKrakenServiceEvent ): iKrakenService; overload;
    function AfterUninstall: TKrakenServiceEvent; overload;

    function BeforeUninstall( AKrakenServiceProc: TKrakenServiceEvent ): iKrakenService; overload;
    function BeforeUninstall: TKrakenServiceEvent; overload;

    function OnStart( AKrakenServiceOnStart: TKrakenServiceEvent ): iKrakenService; overload;
    function OnStart: iKrakenService; overload;

    function OnStop( AKrakenServiceOnStop: TKrakenServiceEvent ): iKrakenService; overload;
    function OnStop: iKrakenService; overload;

    function OnPause( AKrakenServiceOnPause: TKrakenServiceEvent ): iKrakenService; overload;
    function OnPause: iKrakenService; overload;

    function OnContinue( AKrakenServiceOnContinue : TKrakenServiceEvent ): iKrakenService; overload;
    function OnContinue: iKrakenService; overload;

    function OnExecute( AKrakenServiceProc : TKrakenServiceEvent ): iKrakenService; overload;
    function OnExecute: iKrakenService; overload;

    function OnDestroy( AKrakenServiceProc : TKrakenServiceEvent ): iKrakenService; overload;
    function OnDestroy: iKrakenService; overload;

    function Dependencies( ADependencies: TKrakenDependencies ): iKrakenService;

    function Manager: TKrakenServiceManager;

    procedure TryRunAsService;

    procedure Install;
    procedure Uninstall;
  end;

  function KrakenService: iKrakenService;

  procedure WriteLog(ALog: String);
  function FileLogName: string;

implementation

uses
  Kraken.Service.Instance;

var
  FInstance: iKrakenService;

function KrakenService: iKrakenService;
begin
  if not Assigned(FInstance) then
    FInstance := TKrakenService.New;
  Result := FInstance;
end;

function FileLogName: string;
begin
  Result := ExtractFilePath(GetModuleName(HInstance)) + 'sample.log';
end;

procedure WriteLog(ALog: String);
var
  fileName: string;
begin
  fileName := FileLogName;
  with TStringList.Create do
  try
    if FileExists(FileName) then
      LoadFromFile(fileName);

    Add(FormatDateTime('yyyy-MM-dd hh:mm:ss', now) + ' ' + ALog);
    SaveToFile(fileName);
  finally
    Free;
  end;
end;

{ TKrakenService }

constructor TKrakenService.Create;
begin
  FServiceName      := 'KrakenServ';
  FDisplayName      := 'KrakenService';
  FServiceDetail    := 'Windows service creation framework';
  FExecuteInterval  := 3000;
  FServiceStartName := '';
  FServicePassword  := '';
end;

destructor TKrakenService.Destroy;
begin

  inherited;
end;

class function TKrakenService.New: iKrakenService;
begin
  Result := TKrakenService.Create;
end;

function TKrakenService.StartType(AKrakenStartType: Vcl.SvcMgr.TStartType): iKrakenService;
begin
  Result := Self;
  FKrakenStartType := AKrakenStartType;
end;

function TKrakenService.StartType: Vcl.SvcMgr.TStartType;
begin
  Result := FKrakenStartType;
end;

function TKrakenService.ServiceName(AServiceName: PWideChar): iKrakenService;
begin
  Result := Self;
  FServiceName := AServiceName;
end;

function TKrakenService.ServiceName: PWideChar;
begin
  Result := FServiceName;
end;

function TKrakenService.DisplayName(ADisplayName: PWideChar): iKrakenService;
begin
  Result := Self;
  FDisplayName := ADisplayName;
end;

function TKrakenService.DisplayName: PWideChar;
begin
  Result := FDisplayName;
end;

function TKrakenService.ServiceDetail(AServiceDetail: PWideChar): iKrakenService;
begin
  Result := Self;
  FServiceDetail := AServiceDetail;
end;

function TKrakenService.ServiceDetail: PWideChar;
begin
  Result := FServiceDetail;
end;

function TKrakenService.ServiceStartName(const AServiceStartName: PWideChar): iKrakenService;
begin
  Result := Self;
  FServiceStartName := AServiceStartName;
end;

function TKrakenService.ServiceStartName: PWideChar;
begin
  Result := FServiceStartName;
end;

function TKrakenService.ServicePassword(const AServicePassword: PWideChar): iKrakenService;
begin
  Result := Self;
  FServicePassword := AServicePassword;
end;

function TKrakenService.ServicePassword: PWideChar;
begin
  Result := FServicePassword;
end;

function TKrakenService.ExecuteInterval( AExecuteInterval: Integer ): iKrakenService;
begin
  Result := Self;
  FExecuteInterval := AExecuteInterval;
end;

function TKrakenService.ExecuteInterval: Integer;
begin
  Result := FExecuteInterval;
end;

function TKrakenService.GUI(AForm: TComponentClass; var AReference): iKrakenService;
begin
  Result := Self;
  FGUIControl := AForm;
  FGUIRef := TComponent( AReference );
end;

function TKrakenService.AfterInstall(AKrakenServiceProc: TKrakenServiceEvent): iKrakenService;
begin
  Result := Self;
  FKrakenAfterInstall := AKrakenServiceProc;
end;

function TKrakenService.AfterInstall: TKrakenServiceEvent;
begin
  Result := FKrakenAfterInstall;
end;

function TKrakenService.BeforeInstall(AKrakenServiceProc: TKrakenServiceEvent): iKrakenService;
begin
  Result := Self;
  FKrakenBeforeInstall := AKrakenServiceProc;
end;

function TKrakenService.BeforeInstall: TKrakenServiceEvent;
begin
  Result := FKrakenBeforeInstall;
end;

function TKrakenService.AfterUninstall(AKrakenServiceProc: TKrakenServiceEvent): iKrakenService;
begin
  Result := Self;
  FKrakenAfterUninstall := AKrakenServiceProc;
end;

function TKrakenService.AfterUninstall: TKrakenServiceEvent;
begin
  Result := FKrakenAfterUninstall;
end;

function TKrakenService.BeforeUninstall(AKrakenServiceProc: TKrakenServiceEvent): iKrakenService;
begin
  Result := Self;
  FKrakenBeforeUninstall := AKrakenServiceProc;
end;

function TKrakenService.BeforeUninstall: TKrakenServiceEvent;
begin
  Result := FKrakenBeforeUninstall;
end;

function TKrakenService.OnStart(AKrakenServiceOnStart: TKrakenServiceEvent): iKrakenService;
begin
  Result := Self;
  FKrakenServiceOnStart := AKrakenServiceOnStart;
end;

function TKrakenService.OnStart: iKrakenService;
begin
  Result := Self;
  FKrakenServiceOnStart;
end;

function TKrakenService.OnExecute(AKrakenServiceProc : TKrakenServiceEvent): iKrakenService;
begin
  Result := Self;
  FKrakenServiceOnExecute := AKrakenServiceProc;
end;

function TKrakenService.OnExecute: iKrakenService;
begin
  Result := Self;
  FKrakenServiceOnExecute;
end;

function TKrakenService.OnStop(AKrakenServiceOnStop: TKrakenServiceEvent): iKrakenService;
begin
  Result := Self;
  FKrakenServiceOnStop := AKrakenServiceOnStop;
end;

function TKrakenService.OnStop: iKrakenService;
begin
  Result := Self;
  FKrakenServiceOnStop;
end;

function TKrakenService.OnPause(AKrakenServiceOnPause: TKrakenServiceEvent): iKrakenService;
begin
  Result := Self;
  FKrakenServiceOnPause := AKrakenServiceOnPause;
end;

function TKrakenService.OnPause: iKrakenService;
begin
  Result := Self;
  FKrakenServiceOnPause;
end;

function TKrakenService.OnContinue(AKrakenServiceOnContinue : TKrakenServiceEvent): iKrakenService;
begin
  Result := Self;
  FKrakenServiceOnContinue := AKrakenServiceOnContinue;
end;

function TKrakenService.OnContinue: iKrakenService;
begin
  Result := Self;
  FKrakenServiceOnContinue;
end;

function TKrakenService.OnDestroy(AKrakenServiceProc : TKrakenServiceEvent): iKrakenService;
begin
  Result := Self;
  FKrakenServiceOnDestroy := AKrakenServiceProc;
end;

function TKrakenService.OnDestroy: iKrakenService;
begin
  Result := Self;
  FKrakenServiceOnDestroy;
end;

function TKrakenService.Dependencies(ADependencies: TKrakenDependencies): iKrakenService;
begin
  Result := Self;
end;

function TKrakenService.Manager: TKrakenServiceManager;
begin
  Result := KrakenServiceManager;
end;

procedure TKrakenService.TryRunAsService;
begin
  if not KrakenServiceManager.TryRunAsService(FServiceName, FDisplayName) then
  begin
    Vcl.Forms.Application.Initialize;
    Vcl.Forms.Application.CreateForm(FGUIControl, FGUIRef);
    Vcl.Forms.Application.Run;
  end;
end;

procedure TKrakenService.Install;
begin
  KrakenServiceManager.Install;
end;

procedure TKrakenService.Uninstall;
begin
  KrakenServiceManager.Uninstall;
end;

end.
