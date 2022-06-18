//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../interfaces/IRouter.sol";
import "../interfaces/IPresale.sol";
import "../interfaces/IPresaleFactory.sol";
import "../interfaces/IStaking.sol";
import "../pancake-swap/libraries/TransferHelper.sol";

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract PresalePrivateTest is Context, ReentrancyGuard, IPresalePrivate {
    uint256 private constant DENOMINATOR = 100;

    IPresaleFactory public immutable FACTORY;
    IRouter public immutable DEX;
    address public immutable BUSD;

    PresaleInfo public generalInfo;
    VestingInfo public vestingInfo;
    PresaleDexInfo public dexInfo;
    IntermediateVariables public intermediate;

    uint256 private tokenMagnitude;

    mapping(address => bool) public whitelist;
    mapping(address => Investment) public investments; // total wei invested per address

    struct IntermediateVariables {
        bool initialized;
        bool withdrawedFunds;
        address lpAddress;
        uint256 usdToLiq;
        uint256 lpUnlockTime;
        uint256 tokensForSaleLeft;
        uint256 tokensForLiquidityLeft;
        uint256 raisedAmount;
    }

    struct Investment {
        uint256 amountEth;
        uint256 amountTokens;
        uint256 amountClaimed;
    }

    modifier timing() {
        require(
            generalInfo.closeTime > block.timestamp &&
                block.timestamp >= generalInfo.openTime,
            "TIME"
        );
        _;
    }

    modifier liquidityAdded() {
        require(intermediate.lpAddress != address(0), "LIQ");
        _;
    }

    modifier onlyPresaleCreator() {
        require(_msgSender() == generalInfo.creator, "CREATOR");
        _;
    }

    modifier notCreator() {
        require(_msgSender() != generalInfo.creator, "NOT CREATOR");
        _;
    }

    modifier initialized() {
        require(intermediate.initialized, "INIT");
        _;
    }

    constructor(
        address factory,
        address busd,
        address dex
    ) {
        require(
            factory != address(0) && busd != address(0) && dex != address(0),
            "Address 0x0..."
        );

        FACTORY = IPresaleFactory(factory);
        BUSD = busd;
        DEX = IRouter(dex);
    }

    /** @dev Function to activate presale and send tokens
     * @notice Factory only
     */
    function initialize(
        PresaleInfo memory _info,
        PresaleDexInfo memory _dexInfo,
        VestingInfo memory _vestInfo,
        address[] memory _whitelist
    ) external override {
        require(_msgSender() == address(FACTORY), "Only factory");
        require(!intermediate.initialized, "ONCE");
        intermediate.initialized = true;

        tokenMagnitude = 10**IERC20Metadata(_info.tokenAddress).decimals();

        intermediate.tokensForSaleLeft =
            (_info.hardCap * tokenMagnitude) /
            _info.tokenPrice;
        intermediate.tokensForLiquidityLeft =
            (_info.hardCap *
                _dexInfo.liquidityPercentageAllocation *
                tokenMagnitude) /
            (DENOMINATOR * _dexInfo.listingPrice);

        generalInfo = _info;
        dexInfo = _dexInfo;
        vestingInfo = _vestInfo;

        address user;
        for (uint256 i; i < _whitelist.length; i++) {
            user = _whitelist[i];
            if (user != generalInfo.creator && user != address(0))
                whitelist[user] = true;
        }
    }

    /** @dev Function to add/remove addresses in/from whitelist
     * @notice Creator only
     */
    function addOrRemoveParticipants(address[] memory users)
        external
        onlyPresaleCreator
    {
        require(block.timestamp < generalInfo.openTime, "TIME");
        require(users.length > 0, "WRONG PARAM");
        for (uint256 i; i < users.length; i++)
            whitelist[users[i]] = !whitelist[users[i]];
    }

    /** @dev Funtion to invest (send BUSD and buy sale tokens)
     * @notice Whitelisted only
     * @param payAmount amount of BUSD that you invest
     */
    function invest(uint256 payAmount)
        external
        timing
        nonReentrant
        initialized
        notCreator
    {
        address sender = _msgSender();
        require(payAmount > 0 && whitelist[sender], "WRONG PARAMS");
        Investment storage investor = investments[sender];

        uint256 investmentFee;
        (address receiver, uint256 feePercent) = FACTORY.getFeeParams();
        if (feePercent > 0) {
            investmentFee = (payAmount * feePercent) / DENOMINATOR;
        }

        uint256 tokenAmount = _getTokenAmount(payAmount);

        require(
            intermediate.tokensForSaleLeft >= tokenAmount && tokenAmount > 0,
            "WRONG TOKEN AMOUNT"
        );

        intermediate.tokensForSaleLeft -= tokenAmount;
        investor.amountEth += payAmount;
        investor.amountTokens += tokenAmount;
        intermediate.raisedAmount += payAmount;

        if (
            intermediate.raisedAmount == generalInfo.hardCap ||
            intermediate.tokensForSaleLeft == 0
        ) _closePresale();

        TransferHelper.safeTransferFrom(BUSD, sender, address(this), payAmount);

        if (investmentFee > 0) {
            TransferHelper.safeTransferFrom(
                BUSD,
                sender,
                receiver,
                investmentFee
            );
        }
    }

    /** @dev Function to add liquidity in paymentToken-saleToken pair
     * @notice Creator only
     */
    function addLiquidity()
        external
        nonReentrant
        onlyPresaleCreator
        initialized
    {
        uint256 currentTime = block.timestamp;
        require(
            intermediate.raisedAmount >= generalInfo.softCap &&
                currentTime >= dexInfo.liquidityAllocationTime,
            "TIME/SOFTCAP"
        );

        IFactory factory = IFactory(DEX.factory());

        uint256 paymentAmount = (intermediate.raisedAmount *
            dexInfo.liquidityPercentageAllocation) / DENOMINATOR;
        uint256 tokenAmount = (paymentAmount * tokenMagnitude) /
            dexInfo.listingPrice;
        require(
            paymentAmount > 0 &&
                tokenAmount <= intermediate.tokensForLiquidityLeft,
            "WRONG PAYMENT/TOKEN AMOUNT"
        );

        TransferHelper.safeApprove(
            generalInfo.tokenAddress,
            address(DEX),
            tokenAmount
        );

        uint256 amountEth;
        uint256 amountToken;

        intermediate.lpUnlockTime =
            currentTime +
            dexInfo.lpTokensLockDurationInDays *
            1 minutes;

        TransferHelper.safeApprove(BUSD, address(DEX), paymentAmount);

        (amountEth, amountToken, ) = DEX.addLiquidity(
            BUSD,
            generalInfo.tokenAddress,
            paymentAmount,
            tokenAmount,
            0,
            0,
            address(this),
            currentTime
        );

        intermediate.lpAddress = factory.getPair(
            BUSD,
            generalInfo.tokenAddress
        );

        intermediate.usdToLiq = amountEth;
        intermediate.raisedAmount -= amountEth;
        intermediate.tokensForLiquidityLeft -= amountToken;
    }

    /** @dev Function to claim sale tokens
     * @notice Investor only
     */
    function claimTokens()
        external
        nonReentrant
        liquidityAdded
        initialized
        notCreator
    {
        address sender = _msgSender();
        Investment storage investor = investments[sender];
        require(
            investor.amountTokens > 0 &&
                investor.amountClaimed < investor.amountTokens,
            "NTHNG 2 CLAIM"
        );

        if (vestingInfo.vestingPerc1 == DENOMINATOR) {
            investor.amountClaimed = investor.amountTokens;
            TransferHelper.safeTransfer(
                generalInfo.tokenAddress,
                sender,
                investor.amountTokens
            );
        } else {
            uint256 amount = (investor.amountTokens *
                vestingInfo.vestingPerc1) / DENOMINATOR;
            uint256 beginingTime = intermediate.lpUnlockTime -
                dexInfo.lpTokensLockDurationInDays *
                1 minutes;
            uint256 numOfParts = (block.timestamp - beginingTime) /
                vestingInfo.vestingPeriod;
            uint256 part = (investor.amountTokens * vestingInfo.vestingPerc2) /
                DENOMINATOR;

            amount += numOfParts * part;
            amount -= investor.amountClaimed;
            require(amount > 0, "0");
            if (amount + investor.amountClaimed > investor.amountTokens)
                amount = investor.amountTokens - investor.amountClaimed;
            investor.amountClaimed += amount;

            TransferHelper.safeTransfer(
                generalInfo.tokenAddress,
                sender,
                amount
            );
        }
    }

    /** @dev Function to claim earning funds
     * @notice Creator only
     */
    function claimRaisedFunds()
        external
        nonReentrant
        onlyPresaleCreator
        liquidityAdded
        initialized
    {
        require(!intermediate.withdrawedFunds, "WITHDRAWED");
        intermediate.withdrawedFunds = true;

        address sender = _msgSender();
        uint256 unsoldTokensAmount = intermediate.tokensForSaleLeft +
            intermediate.tokensForLiquidityLeft;

        if (unsoldTokensAmount > 0) {
            TransferHelper.safeTransfer(
                generalInfo.tokenAddress,
                generalInfo.unsoldTokenToAddress,
                unsoldTokensAmount
            );
        }

        TransferHelper.safeTransfer(BUSD, sender, intermediate.raisedAmount);
    }

    /** @dev Function to claim LP-tokens
     * @notice Creator only
     */
    function claimLps()
        external
        nonReentrant
        onlyPresaleCreator
        liquidityAdded
    {
        uint256 amount = IERC20(intermediate.lpAddress).balanceOf(
            address(this)
        );
        require(
            intermediate.lpUnlockTime <= block.timestamp && amount > 0,
            "WRONG PARAMS"
        );
        TransferHelper.safeTransfer(
            intermediate.lpAddress,
            _msgSender(),
            amount
        );
    }

    /** @dev Function for presale closing
     * @notice Creator only
     */
    function closePresale() external initialized onlyPresaleCreator timing {
        _closePresale();
    }

    //UNSUCCESSFUL SCENARIO----------------------------------------
    /** @dev Function to withdraw your investments if presale is failed
     * @notice Investor only
     */
    function withdrawInvestment() external nonReentrant initialized notCreator {
        require(
            block.timestamp > generalInfo.closeTime &&
                intermediate.lpAddress == address(0) &&
                intermediate.raisedAmount < generalInfo.softCap,
            "WRONG PARAMS"
        );

        address sender = _msgSender();
        uint256 investmentAmount = investments[sender].amountEth;
        require(investmentAmount > 0, "ZERO");

        delete (investments[sender]);

        TransferHelper.safeTransfer(BUSD, sender, investmentAmount);
    }

    /** @dev Function to withdraw sale tokens if presale is failed
     * @notice Creator only
     */
    function withdrawTokens()
        external
        nonReentrant
        onlyPresaleCreator
        initialized
    {
        require(
            block.timestamp > generalInfo.closeTime &&
                intermediate.lpAddress == address(0) &&
                intermediate.raisedAmount < generalInfo.softCap,
            "WRONG PARAMS"
        );

        intermediate.tokensForLiquidityLeft = 0;
        intermediate.tokensForSaleLeft = 0;

        uint256 amount = IERC20(generalInfo.tokenAddress).balanceOf(
            address(this)
        );
        require(amount > 0, "ZERO");
        TransferHelper.safeTransfer(
            generalInfo.tokenAddress,
            generalInfo.creator,
            amount
        );
    }

    /** @dev View function that returns correct raised amount before and after liquidity allocation
     */
    function getRaisedAmount() external view returns (uint256) {
        if (intermediate.lpAddress != address(0)) {
            return intermediate.raisedAmount + intermediate.usdToLiq;
        } else return intermediate.raisedAmount;
    }

    function _closePresale() private {
        uint256 currentTime = block.timestamp;
        dexInfo.liquidityAllocationTime =
            currentTime +
            (dexInfo.liquidityAllocationTime - generalInfo.closeTime);
        generalInfo.closeTime = currentTime;
    }

    function _getTokenAmount(uint256 _weiAmount)
        private
        view
        returns (uint256)
    {
        return (_weiAmount * tokenMagnitude) / generalInfo.tokenPrice;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IRouter {
    function factory() external view returns (address);

    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

interface IFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IStructs {
    struct PresaleInfo {
        address creator;
        address tokenAddress;
        uint256 tokenPrice;
        uint256 hardCap;
        uint256 softCap;
        uint256 openTime;
        uint256 closeTime;
        address unsoldTokenToAddress;
    }

    struct PresaleDexInfo {
        uint256 listingPrice;
        uint256 lpTokensLockDurationInDays;
        uint8 liquidityPercentageAllocation;
        uint256 liquidityAllocationTime;
    }

    struct VestingInfo {
        uint8 vestingPerc1;
        uint8 vestingPerc2;
        uint256 vestingPeriod;
    }
}

interface IPresalePublic is IStructs {
    function initialize(
        PresaleInfo memory _info,
        PresaleDexInfo memory _dexInfo,
        VestingInfo memory _vestInfo
    ) external;
}

interface IPresalePrivate is IStructs {
    function initialize(
        PresaleInfo memory _info,
        PresaleDexInfo memory _dexInfo,
        VestingInfo memory _vestInfo,
        address[] memory _whitelist
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IPresaleFactory {
    function isApprover(address sender) external view returns (bool);
    function getFeeParams() external view returns (address, uint256);
    function isBackend(address sender) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;


interface IStaking{
    
    
    function stakeForUser(address user, uint256 lockUp) external view
        returns (
            uint256 level,
            uint256 totalStakedForUser,
            bool first_lock,
            bool second_lock,
            bool third_lock,
            bool fourth_lock,
            uint256 amountLock,
            uint256 rewardTaken,
            uint256 enteredAt
        );

    function addPresale(address presale) external;

    function addReLock(address user) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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