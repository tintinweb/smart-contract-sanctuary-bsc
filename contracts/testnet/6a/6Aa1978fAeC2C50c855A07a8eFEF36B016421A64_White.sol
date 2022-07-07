pragma solidity 0.5.16;
import "./bankCommon.sol";

//白名单
contract White is BankCommon{
    uint256 public _whiteAmount=200*10**18;//u单价
    uint256 public _whiteDol=200*10**18;//得到的dol数量
    mapping(address=>bool) public _whites;//白名单
    uint256 public _releasePercentage=50;//线性释放比例
    // constructor (address _superRouter) Common(_superRouter) public {}
    constructor () public {}
    //初始化合约参数
    function _init_params(uint256 whiteAmount,uint256 release) public {
        require(whiteAmount>0);
        require(release<=100&&release>=0);
        _whiteAmount=whiteAmount;
        _releasePercentage=release;
    }
    //购买白名单
    function buyWhite() external{
        require(_whites[_msgSender()]==false);
        _whites[_msgSender()];
        address _pay=Super(_super)._contract("pay");
        require(address(_pay)!=address(0));
        //支付对应token (需授权)
        IBEP20(_pay).transferFrom(_msgSender(),address(this),_whiteAmount);
        _setBalance(_msgSender(),_whiteDol.mul(100-_releasePercentage).div(100));
        _setReleaseBalance(_msgSender(),_whiteDol.mul(_releasePercentage).div(100));
    }
    //设置白名单
    function setWhite(address[] calldata whiteAddresses) external onlyOwner{
        for(uint256 i;i<whiteAddresses.length;i++){
            _whites[whiteAddresses[i]]=true;
            _setBalance(whiteAddresses[i],_whiteDol.mul(100-_releasePercentage).div(100));
            _setReleaseBalance(whiteAddresses[i],_whiteDol.mul(_releasePercentage).div(100));
        }
    }
}

pragma solidity 0.5.16;

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
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
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
    constructor () internal {
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
    using SafeMath for uint256;
    address public _super;//超级合约
    // constructor(address _address) public{
    //   _super=_address;
    // }
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

pragma solidity 0.5.16;

import "./common.sol";
//公共提现类
contract BankCommon is Common{
    //可提现余额
    mapping (address => uint256) public _mybalance;
    //线性释放
    mapping (address => mapping(uint256=>mapping(string => uint256))) public _release;
    mapping (address => uint256) public _release_num;
    uint256 _releaseTime=5*24*3600; //默认5天线性释放
    //设置线性释放时间 单位（秒）
    function setReleaseTime(uint256 releaseTime) external onlyOwner{
        _releaseTime=releaseTime;
    }
    function transfer(address token,address account,uint256 amount) external onlyOwner{
        IBEP20(token).transfer(account,amount);
    }
    //赋予余额
    function _setBalance(address account,uint256 amount) internal{
        _mybalance[account]=amount;
    }
    //用户提现
    function withdraw() external returns(uint256 amount){
        require(_mybalance[_msgSender()] >0,"The account does not have enough money");
        address _dol=Super(_super)._contract("dol");
        require(address(_dol)!=address(0));
        require(IBEP20(_dol).balanceOf(address(this)) >= _mybalance[_msgSender()],"The contract does not have enough money");
        amount=_mybalance[_msgSender()];
        _mybalance[_msgSender()]=0;
        IBEP20(_dol).transfer(_msgSender(),amount);
    }
    //设置线性释放余额
    function _setReleaseBalance(address account,uint256 amount) internal{
        _release[account][_release_num[account]]["total"]=amount;
        _release[account][_release_num[account]]["balance"]=amount;
        _release[account][_release_num[account]]["start_time"]=block.timestamp;
        _release[account][_release_num[account]]["withdraw_time"]=block.timestamp;
        _release[account][_release_num[account]]["end_time"]=block.timestamp.add(_releaseTime);
        _release_num[account]+=1;
    }
    //获取线性释放总额
    function getReleaseTotalBalance(address account) public view returns (uint256 amount){
        require(_release_num[account]>0);
        for(uint i;i<_release_num[account];i++){
            if(_release[account][i]["balance"]>0){
                amount+=_release[account][i]["balance"];
            }
        }
    }
    //获取线性可释放余额
    function getReleaseBalance(address account) public view returns (uint256 amount){
        if(_release_num[account]<=0){
            amount=0;
        }else{
            for(uint i;i<_release_num[account];i++){
                if(_release[account][i]["balance"]>0){
                    if(block.timestamp>=_release[account][i]["end_time"]){
                        amount+=_release[account][i]["balance"];
                    }else{
                        amount += _release[account][i]["balance"]*(block.timestamp-_release[account][i]["withdraw_time"])/((_release[account][i]["end_time"]-_release[account][i]["withdraw_time"]));
                    }
                }
            }
        }
    }
    //用户线性提现 从本合约取出
    function withdrawRelease() external returns (uint256 amount){
        uint256 temp;
        address account=_msgSender();
        for(uint i;i<_release_num[account];i++){
            if(_release[account][i]["balance"]>0){
                if(block.timestamp>=_release[account][i]["end_time"]){
                    amount+=_release[account][i]["balance"];
                    _release[account][i]["balance"]=0;
                }else{
                    temp = _release[account][i]["balance"]*(block.timestamp-_release[account][i]["withdraw_time"])/((_release[account][i]["end_time"]-_release[account][i]["withdraw_time"]));
                    _release[account][i]["balance"]=_release[account][i]["balance"].sub(temp);
                    amount+=temp;
                }
            }
        }
        address _dol=Super(_super)._contract("dol");
        require(address(_dol)!=address(0));
        require(IBEP20(_dol).balanceOf(address(this)) >= amount,"The contract does not have enough money");
        IBEP20(_dol).transfer(account,amount);
    }
}