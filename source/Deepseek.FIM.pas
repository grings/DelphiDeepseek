unit Deepseek.FIM;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiDeepseek
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, REST.JsonReflect, System.JSON, System.Threading,
  REST.Json.Types, Deepseek.API.Params, Deepseek.API, Deepseek.Types,
  Deepseek.Async.Params, Deepseek.Async.Support, Deepseek.Chat;

type
  /// <summary>
  /// Represents a parameter configuration class for the "FIM" model.
  /// </summary>
  /// <remarks>
  /// The <c>TFIMParams</c> class provides methods to set various parameters used for configuring
  /// and customizing requests to the "FIM" (Fill-In-the-Middle) AI model. This includes options
  /// such as the model identifier, prompt text, token limits, penalties, and other advanced settings.
  /// The methods in this class are chainable, allowing for streamlined parameter configuration.
  /// </remarks>
  TFIMParams = class(TJSONParam)
  public
    /// <summary>
    /// Specifies the identifier of the model to use.
    /// </summary>
    /// <param name="Value">
    /// The model ID to be used for the completion.
    /// Ensure that the specified model is supported and correctly spelled.
    /// </param>
    /// <returns>
    /// The updated <c>TFIMParams</c> instance.
    /// </returns>
    /// <remarks>
    /// This parameter is required and determines which model will process the request.
    /// </remarks>
    function Model(const Value: string): TFIMParams;
    /// <summary>
    /// The prompt to generate completions for.
    /// </summary>
    /// <param name="Value">
    /// string prompt
    /// </param>
    /// <returns>
    /// The updated <c>TFIMParams</c> instance.
    /// </returns>
    /// <remarks>
    /// This parameter is required and determines which model will process the request.
    /// </remarks>
    function Prompt(const Value: string): TFIMParams;
    /// <summary>
    /// Echo back the prompt in addition to the completion.
    /// </summary>
    /// <param name="Value">
    /// True calue to activate echo.
    /// </param>
    /// <returns>
    /// The updated <c>TFIMParams</c> instance.
    /// </returns>
    /// <remarks>
    /// This parameter is required and determines which model will process the request.
    /// </remarks>
    function Echo(const Value: Boolean): TFIMParams;
    /// <summary>
    /// Frequency_penalty penalizes the repetition of words based on their frequency in the generated text.
    /// </summary>
    /// <param name="Value">
    /// number (Presence Penalty) [ -2 .. 2 ]; Default: 0
    /// </param>
    /// <returns>
    /// The updated <c>TFIMParams</c> instance.
    /// </returns>
    /// <remarks>
    /// A higher frequency penalty discourages the model from repeating words that have already appeared
    /// frequently in the output, promoting diversity and reducing repetition.
    /// </remarks>
    function FrequencyPenalty(const Value: Double): TFIMParams;
    /// <summary>
    /// Whether to return log probabilities of the output tokens or not. If true, returns the log probabilities of each output token returned in the content of message.
    /// </summary>
    /// <param name="Value">
    /// Possible values: <= 20
    /// </param>
    /// <returns>
    /// The updated <c>TFIMParams</c> instance.
    /// </returns>
    function Logprobs(const Value: Integer): TFIMParams;
    /// <summary>
    /// Sets the maximum number of tokens to generate in the completion.
    /// The total token count of your prompt plus <c>max_tokens</c> cannot exceed the model's context length.
    /// </summary>
    /// <param name="Value">
    /// The maximum number of tokens to generate.
    /// Choose an appropriate value based on your prompt length to avoid exceeding the model's limit.
    /// </param>
    /// <returns>
    /// The updated <c>TFIMParams</c> instance.
    /// </returns>
    function MaxTokens(const Value: Integer): TFIMParams;
    /// <summary>
    /// Presence_penalty determines how much the model penalizes the repetition of words or phrases
    /// </summary>
    /// <param name="Value">
    /// number (Presence Penalty) [ -2 .. 2 ]; Default: 0
    /// </param>
    /// <returns>
    /// The updated <c>TFIMParams</c> instance.
    /// </returns>
    /// <remarks>
    /// A higher presence penalty encourages the model to use a wider variety of words and phrases,
    /// making the output more diverse and creative.
    /// </remarks>
    function PresencePenalty(const Value: Double): TFIMParams;
    /// <summary>
    /// Stop (string)
    /// Stop generation if this token is detected. Or if one of these tokens is detected when providing an array
    /// </summary>
    /// <param name="Value">
    /// The string that causes the stop
    /// </param>
    /// <returns>
    /// The updated <c>TFIMParams</c> instance.
    /// </returns>
    function Stop(const Value: string): TFIMParams; overload;
    /// <summary>
    /// Stop Array of Stop (strings) (Stop)
    /// Stop generation if this token is detected. Or if one of these tokens is detected when providing an array
    /// </summary>
    /// <param name="Value">
    /// The array of string that causes the stop
    /// </param>
    /// <returns>
    /// The updated <c>TFIMParams</c> instance.
    /// </returns>
    function Stop(const Value: TArray<string>): TFIMParams; overload;
    /// <summary>
    /// Specifies whether to stream back partial progress as server-sent events (SSE).
    /// If <c>true</c>, tokens are sent as they become available.
    /// If <c>false</c>, the server will hold the request open until timeout or completion.
    /// </summary>
    /// <param name="Value">
    /// A boolean value indicating whether to enable streaming. Default is <c>true</c>, meaning streaming is enabled by default.
    /// </param>
    /// <returns>
    /// The updated <c>TFIMParams</c> instance.
    /// </returns>
    function Stream(const Value: Boolean = True): TFIMParams;
    /// <summary>
    /// Options for streaming response. Only set this when you set stream: true.
    /// </summary>
    /// <param name="Value">
    /// A boolean value indicating whether to enable streaming. Default is <c>true</c>, meaning streaming is enabled by default.
    /// </param>
    /// <returns>
    /// The updated <c>TFIMParams</c> instance.
    /// </returns>
    /// <remarks>
    /// If set, an additional chunk will be streamed before the data: [DONE] message. The usage field on
    /// this chunk shows the token usage statistics for the entire request, and the choices field will
    /// always be an empty array. All other chunks will also include a usage field, but with a null value.
    /// </remarks>
    function StreamOptions(const Value: Boolean): TFIMParams;
    /// <summary>
    /// The suffix that comes after a completion of inserted text.
    /// </summary>
    /// <param name="Value">
    /// String value
    /// </param>
    /// <returns>
    /// The updated <c>TFIMParams</c> instance.
    /// </returns>
    function Suffix(const Value: string): TFIMParams;
    /// <summary>
    /// Sets the sampling temperature to use for the model's output.
    /// Higher values like 0.8 make the output more random, while lower values like 0.2 make it more focused and deterministic.
    /// </summary>
    /// <param name="Value">
    /// The temperature value between 0.0 and 1.0. Default is 0.7.
    /// A temperature of 0 makes the model deterministic, while a temperature of 1 allows for maximum creativity.
    /// </param>
    /// <returns>
    /// The updated <c>TFIMParams</c> instance.
    /// </returns>
    function Temperature(const Value: Double): TFIMParams;
    /// <summary>
    /// Sets the nucleus sampling probability mass for the model (Top-p).
    /// For example, 0.1 means only the tokens comprising the top 10% probability mass are considered.
    /// </summary>
    /// <param name="Value">
    /// The <c>top_p</c> value between 0.0 and 1.0. Default is 1.
    /// Lower values limit the model to consider only the most probable options.
    /// </param>
    /// <returns>
    /// The updated <c>TFIMParams</c> instance.
    /// </returns>
    function TopP(const Value: Double): TFIMParams;
  end;

  /// <summary>
  /// Represents the top log probabilities for tokens generated by the model.
  /// </summary>
  /// <remarks>
  /// The <c>TFIMToplogprobs</c> class provides detailed information about the
  /// probabilities of tokens chosen by the model, including their text offsets
  /// and associated probabilities.
  /// </remarks>
  TFIMToplogprobs = class
  private
    [JsonNameAttribute('text_offset')]
    FTextOffset: TArray<Int64>;
    [JsonNameAttribute('token_logprobs')]
    FTokenLogprobs: TArray<Double>;
    FTokens: TArray<string>;
  public
    /// <summary>
    /// Gets or sets the text offsets for the tokens.
    /// </summary>
    /// <remarks>
    /// Use the <c>TextOffset</c> property to determine the starting character
    /// positions of tokens within the generated text. Each entry corresponds to
    /// the tokens in the <c>Tokens</c> property.
    /// </remarks>
    property TextOffset: TArray<Int64> read FTextOffset write FTextOffset;
    /// <summary>
    /// Gets or sets the log probabilities of the tokens.
    /// </summary>
    /// <remarks>
    /// The <c>TokenLogprobs</c> property provides a quantitative measure of the
    /// likelihood of each token. Values closer to zero indicate higher probability,
    /// while more negative values indicate lower probability.
    /// </remarks>
    property TokenLogprobs: TArray<Double> read FTokenLogprobs write FTokenLogprobs;
    /// <summary>
    /// Gets or sets the tokens generated by the model.
    /// </summary>
    /// <remarks>
    /// The <c>Tokens</c> property contains the actual text tokens corresponding to
    /// the log probabilities and text offsets. Each token represents a part of the
    /// generated text.
    /// </remarks>
    property Tokens: TArray<string> read FTokens write FTokens;
  end;

  /// <summary>
  /// Represents the log probabilities of tokens generated by the model.
  /// </summary>
  /// <remarks>
  /// The <c>TFIMLogprobs</c> class stores detailed information about the probabilities of tokens
  /// generated during a completion request. It includes data such as the tokens themselves,
  /// their respective log probabilities, and the character offsets of each token in the response text.
  /// Additionally, it can provide detailed insights into the top alternative tokens and their probabilities
  /// at each generation step.
  /// </remarks>
  TFIMLogprobs = class
  private
    [JsonNameAttribute('text_offset')]
    FTextOffset: TArray<Int64>;
    [JsonNameAttribute('token_logprobs')]
    FTokenLogprobs: TArray<Double>;
    FTokens: TArray<string>;
    [JsonNameAttribute('top_logprobs')]
    FTopLogprobs: TArray<TFIMToplogprobs>;
  public
    /// <summary>
    /// Gets or sets the array of character offsets for each token.
    /// </summary>
    property TextOffset: TArray<Int64> read FTextOffset write FTextOffset;
    /// <summary>
    /// Gets or sets the array of log probabilities for each token.
    /// </summary>
    property TokenLogprobs: TArray<Double> read FTokenLogprobs write FTokenLogprobs;
    /// <summary>
    /// Gets or sets the array of tokens generated by the model.
    /// </summary>
    property Tokens: TArray<string> read FTokens write FTokens;
    /// <summary>
    /// Gets or sets the array of top alternative tokens and their log probabilities.
    /// </summary>
    property TopLogprobs: TArray<TFIMToplogprobs> read FTopLogprobs write FTopLogprobs;
    /// <summary>
    /// Destructor to clean up resources used by the <c>TChatChoices</c> instance.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a choice generated by the AI model in response to a completion request.
  /// </summary>
  /// <remarks>
  /// The <c>TFIMChoice</c> class contains details about a specific choice produced by the AI model,
  /// including the generated text, associated log probabilities, the index of the choice,
  /// and the reason why the model stopped generating further tokens.
  /// </remarks>
  TFIMChoice = class
  private
    [JsonNameAttribute('finish_reason')]
    [JsonReflectAttribute(ctString, rtString, TFinishReasonInterceptor)]
    FFinishReason: TFinishReason;
    FIndex: Int64;
    FLogprobs: TFIMLogprobs;
    FText: string;
  public
    /// <summary>
    /// Possible values: [stop, length, content_filter, insufficient_system_resource]
    /// </summary>
    /// <remarks>
    /// The reason the model stopped generating tokens. This will be stop if the model hit a natural stop
    /// point or a provided stop sequence, length if the maximum number of tokens specified in the request
    /// was reached, content_filter if content was omitted due to a flag from our content filters, or
    /// insufficient_system_resource if the request is interrupted due to insufficient resource of the
    /// inference system.
    /// </remarks>
    property FinishReason: TFinishReason read FFinishReason write FFinishReason;
    /// <summary>
    /// The index of the choice in the list of possible choices generated by the model.
    /// </summary>
    /// <remarks>
    /// The <c>Index</c> property helps identify the position of this particular choice in a set of choices provided by the AI model.
    /// This is useful when multiple options are generated for completion, and each one is referenced by its index.
    /// </remarks>
    property Index: Int64 read FIndex write FIndex;
    /// <summary>
    /// Log probability information for the choice.
    /// </summary>
    property Logprobs: TFIMLogprobs read FLogprobs write FLogprobs;
    /// <summary>
    /// The content of the response.
    /// </summary>
    property Text: string read FText write FText;
    /// <summary>
    /// Destructor to clean up resources used by the <c>TChatChoices</c> instance.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents the main class for managing text completion responses.
  /// </summary>
  /// <remarks>
  /// The <c>TFIM</c> class encapsulates the details of a completion operation performed by an AI model.
  /// It includes properties such as the generated text choices, metadata about the completion, and usage statistics.
  /// This class is designed to work with the Deepseek API for handling text completions.
  /// </remarks>
  TFIM = class(TJSONFingerprint)
  private
    FId: string;
    FChoices: TArray<TFIMChoice>;
    FCreated: Int64;
    FModel: string;
    [JsonNameAttribute('system_fingerprint')]
    FSystemFingerprint: string;
    FObject: string;
    FUsage: TUsage;
  public
    /// <summary>
    /// A unique identifier for the completion.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// The list of completion choices the model generated for the input prompt.
    /// </summary>
    property Choices: TArray<TFIMChoice> read FChoices write FChoices;
    /// <summary>
    /// The Unix timestamp (in seconds) of when the completion was created.
    /// </summary>
    property Created: Int64 read FCreated write FCreated;
    /// <summary>
    /// The model used for completion.
    /// </summary>
    property Model: string read FModel write FModel;
    /// <summary>
    /// This fingerprint represents the backend configuration that the model runs with.
    /// </summary>
    property SystemFingerprint: string read FSystemFingerprint write FSystemFingerprint;
    /// <summary>
    /// Possible values: [text_completion]
    /// </summary>
    /// <remarks>
    /// The object type, which is always "text_completion"
    /// </remarks>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Usage statistics for the completion request.
    /// </summary>
    property Usage: TUsage read FUsage write FUsage;
    /// <summary>
    /// Destructor to release any resources used by this instance.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TFIM</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFIM</c> type extends the <c>TAsynParams&lt;TFIM&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynFIM = TAsynCallBack<TFIM>;

  /// <summary>
  /// Manages asynchronous streaming chat callBacks for a chat request using <c>TFIM</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFIMStream</c> type extends the <c>TAsynStreamParams&lt;TFIM&gt;</c> record to support the lifecycle of an asynchronous streaming chat operation.
  /// It provides callbacks for different stages, including when the operation starts, progresses with new data chunks, completes successfully, or encounters an error.
  /// This structure is ideal for handling scenarios where the chat response is streamed incrementally, providing real-time updates to the user interface.
  /// </remarks>
  TAsynFIMStream = TAsynStreamCallBack<TFIM>;

  /// <summary>
  /// Represents a callback procedure used during the reception of responses from a chat request in streaming mode.
  /// </summary>
  /// <param name="FIM">
  /// The <c>TFIM</c> object containing the current information about the response generated by the model.
  /// If this value is <c>nil</c>, it indicates that the data stream is complete.
  /// </param>
  /// <param name="IsDone">
  /// A boolean flag indicating whether the streaming process is complete.
  /// If <c>True</c>, it means the model has finished sending all response data.
  /// </param>
  /// <param name="Cancel">
  /// A boolean flag that can be set to <c>True</c> within the callback to cancel the streaming process.
  /// If set to <c>True</c>, the streaming will be terminated immediately.
  /// </param>
  /// <remarks>
  /// This callback is invoked multiple times during the reception of the response data from the model.
  /// It allows for real-time processing of received messages and interaction with the user interface or other systems
  /// based on the state of the data stream.
  /// When the <c>IsDone</c> parameter is <c>True</c>, it indicates that the model has finished responding,
  /// and the <c>TFIM</c> parameter will be <c>nil</c>.
  /// </remarks>
  TFIMEvent = reference to procedure(var FIM: TFIM; IsDone: Boolean; var Cancel: Boolean);

  /// <summary>
  /// Provides methods to manage and execute completion operations with AI models.
  /// </summary>
  /// <remarks>
  /// The <c>TFIM</c> class extends <c>TDeepseekAPIRoute</c> and offers
  /// functionality for synchronous and asynchronous interactions with AI "fim" models.
  /// It supports:
  /// <para>- Creating chat completions.</para>
  /// <para>- Streaming chat completions for real-time updates.</para>
  /// <para>- Managing callbacks for progress, success, and error handling during asynchronous operations.</para>
  /// <para>
  /// This class is designed to provide seamless integration with the Deepseek API,
  /// allowing for flexible and efficient chat-based interactions in applications.
  /// </para>
  /// </remarks>
  TFIMRoute = class(TDeepseekAPIRoute)
    /// <summary>
    /// Create an asynchronous completion "FIM" for message.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the parameters for the "FIM" request, such as model selection, messages, and other parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns a record containing event handlers for the asynchronous "FIM" completion, such as on success and on error.
    /// </param>
    /// <remarks>
    /// This procedure initiates an asynchronous request to generate a completion based on the provided parameters. The response or error is handled by the provided callBacks.
    /// <code>
    /// //var DeepSeekBeta := TDeepseekFactory.CreateBetaInstance(BarearKey);
    /// DeepSeekBeta.Chat.AsyncCreate(
    ///   procedure (Params: TFIMParams)
    ///   begin
    ///     // Define chat parameters
    ///   end,
    ///   function: TAsynFIM
    ///   begin
    ///     Result.Sender := My_component;  // Instance passed to callback parameter
    ///
    ///     Result.OnStart := nil;   // If nil then; Can be omitted
    ///
    ///     Result.OnSuccess := procedure (Sender: TObject; FIM: TFIM)
    ///     begin
    ///       // Handle success operation
    ///     end;
    ///
    ///     Result.OnError := procedure (Sender: TObject; Value: string)
    ///     begin
    ///       // Handle error message
    ///     end;
    ///   end);
    /// </code>
    /// </remarks>
    procedure AsynCreate(ParamProc: TProc<TFIMParams>; CallBacks: TFunc<TAsynFIM>);
    /// <summary>
    /// Creates an asynchronous streaming "FIM" completion request.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure used to configure the parameters for the "FIM" request, including the model, prompt, and additional options such as max tokens and streaming mode.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns a <c>TAsynFIMStream</c> record which contains event handlers for managing different stages of the streaming process: progress updates, success, errors, and cancellation.
    /// </param>
    /// <remarks>
    /// This procedure initiates an asynchronous "FIM" operation in streaming mode, where tokens are progressively received and processed.
    /// The provided event handlers allow for handling progress (i.e., receiving tokens in real time), detecting success, managing errors, and enabling cancellation logic.
    /// <code>
    /// //var DeepSeekBeta := TDeepseekFactory.CreateBetaInstance(BarearKey);
    /// DeepSeekBeta.Chat.AsyncCreateStream(
    ///   procedure(Params: TFIMParams)
    ///   begin
    ///     // Define chat parameters
    ///     Params.Stream;
    ///   end,
    ///
    ///   function: TAsynFIMStream
    ///   begin
    ///     Result.Sender := My_component; // Instance passed to callback parameter
    ///     Result.OnProgress :=
    ///         procedure (Sender: TObject; FIM: TFIM)
    ///         begin
    ///           // Handle progressive updates to the chat response
    ///         end;
    ///     Result.OnSuccess :=
    ///         procedure (Sender: TObject)
    ///         begin
    ///           // Handle success when the operation completes
    ///         end;
    ///     Result.OnError :=
    ///         procedure (Sender: TObject; Value: string)
    ///         begin
    ///           // Handle error message
    ///         end;
    ///     Result.OnDoCancel :=
    ///         function: Boolean
    ///         begin
    ///           Result := CheckBox1.Checked; // Click on checkbox to cancel
    ///         end;
    ///     Result.OnCancellation :=
    ///         procedure (Sender: TObject)
    ///         begin
    ///           // Processing when process has been canceled
    ///         end;
    ///   end);
    /// </code>
    /// </remarks>
    procedure AsynCreateStream(ParamProc: TProc<TFIMParams>;
      CallBacks: TFunc<TAsynFIMStream>);
    /// <summary>
    /// Creates a completion for the "FIM" message using the provided parameters.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure used to configure the parameters for the "FIM" request, such as selecting the model,
    /// providing messages, setting token limits, etc.
    /// </param>
    /// <returns>
    /// Returns a <c>TFIM</c> object that contains the chat response, including the choices generated by the model.
    /// </returns>
    /// <remarks>
    /// The <c>Create</c> method sends a "FIM" completion request and waits for the full response.
    /// The returned <c>TFIM</c> object contains the model's generated response, including multiple
    /// choices if available.
    /// <code>
    /// //var DeepSeekBeta := TDeepseekFactory.CreateBetaInstance(BarearKey);
    /// var Value := DeepSeekBeta.Chat.Create(
    ///     procedure (Params: TFIMParams)
    ///     begin
    ///       // Define chat parameters
    ///     end);
    ///   try
    ///     // Handle the Value
    ///   finally
    ///     Value.Free;
    ///   end;
    /// </code>
    /// </remarks>
    function Create(ParamProc: TProc<TFIMParams>): TFIM;
    /// <summary>
    /// Creates a "FIM" message completion with a streamed response.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure used to configure the parameters for the "FIM" request, such as selecting the model, providing messages, and adjusting other settings like token limits or temperature.
    /// </param>
    /// <param name="Event">
    /// A callback of type <c>TFIMEvent</c> that is triggered with each chunk of data received during the streaming process. It includes the current state of the <c>TFIM</c> object, a flag indicating if the stream is done, and a boolean to handle cancellation.
    /// </param>
    /// <returns>
    /// Returns <c>True</c> if the streaming process started successfully, <c>False</c> otherwise.
    /// </returns>
    /// <remarks>
    /// This method initiates a chat request in streaming mode, where the response is delivered incrementally in real-time.
    /// The <c>Event</c> callback will be invoked multiple times as tokens are received.
    /// When the response is complete, the <c>IsDone</c> flag will be set to <c>True</c>, and the <c>FIM</c> object will be <c>nil</c>.
    /// The streaming process can be interrupted by setting the <c>Cancel</c> flag to <c>True</c> within the event.
    /// <code>
    /// //var DeepSeekBeta := TDeepseekFactory.CreateBetaInstance(BarearKey);
    ///   DeepSeekBeta.Chat.CreateStream(
    ///     procedure (Params: TFIMParams)
    ///     begin
    ///       // Define chat parameters
    ///     end,
    ///
    ///     procedure(var FIM: TFIM; IsDone: Boolean; var Cancel: Boolean)
    ///     begin
    ///       // Handle displaying
    ///     end);
    /// </code>
    /// </remarks>
    function CreateStream(ParamProc: TProc<TFIMParams>; Event: TFIMEvent): Boolean;
  end;

implementation

uses
  Rest.Json;

{ TFIM }

destructor TFIM.Destroy;
begin
  for var Item in FChoices do
    Item.Free;
  if Assigned(FUsage) then
    FUsage.Free;
  inherited;
end;

{ TFIMChoice }

destructor TFIMChoice.Destroy;
begin
  if Assigned(FLogprobs) then
    FLogprobs.Free;
  inherited;
end;

{ TFIMLogprobs }

destructor TFIMLogprobs.Destroy;
begin
  for var Item in FTopLogprobs do
    Item.Free;
  inherited;
end;

{ TFIMParams }

function TFIMParams.Echo(const Value: Boolean): TFIMParams;
begin
  Result := TFIMParams(Add('echo', Value));
end;

function TFIMParams.FrequencyPenalty(const Value: Double): TFIMParams;
begin
  Result := TFIMParams(Add('frequency_penalty', Value));
end;

function TFIMParams.Logprobs(const Value: Integer): TFIMParams;
begin
  Result := TFIMParams(Add('logprobs', Value));
end;

function TFIMParams.MaxTokens(const Value: Integer): TFIMParams;
begin
  Result := TFIMParams(Add('max_tokens', Value));
end;

function TFIMParams.Model(const Value: string): TFIMParams;
begin
  Result := TFIMParams(Add('model', Value));
end;

function TFIMParams.PresencePenalty(const Value: Double): TFIMParams;
begin
  Result := TFIMParams(Add('presence_penalty', Value));
end;

function TFIMParams.Prompt(const Value: string): TFIMParams;
begin
  Result := TFIMParams(Add('prompt', Value));
end;

function TFIMParams.Stop(const Value: TArray<string>): TFIMParams;
begin
  Result := TFIMParams(Add('stop', Value));
end;

function TFIMParams.Stream(const Value: Boolean): TFIMParams;
begin
  Result := TFIMParams(Add('stream', Value));
end;

function TFIMParams.StreamOptions(const Value: Boolean): TFIMParams;
begin
  if Value then
    Result := TFIMParams(Add('stream_options', TJSONObject.Create.AddPair('include_usage', True) )) else
    Result := Self;
end;

function TFIMParams.Suffix(const Value: string): TFIMParams;
begin
  Result := TFIMParams(Add('suffix', Value));
end;

function TFIMParams.Temperature(const Value: Double): TFIMParams;
begin
  Result := TFIMParams(Add('temperature', Value));
end;

function TFIMParams.TopP(const Value: Double): TFIMParams;
begin
  Result := TFIMParams(Add('top_p', Value));
end;

function TFIMParams.Stop(const Value: string): TFIMParams;
begin
  Result := TFIMParams(Add('stop', Value));
end;

{ TFIMRoute }

procedure TFIMRoute.AsynCreate(ParamProc: TProc<TFIMParams>;
  CallBacks: TFunc<TAsynFIM>);
begin
  with TAsynCallBackExec<TAsynFIM, TFIM>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TFIM
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TFIMRoute.AsynCreateStream(ParamProc: TProc<TFIMParams>;
  CallBacks: TFunc<TAsynFIMStream>);
begin
var CallBackParams := TUseParamsFactory<TAsynFIMStream>.CreateInstance(CallBacks);

  var Sender := CallBackParams.Param.Sender;
  var OnStart := CallBackParams.Param.OnStart;
  var OnSuccess := CallBackParams.Param.OnSuccess;
  var OnProgress := CallBackParams.Param.OnProgress;
  var OnError := CallBackParams.Param.OnError;
  var OnCancellation := CallBackParams.Param.OnCancellation;
  var OnDoCancel := CallBackParams.Param.OnDoCancel;

  var Task: ITask := TTask.Create(
          procedure()
          begin
            {--- Pass the instance of the current class in case no value was specified. }
            if not Assigned(Sender) then
              Sender := Self;

            {--- Trigger OnStart callback }
            if Assigned(OnStart) then
              TThread.Queue(nil,
                procedure
                begin
                  OnStart(Sender);
                end);
            try
              var Stop := False;

              {--- Processing }
              CreateStream(ParamProc,
                procedure (var FIM: TFIM; IsDone: Boolean; var Cancel: Boolean)
                begin
                  {--- Check that the process has not been canceled }
                  if Assigned(OnDoCancel) then
                    TThread.Queue(nil,
                        procedure
                        begin
                          Stop := OnDoCancel();
                        end);
                  if Stop then
                    begin
                      {--- Trigger when processus was stopped }
                      if Assigned(OnCancellation) then
                        TThread.Queue(nil,
                        procedure
                        begin
                          OnCancellation(Sender)
                        end);
                      Cancel := True;
                      Exit;
                    end;
                  if not IsDone and Assigned(FIM) then
                    begin
                      var LocalChat := FIM;
                      FIM := nil;

                      {--- Triggered when processus is progressing }
                      if Assigned(OnProgress) then
                        TThread.Synchronize(TThread.Current,
                        procedure
                        begin
                          try
                            OnProgress(Sender, LocalChat);
                          finally
                            {--- Makes sure to release the instance containing the data obtained
                                 following processing}
                            LocalChat.Free;
                          end;
                        end)
                      else
                        LocalChat.Free;
                    end
                  else
                  if IsDone then
                    begin
                      {--- Trigger OnEnd callback when the process is done }
                      if Assigned(OnSuccess) then
                        TThread.Queue(nil,
                        procedure
                        begin
                          OnSuccess(Sender);
                        end);
                    end;
                end);
            except
              on E: Exception do
                begin
                  var Error := AcquireExceptionObject;
                  try
                    var ErrorMsg := (Error as Exception).Message;

                    {--- Trigger OnError callback if the process has failed }
                    if Assigned(OnError) then
                      TThread.Queue(nil,
                      procedure
                      begin
                        OnError(Sender, ErrorMsg);
                      end);
                  finally
                    {--- Ensures that the instance of the caught exception is released}
                    Error.Free;
                  end;
                end;
            end;
          end);
  Task.Start;
end;

function TFIMRoute.Create(ParamProc: TProc<TFIMParams>): TFIM;
begin
  Result := API.Post<TFIM, TFIMParams>('completions', ParamProc);
end;

function TFIMRoute.CreateStream(ParamProc: TProc<TFIMParams>;
  Event: TFIMEvent): Boolean;
var
  Response: TStringStream;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Result := API.Post<TFIMParams>('completions', ParamProc, Response,
      procedure(const Sender: TObject; AContentLength, AReadCount: Int64; var AAbort: Boolean)
      var
        TextBuffer  : string;
        BufferPos   : Integer;
        PosLineEnd  : Integer;
        Line, Data  : string;
        Chat        : TFIM;
        IsDone      : Boolean;
        NewBuffer   : string;
      begin
        {--- Recovers all data already received }
        try
          TextBuffer := Response.DataString;
        except
          {--- invalid encoding: we are waiting for the rest }
          on E: EEncodingError do
            Exit;
        end;

        {--- Current position in the buffer }
        BufferPos := 0;

        {--- Line-by-line processing as long as a complete line (terminated by LF) is available }
        while True do
          begin
            PosLineEnd := TextBuffer.IndexOf(#10, BufferPos);
            if PosLineEnd < 0 then
              {--- incomplete line -> we are waiting for the rest }
              Break;

            Line := TextBuffer.Substring(BufferPos, PosLineEnd - BufferPos).Trim([' ', #13, #10]);
            {--- go to the next line }
            BufferPos := PosLineEnd + 1;

            if Line.IsEmpty then
              {--- empty line -> we ignore }
              Continue;

            Data   := Line.Replace('data: ', '').Trim([' ', #13, #10]);
            IsDone := SameText(Data, '[DONE]');

            Chat := nil;
            if not IsDone then
            try
              Chat := TDeepseekAPI.Parse<TFIM>(Data);
            except
              {--- if the JSON is incomplete we ignore }
              Chat := nil;
            end;

            try
              Event(Chat, IsDone, AAbort);
            finally
              Chat.Free;
            end;

            if IsDone then
              {--- end of flow }
              Break;
          end;

        {--- Cleaning: only the incomplete portion of the tampon is kept }
        if BufferPos > 0 then
          begin
            {--- remaining fragment }
            NewBuffer := TextBuffer.Substring(BufferPos);

            {--- completely clears the stream }
            Response.Size := 0;
            if not NewBuffer.IsEmpty then
              {--- rewrites the unfinished fragment }
              Response.WriteString(NewBuffer);
          end;
      end);
  finally
    Response.Free;
  end;
end;

end.
