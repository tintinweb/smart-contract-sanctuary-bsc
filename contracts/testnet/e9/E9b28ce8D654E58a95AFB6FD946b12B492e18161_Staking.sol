// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./common.sol";
interface IBEP20Treasury{
    function claim(address recipient,uint256 amount) external;
}

//质押
contract Staking is Common{
    using SafeMath for uint256;
    //质押详情
    struct stakeInfo{
        bool status;//质押状态
        uint256 stakeTime;//质押时间
        uint256 stakeTotal;//质押数量
        uint256 stakeInterestTotal;//累计收益
        uint256 stakeInterest;//本次收益
    }
    //质押列表
    mapping(uint256 => stakeInfo) public _stakeInfo;
    //获取用户质押列表
    mapping(address => uint256[]) public _userStakeList;
    //包质押总数
    uint256 public _stakeTimes;

    //该用户质押总额
    mapping(address => uint256) public _userStakeTotal;
    //用户累计收益
    mapping(address => uint256) public _userInterestTotal;
    //质押用户列表(索引)
    mapping(uint256 => address) public _users;
    //质押用户列表
    mapping(address => uint256) public _userIds;
    //质押用户总数
    uint256 public _userNum;
    //执行利息分红时间
    mapping(uint256 => uint256) public _interestTime;
    //执行分红次数
    uint256 public _interestTimes=1;
    //日息（万分比）
    uint256 public _dayInterest = 120;
    //每天拆分执行三次
    uint256 public _interestOneDayTimes = 3;

    //全网总质押
    uint256 public _stakingTotal=0;
    //全网累计收益
    uint256 public _interestTotal;

    constructor () {
        stake(100000000000000000000);
    }
    //初始化参数
    function _init_params(uint256 dayInterest) external onlyOwner{
        _dayInterest=dayInterest;
    }
    //获取质押列表以及详情
    function getStakes(address account,uint256 index,uint256 offset) external view returns(stakeInfo [] memory infos){
        if(_userStakeList[account].length<index+offset){
            offset=_userStakeList[account].length-index;
        }
        infos=new stakeInfo[](offset);
        for(uint i;i<offset;i++){
            stakeInfo memory info=_stakeInfo[_userStakeList[account][index+i]];
            infos[i]=info;
        }
    }
    //获取用户质押数量
    function userStakeNum(address account) external view returns (uint256){
        return _userStakeList[account].length;
    }
    //质押
    function stake(uint256 amount) public{
        require(amount>0,"error1");
        // address _dol=Super(_super)._contract("dol");
        // require(_dol!=address(0),"error2");
        // require(IBEP20(_dol).balanceOf(_msgSender())>=amount,"error3");
        // IBEP20(_dol).transferFrom(_msgSender(),address(this),amount);

        //写入质押列表
        _stakeInfo[++_stakeTimes]=stakeInfo(true,block.timestamp,amount,0,0);//设置质押详情
        _userStakeList[_msgSender()].push(_stakeTimes);

        _stakingTotal+=amount;
        _userStakeTotal[_msgSender()]+=amount;
        if(_userIds[_msgSender()]==0){
            _users[++_userNum]=_msgSender();
            _userIds[_msgSender()]=_userNum;
        }
    }
    //取出
    function unStake(uint256 id) external{
        address _dol=Super(_super)._contract("dol");

        stakeInfo storage info=_stakeInfo[id];
        uint amount = info.stakeTotal;
        IBEP20(_dol).transfer(_msgSender(),amount);
        if(info.stakeInterest>0){
            amount+=info.stakeInterest;
            _userInterestTotal[_msgSender()]+=info.stakeInterest;
            _interestTotal+=info.stakeInterest;
            info.stakeInterestTotal+=info.stakeInterest;
            info.stakeInterest=0;
        }
        info.status=false;
        _stakingTotal-=amount;
        _userStakeTotal[_msgSender()]-=amount;
        // delete info;//删除质押数据
        IBEP20(_dol).transfer(_msgSender(),amount);
    }
    //提取利息
    function claim(uint256 id) external{
        address _dol=Super(_super)._contract("dol");
        address _treasury=Super(_super)._contract("treasury");
        stakeInfo storage info=_stakeInfo[id];
        require(info.stakeInterest>0,"error2");
        require(IBEP20(_dol).balanceOf(address(this))>=info.stakeInterest,"error3");
        uint amount=info.stakeInterest;
        info.stakeInterest=0;//删除当前获取利息
        info.stakeInterestTotal+=amount;//添加到当前累计收益
        _interestTotal+=amount;//添加到质押总利息
        //从国库提取收益
        IBEP20Treasury(_treasury).claim(_msgSender(),amount);
    }
    //发放利息 status为false 限制次数
    function interest(bool status) external onlyOwner{
        //当天发放利息限制次数（防止超发）
        if(status==false&&_interestTimes+1>=_interestOneDayTimes){
            //3次分红前是否超过1天
            require(block.timestamp-_interestTime[_interestTimes+1-_interestOneDayTimes]<=1 days,"error1");
        }
        for(uint i=1;i<=_stakeTimes;i++){
            stakeInfo storage info=_stakeInfo[i];
            if(info.status==true){
                info.stakeInterest+=info.stakeTotal.mul(_dayInterest).div(_interestOneDayTimes*10**4); //利息=质押总量*日息/3/10000
            }
        }
        _interestTime[_interestTimes++]=block.timestamp;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//超级合约
interface Super{
    //获取合约
    function _contract(string calldata _string) external view returns (address);
    //判断是否为超级合约
    function isSuper(address _address) external view returns (bool);
}
//公共类
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
   */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
  */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

    function mint(address account,uint256 amount) external;
    function burn(address account,uint256 amount) external;
}
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
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
   * - Subtraction cannot overflow.
   */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
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
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
   */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
   */
    function owner() public view returns (address) {
        return _owner;
    }


    /**
     * @dev Returns the address of the current owner.
   */
    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
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
//公共合约
contract Common is Ownable{
    address public _super;//超级合约
    //设置超级约地址
    function _init(address _address) external onlyOwner {
        _super=_address;
    }
    //判断超级合约
    modifier onlySuperContract() {
        require(Super(_super).isSuper(_msgSender()), "Ownable: caller is not the super");
        _;
    }
}