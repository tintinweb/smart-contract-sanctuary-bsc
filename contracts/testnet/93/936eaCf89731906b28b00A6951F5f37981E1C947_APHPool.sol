// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

import "./PoolBaseFunc.sol";

import "./PoolSetting.sol";
import "./APHPoolProxy.sol";
import "./InterestVault.sol";

contract APHPool is PoolBaseFunc, APHPoolProxy, PoolSetting {
    constructor() initializer {}

    function initialize(
        address _tokenAddress,
        address _coreAddress,
        address _membershipAddress,
        address _forwAddress,
        address _wethAddress,
        address _wethHandlerAddress,
        uint256 _blockTime
    ) external virtual initializer {
        require(_tokenAddress != address(0), "APHPool/initialize/tokenAddress-zero-address");
        require(_coreAddress != address(0), "APHPool/initialize/coreAddress-zero-address");
        require(_membershipAddress != address(0), "APHPool/initialize/membership-zero-address");
        tokenAddress = _tokenAddress;
        coreAddress = _coreAddress;
        membershipAddress = _membershipAddress;
        manager = msg.sender;

        forwAddress = _forwAddress;
        interestVaultAddress = address(
            new InterestVault(tokenAddress, forwAddress, coreAddress, manager)
        );
        require(_blockTime != 0, "_blockTime cannot be zero");
        BLOCK_TIME = _blockTime;

        WEI_UNIT = 10**18;
        WEI_PERCENT_UNIT = 10**20;
        initialItpPrice = WEI_UNIT;
        initialIfpPrice = WEI_UNIT;
        lambda = 1 ether / 100;
        __AssetHandler_init_unchained(_wethAddress, _wethHandlerAddress);

        emit Initialize(manager, coreAddress, interestVaultAddress, membershipAddress);
        emit TransferManager(address(0), manager);
    }

    /**
      @dev Returns lending interest rate if lender deposit more token to APHPool

      NOTE: if depositAmount is 0, this return current lending interest rate
     */
    function getNextLendingInterest(uint256 depositAmount) external view returns (uint256) {
        return _getNextLendingInterest(depositAmount);
    }

    /**
      @dev Returns forw interest rate if lender deposit more token to APHPool

      NOTE: if depositAmount is 0, this return current forw interest rate
     */
    function getNextLendingForwInterest(uint256 depositAmount) external view returns (uint256) {
        return _getNextLendingForwInterest(depositAmount);
    }

    /**
      @dev Returns borrowing interest rate if borrower borrow more token from APHPool

      NOTE: if borrowAmount is 0, this return current borrowing interest rate
     */
    function getNextBorrowingInterest(uint256 borrowAmount) external view returns (uint256) {
        return _getNextBorrowingInterest(borrowAmount);
    }

    /**
      @dev Returns borrowing interest rate and interest owedPerDay if borrower borrow more token from APHPool
      NOTE: if borrowAmount is 0, this return current borrowing interest rate and interest owedPerDay
     */
    function calculateInterest(uint256 borrowAmount) external view returns (uint256, uint256) {
        return _calculateBorrowInterest(borrowAmount);
    }

    /**
      @dev Returns price to calculate itpToken mint/burn compared to pToken deposit/withdraw
      NOTE: calculated by (pToken + claimableTokenInterest)/itpToken
     */
    function getInterestTokenPrice() external view returns (uint256) {
        return _getInterestTokenPrice();
    }

    /**
      @dev Returns price to calculate ifpToken mint/burn compared to pToken deposit/withdraw
      NOTE: calculated by (pToken + claimableForwInterest)/ifpToken
     */
    function getInterestForwPrice() external view returns (uint256) {
        return _getInterestForwPrice();
    }

    /**
      @dev Returns available token for lending
     */
    function currentSupply() external view returns (uint256) {
        return _currentSupply();
    }

    /**
      @dev Returns utilizationRate which is ratio between total token borrowed and total token lent
     */
    function utilizationRate() external view returns (uint256) {
        return _utilizationRate(_totalBorrowAmount(), pTokenTotalSupply);
    }

    /**
      @dev Returns claimable token interest and forw interest
     */
    function claimableInterest(uint256 nftId)
        external
        view
        returns (uint256 tokenInterest, uint256 forwInterest)
    {
        PoolTokens memory tokenHolder = tokenHolders[nftId];

        if ((tokenHolder.itpToken * _getInterestTokenPrice()) / WEI_UNIT >= tokenHolder.pToken) {
            tokenInterest =
                ((tokenHolder.itpToken * _getInterestTokenPrice()) / WEI_UNIT) -
                tokenHolder.pToken;
        } else {
            tokenInterest = 0;
        }
        if (((tokenHolder.ifpToken * _getInterestForwPrice()) / WEI_UNIT) >= tokenHolder.pToken) {
            forwInterest =
                ((tokenHolder.ifpToken * _getInterestForwPrice()) / WEI_UNIT) -
                tokenHolder.pToken;
            forwInterest = (forwInterest * WEI_UNIT) / lambda;
        } else {
            forwInterest = 0;
        }
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

import "../../interfaces/IAPHCore.sol";
import "../../interfaces/IStakePool.sol";
import "../../interfaces/IInterestVault.sol";
import "../../interfaces/IMembership.sol";
import "../../interfaces/IPriceFeed.sol";

import "./PoolBase.sol";
import "./PoolToken.sol";

contract PoolBaseFunc is PoolBase, PoolToken {
    modifier settleForwInterest() {
        IAPHCore(coreAddress).settleForwInterest();
        _;
    }

    function pause(bytes4 _func) external onlyManager {
        require(_func != bytes4(0), "PoolBaseFunc/msg.sig-func-is-zero");
        _pause(_func);
    }

    function unPause(bytes4 _func) external onlyManager {
        require(_func != bytes4(0), "PoolBaseFunc/msg.sig-func-is-zero");
        _unpause(_func);
    }

    // internal function
    function _calculateBorrowInterest(uint256 borrowAmount)
        internal
        view
        returns (uint256 interestRate, uint256 interestOwedPerDay)
    {
        interestRate = _getNextBorrowingInterest(borrowAmount);

        interestOwedPerDay = (borrowAmount * interestRate) / (WEI_PERCENT_UNIT * 365);
    }

    function _getNextLendingInterest(uint256 newDepositAmount)
        internal
        view
        returns (uint256 interestRate)
    {
        uint256 totalBorrow = _totalBorrowAmount();
        if (totalBorrow == 0) {
            return 0;
        }
        uint256 utilRate = _utilizationRate(
            totalBorrow, // borrow amount
            pTokenTotalSupply + newDepositAmount // total supply
        );

        uint256 borrowInterestOwedPerDay = IAPHCore(coreAddress)
            .poolStats(address(this))
            .borrowInterestOwedPerDay;

        uint256 avgBorrowInterestRate = (borrowInterestOwedPerDay * 365 * WEI_PERCENT_UNIT) /
            totalBorrow;

        interestRate =
            ((WEI_PERCENT_UNIT - IAPHCore(coreAddress).feeSpread()) *
                avgBorrowInterestRate *
                utilRate) /
            (WEI_PERCENT_UNIT * WEI_PERCENT_UNIT);
    }

    function _getNextLendingForwInterest(uint256 newDepositAmount)
        internal
        view
        returns (uint256 interestRate)
    {
        (uint256 rate, uint256 precision) = IPriceFeed(IAPHCore(coreAddress).priceFeedAddress())
            .queryRate(tokenAddress, forwAddress);

        uint256 ifpPrice = _getInterestForwPrice();

        uint256 newIfpTokenSupply = ifpTokenTotalSupply +
            ((newDepositAmount * WEI_UNIT) / ifpPrice);

        if (newIfpTokenSupply == 0) {
            interestRate = 0;
        } else {
            interestRate =
                (IAPHCore(coreAddress).forwDisPerBlock(address(this)) *
                    (365 days / BLOCK_TIME) *
                    rate *
                    WEI_UNIT) /
                (newIfpTokenSupply * precision);
        }
    }

    function _getNextBorrowingInterest(uint256 newBorrowAmount)
        internal
        view
        returns (uint256 nextInterestRate)
    {
        uint256[10] memory localUtils = utils;
        uint256[10] memory localRates = rates;

        nextInterestRate = localRates[0];

        if (pTokenTotalSupply == 0) {
            return nextInterestRate;
        }

        uint256 w = MathUpgradeable.max(WEI_UNIT, (targetSupply * WEI_UNIT) / pTokenTotalSupply);
        uint256 utilRate = _utilizationRate(
            _totalBorrowAmount() + newBorrowAmount,
            pTokenTotalSupply
        );

        localUtils[utilsLen - 1] = (localUtils[utilsLen - 1] * w) / WEI_UNIT;

        uint256 tmp;
        for (uint256 i = 1; i < utilsLen; i++) {
            tmp = 0;
            tmp = MathUpgradeable.max((w * utilRate) / WEI_UNIT, localUtils[i - 1]);
            tmp = MathUpgradeable.min(tmp, localUtils[i]);
            if (tmp >= localUtils[i - 1]) {
                tmp = tmp - localUtils[i - 1];
            } else {
                tmp = 0;
            }
            nextInterestRate +=
                (tmp * (localRates[i] - localRates[i - 1])) /
                (localUtils[i] - localUtils[i - 1]);
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

    function _getInterestTokenPrice() internal view returns (uint256) {
        if (itpTokenTotalSupply == 0) {
            return initialItpPrice;
        } else {
            return
                ((pTokenTotalSupply +
                    IInterestVault(interestVaultAddress).claimableTokenInterest()) * WEI_UNIT) /
                itpTokenTotalSupply;
        }
    }

    function _getInterestForwPrice() internal view returns (uint256) {
        if (ifpTokenTotalSupply == 0) {
            return initialIfpPrice;
        } else {
            return
                ((pTokenTotalSupply +
                    ((IInterestVault(interestVaultAddress).claimableForwInterest() * lambda) /
                        WEI_UNIT)) * WEI_UNIT) / ifpTokenTotalSupply;
        }
    }

    function _currentSupply() internal view returns (uint256) {
        return pTokenTotalSupply - _totalBorrowAmount();
    }

    function _totalBorrowAmount() internal view returns (uint256) {
        return IAPHCore(coreAddress).poolStats(address(this)).totalBorrowAmount;
    }

    function _getPoolRankInfo(uint256 nftId) internal view returns (StakePoolBase.RankInfo memory) {
        return
            IStakePool(IMembership(membershipAddress).currentPool()).rankInfos(lenders[nftId].rank);
    }

    function _getNFTRankInfo(uint256 nftId) internal view returns (StakePoolBase.RankInfo memory) {
        return
            IStakePool(IMembership(membershipAddress).currentPool()).rankInfos(_getNFTRank(nftId));
    }

    function _getNFTRank(uint256 nftId) internal view returns (uint8) {
        return IMembership(membershipAddress).getRank(nftId);
    }

    function _NFTOwner(uint256 nftId) internal view returns (address) {
        return IMembership(membershipAddress).ownerOf(nftId);
    }

    function _getUsableToken(address owner, uint256 nftId) internal view returns (uint256) {
        return IMembership(membershipAddress).usableTokenId(owner, nftId);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

import "./PoolBaseFunc.sol";
import "./event/PoolSettingEvent.sol";
import "../../interfaces/IAPHCoreSetting.sol";

contract PoolSetting is PoolBaseFunc, PoolSettingEvent {
    function setBorrowInterestParams(
        uint256[] memory _rates,
        uint256[] memory _utils,
        uint256 _targetSupply
    ) external onlyManager {
        require(_rates.length == _utils.length, "PoolSetting/length-not-equal");
        require(_rates.length <= 10, "PoolSetting/length-too-high");
        require(_utils[0] == 0, "PoolSetting/invalid-first-util");
        require(_utils[_utils.length - 1] == WEI_PERCENT_UNIT, "PoolSetting/invalid-last-util");

        for (uint256 i = 1; i < _rates.length; i++) {
            require(_rates[i - 1] <= _rates[i], "PoolSetting/invalid-rate");
            require(_utils[i - 1] < _utils[i], "PoolSetting/invalid-util");
        }

        for (uint256 i = 0; i < _rates.length; i++) {
            rates[i] = _rates[i];
            utils[i] = _utils[i];
        }
        targetSupply = _targetSupply;
        utilsLen = _utils.length;

        emit SetBorrowInterestParams(msg.sender, _rates, _utils, targetSupply);
    }

    function setupLoanConfig(
        address _collateralTokenAddress,
        uint256 _safeLTV,
        uint256 _maxLTV,
        uint256 _liqLTV,
        uint256 _bountyFeeRate
    ) external onlyManager {
        require(
            _safeLTV < _maxLTV && _maxLTV < _liqLTV && _liqLTV < WEI_PERCENT_UNIT,
            "PoolSetting/invalid-loan-config"
        );

        require(_bountyFeeRate <= WEI_PERCENT_UNIT, "CoreSetting/_bountyFeeRate-too-high");

        IAPHCoreSetting(coreAddress).setupLoanConfig(
            tokenAddress,
            _collateralTokenAddress,
            _safeLTV,
            _maxLTV,
            _liqLTV,
            _bountyFeeRate
        );

        emit SetLoanConfig(
            msg.sender,
            _collateralTokenAddress,
            _safeLTV,
            _maxLTV,
            _liqLTV,
            _bountyFeeRate
        );
    }

    function setPoolLendingAddress(address _address) external onlyManager {
        address oldAddress = poolLendingAddress;
        poolLendingAddress = _address;

        emit SetPoolLendingAddress(msg.sender, oldAddress, _address);
    }

    function setPoolBorrowingAddress(address _address) external onlyManager {
        address oldAddress = poolBorrowingAddress;
        poolBorrowingAddress = _address;

        emit SetPoolBorrowingAddress(msg.sender, oldAddress, _address);
    }

    function setWETHHandler(address _address) external onlyManager {
        address oldAddress = wethHandler;
        wethHandler = _address;

        emit SetWETHHandler(msg.sender, oldAddress, _address);
    }

    function setMembershipAddress(address _address) external onlyManager {
        address oldAddress = forwAddress;
        forwAddress = _address;

        emit SetMembershipAddress(msg.sender, oldAddress, _address);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

import "./PoolBaseFunc.sol";

contract APHPoolProxy is PoolBaseFunc {
    function activateRank(uint256 nftId) external returns (uint8 newRank) {
        (bool success, bytes memory data) = poolLendingAddress.delegatecall(
            abi.encodeWithSignature("activateRank(uint256)", nftId)
        );
        if (!success) {
            if (data.length == 0) revert();
            assembly {
                revert(add(32, data), mload(data))
            }
        }
        newRank = abi.decode(data, (uint8));
    }

    function deposit(uint256 nftId, uint256 depositAmount)
        external
        payable
        returns (
            uint256 mintedP,
            uint256 mintedItp,
            uint256 mintedIfp
        )
    {
        (bool success, bytes memory data) = poolLendingAddress.delegatecall(
            abi.encodeWithSignature("deposit(uint256,uint256)", nftId, depositAmount)
        );
        if (!success) {
            if (data.length == 0) revert();
            assembly {
                revert(add(32, data), mload(data))
            }
        }
        (mintedP, mintedItp, mintedIfp) = abi.decode(data, (uint256, uint256, uint256));
    }

    function withdraw(uint256 nftId, uint256 withdrawAmount)
        external
        returns (WithdrawResult memory result)
    {
        (bool success, bytes memory data) = poolLendingAddress.delegatecall(
            abi.encodeWithSignature("withdraw(uint256,uint256)", nftId, withdrawAmount)
        );
        if (!success) {
            if (data.length == 0) revert();
            assembly {
                revert(add(32, data), mload(data))
            }
        }
        result = abi.decode(data, (WithdrawResult));
    }

    function claimAllInterest(uint256 nftId) external returns (WithdrawResult memory result) {
        (bool success, bytes memory data) = poolLendingAddress.delegatecall(
            abi.encodeWithSignature("claimAllInterest(uint256)", nftId)
        );
        if (!success) {
            if (data.length == 0) revert();
            assembly {
                revert(add(32, data), mload(data))
            }
        }
        result = abi.decode(data, (WithdrawResult));
    }

    function claimTokenInterest(uint256 nftId, uint256 claimAmount)
        external
        returns (WithdrawResult memory result)
    {
        (bool success, bytes memory data) = poolLendingAddress.delegatecall(
            abi.encodeWithSignature("claimTokenInterest(uint256,uint256)", nftId, claimAmount)
        );
        if (!success) {
            if (data.length == 0) revert();
            assembly {
                revert(add(32, data), mload(data))
            }
        }
        result = abi.decode(data, (WithdrawResult));
    }

    function claimForwInterest(uint256 nftId, uint256 claimAmount)
        external
        returns (WithdrawResult memory result)
    {
        (bool success, bytes memory data) = poolLendingAddress.delegatecall(
            abi.encodeWithSignature("claimForwInterest(uint256,uint256)", nftId, claimAmount)
        );
        if (!success) {
            if (data.length == 0) revert();
            assembly {
                revert(add(32, data), mload(data))
            }
        }
        result = abi.decode(data, (WithdrawResult));
    }

    function borrow(
        uint256 loanId,
        uint256 nftId,
        uint256 borrowAmount,
        uint256 collateralSentAmount,
        address collateralTokenAddress
    ) external payable returns (CoreBase.Loan memory loan) {
        (bool success, bytes memory data) = poolBorrowingAddress.delegatecall(
            abi.encodeWithSignature(
                "borrow(uint256,uint256,uint256,uint256,address)",
                loanId,
                nftId,
                borrowAmount,
                collateralSentAmount,
                collateralTokenAddress
            )
        );
        if (!success) {
            if (data.length == 0) revert();
            assembly {
                revert(add(32, data), mload(data))
            }
        }
        loan = abi.decode(data, (CoreBase.Loan));
    }

    // function futureTrade(
    //     uint256 nftId,
    //     uint256 collateralSentAmount,
    //     address collateralTokenAddress,
    //     address swapTokenAddress,
    //     uint256 leverage,
    //     uint256 maxSlippage
    // ) external payable returns (CoreBase.Position memory position) {
    //     (bool success, bytes memory data) = poolBorrowingAddress.delegatecall(
    //         abi.encodeWithSignature(
    //             "futureTrade(uint256,uint256,address,address,uint256,uint256)",
    //             nftId,
    //             collateralSentAmount,
    //             collateralTokenAddress,
    //             swapTokenAddress,
    //             leverage,
    //             maxSlippage
    //         )
    //     );
    //     if (!success) {
    //         if (data.length == 0) revert();
    //         assembly {
    //             revert(add(32, data), mload(data))
    //         }
    //     }
    //     position = abi.decode(data, (CoreBase.Position));
    // }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

import "../../externalContract/openzeppelin/non-upgradeable/Ownable.sol";
import "../../externalContract/openzeppelin/non-upgradeable/IERC20.sol";
import "../../externalContract/openzeppelin/non-upgradeable/SafeERC20.sol";
import "../../externalContract/modify/non-upgradeable/SelectorPausable.sol";
import "../../externalContract/modify/non-upgradeable/Manager.sol";

import "./event/InterestVaultEvent.sol";

contract InterestVault is InterestVaultEvent, Ownable, SelectorPausable, Manager {
    using SafeERC20 for IERC20;

    // NOTE: manager is owner account, owner is pool
    uint256 public claimableTokenInterest;
    uint256 public heldTokenInterest;
    uint256 public actualTokenInterestProfit;
    uint256 public claimableForwInterest;
    uint256 public cumulativeTokenInterestProfit;

    address public tokenAddress;
    address public forwAddress;
    address public protocolAddress;

    modifier onlyProtocol() {
        require(msg.sender == protocolAddress, "InterestVault/permission-denied");
        _;
    }

    constructor(
        address _token,
        address _forw,
        address _protocol,
        address _manager
    ) {
        tokenAddress = _token;
        forwAddress = _forw;
        protocolAddress = _protocol;
        manager = _manager;
        _ownerApprove(msg.sender);

        emit SetTokenAddress(msg.sender, address(0), tokenAddress);
        emit SetForwAddress(msg.sender, address(0), forwAddress);
        emit SetProtocolAddress(msg.sender, address(0), protocolAddress);
        emit TransferManager(address(0), msg.sender);
    }

    // pause / unPause
    function pause(bytes4 _func) external onlyOwner {
        require(_func != bytes4(0), "InterestVault/msg.sig-func-is-zero");
        _pause(_func);
    }

    function unPause(bytes4 _func) external onlyOwner {
        require(_func != bytes4(0), "InterestVault/msg.sig-func-is-zero");
        _unpause(_func);
    }

    function setForwAddress(address _address) external onlyManager {
        address oldAddress = forwAddress;
        forwAddress = _address;

        emit SetForwAddress(msg.sender, oldAddress, tokenAddress);
    }

    function setTokenAddress(address _address) external onlyManager {
        address oldAddress = tokenAddress;
        tokenAddress = _address;

        emit SetTokenAddress(msg.sender, oldAddress, tokenAddress);
    }

    function setProtocolAddress(address _address) external onlyManager {
        address oldAddress = protocolAddress;
        protocolAddress = _address;

        emit SetProtocolAddress(msg.sender, oldAddress, protocolAddress);
    }

    /**
      @dev Function call by owner (APHPool) for allowing it to transfer token from InterestVault
     */
    function ownerApprove(address _pool) external onlyOwner {
        _ownerApprove(_pool);
    }

    /**
      @dev Function to settle value of claimable token interest, held token interest
            and claimable forw interest
            Called by APHCore (proxy)
     */
    function settleInterest(
        uint256 _claimableTokenInterest,
        uint256 _heldTokenInterest,
        uint256 _claimableForwInterest
    ) external onlyProtocol {
        _settleInterest(_claimableTokenInterest, _heldTokenInterest, _claimableForwInterest);
    }

    /**
      @dev Function to subtract token interest value, calculated from APHPool, and add actual profit
            Called by APHPool (proxy)
     */
    function withdrawTokenInterest(
        uint256 claimable,
        uint256 bonus,
        uint256 profit
    ) external onlyOwner {
        _withdrawTokenInterest(claimable, bonus, profit);
    }

    /**
      @dev Function to subtract forw interest value, calculated from APHPool
            Called by APHPool (proxy)
     */
    function withdrawForwInterest(uint256 claimAmount) external onlyOwner {
        _withdrawForwInterest(claimAmount);
    }

    /**
      @dev Function to withdraw token actual profit. Called by owner account
     */
    function withdrawActualProfit() external onlyManager returns (uint256) {
        return _withdrawActualProfit();
    }

    function getTotalTokenInterest() external view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function getTotalForwInterest() external view returns (uint256) {
        return IERC20(forwAddress).balanceOf(address(this));
    }

    // Internal
    // `receiver` is for later use (event)
    function _ownerApprove(address _pool) internal {
        uint256 approveAmount = type(uint256).max;
        IERC20(tokenAddress).safeApprove(_pool, approveAmount);
        IERC20(forwAddress).safeApprove(_pool, approveAmount);

        emit OwnerApprove(msg.sender, tokenAddress, forwAddress, approveAmount);
    }

    function _settleInterest(
        uint256 _claimableTokenInterest,
        uint256 _heldTokenInterest,
        uint256 _claimableForwInterest
    ) internal {
        claimableTokenInterest += _claimableTokenInterest;
        heldTokenInterest += _heldTokenInterest;
        claimableForwInterest += _claimableForwInterest;

        emit SettleInterest(
            msg.sender,
            claimableTokenInterest,
            heldTokenInterest,
            claimableForwInterest
        );
    }

    function _withdrawTokenInterest(
        uint256 claimable,
        uint256 bonus,
        uint256 profit
    ) internal {
        claimableTokenInterest -= claimable;
        heldTokenInterest -= bonus + profit;
        actualTokenInterestProfit += profit;
        cumulativeTokenInterestProfit += profit;

        emit WithdrawTokenInterest(msg.sender, claimable, bonus, profit);
    }

    function _withdrawForwInterest(uint256 claimable) internal {
        claimableForwInterest -= claimable;

        emit WithdrawForwInterest(msg.sender, claimable);
    }

    function _withdrawActualProfit() internal returns (uint256) {
        uint256 tempInterestProfit = actualTokenInterestProfit;
        actualTokenInterestProfit = 0;

        IERC20(tokenAddress).safeTransfer(manager, tempInterestProfit);

        emit WithdrawActualProfit(msg.sender, tempInterestProfit);
        return tempInterestProfit;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

import "../src/core/CoreBase.sol";

interface IAPHCore {
    function settleForwInterest() external;

    function settleBorrowInterest(uint256 loanId, uint256 nftId) external;

    // External functions
    function getLoan(uint256 nftId, uint256 loanId) external view returns (CoreBase.Loan memory);

    function getLoanExt(uint256 nftId, uint256 loanId)
        external
        view
        returns (CoreBase.LoanExt memory);

    function isPool(address poolAddess) external view returns (bool);

    function getLoanConfig(address _borrowTokenAddress, address _collateralTokenAddress)
        external
        view
        returns (CoreBase.LoanConfig memory);

    function getActiveLoans(
        uint256 nftId,
        uint256 start,
        uint256 stop
    ) external view returns (CoreBase.Loan[] memory);

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

    // function futureTrade(
    //     uint256 nftId,
    //     uint256 collateralSentAmount,
    //     address collateralTokenAddress,
    //     uint256 borrowAmount,
    //     address borrowTokenAddress,
    //     address swapTokenAddress,
    //     uint256 leverage,
    //     uint256 maxSlippage,
    //     bool isLong,
    //     uint256 newOwedPerDay
    // ) external returns (CoreBase.Position memory);

    // Getter functions
    function getLoanCurrentLTV(uint256 loanId, uint256 nftId) external view returns (uint256);

    function feeSpread() external view returns (uint256);

    function loanDuration() external view returns (uint256);

    function advancedInterestDuration() external view returns (uint256);

    function totalCollateralHold(address) external view returns (uint256);

    function poolStats(address) external view returns (CoreBase.PoolStat memory);

    function swapableToken(address) external view returns (bool);

    function poolToAsset(address) external view returns (address);

    function assetToPool(address) external view returns (address);

    function poolList(uint256) external view returns (address);

    function maxSwapSize() external view returns (uint256);

    function feesController() external view returns (address);

    function priceFeedAddress() external view returns (address);

    function routerAddress() external view returns (address);

    function forwDistributorAddress() external view returns (address);

    function membershipAddress() external view returns (address);

    function loans(uint256, uint256) external view returns (CoreBase.Loan memory);

    function loanExts(uint256, uint256) external view returns (CoreBase.LoanExt memory);

    function currentLoanIndex(uint256) external view returns (uint256);

    function loanConfigs(address, address) external view returns (CoreBase.LoanConfig memory);

    function forwDisPerBlock(address) external view returns (uint256);

    function lastSettleForw(address) external view returns (uint256);

    function isLoanLiquidable(uint256 nftId, uint256 loanId) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

import "../src/stakepool/StakePoolBase.sol";

interface IStakePool {
    // Getter functions

    function rankInfos(uint8) external view returns (StakePoolBase.RankInfo memory);

    function stakeInfos(uint256) external view returns (StakePoolBase.StakeInfo memory);

    // External functions

    function stake(uint256 nftId, uint256 amount) external returns (StakePoolBase.StakeInfo memory);

    function unstake(uint256 nftId, uint256 amount)
        external
        returns (StakePoolBase.StakeInfo memory);

    function setRankInfo(
        uint8[] memory _rank,
        uint256[] memory _interestBonusLending,
        uint256[] memory _forwardBonusLending,
        uint256[] memory _minimumstakeAmount,
        uint256[] memory _maxLTVBonus,
        uint256[] memory _tradingFee
    ) external;

    function setPoolStartTimestamp(uint64 timestamp) external;

    function settleInterval() external view returns (uint256);

    function settlePeriod() external view returns (uint256);

    function poolStartTimestamp() external view returns (uint64);

    function rankLen() external view returns (uint256);

    function getStakeInfo(uint256 nftId) external view returns (StakePoolBase.StakeInfo memory);

    function getMaxLTVBonus(uint256 nftId) external view returns (uint256);

    function deprecateStakeInfo(uint256 nftId) external;

    function migrate(uint256 nftId) external returns (StakePoolBase.StakeInfo memory);

    function setNextPool(address _address) external;

    function nextPoolAddress() external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

interface IInterestVault {
    function claimableTokenInterest() external view returns (uint256);

    function heldTokenInterest() external view returns (uint256);

    function actualTokenInterestProfit() external view returns (uint256);

    function claimableForwInterest() external view returns (uint256);

    function cumulativeTokenInterestProfit() external view returns (uint256);

    function tokenAddress() external view returns (address);

    function forwAddress() external view returns (address);

    function protocolAddress() external view returns (address);

    function getTotalTokenInterest() external view returns (uint256);

    function getTotalForwInterest() external view returns (uint256);

    // exclusive functions
    function pause(bytes4 _func) external;

    function unPause(bytes4 _func) external;

    function setForwAddress(address _address) external;

    function setTokenAddress(address _address) external;

    function setProtocolAddress(address _address) external;

    function ownerApprove(address _pool) external;

    function settleInterest(
        uint256 _claimableTokenInterest,
        uint256 _heldTokenInterest,
        uint256 _claimableForwInterest
    ) external;

    function withdrawTokenInterest(
        uint256 claimable,
        uint256 bonus,
        uint256 profit
    ) external;

    function withdrawForwInterest(uint256 claimable) external;

    function withdrawActualProfit(address receiver) external returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

import "../externalContract/openzeppelin/non-upgradeable/IERC721Enumerable.sol";

interface IMembership is IERC721Enumerable {
    // External functions

    function getDefaultMembership(address owner) external view returns (uint256);

    function setDefaultMembership(uint256 tokenId) external;

    // function setNewPool(address newPool) external;

    function getPoolLists() external view returns (address[] memory);

    function mint() external returns (uint256);

    // function setBaseURI(string memory baseTokenURI) external;

    function updateRank(uint256 tokenId, uint8 newRank) external;

    function usableTokenId(address owner, uint256 tokenId) external view returns (uint256);

    function getRank(uint256 tokenId) external view returns (uint8);

    function getRank(address pool, uint256 tokenId) external view returns (uint8);

    function currentPool() external view returns (address);

    function ownerOf(uint256) external view override returns (address);

    function getPreviousPool() external view returns (address);

    function setNewPool(address newPool) external;
}

// SPDX-License-Identifier: GPL-3.0
/**
 * Copyright 2017-2021, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.8.14;

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

    // function checkPriceDisagreement(
    //     address sourceToken,
    //     address destToken,
    //     uint256 sourceAmount,
    //     uint256 destAmount,
    //     uint256 maxSlippage
    // ) external view returns (uint256 sourceToDestSwapRate);

    function amountInEth(address Token, uint256 amount) external view returns (uint256 ethAmount);

    function queryRateUSD(address token) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

import "../../externalContract/openzeppelin/upgradeable/MathUpgradeable.sol";
import "../../externalContract/openzeppelin/upgradeable/AddressUpgradeable.sol";
import "../../externalContract/openzeppelin/upgradeable/ReentrancyGuardUpgradeable.sol";
import "../../externalContract/modify/upgradeable/SelectorPausableUpgradeable.sol";
import "../../externalContract/modify/upgradeable/AssetHandlerUpgradeable.sol";
import "../../externalContract/modify/upgradeable/ManagerUpgradeable.sol";

contract PoolBase is
    AssetHandlerUpgradeable,
    ManagerUpgradeable,
    ReentrancyGuardUpgradeable,
    SelectorPausableUpgradeable
{
    struct Lend {
        uint8 rank;
        uint64 updatedTimestamp;
    }

    struct WithdrawResult {
        uint256 principle;
        uint256 tokenInterest;
        uint256 forwInterest;
        uint256 pTokenBurn;
        uint256 itpTokenBurn;
        uint256 ifpTokenBurn;
        uint256 tokenInterestBonus;
        uint256 forwInterestBonus;
    }

    uint256 internal WEI_UNIT; //               // 1e18
    uint256 internal WEI_PERCENT_UNIT; //       // 1e20 (100*1e18 for calculating percent)
    uint256 public BLOCK_TIME; //               // time between each block in seconds

    address public poolLendingAddress; //       // address of pool lending logic contract
    address public poolBorrowingAddress; //     // address of pool borrowing logic contract
    address public forwAddress; //              // forw token's address
    address public membershipAddress; //        // address of membership contract
    address public interestVaultAddress; //     // address of interestVault contract
    address public tokenAddress; //             // address of token which pool allows to lend
    address public coreAddress; //              // address of APHCore contract
    mapping(uint256 => Lend) public lenders; // // map nftId => rank

    uint256 internal initialItpPrice;
    uint256 internal initialIfpPrice;

    // borrowing interest params
    uint256 public lambda; //                   // constant use for weight forw token in iftPrice

    uint256 public targetSupply; //             // weighting factor to proportional reduce utilOptimse vaule if total lending is less than targetSupply

    uint256[10] public rates; //                // list of target interest rate at each util
    uint256[10] public utils; //                // list of utilization rate to which each rate reached
    uint256 public utilsLen; //                 // length of current active rates and utils (both must be equl)

    // Allocating __gap for futhur variable (need to subtract equal to new state added)
    uint256[50] private __gap_poolBase;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

import "../../externalContract/openzeppelin/upgradeable/MathUpgradeable.sol";

contract PoolToken {
    struct PoolTokens {
        uint256 pToken;
        uint256 itpToken;
        uint256 ifpToken;
    }

    uint256 public pTokenTotalSupply; //                // token represent principal lent to APHPool
    uint256 public itpTokenTotalSupply; //              // token represent printipal (same as pToken) + interest (claimable token interest in InterestVault)
    uint256 public ifpTokenTotalSupply; //              // token represent printipal (same as pToken) + interest (claimable forw interest in InterestVault)
    mapping(uint256 => PoolTokens) public tokenHolders; // map nftId -> struct

    // Allocating __gap for futhur variable (need to subtract equal to new state added)
    uint256[10] private __gap_poolToken;

    event MintPToken(address indexed minter, uint256 indexed nftId, uint256 amount);
    event MintItpToken(
        address indexed minter,
        uint256 indexed nftId,
        uint256 amount,
        uint256 price
    );
    event MintIfpToken(
        address indexed minter,
        uint256 indexed nftId,
        uint256 amount,
        uint256 price
    );

    event BurnPToken(address indexed burner, uint256 indexed nftId, uint256 amount);
    event BurnItpToken(
        address indexed burner,
        uint256 indexed nftId,
        uint256 amount,
        uint256 price
    );
    event BurnIfpToken(
        address indexed burner,
        uint256 indexed nftId,
        uint256 amount,
        uint256 price
    );

    // external function
    /**
      @dev Returns pToken's balance of the given nftId
     */
    function balancePTokenOf(uint256 nftId) external view returns (uint256) {
        return tokenHolders[nftId].pToken;
    }

    /**
      @dev Returns itpToken's balance of the given nftId
     */
    function balanceItpTokenOf(uint256 nftId) external view returns (uint256) {
        return tokenHolders[nftId].itpToken;
    }

    /**
      @dev Returns ifpToken's balance of the given nftId
     */
    function balanceIfpTokenOf(uint256 nftId) external view returns (uint256) {
        return tokenHolders[nftId].ifpToken;
    }

    // internal function
    function _mintPToken(
        address receiver,
        uint256 nftId,
        uint256 mintAmount
    ) internal returns (uint256) {
        pTokenTotalSupply += mintAmount;
        tokenHolders[nftId].pToken += mintAmount;

        emit MintPToken(receiver, nftId, mintAmount);
        return mintAmount;
    }

    function _mintItpToken(
        address receiver,
        uint256 nftId,
        uint256 mintAmount,
        uint256 price
    ) internal returns (uint256) {
        itpTokenTotalSupply += mintAmount;
        tokenHolders[nftId].itpToken += mintAmount;

        emit MintItpToken(receiver, nftId, mintAmount, price);
        return mintAmount;
    }

    function _mintIfpToken(
        address receiver,
        uint256 nftId,
        uint256 mintAmount,
        uint256 price
    ) internal returns (uint256) {
        ifpTokenTotalSupply += mintAmount;
        tokenHolders[nftId].ifpToken += mintAmount;

        emit MintIfpToken(receiver, nftId, mintAmount, price);
        return mintAmount;
    }

    function _burnPToken(
        address burner,
        uint256 nftId,
        uint256 burnAmount
    ) internal returns (uint256) {
        pTokenTotalSupply -= burnAmount;
        tokenHolders[nftId].pToken -= burnAmount;

        emit BurnPToken(burner, nftId, burnAmount);
        return burnAmount;
    }

    function _burnItpToken(
        address burner,
        uint256 nftId,
        uint256 burnAmount,
        uint256 price
    ) internal returns (uint256) {
        burnAmount = MathUpgradeable.min(burnAmount, tokenHolders[nftId].itpToken);

        itpTokenTotalSupply -= burnAmount;
        tokenHolders[nftId].itpToken -= burnAmount;

        emit BurnItpToken(burner, nftId, burnAmount, price);
        return burnAmount;
    }

    function _burnIfpToken(
        address burner,
        uint256 nftId,
        uint256 burnAmount,
        uint256 price
    ) internal returns (uint256) {
        burnAmount = MathUpgradeable.min(burnAmount, tokenHolders[nftId].ifpToken);

        ifpTokenTotalSupply -= burnAmount;
        tokenHolders[nftId].ifpToken -= burnAmount;

        emit BurnIfpToken(burner, nftId, burnAmount, price);
        return burnAmount;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

import "../../externalContract/openzeppelin/upgradeable/ReentrancyGuardUpgradeable.sol";
import "../../externalContract/openzeppelin/upgradeable/MathUpgradeable.sol";
import "../../externalContract/modify/upgradeable/SelectorPausableUpgradeable.sol";
import "../../externalContract/modify/upgradeable/AssetHandlerUpgradeable.sol";
import "../../externalContract/modify/upgradeable/ManagerUpgradeable.sol";

import "../../interfaces/IAPHPool.sol";
import "../../interfaces/IInterestVault.sol";
import "../../interfaces/IMembership.sol";
import "../../interfaces/IPriceFeed.sol";
import "../../interfaces/IRouter.sol";
import "../../interfaces/IStakePool.sol";

contract CoreBase is
    AssetHandlerUpgradeable,
    ManagerUpgradeable,
    ReentrancyGuardUpgradeable,
    SelectorPausableUpgradeable
{
    struct NextForwDisPerBlock {
        uint256 amount;
        uint256 targetBlock;
    }
    struct Loan {
        address borrowTokenAddress;
        address collateralTokenAddress;
        uint256 borrowAmount;
        uint256 collateralAmount;
        uint256 owedPerDay;
        uint256 minInterest;
        uint256 interestOwed;
        uint256 interestPaid;
        uint256 bountyFee;
        uint64 rolloverTimestamp;
        uint64 lastSettleTimestamp;
    }

    struct LoanExt {
        bool active;
        uint64 startTimestamp;
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

    // struct Position {
    //     address swapTokenAddress;
    //     address borrowTokenAddress;
    //     address collateralTokenAddress;
    //     uint256 borrowAmount;
    //     uint256 collateralAmount;
    //     uint256 positionSize; // contract size after swapped
    //     uint256 inititalMargin;
    //     uint256 owedPerDay;
    //     uint256 interestOwed;
    //     uint256 interestPaid;
    //     uint64 lastSettleTimestamp;
    // }
    // struct PositionExt {
    //     bool active;
    //     bool long;
    //     bool short;
    //     uint64 startTimestamp;
    //     uint256 initialBorrowTokenPrice; // need?
    //     uint256 initialCollateralTokenPrice; // need?
    // }

    // struct PositionConfig {
    //     address borrowTokenAddress;
    //     address collateralTokenAddress;
    //     uint256 maxLeverage;
    //     uint256 maintenanceMargin;
    //     uint256 bountyFeeRate; // liquidation fee
    // }

    struct PoolStat {
        uint64 updatedTimestamp;
        uint256 totalBorrowAmount;
        uint256 borrowInterestOwedPerDay;
        uint256 totalInterestPaid;
    }

    // constant
    uint256 internal WEI_UNIT; //                                                           // 1e18
    uint256 internal WEI_PERCENT_UNIT; //                                                   // 1e20 (100*1e18 for calculating percent)

    // lending
    uint256 public feeSpread; //                                                            // spread for borrowing interest to lending interest                                                    // fee taken from lender interest payments (fee when protocol settles interest to pool)

    // borrowing
    uint256 public loanDuration; //                                                         // max days for borrowing with fix rate interest
    uint256 public advancedInterestDuration; //                                             // duration for calculating minimum interest
    mapping(address => mapping(address => LoanConfig)) public loanConfigs; //               // borrowToken => collateralToken => config
    mapping(uint256 => uint256) public currentLoanIndex; //                                 // nftId => currentLoanIndex
    mapping(uint256 => mapping(uint256 => Loan)) public loans; //                           // nftId => loanId => loan
    mapping(uint256 => mapping(uint256 => LoanExt)) public loanExts; //                     // nftId => loanId => loanExt (extension data)

    // futureTrading
    // uint256 public tradingFees; //                                                          // fee collect when use open or close position
    // mapping(address => mapping(address => PositionConfig)) public positionConfigs; //       // borrowToken => collateralToken => config
    // mapping(uint256 => uint256) public currentPositionIndex; //                             // nftId => currentPositionIndex
    // mapping(uint256 => mapping(uint256 => Position)) public positions; //                   // nftId => positionId => position
    // mapping(uint256 => mapping(uint256 => PositionExt)) public positionExts; //             // nftId => positionId => positionExt (extension data)

    // stat
    mapping(address => uint256) public totalCollateralHold; //                              // tokenAddress => total collateral amount
    mapping(address => PoolStat) public poolStats; //                                       // pool's address => borrowStat
    mapping(address => bool) public swapableToken; //                                       // check that token is allowed for swap
    mapping(address => address) public poolToAsset; //                                      // pool => underlying (token address)
    mapping(address => address) public assetToPool; //                                      // underlying => pool
    address[] public poolList; //                                                           // list of pool

    // forw distributor
    mapping(address => uint256) public forwDisPerBlock; //                                  // pool => forw distribute per block
    mapping(address => uint256) public lastSettleForw; //                                   // pool => lastest settle forward by pool
    mapping(address => NextForwDisPerBlock) public nextForwDisPerBlock; //                  // pool => next forw distribute per block

    uint256 public maxSwapSize; //                                                          // maximum supported swap size in ETH

    address public forwDistributorAddress; //                                               // address of vault which stores forw token for distribution
    address public forwAddress; //                                                          // forw token's address
    address public feesController; //                                                       // address target for withdrawing collected fees
    address public priceFeedAddress; //                                                     // address of price feed contract
    address public routerAddress; //                                                        // address of DEX contract
    address public membershipAddress; //                                                    // address of membership contract

    address public coreBorrowingAddress; //                                                 // address of borrowing logic contract

    // Allocating __gap for futhur variable (need to subtract equal to new state added)
    uint256[50] private __gap_coreBase;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "./InitializableUpgradeable.sol";

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
abstract contract ReentrancyGuardUpgradeable is InitializableUpgradeable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../../openzeppelin/upgradeable/ContextUpgradeable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract SelectorPausableUpgradeable is ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account` and `function selector`.
     */
    event Paused(address account, bytes4 functionSelector);

    /**
     * @dev Emitted when the pause is lifted by `account` and `function selector`.
     */
    event Unpaused(address account, bytes4 functionSelector);

    mapping(bytes4 => bool) private _isPaused;

    // Allocating __gap for futhur variable (need to subtract equal to new state added)
    uint256[10] private __gap_selectorPausable;

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

pragma solidity 0.8.14;

import "../../../interfaces/IWethERC20.sol";
import "../../../interfaces/IWethHandler.sol";
import "../../openzeppelin/upgradeable/InitializableUpgradeable.sol";
import "../../openzeppelin/non-upgradeable/SafeERC20.sol";

contract AssetHandlerUpgradeable is InitializableUpgradeable {
    using SafeERC20 for IERC20;
    using SafeERC20 for IWethERC20;
    address public wethAddress;
    address public wethHandler;

    // Allocating __gap for futhur variable (need to subtract equal to new state added)
    uint256[10] private __gap_AssetHandler;

    function __AssetHandler_init_unchained(address _wethAddress, address _wethHandler)
        internal
        onlyInitializing
    {
        wethAddress = _wethAddress;
        wethHandler = _wethHandler;
    }

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
            IWethERC20(wethAddress).safeTransfer(to, amount);
        } else {
            IERC20(token).safeTransferFrom(from, to, amount);
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
            IWethERC20(wethAddress).safeTransferFrom(from, wethHandler, amount);
            IWethHandler(payable(wethHandler)).withdrawETH(to, amount);
        } else {
            IERC20(token).safeTransferFrom(from, to, amount);
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
            IWethERC20(wethAddress).safeTransfer(wethHandler, amount);
            IWethHandler(payable(wethHandler)).withdrawETH(to, amount);
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
import "../../openzeppelin/upgradeable/ContextUpgradeable.sol";

pragma solidity 0.8.14;

contract ManagerUpgradeable {
    address internal manager;

    // Allocating __gap for futhur variable (need to subtract equal to new state added)
    uint256[10] private __gap_manager;

    event TransferManager(address, address);

    constructor() {}

    modifier onlyManager() {
        _onlyManager();
        _;
    }

    function getManager() external view returns (address) {
        return manager;
    }

    function _onlyManager() internal view {
        require(manager == msg.sender, "Manager/caller-is-not-the-manager");
    }

    function transferManager(address _address) public virtual onlyManager {
        require(_address != address(0), "Manager/new-manager-is-the-zero-address");
        _transferManager(_address);
    }

    function _transferManager(address _address) internal virtual {
        address oldManager = manager;
        manager = _address;
        emit TransferManager(oldManager, _address);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

import "../src/pool/PoolBase.sol";
import "../src/core/CoreBase.sol";

interface IAPHPool {
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

    // function futureTrade(
    //     uint256 nftId,
    //     uint256 collateralSentAmount,
    //     address collateralTokenAddress,
    //     address swapTokenAddress,
    //     uint256 leverage,
    //     uint256 maxSlippage
    // ) external payable returns (CoreBase.Position memory);

    /**
     * @dev Set the rank in APHPool to equal the user's NFT rank
     * @param nftId The user's nft tokenId is used to activate the new rank
     * @return The new rank from user's nft
     */
    function activateRank(uint256 nftId) external returns (uint8);

    function getNextLendingInterest(uint256 depositAmount) external view returns (uint256);

    function getNextLendingForwInterest(uint256 depositAmount) external view returns (uint256);

    function getNextBorrowingInterest(uint256 borrowAmount) external view returns (uint256);

    /**
     * @dev Get interestRate and interestOwedPerDay from new borrow amount
     * @param borrowAmount The 'amount' of token borrow
     * @return The interestRate and interestOwedPerDay
     */
    function calculateInterest(uint256 borrowAmount) external view returns (uint256, uint256);

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
     * @dev Get current supply of the asset token in the pool
     * @return The 'amount' of asset token in the pool
     */
    function currentSupply() external view returns (uint256);

    function utilizationRate() external view returns (uint256);

    function membershipAddress() external view returns (address);

    function interestVaultAddress() external view returns (address);

    function forwAddress() external view returns (address);

    function tokenAddress() external view returns (address);

    function stakePoolAddress() external view returns (address);

    function coreAddress() external view returns (address);

    function utils(uint256) external view returns (uint256);

    function rates(uint256) external view returns (uint256);

    function utilsLen() external view returns (uint256);

    function targetSupply() external view returns (uint256);

    // from PoolToken
    function balancePTokenOf(uint256 NFTId) external view returns (uint256);

    function balanceItpTokenOf(uint256 NFTId) external view returns (uint256);

    function balanceIfpTokenOf(uint256 NFTId) external view returns (uint256);

    function pTokenTotalSupply() external view returns (uint256);

    function itpTokenTotalSupply() external view returns (uint256);

    function ifpTokenTotalSupply() external view returns (uint256);

    function lenders(uint256 NFTId) external view returns (uint8, uint64);

    function claimableInterest(uint256 nftId)
        external
        view
        returns (uint256 tokenInterest, uint256 forwInterest);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

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

    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "./AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract InitializableUpgradeable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
import "./InitializableUpgradeable.sol";

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
abstract contract ContextUpgradeable is InitializableUpgradeable {
    function __Context_init() internal onlyInitializing {}

    function __Context_init_unchained() internal onlyInitializing {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

import "./IWeth.sol";
import "../externalContract/openzeppelin/non-upgradeable/IERC20.sol";

interface IWethERC20 is IWeth, IERC20 {}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

interface IWethHandler {
    function withdrawETH(address to, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
            );
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

interface IWeth {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
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

pragma solidity 0.8.14;

import "../../externalContract/openzeppelin/non-upgradeable/Ownable.sol";
import "../../externalContract/openzeppelin/non-upgradeable/ReentrancyGuard.sol";
import "../../externalContract/modify/non-upgradeable/SelectorPausable.sol";
import "../../externalContract/modify/non-upgradeable/AssetHandler.sol";

contract StakePoolBase is AssetHandler, Ownable, ReentrancyGuard, SelectorPausable {
    struct StakeInfo {
        uint256 stakeBalance; //                                 // Staking forw token amount
        uint256 claimableAmount; //                              // Claimable forw token amount
        uint64 startTimestamp; //                                // Timestamo that user start staking
        uint64 endTimestamp; //                                  // Timestamp that user can withdraw all staking balance
        uint64 lastSettleTimestamp; //                           // Timestamp that represent a lastest update claimable amount of each user
        uint256[] payPattern; //                                 // Part of nft stakeInfo for record withdrawable of user that pass each a quater of settlePeriod
    }

    struct RankInfo {
        uint256 interestBonusLending; //                          // Bonus of lending of each membership tier (lending token bonus)
        uint256 forwardBonusLending; //                           // Bonus of lending of each membership tier (FORW token bonus)
        uint256 minimumStakeAmount; //                            // Minimum forw token staking to claim this rank
        uint256 maxLTVBonus; //                                   // Addition LTV which added during borrowing token
        uint256 tradingFee; //                                    // Trading Fee in future trading
    }

    address public membershipAddress; //                         // Address of membership contract
    address public nextPoolAddress; //                           // Address of new migration stakpool
    address public stakeVaultAddress; //                         // Address of stake vault that use for collect a staking FORW token
    address public forwAddress; //                               // Address of FORW token
    uint8 public rankLen; //                                     // Number of membership rank
    uint64 public poolStartTimestamp; //                         // Timestamp that record poolstart time use for calculate withdrawable balance
    uint256 public settleInterval; //                            // Duration that stake pool allow sender to withdraw a quarter of staking balance
    uint256 public settlePeriod; //                              // Period that stake pool allow sender to withdraw all staking balance
    mapping(uint256 => StakeInfo) public stakeInfos; //          // Object that represent a status of staking of user
    mapping(uint8 => RankInfo) public rankInfos; //              // Represent array of a tier of membership mapping minimum staking balance
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../../openzeppelin/non-upgradeable/Context.sol";

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

pragma solidity 0.8.14;

import "../../../interfaces/IWethERC20.sol";
import "../../../interfaces/IWethHandler.sol";
import "../../openzeppelin/non-upgradeable/IERC20.sol";
import "../../openzeppelin/non-upgradeable/Initializable.sol";
import "../../openzeppelin/non-upgradeable/SafeERC20.sol";

contract AssetHandler is Initializable {
    using SafeERC20 for IERC20;
    using SafeERC20 for IWethERC20;
    address public wethAddress;
    address public wethHandler;

    function __AssetHandler_init_unchained(address _wethAddress, address _wethHandler)
        internal
        onlyInitializing
    {
        wethAddress = _wethAddress;
        wethHandler = _wethHandler;
    }

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
            IWethERC20(wethAddress).safeTransfer(to, amount);
        } else {
            IERC20(token).safeTransferFrom(from, to, amount);
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
            IWethERC20(wethAddress).safeTransferFrom(from, wethHandler, amount);
            IWethHandler(payable(wethHandler)).withdrawETH(to, amount);
        } else {
            IERC20(token).safeTransferFrom(from, to, amount);
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
            IWethERC20(wethAddress).safeTransfer(wethHandler, amount);
            IWethHandler(payable(wethHandler)).withdrawETH(to, amount);
        } else {
            IERC20(token).safeTransfer(to, amount);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../non-upgradeable/Address.sol";

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

contract PoolSettingEvent {
    event SetBorrowInterestParams(
        address indexed sender,
        uint256[] rates,
        uint256[] utils,
        uint256 targetSupply
    );

    event SetLoanConfig(
        address indexed sender,
        address collateralTokenAddress,
        uint256 safeLTV,
        uint256 maxLTV,
        uint256 liqLTV,
        uint256 bountyFeeRate
    );

    event SetPoolLendingAddress(address indexed sender, address oldValue, address newValue);

    event SetPoolBorrowingAddress(address indexed sender, address oldValue, address newValue);

    event SetMembershipAddress(address indexed sender, address oldValue, address newValue);

    event Initialize(
        address indexed manager,
        address indexed coreAddress,
        address interestVaultAddress,
        address membershipAddress
    );

    event SetWETHHandler(address indexed sender, address oldValue, address newValue);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

interface IAPHCoreSetting {
    // External functions

    function setupLoanConfig(
        address borrowTokenAddress,
        address collateralTokenAddress,
        uint256 newSafeLTV,
        uint256 newMaxLTV,
        uint256 newLiquidationLTV,
        uint256 newBountyFeeRate
    ) external;

    function setMembershipAddress(address _address) external;

    function setPriceFeedAddress(address _address) external;

    function setForwDistributorAddress(address _address) external;

    function setRouterAddress(address _address) external;

    function setCoreBorrowingAddress(address _address) external;

    function setFeeController(address _address) external;

    function setWETHAddress(address _address) external;

    function setWETHHandler(address _address) external;

    function setLoanDuration(uint256 _value) external;

    function setAdvancedInterestDuration(uint256 _value) external;

    function setFeeSpread(uint256 _value) external;

    function registerNewPool(
        address poolAddress,
        uint256 amount,
        uint256 targetBlock
    ) external;

    function setForwDisPerBlock(
        address poolAddress,
        uint256 amount,
        uint256 targetBlock
    ) external;

    function approveForRouter(address _assetAddress) external;
}

// SPDX-License-Identifier: GPL-3.0
import "../../openzeppelin/non-upgradeable/Context.sol";

pragma solidity 0.8.14;

contract Manager {
    address internal manager;

    event TransferManager(address, address);

    constructor() {}

    modifier onlyManager() {
        _onlyManager();
        _;
    }

    function getManager() external view returns (address) {
        return manager;
    }

    function _onlyManager() internal view {
        require(manager == msg.sender, "Manager/caller-is-not-the-manager");
    }

    function transferManager(address _address) public virtual onlyManager {
        require(_address != address(0), "Manager/new-manager-is-the-zero-address");
        _transferManager(_address);
    }

    function _transferManager(address _address) internal virtual {
        address oldManager = manager;
        manager = _address;
        emit TransferManager(oldManager, _address);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

contract InterestVaultEvent {
    event SetTokenAddress(address indexed sender, address oldValue, address newValue);
    event SetForwAddress(address indexed sender, address oldValue, address newValue);
    event SetProtocolAddress(address indexed sender, address oldValue, address newValue);

    event OwnerApprove(
        address indexed sender,
        address tokenAddress,
        address forwAddress,
        uint256 amount
    );

    event SettleInterest(
        address indexed sender,
        uint256 claimableTokenInterest,
        uint256 heldTokenInterest,
        uint256 claimableForwInterest
    );

    event WithdrawTokenInterest(
        address indexed sender,
        uint256 claimable,
        uint256 bonus,
        uint256 profit
    );

    event WithdrawForwInterest(address indexed sender, uint256 claimable);

    event WithdrawActualProfit(address indexed sender, uint256 profitWithdraw);
}