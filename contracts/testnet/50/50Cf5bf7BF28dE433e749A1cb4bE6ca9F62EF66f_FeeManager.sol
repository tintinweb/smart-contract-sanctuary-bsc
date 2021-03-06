// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./interfaces/ICarboToken.sol";
import "./interfaces/IDividendManager.sol";
import "./FeeHolder.sol";
import "./RecoverableFunds.sol";

contract FeeManager is Ownable, RecoverableFunds {

    struct Addresses {
        address buyback;
        address treasury;
        address liquidity;
    }

    struct Amounts {
        uint256 dividends;
        uint256 buyback;
        uint256 treasury;
        uint256 liquidity;
        uint256 sum;
    }

    IUniswapV2Router02 public uniswapRouter;
    IERC20 public busd;
    ICarboToken public carbo;
    IDividendManager public dividendManager;
    FeeHolder public buyFeeHolder;
    FeeHolder public sellFeeHolder;

    Addresses public addresses;

    constructor(address _router, address _busd, address _carbo) {
        carbo = ICarboToken(_carbo);
        busd = IERC20(_busd);
        uniswapRouter = IUniswapV2Router02(_router);
        buyFeeHolder = new FeeHolder(_carbo);
        sellFeeHolder = new FeeHolder(_carbo);
    }

    function setFeeAddresses(address buyback, address treasury, address liquidity) external onlyOwner {
        addresses = Addresses(buyback, treasury, liquidity);
    }

    function setDividendManager(address _address) external onlyOwner {
        dividendManager = IDividendManager(_address);
    }

    function swapAndDistribute() external onlyOwner {
        ICarboToken.Fees memory buyFees = carbo.getFees(ICarboToken.FeeType.BUY);
        ICarboToken.Fees memory sellFees = carbo.getFees(ICarboToken.FeeType.SELL);
        uint256 buyFeeTotal = buyFeeHolder.getTokens();
        uint256 sellFeeTotal = sellFeeHolder.getTokens();
        uint256 feeTotal = buyFeeTotal + sellFeeTotal;
        require(feeTotal > 0, "FeeManager: nothing to distribute");
        Amounts memory buyFeeAmounts = _getAmounts(buyFeeTotal, buyFees);
        Amounts memory sellFeeAmounts = _getAmounts(sellFeeTotal, sellFees);
        uint256 notToSwap = (buyFeeAmounts.liquidity + sellFeeAmounts.liquidity) / 2;
        uint256 toSwap = feeTotal - notToSwap;
        require(toSwap > 0, "FeeManager: nothing to swap");
        _swap(toSwap);
        uint256 busdReceived = busd.balanceOf(address(this));
        uint256 dividends = busdReceived * (buyFeeAmounts.dividends + sellFeeAmounts.dividends) / feeTotal;
        uint256 buyback = busdReceived * (buyFeeAmounts.buyback + sellFeeAmounts.buyback) / feeTotal;
        uint256 treasury = busdReceived * (buyFeeAmounts.treasury + sellFeeAmounts.treasury) / feeTotal;
        uint256 liquidity = busdReceived - dividends - buyback - treasury;
        busd.approve(address(dividendManager), dividends);
        dividendManager.distributeDividends(dividends);
        busd.transfer(addresses.buyback, buyback);
        busd.transfer(addresses.treasury, treasury);
        busd.transfer(addresses.liquidity, liquidity);
        carbo.transfer(addresses.liquidity, notToSwap);
    }

    function _getAmounts(uint256 amount, ICarboToken.Fees memory fees) internal view returns (Amounts memory amounts) {
        Amounts memory amounts;
        uint256 denominator = fees.dividends + fees.buyback + fees.treasury + fees.liquidity;
        if (denominator > 0) {
            amounts.dividends = amount * fees.dividends / denominator;
            amounts.buyback = amount * fees.buyback / denominator;
            amounts.treasury = amount * fees.treasury / denominator;
            amounts.liquidity = amount - amounts.dividends - amounts.buyback - amounts.treasury;
        }
        return amounts;
    }

    function _swap(uint256 amount) internal {
        address[] memory path = new address[](2);
        path[0] = address(carbo);
        path[1] = address(busd);

        carbo.approve(address(uniswapRouter), amount);

        uniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @dev Interface of DividendManager
 */
interface IDividendManager {

    function distributeDividends(uint256 amount) external;

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Interface of CarboToken
 */
interface ICarboToken is IERC20 {

    struct Amounts {
        uint256 sum;
        uint256 transfer;
        uint256 rfi;
        uint256 dividends;
        uint256 buyback;
        uint256 treasury;
        uint256 liquidity;
    }

    struct Fees {
        uint256 rfi;
        uint256 dividends;
        uint256 buyback;
        uint256 treasury;
        uint256 liquidity;
    }

    struct FeeAddresses {
        address dividends;
        address buyback;
        address treasury;
        address liquidity;
    }

    enum FeeType { BUY, SELL, NONE}

    event FeeTaken(uint256 rfi, uint256 dividends, uint256 buyback, uint256 treasury, uint256 liquidity);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external pure returns (uint8);
    function burn(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function getFees(FeeType feeType) external view returns (Fees memory);
    function setFees(FeeType feeType, uint rfi, uint dividends, uint buyback, uint treasury, uint liquidity) external;
    function getFeeAddresses(FeeType feeType) external view returns (FeeAddresses memory);
    function setFeeAddresses(FeeType feeType, address dividends, address buyback, address treasury, address liquidity) external;
    function setTaxable(address account, bool value) external;
    function setTaxExempt(address account, bool value) external;
    function getROwned(address account) external view returns (uint256);
    function getRTotal() external view returns (uint256);
    function excludeFromRFI(address account) external;
    function includeInRFI(address account) external;
    function reflect(uint256 tAmount) external;
    function reflectionFromToken(uint256 tAmount) external view returns (uint256);
    function tokenFromReflection(uint256 rAmount) external view returns (uint256);

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Allows the owner to retrieve ETH or tokens sent to this contract by mistake.
 */
contract RecoverableFunds is Ownable {

    function retrieveTokens(address recipient, address tokenAddress) public virtual onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        token.transfer(recipient, token.balanceOf(address(this)));
    }

    function retriveETH(address payable recipient) public virtual onlyOwner {
        recipient.transfer(address(this).balance);
    }

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./RecoverableFunds.sol";

contract FeeHolder is RecoverableFunds {

    address public manager;
    IERC20 public token;

    modifier onlyManager() {
        require(owner() == _msgSender(), "LiquidityHolder: caller is not the manager");
        _;
    }

    constructor(address _token) {
        token = IERC20(_token);
        manager = _msgSender();
    }

    function getTokens() external onlyManager returns (uint256) {
        uint256 balance = token.balanceOf(address(this));
        if (balance > 0) token.transfer(manager, balance);
        return balance;
    }

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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