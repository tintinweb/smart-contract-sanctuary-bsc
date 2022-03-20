// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../../externalContract/openzeppelin/IERC20.sol";
import "../../externalContract/openzeppelin/Math.sol";

import "../../interfaces/IAPHCore.sol";
import "../../interfaces/IStakePool.sol";
import "../../interfaces/IInterestVault.sol";
import "../../interfaces/IMembership.sol";
import "./PoolBase.sol";
import "./PoolToken.sol";
import "./PoolEvent.sol";
import "./PoolSetting.sol";
import "./InterestVault.sol";

contract APHPool is PoolBase, PoolSetting, PoolEvent, PoolToken {
    modifier checkRank(uint256 nftId) {
        require(lenders[nftId].rank == _getNFTRank(nftId), "APHPool/nft-rank-not-match");
        _;
    }

    modifier settleForwInterest() {
        IAPHCore(coreAddress).settleForwInterest();
        _;
    }

    function initialize(
        address _tokenAddress,
        address _coreAddress,
        address _membership
    ) external initializer {
        require(_tokenAddress != address(0), "initialize/tokenAddress-zero-address");
        require(_coreAddress != address(0), "initialize/coreAddress-zero-address");
        require(_membership != address(0), "initialize/membership-zero-address");
        tokenAddress = _tokenAddress;
        coreAddress = _coreAddress;
        membershipAddress = _membership;
        manager = msg.sender;

        forwAddress = 0xAf0244ddcD9EaDA973b28b86BF2F18BCeea1D78f;
        interestVaultAddress = address(new InterestVault(_tokenAddress, forwAddress, _coreAddress));

        WEI_UNIT = 10**18;
        WEI_PERCENT_UNIT = 10**20;
        initialItpPrice = WEI_UNIT;
        initialIfpPrice = WEI_UNIT;

        // emit SetGovernor(_governor);
        // emit SetOracle(_oracle);
        // emit SetConfig(_config);
        // emit SetInterestModel(_interestModel);
        emit Initialize(manager, coreAddress, interestVaultAddress, membershipAddress);
        emit TransferManager(address(0), manager);
    }

    // external function

    function activateRank(uint256 nftId)
        external
        nonReentrant
        whenFuncNotPaused(msg.sig)
        returns (uint8 newRank)
    {
        nftId = IMembership(membershipAddress).usableTokenId(nftId);
        newRank = _activateRank(tx.origin, nftId);
    }

    function deposit(uint256 nftId, uint256 depositAmount)
        external
        payable
        checkRank(nftId)
        nonReentrant
        whenFuncNotPaused(msg.sig)
        settleForwInterest
        returns (
            uint256 mintedP,
            uint256 mintedItp,
            uint256 mintedIfp
        )
    {
        nftId = IMembership(membershipAddress).usableTokenId(nftId);
        _transferFromIn(tx.origin, address(this), tokenAddress, depositAmount);
        (mintedP, mintedItp, mintedIfp) = _deposit(tx.origin, nftId, depositAmount);
    }

    function withdraw(uint256 nftId, uint256 withdrawAmount)
        external
        nonReentrant
        whenFuncNotPaused(msg.sig)
        settleForwInterest
        returns (WithdrawResult memory)
    {
        nftId = IMembership(membershipAddress).usableTokenId(nftId);
        WithdrawResult memory result = _withdraw(tx.origin, nftId, withdrawAmount);
        _transferOut(msg.sender, tokenAddress, result.principle);
        _transferFromOut(
            interestVaultAddress,
            msg.sender,
            tokenAddress,
            result.interest + result.interestBonus
        );
        _transferFromOut(interestVaultAddress, msg.sender, forwAddress, result.forw);
        //TODO: where forw bonus
        _transferFromOut(interestVaultAddress, msg.sender, forwAddress, result.forwBonus);
        return result;
    }

    function claimAllInterest(uint256 nftId)
        external
        checkRank(nftId)
        nonReentrant
        whenFuncNotPaused(msg.sig)
        settleForwInterest
        returns (WithdrawResult memory)
    {
        nftId = IMembership(membershipAddress).usableTokenId(nftId);
        return _claimAllInterest(tx.origin, nftId);
    }

    function claimTokenInterest(uint256 nftId, uint256 claimAmount)
        external
        checkRank(nftId)
        nonReentrant
        whenFuncNotPaused(msg.sig)
        settleForwInterest
        returns (WithdrawResult memory)
    {
        nftId = IMembership(membershipAddress).usableTokenId(nftId);
        WithdrawResult memory result = _claimTokenInterest(tx.origin, nftId, claimAmount);
        _transferFromOut(
            interestVaultAddress,
            msg.sender,
            tokenAddress,
            result.interest + result.interestBonus
        );
        return result;
    }

    function claimForwInterest(uint256 nftId, uint256 claimAmount)
        external
        checkRank(nftId)
        nonReentrant
        whenFuncNotPaused(msg.sig)
        settleForwInterest
        returns (WithdrawResult memory)
    {
        nftId = IMembership(membershipAddress).usableTokenId(nftId);
        WithdrawResult memory result = _claimForwInterest(tx.origin, nftId, claimAmount);
        _transferOut(msg.sender, forwAddress, result.forw);
        _transferFromOut(interestVaultAddress, msg.sender, forwAddress, result.forwBonus);
        return result;
    }

    function borrow(
        uint256 loanId,
        uint256 nftId,
        uint256 borrowAmount,
        uint256 collateralSentAmount,
        address collateralTokenAddress
    ) external payable whenFuncNotPaused(msg.sig) returns (CoreBase.Loan memory) {
        nftId = IMembership(membershipAddress).usableTokenId(nftId);
        _transferFromIn(tx.origin, coreAddress, collateralTokenAddress, collateralSentAmount);
        CoreBase.Loan memory loan = _borrow(
            loanId,
            nftId,
            borrowAmount,
            collateralSentAmount,
            collateralTokenAddress
        );
        _transferOut(tx.origin, collateralTokenAddress, collateralSentAmount);
        return loan;
    }

    function getLendingInterest() external view returns (uint256) {
        return _getNextLendingInterest(0);
    }

    function getNextLendingInterest(uint256 depositAmount) external view returns (uint256) {
        return _getNextLendingInterest(depositAmount);
    }

    function getBorrowingInterest() external view returns (uint256) {
        return _getNextBorrowingInterest(0);
    }

    function getNextBorrowingInterest(uint256 borrowAmount) external view returns (uint256) {
        return _getNextBorrowingInterest(borrowAmount);
    }

    function calculate_interest(uint256 borrowAmount) external view returns (uint256, uint256) {
        return _calculateBorrowInterest(borrowAmount);
    }

    function getInterestTokenPrice() external view returns (uint256) {
        return _getInterestTokenPrice();
    }

    function getInterestForwPrice() external view returns (uint256) {
        return _getInterestForwPrice();
    }

    //TODO: this funtion is not represent totalSupply but remaining balance
    function totalSupply() external view returns (uint256) {
        return _totalSupply();
    }

    // internal function

    function _activateRank(address receiver, uint256 nftId) internal returns (uint8) {
        Lend storage lender = lenders[nftId];
        uint8 oldRank = lender.rank;
        uint8 newRank = _getNFTRank(nftId);

        require(lender.rank != newRank, "APHPool/invalid-rank");
        WithdrawResult memory interestResult = _claimTokenInterest(
            receiver,
            nftId,
            type(uint256).max
        );
        _deposit(receiver, nftId, interestResult.interest + interestResult.interestBonus);
        _claimForwInterest(receiver, nftId, type(uint256).max);

        lender.rank = newRank;

        emit ActivateRank(receiver, nftId, oldRank, newRank);
        return lender.rank;
    }

    function _deposit(
        address receiver,
        uint256 nftId,
        uint256 depositAmount
    )
        internal
        returns (
            uint256 pMintAmount,
            uint256 itpMintAmount,
            uint256 ifpMintAmount
        )
    {
        require(depositAmount > 0, "APHPool/deposit-amount-is-zero");

        // _transferFromIn(receiver, address(this), tokenAddress, depositAmount);
        Lend storage lend = lenders[nftId];

        //mint ip,itp,ifp
        pMintAmount = _mintPToken(receiver, nftId, depositAmount);

        uint256 itpPrice = _getInterestTokenPrice();
        uint256 ifpPrice = _getInterestForwPrice();

        itpMintAmount = _mintItpToken(
            receiver,
            nftId,
            ((depositAmount * WEI_UNIT) / itpPrice),
            itpPrice
        );
        ifpMintAmount = _mintIfpToken(
            receiver,
            nftId,
            ((depositAmount * WEI_UNIT) / ifpPrice),
            ifpPrice
        );

        lend.updatedTimestamp = uint64(block.timestamp);

        emit Deposit(receiver, nftId, depositAmount, pMintAmount, itpMintAmount, ifpMintAmount);
    }

    function _withdraw(
        address receiver,
        uint256 nftId,
        uint256 withdrawAmount
    ) internal returns (WithdrawResult memory) {
        PoolTokens storage tokenHolder = tokenHolders[nftId];
        WithdrawResult memory interestResult;
        if (withdrawAmount >= tokenHolder.pToken) {
            interestResult = _claimAllInterest(receiver, nftId);
            withdrawAmount = tokenHolder.pToken;
        }

        require(withdrawAmount <= _totalSupply(), "APHPool/pool-supply-insufficient");

        uint256 itpPrice = _getInterestTokenPrice();
        uint256 ifpPrice = _getInterestForwPrice();
        uint256 itpBurnAmount = _burnItpToken(
            receiver,
            nftId,
            (withdrawAmount * WEI_UNIT) / itpPrice,
            itpPrice
        );
        uint256 ifpBurnAmount = _burnIfpToken(
            receiver,
            nftId,
            (withdrawAmount * WEI_UNIT) / ifpPrice,
            ifpPrice
        );
        uint256 pBurnAmount = _burnPToken(receiver, nftId, withdrawAmount);

        emit Withdraw(receiver, nftId, withdrawAmount, pBurnAmount, itpBurnAmount, ifpBurnAmount);
        return
            WithdrawResult({
                principle: withdrawAmount,
                interest: interestResult.interest,
                forw: interestResult.forw,
                pTokenBurn: pBurnAmount,
                itpTokenBurn: itpBurnAmount + interestResult.itpTokenBurn,
                ifpTokenBurn: ifpBurnAmount + interestResult.ifpTokenBurn,
                interestBonus: interestResult.interestBonus,
                forwBonus: interestResult.forwBonus
            });
    }

    function _claimAllInterest(address receiver, uint256 nftId)
        internal
        returns (WithdrawResult memory)
    {
        WithdrawResult memory tokenWithdrawResult = _claimTokenInterest(
            receiver,
            nftId,
            type(uint256).max
        );

        WithdrawResult memory forwWithdrawResult = _claimForwInterest(
            receiver,
            nftId,
            type(uint256).max
        );

        return
            WithdrawResult({
                principle: 0,
                interest: tokenWithdrawResult.interest,
                forw: forwWithdrawResult.forw,
                pTokenBurn: 0,
                itpTokenBurn: tokenWithdrawResult.itpTokenBurn,
                ifpTokenBurn: forwWithdrawResult.ifpTokenBurn,
                interestBonus: tokenWithdrawResult.interestBonus,
                forwBonus: forwWithdrawResult.forwBonus
            });
    }

    function _claimTokenInterest(
        address receiver,
        uint256 nftId,
        uint256 claimAmount
    ) internal returns (WithdrawResult memory) {
        uint256 tokenInterestPrice = _getInterestTokenPrice();
        PoolTokens storage tokenHolder = tokenHolders[nftId];
        uint256 claimableAmount = ((tokenHolder.itpToken * tokenInterestPrice) / WEI_UNIT) -
            tokenHolder.pToken;

        claimAmount = Math.min(claimAmount, claimableAmount);

        uint256 burnAmount = _burnIfpToken(
            receiver,
            nftId,
            (claimAmount * WEI_UNIT) / tokenInterestPrice,
            tokenInterestPrice
        );

        uint256 bonusPercent = _getNFTRankInfo(nftId).interestBonusLending;
        uint256 bonusAmount = (claimAmount * bonusPercent) / WEI_PERCENT_UNIT;
        // IERC20(tokenAddress).transferFrom(
        //     interestVaultAddress,
        //     receiver,
        //     claimAmount + bonusAmount
        // );

        uint256 feeSpread = IAPHCore(coreAddress).feeSpread();
        uint256 profitAmount = (claimAmount *
            ((feeSpread / (WEI_PERCENT_UNIT - feeSpread)) - bonusAmount)) / WEI_UNIT;
        IInterestVault(interestVaultAddress).withdrawInterest(
            receiver,
            claimAmount,
            bonusAmount,
            profitAmount
        );

        emit ClaimTokenInterest(receiver, nftId, claimAmount, bonusAmount, burnAmount);

        return
            WithdrawResult({
                principle: 0,
                interest: claimAmount,
                forw: 0,
                pTokenBurn: 0,
                itpTokenBurn: burnAmount,
                ifpTokenBurn: 0,
                interestBonus: bonusAmount,
                forwBonus: 0
            });
    }

    function _claimForwInterest(
        address receiver,
        uint256 nftId,
        uint256 claimAmount
    ) internal returns (WithdrawResult memory) {
        uint256 forwInterestPrice = _getInterestForwPrice();
        PoolTokens storage tokenHolder = tokenHolders[nftId];
        uint256 claimableAmount = ((tokenHolder.ifpToken * forwInterestPrice) / WEI_UNIT) -
            tokenHolder.pToken;

        claimAmount = Math.min(claimAmount, claimableAmount);

        uint256 burnAmount = _burnIfpToken(
            receiver,
            nftId,
            (claimAmount * WEI_UNIT) / forwInterestPrice,
            forwInterestPrice
        );

        uint256 bonusPercent = _getNFTRankInfo(nftId).forwardBonusLending;
        uint256 bonusAmount = (claimAmount * bonusPercent) / WEI_PERCENT_UNIT;
        // _transferFromIn(interestVaultAddress, receiver, forwAddress, claimAmount + bonusAmount);

        IInterestVault(interestVaultAddress).withdrawForwInterest(receiver, claimAmount);

        emit ClaimForwInterest(receiver, nftId, claimAmount, bonusAmount, burnAmount);

        return
            WithdrawResult({
                principle: 0,
                interest: 0,
                forw: claimAmount,
                pTokenBurn: 0,
                itpTokenBurn: 0,
                ifpTokenBurn: burnAmount,
                interestBonus: 0,
                forwBonus: bonusAmount
            });
    }

    function _borrow(
        uint256 loanId,
        uint256 nftId,
        uint256 borrowAmount,
        uint256 collateralSentAmount,
        address collateralTokenAddress
    ) internal returns (CoreBase.Loan memory) {
        require(
            loanId != 0 || collateralSentAmount > 0,
            "APHPool/new-loan-must-provide-collateral"
        );
        // TODO: borrowAmount should not exceed poolMaxCap * reservedFactor
        require(
            borrowAmount > 0 && _totalSupply() >= borrowAmount,
            "APHPool/pool-supply-sufficient-for-borrowing"
        );
        require(
            tokenAddress != collateralTokenAddress,
            "APHPool/collateral-token-is-same-as-borrow-token"
        );

        (uint256 interestRate, uint256 interestOwedPerDay) = _calculateBorrowInterest(borrowAmount);

        return
            IAPHCore(coreAddress).borrow(
                loanId,
                nftId,
                borrowAmount,
                tokenAddress,
                collateralSentAmount,
                collateralTokenAddress,
                interestOwedPerDay,
                interestRate
            );
    }

    function _calculateBorrowInterest(uint256 borrowAmount)
        internal
        view
        returns (uint256 interestRate, uint256 interestOwedPerDay)
    {
        interestRate = _getNextBorrowingInterest(borrowAmount);

        interestOwedPerDay = (borrowAmount * interestRate) / (WEI_PERCENT_UNIT * 365 days);
    }

    function _getNextLendingInterest(uint256 newdepositAmount)
        internal
        view
        returns (uint256 interestRate)
    {
        uint256 utilRate = _utilizationRate(
            pTokenTotalSupply - _totalSupply(),
            pTokenTotalSupply + newdepositAmount
        );

        uint256 borrowInterestOwedPerDay = IAPHCore(coreAddress)
            .poolStats(address(this))
            .borrowInterestOwedPerDay;

        interestRate =
            (IAPHCore(coreAddress).feeSpread() * borrowInterestOwedPerDay * utilRate) /
            (WEI_UNIT * WEI_PERCENT_UNIT);
    }

    function _getNextBorrowingInterest(uint256 newBorrowAmount)
        internal
        view
        returns (uint256 nextInterestRate)
    {
        uint256 utilRate = _utilizationRate(
            pTokenTotalSupply - _totalSupply() + newBorrowAmount,
            pTokenTotalSupply
        );

        uint256[3] memory ws = [w1, w2, w3];
        uint256[4] memory utilOptimises = [
            utilOptimise1,
            utilOptimise2,
            utilOptimise3,
            WEI_PERCENT_UNIT
        ];

        if (pTokenTotalSupply < targetSupply) {
            for (uint256 i = 0; i < 3; i++) {
                utilOptimises[i] =
                    (utilOptimises[i] * pTokenTotalSupply) /
                    (targetSupply * WEI_PERCENT_UNIT);
            }
        }

        nextInterestRate = baseRate;
        for (uint256 i = 0; i < 3; i++) {
            if (utilRate >= utilOptimises[i]) {
                nextInterestRate +=
                    (_getCurrentRatio(
                        Math.min(utilRate, utilOptimises[i + 1]),
                        utilOptimises[i],
                        utilOptimises[i + 1]
                    ) * ws[i]) /
                    WEI_PERCENT_UNIT;
            }
        }
    }

    function _utilizationRate(uint256 assetBorrow, uint256 assetSupply)
        internal
        view
        returns (uint256)
    {
        if (assetBorrow != 0 && assetSupply != 0) {
            // U = total_borrow / total_supply
            return (assetBorrow * WEI_PERCENT_UNIT) / assetSupply;
        }
        return 0;
    }

    function _getCurrentRatio(
        uint256 utilRate,
        uint256 currentUtil,
        uint256 nextUtil
    ) internal view returns (uint256 currentRatio) {
        currentRatio = ((utilRate - currentUtil) * WEI_PERCENT_UNIT) / (nextUtil - currentUtil);
    }

    function _getInterestTokenPrice() internal view returns (uint256) {
        if (itpTokenTotalSupply == 0) {
            return initialItpPrice;
        } else {
            return
                ((pTokenTotalSupply + IInterestVault(interestVaultAddress).claimableInterest()) *
                    WEI_UNIT) / itpTokenTotalSupply;
        }
    }

    function _getInterestForwPrice() internal view returns (uint256) {
        if (ifpTokenTotalSupply == 0) {
            return initialItpPrice;
        } else {
            return
                ((pTokenTotalSupply + IInterestVault(interestVaultAddress).getTotalForw()) *
                    WEI_UNIT) / ifpTokenTotalSupply;
        }
    }

    function _totalSupply() internal view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function _getNFTRank(uint256 nftId) internal view returns (uint8) {
        return IMembership(membershipAddress).getRank(nftId);
    }

    function _getNFTRankInfo(uint256 nftId) internal view returns (StakePoolBase.RankInfo memory) {
        address stakePoolAddress = IMembership(membershipAddress).currentPool();
        return IStakePool(stakePoolAddress).getRankInfo(_getNFTRank(nftId));
    }

    function _NFTOwner(uint256 nftId) internal view returns (address) {
        return IMembership(membershipAddress).ownerOf(nftId);
    }
}

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

import "../src/core/CoreBase.sol";

interface IAPHCore {
    // Mock function
    function setIsHardHatEnv(bool i) external;

    function setMockFeedAddr(address _address) external;

    function settleForwInterest() external;

    // External functions
    function getLoan(uint256 nftId, uint256 loanId) external view returns (CoreBase.Loan memory);

    function isPool(address poolAddess) external view returns (bool);

    function getLoanConfig(address _borrowTokenAddress, address _collateralTokenAddress)
        external
        view
        returns (CoreBase.LoanConfig memory);

    function getActiveLoansId(uint256 nftId) external view returns (uint256[] memory);

    function getActiveLoans(uint256 nftId) external view returns (CoreBase.Loan[] memory);

    function getPoolList() external view returns (address[] memory);

    function borrow(
        uint256 loanId,
        uint256 nftId,
        uint256 borrowAmount,
        address borrowTokenAddress,
        uint256 collateralSentAmount,
        address collateralTokenAddress,
        uint256 newOwedPerDay,
        uint256 interestRate
    ) external returns (CoreBase.Loan memory);

    function repay(
        uint256 loanId,
        uint256 nftId,
        uint256 repayAmount,
        bool isOnlyInterest
    ) external payable returns (uint256, uint256);

    function adjustCollateral(
        uint256 loanId,
        uint256 nftId,
        uint256 collateralAdjustAmount,
        bool isAdd
    ) external payable returns (CoreBase.Loan memory);

    function rollover(uint256 loanId, uint256 nftId) external returns (uint256, uint256);

    function liquidate(uint256 loanId, uint256 nftId)
        external
        returns (
            uint256,
            uint256,
            uint256
        );

    // Getter functions
    function feeSpread() external view returns (uint256);

    function loanDuration() external view returns (uint256);

    function advancedInterestDuration() external view returns (uint256);

    function totalCollateralHold(address) external view returns (uint256);

    function poolStats(address) external view returns (CoreBase.PoolStat memory);

    function swapableToken(address) external view returns (bool);

    function poolToAsset(address) external view returns (address);

    function assetToPool(address) external view returns (address);

    function poolList(uint256) external view returns (address);

    function maxDisagreement() external view returns (uint256);

    function maxSwapSize() external view returns (uint256);

    function feesController() external view returns (address);

    function oracleAddress() external view returns (address);

    function routerAddress() external view returns (address);

    function membershipAddress() external view returns (address);

    function loans(uint256, uint256) external view returns (CoreBase.Loan memory);

    function LoanInterests(uint256, uint256) external view returns (CoreBase.LoanInterest memory);

    function currentIndex(uint256) external view returns (uint256);

    function loanConfigs(address, address) external view returns (CoreBase.LoanConfig memory);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../src/stakepool/StakePoolBase.sol";

interface IStakePool {
    // Getter functions
    function rankInfos(uint8) external view returns (StakePoolBase.RankInfo memory);

    function stakeInfos(uint256) external view returns (StakePoolBase.StakeInfo memory);

    // External functions

    function settle(uint256 nftId) external;

    function stake(uint256 nftId, uint256 amount) external returns (StakePoolBase.StakeInfo memory);

    function unstake(uint256 nftId, uint256 amount)
        external
        returns (StakePoolBase.StakeInfo memory);

    function setRankInfo(
        uint8[] memory _rank,
        uint256[] memory _interestBonusLending,
        uint256[] memory _forwardBonusLending,
        uint256[] memory _minimumstakeAmount
    ) external;

    function settleInterval() external view returns (uint256);

    function settlePeriod() external view returns (uint256);

    function poolStartTimestamp() external view returns (uint64);

    function rankLen() external view returns (uint256);

    function getRankInfo(uint8 _rank) external view returns (StakePoolBase.RankInfo memory);
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

// import "../../abstract/APoolToken.sol";

contract PoolToken {
    struct PoolTokens {
        uint256 pToken;
        uint256 itpToken;
        uint256 ifpToken;
    }

    uint256 public pTokenTotalSupply;
    uint256 public itpTokenTotalSupply;
    uint256 public ifpTokenTotalSupply;
    mapping(uint256 => PoolTokens) public tokenHolders;

    constructor() {
        pTokenTotalSupply = 0;
        itpTokenTotalSupply = 0;
        ifpTokenTotalSupply = 0;
    }

    event MintPToken(address indexed minter, uint256 indexed NFTId, uint256 amount);
    event MintItpToken(
        address indexed minter,
        uint256 indexed NFTId,
        uint256 amount,
        uint256 price
    );
    event MintIfpToken(
        address indexed minter,
        uint256 indexed NFTId,
        uint256 amount,
        uint256 price
    );

    event BurnPToken(address indexed burner, uint256 indexed NFTId, uint256 amount);
    event BurnItpToken(
        address indexed burner,
        uint256 indexed NFTId,
        uint256 amount,
        uint256 price
    );
    event BurnIfpToken(
        address indexed burner,
        uint256 indexed NFTId,
        uint256 amount,
        uint256 price
    );

    // external function

    function balancePTokenOf(uint256 NFTId) external view returns (uint256) {
        return tokenHolders[NFTId].pToken;
    }

    function balanceItpTokenOf(uint256 NFTId) external view returns (uint256) {
        return tokenHolders[NFTId].itpToken;
    }

    function balanceIfpTokenOf(uint256 NFTId) external view returns (uint256) {
        return tokenHolders[NFTId].ifpToken;
    }

    // internal function

    function _mintPToken(
        address receiver,
        uint256 NFTId,
        uint256 mintAmount
    ) internal returns (uint256) {
        pTokenTotalSupply += mintAmount;
        tokenHolders[NFTId].pToken += mintAmount;

        emit MintPToken(receiver, NFTId, mintAmount);
        return mintAmount;
    }

    function _mintItpToken(
        address receiver,
        uint256 NFTId,
        uint256 mintAmount,
        uint256 price
    ) internal returns (uint256) {
        itpTokenTotalSupply += mintAmount;
        tokenHolders[NFTId].itpToken += mintAmount;

        emit MintItpToken(receiver, NFTId, mintAmount, price);
        return mintAmount;
    }

    function _mintIfpToken(
        address receiver,
        uint256 NFTId,
        uint256 mintAmount,
        uint256 price
    ) internal returns (uint256) {
        ifpTokenTotalSupply += mintAmount;
        tokenHolders[NFTId].ifpToken += mintAmount;

        emit MintIfpToken(receiver, NFTId, mintAmount, price);
        return mintAmount;
    }

    function _burnPToken(
        address burner,
        uint256 NFTId,
        uint256 burnAmount
    ) internal returns (uint256) {
        pTokenTotalSupply -= burnAmount;
        tokenHolders[NFTId].pToken -= burnAmount;

        emit BurnPToken(burner, NFTId, burnAmount);
        return burnAmount;
    }

    function _burnItpToken(
        address burner,
        uint256 NFTId,
        uint256 burnAmount,
        uint256 price
    ) internal returns (uint256) {
        itpTokenTotalSupply -= burnAmount;
        tokenHolders[NFTId].itpToken -= burnAmount;

        emit BurnItpToken(burner, NFTId, burnAmount, price);
        return burnAmount;
    }

    function _burnIfpToken(
        address burner,
        uint256 NFTId,
        uint256 burnAmount,
        uint256 price
    ) internal returns (uint256) {
        ifpTokenTotalSupply -= burnAmount;
        tokenHolders[NFTId].ifpToken -= burnAmount;

        emit BurnIfpToken(burner, NFTId, burnAmount, price);
        return burnAmount;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

contract PoolEvent {
    event Deposit(
        address indexed owner,
        uint256 indexed nftId,
        uint256 depositAmount,
        uint256 mintedP,
        uint256 mintedItp,
        uint256 mintedIfp
    );
    event Withdraw(
        address indexed owner,
        uint256 indexed nftId,
        uint256 withdrawAmount,
        uint256 burnedP,
        uint256 burnedItp,
        uint256 burnedIfp
    );
    event ClaimTokenInterest(
        address indexed owner,
        uint256 indexed nftId,
        uint256 interestTokenClaimed,
        uint256 interestTokenBonus,
        uint256 burnedItp
    );
    event ClaimForwInterest(
        address indexed owner,
        uint256 indexed nftId,
        uint256 interestForwClaimed,
        uint256 interestForwBonus,
        uint256 burnedIfp
    );
    event ActivateRank(address indexed owner, uint256 indexed nftId, uint8 oldRank, uint8 newRank);
    event Initialize(
        address indexed manager,
        address indexed coreAddress,
        address interestVaultAddress,
        address membershipAddress
    );
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "./PoolBase.sol";
import "../../interfaces/IAPHCoreSetting.sol";

contract PoolSetting is PoolBase {
    // external function onlyManager
    function setInterestVaultAddress(address _address) external onlyManager {
        interestVaultAddress = _address;
    }

    function setDemandCurve(
        uint256 _baseRate,
        uint256 _w1,
        uint256 _w2,
        uint256 _w3,
        uint256 _utilOptimise1,
        uint256 _utilOptimise2,
        uint256 _utilOptimise3,
        uint256 _targetSupply
    ) external onlyManager {
        // TODO: reduce require statement
        require(_baseRate <= WEI_PERCENT_UNIT, "PoolSetting/curve-params-too-high");
        require(_utilOptimise1 < _utilOptimise2, "PoolSetting/invalid-utilOptimise-1");
        require(_utilOptimise2 < _utilOptimise3, "PoolSetting/invalid-utilOptimise-2");
        require(_utilOptimise3 < WEI_PERCENT_UNIT, "PoolSetting/invalid-utilOptimise-3");

        baseRate = _baseRate;
        w1 = _w1;
        w2 = _w2;
        w3 = _w3;
        utilOptimise1 = _utilOptimise1;
        utilOptimise2 = _utilOptimise2;
        utilOptimise3 = _utilOptimise3;
        targetSupply = _targetSupply;
    }

    function setupLoanConfig(
        address collateralTokenAddress,
        uint256 safeLTV,
        uint256 maxLTV,
        uint256 liqLTV,
        uint256 bountyFeeRate
    ) external onlyManager {
        // TODO: reduce require statement
        require(safeLTV < maxLTV, "PoolSetting/invalid-LTV-1");
        require(maxLTV < liqLTV, "PoolSetting/invalid-LTV-2");
        require(liqLTV < WEI_PERCENT_UNIT, "PoolSetting/invalid-LTV-3");

        IAPHCoreSetting(coreAddress).setupLoanConfig(
            tokenAddress,
            collateralTokenAddress,
            safeLTV,
            maxLTV,
            liqLTV,
            bountyFeeRate
        );
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../../externalContract/openzeppelin/Ownable.sol";
import "../../externalContract/openzeppelin/IERC20.sol";
import "../../externalContract/modify/SelectorPausable.sol";

contract InterestVault is Ownable, SelectorPausable {
    uint256 public claimableInterest;
    uint256 public heldInterest;
    uint256 public actualInterestProfit;
    uint256 public claimableForwInterest;
    uint256 public cumulativeInterestProfit;

    address public token;
    address public forw;
    address public protocol;

    modifier onlyProtocol() {
        require(msg.sender == protocol, "InterestVault/permission-denied");
        _;
    }

    constructor(
        address _token,
        address _forw,
        address _protocol
    ) {
        token = _token;
        forw = _forw;
        protocol = _protocol;
        _ownerApprove(msg.sender);
    }

    // external function onlyOwner
    function ownerApprove(address _pool) external onlyOwner {
        _ownerApprove(_pool);
    }

    function setForwAddress(address _address) external onlyOwner {
        forw = _address;
    }

    function setTokenAddress(address _address) external onlyOwner {
        token = _address;
    }

    function setProtocolAddress(address _address) external onlyOwner {
        protocol = _address;
    }

    // external function

    function settleInterest(
        uint256 _claimableInterest,
        uint256 _heldInterest,
        uint256 _claimableForwInterest
    ) external onlyProtocol {
        _settleInterest(_claimableInterest, _heldInterest, _claimableForwInterest);
    }

    function withdrawInterest(
        address receiver,
        uint256 claimable,
        uint256 bonus,
        uint256 profit
    ) external onlyOwner {
        _withdrawInterest(receiver, claimable, bonus, profit);
    }

    function withdrawForwInterest(address receiver, uint256 claimable) external onlyOwner {
        _withdrawForwInterest(receiver, claimable);
    }

    function withdrawActualProfit(address receiver) external onlyOwner returns (uint256) {
        return _withdrawActualProfit(receiver);
    }

    function getTotalInterest() external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function getTotalForw() external view returns (uint256) {
        return IERC20(forw).balanceOf(address(this));
    }

    function pause(bytes4 _func) external onlyOwner {
        require(_func != bytes4(0), "");
        _pause(_func);
    }

    function unPause(bytes4 _func) external onlyOwner {
        require(_func != bytes4(0), "");
        _unpause(_func);
    }

    // Internal
    // `receiver` is for later use (event)
    function _ownerApprove(address _pool) internal {
        IERC20(token).approve(_pool, type(uint256).max);
        IERC20(forw).approve(_pool, type(uint256).max);
    }

    function _settleInterest(
        uint256 _claimableInterest,
        uint256 _heldInterest,
        uint256 _claimableForwInterest
    ) internal {
        claimableInterest += _claimableInterest;
        heldInterest += _heldInterest;
        claimableForwInterest += _claimableForwInterest;
    }

    function _withdrawInterest(
        address receiver,
        uint256 claimable,
        uint256 bonus,
        uint256 profit
    ) internal {
        claimableInterest -= claimable;
        heldInterest -= bonus + profit;
        actualInterestProfit += profit;
        cumulativeInterestProfit += profit;
    }

    function _withdrawForwInterest(address receiver, uint256 claimable) internal {
        claimableForwInterest -= claimable;
    }

    function _withdrawActualProfit(address receiver) internal returns (uint256) {
        uint256 tempInterestProfit = actualInterestProfit;
        actualInterestProfit = 0;
        return tempInterestProfit;
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

import "./IWeth.sol";
import "../externalContract/openzeppelin/IERC20.sol";

interface IWethERC20 is IWeth, IERC20 {}

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../../externalContract/openzeppelin/Ownable.sol";
import "../../externalContract/openzeppelin/ReentrancyGuard.sol";
import "../../externalContract/modify/SelectorPausable.sol";
import "../utils/AssetHandler.sol";
import "../utils/Manager.sol";

contract StakePoolBase is AssetHandler, Ownable, Manager, ReentrancyGuard, SelectorPausable {
    struct StakeInfo {
        uint256 stakeBalance;
        uint256 claimableAmount;
        uint64 startTimestamp;
        uint64 endTimestamp;
        uint64 lastSettleTimestamp;
        uint256[] payPattern;
    }

    struct RankInfo {
        uint256 interestBonusLending;
        uint256 forwardBonusLending;
        uint256 minimumStakeAmount;
    }

    address public membershipAddress;
    address public nextPoolAddress;
    address public stakeVaultAddress;
    address public forwAddress;
    uint64 public poolStartTimestamp;
    uint256 public settleInterval;
    uint256 public settlePeriod;
    uint256 public rankLen;
    mapping(uint256 => StakeInfo) public stakeInfos;
    mapping(uint8 => RankInfo) public rankInfos;
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../src/core/CoreBase.sol";

interface IAPHCoreSetting {
    // External functions
    function registerNewPool(address poolAddress) external;

    function setupLoanConfig(
        address borrowTokenAddress,
        address collateralTokenAddress,
        uint256 newSafeLTV,
        uint256 newMaxLTV,
        uint256 newLiquidationLTV,
        uint256 newBountyFeeRate
    ) external;

    function setOracleAddress(address _oracleAddress) external;

    function setMembershipAddress(address _address) external;
}