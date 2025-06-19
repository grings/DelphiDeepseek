#### 2025, June 19 version 1.0.3
- `Async/await` methods have been rolled out across all APIs with sensitive endpoints. Consequently, the tutorial’s code snippets have been enriched to provide readers with ready-to-use examples via ***TutorialHub***.
- To access directly to the Deepseek wrapper’s version. For any client implementing the IDeepseek interface, the version number can be retrieved via the Version property, for example:
```Delphi
var version = Client.Version;
```

<br>

#### 2025, April 26 version 1.0.2
- Http request monitoring.
- Parallel method for generating text
- Multiple queries with chainin
- Optimized SSE Algorithm for Streaming : <br>
   Enhanced reception and parsing of SSE streams for improved efficiency and speed.