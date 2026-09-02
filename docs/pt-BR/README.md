# SecureDelivery em português

O SecureDelivery monitora a qualidade de entregas e produz evidências sobre condições que podem comprometer a carga. No MVP, um smartphone preso horizontalmente à caixa funciona como o `Device`; na interface, o produto o apresenta como **SmartBox**.

## Escolha pelo seu objetivo

| Público | Comece aqui | O que você encontrará |
|---|---|---|
| Project Manager, PO e negócio | [Visão do produto e do MVP](produto-e-mvp.md) | problema, proposta de valor, escopo, atores e limites |
| PO e Project Manager organizando a entrega | [Guia de backlog no Trello](guia-backlog-trello.md) | responsabilidades distintas, processo híbrido, fluxo Kanban, comunicação assíncrona, Ready e Done |
| Desenvolvimento e QA | [Guia de desenvolvimento](guia-de-desenvolvimento.md) | arquitetura, fluxo de trabalho, invariantes e checklist |
| Primeiros passos técnicos | [Glossário bilíngue](../terminology.md) | abreviações e termos explicados sem pressupor experiência |
| CI/CD e automação | [Guia simples de CI/CD](ci-cd.md) | comando único, checks, manutenção e futuro deploy |
| Integrações e arquitetura | [Guia dos contratos](guia-dos-contratos.md) | OpenAPI, AsyncAPI, versões e regras críticas |
| Possíveis clientes e parceiros | [Visão do produto e do MVP](produto-e-mvp.md#para-clientes-e-parceiros) | benefícios, funcionamento e o que o MVP ainda não promete |

## Regras rápidas

- `Device` é o termo técnico; **SmartBox** é o nome mostrado no produto.
- O Server é a fonte da verdade para estado, autorização e isolamento de clientes.
- O Mobile detecta eventos localmente e opera offline-first.
- O Dashboard apresenta dados autorizados e nunca é uma barreira de segurança.
- Telemetria normal usa resumos de um minuto; IMU bruta de 50 Hz fica no Device, exceto evidência de eventos.
- Novas observações e tipos de evento usam nomes extensíveis, não enums fechados.

[English documentation](../en/README.md)
