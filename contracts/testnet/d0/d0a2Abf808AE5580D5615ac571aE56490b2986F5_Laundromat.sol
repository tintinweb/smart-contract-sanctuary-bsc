/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: contracts/Laundromat.sol

/* SPDX-License-Identifier: UNLICENSED */

pragma solidity ^0.8.7;



interface IUniswapV2Router01 {
    function WETH() external pure returns (address);

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

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
}

interface IBandit is IERC20 {
    function liquidityPair() external view returns (address);
}

contract Laundromat is Ownable {
    address public TOKEN;
    address public BUSD;
    address payable public GROWTH;
    IUniswapV2Router02 public ROUTER;

    constructor(
        address token,
        address busd,
        address payable growth,
        address router
    ) {
        TOKEN = token;
        BUSD = busd;
        GROWTH = growth;
        ROUTER = IUniswapV2Router02(router);
        IERC20(TOKEN).approve(router, type(uint256).max);
    }

    function _skim() internal {
        if (address(this).balance > 0) {
            GROWTH.transfer(address(this).balance);
        }

        if (IERC20(BUSD).balanceOf(address(this)) > 0) {
            IERC20(BUSD).transfer(
                GROWTH,
                IERC20(BUSD).balanceOf(address(this))
            );
        }

        if (IERC20(TOKEN).balanceOf(address(this)) > 0) {
            IERC20(TOKEN).transfer(
                GROWTH,
                IERC20(TOKEN).balanceOf(address(this))
            );
        }
    }

    function _createLiquidity(uint256 amount) internal {
        address[] memory path = new address[](2);
        path[0] = ROUTER.WETH();
        path[1] = TOKEN;
        ROUTER.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount / 2
        }(0, path, address(this), block.timestamp);
        ROUTER.addLiquidityETH{value: amount / 2}(
            TOKEN,
            IERC20(TOKEN).balanceOf(address(this)),
            0,
            0,
            _msgSender(),
            block.timestamp
        );
        _skim();
    }

    function createLiquidityFromBNB() public payable {
        _createLiquidity(msg.value);
    }

    function createLiqudityFromBUSD(uint256 amount) public {
        require(
            IERC20(BUSD).balanceOf(_msgSender()) >= amount,
            "CREATE: Balance too low."
        );
        require(
            IERC20(BUSD).allowance(_msgSender(), address(this)) >= amount,
            "CREATE: Allowance too low."
        );
        IERC20(BUSD).transferFrom(_msgSender(), address(this), amount);
        address[] memory path = new address[](2);
        path[0] = BUSD;
        path[1] = ROUTER.WETH();
        ROUTER.swapExactTokensForETH(
            IERC20(BUSD).balanceOf(address(this)),
            0,
            path,
            address(this),
            block.timestamp
        );
        _createLiquidity(address(this).balance);
    }

    function _disassembleLiquidity(uint256 amount) internal {
        IERC20 pair = IERC20(IBandit(TOKEN).liquidityPair());
        require(
            pair.balanceOf(_msgSender()) >= amount,
            "DISASSEMBLE: Balance too low."
        );
        require(
            pair.allowance(_msgSender(), address(this)) >= amount,
            "DISASSEMBLE: Allowance too low."
        );
        pair.transferFrom(_msgSender(), address(this), amount);
    }

    function disassembleLiquidityToBNB(uint256 amount) public {
        _disassembleLiquidity(amount);
        ROUTER.removeLiquidityETHSupportingFeeOnTransferTokens(
            TOKEN,
            amount,
            0,
            0,
            _msgSender(),
            block.timestamp
        );
        _skim();
    }

    function disassembleLiquidityToBUSD(uint256 amount) public {
        _disassembleLiquidity(amount);
        ROUTER.removeLiquidityETHSupportingFeeOnTransferTokens(
            TOKEN,
            amount,
            0,
            0,
            address(this),
            block.timestamp
        );
        address[] memory path = new address[](2);
        path[0] = ROUTER.WETH();
        path[1] = BUSD;
        ROUTER.swapExactETHForTokens{value: address(this).balance}(
            0,
            path,
            _msgSender(),
            block.timestamp
        );
        IERC20(TOKEN).transfer(
            _msgSender(),
            IERC20(TOKEN).balanceOf(address(this))
        );
        _skim();
    }

    receive() external payable {}
    fallback() external payable {}
}