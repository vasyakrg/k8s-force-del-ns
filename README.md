# Удаляет залипшие неймспейсы на Rancher стендах
- как бы не решение проблемы - надо смотреть, что именно мешает удалению, а именно смотреть лог-файл, который остается после отработки скрипта
- обычно причина в установленных API, которые перестали работать и\или не были корректно удалены. лечится:
  - `kubectl describe APIService | grep <имя проблемы из лога>`
  - `kubectl delete APIService <имя проблемы из лога>`
- но как быстрое решение - работает

# условия запуска
- скрипту передается имя проблемного неймспейса
- в настроки скрипта заполните переменные `SERVER` и `TOKEN` - там есть примеры