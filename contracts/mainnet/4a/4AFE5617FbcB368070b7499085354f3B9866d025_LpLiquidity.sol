/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

pragma solidity >=0.6.12;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}



interface IERC20 {
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}



pragma solidity >=0.6.12;

pragma solidity >=0.6.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "e0");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ow1");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ow2");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract GasSupply is Ownable  {
    address payable private gasAddress;
    uint256 gasLimit;

    constructor () internal {
        gasAddress = _msgSender();
        gasLimit = 1e15;
    }

    function GasAddress() public view returns (address) {
        return gasAddress;
    }


    function SetGasAddress(address payable _addr) public onlyOwner{
        gasAddress=_addr;
    }

    function SetGasLimit(uint256 limit) public onlyOwner{
        gasLimit=limit;
    }

    function TrasnferGas()  internal {
        require(msg.value==gasLimit,"must supply gas");

        gasAddress.transfer(gasLimit);
    }
}



library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

contract LpLiquidity is Ownable,ReentrancyGuard,GasSupply {
    using SafeMath for uint256;
    //sweet token
    address immutable public xtoken;
    //lp token
    address  immutable public lptoken;

    struct PoolData{
        //all global weight
        uint256 totalWeight;

        //per profit
        uint256 accTokenReward;

        //last balance
        uint256 lastBalance;

        //all withdraw num
        uint256 totalWithdraw;

    }

    struct UserInfo {
        //deposit amount
        uint256 deposit;
        //Withdrawn amount
        uint256 withdraw;
        //Last updated weight
        uint256 lastWeight;
        //Total historical income
        uint256 reward;
        //Each benefit from last update
        uint256 accTokenReward;
    }


    uint256 public DIVLEN=1e18;

    mapping(address=>UserInfo) public userManager;

    PoolData public pool;

    event withdraw(address _user,uint256 _num,uint256 _cur);

    //_x TCOIN address,_lp LP ERC20 address
    constructor(address _x,address _lp) public {
        xtoken = _x;
        lptoken=_lp;
    }


    function Deposit(uint256 num) payable   public nonReentrant{
        TrasnferGas();
        TransferHelper.safeTransferFrom(lptoken,msg.sender,address(this),num);

        _updatePoolData(num,true);
    }


    function PayBack(uint256 num)  payable  public nonReentrant{

        TrasnferGas();
        UserInfo memory u =  userManager[msg.sender];

        require(u.deposit>=num,"must have enough lp");

        TransferHelper.safeTransfer(lptoken,msg.sender,num);

        _updatePoolData(num,false);

    }


    function WithdrawReward()  payable public nonReentrant{
         TrasnferGas();
        _updatePoolData(0,true);

        UserInfo storage u =  userManager[msg.sender];

        uint256 allreward= u.reward.sub(u.withdraw);

        require(allreward>0,"must have enough profit");

        TransferHelper.safeTransfer(xtoken,msg.sender,allreward);

        u.withdraw=u.withdraw.add(allreward);

        pool.totalWithdraw=pool.totalWithdraw.add(allreward);

        emit withdraw(msg.sender,allreward,block.timestamp);

    }

    //global PoolData update
    //addNum: update num
    //opt :buy direction is true,sell direction is false
    function _updatePoolData(uint256 addNum,bool opt) internal{

       uint256 addRewardWeight =  addNum;
    
       uint256 curBalance = _getCurBalance();

       uint256 diffBalance =  curBalance.sub(pool.lastBalance);
    
       if (pool.totalWeight>0){
            pool.accTokenReward = pool.accTokenReward.add(diffBalance.mul(DIVLEN).div(pool.totalWeight));
       }
       
        if(addNum>0){
            if(opt){    
                pool.totalWeight = pool.totalWeight.add(addRewardWeight);
            
            }else{
                pool.totalWeight = pool.totalWeight.sub(addRewardWeight);
            }
        }

       pool.lastBalance = curBalance;

       _updateUserData(addRewardWeight,opt);
    }

    //addNum: update num;
    //opt :buy direction is true,sell direction is false
    function _updateUserData(uint256 addNum,bool opt) internal{

       uint256 addRewardWeight =  addNum;

       UserInfo storage u =  userManager[msg.sender];

       uint256 duringReward = u.lastWeight.mul(pool.accTokenReward.sub(u.accTokenReward)).div(DIVLEN);

       u.reward=u.reward.add(duringReward);

      if(addRewardWeight>0){
        if(opt){
             u.lastWeight =  u.lastWeight.add(addRewardWeight);

             u.deposit=u.deposit.add(addNum);
          }else{
             u.lastWeight =  u.lastWeight.sub(addRewardWeight);

             u.deposit=u.deposit.sub(addNum);
        }
      }

      u.accTokenReward = pool.accTokenReward;
    }


    function _getCurBalance() internal view returns (uint256){

        uint256 curBalance = IERC20(xtoken).balanceOf(address(this));

        return pool.totalWithdraw.add(curBalance);
    }

    function getReward() public view returns (uint256){
       uint256 curBalance = _getCurBalance();

       uint256 diffBalance =  curBalance.sub(pool.lastBalance);

      uint256   accTokenReward;

       if (pool.totalWeight>0){
           accTokenReward = pool.accTokenReward.add(diffBalance.mul(DIVLEN).div(pool.totalWeight));
       }else{
           accTokenReward = pool.accTokenReward;
       }

        UserInfo memory u =  userManager[msg.sender];

        uint256 duringReward = u.lastWeight.mul(accTokenReward.sub(u.accTokenReward)).div(DIVLEN);

        return u.reward.add(duringReward).sub(u.withdraw);

    }

}