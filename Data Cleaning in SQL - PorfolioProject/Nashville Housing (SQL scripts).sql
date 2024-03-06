/*

Cleaning Data in SQL Queries

What we get from this project:

-- Standardize Date Format
-- Populate Property Address data (replace NULL value with address that match ParcelID but UniqueID)
-- Breaking out Address into Individual Columns (Address, City, State) using SUBSTRING
-- Breaking out Address into Individual Columns (Address, City, State) using PARSENAME
-- Change Y and N to Yes and No in "Sold as Vacant" field
-- Remove Duplicates
-- Delete Unused Columns

*/
Select *
From NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, Convert(Date,SaleDate)
From NashvilleHousing

Update NashvilleHousing
SET SaleDate = Convert(Date,SaleDate)


Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date,SaleDate)




 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) --the whole syntax here aim to replace PropertyAdress(Null) to one PropertyAdress that has the same ParcelID but UniqueID
From NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]	--we join ParcelID which are the same but UniqueID
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]	--we join ParcelID which are the same but UniqueID
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State) using SUBSTRING

Select PropertyAddress
From NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address --this syntax means we get from letter 1 to ',' and -1 get rid of ','
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City --this means start with (',' +1) then returns then return rest of them
From NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From NashvilleHousing --see the results


-----------------------------------------------
-- Let's split out OwnerAddress using PARSENAME

Select OwnerAddress
From NashvilleHousing


Select
PARSENAME(Replace(OwnerAddress, ',', '.') , 3)
, PARSENAME(Replace(OwnerAddress, ',', '.') , 2
, PARSENAME(Replace(OwnerAddress, ',', '.') , 1) --we use Replace() here because PARSENAME() only works with '.' not ','
From NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') , 3)




--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- In that case, every row is unique b/c they have UniqueID is unique | But we pretend we don't have UniqueID then We could find duplicates and remove them.


With RowNumCTE AS(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
	PropertyAddress,
	SalePrice,
	LegalReference
	Order By UniqueID
		) row_num -- it literally set sequential number (if all partition by the same, row_num mark 2nd row is '2')
From NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress --until that line, we call the whole syntax with row_num is RowNumCTE



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate