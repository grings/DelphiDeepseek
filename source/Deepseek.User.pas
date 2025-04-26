unit Deepseek.User;

interface

uses
  System.SysUtils, System.Classes, REST.JsonReflect, System.JSON, System.Threading,
  REST.Json.Types, Deepseek.API.Params, Deepseek.API, Deepseek.Async.Support;

type

  /// <summary>
  /// Represents detailed information about a user's balance in a specific currency.
  /// </summary>
  /// <remarks>
  /// This class encapsulates information about the user's balance, including the total available balance,
  /// granted balance, and topped-up balance, all categorized by currency.
  /// </remarks>
  TBalanceInfo = class
  private
    FCurrency: string;
    [JsonNameAttribute('total_balance')]
    FTotalBalance: string;
    [JsonNameAttribute('granted_balance')]
    FGrantedBalance: string;
    [JsonNameAttribute('topped_up_balance')]
    FToppedUpBalance: string;
  public
    /// <summary>
    /// The currency of the balance. Possible values: [CNY, USD]
    /// </summary>
    property Currency: string read FCurrency write FCurrency;
    /// <summary>
    /// The total available balance, including the granted balance and the topped-up balance.
    /// </summary>
    property TotalBalance: string read FTotalBalance write FTotalBalance;
    /// <summary>
    /// The total not expired granted balance.
    /// </summary>
    property GrantedBalance: string read FGrantedBalance write FGrantedBalance;
    /// <summary>
    /// The total topped-up balance.
    /// </summary>
    property ToppedUpBalance: string read FToppedUpBalance write FToppedUpBalance;
  end;

  /// <summary>
  /// Represents the user's balance and its availability for API usage.
  /// </summary>
  /// <remarks>
  /// This class provides information about whether the user's balance is sufficient for API calls
  /// and includes detailed balance information across different currencies.
  /// </remarks>
  TBalance = class(TJSONFingerprint)
  private
    [JsonNameAttribute('is_available')]
    FIsAvailable: Boolean;
    [JsonNameAttribute('balance_infos')]
    FBalanceInfos: TArray<TBalanceInfo>;
  public
    /// <summary>
    /// Whether the user's balance is sufficient for API calls.
    /// </summary>
    property IsAvailable: Boolean read FIsAvailable write FIsAvailable;
    /// <summary>
    /// Provides detailed balance information for each currency.
    /// </summary>
    /// <remarks>
    /// This property contains an array of <c>TBalanceInfo</c> objects, where each object represents
    /// balance details such as the total balance, granted balance, and topped-up balance for a specific currency.
    /// </remarks>
    property BalanceInfos: TArray<TBalanceInfo> read FBalanceInfos write FBalanceInfos;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TBalance</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynBalance</c> type extends the <c>TAsynParams&lt;TBalance&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynBalance = TAsynCallBack<TBalance>;

  TUserRoute = class(TDeepseekAPIRoute)
    /// <summary>
    /// Get user current balance asynchronously.
    /// </summary>
    /// <param name="CallBacks">
    /// A function that returns a record containing event handlers for the asynchronous balance, such as on success and on error.
    /// </param>
    /// <remarks>
    /// <code>
    /// //var DeepSeek := TDeepseekFactory.CreateInstance(BarearKey);
    /// DeepSeek.User.AsynBalance(
    ///   function: TAsynBalance
    ///   begin
    ///     Result.Sender := My_component;  // Instance passed to callback parameter
    ///
    ///     Result.OnStart := nil;   // If nil then; Can be omitted
    ///
    ///     Result.OnSuccess := procedure (Sender: TObject; Value: TBalance)
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
    procedure AsynBalance(CallBacks: TFunc<TAsynBalance>);
    /// <summary>
    /// Get user current balance
    /// </summary>
    /// <returns>
    /// Returns a <c>TBalance</c> object that contains the user balance.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //var DeepSeek := TDeepseekFactory.CreateInstance(BarearKey);
    /// var Value := DeepSeek.User.Balance;
    ///   try
    ///     // Handle the Value
    ///   finally
    ///     Value.Free;
    ///   end;
    /// </code>
    /// </remarks>
    function Balance: TBalance;
  end;

implementation

{ TBalance }

destructor TBalance.Destroy;
begin
  for var Item in FBalanceInfos do
    Item.Free;
  inherited;
end;

{ TUserRoute }

procedure TUserRoute.AsynBalance(CallBacks: TFunc<TAsynBalance>);
begin
  with TAsynCallBackExec<TAsynBalance, TBalance>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TBalance
      begin
        Result := Self.Balance;
      end);
  finally
    Free;
  end;
end;

function TUserRoute.Balance: TBalance;
begin
  Result := API.Get<TBalance>('user/balance');
end;

end.
