# Query 1: Lista de produtos disponíveis para compra (não descontinuados,ou seja, produtos disponíveis para venda).
SELECT ProductID,
       ProductName 
FROM Products 
WHERE Discontinued=0;

# Query 2: Produtos mais caros, acima da média de preços
SELECT Products.ProductName, 
       Products.UnitPrice
FROM Products
WHERE Products.UnitPrice>(SELECT AVG(UnitPrice) From Products);

# Query 3: Produtos por Categoria 
SELECT Categories.CategoryName, 
       Products.ProductName, 
       Products.QuantityPerUnit, 
       Products.UnitsInStock, 
       Products.Discontinued
FROM Categories 
     INNER JOIN Products ON Categories.CategoryID = Products.CategoryID
WHERE Products.Discontinued <> 1;

# Query 4: Alteração do nome `Order Details` para `OrderDetails`.
ALTER TABLE `Order Details` RENAME OrderDetails;

# Query 5: Vendedores que mais Venderam, usando a formula da soma da multiplicação da venda de cada vendedor
SELECT CONCAT(e.FirstName, ' ', e.LastName) as `Vendedor`,
	   SUM(od.UnitPrice * od.Quantity) `Total Vendido`
FROM Employees e
	INNER JOIN Orders o ON e.EmployeeID = o.EmployeeID
		INNER JOIN OrderDetails od ON od.OrderID = o.OrderID
GROUP BY `Vendedor`
ORDER BY `Total Vendido` DESC;

# Query 6: Produtos que mais foram vendidos em quantidade.
SELECT p.ProductName as `Produto`,
	   COUNT(od.Quantity) as `Quantidade de Vendas`
FROM Products p
	INNER JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY `Produto`
ORDER BY `Quantidade de Vendas` DESC;

# Query 7: Produtos que mais foram vendidos em valor.
SELECT p.ProductName as `Produto`,
	   SUM(od.UnitPrice * od.Quantity) as `Valor total Vendido`
FROM Products p
	INNER JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY `Produto`
ORDER BY `Valor total Vendido` DESC;

# Query 8: Vendas que com maior quantidade de produtos diferentes.
SELECT o.OrderID as `Venda`,
	   COUNT(od.OrderID) as `Quantidade de produtos`
FROM Orders o
	INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY `Venda` WITH ROLLUP
ORDER BY `Quantidade de produtos` DESC;

# Query 9: Quantidade de produtos fornecidos por fornecedor.
SELECT su.CompanyName as `Fornecedor`,
	   COUNT(p.SupplierID) as `Produtos Fornecidos`
FROM Suppliers su
	INNER JOIN Products p ON p.SupplierID = su.SupplierID
GROUP BY `Fornecedor`
ORDER BY `Produtos Fornecidos` DESC;

# Query 10: Regiões (paises) com maior volume de clientes.
SELECT cu.Country as `País`,
	   COUNT(cu.CustomerID) as `Quantidade de Clientes`
FROM Customers cu
GROUP BY `País`
ORDER BY `Quantidade de Clientes` DESC;

# Query 11: Vendedores com mais Vendas.
SELECT CONCAT(e.FirstName, ' ', e.LastName) as `Vendedor`,
	   COUNT(o.OrderID) as `Quantidade de Vendas`
FROM Employees e
	INNER JOIN Orders o ON e.EmployeeID = o.EmployeeID
GROUP BY `Vendedor`
ORDER BY `Quantidade de Vendas` DESC;

# Query 12: Vendedores com Maior Tempo de Empresa supondo que trabalham até hoje nesta empresa(aproximado).
SELECT CONCAT(e.FirstName, ' ', e.LastName) as `Vendedor`,
	   DATEDIFF(now(), e.HireDate)/365 as `Tempo de Empresa (anos)`
FROM Employees e
ORDER BY `Tempo de Empresa (anos)` DESC;

# Query 13: Concentração de Funcionários em Cada Região.
SELECT  et.EmployeeID, et.TerritoryID FROM employeeterritories et; 


# Query 14: Meses em que houveram mais entregas 
SELECT 
    EXTRACT(MONTH FROM o.ShippedDate) as `Mês`,
    MONTHNAME(o.ShippedDate) `Nome do Mês`,
    COUNT(o.OrderID) `Quantidade de Entregas`
FROM Orders o
WHERE o.ShippedDate IS NOT NULL
GROUP BY `Mês`, `Nome do Mês`
ORDER BY `Quantidade de Entregas` DESC;

# Query 15: Cada produto e seu nome
SELECT DISTINCT 
	p.ProductID, p.ProductName 
FROM Products p 
ORDER BY ProductID;

# Query 16: Local dos Pedidos, retornando o nome da região e o endereço que foi entregue
SELECT ShipName, ShipAddress from Orders 
UNION
SELECT DISTINCT ShipName, ShipAddress from Orders;

# Query 17: Maiores Salários das Funcionárias mulheres e que atuam em London

SELECT e.EmployeeID,e.FirstName,e.Salary FROM Employees e WHERE TitleOfCourtesy = 'Mrs.'
UNION 
SELECT e.EmployeeID,e.FirstName,e.Salary FROM Employees e WHERE City = 'London' ORDER BY salary DESC;


# Query 18: . Funcionarios que mais vendem por país
SELECT cu.Country as `País`,
	   COUNT(cu.CustomerID) as `Quantidade de Clientes`
FROM Customers cu
GROUP BY `País`
ORDER BY `Quantidade de Clientes` DESC;

# Query 19: Quantidade de Clientes por Vendedor.
WITH RECURSIVE `cte_customers` as 
	(SELECT
		o.CustomerID as `cte_CustomerID`,
        o.EmployeeID as `cte_EmployeeID`
	FROM Orders o)
SELECT DISTINCT
	CONCAT(e.FirstName, ' ', e.LastName) as `Vendedor`,
    COUNT(cte.`cte_CustomerID`) as `Quantidade de Clientes para quem Vendeu`
FROM Employees e
	INNER JOIN `cte_customers` cte ON cte.`cte_EmployeeID` = e.EmployeeID
GROUP BY `Vendedor`
ORDER BY `Quantidade de Clientes para quem Vendeu` DESC;

# Query 20: Verifica se existem vendas sem data de entrega
SELECT IF(
	EXISTS(
		SELECT 
			o.OrderID,
			COUNT(o.ShippedDate)
        FROM Orders o
        WHERE o.ShippedDate IS NULL
        GROUP BY o.OrderID
	), 'SIM', 'NÃO') AS `Existem Vendas sem envio?`;

# Query 21: Total de Entregas por Entregador da empresa Federal Shipping.
WITH `cte_federal_shipping_id` as
	(SELECT 
		sh.ShipperID
	FROM Shippers sh
    WHERE sh.ShipperID = 3)
SELECT 
	cte.ShipperID as `ID da Empresa de Entregas`,
	sh.CompanyName as `Empresa de Entregas`,
	COUNT(o.OrderID) as `Total de Entregas`
FROM Shippers sh
    INNER JOIN Orders o ON sh.ShipperID = o.ShipVia
		INNER JOIN `cte_federal_shipping_id` cte ON cte.ShipperID = sh.ShipperID
GROUP BY `Empresa de Entregas`
ORDER BY `Total de Entregas` DESC;

# Query 22: Produtos com preço entre 10.000 e 500.000.
SELECT DISTINCT p.ProductID, p.ProductName,od.UnitPrice FROM Products p 
INNER JOIN OrderDetails od on p.ProductID = od.ProductID HAVING od.UnitPrice IN (10.000,500.000);

# Query 23: Vendedores com Título de Representante.
SELECT CONCAT(e.FirstName, ' ', e.LastName) as `Vendedor`,
	   e.Title as `Título`
FROM Employees e
WHERE e.Title LIKE '%Representative';

# Query 24: Vendedores que respondem ao Vice presidente de Vendas.
SELECT DISTINCT
	CONCAT(e1.FirstName, ' ', e1.LastName) as `Vendedor`,
    CONCAT(e2.FirstName, ' ', e2.LastName) as `A Quem Responde`
FROM Employees e1
	INNER JOIN Employees e2 ON e1.ReportsTo = e2.EmployeeID
WHERE e2.Title LIKE '%President%';

# Query 25: Vendedores que respondem ao Gestor de Vendas.
SELECT DISTINCT
	CONCAT(e1.FirstName, ' ', e1.LastName) as `Vendedor`,
    CONCAT(e2.FirstName, ' ', e2.LastName) as `A Quem Responde`
FROM Employees e1
	INNER JOIN Employees e2 ON e1.ReportsTo = e2.EmployeeID
WHERE e2.Title LIKE '%Manager';

# Query 26: Funcionários que não respondem a ninguém.
SELECT DISTINCT
	CONCAT(e1.FirstName, ' ', e1.LastName) as `Funcionário`,
    CONCAT(e2.FirstName, ' ', e2.LastName) as `A Quem Responde`
FROM Employees e1
	LEFT JOIN Employees e2 ON e1.ReportsTo = e2.EmployeeID
WHERE e2.Title IS NULL;

# Query 27: Donos/Gestores Encarregadas Mais Funcionários.
SELECT DISTINCT
    CONCAT(e2.FirstName, ' ', e2.LastName) as `Encarregado`,
	COUNT(CONCAT(e1.FirstName, ' ', e1.LastName)) as `Quantidade de Funcionários que o Respondem`
FROM Employees e1
	INNER JOIN Employees e2 ON e1.ReportsTo = e2.EmployeeID
GROUP BY `Encarregado`
ORDER BY `Quantidade de Funcionários que o Respondem` DESC
LIMIT 1;

# Query 28: Funcionários Referenciados por Mr. ou Ms..
SELECT DISTINCT
	CONCAT(e.FirstName, ' ', e.LastName) as `Vendedor`,
    e.TitleOfCourtesy as `Título`
FROM Employees e
WHERE e.TitleOfCourtesy = 'Ms.' OR e.TitleOfCourtesy = 'Mr.';

# Query 29: Funcionários com Salário entre 5.000 e 10.000.
SELECT DISTINCT
	CONCAT(e.FirstName, ' ', e.LastName) as `Vendedor`,
    e.Salary as `Salário`
FROM Employees e
WHERE e.Salary BETWEEN 1000 AND 2000
ORDER BY `Salário` DESC;

# Query 30: Salário dos Funcionários Excluíndo o Dono da Empresa.
SELECT DISTINCT
	CONCAT(e.FirstName, ' ', e.LastName) as `Vendedor`,
    e.Salary as `Salário`
FROM Employees e
WHERE e.EmployeeID NOT IN (2)
ORDER BY `Salário` DESC;
