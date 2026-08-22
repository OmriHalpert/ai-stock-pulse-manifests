# AI Stock Pulse Helm chart

Deploys the NestJS backend, Python agent, nginx frontend, and Postgres.
Env names and probes match [ai-stock-pulse](../../ai-stock-pulse) / docker-compose.

## Secrets

Do **not** commit live API tokens. `values.yaml` ships empty placeholders.

Required keys on the generated Secret (or on `secrets.existingSecret`):

| Key | Used by |
|---|---|
| `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`, `DATABASE_URL` | Postgres + backend |
| `LLM_API_KEY` | Agent (optional; falls back to rule-based verdicts) |
| `FINNHUB_API_KEY` | Agent (optional; needed if `marketDataProvider=finnhub`) |
| `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID` | Agent (optional; otherwise alerts are logged only) |

### `--set` / `--set-file`

```bash
helm upgrade --install pulse ./charts/ai-stock-pulse \
  -f ./charts/ai-stock-pulse/values-dev.yaml \
  --set secrets.telegramBotToken="$TELEGRAM_BOT_TOKEN" \
  --set secrets.telegramChatId="$TELEGRAM_CHAT_ID" \
  --set secrets.llmApiKey="$LLM_API_KEY" \
  --set secrets.finnhubApiKey="$FINNHUB_API_KEY"
```

`--set-file` works if a key is in a file by itself:

```bash
--set-file secrets.llmApiKey=./llm.key
```

### Gitignored values file

```bash
cp charts/ai-stock-pulse/values-secrets.yaml.example charts/ai-stock-pulse/values-secrets.yaml
# edit values-secrets.yaml
helm upgrade --install pulse ./charts/ai-stock-pulse \
  -f ./charts/ai-stock-pulse/values-dev.yaml \
  -f ./charts/ai-stock-pulse/values-secrets.yaml
```

### Existing Secret

```bash
helm upgrade --install pulse ./charts/ai-stock-pulse \
  --set secrets.existingSecret=my-pulse-secrets
```

## Images

Compose builds images locally; this chart defaults to `ghcr.io/omrihalpert/ai-stock-*` with `pullPolicy: IfNotPresent`.

For kind/minikube, build, retag/load, then set `*.image.repository` / `tag`. Private GHCR needs `imagePullSecrets`.

Frontend images should be built with `VITE_API_BASE_URL=/api` (Compose already does this).

## Ingress

`ingress.host` and `ingress.className` are empty by default. Set them for a real cluster, or port-forward the frontend Service (nginx proxies `/api` to the backend).
