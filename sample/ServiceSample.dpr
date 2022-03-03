program ServiceSample;

uses
  Vcl.Forms,
  Vcl.SvcMgr,
  ServiceGUI in 'ServiceGUI.pas' {frmServiceGUI},
  Kraken.Service.Contract in '..\Kraken.Service.Contract.pas',
  Kraken.Service in '..\Kraken.Service.pas',
  Kraken.Service.Instance in '..\Kraken.Service.Instance.pas',
  Kraken.Service.Manager in '..\Kraken.Service.Manager.pas';

{$R *.res}

begin
  KrakenService
    .StartType(stAuto)
    .ServiceName('eSync')
    .DisplayName('eSync')
    .ServiceDetail('Serviço de replicação de dados')
    .ExecuteInterval(5000)
    .OnStart(
      procedure
      begin
        WriteLog('OnStart funcionando');
      end
    )
    .OnExecute(
      procedure
      begin
        WriteLog('OnExecute funcionando');
      end
    )
    .OnPause(
      procedure
      begin
        WriteLog('OnPause funcionando');
      end
    )
    .OnContinue(
      procedure
      begin
        WriteLog('OnContinue funcionando');
      end
    )
    .OnStop(
      procedure
      begin
        WriteLog('OnStop funcionando');
      end
    )
    .OnDestroy(
      procedure
      begin
        WriteLog('OnDestroy funcionando');
      end
    )
    .GUI(TfrmServiceGUI, frmServiceGUI)
    .TryRunAsService;
end.
