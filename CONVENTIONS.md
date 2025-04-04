# ✨ Serverless PDF Chat Crossplane Helm Project – Coding Conventions

## 📁 File & Directory Naming

- Use lowercase and hyphen-separated directory names.
- Group Helm templates by resource type (`dynamodb`, `lambda`, `eventbridge`, etc.).
- Place common helpers in `_helpers.tpl`.
- Template files should be named using the resource type and purpose (e.g. `eventbus.yaml`, `order-table.yaml`).

---

## 📦 Helm Chart Structure

- Use `type: application` in `Chart.yaml`.
- Use semantic versioning (e.g., `0.1.0`).
- Keep each resource in its own YAML file under `templates/`.
- Use `.tpl` extensions for helper templates that don't emit Kubernetes resources.
- Maintain proper YAML formatting with 2-space indentation (no tabs).
- Use consistent filename patterns for Helm templates (e.g., `dynamodb-counting-table.yaml`).

---

## 🔧 Helm Templating Best Practices

- Use `.Values` for all dynamic content — avoid hardcoded names or ARNs.
- Add descriptive comments above each value in `values.yaml`.
- Always include `providerConfigRef` in Crossplane-managed resources.
- Use `{{ include "serverlesspresso.fullname" . }}` or similar for naming.
- Use standard Helm labels:
  ```yaml
  metadata:
    labels:
      app.kubernetes.io/name: {{ include "serverlesspresso.name" . }}
      helm.sh/chart: {{ include "serverlesspresso.chart" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
      app.kubernetes.io/managed-by: {{ .Release.Service }}
  ```

---

## ☁️ AWS Resource Naming

- Prefix all AWS resource names with `{{ .Values.appName }}-{{ .Values.service }}-`.
- Avoid using `Ref`, `Sub`, or CloudFormation-style intrinsic functions.

---

## 🛡️ IAM Policies

- Define IAM roles and policies explicitly.
- Avoid `Resource: "*"` unless required.
- Use inline policies for task-specific permissions; use managed policies for shared roles.

---

## 🧠 Crossplane-Specific Practices

- Always use the latest stable version of the Upbound AWS providers.
- Ensure each resource includes a valid `providerConfigRef.name`.
- Avoid using `deletionPolicy: Orphan` unless necessary.
- Assure that the apropriate provider is included in the `cloud-providers`
  chart whenever you introduce a new resource.

---

## ☑️ Helm Testing & Linting

- Run `helm lint` and `helm template` to test charts regularly.
- Add `NOTES.txt` to provide outputs like API URLs, ARNs, etc.
- Consider adding schema validation (e.g., using `kubeval`, `kubeconform`).

---

## 🧪 Kubernetes Resource Testing

- Validate with dry-runs using `kubectl apply --dry-run=client`.
- Use `helm upgrade --install --dry-run` before actual deploys.

---

## 🚧 CRDs

- If applicable, place all CRDs in the `crds/` folder for Helm to manage installation order.

---

## 🧾 Documentation

- Maintain `README.md` with installation instructions.
- Maintain `todo.md` and update it **whenever a change is made**.
  - ✅ Mark completed tasks.
  - ➕ Add new resources or ideas as subtasks.

---
