/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

/**
 *Submitted for verification at BscScan.com on 2021-10-17
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.5.16;

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
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
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

contract BEP20Cardano is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  //推荐关系
  uint public maxuid;//最大用户id
  mapping(address => uint) public uids;//address=>uid
  mapping(uint => address) public uids_;//uid=>address
  mapping(uint => uint) public pids; //uid=>pid

  //lp矿池手续费
  uint public uniswapbuyfee=15;
  uint public uniswapsalefee=15;

  address public uniswapV2Pair;

  mapping(address=>bool) private _whitearr;
  uint public fee = 3;

  //黑洞钱包
  address public burnacc = address(0x000000000000000000000000000000000000dEaD);
  //慈善钱包
  address public csacc = address(0x0F1ee55359620E81aB531C8D85BD0097e7BB8Df7);
  //营销钱包
  address public yxacc = address(0xA8567B50460E295c0d8CB587125Cb702FFcB9559);
  //奖励钱包
  address public jlacc = address(0x5Bf4d340aa84246BA472E05AC616bbF7a05cC867);
  //回流钱包
  address public hlacc = address(0x29c7C0BffA4A49Bdb698FbBB95A6c1E2373a45F6);

  //锁仓实现
  uint256 public startTime;//时间基数
  address private _locker1;
  address private _locker2;
  address private _locker3;
  address private _locker4;

  constructor() public {
    _name = "worldnft";
    _symbol = "WNFT";
    _decimals = 8;
    _totalSupply = 2200000000 * 10**8;
    maxuid=0;
    // _balances[msg.sender] = _totalSupply;
    _locker1 = 0x64D8CEc90A58a0aE57Ae6C44b5c52E631C2D0447;
    _locker2 = 0x4e3B6D8e773B7066c5604434b807E375B6430E4c;
    _locker3 = 0x272b9B628e25a658754F8f3150C075B5926DE472;
    _locker4 = 0x3e817228d1b83B7999C342c10A98ACED993bcB0c;

    //白名单地址
    _whitearr[_locker1] = true;
    _whitearr[_locker2] = true;
    _whitearr[_locker3] = true;
    _whitearr[_locker4] = true;
    _whitearr[0x855A2A4D8C79e74CA3Bc1B1664B9911E7F04486D] = true;
    _whitearr[0xaD84d04b7d83F215064a97A74b31D3709aD9D75E] = true;
    _whitearr[0x5Ec61A82b807F56d46E3130139D2Ec88b933E123] = true;
    _whitearr[0x0DDf6c0335CC899E713F8eB9e87169DedFa9c945] = true;
    _whitearr[0x098afee29E144121c551b4C76A8f228208b3966c] = true;
    _whitearr[0x5218ab445cDaE200754A9daAF8c35D2F64FB3bD3] = true;
    _whitearr[0x776f2bC8D4dd259047CA78012627d2cc5cE7631D] = true;
    _whitearr[0x27fD1f85C5352EAC95cF4215636baAF1978Cc211] = true;
    _whitearr[0x5Bf4d340aa84246BA472E05AC616bbF7a05cC867] = true;
    _whitearr[0x4701a84EBED61A2132fF882Ba89026f49E27FD77] = true;
    _whitearr[0xa073d97c108593Aa382F0624f98fB97dF98E2F07] = true;
    _whitearr[0x36Be0d9c4173Ad63f833Bea42164214f8eb8a918] = true;
    _whitearr[0x68Ea723e651ed12b83024D503A95c6ff4D9385c9] = true;
    _whitearr[0x7735f963303D3dDBA983F0DBa042a353A08C188e] = true;
    _whitearr[0x7a945A04d06Ffa24DA5897e67C6867E613A22892] = true;
    _whitearr[0x22f14806573d01872D3cB7380D972d5A335248bf] = true;
    _whitearr[0x129f542843AF0ed078580C245e67B07f2B998b76] = true;
    _whitearr[0x0F318f3273889125e6c51Eaa2eC0682ee539B3F7] = true;
    _whitearr[0x71752D5912625c669B9C04Dc9af87036827Af8D1] = true;
    _whitearr[0xA8567B50460E295c0d8CB587125Cb702FFcB9559] = true;
    _whitearr[0xc0bA592E7b8ab20dB13fEB00158a3b17D2Ae86e2] = true;
    _whitearr[0xa8103F5d1A07961696c2b0fEd65d77Bb4A03Cf9e] = true;

    _balances[_locker1] = _totalSupply.div(100).mul(30);
    _balances[_locker2] = 150786997 * 10**8;
    _balances[_locker3] = _totalSupply.div(100).mul(15);
    _balances[_locker4] = _totalSupply.div(100).mul(10);
    _balances[0x000000000000000000000000000000000000dEaD] = _totalSupply.div(100).mul(25);
    // _balances[0x27fD1f85C5352EAC95cF4215636baAF1978Cc211] = 289213003 * 10**8;
    _balances[0xEeE3410f3Be0C4712D1C5F2033AcC13434B8F4f6] = 289213003 * 10**8;

    // emit Transfer(address(0), msg.sender, _totalSupply);
    emit Transfer(address(0),_locker1, _totalSupply.div(100).mul(30));
    emit Transfer(address(0),_locker2, 150786997 * 10**8);
    emit Transfer(address(0),_locker3, _totalSupply.div(100).mul(15));
    emit Transfer(address(0),_locker4, _totalSupply.div(100).mul(10));
    emit Transfer(address(0),0x000000000000000000000000000000000000dEaD, _totalSupply.div(100).mul(25));
    // emit Transfer(address(0),0x27fD1f85C5352EAC95cF4215636baAF1978Cc211, 289213003 * 10**8);
    emit Transfer(address(0),0xEeE3410f3Be0C4712D1C5F2033AcC13434B8F4f6, 289213003 * 10**8);
  }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address) {
    return owner();
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external returns (bool) {
    //查询转账用户余额
    uint256 pye = this.balanceOf(msg.sender);
    if(pye > 1000*10**8 && pids[uids[recipient]]<=0 && msg.sender!=uniswapV2Pair && recipient!=uniswapV2Pair && recipient!=_locker1 && recipient!=_locker2 && recipient!=_locker3 && recipient!=_locker4){//如果用户余额大于1000枚进入推荐关系建立流程
        setpid(recipient);
    }
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  //推荐关系建立函数
  function setpid(address recipient) internal returns(bool){
      //1)检索是不是分配了uid
      uint pid;
      uint uid;
      if(uids[msg.sender]>0){
        pid = uids[msg.sender];
      }else{
        maxuid = maxuid.add(1);
        uids[msg.sender] = maxuid;
        uids_[maxuid] = msg.sender;
        pid  = maxuid;
      }
      if(uids[recipient]>0){
        uid = uids[recipient];
      }else{
        maxuid = maxuid.add(1);
        uids[recipient] = maxuid;
        uids_[maxuid] = recipient;
        uid  = maxuid;
      }
      //uid=>pid 对检查 uid是否已有上级
      if(pids[uid]>0){
        return false;
      }
      //uid=>pid 对检查 pid的上级链条是否包含UID
      //检查用户是不是在用户的推荐线上
      uint nowpid = pids[pid];
      uint i = 0;
      while(nowpid > 0){
         if(nowpid==uid){
            return false;
         }
         nowpid = pids[nowpid];
         i++;
      }
      pids[uid]=pid;
      return true;
  }

  //查询推荐关系
  function getpid(address account) external view returns (uint256) {
    uint uid;
    uid = uids[account];
    return pids[uid];
  }
  //查询uid
  function getuid(address account) external view returns (uint256) {
    uint uid;
    uid = uids[account];
    return uid;
  }
  //查询acc
  function getacc(uint uid) external view returns (address) {
    address acc;
    acc = uids_[uid];
    return acc;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }


  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    uint nowfee =fee;
    uint uid = uids[sender];
    uint nowpid = pids[uid];
    uint i = 0;
    uint sxf = 30;
    address pacc;
    if(sender==uniswapV2Pair){
        nowfee = uniswapbuyfee;
        uid = uids[recipient];
        nowpid = pids[uid];
        require(_balances[recipient].add(amount)<500000 * 10 ** 8,"MAX:500000");
    }
    if(recipient==uniswapV2Pair){
        nowfee = uniswapsalefee;
        uid = uids[sender];
        nowpid = pids[uid];
        require(amount<_balances[recipient].mul(90).div(100),"MAX:90%");
    }
    //手续费15
    if(_whitearr[sender]!=true && _whitearr[recipient]!=true && nowfee==15){
        _tokenTransfer(sender,burnacc,amount.mul(4).div(100));//销毁
        _tokenTransfer(sender,hlacc,amount.mul(4).div(100));//回流
        _tokenTransfer(sender,csacc,amount.mul(1).div(100));//慈善
        _tokenTransfer(sender,yxacc,amount.mul(3).div(100));//营销
        _tokenTransfer(sender,recipient,amount.mul(100-nowfee).div(100));
        //给上级发奖励
        while(nowpid>0 && i < 8){
            pacc = uids_[nowpid];
            if(i==0){
               _tokenTransfer(sender,pacc,amount.mul(2).div(100));
               sxf -= 20;
            }
            if(i==1 || i==3 || i==5 || i==7){
               _tokenTransfer(sender,pacc,amount.mul(1).div(1000));
               sxf -= 1;
            }
            if(i==2 || i==4 || i==6){
               _tokenTransfer(sender,pacc,amount.mul(2).div(1000));
               sxf -= 2;
            }
            nowpid = pids[nowpid];
            i++;
        }
        if(sxf>0){
          _tokenTransfer(sender,jlacc,amount.mul(sxf).div(1000));
        }
    }
    //手续费3
    if(_whitearr[sender]!=true && _whitearr[recipient]!=true && nowfee==3){
        _tokenTransfer(sender,burnacc,amount.mul(3).div(100));//销毁
        _tokenTransfer(sender,recipient,amount.mul(100-nowfee).div(100));
    }
    //白名单
    if(_whitearr[sender]==true && _whitearr[recipient]==true){
        _tokenTransfer(sender,recipient,amount);
    }

  }

  function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

}