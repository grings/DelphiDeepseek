unit Deepseek.Chat;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiDeepseek
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, REST.JsonReflect, System.JSON, System.Threading,
  REST.Json.Types, Deepseek.API.Params, Deepseek.API, Deepseek.Types,
  Deepseek.Async.Params, Deepseek.Async.Support, Deepseek.Async.Promise,
  Deepseek.Functions.Tools, Deepseek.Functions.Core, Deepseek.API.Parallel;

type
  /// <summary>
  /// Messages comprising the conversation so far.
  /// </summary>
  TContentParams = class(TJSONParam)
  public
    /// <summary>
    /// The role of the messages author.
    /// </summary>
    function Role(const Value: TMessageRole): TContentParams; overload;

    /// <summary>
    /// The role of the messages author.
    /// </summary>
    function Role(const Value: string): TContentParams; overload;

    /// <summary>
    /// An optional name for the participant. Provides the model information to differentiate between
    /// participants of the same role.
    /// </summary>
    function Name(const Value: string): TContentParams;

    /// <summary>
    /// The contents of the system message.
    /// </summary>
    function Content(const Value: string): TContentParams; overload;

    /// <summary>
    /// Gets or sets the content of the message.
    /// </summary>
    /// <remarks>
    /// The <c>Content</c> property contains the actual message text. This is a required field and cannot be empty, as it represents the core information being exchanged
    /// in the chat, whether it's from the user, the assistant, or the system.
    /// </remarks>
    function Content(const Value: TJSONArray): TContentParams; overload;

    /// <summary>
    /// (Beta) Set this to true to force the model to start its answer by the content of the supplied
    /// prefix in this assistant message. You must set base_url="https://api.deepseek.com/beta" to use
    /// this feature.
    /// </summary>
    function Prefix(const Value: Boolean): TContentParams;

    /// <summary>
    /// (Beta) Used for the deepseek-reasoner model in the Chat Prefix Completion feature as the input for the CoT
    /// in the last assistant message. When using this feature, the prefix parameter must be set to true.
    /// </summary>
    function ReasoningContent(const Value: string): TContentParams;

    /// <summary>
    /// Creates a new chat message payload with the role of the system.
    /// </summary>
    /// <param name="Value">
    /// The content of the system message.
    /// </param>
    /// <param name="Name">
    /// Set the name for the participant
    /// </param>
    /// <returns>
    /// A <c>TContentParams</c> instance with the role set to "system" and the provided content.
    /// </returns>
    /// <remarks>
    /// This method is used to create system-level messages, which may be used for notifications, warnings, or other system-related interactions.
    /// </remarks>
    class function System(const Content: string; const Name: string = ''): TContentParams;

    /// <summary>
    /// Creates a new chat message payload with the role of the user.
    /// </summary>
    /// <param name="Value">
    /// The content of the message that the user is sending.
    /// </param>
    /// <param name="Name">
    /// Set the name for the participant
    /// </param>
    /// <returns>
    /// A <c>TContentParams</c> instance with the role set to "user" and the provided content.
    /// </returns>
    /// <remarks>
    /// This method is used to create messages from the user's perspective, typically representing inputs or queries in the conversation.
    /// </remarks>
    class function User(const Content: string; const Name: string = ''): TContentParams; overload;

    /// <summary>
    /// Creates a new chat message payload with the role of the assistant.
    /// </summary>
    /// <param name="Value">
    /// The content of the message that the assistant is sending.
    /// </param>
    /// <param name="Prefix">
    /// Use prefix or no.
    /// </param>
    /// <returns>
    /// A <c>TContentParams</c> instance with the role set to "assistant" and the provided content.
    /// </returns>
    /// <remarks>
    /// This method is a convenience for creating assistant messages. Use this method when the assistant needs to respond to the user or system.
    /// </remarks>
    class function Assistant(const Content: string; const Prefix: Boolean = False): TContentParams; overload;

    /// <summary>
    /// Creates a new chat message payload with the role of the assistant.
    /// </summary>
    /// <param name="Value">
    /// The content of the message that the assistant is sending.
    /// </param>
    /// <param name="Name">
    /// Set the name for the participant.
    /// </param>
    /// <param name="Prefix">
    /// Use prefix or no.
    /// </param>
    /// <returns>
    /// A <c>TContentParams</c> instance with the role set to "assistant" and the provided content.
    /// </returns>
    /// <remarks>
    /// This method is a convenience for creating assistant messages. Use this method when the assistant needs to respond to the user or system.
    /// </remarks>
    class function Assistant(const Content, Name: string; const Prefix: Boolean = False): TContentParams; overload;
  end;

  /// <summary>
  /// The <c>TChatParams</c> class represents the set of parameters used to configure a chat interaction with an AI model.
  /// </summary>
  /// <remarks>
  /// This class allows you to define various settings that control how the model behaves, including which model to use, how many tokens to generate,
  /// what kind of messages to send, and how the model should handle its output. By using this class, you can fine-tune the AI's behavior and response format
  /// based on your application's specific needs.
  /// <para>
  /// It inherits from <c>TJSONParam</c>, which provides methods for handling and serializing the parameters as JSON, allowing seamless integration
  /// with JSON-based APIs.
  /// </para>
  /// <code>
  /// var
  ///   Params: TChatParams;
  /// begin
  ///   Params := TChatParams.Create
  ///     .Model('my_model')
  ///     .MaxTokens(100)
  ///     .Messages([TChatMessagePayload.User('Hello!')])
  ///     .ResponseFormat('json_object')
  ///     .Temperature(0.7)
  ///     .TopP(1)
  ///     .SafePrompt(True);
  /// end;
  /// </code>
  /// This example shows how to instantiate and configure a <c>TChatParams</c> object for interacting with an AI model.
  /// </remarks>
  TChatParams = class(TJSONParam)
  public
    function Messages(const Value: TArray<TJSONParam>): TChatParams;

    /// <summary>
    /// Specifies the identifier of the model to use.
    /// </summary>
    /// <param name="Value">
    /// The model ID to be used for the completion.
    /// Ensure that the specified model is supported and correctly spelled.
    /// </param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    /// <remarks>
    /// This parameter is required and determines which model will process the request.
    /// </remarks>
    function Model(const Value: string): TChatParams;

    /// <summary>
    /// Frequency_penalty penalizes the repetition of words based on their frequency in the generated text.
    /// </summary>
    /// <param name="Value">
    /// number (Presence Penalty) [ -2 .. 2 ]; Default: 0
    /// </param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    /// <remarks>
    /// A higher frequency penalty discourages the model from repeating words that have already appeared
    /// frequently in the output, promoting diversity and reducing repetition.
    /// </remarks>
    function FrequencyPenalty(const Value: Double): TChatParams;

    /// <summary>
    /// Sets the maximum number of tokens to generate in the completion.
    /// The total token count of your prompt plus <c>max_tokens</c> cannot exceed the model's context length.
    /// </summary>
    /// <param name="Value">
    /// The maximum number of tokens to generate.
    /// Choose an appropriate value based on your prompt length to avoid exceeding the model's limit.
    /// </param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    function MaxTokens(const Value: Integer): TChatParams;

    /// <summary>
    /// Presence_penalty determines how much the model penalizes the repetition of words or phrases
    /// </summary>
    /// <param name="Value">
    /// number (Presence Penalty) [ -2 .. 2 ]; Default: 0
    /// </param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    /// <remarks>
    /// A higher presence penalty encourages the model to use a wider variety of words and phrases,
    /// making the output more diverse and creative.
    /// </remarks>
    function PresencePenalty(const Value: Double): TChatParams;

    /// <summary>
    /// Specifies the format in which the model should return the response. This can include formats like JSON or plain text.
    /// </summary>
    /// <param name="Value">The desired response format, with the default being <c>"json_object"</c>.</param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    /// <remarks>
    /// If not specified, the default value is <c>{ "type": "text" }</c>. When using JSON mode, it's necessary to instruct the model to produce JSON explicitly through the system or user messages.
    /// </remarks>
    function ResponseFormat(const Value: TResponseFormat): TChatParams; overload;

    /// <summary>
    /// Specifies the format in which the model should return the response. This can include formats like JSON or plain text.
    /// </summary>
    /// <param name="Value">The desired response format, with the default being <c>"json_object"</c>.</param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    /// <remarks>
    /// If not specified, the default value is <c>{ "type": "text" }</c>. When using JSON mode, it's necessary to instruct the model to produce JSON explicitly through the system or user messages.
    /// </remarks>
    function ResponseFormat(const Value: string): TChatParams; overload;

    /// <summary>
    /// Stop (string)
    /// Stop generation if this token is detected. Or if one of these tokens is detected when providing an array
    /// </summary>
    /// <param name="Value">
    /// The string that causes the stop
    /// </param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    function Stop(const Value: string): TChatParams; overload;

    /// <summary>
    /// Stop Array of Stop (strings) (Stop)
    /// Stop generation if this token is detected. Or if one of these tokens is detected when providing an array
    /// </summary>
    /// <param name="Value">
    /// The array of string that causes the stop
    /// </param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    function Stop(const Value: TArray<string>): TChatParams; overload;

    /// <summary>
    /// Specifies whether to stream back partial progress as server-sent events (SSE).
    /// If <c>true</c>, tokens are sent as they become available.
    /// If <c>false</c>, the server will hold the request open until timeout or completion.
    /// </summary>
    /// <param name="Value">
    /// A boolean value indicating whether to enable streaming. Default is <c>true</c>, meaning streaming is enabled by default.
    /// </param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    function Stream(const Value: Boolean = True): TChatParams;

    /// <summary>
    /// Options for streaming response. Only set this when you set stream: true.
    /// </summary>
    /// <param name="Value">
    /// A boolean value indicating whether to enable streaming. Default is <c>true</c>, meaning streaming is enabled by default.
    /// </param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    /// <remarks>
    /// If set, an additional chunk will be streamed before the data: [DONE] message. The usage field on
    /// this chunk shows the token usage statistics for the entire request, and the choices field will
    /// always be an empty array. All other chunks will also include a usage field, but with a null value.
    /// </remarks>
    function StreamOptions(const Value: Boolean): TChatParams;

    /// <summary>
    /// Sets the sampling temperature to use for the model's output.
    /// Higher values like 0.8 make the output more random, while lower values like 0.2 make it more focused and deterministic.
    /// </summary>
    /// <param name="Value">
    /// The temperature value between 0.0 and 1.0. Default is 0.7.
    /// A temperature of 0 makes the model deterministic, while a temperature of 1 allows for maximum creativity.
    /// </param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    function Temperature(const Value: Double): TChatParams;

    /// <summary>
    /// Sets the nucleus sampling probability mass for the model (Top-p).
    /// For example, 0.1 means only the tokens comprising the top 10% probability mass are considered.
    /// </summary>
    /// <param name="Value">
    /// The <c>top_p</c> value between 0.0 and 1.0. Default is 1.
    /// Lower values limit the model to consider only the most probable options.
    /// </param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    function TopP(const Value: Double): TChatParams;

    /// <summary>
    /// Specifies a list of tools that the model can use to generate structured outputs such as JSON inputs for function calls.
    /// </summary>
    /// <param name="Value">
    /// An array of <c>TChatMessageTool</c> representing the tools available to the model.
    /// </param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    /// <remarks>
    /// These tools can include functions that the model can utilize when generating output. For example, they can help the model produce structured data for specific tasks.
    /// </remarks>
    function Tools(const Value: TArray<TChatMessageTool>): TChatParams; overload;

    /// <summary>
    /// Specifies a list of tools that the model can use to generate structured outputs such as JSON inputs for function calls.
    /// </summary>
    /// <param name="Value">
    /// An array of <c>IFunctionCore</c> representing the tools available to the model.
    /// </param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    /// <remarks>
    /// These tools can include functions that the model can utilize when generating output. For example, they can help the model produce structured data for specific tasks.
    /// </remarks>
    function Tools(const Value: TArray<IFunctionCore>): TChatParams; overload;

    /// <summary>
    /// Configures how the model interacts with functions. This can either prevent, allow, or require function calls depending on the setting.
    /// </summary>
    /// <param name="Value">
    /// The <c>TToolChoice</c> setting for function interaction, with a default of "auto".
    /// </param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    /// <remarks>
    /// If set to <c>none</c>, the model will not call any functions and will generate a message instead.
    /// If set to <c>auto</c>, the model can choose between generating a message or calling a function.
    /// If set to <c>required</c>, the model is required to call a function.
    /// </remarks>
    function ToolChoice(const Value: TToolChoice): TChatParams; overload;

    /// <summary>
    /// Configures how the model interacts with functions. This can either prevent, allow, or require function calls depending on the setting.
    /// </summary>
    /// <param name="Value">
    /// The <c>TToolChoice</c> setting for function interaction, with a default of "auto".
    /// </param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    /// <remarks>
    /// If set to <c>none</c>, the model will not call any functions and will generate a message instead.
    /// If set to <c>auto</c>, the model can choose between generating a message or calling a function.
    /// If set to <c>required</c>, the model is required to call a function.
    /// </remarks>
    function ToolChoice(const Value: string): TChatParams; overload;

    /// <summary>
    /// Whether to return log probabilities of the output tokens or not. If true, returns the log probabilities of each output token returned in the content of message.
    /// </summary>
    /// <param name="Value">
    /// Set True to activate.
    /// </param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    function Logprobs(const Value: Boolean): TChatParams;

    /// <summary>
    /// An integer between 0 and 20 specifying the number of most likely tokens to return at each token position, each with an associated log probability.
    /// logprobs must be set to true if this parameter is used.
    /// </summary>
    /// <param name="Value">
    /// Possible values: <= 20.
    /// </param>
    /// <returns>
    /// The updated <c>TChatParams</c> instance.
    /// </returns>
    function TopLogprobs(const Value: Integer): TChatParams;
  end;

  /// <summary>
  /// Represents the buffer for accumulating streamed chat response data.
  /// </summary>
  /// <remarks>
  /// <para>The <c>TPromiseBuffer</c> record stores information collected during a streaming chat operation.</para>
  /// <para><see cref="Content"/> holds the incremental text output from the assistant as it arrives.</para>
  /// <para><see cref="Reasoning"/> holds any reasoning content delivered before the final output.</para>
  /// <para>This buffer is returned to the caller once the stream completes.</para>
  /// </remarks>
  TPromiseBuffer = record
  private
    FContent: string;
    FReasoning: string;
  public
    /// <summary>
    /// Gets or sets the concatenated text output received so far.
    /// </summary>
    property Content: string read FContent write FContent;

    /// <summary>
    /// Gets or sets the concatenated reasoning content received so far.
    /// </summary>
    property Reasoning: string read FReasoning write FReasoning;
  end;

  /// <summary>
  /// Represents the specifics of a called function, including its name and calculated arguments.
  /// </summary>
  TFunction = class
  private
    FName: string;
    FArguments: string;
  public
    /// <summary>
    /// Gets or sets the name of the called function
    /// </summary>
    property Name: string read FName write FName;

    /// <summary>
    /// Gets or sets the calculed Arguments for the called function
    /// </summary>
    property Arguments: string read FArguments write FArguments;
  end;

  /// <summary>
  /// Represents a called function, containing its specifics such as name and arguments.
  /// </summary>
  TToolCalls = class
  private
    FId: string;
    FType: string;
    FFunction: TFunction;
  public
    /// <summary>
    /// Gets or sets the id of the called function
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// Gets or sets the type of the called function
    /// </summary>
    property &Type: string read FType write FType;

    /// <summary>
    /// Gets or sets the specifics of the called function
    /// </summary>
    property &Function: TFunction read FFunction write FFunction;

    /// <summary>
    /// Destructor that ensures proper memory management by freeing the <c>FFunction</c> property
    /// when the <c>TToolCalls</c> instance is destroyed.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a chat message exchanged between participants (user, assistant, or system) in a conversation.
  /// </summary>
  /// <remarks>
  /// The <c>TChoiceMessage</c> class encapsulates the essential information of a message within a chat application, including:
  /// <para>
  /// - The role of the sender (user, assistant, or system).
  /// </para>
  /// <para>
  /// - The content of the message itself.
  /// </para>
  /// <para>
  /// - Optionally, a list of tool calls that may be required to complete the message response.
  /// </para>
  /// This class is fundamental for managing the flow of a conversation, allowing the system to track who said what and what actions need to be taken.
  /// </remarks>
  TChoiceMessage = class
  private
    FContent: string;
    [JsonReflectAttribute(ctString, rtString, TMessageRoleInterceptor)]
    FRole: TMessageRole;
    [JsonNameAttribute('tool_calls')]
    FToolCalls: TArray<TToolCalls>;
    [JsonNameAttribute('reasoning_content')]
    FReasoningContent: string;
  public
    /// <summary>
    /// The contents of the message.
    /// </summary>
    /// <remarks>
    /// The <c>Content</c> property stores the actual message text. This can include user inputs, assistant-generated replies, or system instructions.
    /// </remarks>
    property Content: string read FContent write FContent;

    /// <summary>
    /// The role of the author of this message, indicating the sender (e.g., user, assistant, or system).
    /// </summary>
    /// <remarks>
    /// The <c>Role</c> property identifies the participant responsible for the message. Common values are "user" for messages sent by the user,
    /// "assistant" for responses generated by the AI, or "system" for control messages.
    /// </remarks>
    property Role: TMessageRole read FRole write FRole;

    /// <summary>
    /// A list of tool calls to be executed for query completion.
    /// </summary>
    /// <remarks>
    /// The <c>ToolsCalls</c> property contains a list of functions or tools that need to be invoked to process the current query further.
    /// This is typically used when the assistant needs to call external APIs or perform specific actions before delivering a final response.
    /// </remarks>
    property ToolCalls: TArray<TToolCalls> read FToolCalls write FToolCalls;

    /// <summary>
    /// For deepseek-reasoner model only. The reasoning contents of the assistant message, before the final answer.
    /// </summary>
    property ReasoningContent: string read FReasoningContent write FReasoningContent;

    /// <summary>
    /// Destructor to release any resources used by this instance.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents the top log probabilities of tokens in a model's output.
  /// </summary>
  /// <remarks>
  /// The <c>TTopLogprobs</c> class is used to encapsulate detailed information
  /// about the probabilities of the most likely tokens at a specific position
  /// during the generation of a model's output.
  /// <para>
  /// This class is useful for analyzing and debugging the behavior of language
  /// models by providing a deeper insight into the decision-making process at
  /// the token level.
  /// </para>
  /// <para>
  /// It includes the token, its log probability, and its byte representation
  /// in UTF-8 format, making it an essential tool for advanced token-level
  /// evaluations.
  /// </para>
  /// </remarks>
  TTopLogprobs = class
  private
    FToken: string;
    FLogprob: Double;
    FBytes: TArray<int64>;
  public
    /// <summary>
    /// The current token.
    /// </summary>
    property Token: string read FToken write FToken;

    /// <summary>
    /// The log probability of this token, if it is within the top 20 most likely tokens. Otherwise,
    /// the value -9999.0 is used to signify that the token is very unlikely.
    /// </summary>
    property Logprob: Double read FLogprob write FLogprob;

    /// <summary>
    /// A list of integers representing the UTF-8 bytes representation of the token. Useful in instances
    /// where characters are represented by multiple tokens and their byte representations must be
    /// combined to generate the correct text representation. Can be null if there is no bytes
    /// representation for the token.
    /// </summary>
    property Bytes: TArray<int64> read FBytes write FBytes;
  end;

  /// <summary>
  /// Represents detailed log probability information for a specific token.
  /// </summary>
  /// <remarks>
  /// The <c>TLogprobContent</c> class provides a comprehensive structure for storing
  /// and analyzing the log probabilities of tokens generated by a model.
  /// It includes:
  /// <para>- The token itself.</para>
  /// <para>- The log probability of the token.</para>
  /// <para>- The UTF-8 byte representation of the token, when applicable.</para>
  /// <para>- A list of the most likely tokens and their log probabilities at this position,
  /// represented by <c>TTopLogprobs</c>.</para>
  /// <para>
  /// This class is particularly useful in tasks requiring token-level analysis,
  /// such as understanding model decisions, debugging outputs, or assessing
  /// the confidence of specific token choices.
  /// </para>
  /// </remarks>
  TLogprobContent = class
  private
    FToken: string;
    FLogprob: Double;
    FBytes: TArray<int64>;
    [JsonNameAttribute('top_logprobs')]
    FTopLogprobs: TArray<TTopLogprobs>;
  public
    /// <summary>
    /// The current token.
    /// </summary>
    property Token: string read FToken write FToken;

    /// <summary>
    /// The log probability of this token, if it is within the top 20 most likely tokens. Otherwise,
    /// the value -9999.0 is used to signify that the token is very unlikely.
    /// </summary>
    property Logprob: Double read FLogprob write FLogprob;

    /// <summary>
    /// A list of integers representing the UTF-8 bytes representation of the token. Useful in instances
    /// where characters are represented by multiple tokens and their byte representations must be
    /// combined to generate the correct text representation. Can be null if there is no bytes
    /// representation for the token.
    /// </summary>
    property Bytes: TArray<int64> read FBytes write FBytes;

    /// <summary>
    /// List of the most likely tokens and their log probability, at this token position. In rare cases,
    /// there may be fewer than the number of requested top_logprobs returned.
    /// </summary>
    property TopLogprobs: TArray<TTopLogprobs> read FTopLogprobs write FTopLogprobs;

    /// <summary>
    /// Destructor to release any resources used by this instance.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents the aggregated log probability information for a choice's output.
  /// </summary>
  /// <remarks>
  /// The <c>TLogprobs</c> class provides a structured way to encapsulate
  /// log probability data for tokens generated during a model's output.
  /// It consists of a collection of <c>TLogprobContent</c> instances,
  /// each representing detailed information for a single token.
  /// <para>
  /// This class is essential for advanced token-level analysis, allowing developers
  /// to assess the confidence of a model's predictions and understand the
  /// distribution of token probabilities across an entire response.
  /// </para>
  /// </remarks>
  TLogprobs = class
  private
    FContent: TArray<TLogprobContent>;
  public
    /// <summary>
    /// Log probability information for the choice.
    /// </summary>
    property Content: TArray<TLogprobContent> read FContent write FContent;

    /// <summary>
    /// Destructor to release any resources used by this instance.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents incremental updates to a chat message during streaming responses.
  /// </summary>
  /// <remarks>
  /// The <c>TDelta</c> class provides a structure to encapsulate partial or
  /// incremental updates to a chat message during streaming interactions
  /// with an AI model. It includes:
  /// <para>- The content of the partial message.</para>
  /// <para>- The role of the author of the message (e.g., user, assistant, or system).</para>
  /// <para>
  /// - This class is particularly useful for real-time applications where responses
  /// are streamed as they are generated, allowing for dynamic updates to the
  /// conversation interface.
  /// </para>
  /// <para>
  /// - Does not allow handling function calls during SSE processing.
  /// </para>
  /// </remarks>
  TDelta = class
  private
    FContent: string;
    [JsonReflectAttribute(ctString, rtString, TMessageRoleInterceptor)]
    FRole: TMessageRole;
    [JsonNameAttribute('reasoning_content')]
    FReasoningContent: string;
  public
    /// <summary>
    /// The contents of the message.
    /// </summary>
    /// <remarks>
    /// The <c>Content</c> property stores the actual message text. This can include user inputs, assistant-generated replies, or system instructions.
    /// </remarks>
    property Content: string read FContent write FContent;

    /// <summary>
    /// The role of the author of this message, indicating the sender (e.g., user, assistant, or system).
    /// </summary>
    /// <remarks>
    /// The <c>Role</c> property identifies the participant responsible for the message. Common values are "user" for messages sent by the user,
    /// "assistant" for responses generated by the AI, or "system" for control messages.
    /// </remarks>
    property Role: TMessageRole read FRole write FRole;

    /// <summary>
    /// For deepseek-reasoner model only. The reasoning contents of the assistant message, before the final answer.
    /// </summary>
    property ReasoningContent: string read FReasoningContent write FReasoningContent;
  end;

  /// <summary>
  /// Represents a single completion option generated by the AI model during a chat interaction.
  /// </summary>
  /// <remarks>
  /// The <c>TChatChoice</c> class stores the results of the AI model's response to a user prompt. Each instance of this class represents one of potentially
  /// many choices that the model could return. This includes:
  /// <para>
  /// - The finish reason.
  /// </para>
  /// <para>
  /// - An index identifying the choice.
  /// </para>
  /// <para>
  /// - A message generated by the model.
  /// </para>
  /// <para>
  /// - Optional deltas for streamed responses.
  /// </para>
  /// <para>
  /// - The reason the model stopped generating tokens.
  /// </para>
  /// This class is useful when multiple potential responses are generated and evaluated, or when streaming responses incrementally.
  /// </remarks>
  TChatChoice = class
  private
    [JsonNameAttribute('finish_reason')]
    [JsonReflectAttribute(ctString, rtString, TFinishReasonInterceptor)]
    FFinishReason: TFinishReason;
    FIndex: Int64;
    FMessage: TChoiceMessage;
    FLogprobs: TLogprobs;
    FDelta: TDelta;
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
    /// A chat completion message generated by the AI model.
    /// </summary>
    /// <remarks>
    /// The <c>Message</c> property contains the message that the model generated based on the provided prompt or conversation context.
    /// This is typically a complete message representing the AI's response to a user or system message.
    /// </remarks>
    property Message: TChoiceMessage read FMessage write FMessage;

    /// <summary>
    /// Log probability information for the choice.
    /// </summary>
    property Logprobs: TLogprobs read FLogprobs write FLogprobs;

    /// <summary>
    /// A chat completion delta representing partial responses generated during streaming.
    /// </summary>
    /// <remarks>
    /// The <c>Delta</c> property holds an incremental message (or delta) when the model sends streamed responses.
    /// This allows the model to progressively generate and deliver a response before it is fully completed.
    /// </remarks>
    property Delta: TDelta read FDelta write FDelta;

    /// <summary>
    /// Destructor to clean up resources used by the <c>TChatChoices</c> instance.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents the token usage statistics for a chat interaction, including the number of tokens
  /// used in the prompt, the completion, and the total number of tokens consumed.
  /// </summary>
  /// <remarks>
  /// The <c>TChatUsage</c> class provides insight into the number of tokens used during a chat interaction.
  /// This information is critical for understanding the cost of a request when using token-based billing systems
  /// or for monitoring the model's behavior in terms of input (prompt) and output (completion) size.
  /// </remarks>
  TUsage = class
  private
    [JsonNameAttribute('completion_tokens')]
    FCompletionTokens: Int64;
    [JsonNameAttribute('prompt_tokens')]
    FPromptTokens: Int64;
    [JsonNameAttribute('prompt_cache_hit_tokens')]
    FPromptCacheHitTokens: Int64;
    [JsonNameAttribute('prompt_cache_miss_tokens')]
    FPromptCacheMissTokens: Int64;
    [JsonNameAttribute('total_tokens')]
    FTotalTokens: Int64;
  public
    /// <summary>
    /// Number of tokens in the generated completion.
    /// </summary>
    property CompletionTokens: Int64 read FCompletionTokens write FCompletionTokens;

    /// <summary>
    /// Number of tokens in the prompt. It equals prompt_cache_hit_tokens + prompt_cache_miss_tokens.
    /// </summary>
    property PromptTokens: Int64 read FPromptTokens write FPromptTokens;

    /// <summary>
    /// Number of tokens in the prompt that hits the context cache.
    /// </summary>
    property PromptCacheHitTokens: Int64 read FPromptCacheHitTokens write FPromptCacheHitTokens;

    /// <summary>
    /// Number of tokens in the prompt that misses the context cache.
    /// </summary>
    property PromptCacheMissTokens: Int64 read FPromptCacheMissTokens write FPromptCacheMissTokens;

    /// <summary>
    /// Total number of tokens used in the request (prompt + completion).
    /// </summary>
    property TotalTokens: Int64 read FTotalTokens write FTotalTokens;
  end;

  /// <summary>
  /// Represents a chat completion response generated by an AI model, containing the necessary metadata,
  /// the generated choices, and usage statistics.
  /// </summary>
  /// <remarks>
  /// The <c>TChat</c> class encapsulates the results of a chat request made to an AI model.
  /// It contains details such as a unique identifier, the model used, when the completion was created,
  /// the choices generated by the model, and token usage statistics.
  /// This class is crucial for managing the results of AI-driven conversations and understanding the
  /// underlying usage and response characteristics of the AI.
  /// </remarks>
  TChat = class(TJSONFingerprint)
  private
    FId: string;
    FChoices: TArray<TChatChoice>;
    FCreated: Int64;
    FModel: string;
    [JsonNameAttribute('system_fingerprint')]
    FSystemFingerprint: string;
    FObject: string;
    FUsage: TUsage;
  public
    /// <summary>
    /// A unique identifier for the chat completion.
    /// </summary>
    /// <remarks>
    /// The <c>Id</c> property stores a unique string that identifies the specific chat completion request.
    /// This is useful for tracking and managing chat sessions or retrieving the results of a particular interaction.
    /// </remarks>
    property Id: string read FId write FId;

    /// <summary>
    /// A list of chat completion choices generated by the model.
    /// </summary>
    /// <remarks>
    /// The <c>Choices</c> property holds an array of <c>TChatChoices</c> objects, which represent the different response options
    /// generated by the AI model. There may be multiple choices if the request asked for more than one completion.
    /// </remarks>
    property Choices: TArray<TChatChoice> read FChoices write FChoices;

    /// <summary>
    /// The Unix timestamp (in seconds) of when the chat completion was created.
    /// </summary>
    /// <remarks>
    /// The <c>Created</c> property contains a Unix timestamp indicating when the AI generated the chat completion. This is
    /// useful for logging, auditing, or ordering chat completions chronologically.
    /// </remarks>
    property Created: Int64 read FCreated write FCreated;

    /// <summary>
    /// The model used for the chat completion.
    /// </summary>
    /// <remarks>
    /// The <c>Model</c> property specifies which AI model was used to generate the chat completion. This can be helpful
    /// when comparing results across different models or tracking which model versions are producing responses.
    /// </remarks>
    property Model: string read FModel write FModel;

    /// <summary>
    /// This fingerprint represents the backend configuration that the model runs with.
    /// </summary>
    property SystemFingerprint: string read FSystemFingerprint write FSystemFingerprint;

    /// <summary>
    /// The object type, which is always "chat.completion".
    /// </summary>
    /// <remarks>
    /// The <c>Object</c> property describes the type of the response. For chat completions, this value is always "chat.completion",
    /// providing a clear indication of the response type when working with multiple object types in a system.
    /// </remarks>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// Usage statistics for the completion request, including token counts for the prompt and completion.
    /// </summary>
    /// <remarks>
    /// The <c>Usage</c> property contains information about the number of tokens consumed during the request, including the
    /// tokens used in the prompt and those generated in the completion. This data is important for monitoring API usage and costs.
    /// </remarks>
    property Usage: TUsage read FUsage write FUsage;

    /// <summary>
    /// Destructor to clean up resources used by the <c>TChatChoices</c> instance.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TChat</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynChat</c> type extends the <c>TAsynParams&lt;TChat&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynChat = TAsynCallBack<TChat>;

  /// <summary>
  /// Represents a promise-based callback for an asynchronous chat operation.
  /// </summary>
  /// <remarks>
  /// The <c>TPromiseChat</c> alias extends <see cref="TPromiseCallBack&lt;TChat&gt;"/>
  /// to provide a promise-style API for chat completions, yielding a <see cref="TChat"/>
  /// instance when the operation succeeds or raising an exception on failure.
  /// </remarks>
  TPromiseChat = TPromiseCallBack<TChat>;

  /// <summary>
  /// Manages asynchronous streaming chat callBacks for a chat request using <c>TChat</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynChatStream</c> type extends the <c>TAsynStreamParams&lt;TChat&gt;</c> record to support the lifecycle of an asynchronous streaming chat operation.
  /// It provides callbacks for different stages, including when the operation starts, progresses with new data chunks, completes successfully, or encounters an error.
  /// This structure is ideal for handling scenarios where the chat response is streamed incrementally, providing real-time updates to the user interface.
  /// </remarks>
  TAsynChatStream = TAsynStreamCallBack<TChat>;

  /// <summary>
  /// Represents a promise-based callback for streaming chat operations.
  /// </summary>
  /// <remarks>
  /// The <c>TPromiseChatStream</c> alias extends <see cref="TPromiseStreamCallBack&lt;TChat&gt;"/>
  /// to provide a promise-style API for streaming chat completions, delivering incremental <see cref="TChat"/>
  /// updates until the stream finishes or an error is encountered.
  /// </remarks>
  TPromiseChatStream = TPromiseStreamCallBack<TChat>;

  /// <summary>
  /// Represents a callback procedure used during the reception of responses from a chat request in streaming mode.
  /// </summary>
  /// <param name="Chat">
  /// The <c>TChat</c> object containing the current information about the response generated by the model.
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
  /// and the <c>Chat</c> parameter will be <c>nil</c>.
  /// </remarks>
  TChatEvent = reference to procedure(var Chat: TChat; IsDone: Boolean; var Cancel: Boolean);

  /// <summary>
  /// Provides methods to manage and execute chat operations with AI models.
  /// </summary>
  /// <remarks>
  /// The <c>TChatRoute</c> class extends <c>TDeepseekAPIRoute</c> and offers
  /// functionality for synchronous and asynchronous interactions with AI chat models.
  /// It supports:
  /// <para>- Creating chat completions.</para>
  /// <para>- Streaming chat completions for real-time updates.</para>
  /// <para>- Managing callbacks for progress, success, and error handling during asynchronous operations.</para>
  /// <para>
  /// This class is designed to provide seamless integration with the Deepseek API,
  /// allowing for flexible and efficient chat-based interactions in applications.
  /// </para>
  /// </remarks>
  TChatRoute = class(TDeepseekAPIRoute)
    /// <summary>
    /// Initiates an asynchronous chat completion and returns a promise for the result.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the chat parameters (model, messages, etc.) before sending the request.
    /// </param>
    /// <param name="CallBacks">
    /// An optional function that provides a <see cref="TPromiseChat"/> record for hooking into lifecycle events.
    /// </param>
    /// <returns>
    /// A <see cref="TPromise&lt;TChat&gt;"/> that resolves with the completed <see cref="TChat"/> response or rejects on error.
    /// </returns>
    /// <remarks>
    /// This method wraps the callback-based <see cref="AsynCreate"/> in a promise interface, enabling async/await usage.
    /// If <paramref name="CallBacks"/> is omitted, only the promise resolution is available.
    /// </remarks>
    function AsyncAwaitCreate(const ParamProc: TProc<TChatParams>;
      const CallBacks: TFunc<TPromiseChat> = nil): TPromise<TChat>;

    /// <summary>
    /// Initiates an asynchronous streaming chat completion and returns a promise for the streaming buffer.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the streaming chat parameters (model, messages, stream options, etc.).
    /// </param>
    /// <param name="CallBacks">
    /// A function that provides a <see cref="TPromiseChatStream"/> record for handling streaming lifecycle events.
    /// </param>
    /// <returns>
    /// A <see cref="TPromise&lt;TPromiseBuffer&gt;"/> that resolves with a <see cref="TPromiseBuffer"/>
    /// containing accumulated content and reasoning once the stream completes, or rejects on error.
    /// </returns>
    /// <remarks>
    /// <para>This method wraps the callback-based <see cref="AsynCreateStream"/> in a promise interface,
    /// enabling async/await usage for streaming scenarios.</para>
    /// <para>If you omit <paramref name="CallBacks"/>, you can still await the returned promise to get the final buffer.</para>
    /// </remarks>
    function AsyncAwaitCreateStream(
      const ParamProc: TProc<TChatParams>;
      const CallBacks: TFunc<TPromiseChatStream>): TPromise<TPromiseBuffer>;

    /// <summary>
    /// Initiates parallel processing of multiple chat prompts and returns a promise for the bundled results.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the bundle parameters (model, prompts, reasoning effort, etc.) before dispatch.
    /// </param>
    /// <param name="CallBacks">
    /// An optional function that provides a <see cref="TPromiseBundleList"/> record for hooking into lifecycle events.
    /// </param>
    /// <returns>
    /// A <see cref="TPromise&lt;TBundleList&gt;"/> that resolves with a <see cref="TBundleList"/> containing all responses
    /// once every parallel task completes, or rejects on the first error.
    /// </returns>
    /// <remarks>
    /// This method wraps the callback-based <see cref="CreateParallel"/> in a promise interface, enabling async/await usage
    /// for parallel prompt execution. If <paramref name="CallBacks"/> is omitted, only the promise resolution is available.
    /// </remarks>
    function AsyncAwaitParallel(const ParamProc: TProc<TBundleParams>;
      const CallBacks: TFunc<TPromiseBundleList> = nil): TPromise<TBundleList>;

    /// <summary>
    /// Creates a completion for the chat message using the provided parameters.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure used to configure the parameters for the chat request, such as selecting the model,
    /// providing messages, setting token limits, etc.
    /// </param>
    /// <returns>
    /// Returns a <c>TChat</c> object that contains the chat response, including the choices generated by the model.
    /// </returns>
    /// <remarks>
    /// The <c>Create</c> method sends a chat completion request and waits for the full response.
    /// The returned <c>TChat</c> object contains the model's generated response, including multiple
    /// choices if available.
    /// <code>
    /// //var DeepSeek := TDeepseekFactory.CreateInstance(BarearKey);
    /// var Chat := DeepSeek.Chat.Create(
    ///     procedure (Params: TChatParams)
    ///     begin
    ///       // Define chat parameters
    ///     end);
    ///   try
    ///     // Handle the Chat
    ///   finally
    ///     Chat.Free;
    ///   end;
    /// </code>
    /// </remarks>
    function Create(const ParamProc: TProc<TChatParams>): TChat;

    /// <summary>
    /// Creates a chat message completion with a streamed response.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure used to configure the parameters for the chat request, such as selecting the model, providing messages, and adjusting other settings like token limits or temperature.
    /// </param>
    /// <param name="Event">
    /// A callback of type <c>TChatEvent</c> that is triggered with each chunk of data received during the streaming process. It includes the current state of the <c>TChat</c> object, a flag indicating if the stream is done, and a boolean to handle cancellation.
    /// </param>
    /// <returns>
    /// Returns <c>True</c> if the streaming process started successfully, <c>False</c> otherwise.
    /// </returns>
    /// <remarks>
    /// This method initiates a chat request in streaming mode, where the response is delivered incrementally in real-time.
    /// The <c>Event</c> callback will be invoked multiple times as tokens are received.
    /// When the response is complete, the <c>IsDone</c> flag will be set to <c>True</c>, and the <c>Chat</c> object will be <c>nil</c>.
    /// The streaming process can be interrupted by setting the <c>Cancel</c> flag to <c>True</c> within the event.
    /// <code>
    /// //var DeepSeek := TDeepseekFactory.CreateInstance(BarearKey);
    ///   DeepSeek.Chat.CreateStream(
    ///     procedure (Params: TChatParams)
    ///     begin
    ///       // Define chat parameters
    ///     end,
    ///
    ///     procedure(var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
    ///     begin
    ///       // Handle displaying
    ///     end);
    /// </code>
    /// </remarks>
    function CreateStream(const ParamProc: TProc<TChatParams>; const Event: TChatEvent): Boolean;

    /// <summary>
    /// Initiates parallel processing of chat prompts by creating multiple chat completions
    /// asynchronously, with results stored in a bundle and provided back to the callback function.
    /// This method allows for parallel processing of multiple prompts in an efficient manner,
    /// handling errors and successes for each chat completion.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure delegate that configures the parameters for the bundle. It is responsible
    /// for providing the necessary settings (such as model and reasoning effort) for the chat completions.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns an instance of TAsynBuffer, which manages the lifecycle of the
    /// asynchronous operation. The callbacks include handlers for start, error, and success events.
    /// </param>
    /// <remarks>
    /// The method allows for efficient parallel processing of multiple prompts by delegating
    /// individual tasks to separate threads. It each task's result is properly bundled and communicated back to the caller.
    /// If an error occurs, the error handling callback will be triggered, and the rest of the tasks
    /// will continue processing. The success callback is triggered once all tasks are completed.
    /// </remarks>
    procedure CreateParallel(const ParamProc: TProc<TBundleParams>;
      const CallBacks: TFunc<TAsynBundleList>);

    /// <summary>
    /// Create an asynchronous completion for chat message
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the parameters for the chat request, such as model selection, messages, and other parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns a record containing event handlers for the asynchronous chat completion, such as on success and on error.
    /// </param>
    /// <remarks>
    /// This procedure initiates an asynchronous request to generate a chat completion based on the provided parameters. The response or error is handled by the provided callBacks.
    /// <code>
    /// //var DeepSeek := TDeepseekFactory.CreateInstance(BarearKey);
    /// DeepSeek.Chat.AsyncCreate(
    ///   procedure (Params: TChatParams)
    ///   begin
    ///     // Define chat parameters
    ///   end,
    ///   function: TAsynChat
    ///   begin
    ///     Result.Sender := My_component;  // Instance passed to callback parameter
    ///
    ///     Result.OnStart := nil;   // If nil then; Can be omitted
    ///
    ///     Result.OnSuccess := procedure (Sender: TObject; Chat: TChat)
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
    procedure AsynCreate(const ParamProc: TProc<TChatParams>;
      const CallBacks: TFunc<TAsynChat>);

    /// <summary>
    /// Creates an asynchronous streaming chat completion request.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure used to configure the parameters for the chat request, including the model, messages, and additional options such as max tokens and streaming mode.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns a <c>TAsynChatStream</c> record which contains event handlers for managing different stages of the streaming process: progress updates, success, errors, and cancellation.
    /// </param>
    /// <remarks>
    /// This procedure initiates an asynchronous chat operation in streaming mode, where tokens are progressively received and processed.
    /// The provided event handlers allow for handling progress (i.e., receiving tokens in real time), detecting success, managing errors, and enabling cancellation logic.
    /// <code>
    /// //var DeepSeek := TDeepseekFactory.CreateInstance(BarearKey);
    /// DeepSeek.Chat.AsyncCreateStream(
    ///   procedure(Params: TChatParams)
    ///   begin
    ///     // Define chat parameters
    ///     Params.Stream;
    ///   end,
    ///
    ///   function: TAsynChatStream
    ///   begin
    ///     Result.Sender := Memo1; // Instance passed to callback parameter
    ///     Result.OnProgress :=
    ///         procedure (Sender: TObject; Chat: TChat)
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
    procedure AsynCreateStream(const ParamProc: TProc<TChatParams>;
      const CallBacks: TFunc<TAsynChatStream>);
  end;

implementation

uses
  Rest.Json;

{ TContentParams }

class function TContentParams.Assistant(const Content: string;
  const Prefix: Boolean): TContentParams;
begin
  Result := TContentParams.Create.Role(TMessageRole.assistant).Content(Content);
  if Prefix then
    Result := Result.Prefix(Prefix);
end;

class function TContentParams.Assistant(const Content, Name: string;
  const Prefix: Boolean): TContentParams;
begin
  Result := Assistant(Content, Prefix).Name(Name);
end;

function TContentParams.Content(const Value: TJSONArray): TContentParams;
begin
  Result := TContentParams(Add('content', Value));
end;

function TContentParams.Content(const Value: string): TContentParams;
begin
  Result := TContentParams(Add('content', Value));
end;

function TContentParams.Name(const Value: string): TContentParams;
begin
  Result := TContentParams(Add('name', Value));
end;

function TContentParams.Prefix(const Value: Boolean): TContentParams;
begin
  Result := TContentParams(Add('prefix', Value));
end;

function TContentParams.ReasoningContent(const Value: string): TContentParams;
begin
  Result := TContentParams(Add('reasoning_content', Value));
end;

function TContentParams.Role(const Value: string): TContentParams;
begin
  Result := TContentParams(Add('role', TMessageRole.Create(Value).ToString));
end;

function TContentParams.Role(const Value: TMessageRole): TContentParams;
begin
  Result := TContentParams(Add('role', Value.ToString));
end;

class function TContentParams.System(const Content: string;
  const Name: string): TContentParams;
begin
  Result := TContentParams.Create.Role(TMessageRole.system).Content(Content);
  if not Name.IsEmpty then
    Result := Result.Name(Name);
end;

class function TContentParams.User(const Content: string;
  const Name: string): TContentParams;
begin
  Result := TContentParams.Create.Role(TMessageRole.user).Content(Content);
  if not Name.IsEmpty then
    Result := Result.Name(Name);
end;

{ TChatParams }

function TChatParams.FrequencyPenalty(const Value: Double): TChatParams;
begin
  Result := TChatParams(Add('frequency_penalty', Value));
end;

function TChatParams.Logprobs(const Value: Boolean): TChatParams;
begin
  Result := TChatParams(Add('logprobs', Value));
end;

function TChatParams.MaxTokens(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('max_tokens', Value));
end;

function TChatParams.Messages(const Value: TArray<TJSONParam>): TChatParams;
begin
  Result := TChatParams(Add('messages', Value));
end;

function TChatParams.Model(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('model', Value));
end;

function TChatParams.PresencePenalty(const Value: Double): TChatParams;
begin
  Result := TChatParams(Add('presence_penalty', Value));
end;

function TChatParams.ResponseFormat(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('response_format', TJSONObject.Create.AddPair('type', TResponseFormat.Create(Value).ToString)));
end;

function TChatParams.ResponseFormat(
  const Value: TResponseFormat): TChatParams;
begin
  Result := TChatParams(Add('response_format', TJSONObject.Create.AddPair('type', Value.ToString)));
end;

function TChatParams.Stop(const Value: TArray<string>): TChatParams;
begin
  Result := TChatParams(Add('stop', Value));
end;

function TChatParams.Stop(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('stop', Value));
end;

function TChatParams.Stream(const Value: Boolean): TChatParams;
begin
  Result := TChatParams(Add('stream', Value));
end;

function TChatParams.StreamOptions(const Value: Boolean): TChatParams;
begin
  if Value then
    Result := TChatParams(Add('stream_options', TJSONObject.Create.AddPair('include_usage', True) )) else
    Result := Self;
end;

function TChatParams.Temperature(const Value: Double): TChatParams;
begin
  Result := TChatParams(Add('temperature', Value));
end;

function TChatParams.ToolChoice(const Value: TToolChoice): TChatParams;
begin
  Result := TChatParams(Add('tool_choice', Value.ToString));
end;

function TChatParams.ToolChoice(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('tool_choice', TToolChoice.Create(Value).ToString));
end;

function TChatParams.Tools(const Value: TArray<IFunctionCore>): TChatParams;
var
  Arr: TArray<TChatMessageTool>;
begin
  for var Item in Value do
    Arr := Arr + [TChatMessageTool.Add(Item)];
  Result := Tools(Arr);
end;

function TChatParams.Tools(const Value: TArray<TChatMessageTool>): TChatParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.ToJson);
  Result := TChatParams(Add('tools', JSONArray));
end;

function TChatParams.TopLogprobs(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('top_logprobs', Value));
end;

function TChatParams.TopP(const Value: Double): TChatParams;
begin
  Result := TChatParams(Add('top_p', Value));
end;

{ TChatRoute }

function TChatRoute.AsyncAwaitCreate(const ParamProc: TProc<TChatParams>;
  const CallBacks: TFunc<TPromiseChat>): TPromise<TChat>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TChat>(
    procedure(const CallBackParams: TFunc<TAsynChat>)
    begin
      AsynCreate(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TChatRoute.AsyncAwaitCreateStream(const ParamProc: TProc<TChatParams>;
  const CallBacks: TFunc<TPromiseChatStream>): TPromise<TPromiseBuffer>;
var
  Buffer: TPromiseBuffer;
begin
  Result := TPromise<TPromiseBuffer>.Create(
    procedure(Resolve: TProc<TPromiseBuffer>; Reject: TProc<Exception>)
    begin
      AsynCreateStream(ParamProc,
        function : TAsynChatStream
        begin
          Result.Sender := CallBacks.Sender;

          Result.OnStart := CallBacks.OnStart;

          Result.OnProgress :=
            procedure (Sender: TObject; Event: TChat)
            begin
              if Assigned(CallBacks.OnProgress) then
                CallBacks.OnProgress(Sender, Event);
              for var Item in Event.Choices do
                begin
                  Buffer.Content := Buffer.Content + Item.Delta.Content;
                  Buffer.Reasoning := Buffer.Reasoning + Item.Delta.FReasoningContent;
                end;
            end;

          Result.OnSuccess :=
            procedure (Sender: TObject)
            begin
              if Assigned(CallBacks.OnSuccess) then
                CallBacks.OnSuccess(Sender);
              Resolve(Buffer);
            end;

          Result.OnError :=
            procedure (Sender: TObject; Error: string)
            begin
              if Assigned(CallBacks.OnError) then
                Error := CallBacks.OnError(Sender, Error);
              Reject(Exception.Create(Error));
            end;

          Result.OnDoCancel :=
            function : Boolean
            begin
              if Assigned(CallBacks.OnDoCancel) then
                Result := CallBacks.OnDoCancel()
              else
                Result := False;
            end;

          Result.OnCancellation :=
            procedure (Sender: TObject)
            begin
              var Error := 'aborted';
              if Assigned(CallBacks.OnCancellation) then
                Error := CallBacks.OnCancellation(Sender);
              Reject(Exception.Create(Error));
            end;
        end);
    end);
end;

function TChatRoute.AsyncAwaitParallel(const ParamProc: TProc<TBundleParams>;
  const CallBacks: TFunc<TPromiseBundleList>): TPromise<TBundleList>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TBundleList>(
    procedure(const CallBackParams: TFunc<TAsynBundleList>)
    begin
      CreateParallel(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

procedure TChatRoute.AsynCreate(const ParamProc: TProc<TChatParams>;
  const CallBacks: TFunc<TAsynChat>);
begin
  with TAsynCallBackExec<TAsynChat, TChat>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TChat
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TChatRoute.AsynCreateStream(const ParamProc: TProc<TChatParams>;
  const CallBacks: TFunc<TAsynChatStream>);
begin
var CallBackParams := TUseParamsFactory<TAsynChatStream>.CreateInstance(CallBacks);

  var Sender := CallBackParams.Param.Sender;
  var OnStart := CallBackParams.Param.OnStart;
  var OnSuccess := CallBackParams.Param.OnSuccess;
  var OnProgress := CallBackParams.Param.OnProgress;
  var OnError := CallBackParams.Param.OnError;
  var OnCancellation := CallBackParams.Param.OnCancellation;
  var OnDoCancel := CallBackParams.Param.OnDoCancel;
  var CancelTag := 0;

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
                procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
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
                      if (CancelTag = 0) and Assigned(OnCancellation) then
                        TThread.Queue(nil,
                        procedure
                        begin
                          OnCancellation(Sender);
                        end);
                      Inc(CancelTag);
                      Cancel := True;
                      Exit;
                    end;
                  if not IsDone and Assigned(Chat) then
                    begin
                      var LocalChat := Chat;
                      Chat := nil;

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

function TChatRoute.Create(const ParamProc: TProc<TChatParams>): TChat;
begin
  Result := API.Post<TChat, TChatParams>('chat/completions', ParamProc);
end;

procedure TChatRoute.CreateParallel(const ParamProc: TProc<TBundleParams>;
  const CallBacks: TFunc<TAsynBundleList>);
var
  Tasks: TArray<ITask>;
  BundleParams: TBundleParams;
begin
  BundleParams := TBundleParams.Create;
  try
    if not Assigned(ParamProc) then
      raise Exception.Create('The lambda can''t be null');

    ParamProc(BundleParams);
    var Bundle := TBundleList.Create;
    var Ranking := 0;
    var ErrorExists := False;
    var Prompts := BundleParams.GetPrompt;
    var Counter := Length(Prompts);

    if Assigned(CallBacks.OnStart) then
      CallBacks.OnStart(CallBacks.Sender);

    SetLength(Tasks, Length(Prompts));
    for var index := 0 to Pred(Length(Prompts)) do
      begin
        Tasks[index] := TTask.Run(
          procedure
          begin
            var Buffer := Bundle.Add(index + 1);
            Buffer.Prompt := Prompts[index];
            try
              var Chat := Create(
                procedure (Params: TChatParams)
                begin
                  {--- Set the model for the process }
                  Params.Model(BundleParams.GetModel);

                  {--- Set the current prompt and developer message }
                  Params.Messages([
                    TContentParams.System(BundleParams.GetSystem),
                    TContentParams.User(Buffer.Prompt)
                  ]);
                end);
              Inc(Ranking);
              Buffer.FinishIndex := Ranking;
              Buffer.Response := Chat.Choices[0].Message.Content;
              Buffer.Chat := Chat;
            except
              on E: Exception do
                begin
                  {--- Catch the exception }
                  var Error := AcquireExceptionObject;
                  ErrorExists := True;
                  try
                    var ErrorMsg := (Error as Exception).Message;
                    {--- Trigger OnError callback if the process has failed }
                    if Assigned(CallBacks.OnError) then
                      TThread.Queue(nil,
                      procedure
                      begin
                        CallBacks.OnError(CallBacks.Sender, ErrorMsg);
                      end);
                  finally
                    {--- Ensures that the instance of the caught exception is released}
                    Error.Free;
                  end;
                end;
            end;
          end);

        if ErrorExists then
          Continue;

        {--- TTask.WaitForAll is not used due to a memory leak in TLightweightEvent/TCompleteEventsWrapper.
             See report RSP-12462 and RSP-25999. }
        TTaskHelper.ContinueWith(Tasks[Index],
          procedure
          begin
            Dec(Counter);
            if Counter = 0 then
              begin
                try
                  if not ErrorExists and Assigned(CallBacks.OnSuccess) then
                    CallBacks.OnSuccess(CallBacks.Sender, Bundle);
                finally
                  Bundle.Free;
                end;
              end;
          end);
        {--- Need a delay, otherwise the process runs only with the first task. }
        Sleep(30);
      end;
  finally
    BundleParams.Free;
  end;
end;

function TChatRoute.CreateStream(const ParamProc: TProc<TChatParams>;
  const Event: TChatEvent): Boolean;
var
  Response: TStringStream;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Result := API.Post<TChatParams>('chat/completions', ParamProc, Response,
      procedure(const Sender: TObject; AContentLength, AReadCount: Int64; var AAbort: Boolean)
      var
        TextBuffer  : string;
        BufferPos   : Integer;
        PosLineEnd  : Integer;
        Line, Data  : string;
        Chat        : TChat;
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
              Chat := TDeepseekAPI.Parse<TChat>(Data);
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

{ TChat }

destructor TChat.Destroy;
begin
  for var Item in FChoices do
    Item.Free;
  if Assigned(FUsage) then
    FUsage.Free;
  inherited;
end;

{ TChatChoice }

destructor TChatChoice.Destroy;
begin
  if Assigned(FMessage) then
    FMessage.Free;
  if Assigned(FLogprobs) then
    FLogprobs.Free;
  if Assigned(FDelta) then
    FDelta.Free;
  inherited;
end;

{ TToolCalls }

destructor TToolCalls.Destroy;
begin
  if Assigned(FFunction) then
    FFunction.Free;
  inherited;
end;

{ TChoiceMessage }

destructor TChoiceMessage.Destroy;
begin
  for var Item in FToolCalls do
    Item.Free;
  inherited;
end;

{ TLogprobs }

destructor TLogprobs.Destroy;
begin
  for var Item in FContent do
    Item.Free;
  inherited;
end;

{ TLogprobContent }

destructor TLogprobContent.Destroy;
begin
  for var Item in FTopLogprobs do
    Item.Free;
  inherited;
end;

end.
