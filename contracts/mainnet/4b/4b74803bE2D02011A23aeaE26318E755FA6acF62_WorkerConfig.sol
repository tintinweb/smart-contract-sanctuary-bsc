// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./access/Operatable.sol";
import "./interfaces/ISharpeLib.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WorkerConfig is Operatable
{
    int256[] public Rates;
    int256[] public Times;
    int256 public TotalTime;
    int256[] public RdivT;
    int256 public TSum;
    int256 public RdivTSum;
    uint256 public size;
    uint256 public idx;
    uint256 public LastFeeCollected;
    uint256 public ManagementFeePerSec;
    address public ShareToken;
    int256 public RATE_PRECISION = 1e18;
    ISharpeLib public SharpeLib;
    event lognumber(
        int256 number
    );
    constructor(address sharpeLib, address shareToken){
        size = 30;
        idx = 0;
        SharpeLib = ISharpeLib(sharpeLib);
        ShareToken = shareToken;
    }
    function SetParams(uint256 managementFeePerSec, address shareToken) public onlyOperator
    {
        ShareToken = shareToken;
        ManagementFeePerSec = managementFeePerSec;
    }
    
    function Add(int256 rate, int256 time)  public onlyOwner
    {
        int256 sqrtT = int256(sqrt(uint256(time * RATE_PRECISION / (365*24*3600))));
        emit lognumber(sqrtT);
        if(size > Rates.length){
            Rates.push(rate);
            Times.push(sqrtT);
            TSum = TSum + sqrtT;
            TotalTime = TotalTime + sqrtT * sqrtT;
            int256 rdivt = rate * RATE_PRECISION / sqrtT;
            RdivT.push(rdivt);
            RdivTSum = RdivTSum + rdivt;
        }
        else
        {
            Rates[idx] = rate;
            TSum = TSum - Times[idx] + sqrtT;
            TotalTime = TotalTime - Times[idx] * Times[idx] + sqrtT * sqrtT;
            Times[idx] = sqrtT;
            
            int256 rdivt = rate * RATE_PRECISION / sqrtT;
            RdivTSum = RdivTSum - RdivT[idx] + rdivt;
            RdivT[idx] = rdivt;
            
        }
        idx = (idx + 1) % size;
    }
    function sqrt(uint256 x) internal pure returns(uint256)
    {
        if(x == 0){
            return 0;
        }
        uint256 z =(x + 1)/ 2;
        uint256 y = x;

        //In this case, z is 1 minimum so no divided by 0 would happen
        while(z < y){
            y = z;
            z =(x / z + z)/ 2;
        }
        return y;
    }
    
    function Sharpe() public view returns(int256)
    {
        if(Rates.length < 2){
            return 0;
        }
        require(TSum > 0, "Time series emmpty.");
        int256 u = RdivTSum / TSum;
        int256 sum = 0;
        for(uint i = 0; i < RdivT.length; i++){
            sum = sum + (RdivT[i] - u * Times[i]) * (RdivT[i] - u * Times[i]);
        }
        sum = int256(sqrt(uint256(sum / (int256(RdivT.length) - 1))));
        if(sum == 0 && RdivTSum == 0)
        {
            return 0;
        }
        //If sharpe too large
        else if(sum * 4300 * 30 * 10 ** 9 < u){
            return 43 * 30 * 10 ** 20; 
        }
        else
        {
            return u * 10 ** 27 / sum;
        }
        
    }
    function ManagerDiscount() public view returns(int256[2] memory)
    {
        if(Rates.length == 0){
            return [int256(0), int256(0)];
        }
        int256 sharpeSqrtT = int256(sqrt(uint256(TotalTime) / Rates.length)) * Sharpe() / 10 ** 9;
        int256 managerDiscount = SharpeLib.SharpeToMDF(sharpeSqrtT);
        return [managerDiscount, sharpeSqrtT];
    }
    function PendingManagementFee() public view returns (uint256) {
        uint256 secondsFromLastCollection = block.timestamp - LastFeeCollected;
        return (IERC20(ShareToken).totalSupply() * ManagementFeePerSec * secondsFromLastCollection) / 1e18;
    }
    function PendingManagementFee_Test(uint256 time) public view returns (uint256) {
        uint256 secondsFromLastCollection = time - LastFeeCollected;
        return (IERC20(ShareToken).totalSupply() * ManagementFeePerSec * secondsFromLastCollection) / 1e18;
    }
    function SetLastFeeCollected(uint256 time) public onlyOwner
    {
        LastFeeCollected = time;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';
import "@openzeppelin/contracts/access/Ownable.sol";

contract Operatable is Ownable {
    address private Operator;
    
    event OperatorUpdated(address indexed previousOperator, address indexed newOperator);
    function operator() public view returns(address) 
    {
        return Operator;
    }
    modifier onlyOperator() 
    {
        require(operator() == _msgSender(), "Ownable: caller is not the operator");
        _;
    }
    function updateOperator(address newOperator) public onlyOwner 
    {
        require(newOperator != address(0), "Ownable: new operator is the zero address");
        _updateOperator(newOperator);
    }
    
    function emergencyWithdraw(address token, address to,  uint256 value) public onlyOwner 
    {
        TransferHelper.safeTransfer(token, to , value);
    }
    /**
     * @dev Update operator of the contract
     * Internal function without access restriction.
     */
    function _updateOperator(address newOperator) internal {
        address previousOperator = Operator;
        Operator = newOperator;
        emit OperatorUpdated(previousOperator, Operator);
    }
    
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISharpeLib{
    function SharpeToMDF(int256 sharpe) external view returns(int256);
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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

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