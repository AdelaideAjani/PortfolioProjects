-- Cleaning data in SQL queries to make data usable





--Review data 
SELECT *
FROM [db.Project1] . .[Nashville Housing]




--Standardise date format 

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM [db.Project1] . .[Nashville Housing]

UPDATE [Nashville Housing]
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE [Nashville Housing]
ADD SaleDateConverted Date;

UPDATE [Nashville Housing]
SET SaleDateConverted = CONVERT(date, SaleDate)




--Populate property address data 

SELECT *
FROM [db.Project1] . .[Nashville Housing]
-- WHERE PropertyAddress is null 
Order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [db.Project1] . .[Nashville Housing] a
JOIN [db.Project1] . .[Nashville Housing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [db.Project1] . .[Nashville Housing] a
JOIN [db.Project1] . .[Nashville Housing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null




-- Breaking down address into individual columns (Address, City, State) 

SELECT PropertyAddress
FROM [db.Project1] . .[Nashville Housing]

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
FROM [db.Project1] . .[Nashville Housing]


ALTER TABLE [Nashville Housing]
ADD PropertySplitAddress NVARCHAR(255);

UPDATE [Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE [Nashville Housing]
ADD PropertySplitCity NVARCHAR(255);

UPDATE [Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


SELECT *
FROM [db.Project1] . .[Nashville Housing]


SELECT OwnerAddress
FROM [db.Project1] . .[Nashville Housing]

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM [db.Project1] . .[Nashville Housing]


ALTER TABLE [Nashville Housing]
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE [Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)



ALTER TABLE [Nashville Housing]
ADD OwnerSplitCity NVARCHAR(255);

UPDATE [Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)



ALTER TABLE [Nashville Housing]
ADD OwnerSplitState NVARCHAR(255);

UPDATE [Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


SELECT * --Checking columns have been created correctly
FROM [db.Project1] . .[Nashville Housing]




--Change Y and N to Yes and No in 'Sold as vacant' field 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [db.Project1] . .[Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [db.Project1] . .[Nashville Housing]


UPDATE [Nashville Housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END





--Remove duplicates 


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID) row_num
FROM [db.Project1] . .[Nashville Housing]
ORDER BY ParcelID
)
DELETE *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


SELECT * -- Check duplicates have been deleted
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress




--Delete unused columns 

SELECT * 
FROM [db.Project1] . .[Nashville Housing]

ALTER TABLE [db.Project1] . .[Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [db.Project1] . .[Nashville Housing]
DROP COLUMN SaleDate
