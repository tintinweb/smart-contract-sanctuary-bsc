// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IToken is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(address account, uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.2;

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
pragma solidity ^0.8.2;

interface IMinter {
    function convertBTCBtoDEGA(uint amount) external;
    function convertBTCBtoDEGAAndDeposit(uint amount) external;
    function convertDEGAtoBTCB(uint amount) external;

    function getFee() external view returns (uint256);
    function getExchangeRate() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactBNB(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForBNB(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapBNBForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../interfaces/IToken.sol";
import "./ISwapRouter.sol";
import "./IMinter.sol";

contract SwapBnbDega {
    IToken public degaToken;
    IToken public btcbToken;

    IMinter public minter;
    ISwapRouter public swapRouter;

    constructor (
        address _degaToken,
        address _btcbToken,
        address _minter,
        address _swapRouter
    ) {
        degaToken = IToken(_degaToken);
        btcbToken = IToken(_btcbToken);

        minter = IMinter(_minter);
        swapRouter = ISwapRouter(_swapRouter);
    }

    function convertBNBtoDEGA() public payable {
        require(msg.value > 0, "No BNB sent");

        // swap BNB to BTCB
        address[] memory path = getPathForBNBtoBTCB();
        uint256 btcbAmountOutMin = swapRouter.getAmountsOut(msg.value, path)[1];

        uint256 deadline = block.timestamp + 15;
        uint256 btcbSwapped = swapRouter.swapExactETHForTokens{ value: msg.value }(btcbAmountOutMin, path, address(this), deadline)[1];

        // convert BTCB to DEGA
        btcbToken.approve(address(minter), btcbSwapped);
        minter.convertBTCBtoDEGA(btcbSwapped);

        // calculate DEGA received
        uint256 _pegRatio = minter.getExchangeRate();
        uint256 degaAmount = btcbSwapped * _pegRatio;

        degaToken.transfer(msg.sender, degaAmount);
    }

    function getPathForBNBtoBTCB() public view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = swapRouter.WETH();
        path[1] = address(btcbToken);
        
        return path;
    }

    function getAmountDegaOut(uint256 amountBnbIn) public view returns (uint256) {
        address[] memory path = getPathForBNBtoBTCB();
        uint256 btcbAmountOutMin = swapRouter.getAmountsOut(amountBnbIn, path)[1];
        uint256 _pegRatio = minter.getExchangeRate();
        uint256 degaAmount = btcbAmountOutMin * _pegRatio;
        return degaAmount;
    }

}