// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import './borrowing.sol';
import './lending.sol';
import './admin.sol';

/**
 * @dev Main BorrowingLending contract
 */
contract BorrowingLendingContract is BorrowingContract, LendingContract, AdminContract {
    /**
     * Error messages:
     * borrowing-lending.sol
     * 1 - Owner address can not be zero
     * 2 - Etna contract address can not be zero
     * 3 - Max APR should be greater or equal than min APR
     * admin.sol
     * 4 - Message value should be zero for an ERC20 replenish
     * 5 - Amount should be greater than zero
     * 6 - Message value should be greater than zero
     * borrowing.sol
     * 7 - Borrowing profile is not found
     * 8 - Borrowing profile is blocked
     * 9 - Message sender is flagged for liquidation
     * 10 - No assets to borrow
     * 11 - Not enough assets to borrow
     * 12 - Not enough collateral
     * 13 - Borrowing is not found
     * 14 - Amount can not be greater than borrowing amount
     * 15 - This borrowing is liquidated
     * 16 - Borrowing profile is blocked
     * 16.1 - Sender is not the Borrowing owner
     * collateral.sol
     * 17 - Collateral profile is not found
     * 18 - Collateral profile is blocked
     * 19 - For this type of collateral only internal transfers available
     * 20 - Message value should be greater than zero
     * 21 - Message value should be zero for an ERC20 collateral
     * 22 - Amount should be greater than zero
     * 23 - Wrong collateral profile
     * 27 - Collateral profile is not found
     * 28 - Collateral profile is blocked
     * 29 - Not enough NETNA to withdraw
     * 30 - Not enough available to withdraw collateral
     * 31 - This collateral is liquidated
     * lending.sol
     * 41 - Message sender is flagged for liquidation
     * 42 - Borrowing profile is not found
     * 43 - Message sender is flagged for liquidation
     * 44 - Lending is not found
     * 45 - Borrowing profile is not found
     * 46 - Amount should be greater than zero
     * 47 - Not enough lending amount
     * 47.1 - This lending can not be withdrawn at the moment
     * 48 - Message sender is flagged for liquidation
     * 49 - Lending is not found
     * 50 - Borrowing profile is not found
     * 51 - Amount should be greater than zero
     * 52 - Not enough yield
     * liquidation.sol
     * 53 - Liquidation requirements is not met
     * 54 - User is already flagged for liquidation
     * 55 - User is at liquidation
     * 56 - User is not flagged for liquidation
     * 57 - User was not flagged for a liquidation
     * 58 - Liquidation period is not over yet
     * 59 - Liquidation requirements is not met
     * marketing-indexes.sol
     * 60 - Borrowing apr can not be calculated when nothing is lent
     * 61 - Borrowing apr can not be calculated when not enough assets to borrow
     * storage.sol
     * 62 - caller is not the owner
     * 63 - caller is not the manager
     * 631 - caller is neither the manager nor liquidation contract
     * 64 - Contract address should not be zero
     * 65 - Borrowing profile is not found
     * 66 - Collateral record is not found
     * 67 - Borrowing record is not found
     * 68 - Borrowing profile is not found
     * 69 - Collateral profile is not found
     * 70 - Collateral profile is not found
     * 71 - Collateral profile is not found
     * 72 - Collateral profile is not found
     * 73 - Etna contract address can not be zero
     * 74 - Etna contract address can not be zero
     * 75 - Etna contract address can not be zero
     * 76 - Liquidation manager address can not be zero
     * 77 - caller is not the liquidation manager
     * 78 - caller is not the liquidator
     * 79 - caller is not the nft collateral contract
     * 791 - caller is not the collateral contract
     * 792 - caller is not the access vault contract
     * 793 - Owner address can not be zero
     * 794 - Amount exceeds contract balance
     * utils.sol
     * 80 - ReentrancyGuard: reentrant call
     * 81 - Token address should not be zero
     * 82 - Not enough contract balance
     */
    constructor (
        address newOwner,
        uint16 aprBorrowingMin,
        uint16 aprBorrowingMax,
        uint16 aprBorrowingFixed,
        uint16 aprLendingMin,
        uint16 aprLendingMax
    ) {
        require(newOwner != address(0), '1');
        require(aprBorrowingMax >= aprBorrowingMin, '3');
        require(aprLendingMax >= aprLendingMin, '3');

        _owner = newOwner;
        _managers[newOwner] = true;
        _aprBorrowingMin = aprBorrowingMin;
        _aprBorrowingMax = aprBorrowingMax;
        _aprBorrowingFixed = aprBorrowingFixed;
        _aprLendingMin = aprLendingMin;
        _aprLendingMax = aprLendingMax;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import './marketing-indexes.sol';
import './borrowing-fee.sol';

/**
 * @dev Borrowing functional implementation
 */
contract BorrowingContract is MarketingIndexesContract, BorrowingFeeContract {
    /**
     * @dev Borrowing of the specified amount of assets defined by the borrowing profile
     */
    function borrow (
        uint256 borrowingProfileIndex,
        uint256 amount,
        bool isFixedApr
    ) public returns (bool) {
        require(borrowingProfileIndex > 0 && borrowingProfileIndex
            <= _borrowingProfilesNumber, '7');
        require(_borrowingProfiles[borrowingProfileIndex].active,
            '8');
        require(_borrowingProfiles[borrowingProfileIndex].totalLent > 0,
            '10');
        require(
            (_borrowingProfiles[borrowingProfileIndex].totalBorrowed + amount)
                * DECIMALS
                / _borrowingProfiles[borrowingProfileIndex].totalLent <= 9500,
            '11'
        );
        require(
            getAvailableBorrowingAmount(
                msg.sender, borrowingProfileIndex
            ) >= amount,
            '12'
        );

        _proceedMarketingIndexes(borrowingProfileIndex);

        uint256 fixedApr;
        if (isFixedApr) {
            fixedApr += _aprBorrowingFixed;
            fixedApr += getBorrowingApr(borrowingProfileIndex);
        }

        _borrowingProfiles[borrowingProfileIndex].totalBorrowed += amount;

        uint256 borrowingIndex = _usersBorrowingIndexes[msg.sender][borrowingProfileIndex];
        if (
            borrowingIndex == 0 || _borrowings[borrowingIndex].liquidated
        ) {
            _borrowingsNumber ++;
            borrowingIndex = _borrowingsNumber;
            _borrowings[borrowingIndex].userAddress = msg.sender;
            _borrowings[borrowingIndex].borrowingProfileIndex = borrowingProfileIndex;
            _borrowings[borrowingIndex].lastMarketIndex =
                _borrowingProfiles[borrowingProfileIndex].borrowingMarketIndex;
            _borrowings[borrowingIndex].updatedAt = block.timestamp;
            _borrowings[borrowingIndex].accumulatedFee = 0;
            _borrowings[borrowingIndex].fixedApr = fixedApr;

            _usersBorrowingIndexes[msg.sender][borrowingProfileIndex] = borrowingIndex;
        } else {
            _updateBorrowingFee(borrowingIndex);
            if (
                _borrowings[borrowingIndex].amount == 0
                    && _borrowings[borrowingIndex].accumulatedFee == 0
            ) _borrowings[borrowingIndex].fixedApr = fixedApr;
        }
        _borrowings[borrowingIndex].amount += amount;
        _sendAsset(
            _borrowingProfiles[borrowingProfileIndex].contractAddress,
            msg.sender,
            amount
        );

        return true;
    }

    /**
     * @dev Borrowing of available amount of assets defined by the borrowing profile
     */
    function borrowAvailable (
        uint256 borrowingProfileIndex, bool isFixedApr
    ) external returns (bool) {
        return borrow(
            borrowingProfileIndex,
            getAvailableBorrowingAmount(
                msg.sender, borrowingProfileIndex
            ),
            isFixedApr
        );
    }

    /**
     * @dev returning of the specified amount of assets
     */
    function returnBorrowing (
        uint256 borrowingIndex, uint256 amount, bool returnAll
    ) external returns (bool) {
        require(borrowingIndex > 0 && borrowingIndex
            <= _borrowingsNumber, '13');
        require(_borrowings[borrowingIndex].userAddress == msg.sender,
            '16.1');
        uint256 borrowingProfileIndex = _borrowings[borrowingIndex].borrowingProfileIndex;
        require(!_borrowings[borrowingIndex].liquidated,
            '15');
        require(_borrowingProfiles[borrowingProfileIndex].active, '16');
        _proceedMarketingIndexes(borrowingProfileIndex);
        _updateBorrowingFee(borrowingIndex);
        if (returnAll) {
            amount = _borrowings[borrowingIndex].amount
                + _borrowings[borrowingIndex].accumulatedFee;
        } else {
            require(
                _borrowings[borrowingIndex].amount
                + _borrowings[borrowingIndex].accumulatedFee >= amount,
                '14'
            );
        }
        _takeAsset(
            _borrowingProfiles[borrowingProfileIndex].contractAddress,
            msg.sender,
            amount
        );

        if (amount <= _borrowings[borrowingIndex].accumulatedFee) {
            _borrowings[borrowingIndex].accumulatedFee -= amount;
        } else {
            amount -= _borrowings[borrowingIndex].accumulatedFee;
            _borrowings[borrowingIndex].accumulatedFee = 0;
            _borrowingProfiles[borrowingProfileIndex].totalBorrowed -= amount;
            _borrowings[borrowingIndex].amount -= amount;
        }

        return true;
    }

    function liquidateBorrowing (
        address userAddress
    ) external onlyCollateralContract returns (uint256) {
        uint256 borrowedUsdAmount;
        for (uint256 i = 1; i <= _borrowingProfilesNumber; i ++) {
            uint256 borrowingIndex = _usersBorrowingIndexes[userAddress][i];
            if (
                borrowingIndex == 0 || _borrowings[borrowingIndex].liquidated
                || _borrowings[borrowingIndex].amount == 0
            ) continue;
            borrowedUsdAmount += (_borrowings[borrowingIndex].amount
                + _borrowings[borrowingIndex].accumulatedFee
                + _getBorrowingFee(borrowingIndex))
                * getUsdRate(_borrowingProfiles[i].contractAddress)
                / SHIFT;

            _updateBorrowingFee(borrowingIndex);
            _borrowingProfiles[i].totalLiquidated += (_borrowings[borrowingIndex].amount
                + _borrowings[borrowingIndex].accumulatedFee);
            _borrowings[borrowingIndex].liquidated = true;

            emit BorrowingLiquidation(
                userAddress, msg.sender, borrowingIndex, block.timestamp
            );
        }
        return borrowedUsdAmount;
    }

    /**
     * @dev Returning of the liquidated assets, let keep accounting
     * of the liquidated and returned assets
     */
    function returnLiquidatedBorrowing (
        uint256 borrowingProfileIndex, uint256 amount
    ) external returns (bool) {
        require(
            msg.sender == _collateralContract.getLiquidationManager(),
            '77'
        );
        _takeAsset(
            _borrowingProfiles[borrowingProfileIndex].contractAddress,
            msg.sender,
            amount
        );
        _borrowingProfiles[borrowingProfileIndex].totalReturned += amount;
        _proceedMarketingIndexes(borrowingProfileIndex);
        if (_borrowingProfiles[borrowingProfileIndex].totalBorrowed > amount) {
            _borrowingProfiles[borrowingProfileIndex].totalBorrowed -= amount;
        } else {
            _borrowingProfiles[borrowingProfileIndex].totalBorrowed = 0;
        }

        return true;
    }

    /**
     * @dev Return maximum available for borrowing assets amount
     */
    function getAvailableBorrowingAmount (
        address userAddress, uint256 borrowingProfileIndex
    ) public view returns (uint256) {
        if (!_borrowingProfiles[borrowingProfileIndex].active) return 0;
        uint256 borrowedUsdAmount = getBorrowedUsdAmount(userAddress);
        uint256 collateralUsdAmount = _collateralContract
            .getUserCollateralUsdAmount(userAddress, true);
        if (collateralUsdAmount <= borrowedUsdAmount) return 0;
        return collateralUsdAmount - borrowedUsdAmount;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import './marketing-indexes.sol';

/**
 * @dev Implementation of the lending treating functional,
 * functions names are self explanatory
 */
contract LendingContract is MarketingIndexesContract {
    function lend (
        uint256 borrowingProfileIndex, uint256 amount
    ) external returns (bool) {
        require(borrowingProfileIndex > 0 && borrowingProfileIndex <= _borrowingProfilesNumber,
            '42');
        if (!_isUser[msg.sender]) {
            _totalUsers ++;
            _isUser[msg.sender] = true;
        }

        _proceedMarketingIndexes(borrowingProfileIndex);
        uint256 lendingIndex;
        if (_usersLendingIndexes[msg.sender][borrowingProfileIndex] == 0) {
            _lendingsNumber ++;
            lendingIndex = _lendingsNumber;
            _lendings[lendingIndex] = Lending({
                userAddress: msg.sender,
                borrowingProfileIndex: borrowingProfileIndex,
                amount: amount,
                unlock: block.timestamp + _lockTime,
                lastMarketIndex: _borrowingProfiles[borrowingProfileIndex].lendingMarketIndex,
                updatedAt: block.timestamp,
                accumulatedYield: 0
            });

            _usersLendingIndexes[msg.sender][borrowingProfileIndex] = _lendingsNumber;
        } else {
            lendingIndex = _usersLendingIndexes[msg.sender][borrowingProfileIndex];
            _updateLendingYield(lendingIndex);
            _addToLending(lendingIndex, borrowingProfileIndex, amount);
        }
        _borrowingProfiles[borrowingProfileIndex].totalLent += amount;
        if (address(_rewardContract) != address(0)) {
            _rewardContract.updateRewardData(
                msg.sender,
                borrowingProfileIndex,
                _lendings[lendingIndex].amount,
                _borrowingProfiles[borrowingProfileIndex].totalLent
            );
        }
        _takeAsset(
            _borrowingProfiles[borrowingProfileIndex].contractAddress,
            msg.sender,
            amount
        );

        return true;
    }

    /**
     * @dev Lend accumulated yield to the contract
     */
    function compound (uint256 borrowingProfileIndex) external returns (bool) {
        require(borrowingProfileIndex > 0 && borrowingProfileIndex <= _borrowingProfilesNumber,
            '42');
        uint256 lendingIndex = _usersLendingIndexes[msg.sender][borrowingProfileIndex];
        require(lendingIndex > 0, '44');
        _updateLendingYield(lendingIndex);

        uint256 yield = _lendings[lendingIndex].accumulatedYield;
        _lendings[lendingIndex].accumulatedYield = 0;
        _addToLending(lendingIndex, borrowingProfileIndex, yield);
        _borrowingProfiles[borrowingProfileIndex].totalLent += yield;
        if (address(_rewardContract) != address(0)) {
            _rewardContract.updateRewardData(
                msg.sender,
                borrowingProfileIndex,
                _lendings[lendingIndex].amount,
                _borrowingProfiles[borrowingProfileIndex].totalLent
            );
        }
        return true;
    }

    function withdrawLending (
        uint256 borrowingProfileIndex, uint256 amount
    ) external returns (bool) {
        require(borrowingProfileIndex > 0 && borrowingProfileIndex <= _borrowingProfilesNumber,
            '42');
        uint256 lendingIndex = _usersLendingIndexes[msg.sender][borrowingProfileIndex];
        require(lendingIndex > 0, '44');

        require(_borrowingProfiles[borrowingProfileIndex].contractAddress != address(0),
            '45');
        require(amount > 0, '46');
        _proceedMarketingIndexes(borrowingProfileIndex);
        _updateLendingYield(lendingIndex);
        require(_lendings[lendingIndex].amount >= amount, '47');
        if (_borrowingProfiles[borrowingProfileIndex].totalLent == amount) {
            require(
                _borrowingProfiles[borrowingProfileIndex].totalBorrowed == 0,
                    '47.1'
            );
        } else {
            require(
                _borrowingProfiles[borrowingProfileIndex].totalBorrowed * DECIMALS
                    / (_borrowingProfiles[borrowingProfileIndex].totalLent - amount)
                        <= 9500,
                            '47.1'
            );
        }
        _lendings[lendingIndex].amount -= amount;
        if (address(_rewardContract) != address(0)) {
            _rewardContract.updateRewardData(
                msg.sender,
                borrowingProfileIndex,
                _lendings[lendingIndex].amount,
                _borrowingProfiles[borrowingProfileIndex].totalLent
            );
        }
        _borrowingProfiles[borrowingProfileIndex].totalLent -= amount;
        _sendAsset(
            _borrowingProfiles[borrowingProfileIndex].contractAddress,
            msg.sender,
            amount
        );

        return true;
    }

    function withdrawLendingYield (
        uint256 borrowingProfileIndex, uint256 amount
    ) external returns (bool) {
        uint256 lendingIndex = _usersLendingIndexes[msg.sender][borrowingProfileIndex];
        require(lendingIndex > 0, '49');

        require(_borrowingProfiles[borrowingProfileIndex].contractAddress != address(0),
            '50');
        require(amount > 0, '51');
        _updateLendingYield(lendingIndex);
        require(_lendings[lendingIndex].accumulatedYield >= amount, '52');

        _lendings[lendingIndex].accumulatedYield -= amount;

        _sendAsset(
            _borrowingProfiles[borrowingProfileIndex].contractAddress,
            msg.sender,
            amount
        );

        return true;
    }

    function _addToLending (
        uint256 lendingIndex,
        uint256 borrowingProfileIndex,
        uint256 amount
    ) internal returns (bool) {
        _lendings[lendingIndex].amount += amount;
        if (_lendings[lendingIndex].unlock > block.timestamp){
            _lendings[lendingIndex].unlock = block.timestamp + _lockTime;
        }
        _lendings[lendingIndex].lastMarketIndex = _borrowingProfiles
            [borrowingProfileIndex].lendingMarketIndex;
        _lendings[lendingIndex].updatedAt = block.timestamp;
        return true;
    }

    function _updateLendingYield (
        uint256 lendingIndex
    ) internal returns (bool) {
        uint256 yield = _getLendingYield(lendingIndex);
        _lendings[lendingIndex].accumulatedYield += yield;
        _lendings[lendingIndex].updatedAt = block.timestamp;
        _lendings[lendingIndex].lastMarketIndex =
            _borrowingProfiles[_lendings[lendingIndex].borrowingProfileIndex].lendingMarketIndex;

        return true;
    }

    function getLendingYield (
        uint256 lendingIndex, bool addAccumulated
    ) external view returns (uint256) {
        uint256 lendingYield = _getLendingYield(lendingIndex);
        if (addAccumulated) lendingYield += _lendings[lendingIndex].accumulatedYield;
        return lendingYield;
    }

    function _getLendingYield (
        uint256 lendingIndex
    ) internal view returns (uint256) {
        uint256 borrowingProfileIndex = _lendings[lendingIndex].borrowingProfileIndex;
        uint256 marketIndex = _borrowingProfiles[borrowingProfileIndex].lendingMarketIndex;

        uint256 extraPeriodStartTime =
            _borrowingProfiles[borrowingProfileIndex].lendingMarketIndexLastTime;
        if (extraPeriodStartTime < _lendings[lendingIndex].updatedAt) {
            extraPeriodStartTime = _lendings[lendingIndex].updatedAt;
        }
        uint256 extraPeriod = block.timestamp - extraPeriodStartTime;

        if (extraPeriod > 0) {
            uint256 marketFactor = SHIFT +
                SHIFT * getLendingApr(borrowingProfileIndex)
                * extraPeriod / DECIMALS / YEAR;
            marketIndex = marketIndex * marketFactor / SHIFT;
        }

        uint256 newAmount = _lendings[lendingIndex].amount
            * marketIndex
            / _lendings[lendingIndex].lastMarketIndex;

        return newAmount - _lendings[lendingIndex].amount;
    }

    function getTotalLent (
        uint256 borrowingProfileIndex
    ) external view returns (uint256) {
        if (
            !_borrowingProfiles[borrowingProfileIndex].active
        ) return 0;
        return _borrowingProfiles[borrowingProfileIndex].totalLent;
    }

    function getUserProfileLent (
        address userAddress, uint256 borrowingProfileIndex
    ) external view returns (uint256) {
        if (
            !_borrowingProfiles[borrowingProfileIndex].active
        ) return 0;
        return _lendings[
            _usersLendingIndexes[userAddress][borrowingProfileIndex]
        ].amount;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import './storage.sol';

/**
 * @dev Specific functions for administrator.
 */
contract AdminContract is StorageContract {
    /**
     * @dev Function for withdrawing assets, both native currency and erc20 tokens.
     */
    function adminWithdraw (
        address tokenAddress, uint256 amount
    ) external onlyOwner returns (bool) {
        _sendAsset(tokenAddress, msg.sender, amount);
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import './storage.sol';

/**
 * @dev Implementation of the marketing indexes calculation
 * in order to calculate fees and yield with dynamically changed APR
 */
contract MarketingIndexesContract is StorageContract {
    function _proceedMarketingIndexes (
        uint256 borrowingProfileIndex
    ) internal returns (bool) {
        uint256 borrowingPeriod = block.timestamp
            - _borrowingProfiles[borrowingProfileIndex].borrowingMarketIndexLastTime;
        uint256 borrowingMarketFactor = SHIFT;
        if (_borrowingProfiles[borrowingProfileIndex].totalLent > 0) {
            borrowingMarketFactor += SHIFT * getBorrowingApr(borrowingProfileIndex)
            * borrowingPeriod / DECIMALS / YEAR;
        }
        _borrowingProfiles[borrowingProfileIndex].borrowingMarketIndex *= borrowingMarketFactor;
        _borrowingProfiles[borrowingProfileIndex].borrowingMarketIndex /= SHIFT;
        _borrowingProfiles[borrowingProfileIndex].borrowingMarketIndexLastTime = block.timestamp;

        uint256 lendingPeriod = block.timestamp
            - _borrowingProfiles[borrowingProfileIndex].lendingMarketIndexLastTime;
        uint256 lendingMarketFactor = SHIFT + (
            SHIFT * getLendingApr(borrowingProfileIndex)
            * lendingPeriod / DECIMALS / YEAR
        );

        _borrowingProfiles[borrowingProfileIndex].lendingMarketIndex *= lendingMarketFactor;
        _borrowingProfiles[borrowingProfileIndex].lendingMarketIndex /= SHIFT;
        _borrowingProfiles[borrowingProfileIndex].lendingMarketIndexLastTime = block.timestamp;

        return true;
    }

    function setAprSettings (
        uint16 aprBorrowingMin,
        uint16 aprBorrowingMax,
        uint16 aprBorrowingFixed,
        uint16 aprLendingMin,
        uint16 aprLendingMax
    ) external onlyManager returns (bool) {
        for (uint256 i; i < _borrowingProfilesNumber; i ++) {
            _proceedMarketingIndexes(i + 1);
        }
        _aprBorrowingMin = aprBorrowingMin;
        _aprBorrowingMax = aprBorrowingMax;
        _aprBorrowingFixed = aprBorrowingFixed;
        _aprLendingMin = aprLendingMin;
        _aprLendingMax = aprLendingMax;
        return true;
    }

    function getBorrowingApr (
        uint256 borrowingProfileIndex
    ) public view returns (uint256) {
        if (_borrowingProfiles[borrowingProfileIndex].totalLent == 0) return 0;
        uint256 borrowingPercentage = _borrowingProfiles[borrowingProfileIndex].totalBorrowed
            * DECIMALS
            / _borrowingProfiles[borrowingProfileIndex].totalLent;
        if (borrowingPercentage > 9500) return _aprBorrowingMax;
        return _aprBorrowingMin + (
            borrowingPercentage * (_aprBorrowingMax - _aprBorrowingMin) / 9500
        );
    }

    function getLendingApr (uint256 borrowingProfileIndex) public view returns (uint256) {
        uint256 lendingApr = _aprLendingMin;
        if (_borrowingProfiles[borrowingProfileIndex].totalLent > 0) {
            uint256 borrowingPercentage = _borrowingProfiles[borrowingProfileIndex].totalBorrowed
                * DECIMALS
                / _borrowingProfiles[borrowingProfileIndex].totalLent;
            if (borrowingPercentage < 9500) {
                lendingApr = _aprLendingMin + (
                    borrowingPercentage * (_aprLendingMax - _aprLendingMin) / 9500
                );
            }
        }
        return lendingApr;
    }

    function updateMarketingIndexes () external onlyManager returns (bool) {
        for (uint256 i = 1; i <= _borrowingProfilesNumber; i ++) {
            _proceedMarketingIndexes(i);
        }
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import './marketing-indexes.sol';

/**
 * @dev Functions for the borrowing fee treating and helper functions
 * used in both Borrowing and Collateral contracts
 */
contract BorrowingFeeContract is MarketingIndexesContract {
    /**
     * @dev External getter of the borrowing fee
     */
    function getBorrowingFee (
        uint256 borrowingIndex, bool addAccumulated
    ) external view returns (uint256) {
        uint256 borrowingFee = _getBorrowingFee(borrowingIndex);
        if (addAccumulated) borrowingFee += _borrowings[borrowingIndex].accumulatedFee;
        return borrowingFee;
    }

    /**
     * @dev Updating of the borrowing fee (is proceeded each time when total borrowed amount
     * or total lent amount is changed)
     */
    function _updateBorrowingFee (uint256 borrowingIndex) internal returns (bool) {
        if (_borrowings[borrowingIndex].liquidated) return false;
        uint256 fee = _getBorrowingFee(borrowingIndex);
        _borrowings[borrowingIndex].accumulatedFee += fee;
        _borrowings[borrowingIndex].updatedAt = block.timestamp;
        _borrowings[borrowingIndex].lastMarketIndex =
            _borrowingProfiles[_borrowings[borrowingIndex].borrowingProfileIndex]
            .borrowingMarketIndex;

        return true;
    }

    /**
     * @dev Calculating of the borrowing fee
     */
    function _getBorrowingFee (uint256 borrowingIndex) internal view returns (uint256) {
        if (
            borrowingIndex == 0 || borrowingIndex > _borrowingsNumber
            || _borrowings[borrowingIndex].liquidated
        ) return 0;

        address userAddress = _borrowings[borrowingIndex].userAddress;
        (uint256 totalCollateralUsdAmount, uint256 feeCollateralUsdAmount) =
            _collateralContract.getTotalCollateralUsdAmounts(userAddress);

        if (feeCollateralUsdAmount * totalCollateralUsdAmount == 0) return 0;

        if (_borrowings[borrowingIndex].fixedApr > 0) {
            return _getFixedFee(borrowingIndex) * feeCollateralUsdAmount
                / totalCollateralUsdAmount;
        } else {
            return _getDynamicFee(borrowingIndex) * feeCollateralUsdAmount
                / totalCollateralUsdAmount;
        }
    }

    /**
     * @dev Calculating fixed fee
     */
    function _getFixedFee (uint256 borrowingIndex) internal view returns (uint256) {
        if (_borrowings[borrowingIndex].liquidated) return 0;
        uint256 period = block.timestamp - _borrowings[borrowingIndex].updatedAt;
        uint256 fee = _borrowings[borrowingIndex].amount
            * _borrowings[borrowingIndex].fixedApr
            * period
            / DECIMALS
            / YEAR;
        return fee;
    }

    /**
     * @dev Calculating non fixed fee
     */
    function _getDynamicFee (
        uint256 borrowingIndex
    ) internal view returns (uint256) {
        uint256 profileIndex = _borrowings[borrowingIndex].borrowingProfileIndex;
        uint256 marketIndex = _borrowingProfiles[profileIndex].borrowingMarketIndex;
        uint256 extraPeriodStartTime =
            _borrowingProfiles[profileIndex].borrowingMarketIndexLastTime;
        if (extraPeriodStartTime < _borrowings[borrowingIndex].updatedAt) {
            extraPeriodStartTime = _borrowings[borrowingIndex].updatedAt;
        }
        uint256 extraPeriod = block.timestamp - extraPeriodStartTime;

        if (extraPeriod > 0) {
            uint256 marketFactor = SHIFT +
                SHIFT * getBorrowingApr(
                    _borrowings[borrowingIndex].borrowingProfileIndex
                )
                * extraPeriod / DECIMALS / YEAR;
            marketIndex = marketIndex * marketFactor / SHIFT;
        }

        uint256 newAmount = _borrowings[borrowingIndex].amount
            * marketIndex
            / _borrowings[borrowingIndex].lastMarketIndex;

        return newAmount - _borrowings[borrowingIndex].amount;
    }

    /**
     * @dev Helper function for getting amount borrowed by user in USD
     */
    function getBorrowedUsdAmount (
        address userAddress
    ) public view returns (uint256) {
        uint256 borrowedUsdAmount;
        for (uint256 i = 1; i <= _borrowingProfilesNumber; i ++) {
            uint256 borrowingIndex = _usersBorrowingIndexes[userAddress][i];
            borrowedUsdAmount += getBorrowingUsdAmount(borrowingIndex);
        }

        return borrowedUsdAmount;
    }

    /**
     * @dev Helper function for getting borrowing amount of the specific
     * borrowing record in USD
     */
    function getBorrowingUsdAmount (
        uint256 borrowingIndex
    ) public view returns (uint256) {
        if (
            borrowingIndex == 0 || _borrowings[borrowingIndex].liquidated
            || _borrowings[borrowingIndex].amount == 0
        ) return 0;
        uint256 borrowingProfileIndex = _borrowings[borrowingIndex].borrowingProfileIndex;
        return (_borrowings[borrowingIndex].amount + _borrowings[borrowingIndex].accumulatedFee
                + _getBorrowingFee(borrowingIndex))
            * getUsdRate(_borrowingProfiles[borrowingProfileIndex].contractAddress)
            / SHIFT;
    }

    function _updateAllBorrowingFees (
        address userAddress
    ) internal returns (bool) {
        for (uint256 i = 1; i <= _borrowingProfilesNumber; i ++) {
            uint256 borrowingIndex =
                _usersBorrowingIndexes[userAddress][i];
            if (borrowingIndex == 0) continue;
            _updateBorrowingFee(borrowingIndex);
        }
        return true;
    }

    function updateAllBorrowingFees (
        address userAddress
    ) external onlyCollateralContract returns (bool) {
        return _updateAllBorrowingFees(userAddress);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import './utils.sol';

/**
 * @dev Partial interface of the NftCollateral contract.
 */
interface ICollateral {
    function getTotalCollateralUsdAmounts (
        address userAddress
    ) external view returns (uint256, uint256);

    function getLiquidationManager () external view returns (address);

    function getUserCollateralUsdAmount (
        address userAddress,
        bool borrowingPower
    ) external view returns (uint256);
}

/**
 * @dev Interface of the Proxy contract.
 */
interface IProxy {
    function getUsdRate (
        address contractAddress
    ) external view returns (uint256);
}

/**
 * @dev Interface of the Proxy contract.
 */
interface IReward {
    function updateRewardData (
        address userAddress,
        uint256 profileId,
        uint256 lent,
        uint256 totalLent
    ) external returns (bool);
}

/**
 * @dev Storage functional for a BorrowingLending contract,
 * functions names are self explanatory
 */
contract StorageContract is UtilsContract {
    event BorrowingLiquidation (
        address indexed userAddress, address indexed liquidatorAddress,
        uint256 borrowingIndex, uint256 timestamp
    );
    event AccessVaultWithdraw (
        address tokenAddress,  uint256 amount, uint256 timestamp
    );
    event AccessVaultReplenish (
        address tokenAddress,  uint256 amount, uint256 timestamp
    );

    modifier onlyOwner() {
        require(msg.sender == _owner, '62');
        _;
    }
    modifier onlyManager() {
        require(_managers[msg.sender], '63');
        _;
    }
    modifier onlyCollateralContract() {
        require(msg.sender == address(_collateralContract), '791');
        _;
    }
    modifier onlyAccessVault() {
        require(msg.sender == _accessVault, '792');
        _;
    }

    struct BorrowingProfile {
        address contractAddress;
        uint256 borrowingMarketIndex;
        uint256 borrowingMarketIndexLastTime;
        uint256 lendingMarketIndex;
        uint256 lendingMarketIndexLastTime;
        uint256 totalBorrowed;
        uint256 totalLent;
        uint256 totalLiquidated;
        uint256 totalReturned;
        bool active;
    }
    struct Borrowing {
        address userAddress;
        uint256 borrowingProfileIndex;
        uint256 amount;
        uint256 lastMarketIndex;
        uint256 updatedAt; // timestamp, is resettled to block.timestamp when changed
        uint256 accumulatedFee; // used to store fee when changed
        uint256 fixedApr;
        bool liquidated;
    }
    struct Lending {
        address userAddress;
        uint256 borrowingProfileIndex;
        uint256 amount;
        uint256 unlock;
        uint256 lastMarketIndex;
        uint256 updatedAt; // timestamp, is resettled to block.timestamp when changed
        uint256 accumulatedYield; // used to store reward when changed
    }
    struct UsdRate {
        uint256 rate;
        uint256 updatedAt;
        bool proxy;
    }
    mapping (uint256 => BorrowingProfile) internal _borrowingProfiles;
    mapping (uint256 => Borrowing) internal _borrowings;
    mapping (uint256 => Lending) internal _lendings;
    mapping (address => UsdRate) internal _usdRates;
    mapping (address => bool) internal _managers;
    mapping (address => mapping(uint256 => uint256)) internal _usersBorrowingIndexes;
    // userAddress => borrowingProfileIndex => borrowingIndex
    mapping (address => mapping(uint256 => uint256)) internal _usersLendingIndexes;
    // userAddress => borrowingProfileIndex => lendingIndex
    mapping (address => bool) internal _isUser;

    ICollateral internal _collateralContract;
    IProxy internal _proxyContract;
    IReward internal _rewardContract;
    address internal _owner;
    address internal _accessVault;
    uint256 internal _totalUsers;
    uint256 internal _borrowingProfilesNumber;
    uint256 internal _borrowingsNumber;
    uint256 internal _lendingsNumber;
    uint256 internal constant YEAR = 365 * 24 * 3600;
    uint256 internal constant SHIFT = 1 ether;
    // exponent shifting when calculation with decimals for market index and usd rate
    uint256 internal constant DECIMALS = 10000;
    // exponent shifting when calculation with decimals for percents
    uint256 internal _lockTime = 0; // period when withdraw lending is prohibited
    uint16 internal _aprBorrowingMin; // % * 100
    uint16 internal _aprBorrowingMax; // % * 100
    uint16 internal _aprBorrowingFixed; // % * 100
    uint16 internal _aprLendingMin; // % * 100
    uint16 internal _aprLendingMax; // % * 100

    function addBorrowingProfile (
        address contractAddress
    ) external onlyManager returns (bool) {
        require(contractAddress != address(0), '64');
        _borrowingProfilesNumber ++;
        _borrowingProfiles[_borrowingProfilesNumber].contractAddress = contractAddress;
        _borrowingProfiles[_borrowingProfilesNumber].borrowingMarketIndex = SHIFT;
        _borrowingProfiles[_borrowingProfilesNumber].borrowingMarketIndexLastTime = block.timestamp;
        _borrowingProfiles[_borrowingProfilesNumber].lendingMarketIndex = SHIFT;
        _borrowingProfiles[_borrowingProfilesNumber].lendingMarketIndexLastTime = block.timestamp;
        _borrowingProfiles[_borrowingProfilesNumber].active = true;
        return true;
    }

    function setBorrowingProfileStatus (
        uint256 borrowingProfileIndex,
        bool active
    ) external onlyManager returns (bool) {
        require(borrowingProfileIndex > 0 && borrowingProfileIndex <= _borrowingProfilesNumber,
            '65');
        _borrowingProfiles[borrowingProfileIndex].active = active;
        return true;
    }

    /**
     * @dev Helper function that allows manager to change liquidation status manually
     */
    function setBorrowingLiquidationStatus (
        uint256 borrowingIndex, bool liquidated
    ) external onlyManager returns (bool) {
        require(borrowingIndex > 0 && borrowingIndex <= _borrowingsNumber,
            '67');
        _borrowings[borrowingIndex].liquidated = liquidated;

        return true;
    }

    function setLockTime (
        uint256 lockTime
    ) external onlyManager returns (bool) {
        _lockTime = lockTime;
        return true;
    }

    function setUsdRateData (
        address contractAddress,
        uint256 rate,
        bool proxy
    ) external onlyManager returns (bool) {
        _usdRates[contractAddress].rate = rate;
        _usdRates[contractAddress].proxy = proxy;
        _usdRates[contractAddress].updatedAt = block.timestamp;
        return true;
    }

    function setCollateralContract (
        address collateralContractAddress
    ) external onlyManager returns (bool) {
        require(collateralContractAddress != address(0), '75');
        _collateralContract = ICollateral(collateralContractAddress);
        return true;
    }

    function setProxyContract (
        address proxyContractAddress
    ) external onlyManager returns (bool) {
        _proxyContract = IProxy(proxyContractAddress);
        return true;
    }

    function setRewardContract (
        address rewardContractAddress
    ) external onlyManager returns (bool) {
        _rewardContract = IReward(rewardContractAddress);
        return true;
    }

    function setAccessVault (
        address accessVault
    ) external onlyManager returns (bool) {
        _accessVault = accessVault;
        return true;
    }

    function accessVaultWithdraw(
        uint256 borrowingProfileIndex,
        uint256 amount
    ) external onlyAccessVault returns (bool) {
        require(borrowingProfileIndex > 0 && borrowingProfileIndex <= _borrowingProfilesNumber,
            '65');
        IERC20 tokenContract = IERC20(
            _borrowingProfiles[borrowingProfileIndex].contractAddress
        );
        require(tokenContract.balanceOf(address(this)) >= amount, '794');
        _sendAsset(
            _borrowingProfiles[borrowingProfileIndex].contractAddress,
            _accessVault,
            amount
        );
        emit AccessVaultWithdraw(
            _borrowingProfiles[borrowingProfileIndex].contractAddress,
            amount,
            block.timestamp
        );
        return true;
    }

    function accessVaultReplenish(
        uint256 borrowingProfileIndex,
        uint256 amount
    ) external onlyAccessVault returns (bool) {
        require(borrowingProfileIndex > 0 && borrowingProfileIndex <= _borrowingProfilesNumber,
            '65');
        _takeAsset(
            _borrowingProfiles[borrowingProfileIndex].contractAddress,
            _accessVault,
            amount
        );
        emit AccessVaultReplenish(
            _borrowingProfiles[borrowingProfileIndex].contractAddress,
            amount,
            block.timestamp
        );
        return true;
    }

    function transferOwnership(address newOwner) public onlyOwner returns (bool) {
        require(newOwner != address(0), '793');
        _owner = newOwner;
        return true;
    }

    function addToManagers (
        address userAddress
    ) external onlyOwner returns (bool) {
        _managers[userAddress] = true;
        return true;
    }

    function removeFromManagers (
        address userAddress
    ) external onlyOwner returns (bool) {
        _managers[userAddress] = false;
        return true;
    }

    function updateUsersList (
        address userAddress
    ) external onlyCollateralContract returns (bool) {
        if (!_isUser[userAddress]) {
            _totalUsers ++;
            _isUser[userAddress] = true;
        }
        return true;
    }

    // view functions
    function getBorrowingsNumber () external view returns (uint256) {
        return _borrowingsNumber;
    }

    function getUsersBorrowingIndex (
        address userAddress, uint256 borrowingProfileIndex
    ) external view returns (uint256) {
        if (
            _borrowings[
                _usersBorrowingIndexes[userAddress][borrowingProfileIndex]
            ].liquidated
        ) return 0;
        return _usersBorrowingIndexes[userAddress][borrowingProfileIndex];
    }

    function getBorrowing (uint256 borrowingIndex) external view returns (
        address userAddress, uint256 borrowingProfileIndex,
        uint256 amount, uint256 accumulatedFee, bool liquidated
    ) {
        return (
            _borrowings[borrowingIndex].userAddress,
            _borrowings[borrowingIndex].borrowingProfileIndex,
            _borrowings[borrowingIndex].amount,
            _borrowings[borrowingIndex].accumulatedFee,
            _borrowings[borrowingIndex].liquidated
        );
    }

    function getBorrowingMarketIndex (uint256 borrowingIndex) external view returns (
        uint256 lastMarketIndex, uint256 updatedAt, uint256 fixedApr
    ) {
        return (
            _borrowings[borrowingIndex].lastMarketIndex,
            _borrowings[borrowingIndex].updatedAt,
            _borrowings[borrowingIndex].fixedApr
        );
    }

    function getLendingsNumber () external view returns (uint256) {
        return _lendingsNumber;
    }

    function getUsersLendingIndex (
        address userAddress, uint256 borrowingProfileIndex
    ) external view returns (uint256) {
        return _usersLendingIndexes[userAddress][borrowingProfileIndex];
    }

    function getLending (uint256 lendingIndex) external view returns (
        address userAddress, uint256 borrowingProfileIndex, uint256 amount,
        uint256 unlock, uint256 accumulatedYield
    ) {
        return (
            _lendings[lendingIndex].userAddress,
            _lendings[lendingIndex].borrowingProfileIndex,
            _lendings[lendingIndex].amount,
            _lendings[lendingIndex].unlock,
            _lendings[lendingIndex].accumulatedYield
        );
    }

    function getLendingMarketIndex (uint256 lendingIndex) external view returns (
        uint256 lastMarketIndex, uint256 updatedAt
    ) {
        return (
            _lendings[lendingIndex].lastMarketIndex,
            _lendings[lendingIndex].updatedAt
        );
    }

    function getBorrowingProfilesNumber () external view returns (uint256) {
        return _borrowingProfilesNumber;
    }

    function getBorrowingProfile (uint256 borrowingProfileIndex) external view returns (
        address contractAddress, uint256 totalBorrowed,
        uint256 totalLent, uint256 totalLiquidated,
        uint256 totalReturned, bool active
    ) {
        return (
            _borrowingProfiles[borrowingProfileIndex].contractAddress,
            _borrowingProfiles[borrowingProfileIndex].totalBorrowed,
            _borrowingProfiles[borrowingProfileIndex].totalLent,
            _borrowingProfiles[borrowingProfileIndex].totalLiquidated,
            _borrowingProfiles[borrowingProfileIndex].totalReturned,
            _borrowingProfiles[borrowingProfileIndex].active
        );
    }

    function getBorrowingProfileMarketIndexes (
        uint256 borrowingProfileIndex
    ) external view returns (
        uint256 borrowingMarketIndex, uint256 borrowingMarketIndexLastTime,
        uint256 lendingMarketIndex, uint256 lendingMarketIndexLastTime
    ) {
        return (
            _borrowingProfiles[borrowingProfileIndex].borrowingMarketIndex,
            _borrowingProfiles[borrowingProfileIndex].borrowingMarketIndexLastTime,
            _borrowingProfiles[borrowingProfileIndex].lendingMarketIndex,
            _borrowingProfiles[borrowingProfileIndex].lendingMarketIndexLastTime
        );
    }

    function getCollateralContract () external view returns (address) {
        return address(_collateralContract);
    }

    function getProxyContract () external view returns (address) {
        return address(_proxyContract);
    }

    function getRewardContract () external view returns (address) {
        return address(_rewardContract);
    }

    function getAccessVault () external view returns (address) {
        return _accessVault;
    }

    function getUsdRateData (
        address contractAddress
    ) external view returns (
        uint256 rate, uint256 updatedAt, bool proxy
    ) {
        return (
            _usdRates[contractAddress].rate,
            _usdRates[contractAddress].updatedAt,
            _usdRates[contractAddress].proxy
        );
    }

    function getUsdRate (
        address contractAddress
    ) public view returns (uint256) {
        if (!_usdRates[contractAddress].proxy) return _usdRates[contractAddress].rate;
        return _proxyContract.getUsdRate(contractAddress);
    }

    function getLockTime () external view returns (uint256) {
        return _lockTime;
    }

    function getAprSettings () external view returns (
        uint16 aprBorrowingMin,
        uint16 aprBorrowingMax,
        uint16 aprBorrowingFixed,
        uint16 aprLendingMin,
        uint16 aprLendingMax
    ) {
        return (
            _aprBorrowingMin,
            _aprBorrowingMax,
            _aprBorrowingFixed,
            _aprLendingMin,
            _aprLendingMax
        );
    }

    function getTokenBalance (
        address tokenContractAddress
    ) external view returns (uint256) {
        IERC20 tokenContract = IERC20(tokenContractAddress);
        return tokenContract.balanceOf(address(this));
    }

    function isManager (
        address userAddress
    ) external view returns (bool) {
        return _managers[userAddress];
    }

    function isUser (
        address userAddress
    ) external view returns (bool) {
        return _isUser[userAddress];
    }

    function getTotalUsers () external view returns (uint256) {
        return _totalUsers;
    }

    function owner () external view returns (address) {
        return _owner;
    }

    /**
    * Migrating borrowing data from another contract
    * uint256 values collected into a single array "number" with
    * length 5 times greater than "userAddresses" array
    * Data in "number" array ordered as follows
    * 1 borrowingProfileIndexes
    * 2 amounts
    * 3 fees
    * 4 fixedApr
    * 5 liquidated (if > 0 -> true)
    */
    function migrateBorrowings (
        address[] calldata userAddresses,
        uint256[] calldata numbers
    ) external onlyManager returns (bool) {
        uint256[] memory totalBorrowed = new uint256[](_borrowingProfilesNumber);
        require(
            userAddresses.length * 5 == numbers.length,
            'numbers array length mismatch'
        );
        for (uint256 i; i < userAddresses.length; i ++) {
            if (i > 100) break;
            if (
                _usersBorrowingIndexes[userAddresses[i]]
                    [numbers[i]] > 0
            ) continue;
            _borrowingsNumber ++;
            _borrowings[_borrowingsNumber].userAddress = userAddresses[i];
            _borrowings[_borrowingsNumber].borrowingProfileIndex =
                numbers[i];
            _borrowings[_borrowingsNumber].lastMarketIndex =
                _borrowingProfiles[numbers[i]].borrowingMarketIndex;
            _borrowings[_borrowingsNumber].updatedAt = block.timestamp;
            _borrowings[_borrowingsNumber].amount =
                numbers[i + userAddresses.length];
            _borrowings[_borrowingsNumber].accumulatedFee =
                numbers[i + userAddresses.length * 2];
            _borrowings[_borrowingsNumber].fixedApr =
                numbers[i + userAddresses.length * 3];
            _borrowings[_borrowingsNumber].liquidated =
                numbers[i + userAddresses.length * 4] > 0;
            _usersBorrowingIndexes[userAddresses[i]]
                [numbers[i]] = _borrowingsNumber;
            totalBorrowed[numbers[i] - 1] += numbers[i + userAddresses.length];
        }
        for (uint256 i = 1; i <= _borrowingProfilesNumber; i ++) {
            if (totalBorrowed[i - 1] == 0) continue;
            _borrowingProfiles[i].totalBorrowed += totalBorrowed[i - 1];
        }
        return true;
    }

    /**
    * Migrating lending data from another contract
    * uint256 values collected into a single array "number" with
    * length 4 times greater than "userAddresses" array
    * Data in "number" array ordered as follows
    * 1 borrowingProfileIndexes
    * 2 amounts
    * 3 yields
    * 4 unlock
    */
    function migrateLendings (
        address[] calldata userAddresses,
        uint256[] calldata numbers
    ) external onlyManager returns (bool) {
        uint256[] memory totalLent = new uint256[](_borrowingProfilesNumber);
        require(
            userAddresses.length * 4 == numbers.length,
            'numbers array length mismatch'
        );
        for (uint256 i; i < userAddresses.length; i ++) {
            if (i > 100) break;
            if (
                _usersLendingIndexes[userAddresses[i]]
                    [numbers[i]] > 0
            ) continue;
            _lendingsNumber ++;
            _lendings[_lendingsNumber].userAddress = userAddresses[i];
            _lendings[_lendingsNumber].borrowingProfileIndex =
                numbers[i];
            _lendings[_lendingsNumber].lastMarketIndex =
                _borrowingProfiles[numbers[i]].lendingMarketIndex;
            _lendings[_lendingsNumber].updatedAt = block.timestamp;
            _lendings[_lendingsNumber].amount =
                numbers[i + userAddresses.length];
            _lendings[_lendingsNumber].accumulatedYield =
                numbers[i + userAddresses.length * 2];
            _lendings[_lendingsNumber].unlock =
                numbers[i + userAddresses.length * 3];
            _usersLendingIndexes[userAddresses[i]]
                [numbers[i]] = _lendingsNumber;
            totalLent[numbers[i] - 1] += numbers[i + userAddresses.length];
        }
        for (uint256 i = 1; i <= _borrowingProfilesNumber; i ++) {
            if (totalLent[i - 1] == 0) continue;
            _borrowingProfiles[i].totalLent += totalLent[i - 1];
        }
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @dev Partial interface of the ERC20 standard.
 */
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient, uint256 amount
    ) external returns (bool);
    function transferFrom(
        address sender, address recipient, uint256 amount
    ) external returns (bool);
    function allowance(
        address owner, address spender
    ) external view returns (uint256);
    function decimals() external view returns (uint8);
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, '80');

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

/**
 * @dev Contract utils implement helper functions for the assets transfer
 */
contract UtilsContract is ReentrancyGuard {
    /**
     * @dev helper function to get paid in Erc20 tokens
     */
    function _takeAsset (
        address tokenAddress, address fromAddress, uint256 amount
    ) internal returns (bool) {
        require(tokenAddress != address(0), '81');
        IERC20 tokenContract = IERC20(tokenAddress);

        require(tokenContract.transferFrom(fromAddress, address(this), amount));

        return true;
    }

    /**
    * @dev Assets sending, both native currency (when tokenAddreess is set to zero) and erc20 tokens
    */
    function _sendAsset (
        address tokenAddress, address toAddress, uint256 amount
    ) internal nonReentrant returns (bool) {
        if (tokenAddress == address(0)) {
            require(address(this).balance >= amount, '82');
            payable(toAddress).transfer(amount);
        } else {
            IERC20 tokenContract = IERC20(tokenAddress);
            require(tokenContract.transfer(toAddress, amount));
        }
        return true;
    }
}