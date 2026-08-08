# 架构说明

## 1. 代码目录

相对 `core/src/` 的目录与文件（与实现一致，已忽略 target、测试目录）；「路径」列可点击跳转。

| 层/目录 | 路径（跳转） | 说明 |
|---------|--------------|------|
| **api** | [api/Routes.scala](../core/src/api/Routes.scala)、[api/Server.scala](../core/src/api/Server.scala)、[api/ApiServer.scala](../core/src/api/ApiServer.scala) | 路由、HTTP 服务、入口 |
| | [api/ChatStreamHandler.scala](../core/src/api/ChatStreamHandler.scala)、[api/ChatHandler.scala](../core/src/api/ChatHandler.scala)、[api/ChatHandlerLogic.scala](../core/src/api/ChatHandlerLogic.scala) | 流式/非流式对话 Handler |
| | [api/GraphStatusHandler.scala](../core/src/api/GraphStatusHandler.scala)、[api/HealthHandler.scala](../core/src/api/HealthHandler.scala) | 图状态、健康检查 |
| | [api/support/HttpHelpers.scala](../core/src/api/support/HttpHelpers.scala)、[api/support/ChatRequestParser.scala](../core/src/api/support/ChatRequestParser.scala) 等 | 公共解析与 CORS |
| **application** | [application/ChatApplicationService.scala](../core/src/application/ChatApplicationService.scala)、[application/Chat.scala](../core/src/application/Chat.scala) | 对话应用服务、Chat 对话循环 |
| | [application/Commands.scala](../core/src/application/Commands.scala)、[application/Dtos.scala](../core/src/application/Dtos.scala)、[application/ConversationResponseAssembler.scala](../core/src/application/ConversationResponseAssembler.scala)、[application/GraphSnapshotAssembler.scala](../core/src/application/GraphSnapshotAssembler.scala) | 命令、DTO、响应组装 |
| | [application/needs/StreamWriter.scala](../core/src/application/needs/StreamWriter.scala)、[application/stream/StreamEvents.scala](../core/src/application/stream/StreamEvents.scala) | 流写入 Port、事件类型 |
| **domain** | [domain/orchestration/PlanCoordinator.scala](../core/src/domain/orchestration/PlanCoordinator.scala)、[domain/orchestration/ChatExecutionCoordinator.scala](../core/src/domain/orchestration/ChatExecutionCoordinator.scala) | 规划/对话协调 Port |

| | [application/Commands.scala](../core/src/application/Commands.scala)、[application/Dtos.scala](../core/src/application/Dtos.scala)、[application/ConversationResponseAssembler.scala](../core/src/application/ConversationResponseAssembler.scala)、[application/GraphSnapshotAssembler.scala](../core/src/application/GraphSnapshotAssembler.scala) | 命令、DTO、响应组装 |
ontext/ContextAssembler.scala](../core/src/domain/context/ContextAssembler.scala)、[domain/message/MessageValidator.scala](../core/src/domain/message/MessageValidator.scala)、[domain/Conversation.scala](../core/src/domain/Conversation.scala)、[domain/PlanningTypes.scala](../core/src/domain/PlanningTypes.scala) | 意图、上下文、校验、会话、类型 |
| **infrastructure** | [infrastructure/ApplicationComponents.scala](../core/src/infrastructure/ApplicationComponents.scala) | 组合根：chatService.init、streamWriterFactory |
| | [infrastructure/orchestration/DefaultPlanCoordinator.scala](../core/src/infrastructure/orchestration/DefaultPlanCoordinator.scala)、[infrastructure/orchestration/DefaultChatExecutionCoordinator.scala](../core/src/infrastructure/orchestration/DefaultChatExecutionCoordinator.scala) | 规划/对话协调器实现 |
| | [infrastructure/planning/LLMPlanGenerator.scala](../core/src/infrastructure/planning/LLMPlanGenerator.scala)、[infrastructure/planning/HttpLlmExecutor.scala](../core/src/infrastructure/planning/HttpLlmExecutor.scala)、[infrastructure/execution/GraphRunnerExecutor.scala](../core/src/infrastructure/execution/GraphRunnerExecutor.scala)、[infrastructure/execution/LLMNodeExecutor.scala](../core/src/infrastructure/execution/LLMNodeExecutor.scala) | PlanGenerator/PlanLlmExecutor/GraphRunner/NodeExecutor 实现 |
| | [infrastructure/sse/SSEStreamWriterFactory.scala](../core/src/infrastructure/sse/SSEStreamWriterFactory.scala)、[infrastructure/StreamEventPublisher.scala](../core/src/infrastructure/StreamEventPublisher.scala) | SSE 写入、流事件发布 |

---

## 2. 用例与流程 → 代码位置

**主用例：流式对话（规划或纯对话）**

| 步骤 | 流程 | 代码位置（跳转） |
|------|------|------------------|
| 1 | HTTP 接收 POST /chat/stream，解析请求 | [ChatStreamHandler](../core/src/api/ChatStreamHandler.scala) → [ChatHandlerLogic](../core/src/api/ChatHandlerLogic.scala).runStreamChat |
| 2 | 创建 SSE Source + queue，构造 StreamWriter Handle | [ChatHandlerLogic.runStreamChat](../core/src/api/ChatHandlerLogic.scala)（preMaterialize + streamWriterFactory.newWriter） |
| 3 | 调用应用层处理对话 | [ChatApplicationService](../core/src/application/ChatApplicationService.scala).processConversation(cmd, Some(writer)) |
| 4 | 校验输入、取 session、发「正在处理」 | [ChatApplicationService.run](../core/src/application/ChatApplicationService.scala) → MessageValidator.validateUserInput；manager.getOrCreate；streamEventPublisher.publishThinking |
| 5 | 取对话内容、意图分类 | [ChatApplicationService.runSteps](../core/src/application/ChatApplicationService.scala) → getConversationContent；classifyIntent（IntentClassifier） |
| 6a | 意图 GoToPlan：规划协调 | [ChatApplicationService.runByIntent](../core/src/application/ChatApplicationService.scala) → [DefaultPlanCoordinator](../core/src/infrastructure/orchestration/DefaultPlanCoordinator.scala).coordinate |
| 6b | 意图 GoToChat：对话协调 | [ChatApplicationService.runByIntent](../core/src/application/ChatApplicationService.scala) → [DefaultChatExecutionCoordinator](../core/src/infrastructure/orchestration/DefaultChatExecutionCoordinator.scala).coordinate |
| 7 | 规划路径：组装上下文 → 生成规划 → 执行图 → 写 TODO/graph_state/done | [DefaultPlanCoordinator.coordinate](../core/src/infrastructure/orchestration/DefaultPlanCoordinator.scala) 内 assemblePlanContext → generatePlan → executePlanWorkflow；[StreamEventPublisher](../core/src/infrastructure/StreamEventPublisher.scala) 写 SSE |
| 8 | 规划生成：构造 thinkingConsumer，调 Port | [DefaultPlanCoordinator.generatePlan](../core/src/infrastructure/orchestration/DefaultPlanCoordinator.scala) → [LLMPlanGenerator](../core/src/infrastructure/planning/LLMPlanGenerator.scala).generatePlan(..., thinkingConsumer) |
| 9 | 流式读 LLM，推思考到 Consumer | [LLMPlanGenerator.requestPlanViaStream](../core/src/infrastructure/planning/LLMPlanGenerator.scala) → readStreamAndPushChunks → thinkingConsumer.foreach(_(sessionId, text)) |
| 10 | 图执行：建图、多轮 PlanNext、总结 | [SmartGraphExecutor](../core/src/domain/execution/SmartGraphExecutor.scala).executePlanWorkflow → [GraphRunnerExecutor](../core/src/infrastructure/execution/GraphRunnerExecutor.scala) |
| 11 | 响应体 Chunked(text/event-stream) | [ChatHandlerLogic](../core/src/api/ChatHandlerLogic.scala) 将 source 交给 HttpEntity.Chunked；writer.writeChunk → queue.offer(ByteString) |

---

## 3. Application：主流程与归属

**主流程（一次流式对话）**

| 步骤 | 流程 | 归属 | 代码位置（跳转） |
|------|------|------|------------------|
| 1 | 校验输入 | Domain | [MessageValidator.validateUserInput](../core/src/domain/message/MessageValidator.scala) |
| 2 | 取/建会话、拼对话内容 | App 调 Domain/Infra | [ChatApplicationService.run](../core/src/application/ChatApplicationService.scala) → manager.getOrCreate、getConversationContent |
| 3 | 意图分类 | Domain Port + Infra 实现 | [IntentClassifier.classify](../core/src/domain/intent/IntentClassifierService.scala)；[ChatApplicationService.classifyIntent](../core/src/application/ChatApplicationService.scala) |
| 4 | **分支**：GoToPlan / GoToChat | App | [ChatApplicationService.runByIntent](../core/src/application/ChatApplicationService.scala)：GoToPlan → [PlanCoordinator.coordinate](../core/src/domain/orchestration/PlanCoordinator.scala)；GoToChat → [ChatExecutionCoordinator.coordinate](../core/src/domain/orchestration/ChatExecutionCoordinator.scala) |
| 5 | 规划路径：组装上下文 → 生成规划 → 执行图 → 写 SSE | 协调器 + Infra | [DefaultPlanCoordinator.coordinate](../core/src/infrastructure/orchestration/DefaultPlanCoordinator.scala)；[LLMPlanGenerator](../core/src/infrastructure/planning/LLMPlanGenerator.scala)、[GraphRunnerExecutor](../core/src/infrastructure/execution/GraphRunnerExecutor.scala)、[StreamEventPublisher](../core/src/infrastructure/StreamEventPublisher.scala) |
| 6 | 对话路径：组装上下文 → Chat 对话+工具循环 → 写 SSE | 协调器 + App/Infra | [DefaultChatExecutionCoordinator.coordinate](../core/src/infrastructure/orchestration/DefaultChatExecutionCoordinator.scala)；[Chat](../core/src/application/Chat.scala) |
| 7 | 返回 Either，转 DTO | App | [ChatApplicationService.run](../core/src/application/ChatApplicationService.scala) → [ConversationResponseAssembler.toResponseDTO](../core/src/application/ConversationResponseAssembler.scala) |

**流程归属表**

| 归属 | 职责与调用顺序 | 代码位置（跳转） |
|------|----------------|------------------|
| **App** | run → runSteps → runByIntent；校验、会话、意图一次；按意图调协调器；组装 ConversationResponse、getGraphSnapshot | [ChatApplicationService](../core/src/application/ChatApplicationService.scala) |
| **Domain** | 校验、意图/上下文 Port、规划/对话协调 Port、图执行、PlanGenerator/PlanNext/GraphRunner 等 Port | [MessageValidator](../core/src/domain/message/MessageValidator.scala)、[IntentClassifierService](../core/src/domain/intent/IntentClassifierService.scala)、[ContextAssembler](../core/src/domain/context/ContextAssembler.scala)、[PlanCoordinator](../core/src/domain/orchestration/PlanCoordinator.scala)、[ChatExecutionCoordinator](../core/src/domain/orchestration/ChatExecutionCoordinator.scala)、[SmartGraphExecutor](../core/src/domain/execution/SmartGraphExecutor.scala)、[Needs.scala（PlanGenerator/PlanNext）](../core/src/domain/planning/Needs.scala)、[GraphRunner](../core/src/domain/execution/needs/GraphRunner.scala) |
| **Infra** | 规划/对话协调器实现；PlanGenerator、GraphRunner、NodeExecutor 实现；SSE 写入、流事件发布 | [DefaultPlanCoordinator](../core/src/infrastructure/orchestration/DefaultPlanCoordinator.scala)、[DefaultChatExecutionCoordinator](../core/src/infrastructure/orchestration/DefaultChatExecutionCoordinator.scala)、[LLMPlanGenerator](../core/src/infrastructure/planning/LLMPlanGenerator.scala)、[GraphRunnerExecutor](../core/src/infrastructure/execution/GraphRunnerExecutor.scala)、[LLMNodeExecutor](../core/src/infrastructure/execution/LLMNodeExecutor.scala)、[SSEStreamWriterFactory](../core/src/infrastructure/sse/SSEStreamWriterFactory.scala)、[StreamEventPublisher](../core/src/infrastructure/StreamEventPublisher.scala) |

---

## 4. 组合根

| 角色 | 说明 | 代码位置（跳转） |
|------|------|------------------|
| 路由与 Handler | route(chatService, streamWriterFactory) 只组合路由，不创建 chatService；由调用方传入 | [Routes.route](../core/src/api/Routes.scala) |
| 创建 ChatApplicationService 及依赖 | chatService.init(config) 在入口层被调用：加载 ConfigLoad、创建 OneShotLLMClient、SessionConversationRegistry、IntentClassifier、ContextAssembler、LLMPlanGenerator、GraphRunnerExecutor、LLMNodeExecutor、PlanNextOrchestrator、SmartGraphExecutor、DefaultPlanCoordinator、DefaultChatExecutionCoordinator，最后 new ChatApplicationService(..., NoOpStreamWriter, planCoordinator, chatCoordinator)。流式端点由 Handler 传入 streamWriterFactory.newWriter(...) 覆盖 writer | [ApplicationComponents.chatService.init](../core/src/infrastructure/ApplicationComponents.scala)、[Server](../core/src/api/Server.scala)/[ApiServer](../core/src/api/ApiServer.scala) |

---

## 5. 关键逻辑

指**复杂机制**，涉及多个关键节点，易错或难理解。每类机制单独一个表格段落描述。

---

### 5.1 思考 Consumer 管道（规划→SSE）

**触发条件**：POST /chat/stream 且传入 writer。

| 节点 | 说明 | 代码跳转 |
|------|------|----------|
| Consumer 类型 | (String, String) => Unit，管道末端消费 (sessionId, content) | [PlanningThinkingConsumer](../core/src/domain/planning/Needs.scala) |
| 协调器内联 lambda | generatePlan 内构造 thinkingConsumer，内部调 output.publishThinking(content)（实现里用 StreamEventPublisher） | [DefaultPlanCoordinator.generatePlan](../core/src/infrastructure/orchestration/DefaultPlanCoordinator.scala) |
| 流式请求与消费 | planGenerator.generatePlan → requestPlanViaStream → consumeStreamAndParse → readStreamAndPushChunks 循环 readChunk，非空则 thinkingConsumer(sessionId, text) | [LLMPlanGenerator.generatePlan](../core/src/infrastructure/planning/LLMPlanGenerator.scala)、[readStreamAndPushChunks](../core/src/infrastructure/planning/LLMPlanGenerator.scala) |
| 流结束补发 | PlanningThinkingChunk.fallbackText(reasoning, content) 若有文本且 pushCount==0 则再推一次 | [PlanningThinkingChunk.fallbackText](../core/src/domain/planning/PlanningThinkingChunk.scala) |
| 写出 SSE | StreamEventPublisher.publishThinking → writer.writeChunk(SSE 格式) → 前端思考区 | [StreamEventPublisher](../core/src/infrastructure/StreamEventPublisher.scala)、[SSEStreamWriterFactory](../core/src/infrastructure/sse/SSEStreamWriterFactory.scala) |

**思考过程命名约定**（统一用「思考 / Thinking」一条链路）：

| 名称 | 含义 |
|------|------|
| **StreamWriter** | 流写入句柄，写 StreamChunk（含 Thinking 等类型）到连接 |
| **StreamEventPublisher** | 流事件发布：把业务事件（思考、图快照、TODO 等）转成 StreamChunk 后交给 StreamWriter |
| **publishThinking** | 发布思考内容（方法名，出现在 PlanCoordinatorOutput、StreamEventPublisher） |
| **PlanningThinkingConsumer** | 思考块回调 `(sessionId, content) => Unit`，规划流式产生思考时调用，协调器内接成 output.publishThinking |

---

### 5.2 Agent 思考过程的实现追踪与代码跳转

**范围**：从「思考」数据产生到前端展示的整条链路，按执行顺序可沿链接跳转。

| 步骤 | 环节 | 说明 | 代码跳转 |
|------|------|------|----------|
| 1 | Port 定义 | 思考管道末端类型 `(sessionId, content) => Unit` | [PlanningThinkingConsumer](../core/src/domain/planning/needs/Needs.scala)、[PlanGenerator.generatePlan(..., thinkingConsumer)](../core/src/domain/planning/needs/Needs.scala) |
| 2 | 应用层入口 | 流式请求时 effectiveWriter 非 NoOp，后续 publishThinking 才会写出 | [ChatApplicationService.processConversation](../core/src/application/ChatApplicationService.scala)（effectiveWriter = streamWriterOverride.getOrElse(streamWriter)） |
| 3 | 应用层发思考 | 「正在处理」、意图 reasoning、规划结果等直接调 StreamEventPublisher.publishThinking | [ChatApplicationService.run](../core/src/application/ChatApplicationService.scala) → [publishThinking("正在处理…")](../core/src/application/ChatApplicationService.scala)、[publishThinking(intent.reasoning)](../core/src/application/ChatApplicationService.scala)、[publishThinking(planning_result)](../core/src/application/ChatApplicationService.scala) |
| 4 | 协调器构造 Consumer | 规划路径中构造 thinkingConsumer，内部调 output.publishThinking(content) | [DefaultPlanCoordinator.generatePlan](../core/src/infrastructure/orchestration/DefaultPlanCoordinator.scala)（thinkingConsumer lambda → output.publishThinking） |
| 5 | 协调器输出抽象 | output 实现将 content 转为思考事件并交给 StreamEventPublisher | [StreamWriterPlanCoordinatorOutput.publishThinking](../core/src/infrastructure/orchestration/StreamWriterPlanCoordinatorOutput.scala) → [StreamEventPublisher.publishThinking](../core/src/infrastructure/StreamEventPublisher.scala) |
| 6 | 领域层传递 Consumer | PlanGenerationService 将 thinkingConsumer 传给 LLM 执行 Port | [PlanGenerationService.generatePlanWithLlm](../core/src/domain/planning/service/PlanGenerationService.scala)（llmExecutor.execute(prompt, thinkingConsumer, config)） |
| 7 | Infra 流式拉取 | 打开 LLM 流，消费 chunk 并推入 thinkingConsumer | [LLMPlanGenerator.generatePlan](../core/src/infrastructure/planning/LLMPlanGenerator.scala) → [requestPlanViaStream](../core/src/infrastructure/planning/LLMPlanGenerator.scala) → [consumeStreamAndParse](../core/src/infrastructure/planning/LLMPlanGenerator.scala) → [readStreamAndPushChunks](../core/src/infrastructure/planning/LLMPlanGenerator.scala) |
| 8 | Chunk → 文本 | 每个 (reasoning, content) 转为可推送文本 | [PlanningThinkingChunk.chunkToText](../core/src/domain/planning/model/PlanningThinkingChunk.scala)；[readStreamAndPushChunks 内调用](../core/src/infrastructure/planning/LLMPlanGenerator.scala) |
| 9 | 流结束补发 | 若整段流未推过任何 chunk，用 reasoning/content 再推一次 | [PlanningThinkingChunk.fallbackText](../core/src/domain/planning/model/PlanningThinkingChunk.scala)；[consumeStreamAndParse 内调用](../core/src/infrastructure/planning/LLMPlanGenerator.scala) |
| 10 | 事件 → SSE | StreamEventPublisher 将思考内容写成 StreamChunk(Thinking)，writer 写入连接 | [StreamEventPublisher.publishThinking](../core/src/infrastructure/StreamEventPublisher.scala)（writer.writeChunk(StreamChunk(Thinking, ...))）；[StreamWriter.Handle](../core/src/application/needs/StreamWriter.scala)、[SSEStreamWriterFactory](../core/src/infrastructure/sse/SSEStreamWriterFactory.scala) |

**思考不显示时**：确认 effectiveWriter 非 NoOp（须用 POST /chat/stream 并传入 writer）；再按链路从 hasConsumer → 流内 pushCount → 补发 → SSE 写出逐段查。

---

### 5.3 图执行与智能规划更新

**触发条件**：规划路径；planNext 为 Some。

| 节点 | 说明 | 代码跳转 |
|------|------|----------|
| 分层约定 | planning 不依赖 ExecutionGraph。树 string 在 execution 层生成：ExecutionGraphTree.treeString(graph, outputs) 内调 GraphNodeTree.formatTree(nodesWithDepth, nodeOutput)，得到 allTasksTreeText 传入 PlanNext.generateNextPlan(..., treeTextOpt, graphOpt, outputsOpt) | [ExecutionGraphTree.treeString](../core/src/domain/execution/ExecutionGraphTree.scala)、[GraphNodeTree.formatTree](../core/src/domain/planning/GraphNodeTree.scala)、[PlanNext.generateNextPlan](../core/src/domain/planning/Needs.scala) |
| 事件订阅 | SmartGraphExecutor.run → executeGraphWithCallbacks 订阅 BatchNodesCompletedEvent（每批节点完成触发） | [SmartGraphExecutor.run](../core/src/domain/execution/SmartGraphExecutor.scala)、[executeGraphWithCallbacks](../core/src/domain/execution/SmartGraphExecutor.scala) |
| 增量规划与追加 | runPlanNextAfterBatch：graphRunner.getGraph / getAllNodesFinalOutput → ExecutionGraphTree.treeString(g, outputs) → planNext.generateNextPlan(userInput, existingIds, treeTextOpt, graphOpt, Some(outputs)) → 若非空则 graphRunner.addNodesToGraph → eventBus.publish(GraphUpdatedEvent) | [runPlanNextAfterBatch](../core/src/domain/execution/SmartGraphExecutor.scala)、[PlanNext](../core/src/domain/planning/Needs.scala)、[GraphRunner](../core/src/domain/execution/needs/GraphRunner.scala) |
| 下一轮执行 | graphRunner.executeGraphForSession 内 runLoop：getReadyNodes 含新追加节点，继续执行直至无 Pending | [GraphRunnerExecutor](../core/src/infrastructure/execution/GraphRunnerExecutor.scala) |

---

### 5.4 Graph Node 执行逻辑链

从「规划结果建图」到「单节点执行时注入当前图结构」的完整调用链；每步可沿链接跳转。

**入口**：规划路径中 `DefaultPlanCoordinator.executePlanWorkflow` → `SmartGraphExecutor.run(sessionId, plan, userInput)`。

| 步骤 | 环节 | 说明 | 代码跳转 |
|------|------|------|----------|
| 1 | 建图与接图 | ExecutionGraphBuilder.buildFromInput(plan.nodes) → graphRunner.acceptBuiltGraph(sessionId, graph, plan) → eventBus.publish(GraphUpdatedEvent) | [SmartGraphExecutor.initializeExecutionGraph](../core/src/domain/execution/SmartGraphExecutor.scala)、[ExecutionGraphBuilder](../core/src/domain/execution/ExecutionGraphBuilder.scala)、[GraphRunner.acceptBuiltGraph](../core/src/domain/execution/needs/GraphRunner.scala) |
| 2 | 知识注入 | graphRunner.enrichFromKnowledge(sessionId)（可选） | [SmartGraphExecutor.initializeExecutionGraph](../core/src/domain/execution/SmartGraphExecutor.scala)、[GraphRunnerExecutor.enrichFromKnowledge](../core/src/infrastructure/execution/GraphRunnerExecutor.scala) |
| 3 | 订阅批完成事件 | executeGraphWithCallbacks 内订阅 BatchNodesCompletedEvent，回调 runPlanNextAfterBatch | [SmartGraphExecutor.executeGraphWithCallbacks](../core/src/domain/execution/SmartGraphExecutor.scala) |
| 4 | 按会话执行图 | graphRunner.executeGraphForSession(sessionId)：按 sessionId 取图、创建 ExecutionShared、NodeEventCoordinator（发布 NodeCompletedEvent + BatchNodesCompletedEvent），调 GraphExecutionService.executeGraph(graph, shared, publisher) | [GraphRunnerExecutor.executeGraphForSession](../core/src/infrastructure/execution/GraphRunnerExecutor.scala)、[NodeEventCoordinator](../core/src/infrastructure/execution/NodeEventCoordinator.scala) |
| 5 | 图执行 runLoop | getReadyNodes(graph) → 若有就绪节点：先写当前图结构到 shared，再 executeReadyNodes，再 publishBatchCompleted，递归 runLoop | [GraphExecutionService.runLoop](../core/src/domain/execution/GraphExecutionService.scala)、[GraphScheduler.getReadyNodes](../core/src/domain/execution/GraphScheduler.scala) |
| 6 | 每批执行前写图结构 | 从 shared 收集 node:id → 输出，ExecutionGraphTree.treeString(graph, nodeOutputs)，shared.put(ExecutionShared.KeyGraphTree, treeText) | [GraphExecutionService.runLoop](../core/src/domain/execution/GraphExecutionService.scala)、[ExecutionGraphTree.treeString](../core/src/domain/execution/ExecutionGraphTree.scala)、[ExecutionShared.KeyGraphTree](../core/src/domain/execution/ExecutionShared.scala) |
| 7 | 单节点执行 | 对每颗就绪节点：nodeExecutor.executeNode(node, shared)；结果写回 graph.updateNode、shared.put("node:"+id, result.data)、publisher.publish(node, result) | [GraphExecutionService.executeReadyNodes](../core/src/domain/execution/GraphExecutionService.scala)、[NodeExecutor.executeNode](../core/src/domain/execution/NodeExecutor.scala) |
| 8 | 批完成事件 | executeReadyNodes 完成后 nodeCompletedPublisher.publishBatchCompleted() → 触发 BatchNodesCompletedEvent | [GraphExecutionService.runLoop](../core/src/domain/execution/GraphExecutionService.scala)、[NodeCompletedPublisher.publishBatchCompleted](../core/src/domain/execution/NodeCompletedPublisher.scala)、[NodeEventCoordinator](../core/src/infrastructure/execution/NodeEventCoordinator.scala) |
| 9 | 节点执行实现（LLM） | LLMNodeExecutor.executeNode：技能匹配 → runExecuteNode；从 shared.get(KeyGraphTree) 取当前图树文本，若有则拼到 user 消息前：「当前任务结构（树形，有输出的节点已附摘要）：…」+ 任务/描述；system + user → MultiTurnToolLoop.run | [LLMNodeExecutor.executeNode](../core/src/infrastructure/execution/LLMNodeExecutor.scala)、[LLMNodeExecutor.runExecuteNode](../core/src/infrastructure/execution/LLMNodeExecutor.scala)、[ExecutionShared.KeyGraphTree](../core/src/domain/execution/ExecutionShared.scala) |
| 10 | PlanNext 追加（见 5.3） | BatchNodesCompletedEvent 触发 runPlanNextAfterBatch → generateNextPlan(…, allTasksTreeText, graphOpt, outputs) → 若非空 addNodesToGraph → GraphUpdatedEvent；下一轮 getReadyNodes 含新节点 | [SmartGraphExecutor.runPlanNextAfterBatch](../core/src/domain/execution/SmartGraphExecutor.scala)、5.3 节 |

**数据流小结**

| 数据 | 来源 | 去向 |
|------|------|------|
| 当前图结构树文本 | GraphExecutionService 每批前：graph + shared 中 node 输出 → ExecutionGraphTree.treeString | shared.put(KeyGraphTree)；LLMNodeExecutor 读后注入 LLM user 消息 |
| 节点输出 | NodeExecutor 返回 NodeResult.data | shared.put("node:"+id, result.data)；供下一批树文本与 PlanNext 使用 |
| 批完成 | executeReadyNodes 完成后 publishBatchCompleted | 事件总线 → runPlanNextAfterBatch → generateNextPlan / addNodesToGraph |

**每个任务是否知道整体任务图**：**是**。每批就绪节点执行前，runLoop 会把**整张图**的树形表示（所有节点 id、title、层级 + 已完成节点的输出摘要最多 120 字）写入 `ExecutionShared.KeyGraphTree`；LLMNodeExecutor 执行单节点时从 shared 读出该树，拼成「当前任务结构（树形，有输出的节点已附摘要）：…」注入 user 消息。因此**每个正在执行的节点都能看到当前整张任务图**。节点执行上下文中**不包含**用户目标/goal 的显式字段（除非写在 systemPrompt 里）。

---

### 5.5 节点执行时工具的加载与上下文

**范围**：单节点执行（图节点）时，哪些「工具定义」与「工具/节点输出」会进入 LLM 上下文。

| 节点 | 说明 | 代码跳转 |
|------|------|----------|
| 技能匹配 | 用「任务 + 描述」做 ContextMatcher.matchContext，得到匹配的 skills 及置信度 | [LLMNodeExecutor.executeNode](../core/src/infrastructure/execution/LLMNodeExecutor.scala)（messageForMatch、contextMatcher.matchContext） |
| 工具名过滤 | 仅保留置信度 ≥ policy.skillConfidenceThreshold 的 skill，再 SkillToolMapping.toolNamesForSkillNames(allowedSkillNames) 得到该节点允许的工具名集合；若无匹配或均低于阈值则 allowedToolNames 为空 | [LLMNodeExecutor.runExecuteNode](../core/src/infrastructure/execution/LLMNodeExecutor.scala)（allowedSkillNames、allowedToolNames） |
| **无 skill 匹配时** | allowedToolNames 为空时**不**用 FilteredToolRegistry，直接用底层 toolRegistry，即**全部已注册工具**暴露给该节点 | [LLMNodeExecutor.runExecuteNode](../core/src/infrastructure/execution/LLMNodeExecutor.scala)（`if (allowedToolNames.nonEmpty) new FilteredToolRegistry(...) else toolRegistry`） |
| 工具定义注入 | 有匹配时：FilteredToolRegistry(underlying, allowedToolNames)；MultiTurnToolLoop 用 registry.getDefinitions() 传给 client.chatWithTools(messages, toolDefs) | [FilteredToolRegistry](../core/src/infrastructure/FilteredToolRegistry.scala)、[MultiTurnToolLoop.run](../core/src/infrastructure/MultiTurnToolLoop.scala)（toolDefs = toolRegistry.getDefinitions()） |
| 本节点工具返回 | 每次 tool call 后，ToolCallResult.content 转为 role=tool 的 ChatMessage 追加到 messages，再请求 LLM；多轮内完整保留 | [MultiTurnToolLoop](../core/src/infrastructure/MultiTurnToolLoop.scala)（toolMsgs、next = messages :+ assistantMsg ++ toolMsgs） |
| 其它节点输出 | 不传原始 tool_results。仅通过 ExecutionShared.KeyGraphTree：树形 string 由 ExecutionGraphTree.treeString(graph, nodeOutputs) 生成，每节点取 output_md.plainText 或 output，再 GraphNodeTree.formatTree 截断为每节点最多 MaxOutputChars 字 | [ExecutionGraphTree.treeString](../core/src/domain/execution/ExecutionGraphTree.scala)、[GraphNodeTree.formatTree](../core/src/domain/planning/model/GraphNodeTree.scala)（MaxOutputChars=120）、[LLMNodeExecutor.runExecuteNode](../core/src/infrastructure/execution/LLMNodeExecutor.scala)（treeOpt、userContent） |
| 用户消息内容 | 若有树：`「当前任务结构（树形，有输出的节点已附摘要）：」+ treeText + 「---」+ 任务/描述`；否则仅任务/描述 | [LLMNodeExecutor.runExecuteNode](../core/src/infrastructure/execution/LLMNodeExecutor.scala)（userContent） |

**小结**

| 内容 | 是否进入该节点 LLM 上下文 | 说明 |
|------|---------------------------|------|
| 当前节点可用的工具定义 | 是 | 有 skill 匹配且置信度达标时：仅 [SkillToolMapping](../core/src/infrastructure/SkillToolMapping.scala) 中该 skill 映射的工具；**无匹配或均低于阈值时：全部已注册工具**（见上「无 skill 匹配时」） |
| 当前节点本轮的 tool 返回 | 是 | 完整作为 tool 消息加入多轮对话 |
| 其它节点的输出 | 部分 | 仅树形摘要，且每节点**最多 120 字**（[GraphNodeTree.MaxOutputChars](../core/src/domain/planning/model/GraphNodeTree.scala)）；非完整 tool_results |

---

### 5.6 节点输出 Markdown 渲染（展示用 HTML）

**触发条件**：图状态/任务结论展示；节点有 `output`（工具返回或 LLM 文本）需在 UI 中按 Markdown 排版（表格、标题、列表等）。

| 节点 | 说明 | 代码跳转 |
|------|------|----------|
| 后端渲染 | Markdown → HTML（Flexmark，含 TablesExtension 支持 GFM 表格）；`toHtmlForDisplay` 先在段落间按需插入 `---` 再渲染，表格块（以 `|` 开头）不插分割线 | [MarkdownRenderer](../core/src/infrastructure/MarkdownRenderer.scala)（toHtml、toHtmlForDisplay、insertParagraphSeparators、isParagraphBlock） |
| 组装 output_html | 节点 result.data 展平为前端字段时：对 `output` 调 `MarkdownRenderer.toHtmlForDisplay(out)` 得到 `output_html`，与 `output`、`tool_used` 一并写入 state.data[nodeId] | [GraphSnapshotAssembler.nodeDataToFrontend](../core/src/application/GraphSnapshotAssembler.scala)、[toolCallNodeToFrontendData](../core/src/application/GraphSnapshotAssembler.scala) |
| 前端优先用 HTML | 图视图/待办视图展示节点「输出」时：若存在 `output_html` 则直接插入 DOM（.conclusion-output）；否则用前端 marked 解析 `output` 得到 HTML（fallback） | [graph.js](../desktop/src/views/graph.js)（taskData.output_html / conclusion.output_html）、[todo.js](../desktop/src/views/todo.js)（executionResult.output_html） |
| 前端 fallback | 无 output_html 时（如旧 API 或 GetTaskConclusion 未带 output_html）：`formatOutputAsMarkdown(output)`，内层对「调用结果」后 JSON 数组做 replaceStructuredJsonWithMarkdown 转表格，再 marked.parse；marked 配置（gfm、breaks）在模块加载时设一次 | [formatOutput.js](../desktop/src/utils/formatOutput.js) |

**数据流小结**

| 数据 | 来源 | 去向 |
|------|------|------|
| output | 节点执行结果 data["output"] 或 tool 返回文本 | GraphSnapshotAssembler 展平 → state.data[nodeId].output；同时用于生成 output_html |
| output_html | MarkdownRenderer.toHtmlForDisplay(output) | state.data[nodeId].output_html → 前端优先注入 .conclusion-output |
| 样式 | .task-conclusion-content .conclusion-output 下的 table/h1/p/ul 等 | [app.css](../desktop/src/app.css)（表格、标题、列表、代码块等） |
