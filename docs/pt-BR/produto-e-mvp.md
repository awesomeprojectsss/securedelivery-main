# Produto e MVP

## O problema

Empresas que dependem de entregas precisam entender se impactos, inclinações, quedas ou movimentos anormais podem ter comprometido a carga. Rastreamento de frota, por si só, não responde essa pergunta nem preserva evidência suficiente para auditoria.

O SecureDelivery prioriza a integridade da carga, não a vigilância ou a avaliação automática do entregador.

## A proposta

Durante uma entrega, a SmartBox:

1. coleta movimento e localização no próprio Device;
2. detecta eventos relevantes localmente;
3. preserva amostras de alta frequência ao redor do evento;
4. sincroniza resumos e evidências quando há conexão;
5. permite que pessoas autorizadas investiguem o ocorrido no Dashboard.

## O MVP

O smartphone representa o futuro hardware IoT e é fixado horizontalmente à caixa. O MVP inclui:

- ativação segura por QR Code;
- coleta de IMU a 50 Hz no Device;
- GPS/velocidade de solo em até 1 Hz no Device;
- resumos operacionais de telemetria a cada minuto;
- detecção local de impacto, inclinação, possível queda e movimento anormal;
- operação offline com sincronização posterior;
- gestão de usuários, clientes e SmartBoxes;
- eventos, notificações e suporte;
- solicitações de SmartBox (`DeviceRequest`) com conclusão ou cancelamento explícito.

Ficam fora do MVP: temperatura, faturamento, ecommerce, estoque, rastreamento logístico da solicitação e armazenamento contínuo da rota ou da IMU bruta.

## Papéis

- `SUPER_ADMIN`: administra a plataforma e ações privilegiadas.
- `ADMIN`: gerencia clientes, Devices e suporte dentro das regras permitidas.
- `CUSTOMER`: acompanha somente seus recursos, ativa SmartBoxes, consulta eventos e usa o suporte.

O Server sempre aplica RBAC e isolamento entre clientes.

## Para clientes e parceiros

O valor esperado é tornar incidentes de transporte mais observáveis e auditáveis, com consumo de rede e armazenamento controlados. O MVP valida a coleta, a detecção, a sincronização e a experiência operacional antes de um hardware dedicado.

As detecções são evidências para investigação, não prova automática de culpa ou causalidade. Métricas dependentes de GPS mostram indisponibilidade de forma explícita e nunca transformam ausência de sinal em valores zero.

## Critérios de evolução do produto

Uma capacidade deve entrar no núcleo quando resolve um problema real do cliente, possui semântica mensurável e preserva privacidade, isolamento e auditabilidade. Novos sensores podem usar o protocolo extensível sem forçar uma mudança do Server para cada chave válida.

[Voltar ao início](README.md) · [Guia dos contratos](guia-dos-contratos.md)
