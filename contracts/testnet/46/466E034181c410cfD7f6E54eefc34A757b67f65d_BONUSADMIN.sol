/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// File: interfaces/ISwapRouter.sol


pragma solidity 0.8.17;
interface ISwapRouter {
    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}
// File: interfaces/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.10;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    // function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// File: utils/Context.sol


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

// File: utils/Ownable.sol


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

// File: library/SafeMath.sol


pragma solidity 0.8.17;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

// File: BONUSADMIN.sol



pragma solidity 0.8.17;






contract BONUSADMIN is Ownable{

    using SafeMath for uint256;
    uint256 private constant MAX = type(uint256).max; 
    address public usdt = 0x758c3B41bc9Af877AFccD8e19e55bB0237E75b95;
    address public swapRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address _hive;

    address public operator;
    
    address public raiseAccount = 0xEA71F02Df0Ee772E38839531AA96E05e9Bdf5fb8;
    address public nodeAccount = 0x0eCB9D7D59b065DbBaD66023CFE2C09755C2a443;

    event Distribute(address indexed addr, uint256 indexed value); 

    modifier onlyOwnerOrOperator() {
        require(owner() == _msgSender() || _msgSender() == operator, "Ownable: caller is not the owner or operator");
        _;
    }
  
    constructor(address nodeAccount_, address raiseAccount_){    
        nodeAccount = nodeAccount_;
        raiseAccount = raiseAccount_;

        IERC20(usdt).approve(address(swapRouter), MAX);
    }

    function distribute(uint256 sellFeePool_, uint256 buyFeePool_, uint256 nodeSellBonus_, uint256 raiseSellBonus_)public onlyOwnerOrOperator {
        
        uint256 amountToSwap = IERC20(_hive).balanceOf(address(this));

        address[] memory path = new address[](2);

        path[0] = address(_hive);

        path[1] = address(usdt);

        ISwapRouter(swapRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        _distribute(sellFeePool_,buyFeePool_,nodeSellBonus_,raiseSellBonus_);
    }

    uint256 public  Araiseamount;
    uint256 public  AtotalUsdt;
    function _distribute(uint256 sellFeePool, uint256 buyFeePool, uint256 nodeSellBonus, uint256 raiseSellBonus)internal{
                
        uint256 totalUsdt = IERC20(usdt).balanceOf(address(this));
        AtotalUsdt = totalUsdt;

        if (sellFeePool > 0){

            uint256 totalSellFeeUsdt = totalUsdt.mul(sellFeePool).mul(1e12).div(buyFeePool.add(sellFeePool));

            uint256 raiseFee = totalSellFeeUsdt.mul(raiseSellBonus).div(nodeSellBonus.add(raiseSellBonus)).div(1e12);  

            _safeTransfer(usdt,nodeAccount,totalUsdt.sub(raiseFee)); 

            _safeTransfer(usdt,raiseAccount,raiseFee);   

            
        }else {
            _safeTransfer(usdt,nodeAccount,totalUsdt);
          
        }

    }

    function _safeTransfer(address token, address to, uint value) private {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));

        require(success && (data.length == 0 || abi.decode(data, (bool))), "BONUSADMIN: TRANSFER_FAILED");
        emit Distribute(to,value);
    }


    function setRaiseAccount(address account)external onlyOwner{
        raiseAccount = account;
    }

    function setNodeAccount(address nodeAccount_)external onlyOwner{
        nodeAccount = nodeAccount_;
    }

    function setHive(address hive_)external onlyOwner{
        _hive = hive_;
        operator = hive_;
        IERC20(_hive).approve(address(swapRouter), MAX);
    }

    function withdrawToken(address token, address to)external onlyOwner{
        uint256 amount = IERC20(token).balanceOf(address(this));
        _safeTransfer(token, to, amount);
    }


}