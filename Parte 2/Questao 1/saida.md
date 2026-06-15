As duas regras semânticas:

RS1 - Hierarquia de funcionários sem ciclos
Um funcionário não pode ser chefe de si mesmo, direta ou indiretamente, pela coluna `reports_to`. A FK só garante que o `reports_to` aponta pra um `employee_id` que existe, mas não barra um ciclo do tipo 1 -> 2 -> 1. Por isso resolvemos com trigger na Questão 2.

RS2 - Item de fatura entra só pelo procedimento
Um `invoice_line` só vale se a fatura e a faixa existirem e a quantidade for maior que zero. E o usuário da aplicação não pode inserir direto na tabela, só pelo procedimento (controle por permissão). Resolvida com stored procedure na Questão 3.
