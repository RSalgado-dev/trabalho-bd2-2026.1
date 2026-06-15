-- 1. Criar regras semânticas, que são regras que não podem ser garantidas pela estrutura
-- do modelo relacional, usando o esquema exemplo fornecido. As regras criadas também
-- devem ser descritas textualmente no trabalho a ser entregue.

-- Criamos duas regras semânticas sobre o Chinook:

-- RS1 - Hierarquia de funcionários sem ciclos
-- Um funcionário não pode ser chefe de si mesmo, nem direta nem indiretamente,
-- pela coluna reports_to. A FK só obriga o reports_to a apontar pra um employee_id
-- que existe, mas não impede um ciclo do tipo 1 -> 2 -> 1, então a estrutura sozinha
-- não dá conta. Implementada com trigger na Questão 2.

-- RS2 - Item de fatura só pode entrar pelo procedimento
-- Um invoice_line só faz sentido se a fatura e a faixa existirem e a quantidade for
-- maior que zero. Além disso, o usuário da aplicação não pode escrever direto na
-- tabela: a inserção tem que passar pelo procedimento (controle por permissão).
-- Implementada com stored procedure na Questão 3.
