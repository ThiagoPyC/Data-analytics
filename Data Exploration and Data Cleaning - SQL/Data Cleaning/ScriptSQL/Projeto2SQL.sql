/*

Limpeza de dados em consultas SQL

*/


Select *
From ProjectSql.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Padronizando formato de data

ALTER TABLE NashvilleHousing 
ALTER COLUMN SaleDate DATE

Select saleDate
From ProjectSql.dbo.NashvilleHousing
 --------------------------------------------------------------------------------------------------------------------------

-- Preenchendo dados de endere�o de propriedade

Select *
From ProjectSql.dbo.NashvilleHousing
-- Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From ProjectSql.dbo.NashvilleHousing a
JOIN ProjectSql.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

/* Aqui executamos uma consulta entre duas inst�ncias da tabela. Ele seleciona os identificadores 
de parcela (ParcelID) e endere�os de propriedades (PropertyAddress) de ambas as inst�ncias. A consulta
inclui apenas as linhas da tabela onde o endere�o da propriedade � nulo. A jun��o � feita com base nos identificadores de parcela iguais, 
excluindo combina��es onde os identificadores �nicos (UniqueID) s�o os mesmos para evitar 
correspond�ncias consigo mesmo. A coluna adicional exibe o endere�o da propriedade de "a" se 
estiver presente; caso contr�rio, exibe o endere�o da propriedade de "b".
*/

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From ProjectSql.dbo.NashvilleHousing a
JOIN ProjectSql.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Dividindo o endere�o em colunas individuais (Address, City, State)


Select PropertyAddress
From ProjectSql.dbo.NashvilleHousing
order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
From ProjectSql.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255), 
	PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

Select *
From ProjectSql.dbo.NashvilleHousing

/*

Nessa parte estamos dividindo o endere�o da propriedade em duas partes 'Address' e 'city' pelo delimitador ","
Logo em seguida estamos adicionando as novas colunas ao esquema. Estou utilizando duas formas de se fazer 
essa divis�o pelo delimitador que � com a fun��o SUBSTRING e logo abaixo a fun��o PARSENAME.

*/


Select OwnerAddress
From ProjectSql.dbo.NashvilleHousing


Select
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitState,
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitAddress
From ProjectSql.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
    OwnerSplitCity NVARCHAR(255),
    OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET
  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

Select *
From ProjectSql.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Altere Y e N para Sim e N�o no campo "Sold as Vacant"


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From ProjectSql.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From ProjectSql.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Removendo duplicadas

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From ProjectSql.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1

Select *
From ProjectSql.dbo.NashvilleHousing

/*
Aqui estamos usando o ROW_NUMBER para numerar sequencialmente registros duplicado com base nas
colunas especificadas na PARTITION BY.  A coluna row_num � ent�o utilizada para identificar 
apenas o primeiro registro de cada grupo de duplicatas durante a opera��o de exclus�o, mantendo-os com row_num = 1. 
Isso � feito para eliminar os registros duplicados enquanto preserva um �nico representante de cada conjunto duplicado na tabela.
Como podemos ver removemos com �xito as 104 linhas duplicadas.
*/

---------------------------------------------------------------------------------------------------------

-- Excluindo colunas que n�o irei utilizar

Select *
From ProjectSql.dbo.NashvilleHousing


ALTER TABLE ProjectSql.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

/*
Essa � uma pr�tica que voc� precisa tomar cuidado para n�o deletar colunas considerada importantes,
ent�o geralmete n�o se faz isso com seus dados brutos, essa � uma pr�tica n�o recomendada a se utilizar.
*/