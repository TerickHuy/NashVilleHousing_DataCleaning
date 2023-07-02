/* 
    Cleaning Data in SQL
*/

SELECT *
FROM PortfolioProject__Covid19.dbo.NashvilleHousing

-------------------------------------------------------------

-- Standarize Date Format

SELECT SaleDate
FROM PortfolioProject__Covid19.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

-------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM PortfolioProject__Covid19.dbo.NashvilleHousing
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) as [Populate Property Address from 'b' to 'a']
FROM NashvilleHousing a
    JOIN NashvilleHousing b
    ON  a.ParcelID = b.ParcelID AND a.UniqueID  <> b.UniqueID
WHERE a.PropertyAddress is NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
    JOIN NashvilleHousing b
    ON  a.ParcelID = b.ParcelID AND a.UniqueID  <> b.UniqueID
WHERE a.PropertyAddress is NULL

-------------------------------------------------------------

-- Breaking out Address into Individual colums (Address, City, Sate)

SELECT PropertyAddress
FROM NashvilleHousing
    -- Using SUBSTRING
SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) as Address, -- Take out Address
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City -- Take out City
FROM NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress))

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


SELECT *
FROM NashvilleHousing

    -- Using PARSENAME & REPLACE
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM NashvilleHousing

-- Change Y and N to Yes and No in SoldAsVancant column
SELECT Distinct (SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT distinct SoldAsVacant,
CASE
    When SoldAsVacant LIKE 'Y' THEN 'Yes'
    When SoldAsVacant LIKE 'N' THEN 'No'
    ELSE SoldAsVacant
END 
From NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
    When SoldAsVacant LIKE 'Y' THEN 'Yes'
    When SoldAsVacant LIKE 'N' THEN 'No'
    ELSE SoldAsVacant
END  


-------------------------------------------------------------

-- Remove duplicates
WITH RowNumCTE AS(
    SELECT *
    , ROW_NUMBER() OVER (
        PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference
        ORDER BY UniqueID
        ) as [Row Num]
    FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE [Row Num] > 1

-- DELETE 
-- FROM RowNumCTE
-- WHERE [Row Num] > 1


-------------------------------------------------------------

-- Delete unused columns
SELECT *
FROM NashvilleHousing

ALTER TABLE PortfolioProject__Covid19.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress