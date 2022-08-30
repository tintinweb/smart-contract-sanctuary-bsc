// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./interfaces/IGoosebumpsRouter.sol";
import "./interfaces/IFeeAggregator.sol";
import "./interfaces/IERC20.sol";
import "./libraries/TransferHelper.sol";
import "./utils/Ownable.sol";

contract FeeAggregator is IFeeAggregator, Ownable {
    event LogWithdrawalETH(address indexed recipient, uint256 amount);
    event LogWithdrawToken(address indexed token, address indexed recipient, uint256 amount);
    event LogSetGoosebumpsFee(uint256 fee);

    /**
     * @notice Percentage which get deducted from a swap (1 = 100 / FEE_DENOMINATOR %)
     */
    uint256 public goosebumpsFee;
    uint256 public constant FEE_DENOMINATOR = 10000;

    constructor() {
        // 0.05%
        goosebumpsFee = 5;
    }

    receive() external payable {}
    fallback() external payable {}

    /**
     * @notice returns the fee and the amountOut for the amountIn given
     * @param amountIn input amount
     */
    function calculateFeeAndAmountOut(uint256 amountIn) external override view returns (uint256 fee, uint256 amountOut) {
        amountOut = amountIn * (FEE_DENOMINATOR - goosebumpsFee) / FEE_DENOMINATOR;
        fee = amountIn - amountOut;
    }

    /**
     * @notice returns the fee and the amountIn for the amountOut given
     * @param amountOut output amount
     */
    function calculateFeeAndAmountIn(uint256 amountOut) external override view returns (uint256 fee, uint256 amountIn) {
        amountIn = amountOut * FEE_DENOMINATOR / (FEE_DENOMINATOR - goosebumpsFee);
        fee = amountIn - amountOut;
    }

    /**
     * @notice set the percentage which get deducted from a swap (1 = 100 / FEE_DENOMINATOR %)
     * @param fee percentage to set as fee
     */
    function setGoosebumpsFee(uint256 fee) external override onlyMultiSig {
        require(fee <= FEE_DENOMINATOR * 30 / 100, "FeeAggregator: FEE_MIN_0_MAX_30");
        require(fee != goosebumpsFee, "FeeAggregator: SAME_VALUE");
        goosebumpsFee = fee;

        emit LogSetGoosebumpsFee(fee);
    }

    /**
     * @notice  onlyMultiSig will withdraw ETH and will use to benefit the Empire token holders.
     */
    function withdrawETH(address payable recipient, uint256 amount) external onlyMultiSig
    {
        require(amount <= (address(this)).balance, "INSUFFICIENT_FUNDS");
        recipient.transfer(amount);
        emit LogWithdrawalETH(recipient, amount);
    }

    /**
     * @notice  onlyMultiSig will withdraw ERC20 token that have the price and then will use to benefit the Empire token holders.
     #          Should not be withdrawn scam token.
     */
    function withdrawToken(IERC20 token, address recipient, uint256 amount) external onlyMultiSig {
        require(amount <= token.balanceOf(address(this)), "INSUFFICIENT_FUNDS");
        require(token.transfer(recipient, amount), "Transfer Fail");

        emit LogWithdrawToken(address(token), recipient, amount);
    }

    function swapExactTokensForTokens(
        IGoosebumpsRouter router,
        address[] calldata factories,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external onlyMultiSig {
        require(IERC20(path[0]).balanceOf(address(this)) >= amountIn, "FeeAggregator: NO_FEE_TOKEN_BALANCE");
        TransferHelper.safeApprove(path[0], address(router), amountIn);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(factories, amountIn, amountOutMin, path, to, deadline);
    }

    function swapExactTokensForETH(
        IGoosebumpsRouter router,
        address[] calldata factories,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external onlyMultiSig {
        require(IERC20(path[0]).balanceOf(address(this)) >= amountIn, "FeeAggregator: NO_FEE_TOKEN_BALANCE");
        TransferHelper.safeApprove(path[0], address(router), amountIn);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(factories, amountIn, amountOutMin, path, to, deadline);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IGoosebumpsRouter {
    function WETH() external returns (address);
    function baseFactory() external returns (address);
    function routerPairs() external returns (address);
    function feeAggregator() external returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);
    function swapExactTokensForTokens(
        address[] calldata factories,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapTokensForExactTokens(
        address[] calldata factories,
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactETHForTokens(
        address[] calldata factories,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
    function swapTokensForExactETH(
        address[] calldata factories,
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactTokensForETH(
        address[] calldata factories,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapETHForExactTokens(
        address[] calldata factories, 
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        address[] calldata factories,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        address[] calldata factories,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        address[] calldata factories,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IFeeAggregator {
    function calculateFeeAndAmountOut(uint256 amountIn) external view returns (uint256 fee, uint256 amountOut);
    function calculateFeeAndAmountIn(uint256 amountOut) external view returns (uint256 fee, uint256 amountIn);
    function setGoosebumpsFee(uint256 fee) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity 0.8.7;

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
 * `onlyMultiSig`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    /**
     * @dev Must be Multi-Signature Wallet.
     */
    address private _multiSigOwner;

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
    modifier onlyMultiSig() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _multiSigOwner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyMultiSig` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyMultiSig {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyMultiSig {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _multiSigOwner;
        _multiSigOwner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.7;

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
}