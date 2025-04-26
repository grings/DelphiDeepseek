unit Deepseek.Types;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiDeepseek
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, Deepseek.API.Params;

{$SCOPEDENUMS ON}

type

{$REGION 'Deepseek.Chat'}

  /// <summary>
  /// Type of message role
  /// </summary>
  TMessageRole = (
    /// <summary>
    /// User role for the message
    /// </summary>
    user,
    /// <summary>
    /// Assistant role for the message
    /// </summary>
    assistant,
    /// <summary>
    /// System role for the message
    /// </summary>
    system);

  TMessageRoleHelper = record helper for TMessageRole
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TMessageRoleInterceptor = class(TJSONInterceptorStringToString)
  public
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  /// <summary>
  /// Represents the different reasons why the processing of a request can terminate.
  /// </summary>
  TFinishReason = (
    /// <summary>
    /// The model hit a natural stop point or a provided stop sequence.
    /// </summary>
    stop,
    /// <summary>
    /// The maximum number of tokens specified in the request was reached.
    /// </summary>
    length,
    /// <summary>
    /// The content was omitted due to a flag from our content filters.
    /// </summary>
    content_filter,
    /// <summary>
    /// The model called a tool.
    /// </summary>
    tool_calls,
    /// <summary>
    /// The request is interrupted due to insufficient resource of the inference system.
    /// </summary>
    insufficient_system_resource
    );

  TFinishReasonHelper = record helper for TFinishReason
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TFinishReasonInterceptor = class(TJSONInterceptorStringToString)
  public
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  /// <summary>
  /// Indicator to specify how to use tools.
  /// </summary>
  /// <remarks>
  /// <para>
  /// <c>none</c> is the default when no tools are present.
  /// </para>
  /// <para>
  /// <c>auto</c> is the default if tools are present.
  /// </para>
  /// </remarks>
  TToolChoice = (
    /// <summary>
    /// The model will not call any tool and instead generates a message.
    /// </summary>
    none,
    /// <summary>
    /// The model can pick between generating a message or calling one or more tools.
    /// </summary>
    auto,
    /// <summary>
    /// The model must call one or more tools.
    /// </summary>
    required
  );

  TToolChoiceHelper = record helper for TToolChoice
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TResponseFormat = (
    text,
    json_object
  );

  TResponseFormatHelper = record helper for TResponseFormat
    constructor Create(const Value: string);
    function ToString: string;
  end;

{$ENDREGION}

implementation

uses
  System.StrUtils, System.Rtti, System.TypInfo, Rest.Json;

type
  TEnumValueRecovery = class
    class function TypeRetrieve<T>(const Value: string; const References: TArray<string>): T;
  end;

{ TMessageRoleHelper }

constructor TMessageRoleHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TMessageRole>(Value,
            ['user', 'assistant', 'system']);
end;

function TMessageRoleHelper.ToString: string;
begin
  case Self of
    TMessageRole.user:
      Exit('user');
    TMessageRole.assistant:
      Exit('assistant');
    TMessageRole.system:
      Exit('system');
  end;
end;

{ TMessageRoleInterceptor }

function TMessageRoleInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TMessageRole>.ToString;
end;

procedure TMessageRoleInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TMessageRole.Create(Arg)));
end;

{ TFinishReasonHelper }

constructor TFinishReasonHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TFinishReason>(Value,
            ['stop', 'length', 'content_filter', 'tool_calls', 'insufficient_system_resource']);
end;

function TFinishReasonHelper.ToString: string;
begin
  case Self of
    TFinishReason.stop:
      Exit('stop');
    TFinishReason.length:
      Exit('length');
    TFinishReason.content_filter:
      Exit('content_filter');
    TFinishReason.tool_calls:
      Exit('tool_calls');
    TFinishReason.insufficient_system_resource:
      Exit('insufficient_system_resource');
  end;
end;

{ TFinishReasonInterceptor }

function TFinishReasonInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TFinishReason>.ToString;
end;

procedure TFinishReasonInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TFinishReason.Create(Arg)));
end;

{ TToolChoiceHelper }

constructor TToolChoiceHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TToolChoice>(Value,
            ['none', 'auto', 'required']);
end;

function TToolChoiceHelper.ToString: string;
begin
  case Self of
    TToolChoice.none:
      Exit('none');
    TToolChoice.auto:
      Exit('auto');
    TToolChoice.required:
      Exit('required');
  end;
end;

{ TResponseFormatHelper }

constructor TResponseFormatHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TResponseFormat>(Value,
            ['text', 'json_object']);
end;

function TResponseFormatHelper.ToString: string;
begin
  case Self of
    TResponseFormat.text:
      Exit('text');
    TResponseFormat.json_object:
      Exit('json_object');
  end;
end;

{ TEnumValueRecovery }

class function TEnumValueRecovery.TypeRetrieve<T>(const Value: string;
  const References: TArray<string>): T;
var
  pInfo: PTypeInfo;
begin
  pInfo := TypeInfo(T);
  if pInfo.Kind <> tkEnumeration then
    raise Exception.Create('TRecovery.TypeRetrieve<T>: T is not an enumerated type');

  var index := IndexStr(Value.ToLower, References);
  if index = -1 then
    raise Exception.CreateFmt('%s : Unable to retrieve enum value.', [Value]);

  Move(index, Result, SizeOf(Result));
end;

end.
