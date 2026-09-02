# Guia de backlog para PO e Project Manager no Trello

Este guia ensina uma pessoa com pouca experiência em metodologias ágeis a organizar o backlog do SecureDelivery. O processo é **híbrido e inspirado em Scrum**, usando um **quadro Kanban para fluxo contínuo**, comunicação assíncrona por mensagens e encontros aproximadamente quinzenais.

## Nome honesto do processo

O SecureDelivery não executa Scrum formalmente, pois não terá Daily Scrum nem todos os eventos prescritos pelo framework. Internamente, o time pode dizer “Scrum adaptado”, mas em documentação e avaliação de processo prefira:

```text
Processo híbrido inspirado em Scrum, com fluxo Kanban
```

Do Scrum, preservamos ideias úteis como Product Goal, Product Backlog ordenado, responsabilidade clara do PO, inspeção do resultado e retrospectiva. Do Kanban, usamos fluxo contínuo, trabalho puxado, limites WIP e atenção ao tempo de ciclo.

Não existe obrigação de produzir mensagens diárias ou reuniões apenas para manter o nome Scrum.

## A decisão mais importante

Use **um backlog de produto**, não três backlogs independentes para Server, Mobile e Dashboard.

O cliente percebe capacidades completas, como “ativar uma SmartBox” ou “investigar um impacto”. Essas capacidades normalmente atravessam contratos e mais de um repositório. Separar o backlog por tecnologia facilita produzir três partes que individualmente parecem concluídas, mas ainda não entregam valor.

Quando partes técnicas puderem avançar separadamente:

```text
História de produto
  ├── cartão CONTRACT
  ├── cartão SERVER
  ├── cartão MOBILE
  └── cartão DASHBOARD
```

Vincule os cartões técnicos à história. A história só fica `Done` quando o fluxo necessário funciona de ponta a ponta.

## Responsabilidades

| Papel | Responsabilidade no backlog |
|---|---|
| Product Owner (PO) | comunica o objetivo do produto, ordena e torna transparente o backlog, esclarece valor e inspeciona se o resultado esperado foi alcançado |
| Project Manager (PM) | coordena planejamento e acompanhamento da entrega, dependências, riscos, comunicação, alinhamento com stakeholders e melhoria do fluxo; não substitui a responsabilidade de produto do PO |
| Developers | definem solução técnica, divisão em tarefas, estimativas e como puxar o trabalho selecionado |
| Facilitador do processo | conduz o encontro quinzenal, evidencia bloqueios e ajuda o time a melhorar o fluxo; pode ser uma responsabilidade compartilhada |
| Stakeholders | fornecem contexto e feedback durante validações e encontros de revisão quando necessário |

Neste projeto, `PM` significa **Project Manager (Gerente de Projetos)**, e não Product Manager. O PO e o PM colaboram, mas possuem responsabilidades diferentes: o PO decide sobre valor, objetivo e ordenação do produto; o PM acompanha o plano de entrega, coordena dependências, riscos e comunicação. O PM não reordena sozinho o Product Backlog, e o PO não deve prescrever sozinho arquitetura, número de horas ou divisão técnica.

O PO pode delegar escrita ou detalhamento, mas continua responsável pela clareza e ordenação do Product Backlog.

## Criando o quadro

Nome recomendado:

```text
SecureDelivery — Produto e Entrega
```

Crie estas listas, nesta ordem:

| Lista | Para que serve | Política de saída |
|---|---|---|
| `00 — Objetivos e modelos` | objetivo do produto, objetivo do ciclo, links e cartões-modelo; não representa trabalho em fluxo | PO e PM mantêm regras e modelos de acordo com suas responsabilidades e com o que foi acordado pelo time |
| `01 — Caixa de entrada` | ideias, feedback e solicitações ainda não analisadas | existe contexto mínimo e responsável por esclarecer |
| `02 — Descoberta` | problema ainda sendo validado | problema, usuário e resultado esperado entendidos |
| `03 — Refinamento` | item sendo dividido e detalhado com o time | atende à Definition of Ready |
| `04 — Pronto / Product Backlog` | itens prontos e ordenados; o topo é mais importante | selecionado na reposição/planejamento quinzenal ou quando surgir capacidade acordada |
| `05 — Selecionado para o ciclo` | trabalho escolhido para avançar o objetivo do ciclo | Developer começa quando existe capacidade |
| `06 — Em andamento — WIP 3` | implementação ativa | PR aberto e pronto para revisão/QA |
| `07 — Revisão e QA — WIP 3` | code review, testes e integração | critérios técnicos e funcionais verificados |
| `08 — Validação de produto — WIP 2` | inspeção do resultado e dos critérios com PO/stakeholders relevantes | critérios atendidos ou devolvido com evidência objetiva |
| `09 — Concluído no ciclo` | incremento que atende à Definition of Done | inspecionado no encontro quinzenal e depois arquivado |

`WIP` é o limite de trabalho em andamento. Para uma pessoa desenvolvedora, use `WIP 1`; para um time pequeno, comece com no máximo uma atividade ativa por Developer e ajuste com dados. Não inicie trabalho novo quando a próxima etapa estiver congestionada: ajude a concluir o que já começou.

Histórias de usuário, épicos, Definition of Ready e Story Points são práticas opcionais. Quando termos formais do Scrum aparecerem como referência, seu significado original deve permanecer claro, mesmo que o processo local use “objetivo do ciclo” e “trabalho selecionado”.

Não crie uma lista “Bloqueado”, porque o cartão perde a informação de sua etapa real. Use a etiqueta vermelha `BLOQUEADO`, registre causa e próximo passo em comentário e mantenha o cartão na etapa atual.

## Etiquetas

Use prefixos para as etiquetas continuarem claras mesmo sem depender da cor.

### Área

- `ÁREA: PRODUTO/UX`
- `ÁREA: CONTRACT`
- `ÁREA: SERVER`
- `ÁREA: MOBILE`
- `ÁREA: DASHBOARD`
- `ÁREA: CI/CD/DOCS`

Um cartão pode afetar várias áreas. Marque todas as relevantes e escolha uma área principal na descrição.

### Tipo

- `TIPO: HISTÓRIA`
- `TIPO: BUG`
- `TIPO: SPIKE`
- `TIPO: DÍVIDA TÉCNICA`
- `TIPO: ÉPICO`

### Atenção

- `BLOQUEADO`
- `RISCO ALTO`
- `SEGURANÇA`
- `BREAKING CHANGE`

Não use etiquetas para substituir a ordem do backlog. Dentro de `04 — Pronto`, a prioridade é sempre de cima para baixo.

## Campos opcionais do Trello

Se o plano do Trello oferecer Custom Fields, crie apenas:

| Campo | Tipo | Valores sugeridos |
|---|---|---|
| `Tipo` | dropdown | História, Bug, Spike, Dívida, Épico |
| `Área principal` | dropdown | Produto, Contract, Server, Mobile, Dashboard, CI/CD |
| `Ciclo` | texto | exemplo: `Ciclo 03` |
| `Pontos` | número | estimativa definida pelos Developers |
| `Risco` | dropdown | Baixo, Médio, Alto |

Custom Fields são recurso de planos pagos do Trello. No plano Free, mantenha as mesmas informações no modelo da descrição e use etiquetas. Não torne o processo dependente de um recurso pago.

## Como transformar uma necessidade em backlog

### 1. Comece pelo problema

Evite começar com “criar endpoint” ou “fazer tela”. Pergunte:

- quem tem o problema?
- o que essa pessoa precisa conseguir fazer?
- por que isso importa para o MVP?
- como saberemos que funcionou?
- o que explicitamente ficará fora?

### 2. Relacione ao Product Goal

Um item deve contribuir para o objetivo atual, reduzir um risco relevante ou resolver um defeito. Ideias sem relação clara permanecem na Caixa de Entrada ou são arquivadas.

### 3. Escreva uma história orientada a resultado

Formato recomendado:

```text
Como <tipo de usuário ou ator>,
quero <capacidade>,
para <resultado ou benefício>.
```

Exemplo:

```text
Como Customer,
quero ativar uma SmartBox lendo seu QR Code,
para associá-la com segurança à minha organização.
```

Nem todo item precisa forçar uma história artificial. Bugs, spikes e manutenção técnica usam seus próprios modelos.

### 4. Escreva critérios observáveis

Use `Dado / Quando / Então` quando ajudar:

```text
Dado que o material de ativação é válido e ainda não foi usado,
quando um Customer autenticado confirma a ativação,
então o Device é associado ao Customer correto e fica ACTIVE.
```

Inclua cenários de falha relevantes, como expirado, já utilizado, sem permissão, offline ou tentativa de outro Customer.

### 5. Mapeie componentes e dependências

Use esta ordem para uma mudança compartilhada:

```text
CONTRACT
  -> SERVER
  -> clientes tipados, quando existirem
  -> MOBILE e/ou DASHBOARD
  -> teste integrado e aceite
```

Essa ordem não significa que todo trabalho precisa ser sequencial. Depois que o contrato está acordado, Server, Mobile e Dashboard podem avançar em paralelo com mocks confiáveis.

## Como dividir por Server, Mobile e Dashboard

| Área | Crie trabalho quando a história exige | Exemplos |
|---|---|---|
| CONTRACT | comunicação ou semântica compartilhada entre repositórios | endpoint, payload, evento realtime, versionamento |
| SERVER | estado persistente, regra de negócio, RBAC, ingestão ou processamento central | autorização, DeviceRequest, telemetria, tickets |
| MOBILE | comportamento do Device, sensores, detecção, persistência local ou sincronização | IMU, evidência, offline, retry, QR da SmartBox |
| DASHBOARD | interação humana, gestão, apresentação ou suporte | telas, estados de loading/error, eventos, notificações |

Crie um cartão técnico separado quando houver pelo menos uma destas condições:

- terá responsável ou PR diferente;
- pode iniciar, bloquear ou terminar em momento diferente;
- precisa de estimativa ou evidência própria;
- possui dependência explícita com outro componente.

Use somente uma checklist dentro da história quando o trabalho for pequeno, feito pela mesma pessoa/PR e não precisar de estado independente. Não transforme cada arquivo ou função em cartão.

Todo cartão técnico deve apontar para a história de produto. A história deve listar todos os cartões técnicos necessários, evitando “trabalho órfão” que ninguém consegue relacionar a um objetivo.

## Modelo de cartão: história de produto

Crie um cartão-modelo em `00 — Objetivos e modelos` com esta descrição:

```markdown
## História
Como <persona/ator>, quero <capacidade>, para <benefício>.

## Problema e resultado esperado
<Por que isso importa e qual mudança esperamos observar?>

## Dentro do escopo
- <resultado necessário>

## Fora do escopo
- <algo explicitamente não incluído>

## Critérios de aceite
- [ ] Dado <contexto>, quando <ação>, então <resultado>.
- [ ] Cenário de erro/indisponibilidade definido.
- [ ] RBAC e isolamento de Customer verificados quando aplicável.
- [ ] Comportamento offline/retry definido quando aplicável.

## Áreas afetadas
- [ ] CONTRACT
- [ ] SERVER
- [ ] MOBILE
- [ ] DASHBOARD
- [ ] DOCUMENTAÇÃO/CI

## Dependências e cartões vinculados
- <link e relação: bloqueia, é bloqueado por ou relacionado>

## Evidências para aceite
- <teste, vídeo, screenshot, resposta da API ou roteiro demonstrável>

## Observações
- Contrato/ADR:
- UX:
- Segurança/privacidade:
- Telemetria/eventos:
```

O título segue:

```text
[HISTÓRIA] Customer ativa SmartBox por QR Code
```

## Modelo de cartão: trabalho técnico vinculado

```markdown
## História/épico de origem
<link para o cartão de produto>

## Objetivo técnico
<resultado técnico necessário, sem reescrever a história inteira>

## Escopo
- <mudança concreta>

## Critérios técnicos
- [ ] testes relevantes adicionados/atualizados
- [ ] lint, testes e build passam
- [ ] contrato canônico respeitado
- [ ] logs não expõem secrets ou dados sensíveis
- [ ] documentação atualizada quando aplicável

## Dependências
- <links para CONTRACT, SERVER, MOBILE ou DASHBOARD>

## Evidência
- PR:
- resultado do CI:
```

Títulos:

```text
[CONTRACT] Definir ativação com segredo no body
[SERVER] Implementar validação e confirmação da ativação
[MOBILE] Exibir QR e trocar material por credencial
[DASHBOARD] Capturar fragmento e confirmar ativação
```

## Modelo de cartão: bug

```markdown
## Problema observado
<o que aconteceu>

## Impacto
<quem é afetado e qual o prejuízo>

## Como reproduzir
1. ...

## Resultado atual
...

## Resultado esperado
...

## Evidência
<logs redigidos, screenshot, vídeo, requestId; nunca secrets>

## Critérios de aceite
- [ ] problema não é mais reproduzível
- [ ] teste de regressão existe quando viável
- [ ] comportamento relacionado continua funcionando
```

Se houver incidente de segurança ou produção, priorize imediatamente. “Urgente” não deve ser usado para contornar refinamento normal.

## Modelo de cartão: spike

Spike é uma investigação com tempo limitado, usada quando a incerteza impede planejar uma solução.

```markdown
## Pergunta a responder
<uma pergunta objetiva>

## Timebox
<limite acordado, por exemplo 1 dia>

## Opções a comparar
- ...

## Critérios de conclusão
- [ ] recomendação registrada
- [ ] evidência ou protótipo anexado
- [ ] riscos e perguntas restantes listados
- [ ] novos cartões de entrega criados se necessário
```

Spike não entrega funcionalidade e não deve ficar aberto indefinidamente.

## Definition of Ready

Um cartão entra em `04 — Pronto` somente quando:

- usuário/ator, problema e valor estão claros;
- critérios de aceite são testáveis;
- dentro e fora do escopo estão explícitos;
- áreas afetadas e dependências conhecidas estão marcadas;
- necessidade de contrato ou ADR foi identificada;
- implicações de RBAC, Customer, segurança, offline e telemetria foram discutidas quando aplicáveis;
- o time entende o item o suficiente para estimá-lo;
- o item é pequeno o suficiente para avançar significativamente em um ciclo; se não for, foi dividido.

Definition of Ready é uma política do time, não um artefato obrigatório do Scrum.

## Definition of Done

Um cartão só vai para `09 — Concluído no ciclo` quando tudo que se aplica estiver pronto:

- critérios de aceite atendidos;
- contrato canônico atualizado primeiro quando compartilhado;
- implementação revisada;
- testes, lint e build aprovados;
- CI verde;
- integrações necessárias entre repositórios verificadas;
- RBAC e isolamento de Customer testados;
- offline, retry e idempotência testados quando aplicáveis;
- documentação pt-BR e English atualizada quando a regra compartilhada mudou;
- termo novo explicado no glossário quando necessário;
- PRs e evidências vinculados;
- resultado funcional inspecionado com o PO quando a história exige validação de produto;
- não existem defeitos críticos conhecidos escondidos no cartão.

Um componente técnico concluído não torna a história de produto `Done` se o fluxo de ponta a ponta ainda não funciona.

A Definition of Done é o padrão de qualidade do Incremento; ela não pode depender apenas da opinião ou disponibilidade do PO. A validação de produto confirma critérios e resultado esperado, enquanto os Developers continuam responsáveis por criar um Incremento que atende à Definition of Done.

## Priorização simples

O PO ordena o backlog usando esta sequência de perguntas:

1. protege segurança, privacidade ou integridade de dados?
2. desbloqueia outros itens importantes?
3. entrega ou valida valor central do MVP?
4. reduz uma incerteza de alto risco?
5. possui dependência externa ou compromisso real de data?
6. qual o esforço e risco técnico informados pelos Developers?

O topo de `04 — Pronto` é a decisão final de prioridade. Evite fórmulas complexas no início.

## Estimativa

Estimativa pertence aos Developers. O PO explica valor e urgência; não converte pontos em cobrança individual de horas.

Se o time quiser Story Points, uma escala inicial simples é:

```text
1, 2, 3, 5, 8
```

Itens acima de 8 devem normalmente ser divididos. Pontos representam combinação de esforço, complexidade e incerteza. Velocidade serve para previsão do próprio time, nunca para comparar pessoas ou equipes.

## Cadência real do SecureDelivery

Não há Daily Scrum. O trabalho e a ajuda do time acontecem de forma assíncrona, e o encontro principal ocorre aproximadamente a cada duas semanas. O intervalo pode mudar quando houver feriados, ausência de pauta ou necessidade relevante; o quadro continua sendo atualizado durante todo o período.

### Encontro quinzenal integrado

Duração inicial sugerida: 90 a 120 minutos.

| Parte | Tempo de referência | Resultado |
|---|---:|---|
| Revisão do que foi entregue | 20 min | resultado demonstrado, feedback e itens concluídos confirmados |
| Fluxo, bloqueios e métricas | 10 min | gargalos e ajudas necessárias evidenciados |
| Retrospectiva curta | 15 min | uma ou duas melhorias práticas acordadas |
| Refinamento do topo | 25–40 min | itens mais importantes entendidos e divididos |
| Reposição e objetivo do próximo ciclo | 20–30 min | objetivo do ciclo e trabalho selecionado com respeito ao WIP |

Stakeholders participam da parte de revisão quando seu feedback for útil; não precisam permanecer em discussões internas. A reunião pode ser menor quando a pauta for simples.

### Reuniões adicionais

Marque reunião fora da cadência somente quando a comunicação escrita não resolver bem:

- incidente ou risco crítico;
- decisão de contrato/arquitetura com várias alternativas;
- bloqueio envolvendo várias pessoas;
- descoberta de produto que exige conversa com stakeholder;
- conflito de entendimento que está gerando retrabalho.

Antes de marcar, publique contexto, pergunta e links dos cartões. Depois, registre decisão e próximos passos no Trello ou na documentação; a decisão não pode existir somente na memória da chamada.

## Comunicação assíncrona por mensagens

Mensagens substituem o acompanhamento diário, mas não significam relatório obrigatório todos os dias. Publique uma atualização quando:

- iniciar ou mudar a etapa de um cartão;
- precisar de ajuda ou decisão;
- identificar bloqueio, risco ou mudança de escopo;
- abrir PR ou disponibilizar evidência para revisão;
- concluir algo que desbloqueia outra pessoa.

Modelo curto:

```text
Cartão: <link>
Avanço: <o que mudou>
Próximo passo: <ação seguinte>
Ajuda/bloqueio: <nenhum ou pedido objetivo>
Decisão necessária até: <data real, se houver>
```

Use comentário no cartão para contexto permanente. Use o canal de mensagens do time para chamar atenção e sempre inclua o link. Dúvidas podem ser respondidas por qualquer pessoa apta; decisões de produto continuam com o PO, coordenação de projeto com o PM e decisões técnicas com os responsáveis técnicos, respeitando contratos e ADRs.

O time deve combinar uma expectativa realista de resposta conforme seus horários. Bloqueios críticos são comunicados assim que percebidos; assuntos não urgentes aguardam resposta assíncrona sem interrupção constante.

### Cartão fixo: acordo de comunicação

Crie em `00 — Objetivos e modelos` um cartão chamado:

```text
[REGRA] Comunicação, ajuda e reuniões
```

Preencha e revise com o time:

```markdown
## Cadência
- encontro integrado aproximadamente a cada 2 semanas
- sem Daily Scrum e sem status diário obrigatório

## Onde comunicar
- decisões e contexto permanente: comentário no cartão Trello
- pedido de ajuda/atenção: canal de mensagens + link do cartão
- contrato/arquitetura: documentação ou ADR + link no cartão

## Quando pedir ajuda
- bloqueio identificado
- dúvida que impede o próximo passo
- risco de segurança, dados ou prazo real
- dependência entre componentes sem responsável

## Expectativa de resposta
- assunto crítico: <acordo do time>
- bloqueio normal: <acordo do time>
- dúvida sem bloqueio: <acordo do time>

## Regra de registro
Decisões tomadas por mensagem ou reunião são resumidas no cartão ou documento canônico.
```

Não preencha prazos de resposta sem conversar com as pessoas e considerar disponibilidade, fuso e jornada de trabalho.

## Políticas Kanban do ciclo

- trabalho é puxado quando existe capacidade, não empurrado para cada pessoa;
- respeite os limites WIP;
- bloqueio recebe etiqueta, causa, responsável pelo próximo passo e data do último avanço;
- antes de iniciar algo novo, ajude a liberar Review/QA;
- itens urgentes mudam o trabalho selecionado apenas por decisão explícita do PO com o time;
- acompanhe cartões envelhecendo em `Em andamento` e `Revisão/QA`.

## Métricas úteis

- objetivo do ciclo atingido ou não, com motivo;
- throughput: quantidade de itens concluídos por período;
- cycle time: tempo entre iniciar e concluir;
- idade do WIP: há quanto tempo cada cartão está ativo;
- defeitos reabertos;
- percentual de histórias aceitas sem retrabalho relevante.

Não use quantidade de cartões, horas ou Story Points para avaliar produtividade individual.

## Automações mínimas do Trello

Primeiro estabilize o processo manual. Depois adicione poucas automações:

1. ao mover para `Em andamento`, registrar data de início e remover etiqueta de bloqueio antiga;
2. ao adicionar `BLOQUEADO`, publicar comentário pedindo causa e próximo passo;
3. ao mover para `Concluído no ciclo`, marcar a data de entrega como concluída;
4. perto do encontro quinzenal, criar um lembrete para revisão, métricas e arquivamento dos cartões concluídos.

As automações customizadas do Trello são configuradas em inglês e possuem limites conforme o plano. Não automatize prioridade, aceite do PO ou decisões de segurança.

## Exemplo completo: ativação de SmartBox

### História

```text
[HISTÓRIA] Customer ativa SmartBox por QR Code
```

Critérios essenciais:

- QR não revela identificador interno como credencial;
- segredo fica no fragmento do link e é enviado apenas em body JSON;
- Customer precisa estar autenticado para confirmar;
- token expirado, inválido ou usado retorna erro compreensível;
- Device troca o material uma única vez por credencial própria;
- associação respeita isolamento de Customer;
- logs, traces e erros não contêm o segredo;
- fluxo completo possui evidência de teste.

Cartões vinculados:

```text
[CONTRACT] Contrato body-based de ativação
[SERVER] Validar, confirmar e trocar credencial
[MOBILE] Gerar/exibir QR e armazenar credencial
[DASHBOARD] Ler fragmento e conduzir confirmação
[QA] Validar fluxo integrado e cenários de erro
```

A história permanece em `Revisão/QA` ou `Validação de produto` até o comportamento integrado estar demonstrável.

## Épicos iniciais do SecureDelivery

Use estes temas para extrair histórias verticais, não como cartões gigantes de implementação:

1. fundação de desenvolvimento, contratos e CI;
2. autenticação humana, RBAC e isolamento de Customer;
3. ciclo de vida, ativação e credenciais de Device;
4. solicitação de SmartBox (`DeviceRequest`);
5. ciclo de MonitoringSession;
6. aquisição local de sensores e persistência Mobile;
7. telemetria enxuta, offline e sincronização idempotente;
8. detecção de eventos e preservação de evidência;
9. monitoramento, saúde e eventos no Dashboard;
10. tickets, chat de suporte e notificações;
11. segurança, observabilidade, testes integrados e preparação de release.

Sequência inicial recomendada:

```text
fundação e contratos
  -> autenticação e Devices
  -> monitoramento Mobile
  -> ingestão e sincronização
  -> experiência Dashboard
  -> suporte e notificações
  -> hardening e release
```

## Higiene do backlog

Uma vez por semana, PO e PM devem revisar o quadro em conjunto. O PO responde pela ordenação e clareza do produto; o PM acompanha fluxo, dependências, riscos e comunicação. Nessa revisão, devem:

- revisar a Caixa de Entrada;
- remover duplicatas;
- arquivar ideias sem relação com o Product Goal atual;
- manter somente o topo detalhado;
- confirmar dependências e riscos;
- dividir itens grandes;
- garantir que existam itens Ready suficientes para a próxima reposição de trabalho;
- não preencher meses de especificação detalhada que provavelmente mudará.

## Antipadrões

Evite:

- um quadro separado por repositório sem visão de produto;
- cartão “fazer backend” sem resultado ou critério de aceite;
- mover para Done porque o código foi escrito, mas não integrado;
- usar prazo em todo cartão como falsa prioridade;
- iniciar muitos itens e concluir poucos;
- criar check-in diário obrigatório disfarçado de mensagem;
- usar Story Points para medir pessoas;
- esconder bloqueio em comentário antigo;
- automatizar um processo que o time ainda não entende;
- colocar secrets, dados reais de cliente ou tokens em cartões.

## Referências

- [Scrum Guide oficial](https://scrumguides.org/scrum-guide.html)
- [Documentação oficial do Trello](https://support.atlassian.com/trello/docs/using-trello)
- [Custom Fields no Trello](https://support.atlassian.com/trello/docs/using-custom-fields/)
- [Automações do Trello](https://support.atlassian.com/trello/docs/create-and-manage-automations/)
- [Glossário bilíngue do SecureDelivery](../terminology.md)
- [Produto e MVP](produto-e-mvp.md)
- [Guia de desenvolvimento](guia-de-desenvolvimento.md)
