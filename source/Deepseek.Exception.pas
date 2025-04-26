unit Deepseek.Exception;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiDeepseek
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, Deepseek.Errors;

type
  TDeepseekException = class(Exception)
  private
    FCode: Int64;
    FMessage: string;
    FType: string;
    FErrorCode: string;
    FParam: string;
  public
    constructor Create(const ACode: Int64; const AError: TErrorCore); reintroduce; overload;
    constructor Create(const ACode: Int64; const Value: string); reintroduce; overload;
    function ToMessageString: string;
    property Code: Int64 read FCode write FCode;
    property Message: string read FMessage write FMessage;
    property &Type: string read FType write FType;
    property ErrorCode: string read FErrorCode write FErrorCode;
    property Param: string read FParam write FParam;
  end;

  TDeepseekExceptionAPI = class(Exception);

  /// <summary>
  /// Invalid request body format.
  /// </summary>
  /// <remarks>
  /// Please modify your request body according to the hints in the error message. For more API format
  /// details, please refer to DeepSeek API Docs.
  /// </remarks>
  TDeepseekExceptionInvalidFormatError = class(TDeepseekException);

  /// <summary>
  /// Authentication fails due to the wrong API key.
  /// </summary>
  /// <remarks>
  /// Please check your API key. If you don't have one, please create an API key first.
  /// </remarks>
  TDeepseekExceptionAuthenticationFailsError = class(TDeepseekException);

  /// <summary>
  /// You have run out of balance.
  /// </summary>
  /// <remarks>
  /// Please check your account's balance, and go to the Top up page to add funds.
  /// </remarks>
  TDeepseekExceptionInsufficientBalanceError = class(TDeepseekException);

  /// <summary>
  /// Your request contains invalid parameters.
  /// </summary>
  /// <remarks>
  /// Please modify your request parameters according to the hints in the error message. For more API format
  /// details, please refer to DeepSeek API Docs.
  /// </remarks>
  TDeepseekExceptionInvalidParametersError = class(TDeepseekException);

  /// <summary>
  /// You are sending requests too quickly.
  /// </summary>
  /// <remarks>
  /// Please pace your requests reasonably. We also advise users to temporarily switch to the APIs of
  /// alternative LLM service providers, like OpenAI.
  /// </remarks>
  TDeepseekExceptionRateLimitReachedError = class(TDeepseekException);

  /// <summary>
  /// Our server encounters an issue.
  /// </summary>
  /// <remarks>
  /// Please retry your request after a brief wait and contact us if the issue persists.
  /// </remarks>
  TDeepseekExceptionServerError = class(TDeepseekException);

  /// <summary>
  /// The server is overloaded due to high traffic.
  /// </summary>
  /// <remarks>
  /// Please retry your request after a brief wait.
  /// </remarks>
  TDeepseekExceptionServerOverloadeError = class(TDeepseekException);

  TDeepseekExceptionInvalidResponse = class(TDeepseekException);

implementation

constructor TDeepseekException.Create(const ACode: Int64; const Value: string);
begin
  inherited Create(Format('error %d: %s', [ACode, Value]));
end;

function TDeepseekException.ToMessageString: string;
begin
  Result := Format('error(%d) - %s'#10'  %s', [Code, ErrorCode, Message]);
end;

constructor TDeepseekException.Create(const ACode: Int64; const AError: TErrorCore);
begin
  Code := ACode;
  Message := (AError as TError).Error.Message;
  &Type := (AError as TError).Error.&Type;
  Param := (AError as TError).Error.Param;
  ErrorCode := (AError as TError).Error.ErrorCode;
  inherited Create(ToMessageString);
end;

end.
