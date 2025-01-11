unit Deepseek.Errors;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiDeepseek
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  REST.Json.Types;

type
  TErrorCore = class abstract
  end;

  TErrorDatail = class
  private
    FMessage: string;
    FType: string;
    FParam: string;
    [JsonNameAttribute('code')]
    FErrorCode: string;
  public
    property Message: string read FMessage write FMessage;
    property &Type: string read FType write FType;
    property Param: string read FParam write FParam;
    property ErrorCode: string read FErrorCode write FErrorCode;
  end;

  TError = class(TErrorCore)
  private
    FError: TErrorDatail;
  public
    property Error: TErrorDatail read FError write FError;
    destructor Destroy; override;
  end;

implementation


{ TError }

destructor TError.Destroy;
begin
  if Assigned(FError) then
    FError.Free;
  inherited;
end;

end.
