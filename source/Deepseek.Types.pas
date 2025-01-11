unit Deepseek.Types;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiDeepseek
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, Deepseek.API.Params;

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

  /// <summary>
  /// Helper record for the <c>TMessageRole</c> enumeration, providing utility methods for converting
  /// between <c>TMessageRole</c> values and their string representations.
  /// </summary>
  TMessageRoleHelper = record helper for TMessageRole
    /// <summary>
    /// Converts the current <c>TMessageRole</c> value to its corresponding string representation.
    /// </summary>
    /// <returns>
    /// A string representing the current <c>TMessageRole</c> value.
    /// </returns>
    function ToString: string;
    /// <summary>
    /// Converts a string representation of a <c>TMessageRole</c> into its corresponding enumeration value.
    /// </summary>
    /// <param name="Value">
    /// The string representing a <c>TMessageRole</c>.
    /// </param>
    /// <returns>
    /// The <c>TMessageRole</c> enumeration value that corresponds to the provided string.
    /// </returns>
    class function Create(const Value: string): TMessageRole; static;
  end;

  /// <summary>
  /// Interceptor class for converting <c>TMessageRole</c> values to and from their string representations in JSON serialization and deserialization.
  /// </summary>
  /// <remarks>
  /// This class is used to facilitate the conversion between the <c>TMessageRole</c> enum and its string equivalents during JSON processing.
  /// It extends the <c>TJSONInterceptorStringToString</c> class to override the necessary methods for custom conversion logic.
  /// </remarks>
  TMessageRoleInterceptor = class(TJSONInterceptorStringToString)
  public
    /// <summary>
    /// Converts the <c>TMessageRole</c> value of the specified field to a string during JSON serialization.
    /// </summary>
    /// <param name="Data">
    /// The object containing the field to be converted.
    /// </param>
    /// <param name="Field">
    /// The field name representing the <c>TMessageRole</c> value.
    /// </param>
    /// <returns>
    /// The string representation of the <c>TMessageRole</c> value.
    /// </returns>
    function StringConverter(Data: TObject; Field: string): string; override;
    /// <summary>
    /// Converts a string back to a <c>TMessageRole</c> value for the specified field during JSON deserialization.
    /// </summary>
    /// <param name="Data">
    /// The object containing the field to be set.
    /// </param>
    /// <param name="Field">
    /// The field name where the <c>TMessageRole</c> value will be set.
    /// </param>
    /// <param name="Arg">
    /// The string representation of the <c>TMessageRole</c> to be converted back.
    /// </param>
    /// <remarks>
    /// This method converts the string argument back to the corresponding <c>TMessageRole</c> value and assigns it to the specified field in the object.
    /// </remarks>
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

  /// <summary>
  /// Helper record for the <c>TFinishReason</c> enumeration, providing utility methods for conversion between string representations and <c>TFinishReason</c> values.
  /// </summary>
  TFinishReasonHelper = record helper for TFinishReason
    /// <summary>
    /// Converts the current <c>TFinishReason</c> value to its string representation.
    /// </summary>
    /// <returns>
    /// A string representing the current <c>TFinishReason</c> value.
    /// </returns>
    function ToString: string;
    /// <summary>
    /// Creates a <c>TFinishReason</c> value from its corresponding string representation.
    /// </summary>
    /// <param name="Value">
    /// The string value representing a <c>TFinishReason</c>.
    /// </param>
    /// <returns>
    /// The corresponding <c>TFinishReason</c> enumeration value for the provided string.
    /// </returns>
    /// <remarks>
    /// This method throws an exception if the input string does not match any valid <c>TFinishReason</c> values.
    /// </remarks>
    class function Create(const Value: string): TFinishReason; static;
  end;

  /// <summary>
  /// Interceptor class for converting <c>TFinishReason</c> values to and from their string representations in JSON serialization and deserialization.
  /// </summary>
  /// <remarks>
  /// This class is used to facilitate the conversion between the <c>TFinishReason</c> enum and its string equivalents during JSON processing.
  /// It extends the <c>TJSONInterceptorStringToString</c> class to override the necessary methods for custom conversion logic.
  /// </remarks>
  TFinishReasonInterceptor = class(TJSONInterceptorStringToString)
  public
    /// <summary>
    /// Converts the <c>TFinishReason</c> value of the specified field to a string during JSON serialization.
    /// </summary>
    /// <param name="Data">
    /// The object containing the field to be converted.
    /// </param>
    /// <param name="Field">
    /// The field name representing the <c>TFinishReason</c> value.
    /// </param>
    /// <returns>
    /// The string representation of the <c>TFinishReason</c> value.
    /// </returns>
    function StringConverter(Data: TObject; Field: string): string; override;
    /// <summary>
    /// Converts a string back to a <c>TFinishReason</c> value for the specified field during JSON deserialization.
    /// </summary>
    /// <param name="Data">
    /// The object containing the field to be set.
    /// </param>
    /// <param name="Field">
    /// The field name where the <c>TFinishReason</c> value will be set.
    /// </param>
    /// <param name="Arg">
    /// The string representation of the <c>TFinishReason</c> to be converted back.
    /// </param>
    /// <remarks>
    /// This method converts the string argument back to the corresponding <c>TFinishReason</c> value and assigns it to the specified field in the object.
    /// </remarks>
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

  /// <summary>
  /// Helper record for the <c>TToolChoice</c> enumeration, providing utility methods for conversion between string representations and <c>TFinishReason</c> values.
  /// </summary>
  TToolChoiceHelper = record helper for TToolChoice
    /// <summary>
    /// Converts the current <c>TToolChoice</c> value to its string representation.
    /// </summary>
    /// <returns>
    /// A string representing the current <c>TToolChoice</c> value.
    /// </returns>
    function ToString: string;
  end;

  TResponseFormat = (
    text,
    json_object
  );

  /// <summary>
  /// Helper record for the <c>TResponseFormat</c> enumeration, providing utility methods for conversion between string representations and <c>TFinishReason</c> values.
  /// </summary>
  TResponseFormatHelper = record helper for TResponseFormat
    /// <summary>
    /// Converts the current <c>TResponseFormat</c> value to its string representation.
    /// </summary>
    /// <returns>
    /// A string representing the current <c>TResponseFormat</c> value.
    /// </returns>
    function ToString: string;
  end;

  /// <summary>
  /// Represents the type of the content: text or image_url
  /// </summary>
  TContentType = (
    /// <summary>
    /// The content is a text
    /// </summary>
    ct_text,
    /// <summary>
    /// The content is an url or a base-64 text
    /// </summary>
    image_url
  );

  /// <summary>
  /// Helper record for the <c>TContentType</c> enumeration, providing utility methods for conversion between string representations and <c>TContentType</c> values.
  /// </summary>
  TContentTypeHelper = record Helper for TContentType
    /// <summary>
    /// Converts the current <c>TFinishReason</c> value to its string representation.
    /// </summary>
    /// <returns>
    /// A string representing the current <c>TFinishReason</c> value.
    /// </returns>
    function ToString: string;
  end;

{$ENDREGION}

implementation

uses
  System.StrUtils, System.Rtti, Rest.Json;

{ TMessageRoleHelper }

class function TMessageRoleHelper.Create(const Value: string): TMessageRole;
begin
  var index := IndexStr(AnsiLowerCase(Value), ['user', 'assistant', 'system']);
  if index = -1 then
    raise Exception.Create('Invalid message role value.');
  Result := TMessageRole(index);
end;

function TMessageRoleHelper.ToString: string;
begin
  case Self of
    user:
      Exit('user');
    assistant:
      Exit('assistant');
    system:
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

class function TFinishReasonHelper.Create(const Value: string): TFinishReason;
begin
  var index := IndexStr(AnsiLowerCase(Value), [
    'stop', 'length', 'content_filter', 'tool_calls', 'insufficient_system_resource'
  ]);
  if index = -1 then
    raise Exception.Create('Invalid finish reason value.');
  Result := TFinishReason(index);
end;

function TFinishReasonHelper.ToString: string;
begin
  case Self of
    stop:
      Exit('stop');
    length:
      Exit('length');
    content_filter:
      Exit('content_filter');
    tool_calls:
      Exit('tool_calls');
    insufficient_system_resource:
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

function TToolChoiceHelper.ToString: string;
begin
  case Self of
    none:
      Exit('none');
    auto:
      Exit('auto');
    required:
      Exit('required');
  end;
end;

{ TResponseFormatHelper }

function TResponseFormatHelper.ToString: string;
begin
  case Self of
    text:
      Exit('text');
    json_object:
      Exit('json_object');
  end;
end;

{ TContentTypeHelper }

function TContentTypeHelper.ToString: string;
begin
  case Self of
    ct_text:
      Exit('text');
    image_url:
      Exit('image_url');
  end;
end;

end.
