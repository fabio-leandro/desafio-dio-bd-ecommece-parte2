/*Criando tabela pessoa e tabela forma_pagamento com insercao de dados*/
/*Selects basicos e INNER join de pessoa e forma_pagamento*/

CREATE TYPE TIPO_PESSOA AS ENUM('PJ','PF');
CREATE TABLE IF NOT EXISTS clientes (
	idCliente SERIAL PRIMARY KEY,
	nome VARCHAR(20) NOT NULL,
	sobrenome VARCHAR(30) NOT NULL,
	tipoCliente TIPO_PESSOA,
	cpfCnpj VARCHAR(15) NOT NULL,
	endereco VARCHAR(100) NOT NULL,
	id_forma_pagamento INTEGER
);

CREATE TABLE IF NOT EXISTS formas_pagamentos(
	idFormaPagamento SERIAL PRIMARY KEY,
	descricacao VARCHAR(50) NOT NULL
);

ALTER TABLE formas_pagamentos RENAME descricacao TO descricao;

ALTER TABLE clientes ADD CONSTRAINT constraints_fk FOREIGN KEY (id_forma_pagamento) 
REFERENCES formas_pagamentos (idFormaPagamento);

ALTER TABLE clientes ADD CONSTRAINT constraint_unique_cpf_cnpj UNIQUE (cpfCnpj);

INSERT INTO formas_pagamentos VALUES (1, 'Debito à vista');
INSERT INTO formas_pagamentos VALUES (2, 'Crédito à vista');
INSERT INTO formas_pagamentos VALUES (3, 'Crédito 6x');
INSERT INTO formas_pagamentos VALUES (4, 'Boleto');
INSERT INTO formas_pagamentos VALUES (5, 'PIX');

SELECT * FROM formas_pagamentos;

INSERT INTO clientes VALUES (1,'Fábio','Silva','PF','47997145621','Rua Vinte Hum, 21, bairro Sion Ameila BH-MG',1);
INSERT INTO clientes VALUES (2,'Paulo','Silva','PF','31510917683','Rua Trinta e Dois, 32, bairro Branca BH-MG',3);
INSERT INTO clientes VALUES (3,'Sarah','Alves','PF','38899816662','Rua Primeiro de Maio, 55, bairro Village BH-MG',3);

SELECT * FROM clientes;

SELECT c.nome, c.sobrenome, c.cpfCnpj, c.tipoCliente, c.endereco, fp.descricao as Forma_Pagamento
FROM clientes as c
INNER JOIN formas_pagamentos as fp
ON idCliente = idFormaPagamento;

/*Criando tabela pedidos */
CREATE TYPE STATUS_PEDIDO AS ENUM('Processando','Confirmado','Cancelado');
CREATE TABLE IF NOT EXISTS pedidos(
	idPedido SERIAL PRIMARY KEY,
	status STATUS_PEDIDO default 'Processando',
	custoFrete FLOAT NOT NULL,
	id_cliente INTEGER NOT NULL,
	FOREIGN KEY (id_cliente) REFERENCES clientes (idCliente)
);
INSERT INTO pedidos VALUES (1,default,20.00,1);
INSERT INTO pedidos VALUES (2,default,15.00,2);
INSERT INTO pedidos VALUES (3,'Confirmado',30.00,3);
SELECT * FROM pedidos;

/*Criando a tabela estoque*/
CREATE TYPE LOCAL_ESTOQUE AS ENUM('Almoxarifado','Logistica');
CREATE TABLE IF NOT EXISTS estoques (
	idEstoque SERIAL PRIMARY KEY,
	central LOCAL_ESTOQUE 
);
INSERT INTO estoques VALUES (1,'Logistica');
INSERT INTO estoques VALUES (2,'Almoxarifado');
SELECT * FROM estoques;

/*Criando a tabela produtos*/
CREATE TYPE PRODUTO_CATEGORIA AS ENUM('Eletrodomesticos','Informatica','Celulares','Moveis','Beleza e Perfumaria');
CREATE TABLE IF NOT EXISTS produtos(
	idProduto SERIAL PRIMARY KEY,
	categoria PRODUTO_CATEGORIA NOT NULL,
	descricao VARCHAR(100) NOT NULL,
	custo FLOAT NOT NULL,
	preco FLOAT NOT NULL
);

INSERT INTO produtos VALUES (1,'Eletrodomesticos','Geladeira',1000.00, 2000.00);
INSERT INTO produtos VALUES (2,'Eletrodomesticos','Lavadora',800.00,1300.00);
INSERT INTO produtos VALUES (3,'Eletrodomesticos','Smart Tv', 1300.00,2300.00);
INSERT INTO produtos VALUES (4,'Informatica','Notebook',2000.00, 4000.00);
INSERT INTO produtos VALUES (5,'Informatica','Tablet',700.00,1500.00);
INSERT INTO produtos VALUES (6,'Informatica','Mouse',35.00, 80.00);
INSERT INTO produtos VALUES (7,'Celulares','Sammsung V4', 350.00, 1200.00);
INSERT INTO produtos VALUES (8,'Beleza e Perfumaria','Shampoo', 13.00, 24.00);
INSERT INTO produtos VALUES (9,'Beleza e Perfumaria','Perfume Loiola',12.00, 100.00);
INSERT INTO produtos VALUES (10,'Beleza e Perfumaria','Creme Pele Bebê', 32.00, 64.00);

SELECT * FROM produtos;

/*Tabela produtos_estoques*/
CREATE TYPE TIPO_MOVIMENTACAO AS ENUM('Saida','Entrada');
CREATE TABLE IF NOT EXISTS produtos_estoques(
	id_produtos INTEGER NOT NULL,
	id_estoques INTEGER NOT NULL,
	quantidade INTEGER NOT NULL,
	movimentacao TIPO_MOVIMENTACAO,
	FOREIGN KEY (id_produtos) REFERENCES produtos (idProduto),
	FOREIGN KEY (id_estoques) REFERENCES estoques (idEstoque)
);

INSERT INTO produtos_estoques VALUES (1,1,5,'Entrada');
INSERT INTO produtos_estoques VALUES (2,1,4,'Entrada');
INSERT INTO produtos_estoques VALUES (3,1,5,'Entrada');
INSERT INTO produtos_estoques VALUES (4,1,3,'Entrada');
INSERT INTO produtos_estoques VALUES (5,1,7,'Entrada');
INSERT INTO produtos_estoques VALUES (6,1,5,'Entrada');
INSERT INTO produtos_estoques VALUES (7,1,5,'Entrada');
INSERT INTO produtos_estoques VALUES (8,1,2,'Entrada');
INSERT INTO produtos_estoques VALUES (9,1,12,'Entrada');
INSERT INTO produtos_estoques VALUES (10,1,10,'Entrada');

SELECT * FROM produtos_estoques;
SELECT * FROM produtos;

SELECT p.categoria,p.descricao,p.custo,p.preco, pe.quantidade, pe.movimentacao, e.central
FROM produtos as p
INNER JOIN produtos_estoques as pe
ON p.idProduto = pe.id_produtos
INNER JOIN estoques as e
ON e.idEstoque = pe.id_estoques;

/*Colocando produtos nos pedidos*/
CREATE TABLE IF NOT EXISTS produtos_pedidos(
	id_produtos INTEGER NOT NULL,
	id_pedidos INTEGER NOT NULL,
	quantidade INTEGER NOT NULL,
	FOREIGN KEY (id_produtos) REFERENCES produtos (idProduto),
	FOREIGN KEY (id_pedidos) REFERENCES pedidos (idPedido)
);
INSERT INTO produtos_pedidos VALUES (1,1,5);
INSERT INTO produtos_pedidos VALUES (2,1,4);
INSERT INTO produtos_pedidos VALUES (3,1,5);
INSERT INTO produtos_pedidos VALUES (4,1,3);

INSERT INTO produtos_pedidos VALUES (5,2,7);
INSERT INTO produtos_pedidos VALUES (6,2,5);
INSERT INTO produtos_pedidos VALUES (7,2,5);

INSERT INTO produtos_pedidos VALUES (8,3,2);
INSERT INTO produtos_pedidos VALUES (9,3,12);
INSERT INTO produtos_pedidos VALUES (10,3,10);

SELECT * FROM pedidos;
SELECT * FROM produtos;

SELECT ped.idPedido as codigo, ped.status,ped.custoFrete,pp.quantidade, prod.categoria, prod.descricao, prod.custo,prod.preco
FROM pedidos as ped
INNER JOIN produtos_pedidos as pp
ON ped.idPedido = pp.id_pedidos
INNER JOIN produtos as prod
ON prod.idProduto = pp.id_produtos;

/*Criando a tabela Transportadoras*/
CREATE TABLE IF NOT EXISTS transportadoras(
	idTransportadora SERIAL PRIMARY KEY,
	razaoSocial VARCHAR(100) NOT NULL,
	cnpj VARCHAR(15) NOT NULL
);

ALTER TABLE transportadoras ADD CONSTRAINT constraint_unique_cpf_cnpj_transportadoras UNIQUE (cnpj);

INSERT INTO transportadoras VALUES (1, 'Tranportes Leve Traz LTDA','58112475000150');
INSERT INTO transportadoras VALUES (2, 'Bau da Mercadoria LTDA','40452433000100');

SELECT * FROM transportadoras;

/*Criando a tabela entregas*/
CREATE TYPE STATUS_ENTREGA AS ENUM('Enviado','Entregue','Devolvido');
CREATE TABLE IF NOT EXISTS entregas(
	idEntrega SERIAL PRIMARY KEY,
	status STATUS_ENTREGA default 'Enviado',
	codigoRastreio VARCHAR(20),
	id_pedido INTEGER NOT NULL,
	id_transportadora INTEGER NOT NULL,
	FOREIGN KEY (id_pedido) REFERENCES pedidos (idPedido),
	FOREIGN KEY (id_transportadora) REFERENCES transportadoras (idTransportadora)
);

INSERT INTO entregas VALUES (1,default,'ER2345',1,1);
INSERT INTO entregas VALUES (2,default,'ER2346',2,2);
INSERT INTO entregas VALUES (3,default,'ER2347',3,1);

SELECT * FROM entregas;
SELECT * FROM pedidos;

SELECT entregas.status,entregas.codigoRastreio, pedidos.custoFrete, clientes.nome as Cliente, clientes.endereco
FROM entregas
INNER JOIN pedidos
ON entregas.id_pedido = pedidos.idPedido
INNER JOIN clientes
ON pedidos.id_cliente = clientes.idCliente;

/*Criando tabela vendedores externos*/
CREATE TABLE IF NOT EXISTS vendedores_externos(
	idVendedorExterno SERIAL PRIMARY KEY,
	cnpj VARCHAR(15) NOT NULL,
	razaoSocial VARCHAR(100) NOT NULL,
	endereco VARCHAR(100) NOT NULL
);

ALTER TABLE vendedores_externos ADD CONSTRAINT constraint_unique_cpf_cnpj_vendedores_externos UNIQUE (cnpj);

INSERT INTO vendedores_externos VALUES (1, '04487308000164','Vendas em Geral LTDA', 'Rua da Meta Batida, 87, Bairro Comissão, BH-MG');

SELECT * FROM vendedores_externos;

/*Criando tabela vendedores_pedidos*/
CREATE TABLE IF NOT EXISTS vendedores_pedidos(
	id_pedidos INTEGER NOT NULL,
	id_vendedores INTEGER NOT NULL,
	FOREIGN KEY (id_pedidos) REFERENCES pedidos (idPedido),
	FOREIGN KEY (id_vendedores) REFERENCES vendedores_externos (idVendedorExterno)
);

INSERT INTO vendedores_pedidos VALUES(1,1);
INSERT INTO vendedores_pedidos VALUES(2,1);
INSERT INTO vendedores_pedidos VALUES(3,1);

SELECT * FROM vendedores_pedidos;
SELECT * FROM pedidos;
SELECT * FROM clientes;

SELECT pedidos.idPedido as Pedido, pedidos.status, pedidos.custoFrete, clientes.nome || ' ' || clientes.sobrenome as Clientes, v.razaoSocial as Vendedor
FROM pedidos
INNER JOIN clientes
ON pedidos.id_cliente = clientes.idCliente
INNER JOIN vendedores_pedidos as vp
ON pedidos.idPedido = vp.id_pedidos
INNER JOIN vendedores_externos as v
ON vp.id_vendedores = v.idVendedorExterno;

/*Criando tabela fornecedores*/
CREATE TABLE IF NOT EXISTS fornecedores(
	idFornecedor SERIAL PRIMARY KEY,
	cnpj VARCHAR(15) NOT NULL,
	razaoSocial VARCHAR(100) NOT NULL,
	endereco VARCHAR(100) NOT NULL
);

ALTER TABLE fornecedores ADD CONSTRAINT constraint_unique_cpf_cnpj_fornecedores UNIQUE (cnpj);

INSERT INTO fornecedores VALUES (1,'70670684000114','Fabrica Faz Tudo Ltda','Rua Paraguai,22,Bairro Produtor, BH_MG');

/*Criando tabela fornecedores_produtos*/
CREATE TABLE IF NOT EXISTS fornecedores_produtos(
	id_fornecedores INTEGER NOT NULL,
	id_produtos INTEGER NOT NULL,
	FOREIGN KEY (id_fornecedores) REFERENCES fornecedores (idFornecedor),
	FOREIGN KEY (id_produtos) REFERENCES produtos (idProduto)
);

SELECT * FROM PRODUTOS;

INSERT INTO fornecedores_produtos VALUES (1,1);
INSERT INTO fornecedores_produtos VALUES (1,2);
INSERT INTO fornecedores_produtos VALUES (1,3);
INSERT INTO fornecedores_produtos VALUES (1,4);
INSERT INTO fornecedores_produtos VALUES (1,5);
INSERT INTO fornecedores_produtos VALUES (1,6);
INSERT INTO fornecedores_produtos VALUES (1,7);
INSERT INTO fornecedores_produtos VALUES (1,8);
INSERT INTO fornecedores_produtos VALUES (1,9);
INSERT INTO fornecedores_produtos VALUES (1,10);

SELECT * FROM fornecedores_produtos;
SELECT * FROM produtos;

SELECT produtos.categoria, produtos.descricao, produtos.custo, produtos.preco, f.razaoSocial
FROM produtos
INNER JOIN fornecedores_produtos as fp
ON produtos.idProduto = fp.id_produtos
INNER JOIN fornecedores as f
ON fp.id_fornecedores = f.idFornecedor;

/*Outras Consultas*/
SELECT * FROM pedidos;
SELECT * FROM produtos;
SELECT * FROM formas_pagamentos;
SELECT * FROM clientes;
                      
					  /*Pedidos, clientes, produtos com join*/

SELECT pedidos.idPedido as Numero_Pedido, pedidos.status, pedidos.custoFrete, produtos.categoria, 
produtos.descricao, produtos.custo, produtos.preco, clientes.nome || ' ' || clientes.sobrenome as Clientes, fp.descricao
FROM pedidos
INNER JOIN produtos_pedidos as pp
ON pp.id_pedidos = pedidos.idPedido
INNER JOIN produtos
ON pp.id_produtos = produtos.idProduto
INNER JOIN clientes
ON pedidos.id_cliente = clientes.idCliente
INNER JOIN formas_pagamentos as fp
ON clientes.id_forma_pagamento = fp.idFormaPagamento;


					  /*Pedidos, clientes, produtos com join com valor total do pedido e lucro obtido*/

SELECT pedidos.idPedido as Numero_Pedido, pedidos.status, pedidos.custoFrete, produtos.categoria, 
produtos.descricao, produtos.custo, produtos.preco, clientes.nome || ' ' || clientes.sobrenome as Clientes, fp.descricao,
(to_char(pedidos.custoFrete + produtos.preco, 'L9G999G990D99')) as Total_Pedido,
(to_char((pedidos.custoFrete + produtos.preco) - produtos.custo, 'L9G999G990D99')) as Lucro_Bruto
FROM pedidos
INNER JOIN produtos_pedidos as pp
ON pp.id_pedidos = pedidos.idPedido
INNER JOIN produtos
ON pp.id_produtos = produtos.idProduto
INNER JOIN clientes
ON pedidos.id_cliente = clientes.idCliente
INNER JOIN formas_pagamentos as fp
ON clientes.id_forma_pagamento = fp.idFormaPagamento;

 					/*Pedidos, clientes, produtos com join com valor total do pedido e lucro obtido e filtro por categoria*/

SELECT pedidos.idPedido as Numero_Pedido, pedidos.status, pedidos.custoFrete, produtos.categoria, 
produtos.descricao, produtos.custo, produtos.preco, clientes.nome || ' ' || clientes.sobrenome as Clientes, fp.descricao,
(to_char(pedidos.custoFrete + produtos.preco, 'L9G999G990D99')) as Total_Pedido,
(to_char((pedidos.custoFrete + produtos.preco) - produtos.custo, 'L9G999G990D99')) as Lucro_Bruto
FROM pedidos
INNER JOIN produtos_pedidos as pp
ON pp.id_pedidos = pedidos.idPedido
INNER JOIN produtos
ON pp.id_produtos = produtos.idProduto
INNER JOIN clientes
ON pedidos.id_cliente = clientes.idCliente
INNER JOIN formas_pagamentos as fp
ON clientes.id_forma_pagamento = fp.idFormaPagamento
WHERE produtos.categoria = 'Informatica';


        /*Pedidos, clientes, produtos com join com valor total do pedido e lucro obtido e filtro por venda a vista*/
SELECT pedidos.idPedido as Numero_Pedido, pedidos.status, pedidos.custoFrete, produtos.categoria, 
produtos.descricao, produtos.custo, produtos.preco, clientes.nome || ' ' || clientes.sobrenome as Clientes, fp.descricao,
(to_char(pedidos.custoFrete + produtos.preco, 'L9G999G990D99')) as Total_Pedido,
(to_char((pedidos.custoFrete + produtos.preco) - produtos.custo, 'L9G999G990D99')) as Lucro_Bruto
FROM pedidos
INNER JOIN produtos_pedidos as pp
ON pp.id_pedidos = pedidos.idPedido
INNER JOIN produtos
ON pp.id_produtos = produtos.idProduto
INNER JOIN clientes
ON pedidos.id_cliente = clientes.idCliente
INNER JOIN formas_pagamentos as fp
ON clientes.id_forma_pagamento = fp.idFormaPagamento
WHERE fp.descricao LIKE '%Debito à vista%';

							/*Criando a coluna resultado*/
SELECT pedidos.idPedido as Numero_Pedido, pedidos.status, pedidos.custoFrete, produtos.categoria, 
produtos.descricao, produtos.custo, produtos.preco, clientes.nome || ' ' || clientes.sobrenome as Clientes, fp.descricao,
CASE
    WHEN pedidos.custoFrete + produtos.preco > produtos.custo THEN 'LUCRO'
	ELSE 'DEFICIT'
END AS "RESULTADO"
FROM pedidos
INNER JOIN produtos_pedidos as pp
ON pp.id_pedidos = pedidos.idPedido
INNER JOIN produtos
ON pp.id_produtos = produtos.idProduto
INNER JOIN clientes
ON pedidos.id_cliente = clientes.idCliente
INNER JOIN formas_pagamentos as fp
ON clientes.id_forma_pagamento = fp.idFormaPagamento;

/*Custo por categoria com GROUP BY*/
SELECT produtos.categoria,(to_char(SUM(produtos.custo),'L9G999G990D99')) as CUSTO
FROM pedidos
INNER JOIN produtos_pedidos as pp
ON pp.id_pedidos = pedidos.idPedido
INNER JOIN produtos
ON pp.id_produtos = produtos.idProduto
GROUP BY produtos.categoria;

/*Receita por categoria produto com GROUP BY e ORDER BY receita*/
SELECT produtos.categoria,(to_char(SUM(produtos.preco),'L9G999G990D99')) as RECEITA
FROM pedidos
INNER JOIN produtos_pedidos as pp
ON pp.id_pedidos = pedidos.idPedido
INNER JOIN produtos
ON pp.id_produtos = produtos.idProduto
GROUP BY produtos.categoria
ORDER BY 2;

/*Receita por categoria produto com GROUP BY,HAVING para receitas maior que 1000 e ORDER BY por receita*/
SELECT produtos.descricao, SUM(produtos.preco)
FROM pedidos
INNER JOIN produtos_pedidos as pp
ON pp.id_pedidos = pedidos.idPedido
INNER JOIN produtos
ON pp.id_produtos = produtos.idProduto
GROUP BY produtos.descricao, produtos.preco
HAVING SUM(produtos.preco) > 1000
ORDER BY 2;




















