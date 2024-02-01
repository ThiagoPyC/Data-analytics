CREATE VIEW dCliente as
select 
	c.id,
	c.geografia_id,
	c.descricao,
	g.cidade,
	g.uf,
	g.estado,
	r.Regiao
From Cliente c
left join Geografia g on c.geografia_id = g.id
left join RegioesBrasil r on r.UF = g.uf

Go

CREATE VIEW dProduto as
select
	p.id,
	p.descricao,
	p.tamanho,
	p.custoUnitario,
	cp.id categoria_id,
	cp.descricao categoria_descricao
From Produto p
left JOIN Categoriaproduto cp ON p.categoria_id = cp.id

GO

CREATE VIEW dVendedor as
SELECT
	v.id,
	v.descricao,
	s.id supervisor_id,
	s.descricao supervisor_descricao,
	s.gerente_id,
	s.gerente_descricao
FROM Vendedor v
LEFT JOIN Supervisor s ON v.supervisor_id = s.id

GO

CREATE VIEW FVendas as 
SELECT        
	v.nfe, 
	v.data, 
	cc.vendedor_id, 
	v.cliente_id, 
	iv.produto_id, 
	(v.nf_desconto * iv.valor_bruto) / v.valor_bruto AS valor_desconto, 
	iv.item_quantidade, 
	iv.valor_unitario
FROM
	Vendas v 
	LEFT JOIN ItensVendas iv ON v.id = iv.vendas_id
	LEFT JOIN ClientesVendedores cc on cc.cliente_id = v.cliente_id
GO