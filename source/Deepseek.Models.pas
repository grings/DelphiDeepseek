unit Deepseek.Models;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiDeepseek
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, REST.JsonReflect, System.JSON, System.Threading,
  REST.Json.Types, Deepseek.API.Params, Deepseek.API, Deepseek.Async.Support;

type
  /// <summary>
  /// The <c>TModel</c> class represents a model entity retrieved from the Deepseek API.
  /// It encapsulates basic information about the model, including its unique identifier,
  /// object type, and ownership details.
  /// </summary>
  /// <remarks>
  /// This class is designed to be used as part of the Deepseek framework for API integrations.
  /// Instances of <c>TModel</c> are typically created as a result of API calls
  /// and provide detailed information about individual models available within the system.
  /// Key properties include <c>Id</c>, which identifies the model uniquely,
  /// <c>Object</c>, which specifies the type of the object, and <c>OwnedBy</c>,
  /// indicating the organ
  TModel = class(TJSONFingerprint)
  private
    FId: string;
    FObject: string;
    [JsonNameAttribute('owned_by')]
    FOwnedBy: string;
  public
    /// <summary>
    /// The model identifier, which can be referenced in the API endpoints.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// The object type, which is always "model".
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// The organization that owns the model.
    /// </summary>
    property OwnedBy: string read FOwnedBy write FOwnedBy;
  end;

  /// <summary>
  /// The <c>TModels</c> class represents a collection of model entities retrieved from the Deepseek API.
  /// It provides information about the collection as a whole and an array of individual models.
  /// </summary>
  /// <remarks>
  /// This class is used to handle the response from API endpoints that return a list of models.
  /// The <c>Object</c> property indicates the type of the object, typically set to "list",
  /// while the <c>Data</c> property contains an array of <c>TModel</c> instances representing each model in the collection.
  /// Instances of this class are created as a result of API calls to list available models.
  /// </remarks>
  TModels = class(TJSONFingerprint)
  private
    FObject: string;
    FData: TArray<TModel>;
  public
    /// <summary>
    /// Possible values: [list].
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// An array with each model.
    /// </summary>
    property Data: TArray<TModel> read FData write FData;
    /// <summary>
    /// Destructor to clean up resources used by the <c>TChatChoices</c> instance.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  /// The <c>TModelsRoute</c> class provides methods for interacting with the Deepseek API
  /// to retrieve and manage models. It offers both synchronous and asynchronous operations
  /// for listing and retrieving individual models.
  /// </summary>
  /// <remarks>
  /// This class serves as a high-level interface for accessing model-related API endpoints.
  /// It extends the <c>TDeepseekAPIRoute</c> class, inheriting base functionalities
  /// while adding methods specific to model operations.
  /// <para>
  /// Key functionalities include:
  /// <list type="bullet">
  /// <item><description>Listing all available models using <c>List</c> and <c>AsynList</c> methods.</description></item>
  /// <item><description>Retrieving details of a specific model by its ID using <c>Retrieve</c> and <c>AsynRetrieve</c> methods.</description></item>
  /// </list>
  /// </para>
  /// <para>
  /// Asynchronous methods (<c>AsynList</c> and <c>AsynRetrieve</c>) allow the application
  /// to handle API responses in a non-blocking manner, suitable for UI-intensive scenarios.
  /// Synchronous methods (<c>List</c> and <c>Retrieve</c>) block execution until the API response is received.
  /// </para>
  /// </remarks>
  TAsynModel = TAsynCallBack<TModel>;

  /// <summary>
  /// The <c>TAsynModels</c> class is a type alias used to handle asynchronous callbacks for batch processing.
  /// It provides support for executing batch operations asynchronously and processing the results upon completion.
  /// </summary>
  /// <remarks>
  /// This class is part of the asynchronous framework that allows non-blocking batch operations.
  /// It uses a callback mechanism to return the result of a batch process once it is completed.
  /// </remarks>
  TAsynModels = TAsynCallBack<TModels>;

  /// <summary>
  /// The <c>TModelsRoute</c> class provides methods for interacting with the Deepseek API
  /// to retrieve and manage models. It offers both synchronous and asynchronous operations
  /// for listing models.
  /// </summary>
  /// <remarks>
  /// This class serves as a high-level interface for accessing model-related API endpoints.
  /// It extends the <c>TDeepseekAPIRoute</c> class, inheriting base functionalities
  /// while adding methods specific to model operations.
  /// </remarks>
  TModelsRoute = class(TDeepseekAPIRoute)
    /// <summary>
    /// List available models.
    /// The Models API response can be used to determine which models are available for use in the API.
    /// </summary>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynModels</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or
    /// with an error.
    /// </para>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var DeepSeek := TDeepseekFactory.CreateInstance(BarearKey);
    /// DeepSeek.Models.AsynList(
    ///   function : TAsynModels
    ///   begin
    ///      Result.Sender := my_display_component;
    ///
    ///      Result.OnStart :=
    ///        procedure (Sender: TObject);
    ///        begin
    ///          // Handle the start
    ///        end;
    ///
    ///      Result.OnSuccess :=
    ///        procedure (Sender: TObject; Value: TModels)
    ///        begin
    ///          // Handle the display
    ///        end;
    ///
    ///      Result.OnError :=
    ///        procedure (Sender: TObject; Error: string)
    ///        begin
    ///          // Handle the error message
    ///        end;
    ///   end);
    /// </code>
    /// </remarks>
    procedure AsynList(CallBacks: TFunc<TAsynModels>);
    /// <summary>
    /// List available models.
    /// The Models API response can be used to determine which models are available for use in the API.
    /// </summary>
    /// <returns>
    /// A <c>TModels</c> object containing the list of models.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var DeepSeek := TDeepseekFactory.CreateInstance(BarearKey);
    /// var Value := DeepSeek.Models.List;
    /// try
    ///   // Handle the Value
    /// finally
    ///   Value.Free;
    /// end;
    /// </code>
    function List: TModels;
  end;

implementation

{ TModels }

destructor TModels.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

{ TModelsRoute }

procedure TModelsRoute.AsynList(CallBacks: TFunc<TAsynModels>);
begin
  with TAsynCallBackExec<TAsynModels, TModels>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TModels
      begin
        Result := Self.List;
      end);
  finally
    Free;
  end;
end;

function TModelsRoute.List: TModels;
begin
  Result := API.Get<TModels>('models');
end;

end.
