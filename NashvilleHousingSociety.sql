
-- Changing date format


ALTER TABLE NashvilleHousing
Add SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate);

SELECT SaleDateConverted
FROM NashvilleHousing;

---- Populating thr property address where it is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress ,ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
	ON a.parcelid= b.parcelid
	and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.propertyAddress IS NULL


-- UPDATING THE PROPERTY ADDRESS COLUMN

UPDATE A
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
	ON a.parcelid= b.parcelid
	and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.propertyAddress IS NULL


--- Splitting address based on Address and City

ALTER TABLE NashvilleHousing
Add PropAddress nvarchar (255);

UPDATE NashvilleHousing
SET PropAddress = SUBSTRING(propertyAddress,1,CHARINDEX(',',propertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropCity nvarchar (255);

UPDATE NashvilleHousing
SET PropCity = SUBSTRING(propertyAddress,CHARINDEX(',',propertyAddress)+1,LEN(propertyAddress))

SELECT *
FROM NashvilleHousing;

--- Splitting OwnerAddress

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3) ,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) ,
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar (255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar (255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar (255);

UPDATE NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT TOP(10)*
FROM NashvilleHousing

----- Change Y to Yes and N to No to keep consistency
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Method to change the value
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM NashvilleHousing

-- Updating the Values 
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						 WHEN SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant
						 END


------ Removing Duplicates

WITH RowNumCTE AS 
(
	SELECT *,
			ROW_NUMBER() OVER 
			(PARTITION BY
					ParcelID,
					PropertyAddress,
					SaleDate,
					SalePrice,
					LegalReference
				ORDER BY 
					UniqueID ) row_num
	FROM NashvilleHousing
)

DELETE
FROM RowNumCTE 
WHERE row_num > 1


--- Deleting redundant columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate




























