// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IElvantisFeeReceiver.sol";
import "./interfaces/IDEXRouter.sol";

// This contract will only be used for Elvantis Token
contract ElvantisFeeReceiverV3 is Ownable, IElvantisFeeReceiver {
    enum SwapSetting {
        Disabled,
        SwapForEth,
        SwapAndLiquify
    }

    IERC20 public elvantis;
    IDEXRouter public router;
    address public feeRecipient;

    SwapSetting public swapSetting = SwapSetting.SwapAndLiquify;
    uint256 public swapThreshold = 4300e18;
    uint256 public maxSwapAmount = 20000e18;
    bool private inSwapAndLiquify;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    event FeeRecipientUpdated(address indexed feeRecipient);
    event RouterUpdated(address indexed router);
    event SwapSettingUpdated(SwapSetting indexed setting);
    event SwapThresholdUpdated(uint256 indexed threshold);
    event SwapAndLiquify(uint256 amount, uint256 newBalance, uint256 otherHalf);

    modifier onlyElvantis() {
        require(msg.sender == address(elvantis), "ElvantisFeeReceiver: Only Elvantis!");
        _;
    }

    constructor(
        address _elvantis,
        address _router,
        address _owner
    ) {
        require(
            _elvantis != address(0) && _router != address(0) && _owner != address(0),
            "ElvantisFeeReceiver: zero address"
        );

        elvantis = IERC20(_elvantis);
        router = IDEXRouter(_router);
        transferOwnership(_owner);
    }

    function onFeeReceived(address token, uint256 amount) external override onlyElvantis {
        if (token != address(0)) {
            address recipient = swapSetting == SwapSetting.Disabled ? feeRecipient : address(this);
            elvantis.transferFrom(address(elvantis), recipient, amount);

            if (swapSetting == SwapSetting.SwapForEth) {
                _swapTokensForETH(elvantis.balanceOf(address(this)), feeRecipient);
            } else if (swapSetting == SwapSetting.SwapAndLiquify) {
                _swapAndLiquify(elvantis.balanceOf(address(this)));
            }
        }
    }

    function _swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        if (contractTokenBalance > maxSwapAmount) {
            contractTokenBalance = maxSwapAmount;
        }
        uint256 half = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;

        uint256 initialBalance = address(this).balance;
        _swapTokensForETH(half, address(this));
        uint256 newBalance = address(this).balance - initialBalance;

        _addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        elvantis.approve(address(router), tokenAmount);
        router.addLiquidityETH{value: ethAmount}(address(this), tokenAmount, 0, 0, feeRecipient, block.timestamp);
    }

    function _swapTokensForETH(uint256 amount, address recipient) private {
        if (amount > swapThreshold) {
            address[] memory path = new address[](2);
            path[0] = address(elvantis);
            path[1] = router.WETH();

            elvantis.approve(address(router), amount);

            router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path, recipient, block.timestamp);
        }
    }

    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        require(_feeRecipient != address(0), "ElvantisFeeReceiver: _feeRecipient is a zero address");
        feeRecipient = _feeRecipient;
        emit FeeRecipientUpdated(_feeRecipient);
    }

    function setRouter(IDEXRouter _router) external onlyOwner {
        require(address(_router) != address(0), "ElvantisFeeReceiver: _router is a zero address");
        router = _router;
        emit RouterUpdated(address(_router));
    }

    function setSwapSetting(SwapSetting _setting) external onlyOwner {
        swapSetting = _setting;
        emit SwapSettingUpdated(_setting);
    }

    function setSwapThreshold(uint256 _threshold) external onlyOwner {
        swapThreshold = _threshold;
        emit SwapThresholdUpdated(_threshold);
    }

    function setMaxSwapAmount(uint256 _amount) external onlyOwner {
        maxSwapAmount = _amount;
        emit SwapThresholdUpdated(_amount);
    }

    receive() external payable {}

    function drainAccidentallySentTokens(
        IERC20 token,
        address recipient,
        uint256 amount
    ) external onlyOwner {
        token.transfer(recipient, amount);
    }

    function drainAccidentallySentEth(address payable recipient, uint256 amount) external onlyOwner {
        recipient.transfer(amount);
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IElvantisFeeReceiver {
    function onFeeReceived(address token, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDEXRouter {
    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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