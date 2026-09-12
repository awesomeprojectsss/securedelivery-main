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

O aplicativo-Device do MVP suporta Android 10 ou superior. O monitoramento usa no máximo 50 MiB para payloads locais, tenta sincronizar a cada minuto e recebe confirmação individual por período mesmo quando envia vários períodos em lote. A evidência usa uma janela fixa de dois segundos antes e dois segundos depois do gatilho, além do próprio intervalo do evento.

Para segurança operacional, o monitoramento não inicia abaixo de 15% de bateria sem carregamento, para quando o Android informa estado térmico `SEVERE` ou pior e respeita o máximo de 12 horas acumuladas em um período móvel de 24 horas. Os limites dos detectores de movimento ainda dependem de estudo e testes em aparelhos reais; não devem ser inventados durante a implementação.

Ficam fora do MVP: temperatura, faturamento, ecommerce, estoque, rastreamento logístico da solicitação e armazenamento contínuo da rota ou da IMU bruta.

## Papéis

- `SUPER_ADMIN`: administra a plataforma e ações privilegiadas.
- `ADMIN`: operador interno com visão de plataforma; gerencia Customers, usuários `CUSTOMER`, Devices e suporte dentro das regras permitidas.
- `CUSTOMER`: acompanha somente seus recursos, ativa SmartBoxes, consulta eventos e usa o suporte.

O Server sempre aplica RBAC e isolamento entre clientes.

Somente `SUPER_ADMIN` administra contas privilegiadas. E-mails são únicos globalmente. Redefinição administrativa usa senha temporária, revoga sessões e exige troca no próximo acesso. Ao desativar um Customer, seus usuários perdem acesso e o Server deixa de aceitar novos dados dos seus Devices, preservando o histórico para administradores autorizados. Registros de auditoria têm retenção padrão de 18 meses, salvo obrigação legal, investigação ou retenção jurídica documentada.

Uma solicitação representa uma SmartBox e contém apenas observações opcionais. O Device é criado diretamente em `PENDING_ACTIVATION`. Seu QR usa um código opaco sem expiração enquanto aguarda ativação; pode ser lido novamente, mas a primeira confirmação associa o Customer e novas tentativas retornam “já ativado”, sem transferir propriedade.

## Para clientes e parceiros

O valor esperado é tornar incidentes de transporte mais observáveis e auditáveis, com consumo de rede e armazenamento controlados. O MVP valida a coleta, a detecção, a sincronização e a experiência operacional antes de um hardware dedicado.

As detecções são evidências para investigação, não prova automática de culpa ou causalidade. Métricas dependentes de GPS mostram indisponibilidade de forma explícita e nunca transformam ausência de sinal em valores zero.

## Critérios de evolução do produto

Uma capacidade deve entrar no núcleo quando resolve um problema real do cliente, possui semântica mensurável e preserva privacidade, isolamento e auditabilidade. Novos sensores podem usar o protocolo extensível sem forçar uma mudança do Server para cada chave válida.

[Voltar ao início](README.md) · [Guia dos contratos](guia-dos-contratos.md)
