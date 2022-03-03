unit Kraken.Service.Instance;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.WinSvc,
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections,
  System.Win.Registry,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.SvcMgr;

type
  TKrakenThreadExecute = class(TThread)
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  class var
    FEvent: TEvent;
    FDefaultJob: TKrakenThreadExecute;
  protected
    procedure Execute; override;
  public
    class function DefaultJob: TKrakenThreadExecute;
    class destructor UnInitialize;
  end;

  TKrakenInstance = class(TService)
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceExecute(Sender: TService);
  protected
    constructor Create(AOwner: TComponent); override;
    function GetServiceController: TServiceController; override;

    procedure DoStart; override;
    function DoStop: Boolean; override;
    function DoPause: Boolean; override;
    function DoContinue: Boolean; override;
    procedure DoShutdown; override;
  end;

var
  KrakenInstance : TKrakenInstance;

implementation

uses
  Kraken.Service;

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  KrakenInstance.Controller(CtrlCode);
end;

{ TBinaryUpdaterJob }

procedure TKrakenThreadExecute.AfterConstruction;
begin
  inherited;
  FEvent := TEvent.Create;
end;

procedure TKrakenThreadExecute.BeforeDestruction;
begin
  inherited;
  FEvent.Free;
end;

procedure TKrakenThreadExecute.Execute;
var
  LWaitResult: TWaitResult;
  LCriticalSection: TCriticalSection;
begin
  inherited;

  LCriticalSection := TCriticalSection.Create;
  LCriticalSection.Enter;

  if not Self.Terminated  then
  begin
    try
      KrakenService.OnExecute;
    except

    end;
  end;

  while not Self.Terminated do
  begin
    LWaitResult := FEvent.WaitFor( KrakenService.ExecuteInterval );

    if LWaitResult <> TWaitResult.wrTimeout then
      Break;
    try
      KrakenService.OnExecute;
    except
      Continue;
    end;
  end;

  LCriticalSection.Leave;
  LCriticalSection.Free;
end;

class function TKrakenThreadExecute.DefaultJob: TKrakenThreadExecute;
begin
  if FDefaultJob = nil then
  begin
    FDefaultJob := TKrakenThreadExecute.Create(True);
    FDefaultJob.FreeOnTerminate := False;
  end;

  Result := FDefaultJob;
end;

class destructor TKrakenThreadExecute.UnInitialize;
begin
  if Assigned(FDefaultJob) then
  begin
    if not FDefaultJob.Terminated then
    begin
      FDefaultJob.Terminate;
      FEvent.SetEvent;
      FDefaultJob.WaitFor;
    end;

    FreeAndNil(FDefaultJob);
  end;
end;

{ TKrakenInstance }

constructor TKrakenInstance.Create(AOwner: TComponent);
begin
  inherited;

  Self.Name        := KrakenService.ServiceName;
  Self.DisplayName := KrakenService.DisplayName;
  Self.StartType   := KrakenService.StartType;
end;

function TKrakenInstance.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TKrakenInstance.ServiceAfterInstall(Sender: TService);
var
  reg : TRegIniFile;
begin
  if KrakenService.ServiceDetail = '' then
    Exit;

  Reg := TRegIniFile.Create(KEY_ALL_ACCESS);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;

    if Reg.OpenKey('\SYSTEM\CurrentControlSet\Services\Eventlog\Application\' + Name, True) then
    begin
      TRegistry(Reg).WriteString('EventMessageFile', ParamStr(0));
      TRegistry(Reg).WriteInteger('TypesSupported', 7);
      TRegistry(Reg).WriteString('Description', KrakenService.ServiceDetail);
    end;

    if Reg.OpenKey('\SYSTEM\CurrentControlSet\Services\' + Name, True) then
    begin
      if FindCmdLineSwitch('NOVALIDATE', ['-', '/'], True) then
        TRegistry(Reg).WriteString('ImagePath', GetModuleName(HInstance) + ' -NOVALIDATE')
      Else
        TRegistry(Reg).WriteString('ImagePath', GetModuleName(HInstance) +  ' -RunService' );
    end;

  finally
    Reg.Free;
  end;
end;

procedure TKrakenInstance.ServiceExecute(Sender: TService);
begin
  while not Self.Terminated do
    ServiceThread.ProcessRequests(true);
end;

function TKrakenInstance.DoContinue: Boolean;
begin
  if not TKrakenThreadExecute.DefaultJob.Started then
    TKrakenThreadExecute.DefaultJob.Start;

  inherited;
end;

function TKrakenInstance.DoPause: Boolean;
begin
  if not TKrakenThreadExecute.DefaultJob.Terminated then
    TKrakenThreadExecute.DefaultJob.Terminate;

  KrakenService.OnPause;
  inherited;
end;

procedure TKrakenInstance.DoShutdown;
begin
  if not TKrakenThreadExecute.DefaultJob.Terminated then
    TKrakenThreadExecute.DefaultJob.Terminate;

  KrakenService.OnDestroy;
  inherited;
end;

procedure TKrakenInstance.DoStart;
begin
  KrakenService.OnStart;

  if not TKrakenThreadExecute.DefaultJob.Started then
    TKrakenThreadExecute.DefaultJob.Start;
  inherited;
end;

function TKrakenInstance.DoStop: Boolean;
begin
  if not TKrakenThreadExecute.DefaultJob.Terminated then
    TKrakenThreadExecute.DefaultJob.Terminate;

  KrakenService.OnStop;
  inherited;
end;

end.
