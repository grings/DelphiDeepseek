unit Deepseek.API;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiDeepseek
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.Classes, System.Net.HttpClient, System.Net.URLClient, System.Net.Mime,
  System.JSON, Deepseek.Errors, Deepseek.API.Params, System.SysUtils;

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

  TDeepseekAPI = class
  public
    const
      URL_BASE = 'https://api.deepseek.com';
  private
    FToken: string;
    FBaseUrl: string;
    FCustomHeaders: TNetHeaders;

    procedure SetToken(const Value: string);
    procedure SetBaseUrl(const Value: string);
    procedure RaiseError(Code: Int64; Error: TErrorCore);
    procedure ParseError(const Code: Int64; const ResponseText: string);
    procedure SetCustomHeaders(const Value: TNetHeaders);

  protected
    function GetHeaders: TNetHeaders; virtual;
    function GetClient: THTTPClient; virtual;
    function GetRequestURL(const Path: string): string;
    function Get(const Path: string; Response: TStringStream): Integer; overload;
    function Delete(const Path: string; Response: TStringStream): Integer; overload;
    function Post(const Path: string; Response: TStringStream): Integer; overload;
    function Post(const Path: string; Body: TJSONObject; Response: TStringStream; OnReceiveData: TReceiveDataCallback = nil): Integer; overload;
    function Post(const Path: string; Body: TMultipartFormData; Response: TStringStream; var ResponseHeader: TNetHeaders): Integer; overload;
    function ParseResponse<T: class, constructor>(const Code: Int64; const ResponseText: string): T; overload;
    procedure CheckAPI;
  public
    function GetArray<TResult: class, constructor>(const Path: string): TResult;
    function Get<TResult: class, constructor>(const Path: string): TResult; overload;
    function Get<TResult: class, constructor; TParams: TJSONParam>(const Path: string; ParamProc: TProc<TParams>): TResult; overload;
    procedure GetFile(const Path: string; Response: TStream); overload;
    function Delete<TResult: class, constructor>(const Path: string): TResult; overload;
    function Post<TParams: TJSONParam>(const Path: string; ParamProc: TProc<TParams>; Response: TStringStream; Event: TReceiveDataCallback = nil): Boolean; overload;
    function Post<TResult: class, constructor; TParams: TJSONParam>(const Path: string; ParamProc: TProc<TParams>): TResult; overload;
    function Post<TResult: class, constructor>(const Path: string): TResult; overload;
    function PostForm<TResult: class, constructor; TParams: TMultipartFormData, constructor>(const Path: string; ParamProc: TProc<TParams>): TResult; overload;
    function PostForm<TResult: class, constructor; TParams: TMultipartFormData, constructor>(const Path: string; ParamProc: TProc<TParams>;
      var ResponseHeader: TNetHeaders): TResult; overload;
  public
    constructor Create; overload;
    constructor Create(const AToken: string); overload;
    destructor Destroy; override;
    property Token: string read FToken write SetToken;
    property BaseUrl: string read FBaseUrl write SetBaseUrl;
    property CustomHeaders: TNetHeaders read FCustomHeaders write SetCustomHeaders;
  end;

  TDeepseekAPIRoute = class
  private
    FAPI: TDeepseekAPI;
    procedure SetAPI(const Value: TDeepseekAPI);
  public
    property API: TDeepseekAPI read FAPI write SetAPI;
    constructor CreateRoute(AAPI: TDeepseekAPI); reintroduce;
  end;

implementation

uses
  System.StrUtils, REST.Json, System.NetConsts;

constructor TDeepseekAPI.Create;
begin
  inherited;
  FToken := '';
  FBaseUrl := URL_BASE;
end;

constructor TDeepseekAPI.Create(const AToken: string);
begin
  Create;
  Token := AToken;
end;

destructor TDeepseekAPI.Destroy;
begin
  inherited;
end;

function TDeepseekAPI.Post(const Path: string; Body: TJSONObject; Response: TStringStream; OnReceiveData: TReceiveDataCallback): Integer;
var
  Headers: TNetHeaders;
  Stream: TStringStream;
  Client: THTTPClient;
begin
  CheckAPI;
  Client := GetClient;
  try
    Headers := GetHeaders + [TNetHeader.Create('Content-Type', 'application/json')];
    Stream := TStringStream.Create;
    Client.ReceiveDataCallBack := OnReceiveData;
    try
      Stream.WriteString(Body.ToJSON);
      Stream.Position := 0;
      Result := Client.Post(GetRequestURL(Path), Stream, Response, Headers).StatusCode;
    finally
      Client.ReceiveDataCallBack := nil;
      Stream.Free;
    end;
  finally
    Client.Free;
  end;
end;

function TDeepseekAPI.Get(const Path: string;
  Response: TStringStream): Integer;
var
  Client: THTTPClient;
  Headers: TNetHeaders;
begin
  CheckAPI;
  Client := GetClient;
  try
    Headers := GetHeaders;
    Result := Client.Get(GetRequestURL(Path), Response, Headers).StatusCode;
  finally
    Client.Free;
  end;
end;

function TDeepseekAPI.Post(const Path: string; Body: TMultipartFormData; Response: TStringStream;
  var ResponseHeader: TNetHeaders): Integer;
var
  Client: THTTPClient;
begin
  CheckAPI;
  Client := GetClient;
  try
    var PostResult := Client.Post(GetRequestURL(Path), Body, Response, GetHeaders);
    ResponseHeader := PostResult.Headers;
    Result := PostResult.StatusCode;
  finally
    Client.Free;
  end;
end;

function TDeepseekAPI.Post(const Path: string; Response: TStringStream): Integer;
var
  Client: THTTPClient;
begin
  CheckAPI;
  Client := GetClient;
  try
    Result := Client.Post(GetRequestURL(Path), TStream(nil), Response, GetHeaders).StatusCode;
  finally
    Client.Free;
  end;
end;

function TDeepseekAPI.Post<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>): TResult;
var
  Response: TStringStream;
  Params: TParams;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    Code := Post(Path, Params.JSON, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString)
  finally
    Params.Free;
    Response.Free;
  end;
end;

function TDeepseekAPI.Post<TParams>(const Path: string; ParamProc: TProc<TParams>; Response: TStringStream; Event: TReceiveDataCallback): Boolean;
var
  Params: TParams;
  Code: Integer;
begin
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    Code := Post(Path, Params.JSON, Response, Event);
    case Code of
      200..299:
        Result := True;
    else
      Result := False;
    end;
  finally
    Params.Free;
  end;
end;

function TDeepseekAPI.Post<TResult>(const Path: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Post(Path, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Response.Free;
  end;
end;

function TDeepseekAPI.Delete(const Path: string; Response: TStringStream): Integer;
var
  Client: THTTPClient;
begin
  CheckAPI;
  Client := GetClient;
  try
    Result := Client.Delete(GetRequestURL(Path), Response, GetHeaders).StatusCode;
  finally
    Client.Free;
  end;
end;

function TDeepseekAPI.Delete<TResult>(const Path: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Delete(Path, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Response.Free;
  end;
end;

function TDeepseekAPI.PostForm<TResult, TParams>(const Path: string;
  ParamProc: TProc<TParams>; var ResponseHeader: TNetHeaders): TResult;
begin
  var Response := TStringStream.Create('', TEncoding.UTF8);
  var Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    var Code := Post(Path, Params, Response, ResponseHeader);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Params.Free;
    Response.Free;
  end;
end;

function TDeepseekAPI.PostForm<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>): TResult;
var
  ResponseHeader: TNetHeaders;
begin
  Result := PostForm<TResult, TParams>(Path, ParamProc, ResponseHeader);
end;

function TDeepseekAPI.Get<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>): TResult;
var
  Response: TStringStream;
  Params: TParams;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    var Pairs: TArray<string> := [];
    for var Pair in Params.ToStringPairs do
      Pairs := Pairs + [Pair.Key + '=' + Pair.Value];
    var QPath := Path;
    if Length(Pairs) > 0 then
      QPath := QPath + '?' + string.Join('&', Pairs);
    Code := Get(QPath, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Params.Free;
    Response.Free;
  end;
end;

function TDeepseekAPI.Get<TResult>(const Path: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  CustomHeaders := [TNetHeader.Create('accept', 'application/json')];
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Get(Path, Response);

    with TStringList.Create do
    try
      Text := Response.DataString;
      SaveToFile('Response.JSON', TEncoding.UTF8);
    finally
      Free;
    end;

    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Response.Free;
  end;
end;

function TDeepseekAPI.GetArray<TResult>(const Path: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  CustomHeaders := [TNetHeader.Create('accept', 'application/json')];
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Get(Path, Response);
    var Data := Response.DataString.Trim([#10]);
    if Data.StartsWith('[') then
      Data := Format('{"result":%s}', [Data]);
    Result := ParseResponse<TResult>(Code, Data);
  finally
    Response.Free;
  end;
end;

function TDeepseekAPI.GetClient: THTTPClient;
begin
  Result := THTTPClient.Create;
  Result.AcceptCharSet := 'utf-8';
end;

procedure TDeepseekAPI.GetFile(const Path: string; Response: TStream);
var
  Code: Integer;
  Strings: TStringStream;
  Client: THTTPClient;
begin
  CheckAPI;
  Client := GetClient;
  try
    Code := Client.Get(GetRequestURL(Path), Response, GetHeaders).StatusCode;
    case Code of
      200..299:
        ; {success}
    else
      Strings := TStringStream.Create;
      try
        Response.Position := 0;
        Strings.LoadFromStream(Response);
        ParseError(Code, Strings.DataString);
      finally
        Strings.Free;
      end;
    end;
  finally
    Client.Free;
  end;
end;

function TDeepseekAPI.GetHeaders: TNetHeaders;
begin
  Result :=
    [TNetHeader.Create('authorization', 'Bearer ' + FToken)] +
    FCustomHeaders;
end;

function TDeepseekAPI.GetRequestURL(const Path: string): string;
begin
  Result := Format('%s/%s', [FBaseURL, Path]);
end;

procedure TDeepseekAPI.CheckAPI;
begin
  if FToken.IsEmpty then
    raise TDeepseekExceptionAPI.Create('Token is empty!');
  if FBaseUrl.IsEmpty then
    raise TDeepseekExceptionAPI.Create('Base url is empty!');
end;

procedure TDeepseekAPI.RaiseError(Code: Int64; Error: TErrorCore);
begin
  case Code of
    {--- Client Error Codes }
    400:
      raise TDeepseekExceptionInvalidFormatError.Create(Code, Error);
    401:
      raise TDeepseekExceptionAuthenticationFailsError.Create(Code, Error);
    402:
      raise TDeepseekExceptionInsufficientBalanceError.Create(Code, Error);
    422:
      raise TDeepseekExceptionInvalidParametersError.Create(Code, Error);
    429:
      raise TDeepseekExceptionRateLimitReachedError.Create(Code, Error);
    {--- Server Error Codes }
    500:
      raise TDeepseekExceptionServerError.Create(Code, Error);
    503:
      raise TDeepseekExceptionServerOverloadeError.Create(Code, Error);
  else
    raise TDeepseekException.Create(Code, Error);
  end;
end;

procedure TDeepseekAPI.ParseError(const Code: Int64; const ResponseText: string);
var
  Error: TErrorCore;
begin
  Error := nil;
  try
    try
      Error := TJson.JsonToObject<TError>(ResponseText);
    except
      Error := nil;
    end;
    if Assigned(Error) and Assigned(Error) then
      RaiseError(Code, Error)
  finally
    if Assigned(Error) then
      Error.Free;
  end;
end;

function TDeepseekAPI.ParseResponse<T>(const Code: Int64; const ResponseText: string): T;
begin
  Result := nil;
  case Code of
    200..299:
      try
        Result := TJson.JsonToObject<T>(ResponseText)
      except
        FreeAndNil(Result);
      end;
  else
    ParseError(Code, ResponseText);
  end;
  if not Assigned(Result) then
    raise TDeepseekExceptionInvalidResponse.Create(Code, 'Empty or invalid response');
end;

procedure TDeepseekAPI.SetBaseUrl(const Value: string);
begin
  FBaseUrl := Value;
end;

procedure TDeepseekAPI.SetCustomHeaders(const Value: TNetHeaders);
begin
  FCustomHeaders := Value;
end;

procedure TDeepseekAPI.SetToken(const Value: string);
begin
  FToken := Value;
end;

{ TDeepseekAPIRoute }

constructor TDeepseekAPIRoute.CreateRoute(AAPI: TDeepseekAPI);
begin
  inherited Create;
  FAPI := AAPI;
end;

procedure TDeepseekAPIRoute.SetAPI(const Value: TDeepseekAPI);
begin
  FAPI := Value;
end;

{ TDeepseekException }

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

