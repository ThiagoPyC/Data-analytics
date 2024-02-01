## Data Analytics - PowerBI and SQL
Objetivo do projeto é criar uma solução de análise de dados usando o Power BI. A ideia é, simular diferentes situações e ajudar os líderes a decidirem sobre o futuro dos produtos e lojas. 

Inicialmente utilizei o SQL para criação das views separando as tabelas em dimensões e tabelas fatos. As tabelas de dimensões são usadas para armazenar dados de contexto, como dados sobre clientes, produtos, vendedores e calendário, já as tabelas fatos são usadas para armazenar dados sobre transações, como vendas, métricas do negócio e etc... As views servem para facilitar a recuperação de dados do banco de dados. Por exemplo, a view dCliente pode ser usada para recuperar informações sobre um cliente, incluindo sua localização. 

![](./readme/view_sql.png)
  

Na imagem acima vemos a view dCliente sendo criada com as informações sobre clientes e sua localização geográfica. Ela é criada a partir de uma consulta que junta as tabelas Cliente, Geografia e RegioesBrasil com a função LEFT JOIN. A visão resultante contém as seguintes colunas: id, geografia_id, descrição, cidade, uf, estado e Região. 

Logo em seguida fiz a conexão local da base de dados do SQL Server no Power Bi para assim começar a modelagem e a criação dos visuais. Depois da modelagem, na mesclagem de consultas e criações de funções e de novas tabelas, em suma esse é o meu modelo final:  

![Diagrama do modelo final.](./readme/modelo_pbi.png) 

Esses relacionamentos entre essas entidades permitem que o sistema rastreie as vendas realizadas, os produtos vendidos, os clientes que realizaram as vendas e os vendedores que realizaram as vendas.  Por exemplo, Cliente: tem um relacionamento com a tabela Vendas. Cada cliente pode ter várias vendas associadas. Além disso, a tabela Vendas também está relacionada à tabela Metas, indicando que as vendas podem ser usadas para medir o progresso em relação às metas estabelecidas. E a tabela Metas: também tem uma relação com a tabela Produto, apontando que as metas podem ser definidas com base em categorias de produtos específicas. Essas são alguns exemplos dos relacionamentos acima. Por fim realizei a criação do visual:  

![](./readme/dashboard.png) 

Utilizei um background feito no Figma (uma plataforma para criação de templates) e criei várias medidas para uma melhor compreensão dos dados nos visuais. Caso queira acessar o visual segue o link: [Dashboard](https://app.powerbi.com/view?r=eyJrIjoiODVjY2VmZjctNjliZi00OGI3LWIyNDQtNTc3YzI5YTEwYjk2IiwidCI6ImZhZDg1ZGFiLWVjODAtNGE3Yi05YmZmLTJlNDA3MzQ0YmZhNyJ9)