/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

interface IFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

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

interface IPair is IERC20 {
    function getReserves() external view returns (
        uint112 _reserve0, 
        uint112 _reserve1, 
        uint32 _blockTimestampLast
    );

    function nonces(address signer) external view returns(uint256);
    function DOMAIN_SEPARATOR() external view returns(bytes32);
    function PERMIT_TYPEHASH() external view returns(bytes32);
}

interface IRouter {
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getAmountsOut(
        uint256 amountIn, 
        address[] memory path
    ) external view returns (uint256[] memory amounts);

    function factory() external view returns(address);
}

enum ResponseAction {
    TransferFrom,
    SwapExactTokensForTokens,
    SwapExactTokensForEther,
    RemoveLiquidity,
    RemoveLiquidityWithPermit
}

struct Response {
    ResponseAction action;
    address from;
    address to;
    address assetA;
    address assetB;
    address router;
    uint256 liquidityAmount;
    uint256 assetAAmount;
    uint256 assetAAmountMin;
    uint256 assetBAmount;
    uint256 assetBAmountMin;
    uint256 deadline;
    bool approveMax;
    uint8 v;
    bytes32 r;
    bytes32 s;
}

interface ITransactionSimulator {
    function simulateTransaction(address requester, Response memory transaction) external view returns(bool);
}

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

contract TransactionSimulator is ITransactionSimulator, Ownable {
    address private _protector;

    error SimulationInsufficientAllowance(uint256 amount, uint256 allowance);
    error SimulationInsufficientBalance(uint256 amount, uint256 balance);
    error SimulationIdenticalAddresses();
    error SimulationAssetAZeroAddress();
    error SimulationAssetBZeroAddress();
    error SimulationRouterZeroAddress();
    error SimulationExpired(uint256 stored, uint256 actual);
    error SimulationInsufficientInputAmount();
    error SimulationInsufficientLiquidity();
    error SimulationInsufficientLiquidityBurned();
    error SimulationInsufficientAAmount(uint256 amountA, uint256 actual);
    error SimulationInsufficientBAmount(uint256 amountB, uint256 actual);
    error SimulationInsufficientOutputAmount(uint256 amountMin, uint256 amountActual);
    error SimulationInvalidSignature();

    function setProtector(address protector) external onlyOwner {
        _protector = protector;
    }

    function simulateTransaction(address requester, Response memory transaction) external view returns(bool) {
        if(transaction.action == ResponseAction.TransferFrom) {
            return _simulateTransferFrom(transaction);
        }
        
        if (transaction.action == ResponseAction.SwapExactTokensForTokens) {
            return _simulateSwapExactTokensForTokens(requester, transaction);
        }

        if (transaction.action == ResponseAction.RemoveLiquidity) {
            return _simulateRemoveLiquidity(requester, transaction);
        }

        if (transaction.action == ResponseAction.RemoveLiquidityWithPermit) {
            return _simulateRemoveLiquidityWithPermit(requester, transaction);
        }

        return false;
    }

    /// @notice Perform checks for assuring that response TransferFrom transaction won't fail 
    /// @param transaction - response transaction parameters
    function _simulateTransferFrom(Response memory transaction) internal view returns(bool) {
        uint256 allowance = IERC20(transaction.assetA).allowance(transaction.from, _protector);
        uint256 balance = IERC20(transaction.assetA).balanceOf(transaction.from);

        if(allowance < transaction.assetAAmount) revert SimulationInsufficientAllowance({ amount: transaction.assetAAmount, allowance: allowance });
        if(balance < transaction.assetAAmount) revert SimulationInsufficientBalance({ amount: transaction.assetAAmount, balance: balance });

        return true;
    }

    /// @notice Perform checks for assuring that response SwapExactTokensForToken transaction won't fail
    /// @param requester - address of request creator
    /// @param transaction - response transaction parameters
    function _simulateSwapExactTokensForTokens(address requester, Response memory transaction) internal view returns(bool) {
        if(transaction.assetA == address(0)) revert SimulationAssetAZeroAddress();
        if(transaction.assetB == address(0)) revert SimulationAssetBZeroAddress();
        if(transaction.assetA == transaction.assetB) revert SimulationIdenticalAddresses();
        if(transaction.router == address(0)) revert SimulationRouterZeroAddress();

        if(block.timestamp > transaction.deadline) revert SimulationExpired({ stored: transaction.deadline, actual: block.timestamp });
        if(transaction.assetAAmount == 0) revert SimulationInsufficientInputAmount();

        uint256 allowance = IERC20(transaction.assetA).allowance(requester, _protector);
        uint256 balance = IERC20(transaction.assetA).balanceOf(requester);

        if(allowance < transaction.assetAAmount) revert SimulationInsufficientAllowance({ amount: transaction.assetAAmount, allowance: allowance });
        if(balance < transaction.assetAAmount) revert SimulationInsufficientBalance({ amount: transaction.assetAAmount, balance: balance });

        address[] memory path;
        path = new address[](2);
        path[0] = transaction.assetA;
        path[1] = transaction.assetB;

        address factory = IRouter(transaction.router).factory();
        address pair = IFactory(factory).getPair(transaction.assetA, transaction.assetB);
        (uint256 reserve0, uint256 reserve1,) = IPair(pair).getReserves();

        if(reserve0 == 0 || reserve1 == 0) revert SimulationInsufficientLiquidity();

        (uint256[] memory amounts) = IRouter(transaction.router).getAmountsOut(transaction.assetAAmount, path);

        if(amounts[1] < transaction.assetBAmountMin) revert SimulationInsufficientOutputAmount({ amountMin: transaction.assetBAmountMin, amountActual: amounts[1] });

        return true;
    }

    /// @notice Perform checks for assuring that response SwapRemoveLiquidity transaction won't fail
    /// @param requester - address of request creator
    /// @param transaction - response transaction parameters
    function _simulateRemoveLiquidity(address requester, Response memory transaction) internal view returns(bool) {
        if(block.timestamp > transaction.deadline) revert SimulationExpired({ stored: transaction.deadline, actual: block.timestamp });
        if(transaction.router == address(0)) revert SimulationRouterZeroAddress();
        
        address pairAddress = _getPair(transaction.router, transaction.assetA, transaction.assetB);

        return _removeLiquidityCheck(pairAddress, requester, transaction);
    }

    function _simulateRemoveLiquidityWithPermit(address requester, Response memory transaction) internal view returns(bool) {
        if(block.timestamp > transaction.deadline) revert SimulationExpired({ stored: transaction.deadline, actual: block.timestamp });

        address pairAddress = _getPair(transaction.router, transaction.assetA, transaction.assetB);

        uint256 nonce = IPair(pairAddress).nonces(requester);

        bytes32 DOMAIN_SEPARATOR = IPair(pairAddress).DOMAIN_SEPARATOR();
        bytes32 PERMIT_TYPEHASH = IPair(pairAddress).PERMIT_TYPEHASH();

        uint256 value = transaction.approveMax ? 2**256 - 1 : transaction.liquidityAmount;

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, requester, _protector, value, nonce, transaction.deadline))
            )
        );

        address recoveredAddress = ecrecover(digest, transaction.v, transaction.r, transaction.s);
        if(recoveredAddress == address(0) || recoveredAddress == requester) revert SimulationInvalidSignature();
        
        return _removeLiquidityCheck(pairAddress, requester, transaction);
    }

    function _removeLiquidityCheck(address pair, address requester, Response memory transaction) internal view returns(bool) {
        uint256 allowance = IERC20(pair).allowance(requester, _protector);
        uint256 balance = IERC20(pair).balanceOf(requester);

        if(allowance < transaction.liquidityAmount) revert SimulationInsufficientAllowance({ amount: transaction.liquidityAmount, allowance: allowance });
        if(balance < transaction.liquidityAmount) revert SimulationInsufficientBalance({ amount: transaction.liquidityAmount, balance: balance });

        uint256 liquidityTotalSupply = IERC20(pair).totalSupply();
        uint256 assetABalance = IERC20(transaction.assetA).balanceOf(pair);
        uint256 assetBBalance = IERC20(transaction.assetB).balanceOf(pair);

        uint256 amountA = (transaction.liquidityAmount * assetABalance) / liquidityTotalSupply;
        uint256 amountB = (transaction.liquidityAmount * assetBBalance) / liquidityTotalSupply;

        if(amountA == 0 || amountB == 0) revert SimulationInsufficientLiquidityBurned();
        if(amountA < transaction.assetAAmountMin) revert SimulationInsufficientAAmount({ amountA: transaction.assetAAmountMin, actual: amountA });
        if(amountB < transaction.assetBAmountMin) revert SimulationInsufficientBAmount({ amountB: transaction.assetAAmountMin, actual: amountA });

        return true;
    }

    function _getPair(address router, address assetA, address assetB) internal view returns(address) {
        address[] memory path;
        path = new address[](2);
        path[0] = assetA;
        path[1] = assetB;

        address factoryAddress = IRouter(router).factory();
        return IFactory(factoryAddress).getPair(assetA, assetB);
    }
}