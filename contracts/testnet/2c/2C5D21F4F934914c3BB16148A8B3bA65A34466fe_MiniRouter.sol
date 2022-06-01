// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

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
}

interface IEmpire {
    function isExcludedFromFee(address account) external view returns (bool);
}

contract MiniRouter is Ownable, Pausable, ReentrancyGuard {
    ///@notice MiniRouter must be excluded from Empire buy/sell fee
    address public empire;

    ///@notice The only owner can add or remove new router, but before add, owner must check its contract.
    mapping(address => bool) public supportedRouters;

    ///@notice The only owner can add or remove new token, but before add, owner must check token contract.
    mapping(address => bool) public supportedTokens;

    event LogUpdateSupportedRouters(address router, bool enabled);
    event LogUpdateSupportedTokens(address token, bool enabled);
    event LogSetEmpire(address empire);
    event LogFallback(address from, uint256 amount);
    event LogReceive(address from, uint256 amount);
    event LogWithdrawalETH(address indexed recipient, uint256 amount);
    event LogWithdrawToken(
        address indexed token,
        address indexed recipient,
        uint256 amount
    );
    event LogAddLiquidityTokens(
        address indexed from,
        address indexed router,
        address indexed tokenB,
        uint256 amountEmpire,
        uint256 amountTokenB,
        uint256 liquidity,
        address to
    );
    event LogAddLiquidityETH(
        address indexed from,
        address indexed router,
        uint256 amountEmpire,
        uint256 amountETH,
        uint256 liquidity,
        address to
    );
    event LogRemoveLiquidityTokens(
        address indexed from,
        address indexed router,
        address indexed tokenB,
        uint256 liquidity,
        uint256 amountEmpire,
        uint256 amountTokenB,
        address to
    );
    event LogRemoveLiquidityETH(
        address indexed from,
        address indexed router,
        uint256 liquidity,
        uint256 amountEmpire,
        uint256 amountETH,
        address to
    );

    constructor(address empire_, address router_, address weth_, address busd_) {
        setEmpire(empire_);

        updateSupportedRouters(router_, true);

        updateSupportedTokens(weth_, true);
        updateSupportedTokens(busd_, true);
    }

    function ensure(address router) private view {
        require(
            IEmpire(empire).isExcludedFromFee(address(this)) == true,
            "MiniRouter: The Router must be excluded from fee"
        );

        require(
            supportedRouters[router] == true,
            "MiniRouter: The Router is not supported"
        );
    }

    modifier ensureAddLiquidity(address router, uint256 amountEmpireDesired) {
        ensure(router);

        require(
            IERC20(empire).transferFrom(
                msg.sender,
                address(this),
                amountEmpireDesired
            ),
            "MiniRouter: TransferFrom failed"
        );

        require(
            IERC20(empire).approve(router, amountEmpireDesired),
            "MiniRouter: Approve failed"
        );

        _;
    }

    modifier ensureRemoveLiquidity(
        address router,
        address tokenB,
        uint256 liquidity
    ) {
        ensure(router);

        require(
            supportedTokens[tokenB] == true,
            "MiniRouter: The TokenB is not supported"
        );

        address pair = IUniswapV2Factory(IUniswapV2Router02(router).factory())
            .getPair(empire, tokenB);

        require(pair != address(0), "MiniRouter: Pair does not exist");

        require(
            IERC20(pair).transferFrom(msg.sender, address(this), liquidity),
            "MiniRouter: TransferFrom failed"
        );

        require(
            IERC20(pair).approve(router, liquidity),
            "MiniRouter: Approve failed"
        );

        _;
    }

    function beforeAddLiquidityTokens(
        address router,
        address tokenB,
        uint256 amountTokenBDesired
    ) private {
        require(
            supportedTokens[tokenB] == true,
            "MiniRouter: The TokenB is not supported"
        );

        require(
            IERC20(tokenB).transferFrom(
                msg.sender,
                address(this),
                amountTokenBDesired
            ),
            "MiniRouter: TransferFrom failed"
        );

        require(
            IERC20(tokenB).approve(router, amountTokenBDesired),
            "MiniRouter: Approve failed"
        );
    }

    function addLiquidityTokens(
        address router,
        address tokenB,
        uint256 amountEmpireDesired,
        uint256 amountTokenBDesired,
        address to,
        uint256 deadline
    )
        external
        whenNotPaused
        nonReentrant
        ensureAddLiquidity(router, amountEmpireDesired)
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        beforeAddLiquidityTokens(router, tokenB, amountTokenBDesired);

        (amountA, amountB, liquidity) = IUniswapV2Router02(router).addLiquidity(
            empire,
            tokenB,
            amountEmpireDesired,
            amountTokenBDesired,
            0,
            0,
            to,
            deadline
        );

        uint256 amountEmpireRefund = amountEmpireDesired - amountA;
        uint256 amountTokenBRefund = amountTokenBDesired - amountB;

        if (amountEmpireRefund > 0) {
            require(
                IERC20(empire).transfer(msg.sender, amountEmpireRefund),
                "Transfer fail"
            );
        }

        if (amountTokenBRefund > 0) {
            require(
                IERC20(tokenB).transfer(msg.sender, amountTokenBRefund),
                "Transfer fail"
            );
        }

        emit LogAddLiquidityTokens(
            msg.sender,
            router,
            tokenB,
            amountA,
            amountB,
            liquidity,
            to
        );
    }

    function addLiquidityETH(
        address router,
        uint256 amountEmpireDesired,
        address to,
        uint256 deadline
    )
        external
        payable
        whenNotPaused
        nonReentrant
        ensureAddLiquidity(router, amountEmpireDesired)
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        )
    {
        (amountToken, amountETH, liquidity) = IUniswapV2Router02(router)
            .addLiquidityETH{value: msg.value}(
            empire,
            amountEmpireDesired,
            0,
            0,
            to,
            deadline
        );

        uint256 amountEmpireRefund = amountEmpireDesired - amountToken;
        uint256 amountETHRefund = msg.value - amountETH;

        if (amountEmpireRefund > 0) {
            require(
                IERC20(empire).transfer(msg.sender, amountEmpireRefund),
                "Transfer fail"
            );
        }

        if (amountETHRefund > 0) {
            (bool success, ) = msg.sender.call{value: amountETHRefund}(
                new bytes(0)
            );
            require(success, "ETH Refund fail");
        }

        emit LogAddLiquidityETH(
            msg.sender,
            router,
            amountToken,
            amountETH,
            liquidity,
            to
        );
    }

    function removeLiquidityTokens(
        address router,
        address tokenB,
        uint256 liquidity,
        address to,
        uint256 deadline
    )
        external
        whenNotPaused
        nonReentrant
        ensureRemoveLiquidity(router, tokenB, liquidity)
        returns (uint256 amountA, uint256 amountB)
    {
        (amountA, amountB) = IUniswapV2Router02(router).removeLiquidity(
            empire,
            tokenB,
            liquidity,
            0,
            0,
            to,
            deadline
        );

        emit LogRemoveLiquidityTokens(
            msg.sender,
            router,
            tokenB,
            liquidity,
            amountA,
            amountB,
            to
        );
    }

    function removeLiquidityETH(
        address router,
        uint256 liquidity,
        address to,
        uint256 deadline
    )
        external
        whenNotPaused
        nonReentrant
        ensureRemoveLiquidity(
            router,
            IUniswapV2Router02(router).WETH(),
            liquidity
        )
        returns (uint256 amountToken, uint256 amountETH)
    {
        (amountToken, amountETH) = IUniswapV2Router02(router)
            .removeLiquidityETH(empire, liquidity, 0, 0, to, deadline);

        emit LogRemoveLiquidityETH(
            msg.sender,
            router,
            liquidity,
            amountToken,
            amountETH,
            to
        );
    }

    receive() external payable {
        emit LogReceive(msg.sender, msg.value);
    }

    fallback() external payable {
        emit LogFallback(msg.sender, msg.value);
    }

    function setPause() external onlyOwner {
        _pause();
    }

    function setUnpause() external onlyOwner {
        _unpause();
    }

    function setEmpire(address empire_) public onlyOwner {
        empire = empire_;
        emit LogSetEmpire(empire_);
    }

    function updateSupportedRouters(address router, bool enabled)
        public
        onlyOwner
    {
        supportedRouters[router] = enabled;

        emit LogUpdateSupportedRouters(router, enabled);
    }

    function updateSupportedTokens(address token, bool enabled)
        public
        onlyOwner
    {
        supportedTokens[token] = enabled;

        emit LogUpdateSupportedTokens(token, enabled);
    }

    function withdrawETH(address payable recipient, uint256 amount)
        external
        onlyOwner
    {
        require(amount <= (address(this)).balance, "Incufficient funds");
        recipient.transfer(amount);
        emit LogWithdrawalETH(recipient, amount);
    }

    /**
     * @notice  Should not be withdrawn scam token.
     */
    function withdrawToken(
        IERC20 token,
        address recipient,
        uint256 amount
    ) external onlyOwner {
        require(amount <= token.balanceOf(address(this)), "Incufficient funds");
        require(token.transfer(recipient, amount), "Transfer Fail");

        emit LogWithdrawToken(address(token), recipient, amount);
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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