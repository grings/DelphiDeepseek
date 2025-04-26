# Delphi Deepseek

___
![GitHub](https://img.shields.io/badge/IDE%20Version-Delphi%2010.3/11/12-yellow)
![GitHub](https://img.shields.io/badge/platform-all%20platforms-green)
![GitHub](https://img.shields.io/badge/Updated%20on%20april%2026,%202025-blue)

<br/>

NEW: 
- [Changelog](https://github.com/MaxiDonkey/DelphiDeepseek/blob/main/Changelog.md)
- [Deepseek-reasoner](#deepseek-reasoner)
- [Parallel method for generating text](#parallel-method-for-generating-text)
- [Multiple queries with chaining](#multiple-queries-with-chaining)
- [Tips and tricks](#tips-and-tricks)
___

- [Introduction](#introduction)
- [Remarks](#remarks)
- [Wrapper Tools Info](#wrapper-tools-info)
    - [Tools for simplifying this tutorial](#tools-for-simplifying-this-tutorial)
    - [Asynchronous callback mode management](#asynchronous-callback-mode-management)
    - [Simplified Unit Declaration](#simplified-unit-declaration) 
- [Usage](#usage)
    - [Initialization](#initialization)
    - [Deepseek Models Overview](#deepseek-models-overview)
    - [Chats](#chats)
        - [Create a message](#create-a-message)
        - [Streaming messages](#streaming-messages)
        - [Multi-turn conversation](#multi-turn-conversation)
        - [Deepseek-reasoner](#deepseek-reasoner)
        - [Parallel method for generating text](#parallel-method-for-generating-text)
        - [Multiple queries with chaining](#multiple-queries-with-chaining)
    - [Function calling](#function-calling)
        - [Use case](#use-case)
    - [JSON Output](#json-output)
    - [Context Caching](#context-caching)
    - [Get user balance](#get-user-balance)
- [Beta version](#beta-version)
    - [FIM Completion](#fim-completion)
        - [Completion](#completion)
        - [Streamed completion](#streamed-completion)
    - [Chat prefix completion](#chat-prefix-completion)
- [Tips and tricks](#tips-and-tricks)
- [Contributing](#contributing)
- [License](#license)

<br/>
<br/>

# Introduction

Founded in 2023, Deepseek provides two language models with automatic caching. Developed in China, this technology is influenced by a specific cultural and regulatory framework, shaping its priorities and development choices. While its scope of application is still evolving, Deepseek offers an option for Delphi developers looking to experiment with AI tools.

This unofficial wrapper aims to simplify the integration of Deepseek APIs into Delphi projects. It provides a practical way for developers to explore and test these models, whether for natural language processing, conversational assistants, or other targeted use cases. The library enables quick experimentation while leveraging Delphi’s familiar environment.

This wrapper is primarily intended for exploratory purposes. It provides users with a tool to assess whether Deepseek meets their specific needs and to integrate it into their projects if deemed suitable.

<br/>

# Remarks

> [!IMPORTANT]
>
> This is an unofficial library. **Deepseek** does not provide any official library for `Delphi`.
> This repository contains `Delphi` implementation over [Deepseek](https://api-docs.deepseek.com/) public API.

<br/>

# Wrapper Tools Info

This section offers concise notifications and explanations about the tools designed to streamline the presentation and clarify the wrapper's functions throughout the tutorial.

<br/>

## Tools for simplifying this tutorial

To streamline the code examples provided in this tutorial and facilitate quick implementation, two units have been included in the source code: `Deepseek.Tutorial.VCL` and `Deepseek.Tutorial.FMX`. Depending on the platform you choose to test the provided source code, you will need to instantiate either the `TVCLTutorialHub` or `TFMXTutorialHub` class in the application's OnCreate event, as demonstrated below:

>[!TIP]
>```Pascal
> //uses Deepseek.Tutorial.VCL;
> TutorialHub := TVCLTutorialHub.Create(Deepseek, Memo1, Memo2, Memo3, Memo4, Button2);
>```

or

>[!TIP]
>```Pascal
> //uses Deepseek.Tutorial.FMX;
> TutorialHub := TFMXTutorialHub.Create(Deepseek, Memo1, Memo2, Memo3, Memo4, Button2);
>```

Make sure to add a three `TMemo`, a `TButton` component to your form beforehand and Deepseek then client ([see bellow.](#initialization)) 

The `TButton` will allow the interruption of any streamed reception.

<br/>

## Asynchronous callback mode management

In the context of asynchronous methods, for a method that does not involve streaming, callbacks use the following generic record: `TAsynCallBack<T> = record` defined in the `Deepseek.Async.Support.pas` unit. This record exposes the following properties:

```Pascal
   TAsynCallBack<T> = record
   ... 
       Sender: TObject;
       OnStart: TProc<TObject>;
       OnSuccess: TProc<TObject, T>;
       OnError: TProc<TObject, string>; 
```
<br/>

For methods requiring streaming, callbacks use the generic record `TAsynStreamCallBack<T> = record`, also defined in the `Deepseek.Async.Support.pas` unit. This record exposes the following properties:

```Pascal
   TAsynCallBack<T> = record
   ... 
       Sender: TObject;
       OnStart: TProc<TObject>;
       OnProgress: TProc<TObject, T>;
       OnSuccess: TProc<TObject, T>;
       OnError: TProc<TObject, string>;
       OnCancellation: TProc<TObject>;
       OnDoCancel: TFunc<Boolean>;
```

The name of each property is self-explanatory; if needed, refer to the internal documentation for more details.

<br>

>[!NOTE]
> All methods managed by the wrapper are designed to support both synchronous and asynchronous execution modes. This dual-mode functionality ensures greater flexibility for users, allowing them to choose the approach that best suits their application's requirements and workflow.

<br/>

## Simplified Unit Declaration

To streamline the use of the API wrapper, the process for declaring units has been simplified. Regardless of the methods being utilized, you only need to reference the following two core units:

```Pascal
  uses
    Deepseek, Deepseek.Types;
```

If required, you may also include the `Deepseek.Schema` unit or any plugin units developed for specific function calls (e.g., `Deepseek.Functions.Example`). This simplification ensures a more intuitive and efficient integration process for developers.

<br/>

# Usage

## Initialization

To initialize the API instance, you need to [obtain an API key from Deepseek](https://platform.deepseek.com/api_keys).

Once you have a token, you can initialize `IDeepseek` interface, which is an entry point to the API.


> [!NOTE]
>```Pascal
>uses Deepseek;
>
>var Deepseek := TDeepseek.CreateInstance(API_KEY);
>var DeepseekBeta := TDeepseekFactory.CreateBetaInstance(API_KEY); 
>```

The DeepseekBeta client must be used to access APIs that are currently provided in beta version.

>[!Warning]
> To effectively use the examples in this tutorial, particularly when working with asynchronous methods, it is recommended to define the Deepseek and DeepseekBeta interfaces with the broadest possible scope. For optimal implementation, these clients should be declared in the application's OnCreate method.

<br/>

## Deepseek Models Overview

Two models are currently available:
- [deepseek-chat](https://huggingface.co/deepseek-ai/deepseek-llm-67b-chat) 
- [deepseek-coder](https://deepseekcoder.github.io/). et sur [HuggingFace](https://huggingface.co/deepseek-ai) 

Regarding the APIs, only version 3 appears to be available, although the documentation lacks clarity on this point.

To retrieve the list of available models, you can use the following code example:

```Pascal
// uses Deepseek, Deepseek.Types, Deepseek.Tutorial.VCL;

  TutorialHub.Clear;

  //Asynchronous example
  DeepSeek.Models.AsynList(
    function : TAsynModels
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := DeepSeek.Models.List;
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

## Chats

You can send a structured list of input messages containing only text content, and the model will generate the next message in the conversation.

The Messages API can be used for both single-turn requests and multi-turn, stateless conversations.

### Create a message

```Pascal
// uses Deepseek, Deepseek.Types, Deepseek.Tutorial.VCL;

  TutorialHub.Clear;
  Deepseek.ClientHttp.ResponseTimeout := 120000;

  //Asynchronous example
  DeepSeek.Chat.AsynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('deepseek-chat');
      Params.Messages([
        FromUser('What is the capital of France, and then the capital of champagne?')
      ]);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := DeepSeek.Chat.Create(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('deepseek-chat');
//      Params.Messages([
//        FromUser('What is the capital of France, and then the capital of champagne?')
//      ]);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

### Streaming messages

When generating a Message, you can enable `"stream": true` to progressively receive the response through server-sent events (SSE).

```Pascal
// uses Deepseek, Deepseek.Types, Deepseek.Tutorial.VCL;

  TutorialHub.Clear;
  
  //Asynchronous example
  DeepSeek.Chat.ASynCreateStream(
    procedure (Params: TChatParams)
    begin
      Params.Model('deepseek-chat');
      Params.Messages([
        FromUser('Are there accumulation points in a discrete topology?')
      ]);
      Params.MaxTokens(1024);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  DeepSeek.Chat.CreateStream(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('deepseek-chat');
//      Params.Messages([
//        FromUser('Are there accumulation points in a discrete topology?')
//      ]);
//      Params.MaxTokens(1024);
//      Params.Stream;
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
//    begin
//      if Assigned(Chat) and not IsDone then
//        DisplayStream(TutorialHub, Chat);
//    end);
```

<br/>

### Multi-turn conversation

The `Deepseek API` enables the creation of interactive chat experiences tailored to your users' needs. Its chat functionality supports multiple rounds of questions and answers, allowing users to gradually work toward solutions or receive help with complex, multi-step issues. This capability is especially useful for applications requiring ongoing interaction, such as:
- **Chatbots**
- **Educational tools**
- **Customer support assistants.**

Refer to the [official documentation](https://api-docs.deepseek.com/guides/multi_round_chat)

```Pascal
// uses Deepseek, Deepseek.Types, Deepseek.Tutorial.VCL;

  TutorialHub.Clear;

  //Asynchronous example
  DeepSeek.Chat.ASynCreateStream(
    procedure (Params: TChatParams)
    begin
      Params.Model('deepseek-chat');
      Params.Messages([
        FromSystem('You are a funny domestic assistant.'),
        FromUser('Hello'),
        FromAssistant('Great to meet you. What would you like to know?'),
        FromUser('I have two dogs in my house. How many paws are in my house?')
      ]);
      Params.MaxTokens(1024);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  DeepSeek.Chat.CreateStream(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('deepseek-chat');
//      Params.Messages([
//        FromSystem('You are a funny domestic assistant.'),
//        FromUser('Hello'),
//        FromAssistant('Great to meet you. What would you like to know?'),
//        FromUser('I have two dogs in my house. How many paws are in my house?')
//      ]);
//      Params.MaxTokens(1024);
//      Params.Stream;
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
//    begin
//      if Assigned(Chat) and not IsDone then
//        DisplayStream(TutorialHub, Chat);
//    end);
```

<br/>

### Deepseek-reasoner

Since January 25, 2025, Deepseek has released a new model called `deepseek-reasoner`, designed to provide advanced reasoning capabilities similar to `OpenAI's O1` model.

Please refer to the [dedicated page](https://api-docs.deepseek.com/guides/reasoning_model) on the official website.

>[!WARNING]
>**Important Note:** This model does not support *function calls, JSON-formatted outputs, or the fill-in-the-middle (FIM) method*.
> The parameter to control the CoT length (reasoning_effort) will be available soon.

**Unsupported parameters:**
- *temperature, top_p, presence_penalty, frequency_penalty, logprobs, top_logprobs.*

To ensure compatibility with existing software, using *temperature, top_p, presence_penalty, and frequency_penalty* will not trigger an error but will have no effect on the model. However, using logprobs and top_logprobs will result in an error.

>[!TIP]
> This model is accessible through the APIs available in this wrapper. However, due to the processing time required for its reasoning methods, it is recommended to use asynchronous approaches to prevent potential application blocking.
>

```Pascal
// uses Deepseek, Deepseek.Types, Deepseek.Tutorial.VCL;

  TutorialHub.Clear;

  //Asynchronous example
  DeepSeek.Chat.ASynCreateStream(
    procedure (Params: TChatParams)
    begin
      Params.Model('deepseek-reasoner');
      Params.Messages([
        FromUser('What does the ability to reason bring to language models?')
      ]);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);
```

In the sample code provided with the DisplayStream method, you can see how to handle the reasoning portion separately from the final response generation:

```Delphi
procedure DisplayStream(Sender: TObject; Value: TChat);
begin
  if Assigned(Value) then
    begin
      DisplayChunk(Value);
      if not Value.Choices[0].Delta.ReasoningContent.IsEmpty then
        {--- Display reasoning chunk }
        DisplayStream(TutorialHub.Reasoning, Value.Choices[0].Delta.ReasoningContent)
      else
        {--- Display responses chunk }
        DisplayStream(Sender, Value.Choices[0].Delta.Content.Replace('\n', #10));
    end;
end;  
```


![Preview](/../main/images/ReasoningStream.png?raw=true "Preview")


<br/>

### Parallel method for generating text

This approach enables the simultaneous execution of multiple prompts, provided they are all processed by the same model.

#### Example 1 : Two prompts processed in parallel.


```Pascal
// uses Deepseek, Deepseek.Types, Deepseek.Tutorial.VCL;

  TutorialHub.Clear;

  DeepSeek.Chat.CreateParallel(
    procedure (Params: TBundleParams)
    begin
      Params.Prompts([
        'How many television channels were there in France in 1980?',
        'How many TV channels were there in Germany in 1980?.'
      ]);
      Params.System('Write the response in capital letters.');
      Params.Model('deepseek-chat');
    end,
    function : TAsynBundleList
    begin
      Result.Sender := TutorialHub;

      Result.OnStart :=
        procedure (Sender: TObject)
        begin
          Display(Sender, 'Start the job' + sLineBreak);
        end;

      Result.OnSuccess :=
        procedure (Sender: TObject; Bundle: TBundleList)
        begin
          // Background bundle processing
          for var Item in Bundle.Items do
            begin
              Display(Sender, 'Index : ' + Item.Index.ToString);
              Display(Sender, 'FinishIndex : ' + Item.FinishIndex.ToString);
              Display(Sender, Item.Prompt + sLineBreak);
              Display(Sender, Item.Response + sLineBreak + sLineBreak);
              // or Display(Sender, TChat(Item.Chat).Choices[0].Message.Content);
            end;
        end;

      Result.OnError := Display;
    end)
```

Result

![Preview](/../main/images/Parallel.png?raw=true "Preview")

<br>

### Multiple queries with chaining

In some cases, you need to chain multiple requests so that each step’s output feeds into the next. The Promise pattern is ideal for orchestrating this kind of workflow: it lets you build complex processing that a single prompt—no matter how sophisticated—couldn’t achieve on its own.
 
**Implementation:** <br>
- Be sure to include the `Deepseek.Async.Promise` unit in your `uses` clause.
- Each Promise runs asynchronously and non-blockingly in the background, freeing the main thread for other operations.

#### Process

We’ll use a simple, educational scenario with three steps:

 1. Send a prompt to the deepseek-chat model.

 2. Process the received response to extract and reformat the relevant information.

 3. Generate the next prompt from the enriched result.

This minimal example is designed to help you get comfortable with asynchronous execution and promise chaining. You can then customize each step to suit your specific business needs.

<br>

#### We will use the following 3 prompts

```Delphi
const
  Step1 =
    '# Do not answer the question directly.'#10 +
    '# Consider possible lines of thought'#10 +
    '# Break the main problem down into subproblems.'#10 +
    '## For each subproblem: Develop a strategy to address that point.'#10 +
    '## For each subproblem: Evaluate and then critique the strategy established.'#10 +
    '## For each subproblem: Assess the relevance and effectiveness of the strategy.'#10 +
    '# Formatting'#10 +
    '## – Use everyday language to explain the reasoning.'#10 +
    '## – Avoid lists and markdown formatting.'#10 +
    '## – Write as if you were explaining to a third party.';

  Step2 =
    '# Build an effective outline to answer the question based on the analysis.'#10 +
    '## Do not go into detail on each point of the outline but rather discuss its relevance.'#10 +
    '## Identify the points that should be addressed in the thesis.'#10 +
    '## Identify the points that should be addressed in the antithesis.'#10 +
    '## Identify the points that should be addressed in the synthesis.'#10 +
    '## Determine the points to cover for a powerful introduction.'#10 +
    '## Determine the points to cover for a memorable conclusion.'#10 +
    '# Formatting'#10 +
    '## – Use everyday language to explain the reasoning.'#10 +
    '## – Avoid lists and markdown formatting.'#10 +
    '## – Write as if you were explaining to a third party.’';

  Step3 =
    '# Answer the following question in a teaching style'#10 +
    '## Use all the information provided in the system section.';
```

<br>

#### The code enabling chaining using the promise pattern

```Pascal
// uses Deepseek, Deepseek.Types, Deepseek.Tutorial.VCL, Deepseek.Async.Promise;

var
  Analysis: string;
begin
  TutorialHub.Clear;

  var Request := 'Does personal data belong to the individuals who generate it or to the platforms that collect it?';
  var System := Step1;

  TutorialHub.PromiseStep('Reasoning'#10, Request, System)
    .&Then<string>(
      function(Value: string): string
      begin
        Analysis := Value;
        Result := 'Request : '#10 + Request + #10 + 'Analysis : ' + Analysis;
        System := Step2;
      end)
    .&Then(
      function (Value: string): TPromise<string>
      begin
        Result := TutorialHub.PromiseStep(#10#10'Develop a plan'#10, Value, System);
      end)
    .&Then<string>(
      function(Value: string): string
      begin
        Result := Request + #10 + Step3 + #10 + Request;
        System := Analysis + #10 + Value;
      end)
    .&Then(
      function (Value: string): TPromise<string>
      begin
        Result := TutorialHub.PromiseStep(#10#10'Response'#10, Value, System);
      end)
    .&Catch(
      procedure(E: Exception)
      begin
        Display(Memo1, 'Error : ' + E.Message);
      end);
end;
```

This code answers the question provided in the `Request` variable by using two intermediate steps. We will now review the body of the Promise used at each stage.

![Preview](/../main/images/Promise.png?raw=true "Preview")

>[!NOTE]
>The corresponding code is available in the `Deepseek.Tutorial.VCL` and `Deepseek.Tutorial.FMX` units, depending on the platform on which you are running the test.

```Pascal
function TFMXTutorialHub.PromiseStep(const StepName, Prompt,
  System: string): TPromise<string>;
var
  Buffer: string;
begin
  Result := TPromise<string>.Create(
    procedure(Resolve: TProc<string>; Reject: TProc<Exception>)
    begin
      Client.Chat.AsynCreateStream(
        procedure (Params: TChatParams)
        begin
          Params.Model('deepseek-chat');
          Params.Messages([
            FromSystem(system),
            FromUser(Prompt)
          ]);
          Params.Stream;
        end,
        function : TAsynChatStream
        begin
          Result.Sender := TutorialHub;

          Result.OnStart :=
            procedure (Sender: TObject)
            begin
              Display(Sender, StepName + #10);
            end;

          Result.OnProgress :=
            procedure (Sender: TObject; Chat: TChat)
            begin
              DisplayStream(Sender, Chat);
              Buffer := Buffer + Chat.Choices[0].Delta.Content;
            end;

          Result.OnSuccess :=
            procedure (Sender: TObject)
            begin
              Resolve(Buffer); //The promise is resolved --> &Then<string>
            end;

          Result.OnError :=
            procedure (Sender: TObject; Error: string)
            begin
              Reject(Exception.Create(Error));  //The promise is rejected --> &Catch
            end;

          Result.OnDoCancel := DoCancellation;

          Result.OnCancellation :=
            procedure (Sender: TObject)
            begin
              Reject(Exception.Create('Aborted'));  //The promise is rejected --> &Catch
            end;

        end);
    end);
end;
 
```

<br>

#### Note

This approach proves to be particularly powerful for handling asynchronous mechanisms. However, when a process involves a large number of steps, the resulting code can quickly become difficult to maintain, leading to what is commonly referred to as a "pyramid of doom."

To avoid this, it is recommended to adopt a Pipeline mechanism, which organizes and chains the steps in a clear, streamlined, and structured way.

[An example implementation](https://github.com/MaxiDonkey/SynkFlowAI) based on the [GenAI wrapper for OpenAI](https://github.com/MaxiDonkey/DelphiGenAI) is available. With a few minor adjustments, it can also be used with Deepseek, except for the web search functionality.

<br>

## Function calling

>[!CAUTION]
> Note from DeepSeek in their [official documentation](https://api-docs.deepseek.com/guides/function_calling)
> *"The current version of the deepseek-chat model's Function Calling capabilitity is unstable, which may result in looped calls or empty responses. We are actively working on a fix, and it is expected to be resolved in the next version."*

Furthermore, function calls cannot be made in the context of a streaming request. Regarding the APIs, `Delta` does not support the `tool_calls object`.

<br/>

### Use case

**What’s the weather in Paris?**

In the `Deepseek.Functions.Example` unit, there is a class that defines a function which `Deepseek` can choose to use or not, depending on the options provided. This class inherits from a parent class defined in the `Deepseek.Functions.Core` unit. To create new functions, you can derive from the `TFunctionCore class` and define a new plugin.

In this unit, this schema will be used for function calls.

```Json
{
    "type": "object",
    "properties": {
         "location": {
             "type": "string",
             "description": "The city and department, e.g. Marseille, 13"
         },
         "unit": {
             "type": "string",
             "enum": ["celsius", "fahrenheit"]
         }
     },
     "required": ["location"]
  }
```

<br/>

1. We will use the TWeatherReportFunction plugin defined in the [`Deepseek.Functions.Example`](https://github.com/MaxiDonkey/DelphiDeepseek/blob/main/source/Deepseek.Functions.Example.pas) unit.

```Pascal
  var Weather := TWeatherReportFunction.CreateInstance;
  //See step 3
```

<br/>

2. We then define a method to display the **result** of the query using the **Weather tool**.

```Pascal
procedure TMy_Form.DisplayWeather(const Value: string);
begin
  //Asynchronous example
  DeepSeek.Chat.ASynCreateStream(
    procedure (Params: TChatParams)
    begin
      Params.Model('deepseek-chat');
      Params.Messages([
        FromSystem('You are a star weather presenter on a national TV channel.'),
        FromUser(Value)
      ]);
      Params.Stream;
    end,
    function : TAsynChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);
end;
```

<br/>

3. Building the query using the Weather tool

```Pascal
// uses Deepseek, Deepseek.Types, Deepseek.Functions.Example, Deepseek.Tutorial.VCL;
  
  TutorialHub.Clear;
  var Weather := TWeatherReportFunction.CreateInstance;
  TutorialHub.Tool := Weather;
  TutorialHub.ToolCall := DisplayWeather;

  //Asynchronous example
  DeepSeek.Chat.AsynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('deepseek-chat');
      Params.Messages([
        TContentParams.User('What is the weather in Paris?')
      ]);
      Params.Tools([Weather]);
      Params.ToolChoice(auto);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError
  end;
```

<br/>

## JSON Output

In many scenarios, users require the model to produce output in strictly JSON format to ensure structured data, facilitating seamless downstream processing.

DeepSeek provides a JSON Output feature to guarantee the generation of valid JSON strings.

**Key Considerations:**
1. **Enabling JSON Output:**
     - Set the response_format parameter to `{'type': 'json_object'}`.
     - Include the word "json" in the system or user prompt, and provide an example of the desired JSON format to guide the model in producing compliant outputs.

2. **Adjusting Output Length:**
     - Configure the max_tokens parameter appropriately to prevent the JSON string from being truncated.

3. **Handling Potential Issues:**
     - The API may occasionally return empty content. This issue is under active optimization. Adjusting the prompt can help mitigate such occurrences.

Refer to [official documentation](https://api-docs.deepseek.com/guides/json_mode)

<br/>

```Pascal
// uses Deepseek, Deepseek.Types, Deepseek.Tutorial.VCL;

  TutorialHub.Clear;

  //Asynchronous example
  DeepSeek.Chat.AsynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('deepseek-chat');
      Params.Messages([
        TContentParams.System('The user will provide some exam text. Please parse the "question" and "answer" and output them in JSON format. EXAMPLE INPUT: Which is the highest mountain in the world? Mount Everest. EXAMPLE JSON OUTPUT: {     "question": "Which is the highest mountain in the world?",     "answer": "Mount Everest" }'),
        TContentParams.User('Which is the longest river in the world? The Nile River')
      ]);
      Params.ResponseFormat(TResponseFormat.json_object);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := DeepSeek.Chat.Create(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('deepseek-chat');
//      Params.Messages([
//        TContentParams.System('The user will provide some exam text. Please parse the "question" and "answer" and output them in JSON format. EXAMPLE INPUT: Which is the highest mountain in the world? Mount Everest. EXAMPLE JSON OUTPUT: {     "question": "Which is the highest mountain in the world?",     "answer": "Mount Everest" }'),
//        TContentParams.User('Which is the longest river in the world? The Nile River')
//      ]);
//      Params.ResponseFormat(TResponseFormat.json_object);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

The model will output:

```Json
{
    "question": "Which is the longest river in the world?",
    "answer": "The Nile River"
}  
```

<br/>

## Context Caching

Refer to the [official documentation](https://api-docs.deepseek.com/guides/kv_cache)

The automatic enforcement of caching has the effect of limiting the diversity of generated responses. While adjusting the temperature parameter can provide some flexibility, it is not an optimal solution in all cases.

Additionally, users are unable to directly intervene to perform a manual "cache clearing." In this regard, I refer you to the official documentation, which states: 

- *"Cache construction takes seconds. Once the cache is no longer in use, it will be automatically cleared, usually within a few hours to a **`few days`**.."*

<br/>

## Get user balance

View account details, including available credit balance.

```Pascal
// uses Deepseek, Deepseek.Types, Deepseek.Tutorial.VCL;

  TutorialHub.Clear;

  //Asynchronous example
  DeepSeek.User.AsynBalance(
    function : TAsynBalance
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := DeepSeek.User.Balance;
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

# Beta version

## FIM Completion

In Fill-In-the-Middle (FIM) completion, users can specify a prefix and optionally a suffix, allowing the model to generate content that seamlessly fills the gap between them. This approach is particularly useful for tasks such as content and code completion.

**Important Notes:**
- Token Limit: FIM completion supports a maximum token limit of 4,000.
- Enabling the Beta Feature: Users must set base_url=https://api.deepseek.com/beta to activate this functionality.

>[!TIP]
> In this case, we will use the [DeepseekBeta](#initialization) client in our code examples.

<br/>

### Completion

```Pascal
// uses Deepseek, Deepseek.Types, Deepseek.Tutorial.VCL;

  TutorialHub.Clear;

  //Asynchronous example
  DeepSeekBeta.FIM.AsynCreate(
    procedure (Params: TFIMParams)
    begin
      Params.Model('deepseek-chat');
      Params.Prompt('def fib(a):');
      Params.Suffix('    return fib(a-1) + fib(a-2)');
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynFIM
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := DeepSeekBeta.FIM.Create(
//    procedure (Params: TFIMParams)
//    begin
//      Params.Model('deepseek-chat');
//      Params.Prompt('def fib(a):');
//      Params.Suffix('    return fib(a-1) + fib(a-2)');
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```
<br/>

The model will output:

``` 
    if a == 0:
        return 0
    elif a == 1:
        return 1
    else:  
```

<br/>

### Streamed completion

```Pascal
// uses Deepseek, Deepseek.Types, Deepseek.Tutorial.VCL;

  TutorialHub.Clear;

  //Asynchronous example
  DeepSeekBeta.FIM.AsynCreateStream(
    procedure (Params: TFIMParams)
    begin
      Params.Model('deepseek-chat');
      Params.Prompt('def fib(a):');
      Params.Suffix('  return fib(a-1) + fib(a-2)');
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynFIMStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  DeepSeekBeta.FIM.CreateStream(
//    procedure (Params: TFIMParams)
//    begin
//      Params.Model('deepseek-chat');
//      Params.Prompt('def fib(a):');
//      Params.Suffix('  return fib(a-1) + fib(a-2)');
//      Params.Stream;
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    procedure (var FIM: TFIM; IsDone: Boolean; var Cancel: Boolean)
//    begin
//      if Assigned(FIM) and not IsDone then
//        DisplayStream(TutorialHub, FIM);
//    end);
```

## Chat prefix completion

To utilize the chat prefix completion feature, users must provide a message prefix for the assistant, allowing the model to complete the rest of the message.

**Important Note**
When using prefix completion, it is essential to ensure that the role of the last message in the message list is set to "assistant" and that the `prefix` parameter for this message is enabled (set to `True`). Additionally, users must configure `base_url="https://api.deepseek.com/beta"` to activate the Beta feature.

>[!TIP]
> In this case, we will use the [DeepseekBeta](#initialization) client in our code examples.

```Pascal
// uses Deepseek, Deepseek.Types, Deepseek.Tutorial.VCL;

  TutorialHub.Clear;

  //Asynchronous example
  DeepSeekBeta.Chat.AsynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('deepseek-chat');
      Params.Messages([
        FromUser('Please write quick sort code'),
        FromAssistant('```python\n', True)
      ]);
      Params.Stop('```');
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

The model will output:

```Python
# Quick Sort implementation in Python

def quick_sort(arr):
    if len(arr) <= 1:
        return arr
    pivot = arr[len(arr) // 2]
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]
    return quick_sort(left) + middle + quick_sort(right)

# Example usage:
arr = [3, 6, 8, 10, 1, 2, 1]
sorted_arr = quick_sort(arr)
print("Sorted array:", sorted_arr)
```

<br>

# Tips and tricks

## How to prevent an error when closing an application while requests are still in progress?

Starting from version 1.0.2 of Deepseek, the Deepseek.Monitoring unit is responsible for monitoring ongoing HTTP requests.

The Monitoring interface is accessible by including the Deepseek.Monitoring unit in the uses clause.
Alternatively, you can access it via the HttpMonitoring function, declared in the Deepseek unit.

### Usage example

```Delphi
procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not HttpMonitoring.IsBusy;
  if not CanClose then
    MessageDLG(
      'Requests are still in progress. Please wait for them to complete before closing the application."',
      TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);
end;
```

<br>

# Contributing

Pull requests are welcome. If you're planning to make a major change, please open an issue first to discuss your proposed changes.

# License

This project is licensed under the [MIT](https://choosealicense.com/licenses/mit/) License.

