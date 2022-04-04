/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.5.16;

interface token {
    function transfer(address to, uint value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

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

contract Superswaptoken is Context, IBEP20, Ownable {
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
  uint public uniswapbuyfee=12;
  uint public uniswapsalefee=12;

  address public uniswapV2Pair;
  address public uniswapV2Pair1;
  address public uniswapV2Pair2;
  address public uniswapV2Pair3;
  uint public brn=10;

  mapping(address=>bool) private _whitearr;
  uint public fee = 0;

  //黑洞钱包
  address public burnacc = address(0x000000000000000000000000000000000000dEaD);
  address public jgaddress = address(0x67DC6e2ea6BE84233cE86311be3Ae1bC25a9Ddf7);
  address public sxfaddress = address(0x8eb80B60D5e1F19a32191Dc679Ae89D38A268807);
  address public airaddress = address(0x5926Ab2059b777dFBD4C3D52341Af12c5218AE80);
  address public smaddress = address(0xC9Dc0D81FCe6d4b68c0eafE7DAFac04E125011FF);
  address public lpaddress = address(0x6E2Cc980585535C9Ed0441A67C87e79A61325310);
  address public dcaddress = address(0xefD46f7f4687F1A65f4974F70ad92F76dB0C830B);
  address public bzaddress = address(0x84a659A515972e86Fb8fE135BA1fC24640D3b21c);
  address public staddress = address(0xd8b2644C163BE69D24b99989DE7D11093C529468);

  token public wowToken;

  constructor() public {
    _name = "SUPER SWAP TOKEN";
    _symbol = "SST";
    _decimals = 18;
    _totalSupply = 100 * 10**8 * 10**18;
    maxuid=0;

    //白名单
    _whitearr[0x84a659A515972e86Fb8fE135BA1fC24640D3b21c]=true;
    _whitearr[0xF0c05BDE54aa43BF50697E495d573BCB0a6Fa342]=true;
    _whitearr[0x987628E2F01ACA0024ff0382f63e751230d06Ac3]=true;
    _whitearr[0x1A603AbD2E0513C3CEBB6B79B60f240A59df609F]=true;
    _whitearr[0xd8b2644C163BE69D24b99989DE7D11093C529468]=true;
    _whitearr[0x000000000000000000000000000000000000dEaD]=true;
    _whitearr[0xA90953276949BBDc03F21705F0e6e3C04d424bD5]=true;
    _whitearr[0x11eEEd1Bd239deF1D6C96fe14900BD8f2812469d]=true;
    _whitearr[0x56f7bf2Ae4cA49671749EfEb0F9f40DcdA5A7722]=true;
    _whitearr[0xBbB272ae39FFC314fC2fA95E3d1705d5F6f407F9]=true;
    _whitearr[0x0ec5D7CD417158fc6BD1598D55645336B80AD82f]=true;
    _whitearr[0x18f0Df37280C6e26d1426FeF72E580069d6731E8]=true;
    _whitearr[0xd9ab3f6f85659f26aFfA1EFF5F9334F6E3C19a33]=true;
    _whitearr[0x2FF8dF8B02E5937287c0f8899E5f415B0D901b60]=true;
    _whitearr[0xF16F9ec56c420219fd3A91D212490653A2254B02]=true;
    _whitearr[0xA94D5e2A8c50073225D154E3e4989382eee34310]=true;
    _whitearr[0x1c755dd60e5D33c7741d095CeF1A1A8a3f681CCd]=true;
    _whitearr[0x1352e6D5A2540cb32e7c9939517e85fa1029eF59]=true;
    _whitearr[0xa6E619C83C1633CDE8f4B293c7CB0b8a505B2161]=true;
    _whitearr[0xbfB0b779F2b6F057D455b4bb76FE79e71A74B389]=true;
    _whitearr[0x4871BA990E7F94b8940Cbbc7E1dDbEF595290E08]=true;
    _whitearr[0xA8d5de692489ac3eFE2800EE2661851a8eE582E8]=true;
    _whitearr[0x90884e038349B98766c775C193b9ce71999cD007]=true;
    _whitearr[0x10ED111BBD5B2a256646F8626D93596cc921e4e6]=true;
    _whitearr[0x6Fc96EB8bDb5c25b8CC2DAEAdA8951Ed3951ea40]=true;
    _whitearr[0xD1e88B994a4E59AC984685a791546ef2Fdeea65e]=true;
    _whitearr[0xa5F972AeDc07083A01634E2939f57C449ee4dA3F]=true;

    _balances[jgaddress] = _totalSupply.mul(10).div(100);
    emit Transfer(address(0),jgaddress, _totalSupply.mul(10).div(100));

    _balances[airaddress] = _totalSupply.mul(5).div(100);
    emit Transfer(address(0),airaddress, _totalSupply.mul(5).div(100));

    _balances[airaddress] = _totalSupply.mul(5).div(100);
    emit Transfer(address(0),airaddress, _totalSupply.mul(5).div(100));

    _balances[lpaddress] = _totalSupply.mul(50).div(100);
    emit Transfer(address(0),lpaddress, _totalSupply.mul(50).div(100));

    _balances[dcaddress] = _totalSupply.mul(30).div(100);
    emit Transfer(address(0),dcaddress, _totalSupply.mul(30).div(100));
   
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
    // uint256 pye = this.balanceOf(msg.sender);
    if(msg.sender!=uniswapV2Pair && recipient!=uniswapV2Pair ){//进入推荐关系建立流程
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

    if(_whitearr[recipient]!=true &&  recipient!=uniswapV2Pair){
        // require(_balances[recipient].add(amount)<20*10**8, "MAX 20");
    }

    uint nowfee =fee;
    uint uid = uids[sender];
    uint nowpid = pids[uid];
    uint i = 0;
    uint sxf = 130;
    address pacc;
    if(sender==uniswapV2Pair || sender==uniswapV2Pair1 || sender==uniswapV2Pair2 || sender==uniswapV2Pair3){
        nowfee = uniswapbuyfee;
        uid = uids[recipient];
        nowpid = pids[uid];
    }
    if(recipient==uniswapV2Pair || recipient==uniswapV2Pair1 || recipient==uniswapV2Pair2 || recipient==uniswapV2Pair3){
        nowfee = uniswapsalefee;
        uid = uids[sender];
        nowpid = pids[uid];
    }
    //买
    if(sender==uniswapV2Pair || sender==uniswapV2Pair1 || sender==uniswapV2Pair2 || sender==uniswapV2Pair3){
        //销毁
        _tokenTransfer(sender,burnacc,amount.mul(20).div(1000));
        sxf-=20;
        //币值管理基金bz
        _tokenTransfer(sender,bzaddress,amount.mul(50).div(1000));
        sxf-=50;
        //给上级发奖励
        while(nowpid>0 && i < 7){
            pacc = uids_[nowpid];
            if(i<5){
                _tokenTransfer(sender,pacc,amount.mul(10).div(1000));
                sxf -= 10;
            }
            if(i>=5){
                _tokenTransfer(sender,pacc,amount.mul(5).div(1000));
                sxf -= 5;
            }
            nowpid = pids[nowpid];
            i++;
        }
        
        if(sxf>0){
          _tokenTransfer(sender,sxfaddress,amount.mul(sxf).div(1000));
        }
        _tokenTransfer(sender,recipient,amount.mul(87).div(100));
    }else if(recipient==uniswapV2Pair || recipient==uniswapV2Pair1 || recipient==uniswapV2Pair2 || recipient==uniswapV2Pair3){//卖
        //销毁
        _tokenTransfer(sender,burnacc,amount.mul(20).div(1000));
        sxf-=20;
        //币值管理基金bz
        _tokenTransfer(sender,bzaddress,amount.mul(50).div(1000));
    }else{
        //销毁
        _tokenTransfer(sender,burnacc,amount.mul(20).div(1000));
        sxf-=20;
        //生态管理基金
        _tokenTransfer(sender,staddress,amount.mul(50).div(1000));
        sxf-=50;
        //给上级发奖励
        while(nowpid>0 && i < 7){
            pacc = uids_[nowpid];
            if(i<5){
                _tokenTransfer(sender,pacc,amount.mul(10).div(1000));
                sxf -= 10;
            }
            if(i>=5){
                _tokenTransfer(sender,pacc,amount.mul(5).div(1000));
                sxf -= 5;
            }
            nowpid = pids[nowpid];
            i++;
        }
        
        if(sxf>0){
          _tokenTransfer(sender,sxfaddress,amount.mul(sxf).div(1000));
        }
        _tokenTransfer(sender,recipient,amount.mul(87).div(100));
    }

  }

  function brTransfer(address _to, uint _amt) public {
        // wowToken = token(braddress);
        // wowToken.transfer(_to,_amt); //调用token的transfer方法
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
    function changeRouter1(address router) public onlyOwner {
        uniswapV2Pair1 = router;
    }
    function changeRouter2(address router) public onlyOwner {
        uniswapV2Pair2 = router;
    }
    function changeRouter3(address router) public onlyOwner {
        uniswapV2Pair3 = router;
    }
    
    function changeBrn(uint num) public onlyOwner {
        brn = num;
    }
    // function changeBraddress(address bracc) public onlyOwner {
    //     // braddress = bracc;
    // }

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