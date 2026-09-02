# Guia de desenvolvimento

## Mapa do workspace

| Repositório | Responsabilidade principal |
|---|---|
| `securedelivery-server` | estado persistente, autenticação, RBAC, ingestão, tickets, notificações e realtime |
| `securedelivery-mobile` | sensores, detecção local, evidência, persistência offline, lotes e sincronização |
| `securedelivery-dashboard` | gestão, monitoramento, eventos, solicitações, notificações e suporte |

Antes de uma mudança entre repositórios, execute `./scripts/refresh-local-workspace.sh`, leia o `AGENTS.md` da raiz, o `AGENTS.md` do repositório alvo, sua arquitetura e os contratos/ADRs envolvidos. Preserve avisos de branch divergente ou com alterações locais.

## Ordem de uma mudança compartilhada

1. Atualize primeiro o contrato canônico em [`docs/contracts`](../contracts/README.md).
2. Classifique compatibilidade e ajuste a versão quando necessário.
3. Atualize o Server.
4. Atualize ou regenere clientes tipados.
5. Atualize Mobile e Dashboard afetados.
6. Cubra regras e falhas com testes.
7. Atualize ADRs e os dois idiomas quando a explicação pública mudar.

Não crie payloads locais que contradigam OpenAPI ou AsyncAPI.

## Invariantes que devem permanecer verdadeiros

### Identidade e segurança

- APIs humanas usam `UserBearerAuth`; ingestão do Device usa `DeviceBearerAuth` limitado a um `deviceId`.
- O Server aplica RBAC e isolamento de Customer em HTTP e WebSocket.
- Segredos de ativação existem somente em corpos JSON; nunca em path, query, log, trace ou mensagem de erro.
- O QR web pode usar fragmento de URL. O cliente captura o valor localmente, limpa o histórico visível e envia o segredo no corpo.

### Telemetria

- IMU: 50 Hz local; GPS/velocidade: até 1 Hz local; resumo normal: um minuto.
- O Device cria e persiste `monitoringSessionId`, `batchId` e `eventId` antes de transmitir.
- Retries preservam os mesmos identificadores.
- `navigation.status/source` e métricas obedecem à versão 3; valores desconhecidos são `null`, não zero.
- Somente números confiáveis entram nos KPIs.
- `observations[]` e `eventType` continuam extensíveis.

### DeviceRequest

- Somente `PENDING` pode mudar de estado.
- `fulfill` é administrativo, exige `deviceId` elegível e grava `fulfilledDeviceId/fulfilledAt` atomicamente.
- `cancel` exige motivo; Customer cancela somente solicitação própria, e administradores seguem RBAC.
- `FULFILLED` e `CANCELLED` são terminais e auditáveis.

## Checklist antes de entregar

- contratos validam sem erro;
- exemplos usam a versão atual do envelope;
- nenhum segredo aparece em URL;
- estados inválidos retornam erro consistente, sem sobrescrever auditoria;
- dados offline sincronizam de forma idempotente;
- um Customer não lê dados de outro;
- eventos desconhecidos têm fallback seguro no Dashboard;
- documentação pt-BR e English continua equivalente nas regras essenciais.

## Referências

- [Glossário bilíngue](../terminology.md)
- [CI/CD simples](ci-cd.md)
- [Guia dos contratos](guia-dos-contratos.md)
- [OpenAPI canônico](../contracts/openapi.yaml)
- [AsyncAPI canônico](../contracts/asyncapi.yaml)
- [ADRs compartilhados](../decisions/README.md)
- [Contexto detalhado](../project.md)
