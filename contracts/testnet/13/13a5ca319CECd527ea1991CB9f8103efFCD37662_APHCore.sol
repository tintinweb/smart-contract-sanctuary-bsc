// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "./CoreBase.sol";
import "./CoreBorrowing.sol";
import "./CoreSetting.sol";
import "../../interfaces/IAPHPool.sol";

contract APHCore is CoreBase, CoreBorrowing, CoreSetting {
    function initialize() external initializer {
        manager = msg.sender;

        WEI_UNIT = 10**18;
        WEI_PERCENT_UNIT = 10**20;
        SEC_IN_WEEK = 7 days;
        SEC_IN_YEAR = 365 days;

        feeSpread = 10 ether;
        loanDuration = 28 days;
        advancedInterestDuration = 3 days;

        maxDisagreement = 5 ether;
        maxSwapSize = 1500 ether;

        routerAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        // routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // mainnet

        BUSDAddress = 0x665aE6c8B332cCE9B1B50d9B2c79d1731516d2fB;

        // TODO: emit event
        // emit SetGovernor(_governor);
        // emit SetOracle(_oracle);
        // emit SetConfig(_config);
        // emit SetInterestModel(_interestModel);
        emit TransferManager(address(0), manager);
    }

    function settleForwInterest() external {
        require(poolToAsset[msg.sender] != address(0), "APHCore/caller-is-not-pool");
        uint256 forwAmount = _settleForwInterest();
        _transferFromOut(
            forwDistributorAddress,
            IAPHPool(msg.sender).interestVaultAddress(),
            IAPHPool(msg.sender).forwAddress(),
            forwAmount
        );
    }

    function getLoan(uint256 nftId, uint256 loanId) external view returns (Loan memory) {
        Loan storage loan = loans[nftId][loanId];
        if (loanId != 0) {
            return loan;
        }
        return loan;
    }

    function isPool(address poolAddess) external view returns (bool) {
        return poolToAsset[poolAddess] != address(0);
    }

    function getLoanConfig(address _borrowTokenAddress, address _collateralTokenAddress)
        external
        view
        returns (LoanConfig memory)
    {
        LoanConfig storage loanConfig = loanConfigs[_borrowTokenAddress][_collateralTokenAddress];
        return loanConfig;
    }

    function getActiveLoansId(uint256 nftId) external view returns (uint256[] memory) {
        mapping(uint256 => Loan) storage loanList = loans[nftId];
        uint256 currentLoanIndex = currentIndex[nftId];
        uint256[] memory activeLoanIds = new uint256[](currentLoanIndex);
        uint256 count = 0;
        for (uint256 i = 0; i < currentLoanIndex; i++) {
            if (loanList[i].active) {
                activeLoanIds[count] = i;
                count++;
            }
        }
        return activeLoanIds;
    }

    function getActiveLoans(uint256 nftId) external view returns (Loan[] memory) {
        mapping(uint256 => Loan) storage loanList = loans[nftId];
        uint256 currentLoanIndex = currentIndex[nftId];
        Loan[] memory activeLoans = new Loan[](currentLoanIndex);
        uint256 count = 0;
        for (uint256 i = 0; i < currentLoanIndex; i++) {
            if (loanList[i].active) {
                activeLoans[count] = loanList[i];
                count++;
            }
        }
        return activeLoans;
    }

    function getPoolList() external view returns (address[] memory) {
        return poolList;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

// import "../../externalContract/openzeppelin/Ownable.sol";
import "../../externalContract/openzeppelin/ReentrancyGuard.sol";
import "../../externalContract/openzeppelin/Initializable.sol";
import "../../externalContract/modify/SelectorPausable.sol";

import "../../interfaces/IAPHPool.sol";
import "../../interfaces/IInterestVault.sol";

import "../utils/AssetHandler.sol";
import "../utils/Manager.sol";

contract CoreBase is AssetHandler, Manager, ReentrancyGuard, Initializable, SelectorPausable {
    struct LoanInterest {
        uint256 owedPerDay;
        uint256 minInterest;
        uint256 interestOwed;
        uint256 interestPaid;
        uint256 bountyFee;
        uint64 rolloverTimestamp;
        uint64 lastSettleTimestamp;
    }

    struct Loan {
        bool active;
        address borrowTokenAddress;
        address collateralTokenAddress;
        uint64 startTimestamp;
        uint256 borrowAmount;
        uint256 collateralAmount;
        uint256 initialBorrowTokenPrice;
        uint256 initialCollateralTokenPrice;
    }

    struct LoanConfig {
        address borrowTokenAddress;
        address collateralTokenAddress;
        uint256 safeLTV;
        uint256 maxLTV;
        uint256 liquidationLTV;
        uint256 bountyFeeRate;
    }

    struct PoolStat {
        address tokenAddress;
        uint64 updatedTimestamp;
        uint256 totalPrincipal;
        uint256 borrowInterestOwedPerDay;
        uint256 totalInterestPaid;
    }

    // constant
    uint256 internal WEI_UNIT; //                                                           // 1e18
    uint256 internal WEI_PERCENT_UNIT; //                                                   // 1e20 (100*1e18 for calculating percent)
    uint256 internal SEC_IN_WEEK;
    uint256 internal SEC_IN_YEAR;

    // lending
    uint256 public feeSpread; //                                                            // 10% fee                                                    // fee taken from lender interest payments (fee when protocol settles interest to pool)

    // borrowing
    uint256 public loanDuration; //                                                         // max days for borrowing with fix rate interest
    uint256 public advancedInterestDuration; //                                             // duration for calculation min interest
    mapping(uint256 => mapping(uint256 => Loan)) public loans; //                           // nftId => loanId => loan
    mapping(uint256 => mapping(uint256 => LoanInterest)) public loanInterests; //           // nftId => loanId => loanInterest
    mapping(uint256 => uint256) public currentIndex; //                                     // nftId => currentIndex
    mapping(address => mapping(address => LoanConfig)) public loanConfigs; //               // borrowToken => collateralToken => config

    // stat
    mapping(address => uint256) public totalCollateralHold; //                              // tokenAddress => total collateral amoyunt
    mapping(address => PoolStat) public poolStats; //                                       // pool's address => borrowStat
    mapping(address => bool) public swapableToken; //                                       // check that token is allowed for swap
    mapping(address => address) public poolToAsset; //                                      // pool => underlying (token address)
    mapping(address => address) public assetToPool; //                                      // underlying => pool
    address[] public poolList; //                                                           // list of pool

    // forw distributor
    mapping(address => uint256) public forwPerBlock; //                                     // forwardRewardPerBlock ?
    mapping(address => uint256) public lastSettleForw; //                                   // lastest settle forward by pool
    address public forwDistributorAddress;

    uint256 public maxDisagreement; //                                                      // % disagreement between swap rate and reference rate
    uint256 public maxSwapSize; //                                                          // maximum supported swap size in ETH

    address public feesController; //                                                       // address controlling fee withdrawals
    address public oracleAddress; //                                                        // handles asset reference price lookups
    address public routerAddress; //                                                        // handles asset swaps using dex liquidity
    address public membershipAddress; //                                                    // address of membership contract

    address internal BUSDAddress;

    function pause(bytes4 _func) external onlyManager {
        require(_func != bytes4(0), "");
        _pause(_func);
    }

    function unPause(bytes4 _func) external onlyManager {
        require(_func != bytes4(0), "");
        _unpause(_func);
    }

    function _settleForwInterest() internal returns (uint256 forwAmount) {
        uint256 blockDiff = block.number - lastSettleForw[msg.sender];
        if (blockDiff != 0) {
            forwAmount = blockDiff * forwPerBlock[msg.sender];
            lastSettleForw[msg.sender] = block.number;
        }
        IInterestVault(IAPHPool(msg.sender).interestVaultAddress()).settleInterest(
            0,
            0,
            forwAmount
        );
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../../externalContract/openzeppelin/Math.sol";
import "../../interfaces/IRouter.sol";
import "../../interfaces/IMembership.sol";
import "../../interfaces/IPriceFeed.sol";

import "./event/CoreBorrowingEvent.sol";
import "./CoreBase.sol";

import "../mock/MockPriceFeed.sol";

contract CoreBorrowing is CoreBase, CoreBorrowingEvent {
    // Mock function to test price feed on hardhat
    bool public isHardhatEnv;
    address public mockFeedAddr;

    function setIsHardHatEnv(bool i) external onlyManager {
        isHardhatEnv = i;
    }

    function setMockFeedAddr(address _address) external onlyManager {
        mockFeedAddr = _address;
    }

    //////////////////////////////////////////////

    function borrow(
        uint256 loanId,
        uint256 nftId,
        uint256 borrowAmount,
        address borrowTokenAddress,
        uint256 collateralSentAmount,
        address collateralTokenAddress,
        uint256 newOwedPerDay,
        uint256 interestRate
    ) external whenFuncNotPaused(msg.sig) returns (Loan memory) {
        nftId = IMembership(membershipAddress).usableTokenId(nftId);
        return
            _borrow(
                loanId,
                nftId,
                borrowAmount,
                borrowTokenAddress,
                collateralSentAmount,
                collateralTokenAddress,
                newOwedPerDay,
                interestRate
            );
    }

    function repay(
        uint256 loanId,
        uint256 nftId,
        uint256 repayAmount,
        bool isOnlyInterest
    ) external whenFuncNotPaused(msg.sig) returns (uint256, uint256) {
        nftId = IMembership(membershipAddress).usableTokenId(nftId);
        Loan storage loan = loans[nftId][loanId];
        (uint256 borrowPaid, uint256 interestPaid) = _repay(
            loanId,
            nftId,
            repayAmount,
            isOnlyInterest
        );
        if (borrowPaid + interestPaid > 0) {
            _transferFromIn(
                IMembership(membershipAddress).ownerOf(nftId),
                assetToPool[loan.collateralTokenAddress],
                loan.collateralTokenAddress,
                borrowPaid + interestPaid
            );
        }
        return (borrowPaid, interestPaid);
    }

    function adjustCollateral(
        uint256 loanId,
        uint256 nftId,
        uint256 collateralAdjustAmount,
        bool isAdd
    ) external whenFuncNotPaused(msg.sig) returns (Loan memory) {
        nftId = IMembership(membershipAddress).usableTokenId(nftId);
        Loan storage loan = loans[nftId][loanId];
        if (isAdd) {
            _transferFromIn(
                IMembership(membershipAddress).ownerOf(nftId),
                address(this),
                loan.collateralTokenAddress,
                collateralAdjustAmount
            );
        }
        Loan memory loanData = _adjustCollateral(loanId, nftId, collateralAdjustAmount, isAdd);
        if (!isAdd) {
            _transferOut(msg.sender, loan.collateralTokenAddress, collateralAdjustAmount);
        }
        return loanData;
    }

    function rollover(uint256 loanId, uint256 nftId)
        external
        whenFuncNotPaused(msg.sig)
        returns (uint256, uint256)
    {
        nftId = IMembership(membershipAddress).usableTokenId(nftId);
        return _rollover(loanId, nftId, address(this));
    }

    function liquidate(uint256 loanId, uint256 nftId)
        external
        whenFuncNotPaused(msg.sig)
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        nftId = IMembership(membershipAddress).usableTokenId(nftId);
        Loan storage loan = loans[nftId][loanId];
        (
            uint256 repayBorrow,
            uint256 repayInterest,
            uint256 bountyReward,
            uint256 backToUser
        ) = _liquidate(loanId, nftId);

        //TODO: if liquidator is official liq transfer bounty to vault
        _transferOut(msg.sender, loan.borrowTokenAddress, bountyReward);
        _transferOut(
            IMembership(membershipAddress).ownerOf(nftId),
            loan.borrowTokenAddress,
            backToUser
        );
        return (repayBorrow, repayInterest, bountyReward, backToUser);
    }

    // internal function
    function _borrow(
        uint256 loanId,
        uint256 nftId,
        uint256 borrowAmount,
        address borrowTokenAddress,
        uint256 collateralSentAmount,
        address collateralTokenAddress,
        uint256 newOwedPerDay,
        uint256 interestRate
    ) internal returns (Loan memory) {
        require(
            msg.sender == assetToPool[borrowTokenAddress],
            "CoreBorrowing/permission-denied-for-borrow"
        );

        Loan storage loan;
        LoanInterest storage loanInterest;
        uint256[] memory numberArray = new uint256[](3);
        //newLoan
        numberArray[0] = 1;

        if (loanId == 0) {
            currentIndex[nftId] += 1;
            loanId = currentIndex[nftId];
            loan = loans[nftId][loanId];
            loanInterest = loanInterests[nftId][loanId];
        } else {
            loan = loans[nftId][loanId];
            loanInterest = loanInterests[nftId][loanId];
            numberArray[0] = 0;

            require(loan.active == true, "CoreBorrowing/loan-is-closed");

            _settleBorrowInterest(loanInterest);
        }

        if (loan.startTimestamp == 0) {
            loan.borrowTokenAddress = borrowTokenAddress;
            loan.collateralTokenAddress = collateralTokenAddress;

            if (isHardhatEnv) {
                loan.initialBorrowTokenPrice = MockPriceFeed(mockFeedAddr).getPrice(
                    borrowTokenAddress,
                    BUSDAddress
                );
                loan.initialCollateralTokenPrice = MockPriceFeed(mockFeedAddr).getPrice(
                    collateralTokenAddress,
                    BUSDAddress
                );
            } else {
                (loan.initialBorrowTokenPrice, ) = IPriceFeed(oracleAddress).queryRate(
                    borrowTokenAddress,
                    BUSDAddress
                ); //load price
                (loan.initialCollateralTokenPrice, ) = IPriceFeed(oracleAddress).queryRate(
                    collateralTokenAddress,
                    BUSDAddress
                ); //load price
            }
            loan.active = true;
            loan.startTimestamp = uint64(block.timestamp);
            loanInterest.owedPerDay = newOwedPerDay;
        } else {
            loanInterest.owedPerDay =
                ((loanInterest.owedPerDay * (loanInterest.rolloverTimestamp - block.timestamp)) +
                    (newOwedPerDay * loanDuration) +
                    ((interestRate *
                        borrowAmount *
                        (loanDuration - ((loanInterest.rolloverTimestamp - block.timestamp)))) /
                        365)) /
                loanDuration;
        }

        loan.borrowAmount += borrowAmount;
        loan.collateralAmount += collateralSentAmount;
        loanInterest.rolloverTimestamp = uint64(block.timestamp + loanDuration);
        loanInterest.minInterest += (newOwedPerDay * advancedInterestDuration);
        //maxLTV
        numberArray[1] = loanConfigs[borrowTokenAddress][collateralTokenAddress].maxLTV;
        //rate and precision
        if (isHardhatEnv) {
            numberArray[1] = MockPriceFeed(mockFeedAddr).getPrice(
                loan.collateralTokenAddress,
                loan.borrowTokenAddress
            );
            numberArray[2] = MockPriceFeed(mockFeedAddr).getPrecision(
                loan.collateralTokenAddress,
                loan.borrowTokenAddress
            );
        } else {
            (numberArray[1], numberArray[2]) = IPriceFeed(oracleAddress).queryRate(
                loan.collateralTokenAddress,
                loan.borrowTokenAddress
            );
        }

        require(
            // _isLoanLTVExceedMaxLTV(loan, numberArray[1], numberArray[2] / numberArray[3]) == false,
            _isLoanLTVExceedMaxLTV(
                loan.borrowAmount,
                loan.collateralAmount,
                loanInterest.interestOwed,
                loanConfigs[borrowTokenAddress][collateralTokenAddress].maxLTV,
                numberArray[1] / numberArray[2]
            ) == false,
            "CoreBorrowing/loan-LTV-is-exceed-maxLTV"
        );

        emit Borrow(
            tx.origin,
            nftId,
            loanId,
            loan.borrowTokenAddress,
            loan.collateralTokenAddress,
            loan.borrowAmount,
            loan.collateralAmount,
            loanInterest.owedPerDay,
            loanInterest.minInterest,
            uint8(numberArray[0]),
            loanInterest.rolloverTimestamp,
            loan.initialBorrowTokenPrice,
            loan.initialCollateralTokenPrice
        );

        return loan;
    }

    function _repay(
        uint256 loanId,
        uint256 nftId,
        uint256 repayAmount,
        bool isOnlyInterest
    ) internal returns (uint256 borrowPaid, uint256 interestPaid) {
        Loan storage loan = loans[nftId][loanId];
        LoanInterest storage loanInterest = loanInterests[nftId][loanId];
        require(loan.active == true, "CoreBorrowing/loan-is-closed");

        _settleBorrowInterest(loanInterest);

        uint256 collateralAmountWithdraw = 0;

        if (isOnlyInterest || repayAmount <= loanInterest.interestOwed) {
            interestPaid = Math.min(repayAmount, loanInterest.interestOwed);
            loanInterest.interestOwed -= interestPaid;
            loanInterest.interestPaid += interestPaid;
            // pay int to pool

            if (loanInterest.minInterest > interestPaid) {
                loanInterest.minInterest -= interestPaid;
            } else {
                loanInterest.minInterest = 0;
            }
        } else {
            uint256 maxInterest = Math.max(loanInterest.minInterest, loanInterest.interestOwed);
            if (repayAmount >= (loan.borrowAmount + maxInterest)) {
                collateralAmountWithdraw = loan.collateralAmount;

                borrowPaid = loan.borrowAmount;
                interestPaid = maxInterest;
                loanInterest.minInterest = 0;
                loanInterest.interestOwed = 0;
                loan.borrowAmount = 0;
                loan.collateralAmount = 0;
                loan.active = false;
                loanInterest.interestPaid += maxInterest;
            } else {
                interestPaid = loanInterest.interestPaid;
                loanInterest.interestPaid += interestPaid;
                borrowPaid = repayAmount - interestPaid;
                loan.borrowAmount = borrowPaid;
                loanInterest.interestPaid -= interestPaid;

                if (loanInterest.minInterest > interestPaid) {
                    loanInterest.minInterest -= interestPaid;
                } else {
                    loanInterest.minInterest = 0;
                }
            }
        }
        IInterestVault(IAPHPool(assetToPool[loan.borrowTokenAddress]).interestVaultAddress())
            .settleInterest(interestPaid, interestPaid * feeSpread, 0);

        emit Repay(
            tx.origin,
            nftId,
            loanId,
            collateralAmountWithdraw > 0,
            borrowPaid,
            interestPaid,
            collateralAmountWithdraw
        );
    }

    function _adjustCollateral(
        uint256 loanId,
        uint256 nftId,
        uint256 collateralAdjustAmount,
        bool isAdd
    ) internal returns (Loan memory) {
        Loan storage loan = loans[nftId][loanId];
        require(loan.active == true, "CoreBorrowing/loan-is-closed");

        LoanInterest storage loanInterest = loanInterests[nftId][loanId];

        _settleBorrowInterest(loanInterest);

        LoanConfig storage loanConfig = loanConfigs[loan.borrowTokenAddress][
            loan.collateralTokenAddress
        ];

        if (isAdd) {
            loan.collateralAmount += collateralAdjustAmount;
        } else {
            loan.collateralAmount -= collateralAdjustAmount;
        }
        uint256 rate;
        uint256 precision;
        if (isHardhatEnv) {
            (rate, precision) = IPriceFeed(oracleAddress).queryRate(
                loan.collateralTokenAddress,
                loan.borrowTokenAddress
            );
        } else {
            (rate, precision) = IPriceFeed(oracleAddress).queryRate(
                loan.collateralTokenAddress,
                loan.borrowTokenAddress
            );
        }

        require(
            _isLoanLTVExceedMaxLTV(
                loan.borrowAmount,
                loan.collateralAmount,
                loanInterest.interestOwed,
                loanConfig.maxLTV,
                rate / precision
            ) == false,
            "CoreBorrowing/loan-LTV-is-exceed-maxLTV"
        );

        emit AdjustCollateral(tx.origin, nftId, loanId, isAdd, collateralAdjustAmount);

        return loan;
    }

    function _rollover(
        uint256 loanId,
        uint256 nftId,
        address caller
    ) internal returns (uint256 delayInterest, uint256 bountyReward) {
        Loan storage loan = loans[nftId][loanId];
        require(loan.active == true, "CoreBorrowing/loan-is-closed");

        LoanInterest storage loanInterest = loanInterests[nftId][loanId];

        _settleBorrowInterest(loanInterest);

        LoanConfig storage loanConfig = loanConfigs[loan.borrowTokenAddress][
            loan.collateralTokenAddress
        ];

        if (block.timestamp > loanInterest.rolloverTimestamp) {
            delayInterest =
                ((block.timestamp - loanInterest.rolloverTimestamp) * loanInterest.owedPerDay) /
                1 days;
            bountyReward = (delayInterest * loanConfig.bountyFeeRate) / WEI_PERCENT_UNIT;

            loanInterest.interestPaid += delayInterest + bountyReward;
            loanInterest.bountyFee += bountyReward;
        }
        address poolAddress = assetToPool[loan.borrowTokenAddress];

        (, uint256 interestOwedPerDay) = IAPHPool(poolAddress).calculate_interest(
            loan.borrowAmount
        );

        loanInterest.rolloverTimestamp = uint64(block.timestamp + loanDuration);
        loanInterest.owedPerDay = interestOwedPerDay;
        loanInterest.lastSettleTimestamp = uint64(block.timestamp);

        emit Rollover(
            tx.origin,
            nftId,
            loanId,
            caller,
            delayInterest,
            bountyReward,
            interestOwedPerDay
        );
    }

    function _liquidate(uint256 loanId, uint256 nftId)
        internal
        returns (
            uint256 repayBorrow,
            uint256 repayInterest,
            uint256 bountyReward,
            uint256 backToUser
        )
    {
        Loan storage loan = loans[nftId][loanId];
        require(loan.active == true, "CoreBorrowing/loan-is-closed");

        LoanInterest storage loanInterest = loanInterests[nftId][loanId];

        _settleBorrowInterest(loanInterest);

        LoanConfig storage loanConfig = loanConfigs[loan.borrowTokenAddress][
            loan.collateralTokenAddress
        ];

        uint256[] memory numberArray = new uint256[](3);

        if (isHardhatEnv) {
            (numberArray[0], numberArray[1]) = IPriceFeed(oracleAddress).queryRate(
                loan.collateralTokenAddress,
                loan.borrowTokenAddress
            );
        } else {
            //rate and precision
            (numberArray[0], numberArray[1]) = IPriceFeed(oracleAddress).queryRate(
                loan.collateralTokenAddress,
                loan.borrowTokenAddress
            );
        }

        if (
            _isLoanLTVLiquidatable(
                loan.borrowAmount,
                loan.collateralAmount,
                loanInterest.interestOwed,
                loanConfig.liquidationLTV,
                numberArray[0] / numberArray[1]
            )
        ) {
            address[] memory path_data = new address[](2);
            path_data[0] = loan.collateralTokenAddress;
            path_data[1] = loan.borrowTokenAddress;

            //newCollateralAmount
            if (isHardhatEnv) {
                numberArray[2] =
                    MockPriceFeed(mockFeedAddr).queryReturn(
                        loan.borrowTokenAddress,
                        loan.collateralTokenAddress,
                        loan.borrowAmount
                    ) *
                    ((WEI_PERCENT_UNIT - maxDisagreement) / WEI_PERCENT_UNIT);
            } else {
                numberArray[2] =
                    IPriceFeed(oracleAddress).queryReturn(
                        loan.borrowTokenAddress,
                        loan.collateralTokenAddress,
                        loan.borrowAmount
                    ) *
                    ((WEI_PERCENT_UNIT - maxDisagreement) / WEI_PERCENT_UNIT);
            }
            uint256[] memory amounts = IRouter(routerAddress).swapExactTokensForTokens(
                numberArray[2],
                loan.borrowAmount,
                path_data,
                address(this),
                1 hours
            );
            uint256 borrowTokenAmountSwap = amounts[amounts.length - 1];

            (repayBorrow, repayInterest) = _repay(loanId, nftId, borrowTokenAmountSwap, false);

            borrowTokenAmountSwap -= (repayBorrow + repayInterest);
            bountyReward = (borrowTokenAmountSwap * loanConfig.bountyFeeRate) / WEI_PERCENT_UNIT;
            borrowTokenAmountSwap -= bountyReward;

            if (borrowTokenAmountSwap != 0) {
                backToUser = borrowTokenAmountSwap;
            }

            emit Liquidate(
                tx.origin,
                nftId,
                loanId,
                msg.sender,
                numberArray[0],
                borrowTokenAmountSwap,
                bountyReward,
                backToUser
            );
        } else {
            (, bountyReward) = _rollover(loanId, nftId, msg.sender);
        }
    }

    function _settleBorrowInterest(LoanInterest storage loanInterest) internal virtual {
        uint256 ts = uint256(block.timestamp);
        if (loanInterest.lastSettleTimestamp < ts) {
            uint64 settleTimestamp = uint64(Math.min(ts, loanInterest.rolloverTimestamp));
            uint256 interestOwed = ((settleTimestamp - loanInterest.lastSettleTimestamp) *
                loanInterest.owedPerDay) / 1 days;
            loanInterest.interestPaid += interestOwed;
            loanInterest.lastSettleTimestamp = settleTimestamp;
        }
    }

    function _isLoanLTVExceedMaxLTV(
        uint256 borrowAmount,
        uint256 collateralAmount,
        uint256 interestOwed,
        uint256 maxLTV,
        uint256 rate
    ) internal virtual returns (bool) {
        uint256 loanLTV = (borrowAmount + interestOwed) / (collateralAmount * rate);
        return maxLTV > loanLTV ? true : false;
    }

    function _isLoanLTVLiquidatable(
        uint256 borrowAmount,
        uint256 collateralAmount,
        uint256 interestOwed,
        uint256 liqLTV,
        uint256 rate
    ) internal virtual returns (bool) {
        uint256 loanLTV = (borrowAmount + interestOwed) / (collateralAmount * rate);
        return loanLTV > liqLTV ? true : false;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../../interfaces/IAPHPool.sol";

import "./CoreBase.sol";
import "./event/CoreSettingEvent.sol";

contract CoreSetting is CoreBase, CoreSettingEvent {
    function setMembershipAddress(address newAddress) external onlyManager {
        address oldAddress = membershipAddress;
        membershipAddress = newAddress;

        emit SetMembershipAddress(msg.sender, oldAddress, newAddress);
    }

    function setOracleAddress(address newAddress) external onlyManager {
        address oldAddress = membershipAddress;
        oracleAddress = newAddress;

        emit SetOracleAddress(msg.sender, oldAddress, newAddress);
    }

    function setRouterAddress(address newAddress) external onlyManager {
        address oldAddress = membershipAddress;
        routerAddress = newAddress;

        emit SetRouterAddress(msg.sender, oldAddress, newAddress);
    }

    function setFeeController(address newAddress) external onlyManager {
        address oldAddress = feesController;
        feesController = newAddress;

        emit SetFeeController(msg.sender, oldAddress, newAddress);
    }

    function setLoanDuration(uint256 newValue) external onlyManager {
        uint256 oldValue = loanDuration;
        loanDuration = newValue;

        emit SetLoanDuration(msg.sender, oldValue, newValue);
    }

    function setAdvancedInterestDuration(uint256 newValue) external onlyManager {
        uint256 oldValue = advancedInterestDuration;
        advancedInterestDuration = newValue;

        emit SetAdvancedInterestDuration(msg.sender, oldValue, newValue);
    }

    function setFeeSpread(uint256 newValue) external onlyManager {
        require(newValue <= WEI_PERCENT_UNIT, "CoreSetting/value-exceed-100-percent");
        uint256 oldValue = feeSpread;
        feeSpread = newValue;

        emit SetFeeSpread(msg.sender, oldValue, newValue);
    }

    function registerNewPool(address poolAddress) external onlyManager {
        require(poolToAsset[poolAddress] == address(0), "CoreSetting/pool-is-already-exist");
        address assetAddress = IAPHPool(poolAddress).tokenAddress();

        poolToAsset[poolAddress] = assetAddress;
        assetToPool[assetAddress] = poolAddress;
        swapableToken[assetAddress] = true;
        poolList.push(poolAddress);

        emit RegisterNewPool(msg.sender, poolAddress);
    }

    function setForwPerBlock(address poolAddress, uint256 amount) external onlyManager {
        require(poolToAsset[poolAddress] == address(0), "CoreSetting/pool-is-already-exist");
        forwPerBlock[poolAddress] = amount;

        emit SetFowPerBlock(msg.sender, amount);
    }

    function setupLoanConfig(
        address borrowTokenAddress,
        address collateralTokenAddress,
        uint256 newSafeLTV,
        uint256 newMaxLTV,
        uint256 newLiquidationLTV,
        uint256 newBountyFeeRate
    ) external {
        require(
            poolToAsset[msg.sender] != address(0) || msg.sender == manager,
            "CoreSetting/permission-denied-for-setup-loan-config"
        );
        require(
            borrowTokenAddress != collateralTokenAddress,
            "CoreSetting/borrow-token-and-collateral-token-is-same"
        );
        require(
            assetToPool[borrowTokenAddress] != address(0),
            "CoreSetting/borrowTokenAddress-is-not-registered-yet"
        );
        require(
            assetToPool[collateralTokenAddress] != address(0),
            "CoreSetting/collateralTokenAddress-is-not-registered-yet"
        );

        LoanConfig memory configOld = loanConfigs[borrowTokenAddress][collateralTokenAddress];
        LoanConfig storage config = loanConfigs[borrowTokenAddress][collateralTokenAddress];
        config.borrowTokenAddress = borrowTokenAddress;
        config.collateralTokenAddress = collateralTokenAddress;
        config.safeLTV = newSafeLTV;
        config.maxLTV = newMaxLTV;
        config.liquidationLTV = newLiquidationLTV;
        config.bountyFeeRate = newBountyFeeRate;

        emit SetupLoanConfig(
            msg.sender,
            borrowTokenAddress,
            collateralTokenAddress,
            configOld.safeLTV,
            configOld.maxLTV,
            configOld.liquidationLTV,
            configOld.bountyFeeRate,
            config.safeLTV,
            config.maxLTV,
            config.liquidationLTV,
            config.bountyFeeRate
        );
    }

    function mockSetBUSDAddress() external onlyManager {
        BUSDAddress = 0x665aE6c8B332cCE9B1B50d9B2c79d1731516d2fB;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../src/pool/PoolBase.sol";
import "../src/core/CoreBase.sol";

interface IAPHPool {
    // /**
    //  * @dev Set NFT contract address
    //  * @param _address The address of NFT contract
    //  */
    // function setMembershipAddress(address _address) external;

    // /**
    //  * @dev Set interest vault contract address
    //  * @param _address The address of interest vault
    //  */
    // function setInterestVaultAddress(address _address) external;

    // /**
    //  * @dev Set Forward token address
    //  * @param _address The address of Forward token
    //  */
    // function setForwAddress(address _address) external;

    // /**
    //  * @dev Set asset goken address
    //  * @param _address The address of asset token
    //  */
    // function setTokenAddress(address _address) external;

    /**
     * @dev Deposit the asset token to the pool
     * @param nftId The nft tokenId that is holding the user's lending position
     * @param depositAmount The amount of token that are being transfered
     * @return mintedP The 'amount' of pToken (principal) minted
     * @return mintedItp The 'amount' of itpToken (asset token interest) minted
     * @return mintedIfp The 'amount' of ifpToken (Forward token interest) minted
     */
    function deposit(uint256 nftId, uint256 depositAmount)
        external
        payable
        returns (
            uint256 mintedP,
            uint256 mintedItp,
            uint256 mintedIfp
        );

    /**
     * @dev Withdraw the 'amount' of the principal (and claim all interest if user withdraw all of the principal)
     * @param nftId The nft tokenId that is holding the user's lending position
     * @param withdrawAmount The 'amount' of token that are being withdraw
     * @return The 'amount' of all tokens is withdraw and burnt
     */
    function withdraw(uint256 nftId, uint256 withdrawAmount)
        external
        returns (PoolBase.WithdrawResult memory);

    /**
     * @dev Claim the entire remaining of both asset token and Forward interest
     * @param nftId The nft tokenId that is holding the user's lending position
     * @return The 'amount' of all tokens is claimed and burnt
     */
    function claimAllInterest(uint256 nftId) external returns (PoolBase.WithdrawResult memory);

    /**
     * @dev Claim the 'amount' of Forward token interest
     * @param nftId The nft TokenId that is holding the user's lending position
     * @param claimAmount The 'amount' of asset token interest that are being claimed
     * @return The 'amount' of asset token interest is claimed and burnt
     */
    function claimTokenInterest(uint256 nftId, uint256 claimAmount)
        external
        returns (PoolBase.WithdrawResult memory);

    /**
     * @dev Claim the 'amount' of asset token interest
     * @param nftId The nft tokenId that is holding the user's lending position
     * @param claimAmount The 'amount' of Forward token interest that are being claimed
     * @return The 'amount' of Forward token interest is claimed and burnt
     */
    function claimForwInterest(uint256 nftId, uint256 claimAmount)
        external
        returns (PoolBase.WithdrawResult memory);

    function borrow(
        uint256 loanId,
        uint256 nftId,
        uint256 borrowAmount,
        uint256 collateralSentAmount,
        address collateralTokenAddress
    ) external payable returns (CoreBase.Loan memory);

    /**
     * @dev Set the rank in APHPool to equal the user's NFT rank
     * @param nftId The user's nft tokenId is used to activate the new rank
     * @return The new rank from user's nft
     */
    function activateRank(uint256 nftId) external returns (uint8);

    function getLendingInterest() external view returns (uint256);

    function getNextLendingInterest(uint256 depositAmount) external view returns (uint256);

    function getBorrowingInterest() external view returns (uint256);

    function getNextBorrowingInterest(uint256 borrowAmount) external view returns (uint256);

    /**
     * @dev Get interestRate and interestOwedPerDay from new borrow amount
     * @param borrowAmount The 'amount' of token borrow
     * @return The interestRate and interestOwedPerDay
     */
    function calculate_interest(uint256 borrowAmount) external view returns (uint256, uint256);

    /**
     * @dev Get asset interest token (itpToken) price
     * @return interest token price (pToken per itpToken)
     */
    function getInterestTokenPrice() external view returns (uint256);

    /**
     * @dev Get Forward interest token (ifpToken) price
     * @return Forward interest token price (pToken per ifpToken)
     */
    function getInterestForwPrice() external view returns (uint256);

    /**
     * @dev Get total supply of the asset token in the pool
     * @return The 'amount' of asset token in the pool
     */
    function totalSupply() external returns (uint256);

    function membershipAddress() external returns (address);

    function interestVaultAddress() external returns (address);

    function forwAddress() external returns (address);

    function tokenAddress() external returns (address);

    function stakePoolAddress() external returns (address);

    function coreAddress() external returns (address);

    function baseRate() external returns (uint256);

    function w1() external returns (uint256);

    function w2() external returns (uint256);

    function w3() external returns (uint256);

    function utilOptimise1() external returns (uint256);

    function utilOptimise2() external returns (uint256);

    function utilOptimise3() external returns (uint256);

    function targetSupply() external returns (uint256);

    // from PoolToken
    function balancePTokenOf(uint256 NFTId) external view returns (uint256);

    function balanceItpTokenOf(uint256 NFTId) external view returns (uint256);

    function balanceIfpTokenOf(uint256 NFTId) external view returns (uint256);

    function pTokenTotalSupply() external view returns (uint256);

    function itpTokenTotalSupply() external view returns (uint256);

    function ifpTokenTotalSupply() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "./Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(
            _initializing ? _isConstructor() : !_initialized,
            "Initializable: contract is already initialized"
        );

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../openzeppelin/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract SelectorPausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account` and `function selector`.
     */
    event Paused(address account, bytes4 functionSelector);

    /**
     * @dev Emitted when the pause is lifted by `account` and `function selector`.
     */
    event Unpaused(address account, bytes4 functionSelector);

    mapping(bytes4 => bool) private _isPaused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        //_isPaused = false;
    }

    /**
     * @dev Returns true if the function selected is paused, and false otherwise.
     */
    function isPaused(bytes4 _func) public view virtual returns (bool) {
        return _isPaused[_func];
    }

    /**
     * @dev Modifier to make a function callable only when the function selected is not paused.
     *
     * Requirements:
     *
     * - The function selected must not be paused.
     */
    modifier whenFuncNotPaused(bytes4 _func) {
        require(!_isPaused[_func], "Pausable/function-is-paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the function selected is paused.
     *
     * Requirements:
     *
     * - The function selected must be paused.
     */
    modifier whenFuncPaused(bytes4 _func) {
        require(_isPaused[_func], "Pausable/function-is-not-paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The function selected must not be paused.
     */
    function _pause(bytes4 _func) internal virtual whenFuncNotPaused(_func) {
        _isPaused[_func] = true;
        emit Paused(_msgSender(), _func);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The function selected must be paused.
     */
    function _unpause(bytes4 _func) internal virtual whenFuncPaused(_func) {
        _isPaused[_func] = false;
        emit Unpaused(_msgSender(), _func);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

interface IInterestVault {
    function claimableInterest() external view returns (uint256);

    function heldInterest() external view returns (uint256);

    function actualInterestProfit() external view returns (uint256);

    function claimableForwInterest() external view returns (uint256);

    function cumulativeInterestProfit() external view returns (uint256);

    function tokenAddress() external view returns (address);

    function forwAddress() external view returns (address);

    function protocolAddress() external view returns (address);

    function getTotalInterest() external view returns (uint256);

    function getTotalForw() external view returns (uint256);

    function settleInterest(
        uint256 _claimableInterest,
        uint256 _heldInterest,
        uint256 _claimableForwInterest
    ) external;

    function withdrawInterest(
        address receiver,
        uint256 claimable,
        uint256 bonus,
        uint256 profit
    ) external;

    function withdrawForwInterest(address receiver, uint256 claimable) external;

    // function setForwAddress(address _address) external;

    // function setTokenAddress(address _address) external;

    // function setProtocolAddress(address _address) external;

    function withdrawActualProfit(address receiver) external returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../../interfaces/IWethERC20.sol";
import "../../externalContract/openzeppelin/IERC20.sol";

import "./WETHHandler.sol";

contract AssetHandler {
    address public constant wethAddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    //address public constant wethToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c  // bsc (Wrapped BNB)

    address public constant wethHandler = 0x64493B5B3419e116F9fbE3ec41cF2E65Ef15cAB6;

    function _transferFromIn(
        address from,
        address to,
        address token,
        uint256 amount
    ) internal {
        require(amount != 0, "AssetHandler/amount-is-zero");

        if (token == wethAddress) {
            require(amount == msg.value, "AssetHandler/value-not-matched");
            IWethERC20(wethAddress).deposit{value: amount}();
        } else {
            IERC20(token).transferFrom(from, to, amount);
        }
    }

    function _transferFromOut(
        address from,
        address to,
        address token,
        uint256 amount
    ) internal {
        if (amount == 0) {
            return;
        }
        if (token == wethAddress) {
            IWethERC20(wethAddress).transfer(wethHandler, amount);
            WETHHandler(payable(wethHandler)).withdrawETH(to, amount);
            // (bool success, ) = to.call{value: amount}(new bytes(0));
            // require(success, "AssetHandler/withdraw-failed-1");
        } else {
            IERC20(token).transferFrom(from, to, amount);
        }
    }

    function _transferOut(
        address to,
        address token,
        uint256 amount
    ) internal {
        if (amount == 0) {
            return;
        }
        if (token == wethAddress) {
            IWethERC20(wethAddress).transfer(wethHandler, amount);
            WETHHandler(payable(wethHandler)).withdrawETH(to, amount);
            // (bool success, ) = to.call{value: amount}(new bytes(0));
            // require(success, "AssetHandler/withdraw-failed-2");
        } else {
            IERC20(token).transfer(to, amount);
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
import "../../externalContract/openzeppelin/Context.sol";

pragma solidity 0.8.7;

contract Manager {
    address public manager;
    event TransferManager(address, address);

    constructor() {}

    modifier onlyManager() {
        require(manager == msg.sender, "Manager/caller-is-not-the-manager");
        _;
    }

    function transferManager(address newManager) public virtual onlyManager {
        require(newManager != address(0), "Manager/new-manager-is-the-zero-address");
        _transferManager(newManager);
    }

    function _transferManager(address newManager) internal virtual {
        address oldManager = manager;
        manager = newManager;
        emit TransferManager(oldManager, newManager);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../../externalContract/openzeppelin/Address.sol";
import "../../externalContract/openzeppelin/ReentrancyGuard.sol";
import "../../externalContract/openzeppelin/Initializable.sol";
import "../../externalContract/modify/SelectorPausable.sol";

import "../utils/AssetHandler.sol";
import "../utils/Manager.sol";

contract PoolBase is AssetHandler, Manager, ReentrancyGuard, Initializable, SelectorPausable {
    struct Lend {
        uint8 rank;
        uint64 updatedTimestamp;
    }

    struct WithdrawResult {
        uint256 principle;
        uint256 interest;
        uint256 forw;
        uint256 pTokenBurn;
        uint256 itpTokenBurn;
        uint256 ifpTokenBurn;
        uint256 interestBonus;
        uint256 forwBonus;
    }

    uint256 internal WEI_UNIT; // 1e18
    uint256 internal WEI_PERCENT_UNIT; // 1e20 (100*1e18 for calculating percent)

    address public forwAddress;
    address public membershipAddress;
    address public interestVaultAddress;
    address public tokenAddress;
    address public coreAddress;
    mapping(uint256 => Lend) lenders;

    uint256 internal initialItpPrice;
    uint256 internal initialIfpPrice;

    uint256 public baseRate;

    uint256 public w1;
    uint256 public w2;
    uint256 public w3;

    uint256 public utilOptimise1;
    uint256 public utilOptimise2;
    uint256 public utilOptimise3;

    uint256 public targetSupply;

    function pause(bytes4 _func) external onlyManager {
        require(_func != bytes4(0), "");
        _pause(_func);
    }

    function unPause(bytes4 _func) external onlyManager {
        require(_func != bytes4(0), "");
        _unpause(_func);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "./IWeth.sol";
import "../externalContract/openzeppelin/IERC20.sol";

interface IWethERC20 is IWeth, IERC20 {}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../../interfaces/IWeth.sol";

contract WETHHandler {
    address public constant wethAddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    //address public constant wethToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c  // bsc (Wrapped BNB)

    function withdrawETH(address to, uint256 amount) external {
        IWeth(wethAddress).withdraw(amount);
        (bool success, ) = to.call{value: amount}(new bytes(0));
        require(success, "AssetHandler/withdraw-failed-1");
    }

    fallback() external {
        revert("fallback function not allowed");
    }

    receive() external payable {}
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

interface IWeth {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

interface IRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../externalContract/openzeppelin/IERC721Enumerable.sol";

interface IMembership is IERC721Enumerable {
    // External functions

    function getDefaultMembership(address owner) external view returns (uint256);

    function setDefaultMembership(uint256 tokenId) external;

    // function setNewPool(address newPool) external;

    function getPoolLists() external view returns (address[] memory);

    function mint(address to) external returns (uint256);

    // function setBaseURI(string memory baseTokenURI) external;

    function updateRank(uint256 tokenId, uint8 newRank) external;

    function usableTokenId(uint256 tokenId) external view returns (uint256);

    function getRank(uint256 tokenId) external view returns (uint8);

    function getRank(address pool, uint256 tokenId) external view returns (uint8);

    function currentPool() external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0
/**
 * Copyright 2017-2021, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.8.7;

interface IPriceFeed {
    function queryRate(address sourceToken, address destToken)
        external
        view
        returns (uint256 rate, uint256 precision);

    function queryPrecision(address sourceToken, address destToken)
        external
        view
        returns (uint256 precision);

    function queryReturn(
        address sourceToken,
        address destToken,
        uint256 sourceAmount
    ) external view returns (uint256 destAmount);

    function checkPriceDisagreement(
        address sourceToken,
        address destToken,
        uint256 sourceAmount,
        uint256 destAmount,
        uint256 maxSlippage
    ) external view returns (uint256 sourceToDestSwapRate);

    function amountInEth(address Token, uint256 amount) external view returns (uint256 ethAmount);

    function getFastGasPrice(address payToken) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

contract CoreBorrowingEvent {
    event Borrow(
        address indexed owner,
        uint256 indexed nftId,
        uint256 indexed loanId,
        address borrowTokenAddress,
        address collateralTokenAddress,
        uint256 borrowAmount,
        uint256 collateralAmount,
        uint256 owedPerDay,
        uint256 minInterest,
        // uint256 interestOwed,
        // uint256 interestPaid,
        // uint256 bountyFee,
        uint8 newLoan,
        uint64 rolloverTimestamp,
        uint256 initialBorrowTokenPrice,
        uint256 initialCollateralTokenPrice
    );

    event CloseLoan(
        address indexed owner,
        uint256 indexed nftId,
        uint256 indexed loanId,
        uint256 borrowPaid,
        uint256 interestPaid,
        uint256 collateralAmountwithdraw
    );
    event Repay(
        address indexed owner,
        uint256 indexed nftId,
        uint256 indexed loanId,
        bool closeLoan,
        uint256 borrowPaid,
        uint256 interestPaid,
        uint256 collateralAmountwithdraw
    );
    event AdjustCollateral(
        address indexed owner,
        uint256 indexed nftId,
        uint256 indexed loanId,
        bool isAdd,
        uint256 collateralAdjustAmount
    );
    event Rollover(
        address indexed owner,
        uint256 indexed nftId,
        uint256 indexed loanId,
        address bountyHunter,
        uint256 delayInterest,
        uint256 bountyReward,
        uint256 newInterestOwedPerDay
    );

    event Liquidate(
        address indexed owner,
        uint256 indexed nftId,
        uint256 indexed loanId,
        address liquidator,
        uint256 swapPrice,
        uint256 tokenAmountFromSwap,
        uint256 bountyReward,
        uint256 tokenSentBackToUser
    );
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../../externalContract/openzeppelin/Ownable.sol";

contract MockPriceFeed is Ownable {
    mapping(address => mapping(address => uint256)) public tokenPrice;
    mapping(address => uint256) public tokenPrecision;

    function setPrice(
        address src,
        address dest,
        uint256 price
    ) public onlyOwner {
        tokenPrice[src][dest] = price;
        tokenPrice[dest][src] = (1e18 * 1e18) / price;
    }

    function setPrecision(address token, uint256 precision) public onlyOwner {
        tokenPrecision[token] = precision;
    }

    function getPrice(address src, address dest) public view returns (uint256) {
        return tokenPrice[src][dest];
    }

    function getPrecision(address src, address dest) public view returns (uint256) {
        if (tokenPrecision[dest] >= tokenPrecision[src]) {
            return 10**(18 - (tokenPrecision[dest] - tokenPrecision[src]));
        } else {
            return 10**(18 - (tokenPrecision[src] - tokenPrecision[dest]));
        }
    }

    function queryRate(address src, address dest) public view returns (uint256, uint256) {
        return (getPrice(src, dest), getPrecision(src, dest));
    }

    function queryReturn(
        address sourceToken,
        address destToken,
        uint256 sourceAmount
    ) public view returns (uint256 destAmount) {
        (uint256 rate, uint256 precision) = queryRate(sourceToken, destToken);

        destAmount = (sourceAmount * rate) / precision;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

contract CoreSettingEvent {
    event SetMembershipAddress(address indexed sender, address oldValue, address newValue);
    event SetOracleAddress(address indexed sender, address oldValue, address newValue);
    event SetRouterAddress(address indexed sender, address oldValue, address newValue);
    event SetFeeController(address indexed sender, address oldValue, address newValue);

    event SetLoanDuration(address indexed sender, uint256 oldValue, uint256 newValue);
    event SetAdvancedInterestDuration(address indexed sender, uint256 oldValue, uint256 newValue);
    event SetFeeSpread(address indexed sender, uint256 oldValue, uint256 newValue);

    event RegisterNewPool(address indexed sender, address poolAddress);
    event SetupLoanConfig(
        address indexed sender,
        address indexed borrowTokenAddress,
        address indexed collateralTokenAddress,
        uint256 oldSafeLTV,
        uint256 oldMaxLTV,
        uint256 oldLiquidationLTV,
        uint256 oldBountyFeeRate,
        uint256 newSafeLTV,
        uint256 newLMaxLTV,
        uint256 newLiquidationLTV,
        uint256 newBountyFeeRate
    );
    event SetFowPerBlock(address indexed sender, uint256 amount);
}