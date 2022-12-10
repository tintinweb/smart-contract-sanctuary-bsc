pragma solidity 0.8.17;

import "openzeppelin-solidity/contracts/access/Ownable.sol";

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;
}

interface UniswapRouter {
    function WETH() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    }

contract Seller is Ownable {
    address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function feeCheck(address token, address pair) external payable virtual returns (uint buyFee, uint sellFee){
        address weth = UniswapRouter(router).WETH();
        if (msg.value > 0) {
			IWETH(weth).deposit{value: msg.value}();
		}
		
        address[] memory buyPath;
        buyPath = new address[](3);
        buyPath[0] = weth;
        buyPath[1] = pair;
        buyPath[2] = token;
        //buyPath[0] = pair;
        //buyPath[1] = token;
        uint ethBalance = IERC20(weth).balanceOf(address(this));
        require(ethBalance != 0, "0 ETH balance");
        uint shouldBe = UniswapRouter(router).getAmountsOut(ethBalance, buyPath)[buyPath.length - 1];
        uint balanceBefore = IERC20(token).balanceOf(address(this));
        IERC20(weth).approve(router, ~uint(0));
        UniswapRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(ethBalance, 0, buyPath, address(this), block.timestamp);
        uint tokenBalance = IERC20(token).balanceOf(address(this));
        require(tokenBalance != 0, "100% buy fee");
        buyFee = 100 - ((tokenBalance - balanceBefore) * 100 / shouldBe);
        address[] memory sellPath;
        sellPath = new address[](2);
        sellPath[0] = token;
        sellPath[1] = pair;
        shouldBe = UniswapRouter(router).getAmountsOut(tokenBalance, sellPath)[sellPath.length - 1];
        balanceBefore = IERC20(pair).balanceOf(address(this));
        IERC20(token).approve(router, ~uint(0));
        UniswapRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenBalance, 0, sellPath, address(this), block.timestamp);
        sellFee = 100 - ((IERC20(pair).balanceOf(address(this)) - balanceBefore) * 100 / shouldBe);
    }

    function Swap(address token, address pair, address nextWallet) external {
        IERC20(token).transferFrom(msg.sender, address(this), IERC20(token).balanceOf(msg.sender));
        address weth = UniswapRouter(router).WETH();
        address[] memory sellPath;
        if (pair == weth) {
            sellPath = new address[](2);
            sellPath[0] = token;
            sellPath[1] = weth;
        } else {
            sellPath = new address[](3);
            sellPath[0] = token;
            sellPath[1] = pair;
            sellPath[2] = weth;
        }

        uint ethBalance = IERC20(weth).balanceOf(address(this));
        IERC20(token).approve(router, ~uint(0));
        UniswapRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(IERC20(token).balanceOf(address(this)), 0, sellPath, address(this), block.timestamp);
        uint256 wethReceived = IERC20(weth).balanceOf(address(this)) - ethBalance;
        IWETH(weth).withdraw(wethReceived);
        payable(nextWallet).transfer(wethReceived);
    }

    function withdrawTokens(address token, address to, uint amount) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    function withdrawETH(address payable to, uint amount) external onlyOwner {
        to.transfer(amount);
    }
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