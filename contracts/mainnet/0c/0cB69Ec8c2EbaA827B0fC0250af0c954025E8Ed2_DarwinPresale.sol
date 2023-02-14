// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import {IDarwinPresale} from "./interface/IDarwinPresale.sol";
import {IDarwin} from "./interface/IDarwin.sol";

/// @title Darwin Presale
contract DarwinPresale is IDarwinPresale, ReentrancyGuard, Ownable {
    /// @notice Min BNB deposit per user
    uint256 public constant RAISE_MIN = .1 ether;
    /// @notice Max BNB deposit per user
    uint256 public constant RAISE_MAX = 4_000 ether;
    /// @notice Max number of BNB to be raised
    uint256 public constant HARDCAP = 140_000 ether;
    /// @notice Amount of Darwin to be sent to the LP if hardcap reached
    uint256 public constant LP_AMOUNT = 1e25; // 10,000,000 Darwin
    /// @notice % of raised BNB to be sent to Wallet1
    uint256 public constant WALLET1_PERCENTAGE = 30;
    /// @notice % of raised BNB to be added to Wallet1 percentage at the end of the presale
    uint256 public constant WALLET1_ADDITIONAL_PERCENTAGE = 5;
    /// @notice % of raised BNB to be sent to Wallet2
    uint256 public constant WALLET2_PERCENTAGE = 20;

    /// @notice The Darwin token
    IERC20 public darwin;
    /// @notice Timestamp of the presale start
    uint256 public presaleStart;

    /// @notice Timestamp of the presale end
    uint256 public presaleEnd;

    address public wallet1;
    address public wallet2;

    enum Status {
        QUEUED,
        ACTIVE,
        SUCCESS
    }

    struct PresaleStatus {
        uint256 raisedAmount; // Total BNB raised
        uint256 soldAmount; // Total Darwin sold
        uint256 numBuyers; // Number of unique participants
    }

    /// @notice Mapping of total BNB deposited by user
    mapping(address => uint256) public userDeposits;

    PresaleStatus public status;

    IUniswapV2Router02 private router;
    bool private _isInitialized;

    modifier isInitialized() {
        if (!_isInitialized) {
            revert NotInitialized();
        }
        _;
    }

    /// @dev Initializes the Darwin Protocol address
    /// @param _darwin The Darwin Protocol address
    function init(
        address _darwin
    ) external onlyOwner {
        if (_isInitialized) revert AlreadyInitialized();
        if (_darwin == address(0)) revert ZeroAddress();

        darwin = IERC20(_darwin);
        IDarwin(_darwin).pause();

        _setWallet1(0x0bF1C4139A6168988Fe0d1384296e6df44B27aFd);
        _setWallet2(0xBE013CeAB3611Dc71A4f150577375f8Cb8d9f6c3);
    }

    /// @dev Initializes the presale start date, and sets presale end date to 90 days after it
    function startPresale() external onlyOwner {
        if (_isInitialized) revert AlreadyInitialized();
        _isInitialized = true;

        presaleStart = block.timestamp;
        presaleEnd = presaleStart + (90 days);
    }

    /// @notice Deposits BNB into the presale
    /// @dev Emits a UserDeposit event
    /// @dev Emits a RewardsDispersed event
    function userDeposit() external payable nonReentrant isInitialized {

        if (presaleStatus() != Status.ACTIVE) {
            revert PresaleNotActive();
        }

        uint256 base = userDeposits[msg.sender];

        if (msg.value < RAISE_MIN || base + msg.value > RAISE_MAX) {
            revert InvalidDepositAmount();
        }

        if (base == 0) {
            // new depositer
            ++status.numBuyers;
        }

        userDeposits[msg.sender] += msg.value;

        uint256 darwinAmount = calculateDarwinAmount(msg.value);

        status.raisedAmount += msg.value;
        status.soldAmount += darwinAmount;

        uint256 wallet1Amount = (msg.value * WALLET1_PERCENTAGE) / 100;
        _transferBNB(wallet1, wallet1Amount);

        if (!darwin.transfer(msg.sender, darwinAmount)) {
            revert TransferFailed();
        }

        emit UserDeposit(msg.sender, msg.value, darwinAmount);
    }

    /// @notice Set the presale end date to `_endDate`
    /// @param _endDate The new presale end date
    function setPresaleEndDate(uint256 _endDate) external onlyOwner {
        // solhint-disable-next-line not-rely-on-time
        if (_endDate < block.timestamp || _endDate < presaleStart || _endDate > presaleEnd) {
            revert InvalidEndDate();
        }
        presaleEnd = _endDate;
        emit PresaleEndDateSet(_endDate);
    }

    /// @notice Set addresses for Wallet1 and Wallet2
    /// @param _wallet1 The new Wallet1 address
    /// @param _wallet2 The new Wallet2 address
    function setWallets(
        address _wallet1,
        address _wallet2
    ) external onlyOwner {
        if (_wallet1 == address(0) || _wallet2 == address(0)) {
            revert ZeroAddress();
        }
        _setWallet1(_wallet1);
        _setWallet2(_wallet2);
    }

    /// @notice Allocates presale funds to LP, Wallet2, and Wallet1
    /// @dev The unsold darwin tokens are sent back to the owner
    function provideLpAndWithdrawTokens() external onlyOwner {
        if (wallet1 == address(0) || wallet2 == address(0)) {
            revert ZeroAddress();
        }
        if (presaleStatus() != Status.SUCCESS) {
            revert PresaleNotEnded();
        }

        IDarwin(address(darwin)).unPause();
        IDarwin(address(darwin)).setLive();

        uint256 balance = address(this).balance;

        uint256 wallet2Amount = (status.raisedAmount * WALLET2_PERCENTAGE) / 100;
        uint256 wallet1Amount = (status.raisedAmount * WALLET1_ADDITIONAL_PERCENTAGE) / 100;

        uint256 lp = balance - wallet2Amount - wallet1Amount; // 45%

        // set the price of darwin in the lp to be the price of the next stage of funding
        uint nextStage = _getCurrentStage() + 1;
        uint darwinDepositRate;
        uint darwinToDeposit;
        if(nextStage == 9) {
            //darwinDepositRate = 15_873;
            darwinToDeposit = LP_AMOUNT;
        } else {
            (darwinDepositRate, ,) = _getStageDetails(nextStage);
            darwinToDeposit = (lp * darwinDepositRate);
        }

        _addLiquidity(address(darwin), darwinToDeposit, lp);
        
        _transferBNB(wallet2, wallet2Amount);
        _transferBNB(wallet1, wallet1Amount);

        if (!darwin.transfer(wallet1, darwin.balanceOf(address(this)))) {
            revert TransferFailed();
        }

        emit LpProvided(lp, darwinToDeposit);
    }

    /// @notice Changes the router address.
    /// @dev Only callable by the owner. Useful when we want to set the router to DarwinSwap's one, since we're deploying it during presale.
    /// @param _router the new router address.
    function setRouter(address _router) external onlyOwner {
        router = IUniswapV2Router02(_router);
        emit RouterSet(_router);
    }

    /// @notice Returns the current stage of the presale
    /// @return stage The current stage of the presale
    function getCurrentStage() external view returns (uint256 stage) {
        stage = _getCurrentStage();
    }

    function tokensDepositedAndOwned(
        address account
    ) external view returns (uint256, uint256) {
        uint256 deposited = userDeposits[account];
        uint256 owned = darwin.balanceOf(account);
        return (deposited, owned);
    }

    /// @notice Returns the number of tokens left to raise on the current stage
    /// @return tokensLeft The number of tokens left to raise on the current stage
    function baseTokensLeftToRaiseOnCurrentStage()
        public
        view
        returns (uint256 tokensLeft)
    {
        (, , uint256 stageCap) = _getStageDetails(_getCurrentStage());
        tokensLeft = stageCap - status.raisedAmount;
    }

    /// @notice Returns the current presale status
    /// @return The current presale status
    function presaleStatus() public view returns (Status) {
        if (!_isInitialized) {
            return Status.QUEUED;
        }

        // solhint-disable-next-line not-rely-on-time
        if (status.raisedAmount >= HARDCAP || block.timestamp > presaleEnd) {
            return Status.SUCCESS; // Wonderful, presale has ended
        }

        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp >= presaleStart && block.timestamp <= presaleEnd) {
            return Status.ACTIVE; // ACTIVE - Deposits enabled, now in Presale
        }

        return Status.QUEUED; // QUEUED - Awaiting start block
    }

    /// @notice Calculates the number of tokens that can be bought with `bnbAmount` BNB
    /// @param bnbAmount The number of BNB to be deposited
    /// @return The number of Darwin to be purchased with `bnbAmount` BNB
    function calculateDarwinAmount(
        uint256 bnbAmount
    ) public view returns (uint256) {
        if (bnbAmount > HARDCAP - status.raisedAmount) {
            revert AmountExceedsHardcap();
        }
        uint256 tokensLeft = baseTokensLeftToRaiseOnCurrentStage();
        if (bnbAmount < tokensLeft) {
            return ((bnbAmount * _getCurrentRate()));
        } else {
            uint256 stage = _getCurrentStage();
            uint256 darwinAmount;
            uint256 rate;
            uint256 stageAmount;
            uint256 stageCap;
            uint amountRaised = status.raisedAmount;
            while (bnbAmount > 0) {
                (rate, stageAmount, stageCap) = _getStageDetails(stage);
                uint amountLeftInStage = stageCap - amountRaised;
                if (bnbAmount <= amountLeftInStage) {
                    darwinAmount += (bnbAmount * rate);
                    bnbAmount = 0;
                    break;
                }

                amountRaised += amountLeftInStage;
                darwinAmount += (amountLeftInStage * rate);
                bnbAmount -= amountLeftInStage;
                
                ++stage;
            }

            return darwinAmount;
        }
    }

    function _transferBNB(address to, uint256 amount) internal {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) {
            revert TransferFailed();
        }
    }

    function _setWallet1(address _wallet1) internal {
        wallet1 = _wallet1;
        emit Wallet1Set(_wallet1);
    }

    function _setWallet2(address _wallet2) internal {
        wallet2 = _wallet2;
        emit Wallet2Set(_wallet2);
    }

    function _addLiquidity(
        address tokenAddress,
        uint256 tokenAmount,
        uint256 bnbAmount
    ) private {
        // approve token transfer to cover all possible scenarios
        if (!IERC20(tokenAddress).approve(address(router), tokenAmount)) {
            revert ApproveFailed();
        }

        // add the liquidity
        router.addLiquidityETH{value: bnbAmount}(
            tokenAddress, // token
            tokenAmount, // amountTokenDesired
            0, // amountTokenMin (slippage is unavoidable)
            0, // amountETHMin (slippage is unavoidable)
            owner(), // to (Recipient of the liquidity tokens.)
            block.timestamp + 600 // deadline (10 mins.)
        );
    }

    function _getCurrentRate() private view returns (uint256 rate) {
        (rate, , ) = _getStageDetails(_getCurrentStage());
    }

    function _getCurrentStage() private view returns (uint256) {
        uint raisedAmount = status.raisedAmount;
        if (raisedAmount > 117_164 ether) {
            return 8;
        } else if (raisedAmount > 96_690 ether) {
            return 7;
        } else if (raisedAmount > 78_135 ether) {
            return 6;
        } else if (raisedAmount > 61_170 ether) {
            return 5;
        } else if (raisedAmount > 45_545 ether) {
            return 4;
        } else if (raisedAmount > 31_063 ether) {
            return 3;
        } else if (raisedAmount > 17_569 ether) {
            return 2;
        } else if (raisedAmount > 5_000 ether) {
            return 1;
        } else {
            return 0;
        }
    }

    function _getStageDetails(
        uint256 stage
    ) private pure returns (uint256, uint256, uint256) {
        assert(stage <= 8);
        if (stage == 0) {
            return (500, 5_000 ether, 5_000 ether);
        } else if (stage == 1) {
            return (470, 12_569 ether, 17_569 ether);
        } else if (stage == 2) {
            return (440, 13_494 ether, 31_063 ether);
        } else if (stage == 3) {
            return (410, 14_482 ether, 45_545 ether);
        } else if (stage == 4) {
            return (380, 15_625 ether, 61_170 ether);
        } else if (stage == 5) {
            return (350, 16_925 ether, 78_135 ether);
        } else if (stage == 6) {
            return (320, 18_555 ether, 96_690 ether);
        } else if (stage == 7) {
            return (290, 20_474 ether, 117_164 ether);
        } else {
            return (261, 22_745 ether, 140_000 ether); //old: 26_131
        }
    }
}

pragma solidity ^0.8.14;

// SPDX-License-Identifier: MIT

interface IDarwin {

    /// @notice Accumulatively log sold tokens
    struct TokenSellLog {
        uint40 lastSale;
        uint216 amount;
    }

    event ExcludedFromReflection(address account, bool isExcluded);
    event ExcludedFromSellLimit(address account, bool isExcluded);

    // PUBLIC
    function distributeRewards(uint256 amount) external;
    function bulkTransfer(address[] calldata recipients, uint256[] calldata amounts) external;

    // PRESALE
    function pause() external;
    function unPause() external;
    function setLive() external;

    // COMMUNITY
    // function upgradeTo(address newImplementation) external; RESTRICTED
    // function upgradeToAndCall(address newImplementation, bytes memory data) external payable; RESTRICTED
    function setMinter(address user_, bool canMint_) external; // RESTRICTED
    function setReceiveRewards(address account, bool shouldReceive) external; // RESTRICTED
    function setHoldingLimitWhitelist(address account, bool whitelisted) external; // RESTRICTED
    function setSellLimitWhitelist(address account, bool whitelisted) external; // RESTRICTED
    function registerPair(address pairAddress) external; // RESTRICTED
    function communityUnPause() external;

    // FACTORY
    function registerDarwinSwapPair(address _pair) external;

    // SECURITY
    function emergencyPause() external;
    function emergencyUnPause() external;

    // MAINTENANCE
    function setDarwinSwapFactory(address _darwinSwapFactory) external;
    function setPauseWhitelist(address _addr, bool value) external;
    function setPrivateSaleAddress(address _addr) external;

    // VIEW
    function isExcludedFromHoldingLimit(address account) external view returns (bool);
    function isExcludedFromSellLimit(address account) external view returns (bool);
    function isPaused() external view returns (bool);
    function maxTokenHoldingSize() external view returns(uint256);
    function maxTokenSellSize() external view returns(uint256);

    /// TransferFrom amount is greater than allowance
    error InsufficientAllowance();
    /// Only the DarwinCommunity can call this function
    error OnlyDarwinCommunity();

    /// Input cannot be the zero address
    error ZeroAddress();
    /// Amount cannot be 0
    error ZeroAmount();
    /// Arrays must be the same length
    error InvalidArrayLengths();

    /// Holding limit exceeded
    error HoldingLimitExceeded();
    /// Sell limit exceeded
    error SellLimitExceeded();
    /// Paused
    error Paused();
    error AccountAlreadyExcluded();
    error AccountNotExcluded();

    /// Max supply reached, cannot mint more Darwin
    error MaxSupplyReached();
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

/// @title Interface for the Darwin Presale
interface IDarwinPresale {

    /// Presale contract is already initialized
    error AlreadyInitialized();
    /// Presale contract is not initialized
    error NotInitialized();
    /// Presale has not started yet
    error PresaleNotActive();
    /// Presale has not ended yet
    error PresaleNotEnded();
    /// Parameter cannot be the zero address
    error ZeroAddress();
    /// Start date cannot be less than the current timestamp
    error InvalidStartDate();
    /// End date cannot be less than the start date or the current timestamp
    error InvalidEndDate();
    /// Deposit amount must be between 0.1 and 4,000 BNB
    error InvalidDepositAmount();
    /// Deposit amount exceeds the hardcap
    error AmountExceedsHardcap();
    /// Attempted transfer failed
    error TransferFailed();
    /// ERC20 token approval failed
    error ApproveFailed();

    /// @notice Emitted when bnb is deposited
    /// @param user Address of the user who deposited
    /// @param amountIn Amount of BNB deposited
    /// @param darwinAmount Amount of Darwin received
    event UserDeposit(address indexed user, uint256 indexed amountIn, uint256 indexed darwinAmount);
    event PresaleEndDateSet(uint256 indexed endDate);
    event Wallet1Set(address indexed wallet1);
    event Wallet2Set(address indexed wallet2);
    event RouterSet(address indexed router);
    event LpProvided(uint256 indexed lpAmount, uint256 indexed remainingAmount);
    
}