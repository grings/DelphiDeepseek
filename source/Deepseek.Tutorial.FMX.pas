unit Deepseek.Tutorial.FMX;

{ Tutorial Support Unit

   WARNING:
     This module is intended solely to illustrate the examples provided in the
     README.md file of the repository :
          https://github.com/MaxiDonkey/DelphiDeepseek
     Under no circumstances should the methods described below be used outside
     of the examples presented on the repository's page.
}

interface

uses
  System.SysUtils, System.Classes, Winapi.Messages, FMX.Types, FMX.StdCtrls, FMX.ExtCtrls,
  FMX.Controls, FMX.Forms, Winapi.Windows, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.Media, FMX.Objects, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, System.UITypes,
  System.Types, System.JSON,
  Deepseek, Deepseek.Types, Deepseek.Async.Promise;

type
  TToolProc = procedure (const Value: string) of object;

  /// <summary>
  /// Represents a tutorial hub for handling visual components in a Delphi application,
  /// including text display, button interactions, and navigation through pages.
  /// </summary>
  TFMXTutorialHub = class
  private
    FMemo1: TMemo;
    FMemo2: TMemo;
    FMemo3: TMemo;
    FMemo4: TMemo;
    FButton: TButton;
    FModelId: string;
    FTool: IFunctionCore;
    FToolCall: TToolProc;
    FCancel: Boolean;
    FClient: IDeepseek;
    procedure OnButtonClick(Sender: TObject);
    procedure SetButton(const Value: TButton);
    procedure SetMemo1(const Value: TMemo);
    procedure SetMemo2(const Value: TMemo);
    procedure SetMemo3(const Value: TMemo);
    procedure SetMemo4(const Value: TMemo);
    procedure SetJSONRequest(const Value: string);
    procedure SetJSONResponse(const Value: string);
    function GetReasoning: TMemo;
  public
    /// <summary>
    /// Gets or sets the first memo component for displaying messages or data.
    /// </summary>
    property Memo1: TMemo read FMemo1 write SetMemo1;
    /// <summary>
    /// Gets or sets the button component used to trigger actions or handle cancellation.
    /// </summary>
    property Button: TButton read FButton write SetButton;
    /// <summary>
    /// Gets or sets a value indicating whether the operation has been canceled.
    /// </summary>
    property Cancel: Boolean read FCancel write FCancel;
    /// <summary>
    /// Gets or sets the model identifier associated with the tutorial hub.
    /// </summary>
    property ModelId: string read FModelId write FModelId;
    /// <summary>
    /// Gets or sets the core function tool used for processing.
    /// </summary>
    property Tool: IFunctionCore read FTool write FTool;
    /// <summary>
    /// Gets or sets the procedure for handling tool-specific calls.
    /// </summary>
    property ToolCall: TToolProc read FToolCall write FToolCall;
    /// <summary>
    /// Sets text for displaying JSON request.
    /// </summary>
    property JSONRequest: string write SetJSONRequest;
    /// <summary>
    /// Sets text for displaying JSON response.
    /// </summary>
    property JSONResponse: string write SetJSONResponse;
    /// <summary>
    /// Gets or sets the third memo component for displaying messages or data.
    /// </summary>
    property Memo3: TMemo read FMemo3 write SetMemo3;
    /// <summary>
    /// Get the reasoning Memo.
    /// </summary>
    property Reasoning: TMemo read GetReasoning;
    /// <summary>
    /// Instance of IDeepseek
    /// </summary>
    property Client: IDeepseek read FClient;

    procedure JSONRequestClear;
    procedure JSONResponseClear;
    procedure Clear;
    function PromiseStep(const StepName, Prompt: string; const System: string = ''): TPromise<string>;
    /// <summary>
    /// Gets or sets a value indicating whether file overrides are allowed.
    /// </summary>
    constructor Create(const AClient: IDeepseek; const AMemo1, AMemo2, AMemo3, AMemo4: TMemo; const AButton: TButton);
  end;

  procedure Cancellation(Sender: TObject);
  function DoCancellation: Boolean;
  procedure Start(Sender: TObject);

  procedure Display(Sender: TObject); overload;
  procedure Display(Sender: TObject; Value: string); overload;
  procedure Display(Sender: TObject; Value: TArray<string>); overload;
  procedure Display(Sender: TObject; Value: TModel); overload;
  procedure Display(Sender: TObject; Value: TModels); overload;
  procedure Display(Sender: TObject; Value: TChat); overload;
  procedure Display(Sender: TObject; Value: TFIM); overload;
  procedure Display(Sender: TObject; Value: TBalance); overload;

  procedure DisplayStream(Sender: TObject; Value: string); overload;
  procedure DisplayStream(Sender: TObject; Value: TChat); overload;
  procedure DisplayStream(Sender: TObject; Value: TFIM); overload;

  procedure DisplayUsage(Sender: TObject; Value: TUsage);

  procedure DisplayChunk(Value: string); overload;
  procedure DisplayChunk(Value: TChat); overload;
  procedure DisplayChunk(Value: TFIM); overload;

  function F(const Name, Value: string): string; overload;
  function F(const Name: string; const Value: TArray<string>): string; overload;
  function F(const Name: string; const Value: boolean): string; overload;
  function F(const Name: string; const State: Boolean; const Value: Double): string; overload;

var
  /// <summary>
  /// A global instance of the <see cref="TVCLTutorialHub"/> class used as the main tutorial hub.
  /// </summary>
  /// <remarks>
  /// This variable serves as the central hub for managing tutorial components, such as memos, buttons, and pages.
  /// It is initialized dynamically during the application's runtime, and its memory is automatically released during
  /// the application's finalization phase.
  /// </remarks>
  TutorialHub: TFMXTutorialHub = nil;

implementation

uses
  System.DateUtils;

function UnixIntToDateTime(const Value: Int64): TDateTime;
begin
  Result := TTimeZone.Local.ToLocalTime(UnixToDateTime(Value));
end;

function UnixDateTimeToString(const Value: Int64): string;
begin
  Result := DateTimeToStr(UnixIntToDateTime(Value))
end;

procedure Cancellation(Sender: TObject);
begin
  Display(Sender, 'The operation was cancelled' + sLineBreak);
  TutorialHub.Cancel := False;
end;

function DoCancellation: Boolean;
begin
  Result := TutorialHub.Cancel;
end;

procedure Start(Sender: TObject);
begin
  Display(Sender, 'Please wait...');
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: string);
var
  M: TMemo;
begin
  if Sender is TMemo then
    M := Sender as TMemo else
    M := (Sender as TFMXTutorialHub).Memo1;
  M.Lines.Add(Value);
  M.ViewportPosition := PointF(M.ViewportPosition.X, M.Content.Height - M.Height);
end;

procedure Display(Sender: TObject; Value: TArray<string>);
begin
  var index := 0;
  for var Item in Value do
    begin
      if not Item.IsEmpty then
        begin
          if index = 0 then
            Display(Sender, Item) else
            Display(Sender, '    ' + Item);
        end;
      Inc(index);
    end;
end;

procedure Display(Sender: TObject);
begin
  Display(Sender, sLineBreak);
end;

procedure Display(Sender: TObject; Value: TModel);
begin
  Display(Sender, [
    EmptyStr,
    F('id', Value.Id),
    F('object', Value.&Object),
    F('owned_by', Value.OwnedBy)
  ]);
  Display(Sender, EmptyStr);
end;

procedure Display(Sender: TObject; Value: TModels);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, 'Models list');
  if System.Length(Value.Data) = 0 then
    begin
      Display(Sender, 'No model found');
      Exit;
    end;
  for var Item in Value.Data do
    begin
      Display(Sender, Item);
      Application.ProcessMessages;
    end;
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TChat);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Choices do
    if Item.FinishReason = TFinishReason.tool_calls then
      begin
        if Assigned(TutorialHub.ToolCall) then
          TutorialHub.ToolCall(TutorialHub.Tool.Execute(Item.Message.ToolCalls[0].&Function.Arguments));
      end
    else
      begin
        Display(TutorialHub.Reasoning, Item.Message.ReasoningContent.Replace('\n', #10));
        Display(Sender, Item.Message.Content.Replace('\n', #10));
        DisplayUsage(Sender, Value.Usage);
      end;
end;

procedure Display(Sender: TObject; Value: TFIM);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Choices do
    Display(TutorialHub, Item.Text);
end;

procedure Display(Sender: TObject; Value: TBalance);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, F('is_Available', BoolToStr(Value.IsAvailable, True)));
  for var Item in Value.BalanceInfos do
    Display(Sender, [
      EmptyStr,
      F('currency', Item.Currency),
      F('total_balance', Item.TotalBalance),
      F('granted_balance', Item.GrantedBalance),
      F('topped_up_balance', Item.ToppedUpBalance)
    ]);
  Display(Sender, EmptyStr);
end;

procedure DisplayStream(Sender: TObject; Value: string);
var
  M: TMemo;
  CurrentLine: string;
begin
  if Sender is TMemo then
    M := Sender as TMemo
  else
    M := (Sender as TFMXTutorialHub).Memo1;
  var ShouldScroll := M.ViewportPosition.Y >= (M.Content.Height - M.Height - 16);
  M.Lines.BeginUpdate;
  try
    var Lines := Value.Replace(#13, '').Split([#10]);
    if System.Length(Lines) > 0 then
    begin
      if M.Lines.Count > 0 then
        CurrentLine := M.Lines[M.Lines.Count - 1]
      else
        CurrentLine := EmptyStr;
      CurrentLine := CurrentLine + Lines[0];
      if M.Lines.Count > 0 then
        M.Lines[M.Lines.Count - 1] := CurrentLine
      else
        M.Lines.Add(CurrentLine);
      for var i := 1 to High(Lines) do
        M.Lines.Add(Lines[i]);
    end;
  finally
    M.Lines.EndUpdate;
  end;
  if ShouldScroll then
    M.ViewportPosition := PointF(M.ViewportPosition.X, M.Content.Height - M.Height + 1);
end;

procedure DisplayStream(Sender: TObject; Value: TChat);
begin
  if Assigned(Value) then
    begin
      DisplayChunk(Value);
      if not Value.Choices[0].Delta.ReasoningContent.IsEmpty then
        DisplayStream(TutorialHub.Reasoning, Value.Choices[0].Delta.ReasoningContent)
      else
        DisplayStream(Sender, Value.Choices[0].Delta.Content.Replace('\n', #10));
    end;
end;

procedure DisplayStream(Sender: TObject; Value: TFIM);
begin
  if Assigned(Value) then
    begin
      DisplayChunk(Value);
      DisplayStream(Sender, Value.Choices[0].Text);
    end;
end;

procedure DisplayUsage(Sender: TObject; Value: TUsage);
begin
  Display(Sender, EmptyStr);
  Display(Sender, F('completion_tokens', [
    Value.CompletionTokens.ToString,
    F('promp_tokens', Value.PromptTokens.ToString),
    F('prompt_cache_hit_tokens', Value.PromptCacheHitTokens.ToString),
    F('prompt_cache_miss_tokens', Value.PromptCacheMissTokens.ToString),
    F('total_tokens', Value.TotalTokens.ToString)
  ]));
  Display(Sender, EmptyStr);
end;

procedure DisplayChunk(Value: string);
begin
  if not Value.IsEmpty then
    begin
      var JSONValue := TJSONObject.ParseJSONValue(Value);
      TutorialHub.Memo3.Lines.BeginUpdate;
      try
        Display(TutorialHub.Memo3, JSONValue.ToString);
      finally
        TutorialHub.Memo3.Lines.EndUpdate;
        JSONValue.Free;
      end;
    end;
end;

procedure DisplayChunk(Value: TChat);
begin
  DisplayChunk(Value.JSONResponse);
end;

procedure DisplayChunk(Value: TFIM);
begin
  DisplayChunk(Value.JSONResponse);
end;

function F(const Name, Value: string): string;
begin
  if not Value.IsEmpty then
    Result := Format('%s: %s', [Name, Value])
end;

function F(const Name: string; const Value: TArray<string>): string;
begin
  var index := 0;
  for var Item in Value do
    begin
      if index = 0 then
        Result := Format('%s: %s', [Name, Item]) else
        Result := Result + '    ' + Item;
      Inc(index);
    end;
end;

function F(const Name: string; const Value: boolean): string;
begin
  Result := Format('%s: %s', [Name, BoolToStr(Value, True)])
end;

function F(const Name: string; const State: Boolean; const Value: Double): string;
begin
  Result := Format('%s (%s): %s%%', [Name, BoolToStr(State, True), (Value * 100).ToString(ffNumber, 3, 3)])
end;

{ TFMXTutorialHub }

procedure TFMXTutorialHub.Clear;
begin
  JSONRequestClear;
  JSONResponseClear;
  FMemo4.Lines.Clear;
end;

constructor TFMXTutorialHub.Create(const AClient: IDeepseek; const AMemo1, AMemo2, AMemo3, AMemo4: TMemo; const AButton: TButton);
begin
  inherited Create;
  FClient := AClient;
  Memo1 := AMemo1;
  Button := AButton;
  SetMemo2(AMemo2);
  SetMemo3(AMemo3);
  SetMemo4(AMemo4);
end;

function TFMXTutorialHub.GetReasoning: TMemo;
begin
  Result := FMemo4;
end;

procedure TFMXTutorialHub.JSONRequestClear;
begin
  FMemo2.Lines.Clear;
end;

procedure TFMXTutorialHub.JSONResponseClear;
begin
  FMemo3.Lines.Clear;
end;

procedure TFMXTutorialHub.OnButtonClick(Sender: TObject);
begin
  Cancel := True;
end;

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
              Resolve(Buffer);
            end;

          Result.OnError :=
            procedure (Sender: TObject; Error: string)
            begin
              Reject(Exception.Create(Error));
            end;

          Result.OnDoCancel := DoCancellation;

          Result.OnCancellation :=
            procedure (Sender: TObject)
            begin
              Reject(Exception.Create('Aborted'));
            end;

        end);
    end);
end;

procedure TFMXTutorialHub.SetButton(const Value: TButton);
begin
  FButton := Value;
  FButton.OnClick := OnButtonClick;
  FButton.Text := 'Cancel';
end;

procedure TFMXTutorialHub.SetJSONRequest(const Value: string);
begin
  FMemo2.Lines.Text := Value;
  FMemo2.SelStart := 0;
  Application.ProcessMessages;
end;

procedure TFMXTutorialHub.SetJSONResponse(const Value: string);
begin
  FMemo3.Lines.Text := Value;
  FMemo2.SelStart := 0;
  Application.ProcessMessages;
end;

procedure TFMXTutorialHub.SetMemo1(const Value: TMemo);
begin
  FMemo1 := Value;
  FMemo1.TextSettings.WordWrap := True;
end;

procedure TFMXTutorialHub.SetMemo2(const Value: TMemo);
begin
  FMemo2 := Value;
end;

procedure TFMXTutorialHub.SetMemo3(const Value: TMemo);
begin
  FMemo3 := Value;
end;

procedure TFMXTutorialHub.SetMemo4(const Value: TMemo);
begin
  FMemo4 := Value;
end;

initialization
finalization
  if Assigned(TutorialHub) then
    TutorialHub.Free;
end.
