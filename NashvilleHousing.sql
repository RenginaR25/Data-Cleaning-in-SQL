/*

Cleaning Data in SQL Queries


*/

--------------------------------------------------

----------Populate Property Address Data

Select *
from [dbo].[NashvilleHousing]
where PropertyAddress is Null
order by parcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
from [dbo].[NashvilleHousing] as a
Join [dbo].[NashvilleHousing]  as b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is Null

update a
set PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
from [dbo].[NashvilleHousing] as a
Join [dbo].[NashvilleHousing]  as b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is Null

----------------------------------------------------------------
----Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from [dbo].[NashvilleHousing]

Select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,substring(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from [dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
ADD PropertySplitAddress Nvarchar(50)

Update [dbo].[NashvilleHousing]
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE [dbo].[NashvilleHousing]
ADD PropertySplitCity Nvarchar(50)

Update [dbo].[NashvilleHousing]
set PropertySplitCity = substring(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select OwnerAddress
from [dbo].[NashvilleHousing]

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from [dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
ADD OwnerSplitAddress Nvarchar(50)
, OwnerSplitCity Nvarchar(50),
OwnerSplitState Nvarchar(50)

Update [dbo].[NashvilleHousing]
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

----------------------------------------------------------------------------------

----------Change Y and N to Yes and No in "SoldASVacant" Field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from [dbo].[NashvilleHousing]
group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
from [dbo].[NashvilleHousing]

UPDATE [dbo].[NashvilleHousing]
SET SoldAsVacant = Case
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END



---------------------------------------------------------------------------------

--------------Remove Duplicates
With RowNumCTE AS(
Select*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by UniqueID
		) row_num

from [dbo].[NashvilleHousing]
---order by ParcelID
)

DELETE
From RowNumCTE
where row_num > 1
--order by PropertyAddress


---------------------------------------------------------------------------------


----Delete Unused Columns


Select *
From [dbo].[NashvilleHousing]

ALTER Table [dbo].[NashvilleHousing]
drop Column OwnerAddress, TaxDistrict, PropertyAddress

