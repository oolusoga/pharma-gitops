#!/bin/bash
# Auto ArgoCD login, sync, and open UI (Windows Git Bash)

NAMESPACE="argocd"
APP_NAME="pharma-dev"
ARGOCD_PORT=8080

# 1️⃣ Port-forward ArgoCD server in the background
echo "Starting port-forward for ArgoCD server..."
kubectl port-forward svc/argocd-server -n $NAMESPACE $ARGOCD_PORT:443 >/dev/null 2>&1 &
PF_PID=$!
sleep 5  # wait a few seconds for port-forward to start

# 2️⃣ Get the ArgoCD admin password
echo "Retrieving ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n $NAMESPACE get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)

# 3️⃣ Login via ArgoCD CLI
echo "Logging in to ArgoCD CLI..."
argocd login localhost:$ARGOCD_PORT --username admin --password $ARGOCD_PASSWORD --insecure

# 4️⃣ Sync the pharma-dev application
echo "Syncing ArgoCD application: $APP_NAME..."
argocd app sync $APP_NAME
argocd app wait $APP_NAME --timeout 300

# 5️⃣ Open ArgoCD UI in default browser
echo "Opening ArgoCD UI in your default browser..."
if command -v xdg-open >/dev/null 2>&1; then
    xdg-open https://localhost:$ARGOCD_PORT
elif command -v start >/dev/null 2>&1; then
    start https://localhost:$ARGOCD_PORT
elif command -v explorer.exe >/dev/null 2>&1; then
    explorer.exe https://localhost:$ARGOCD_PORT
else
    echo "Please open your browser and go to: https://localhost:$ARGOCD_PORT"
fi

# 6️⃣ Done
echo "✅ ArgoCD login, sync complete, and UI opened!"
echo "Port-forward process PID: $PF_PID (keep this terminal open for UI access)"
