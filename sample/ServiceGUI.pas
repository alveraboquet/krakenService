unit ServiceGUI;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Kraken.Service,
  Kraken.Service.Contract;

type
  TfrmServiceGUI = class(TForm)
    btnInstall: TButton;
    btnUninstall: TButton;
    btnStart: TButton;
    btnStop: TButton;
    procedure btnInstallClick(Sender: TObject);
    procedure btnUninstallClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmServiceGUI: TfrmServiceGUI;

implementation

{$R *.dfm}

procedure TfrmServiceGUI.btnInstallClick(Sender: TObject);
begin
  KrakenService.Install;
  KrakenService.Manager.StartService;
end;

procedure TfrmServiceGUI.btnStartClick(Sender: TObject);
begin
  KrakenService.Manager.StartService;
end;

procedure TfrmServiceGUI.btnStopClick(Sender: TObject);
begin
  KrakenService.Manager.StopService;
end;

procedure TfrmServiceGUI.btnUninstallClick(Sender: TObject);
begin
  KrakenService.Uninstall;
end;

end.
