# CI/CD simples do SecureDelivery

## O que existe agora

O workspace principal usa GitHub Actions. O mesmo comando funciona na máquina do desenvolvedor e no GitHub:

O tooling usa Node.js 24 LTS. Com `nvm`, execute `nvm use` na raiz para selecionar a versão indicada em `.nvmrc`.

```bash
npm ci
npm run ci
```

O CI valida:

1. OpenAPI;
2. AsyncAPI;
3. invariantes críticas dos contratos;
4. links da documentação em todos os repositórios presentes no workspace.

Ele roda em Pull Requests, em pushes para `develop`/`main` e manualmente pelo GitHub. Execuções antigas do mesmo branch são canceladas quando chega uma mudança nova.

Os três repositórios de aplicação chamam um workflow documental reutilizável mantido no `securedelivery-main`. Publique primeiro o workflow do repositório principal em `main`; depois publique os workflows de Server, Mobile e Dashboard.

## Rotina para quem não conhece CI/CD

Você não precisa editar o workflow no trabalho cotidiano:

1. faça sua alteração;
2. rode `npm ci` uma vez quando dependências mudarem;
3. rode `npm run ci`;
4. abra o Pull Request;
5. espere o check **Contracts and documentation** ficar verde;
6. se ficar vermelho, abra o job e leia o primeiro passo com erro.

Nunca “conserte” um check removendo a validação. Corrija o contrato, documento, teste ou build que falhou.

## Automação de manutenção

O Dependabot verifica atualizações mensalmente, agrupa ferramentas de CI e GitHub Actions e limita a três os PRs simultâneos por ecossistema. Não há merge automático: uma pessoa revisa e deixa o CI validar.

As versões diretas ficam no `package.json`; o `package-lock.json` fixa toda a árvore para que local e GitHub usem as mesmas ferramentas.

## Por que o deploy ainda não é automático

Os repositórios de Server, Mobile e Dashboard ainda não possuem aplicações inicializadas nem destinos de hospedagem definidos. Um pipeline de deploy agora precisaria inventar provedor, ambiente, credenciais e estratégia de rollback.

Até essas decisões existirem:

- CI é obrigatório;
- não existem credenciais de produção no repositório;
- não existe deploy automático;
- publicação em produção exige aprovação humana.

## Modelo de CD quando houver aplicações

Manter apenas três ambientes:

```text
local -> staging -> production
```

- Pull Request: lint, testes e build, sem deploy.
- Merge em `develop`: deploy automático em staging.
- Release a partir de `main`: deploy de produção com aprovação manual.
- Falha: interromper o pipeline; nunca continuar silenciosamente.

Comandos esperados quando os projetos forem inicializados:

| Projeto | CI mínimo |
|---|---|
| Server NestJS | `npm ci`, lint, testes e build |
| Dashboard Next.js | `npm ci`, lint, testes e build |
| Mobile Flutter | `flutter pub get`, `flutter analyze` e `flutter test` |

Cada repositório terá um único workflow pequeno que chama seus comandos oficiais. Não adicionar Jenkins, Kubernetes, Argo CD, múltiplas ferramentas de pipeline ou deploy paralelo sem necessidade comprovada e ADR.

## Configuração única no GitHub

Quando as mudanças forem publicadas:

1. habilite GitHub Actions no repositório;
2. proteja `develop` e `main`: no workspace exija **Contracts and documentation**; nos três repositórios de aplicação exija **Repository documentation**;
3. mantenha permissões padrão do workflow como somente leitura;
4. não cadastre secrets até existir um destino real de staging/produção;
5. quando produção existir, use um Environment protegido com aprovação obrigatória.

## Arquivos que normalmente importam

- `.github/workflows/ci.yml`: quando o CI roda;
- `package.json`: comando único e versões diretas;
- `package-lock.json`: versões reproduzíveis;
- `scripts/ci.sh`: ordem das validações;
- `.github/dependabot.yml`: atualizações mensais agrupadas.

[Glossário bilíngue](../terminology.md) · [Guia de desenvolvimento](guia-de-desenvolvimento.md)

Referências oficiais: [Releases do Node.js](https://nodejs.org/en/about/previous-releases) · [GitHub Actions](https://docs.github.com/actions) · [Opções do Dependabot](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference) · [Environments de deploy](https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments)
