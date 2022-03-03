unit Kraken.Service.Contract;

interface

uses
  Vcl.SvcMgr,
  System.Classes,
  System.Generics.Collections,
  Kraken.Service.Manager;

type
  TService            = Vcl.SvcMgr.TService;
  TKrakenDependencies = TDictionary<string, string>;

  TKrakenServiceEvent = reference to procedure;

  iKrakenService = interface
    ['{99A0BFAF-2B2D-4132-82E3-7CC2447DD316}']
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

implementation

end.
