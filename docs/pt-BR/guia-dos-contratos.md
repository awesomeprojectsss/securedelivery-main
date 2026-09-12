# Guia dos contratos

## O que é fonte da verdade

- [`openapi.yaml`](../contracts/openapi.yaml): operações HTTP, autenticação, corpos e respostas.
- [`asyncapi.yaml`](../contracts/asyncapi.yaml): sinais publicados em tempo real.
- [`common.md`](../contracts/common.md): IDs, tempo, enums e erros.
- [`telemetry.md`](../contracts/telemetry.md): aquisição local, resumos e retenção.
- [`events.md`](../contracts/events.md): eventos extensíveis e evidência.
- [`kpis.md`](../contracts/kpis.md): fórmulas e tratamento de dados indisponíveis.
- [`versioning.md`](../contracts/versioning.md): compatibilidade.
- [ADRs](../decisions/README.md): motivação e consequências das decisões.

OpenAPI e AsyncAPI são canônicos. Este guia traduz a intenção, mas não redefine schemas.

## Três fluxos críticos

### Ativação sem segredo na URL

1. O QR web transporta o segredo no fragmento (`#...`), não no path/query.
2. O cliente envia `{ "activationToken": "..." }` para `POST /device-activations/validate`.
3. O Customer autenticado confirma em `POST /device-activations/confirm`.
4. O Device faz a troca única em `POST /device-credentials/exchange`.
5. Logs, traces e erros sempre removem o valor.

O código tem alta entropia e não expira enquanto o Device está `PENDING_ACTIVATION`; ele pode ser validado novamente, mas não autoriza APIs do Device. A primeira confirmação ativa e associa a SmartBox. Depois disso, novas tentativas retornam `ALREADY_ACTIVATED` e nunca transferem propriedade. As tentativas são limitadas pelo Server.

### Qualidade de navegação

| `status` | `source` | Métricas |
|---|---|---|
| `VALID` | `GNSS` ou `GPS_DERIVED` | todas numéricas e não negativas |
| `PARTIAL` | `GNSS` ou `GPS_DERIVED` | ao menos uma numérica; demais `null` |
| `UNAVAILABLE` | `UNAVAILABLE` | todas `null` |

Zero significa um valor medido igual a zero. Ausência de medida significa `null`. Cada KPI inclui somente valores numéricos confiáveis.

### Transições de DeviceRequest

```text
PENDING --fulfill(deviceId)--> FULFILLED
PENDING --cancel(reason)-----> CANCELLED
```

Somente o Server autoriza e efetiva a transição. Estados terminais não voltam para `PENDING` e não mudam entre si.

Cada solicitação representa exatamente um Device, aceita somente `notes` opcionais e só pode ser atendida com um Device `PENDING_ACTIVATION`, sem Customer e não removido.

### Confirmação de telemetria por período

Mobile envia vários períodos em um lote, mas cada período possui `periodId` estável e recebe seu próprio resultado. Itens aceitos podem ser removidos localmente; itens rejeitados permanecem para diagnóstico ou nova tentativa. Um item inválido não descarta os irmãos válidos.

## Versões atuais

- rota HTTP: `/api/v1`;
- documento OpenAPI: `1.4.0`;
- envelope de telemetria: `schemaVersion = 4`;
- envelope de evento do Device: `schemaVersion = 2`.

[Voltar ao início](README.md) · [Guia de desenvolvimento](guia-de-desenvolvimento.md)
