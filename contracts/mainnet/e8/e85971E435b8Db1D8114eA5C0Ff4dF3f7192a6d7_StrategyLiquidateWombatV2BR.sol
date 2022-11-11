/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

// File: openzeppelin-solidity-2.3.0/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: openzeppelin-solidity-2.3.0/contracts/utils/ReentrancyGuard.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the `nonReentrant` modifier
 * available, which can be aplied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

// File: contracts/SafeToken.sol

pragma solidity 0.5.16;

interface ERC20Interface {
    function balanceOf(address user) external view returns (uint256);
}

library SafeToken {
    function myBalance(address token) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(address(this));
    }

    function balanceOf(address token, address user) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(user);
    }

    function safeApprove(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeApprove");
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransfer");
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransferFrom");
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call.value(value)(new bytes(0));
        require(success, "!safeTransferETH");
    }
}

// File: contracts/Strategy.sol

pragma solidity 0.5.16;

interface Strategy {
    /// @dev Execute worker strategy. Take LP tokens + ETH. Return LP tokens + ETH.
    /// @param user The original user that is interacting with the operator.
    /// @param debt The user's total debt, for better decision making context.
    /// @param data Extra calldata information passed along to this strategy.
    function execute(address user, uint256 debt, bytes calldata data) external payable;
}

// File: contracts/wombat/IWombatPool.sol

pragma solidity 0.5.16;

interface IWombatPool {
    function quotePotentialWithdraw(address token, uint256 liquidity)
    external
    view
    returns (uint256 amount, uint256 fee);

  function quotePotentialSwap(
    address fromToken,
    address toToken,
    int256 fromAmount
  ) external
    view
    returns (uint256 potentialOutcome, uint256 haircut);

  function deposit(
    address token,
    uint256 amount,
    uint256 minimumLiquidity,
    address to,
    uint256 deadline,
    bool shouldStake
  ) external returns (uint256 liquidity);

  function withdraw(
    address token,
    uint256 liquidity,
    uint256 minimumAmount,
    address to,
    uint256 deadline
  ) external returns (uint256 amount);
}

// File: contracts/wombat/IWombatRouterV2.sol

pragma solidity 0.5.16;

interface IWombatRouterV2 {
  function wNative() external returns (address);

  function swapExactTokensForTokens(
    address[] calldata tokenPath,
    address[] calldata poolPath,
    uint256 amountIn,
    uint256 minimumamountOut,
    address to,
    uint256 deadline
  ) external returns (uint256 amountOut);

  function swapExactNativeForTokens(
    address[] calldata tokenPath,
    address[] calldata poolPath,
    uint256 minimumamountOut,
    address to,
    uint256 deadline
  ) external payable returns (uint256 amountOut);

  function swapExactTokensForNative(
    address[] calldata tokenPath,
    address[] calldata poolPath,
    uint256 amountIn,
    uint256 minimumamountOut,
    address to,
    uint256 deadline
  ) external returns (uint256 amountOut);
}

// File: contracts/ISwapV2.sol

pragma solidity 0.5.16;

interface ISwapV2 {
  function etherERC20() external pure returns (address);
  function swapQuery(uint256 amount, address src, address dest) external payable;
}

// File: contracts/StrategyLiquidateWombatV2BR.sol

pragma solidity 0.5.16;








contract StrategyLiquidateWombatV2BR is Ownable, ReentrancyGuard, Strategy {
    using SafeToken for address;

    IWombatRouterV2 public router;
    IWombatPool public wombatPool;
    address public weth;
    ISwapV2 public swap;
    address public swapWETH;

    /// @dev Create a new liquidate strategy instance.
    /// @param _router The Uniswap router smart contract.
    constructor(IWombatRouterV2 _router, IWombatPool _wombatPool, ISwapV2 _swap) public {
        router = _router;
        swap = _swap;
        swapWETH = _swap.etherERC20();
        weth = _router.wNative();
        wombatPool = _wombatPool;
    }

    /// @dev Execute worker strategy. Take LP tokens + ETH. Return LP tokens + ETH.
    /// @param data Extra calldata information passed along to this strategy.
    function execute(address /* user */, uint256 /* debt */, bytes calldata data)
        external
        payable
        nonReentrant
    {
        // 1. Find out what farming token we are dealing with.
        (address fToken, uint256 minETH, address lpToken) = abi.decode(data, (address, uint256, address));
        // 2. Remove all liquidity back to ETH and farming tokens.
        lpToken.safeApprove(address(wombatPool), uint256(-1));
        wombatPool.withdraw(fToken, lpToken.balanceOf(address(this)), 0, address(this), now);
        // 3. Convert farming tokens to ETH.
        fToken.safeApprove(address(swap), 0);
        fToken.safeApprove(address(swap), uint(-1));
        swap.swapQuery(fToken.myBalance(), fToken, swapWETH);
        // 4. Return all ETH back to the original caller.
        uint256 balance = address(this).balance;
        require(balance >= minETH, "insufficient ETH received");
        SafeToken.safeTransferETH(msg.sender, balance);
    }

    /// @dev Recover ERC20 tokens that were accidentally sent to this smart contract.
    /// @param token The token contract. Can be anything. This contract should not hold ERC20 tokens.
    /// @param to The address to send the tokens to.
    /// @param value The number of tokens to transfer to `to`.
    function recover(address token, address to, uint256 value) external onlyOwner nonReentrant {
        token.safeTransfer(to, value);
    }

    function() external payable {}
}