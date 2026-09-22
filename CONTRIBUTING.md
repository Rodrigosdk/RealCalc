# Contribuindo

Obrigado por contribuir com o RealCalc.

## Antes de abrir um pull request

1. Crie uma branch para a alteração.
2. Mantenha a regra de negócio em casos de uso e entidades.
3. Adicione ou atualize os testes do comportamento alterado.
4. Execute as verificações do projeto:

   ```bash
   dart format lib test
   flutter analyze
   flutter test
   ```

5. Descreva no pull request o comportamento alterado e os cenários validados.

## Versionamento e releases

A versão do aplicativo fica no campo `version` de `pubspec.yaml`, no formato:

```text
major.minor.patch+buildNumber
```

Ao preparar uma release:

- Incremente `major` quando houver mudanças incompatíveis ou uma nova geração do produto.
- Incremente `minor` quando houver funcionalidade nova compatível com a versão anterior.
- Incremente `patch` quando houver correções ou mudanças compatíveis sem nova funcionalidade relevante.
- Incremente também o `buildNumber` em todo upload para a Play Store.

O `buildNumber` é independente de `major`, `minor` e `patch`, mas deve ser sempre um número inteiro estritamente maior que o usado no upload anterior. A Play Store rejeita um novo pacote com `buildNumber` repetido ou menor, inclusive em testes e faixas internas. Portanto, nunca reutilize um número de build já enviado.

Exemplos:

```yaml
# Correção: patch e build incrementados
version: 1.0.1+2

# Nova funcionalidade: minor e build incrementados
version: 1.1.0+3

# Mudança incompatível: major e build incrementados
version: 2.0.0+4
```

Antes de gerar o pacote, confirme qual foi o último `buildNumber` aceito na Play Console e escolha um valor maior. O incremento do build deve acontecer mesmo quando `major`, `minor` e `patch` não mudarem.

Para gerar um pacote Android de release:

```bash
flutter build appbundle --release
```
