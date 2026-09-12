# SecureDelivery terminology / Terminologia do SecureDelivery

This beginner-friendly glossary is intentionally bilingual. Protocol names and code identifiers stay in English; explanations are available in English and Brazilian Portuguese.

Este glossário bilíngue foi escrito para iniciantes. Nomes de protocolos e identificadores de código permanecem em inglês; as explicações estão em inglês e português brasileiro.

## Project and product / Projeto e produto

| Term | English | Português (Brasil) |
|---|---|---|
| **MVP** — Minimum Viable Product | The smallest product version that can test the main value with real users. It is not expected to contain every future feature. | Produto Mínimo Viável: a menor versão capaz de validar o valor principal com usuários reais. Não precisa conter tudo que o produto terá no futuro. |
| **PM** — Project Manager | Person responsible for coordinating project planning, delivery follow-up, dependencies, risks, communication and stakeholder alignment. In SecureDelivery, PM does not mean Product Manager. | Gerente de Projetos: pessoa responsável por coordenar planejamento, acompanhamento da entrega, dependências, riscos, comunicação e alinhamento com stakeholders. No SecureDelivery, PM não significa Product Manager. |
| **PO** — Product Owner | Person accountable for product value, the Product Goal, ordering and clarifying the Product Backlog, and inspecting whether delivered outcomes meet the expected need. It is distinct from the Project Manager role. | Dono do Produto: pessoa responsável pelo valor do produto, Objetivo do Produto, ordenação e clareza do Product Backlog e inspeção do resultado entregue. É um papel diferente do Gerente de Projetos. |
| **QA** — Quality Assurance | Practices and people focused on preventing defects and verifying quality. | Garantia de Qualidade: práticas e pessoas focadas em prevenir defeitos e verificar qualidade. |
| **Device** | Canonical technical entity that collects and sends SecureDelivery data. In the MVP it is a smartphone. | Entidade técnica canônica que coleta e envia dados. No MVP, é um smartphone. |
| **SmartBox** | Product-facing name shown to users for a Device. It is not used in API paths or shared DTOs. | Nome de produto exibido ao usuário para um Device. Não é usado em rotas da API ou DTOs compartilhados. |
| **Customer / tenant** | A Customer is an organization using the platform. “Tenant” emphasizes that its data must be isolated from every other Customer. | Customer é uma organização que usa a plataforma. “Tenant” destaca que seus dados devem ficar isolados dos demais clientes. |
| **Cargo integrity** | Whether transported goods remained within acceptable physical conditions. | Integridade da carga: se os itens transportados permaneceram em condições físicas aceitáveis. |

## Architecture and development / Arquitetura e desenvolvimento

| Term | English | Português (Brasil) |
|---|---|---|
| **ADR** — Architecture Decision Record | A short document recording an important technical decision, its context and consequences. | Registro de Decisão Arquitetural: documento curto com uma decisão técnica importante, seu contexto e consequências. |
| **API** — Application Programming Interface | A defined way for software components to communicate. | Interface de Programação de Aplicações: forma definida para sistemas se comunicarem. |
| **REST** — Representational State Transfer | A common style for HTTP APIs based on resources and standard HTTP methods. | Estilo comum de API HTTP baseado em recursos e métodos HTTP padronizados. |
| **HTTP / HTTPS** | Protocol used for web requests. HTTPS is HTTP protected with encryption and server authentication. | Protocolo usado em requisições web. HTTPS é HTTP protegido por criptografia e autenticação do servidor. |
| **WebSocket** | A persistent connection that lets Server and client exchange realtime signals. | Conexão persistente que permite ao Server e cliente trocarem sinais em tempo real. |
| **JSON** — JavaScript Object Notation | Text format used for most API payloads. | Formato de texto usado na maioria dos payloads da API. |
| **YAML** — YAML Ain't Markup Language | Human-readable configuration format used by OpenAPI, AsyncAPI and CI workflows here. Indentation is significant. | Formato legível usado em OpenAPI, AsyncAPI e workflows de CI. A indentação faz parte da estrutura. |
| **OpenAPI** | Machine-readable description of the HTTP API: paths, requests, responses and schemas. | Descrição legível por máquinas da API HTTP: rotas, requisições, respostas e schemas. |
| **AsyncAPI** | Machine-readable description of asynchronous or realtime messages. | Descrição legível por máquinas das mensagens assíncronas ou em tempo real. |
| **DTO** — Data Transfer Object | A typed data shape used to move information across a boundary, such as an API request. | Objeto de Transferência de Dados: formato tipado usado para transportar informação, como o corpo de uma requisição. |
| **Schema** | Formal definition of allowed fields, types and validation rules. | Definição formal dos campos, tipos e regras de validação permitidos. |
| **Payload** | The useful data carried by a request, response or message. | Conteúdo útil transportado por uma requisição, resposta ou mensagem. |
| **UUID** — Universally Unique Identifier | Opaque identifier designed to be unique without a central numeric sequence. | Identificador opaco projetado para ser único sem depender de uma sequência numérica central. |
| **UTC** — Coordinated Universal Time | Global time reference used by contract timestamps; avoids local timezone ambiguity. | Referência global usada nos timestamps; evita ambiguidades de fuso horário. |
| **ISO 8601** | Standard text representation for dates and times, such as `2026-09-01T12:30:00Z`. | Padrão textual para datas e horários, como `2026-09-01T12:30:00Z`. |
| **Idempotency** | Retrying the same logical operation produces the same final result instead of creating duplicates. | Idempotência: repetir a mesma operação lógica mantém o mesmo resultado final, sem criar duplicatas. |
| **Batch** | A group of records sent or processed together. | Lote: grupo de registros enviado ou processado em conjunto. |
| **Modular monolith** | One deployable backend organized into clear internal modules. | Monólito modular: um único backend implantável, dividido internamente em módulos claros. |
| **Soft deletion** | Marking a record inactive/deleted while preserving its history instead of physically erasing it. | Exclusão lógica: marcar um registro como removido/inativo sem apagar seu histórico fisicamente. |

## Security and access / Segurança e acesso

| Term | English | Português (Brasil) |
|---|---|---|
| **RBAC** — Role-Based Access Control | Permissions granted according to roles such as `ADMIN` and `CUSTOMER`. | Controle de Acesso Baseado em Papéis: permissões definidas por papéis como `ADMIN` e `CUSTOMER`. |
| **Authentication** | Proving who a user or Device is. | Autenticação: comprovar quem é o usuário ou Device. |
| **Authorization** | Deciding what an authenticated identity may do. | Autorização: decidir o que uma identidade autenticada pode fazer. |
| **Bearer token** | Secret presented with a request; whoever possesses a valid token may exercise its scoped permissions. | Token portador: segredo enviado na requisição; quem possui um token válido pode exercer as permissões limitadas dele. |
| **JWT** — JSON Web Token | A signed token format that can carry identity and authorization claims. Not every bearer token must be a JWT. | Formato de token assinado que pode carregar identidade e permissões. Nem todo bearer token precisa ser JWT. |
| **Access token** | Short-lived credential used to call protected APIs. | Credencial de curta duração usada para chamar APIs protegidas. |
| **Refresh token** | Credential used to obtain a new access token without logging in again. It must be stored securely. | Credencial usada para obter um novo access token sem novo login. Deve ser armazenada com segurança. |
| **Bootstrap secret / activation material** | High-entropy code used only to activate and provision a Device credential. In this MVP it does not expire while the Device is pending, but it never authorizes Device APIs by itself. | Código de alta entropia usado somente para ativar e provisionar a credencial de um Device. Neste MVP não expira enquanto o Device aguarda ativação, mas sozinho nunca autoriza as APIs do Device. |
| **QR Code** — Quick Response Code | Machine-readable square code. Here it starts the SmartBox activation flow; it is not itself authorization. | Código quadrado legível por câmera. Aqui inicia a ativação da SmartBox; ele não é, sozinho, uma autorização. |
| **URL** — Uniform Resource Locator | Address of a web resource. Sensitive activation material must not appear in its path or query. | Endereço de um recurso web. Material sensível de ativação não pode aparecer no path ou query. |
| **URL fragment** | The part after `#`. Browsers do not send it to the web server in the HTTP request; the client can read it locally. | Parte após `#`. O navegador não a envia ao servidor na requisição HTTP; o cliente pode lê-la localmente. |

## IoT, telemetry and events / IoT, telemetria e eventos

| Term | English | Português (Brasil) |
|---|---|---|
| **IoT** — Internet of Things | Physical devices with software and connectivity that collect or exchange data. | Internet das Coisas: dispositivos físicos com software e conectividade que coletam ou trocam dados. |
| **IMU** — Inertial Measurement Unit | Sensor unit containing accelerometer and usually gyroscope data for motion/orientation analysis. | Unidade de Medição Inercial: conjunto com acelerômetro e normalmente giroscópio para analisar movimento/orientação. |
| **GPS** — Global Positioning System | One satellite navigation system. The term is often used informally for location in general. | Sistema de Posicionamento Global: um dos sistemas de navegação por satélite; informalmente usado como sinônimo de localização. |
| **GNSS** — Global Navigation Satellite System | General term covering GPS and other satellite navigation constellations. | Sistema Global de Navegação por Satélite: termo geral que inclui GPS e outras constelações. |
| **Telemetry** | Measurements and operational state sent by a remote Device. | Telemetria: medições e estado operacional enviados por um Device remoto. |
| **Observation** | One extensible measured value identified by a namespaced key. | Observação: um valor medido extensível, identificado por uma chave com namespace. |
| **Namespaced key** | Structured name such as `motion.acceleration.x` that reduces naming collisions and groups meaning. | Nome estruturado como `motion.acceleration.x`, usado para agrupar significado e evitar colisões. |
| **Event** | A notable condition detected by the Device, such as a strong impact. | Evento: condição relevante detectada pelo Device, como um impacto forte. |
| **Evidence window** | High-frequency samples preserved before, during and after a detected event. | Janela de evidência: amostras de alta frequência preservadas antes, durante e depois de um evento. |
| **Store-and-forward** | Save data locally when offline and forward it later when connectivity returns. | Armazenar e encaminhar: salvar localmente sem conexão e enviar depois quando a rede voltar. |
| **Offline-first** | Design in which core operation continues without network access. | Projeto em que a operação principal continua mesmo sem acesso à rede. |
| **KPI** — Key Performance Indicator | A defined metric used to understand product or operational performance. | Indicador-Chave de Desempenho: métrica definida para entender desempenho operacional ou do produto. |
| **Hz** — hertz | Number of samples or cycles per second. `50 Hz` means 50 samples each second. | Hertz: quantidade de amostras ou ciclos por segundo. `50 Hz` significa 50 amostras por segundo. |
| **MiB** — mebibyte | Binary storage unit equal to 1,048,576 bytes. `50 MiB` is the hard local payload budget used by Mobile. | Unidade binária de armazenamento equivalente a 1.048.576 bytes. `50 MiB` é o limite rígido de payloads locais usado pelo Mobile. |
| **Backoff** | Retry strategy that progressively increases the wait after repeated failures, reducing load during an outage. The initial MVP uses a fixed one-minute interval instead, while honoring `Retry-After`. | Estratégia que aumenta progressivamente a espera após falhas repetidas, reduzindo carga durante uma indisponibilidade. O MVP inicial usa intervalo fixo de um minuto e respeita `Retry-After`. |
| **Retry-After** | Server instruction telling a client how long to wait before trying again. | Instrução do Server indicando quanto o cliente deve esperar antes de tentar novamente. |
| **Thermal status** | Android's hardware-aware heat severity signal. SecureDelivery stops monitoring at `SEVERE` or worse instead of assuming one raw temperature is safe for every phone. | Estado térmico: sinal do Android que considera o hardware para indicar a gravidade do aquecimento. O SecureDelivery para em `SEVERE` ou pior, em vez de presumir uma temperatura bruta segura para todo celular. |

## Agile product delivery / Entrega ágil de produto

| Term | English | Português (Brasil) |
|---|---|---|
| **Scrum** | Lightweight framework in which a small team delivers and inspects a usable Increment within fixed-length Sprints. | Framework leve em que um time pequeno entrega e inspeciona um Incremento utilizável em Sprints de duração fixa. |
| **Kanban** | Method for visualizing workflow, limiting work in progress and improving flow. | Método para visualizar o fluxo, limitar trabalho em andamento e melhorar a entrega. |
| **Hybrid process / processo híbrido** | A deliberately adapted operating model combining selected practices from more than one method. SecureDelivery is inspired by Scrum but uses continuous Kanban flow, no Daily Scrum and roughly biweekly meetings. | Modelo de trabalho deliberadamente adaptado, combinando práticas de mais de um método. O SecureDelivery se inspira em Scrum, mas usa fluxo Kanban contínuo, não possui Daily Scrum e realiza reuniões aproximadamente quinzenais. |
| **Asynchronous communication** | Collaboration through messages and recorded context without requiring everyone to be present at the same time. | Comunicação assíncrona: colaboração por mensagens e contexto registrado, sem exigir que todos estejam presentes ao mesmo tempo. |
| **Cadence** | Expected rhythm for recurring review or planning activities; it need not stop continuous work between meetings. | Cadência: ritmo esperado para atividades recorrentes de revisão ou planejamento; não interrompe o fluxo contínuo entre reuniões. |
| **Replenishment** | Selecting ready work to enter the active flow when capacity is available. | Reposição: seleção de trabalho pronto para entrar no fluxo ativo quando existe capacidade. |
| **Blocker** | Condition preventing an item from progressing and requiring an explicit next action or assistance. | Bloqueio: condição que impede o avanço de um item e exige ajuda ou próximo passo explícito. |
| **Product Goal** | Long-term objective describing the future product state the Scrum Team is working toward. | Objetivo do Produto: estado futuro que o Scrum Team busca alcançar. |
| **Product Backlog** | Emergent, ordered list of what is needed to improve the product. | Backlog do Produto: lista ordenada e evolutiva do que é necessário para melhorar o produto. |
| **Sprint** | Fixed-length Scrum event, one month or less, in which ideas are turned into value. | Evento Scrum de duração fixa, de no máximo um mês, no qual ideias são transformadas em valor. |
| **Sprint Goal** | Single objective that gives the Sprint coherence and flexibility about the exact work. | Objetivo da Sprint: objetivo único que dá coerência à Sprint e permite flexibilidade sobre o trabalho exato. |
| **Sprint Backlog** | Sprint Goal, selected Product Backlog items and the Developers' delivery plan. | Backlog da Sprint: Objetivo da Sprint, itens selecionados e plano dos Developers para entregar. |
| **Increment** | Concrete, usable step toward the Product Goal that meets the Definition of Done. | Incremento: passo concreto e utilizável em direção ao Product Goal que atende à Definition of Done. |
| **Epic** | Large product theme that must be split into smaller deliverable items. It is a planning convention, not a required Scrum artifact. | Épico: tema grande que deve ser dividido em itens menores entregáveis. É uma convenção, não um artefato obrigatório do Scrum. |
| **User Story** | Short description of a desired capability from an actor's perspective, usually including the expected benefit. | História de usuário: descrição curta de uma capacidade sob a perspectiva de um ator, normalmente incluindo o benefício. |
| **Acceptance Criteria** | Observable conditions that clarify when an item behaves as expected. | Critérios de aceite: condições observáveis que esclarecem quando um item funciona como esperado. |
| **DoR** — Definition of Ready | Team policy describing when an item is understood enough to be selected. It is not required by Scrum. | Definição de Pronto para Iniciar: política do time que indica quando um item está claro para ser selecionado. Não é obrigatória no Scrum. |
| **DoD** — Definition of Done | Formal quality description of the state an Increment must reach to be considered complete. | Definição de Concluído: descrição formal da qualidade necessária para considerar um Incremento concluído. |
| **WIP** — Work in Progress | Work already started but not yet finished. Limiting WIP helps the team finish before starting more. | Trabalho em Andamento: trabalho iniciado e ainda não concluído. Limitar WIP ajuda a concluir antes de começar mais. |
| **Refinement** | Ongoing activity of clarifying, ordering and splitting Product Backlog items. | Refinamento: atividade contínua de esclarecer, ordenar e dividir itens do Product Backlog. |
| **Spike** | Time-limited investigation used to reduce uncertainty before delivery work. | Investigação com tempo limitado usada para reduzir incerteza antes da implementação. |
| **Story Points** | Relative estimate combining effort, complexity and uncertainty; not a measure of individual productivity. | Pontos de História: estimativa relativa de esforço, complexidade e incerteza; não mede produtividade individual. |
| **Velocity** | Amount of estimated work a team completed in past Sprints, useful only for that team's forecasting. | Velocidade: volume estimado concluído pelo time em Sprints anteriores, útil somente para previsão do próprio time. |
| **Throughput** | Number of work items completed in a period. | Vazão: quantidade de itens concluídos em determinado período. |
| **Cycle time** | Elapsed time from starting one item until it is finished. | Tempo de ciclo: tempo entre iniciar e concluir um item. |

## Delivery automation / Automação de entrega

| Term | English | Português (Brasil) |
|---|---|---|
| **CI** — Continuous Integration | Automatic validation of every proposed change, usually lint, tests and build. | Integração Contínua: validação automática de cada mudança, normalmente lint, testes e build. |
| **CD** — Continuous Delivery/Deployment | Delivery prepares a releasable artifact; deployment also publishes it to an environment. SecureDelivery requires manual production approval. | Entrega/Implantação Contínua: delivery prepara algo publicável; deployment também publica em um ambiente. SecureDelivery exige aprovação manual em produção. |
| **Pipeline / workflow** | Ordered automated steps executed by a CI/CD service. | Pipeline ou workflow: sequência ordenada de passos automáticos executados por um serviço de CI/CD. |
| **GitHub Actions** | GitHub service that runs the SecureDelivery CI workflow. | Serviço do GitHub que executa o workflow de CI do SecureDelivery. |
| **Runner** | Temporary machine that executes a workflow job. | Máquina temporária que executa um job do workflow. |
| **Job / step** | A job runs on one runner; steps are the commands inside that job. | Um job roda em um runner; steps são os comandos executados dentro do job. |
| **Artifact** | File or package produced by a build and kept for testing or release. | Artefato: arquivo ou pacote produzido por um build e guardado para teste ou publicação. |
| **Environment** | Isolated deployment target, commonly local, staging or production. | Ambiente: destino isolado de implantação, normalmente local, staging ou produção. |
| **Staging** | Production-like environment used for final validation before real users. | Homologação: ambiente semelhante à produção para validação final antes dos usuários reais. |
| **Production** | Live environment used by real customers. | Produção: ambiente real utilizado pelos clientes. |
| **Secret** | Sensitive value stored by the CI/CD platform, such as a deployment credential. It must not be committed. | Segredo: valor sensível armazenado pela plataforma de CI/CD, como uma credencial de deploy. Nunca deve ser commitado. |
| **Lint** | Automated check for formatting, style and suspicious code patterns. | Verificação automática de formatação, estilo e padrões suspeitos no código. |
| **Build** | Process that converts source code into a runnable or deployable form. | Processo que transforma código-fonte em algo executável ou implantável. |
| **PR** — Pull Request | Proposed change reviewed and validated before it is merged. | Pull Request: mudança proposta, revisada e validada antes de entrar no branch principal. |

## Maintenance rule / Regra de manutenção

Add a term when it appears in project documentation and a beginner may reasonably not understand it. Prefer a plain explanation over a dictionary definition, and update both languages in the same change.

Adicione um termo quando ele aparecer na documentação e uma pessoa iniciante puder não entendê-lo. Prefira uma explicação simples a uma definição de dicionário e atualize os dois idiomas na mesma mudança.
