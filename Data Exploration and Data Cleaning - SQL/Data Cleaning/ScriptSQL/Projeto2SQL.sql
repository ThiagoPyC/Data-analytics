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

-- Preenchendo dados de endereço de propriedade

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

/* Aqui executamos uma consulta entre duas instâncias da tabela. Ele seleciona os identificadores 
de parcela (ParcelID) e endereços de propriedades (PropertyAddress) de ambas as instâncias. A consulta
inclui apenas as linhas da tabela onde o endereço da propriedade é nulo. A junção é feita com base nos identificadores de parcela iguais, 
excluindo combinações onde os identificadores únicos (UniqueID) são os mesmos para evitar 
correspondências consigo mesmo. A coluna adicional exibe o endereço da propriedade de "a" se 
estiver presente; caso contrário, exibe o endereço da propriedade de "b".
*/

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From ProjectSql.dbo.NashvilleHousing a
JOIN ProjectSql.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Dividindo o endereço em colunas individuais (Address, City, State)


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

Nessa parte estamos dividindo o endereço da propriedade em duas partes 'Address' e 'city' pelo delimitador ","
Logo em seguida estamos adicionando as novas colunas ao esquema. Estou utilizando duas formas de se fazer 
essa divisão pelo delimitador que é com a função SUBSTRING e logo abaixo a função PARSENAME.

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


-- Altere Y e N para Sim e Não no campo "Sold as Vacant"


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
colunas especificadas na PARTITION BY.  A coluna row_num é então utilizada para identificar 
apenas o primeiro registro de cada grupo de duplicatas durante a operação de exclusão, mantendo-os com row_num = 1. 
Isso é feito para eliminar os registros duplicados enquanto preserva um único representante de cada conjunto duplicado na tabela.
Como podemos ver removemos com êxito as 104 linhas duplicadas.
*/

---------------------------------------------------------------------------------------------------------

-- Excluindo colunas que não irei utilizar

Select *
From ProjectSql.dbo.NashvilleHousing


ALTER TABLE ProjectSql.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

/*
Essa é uma prática que você precisa tomar cuidado para não deletar colunas considerada importantes,
então geralmete não se faz isso com seus dados brutos, essa é uma prática não recomendada a se utilizar.
*/