/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC20 {
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
  constructor ()  {
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

interface IUniswapV2Pair {
   
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  
}

interface IOASUser {
    function invites(address user) external returns(address);
    function addUser(address user,address inviter) external;
    function addressToId(address user) external returns(uint256);
    function inviteCount(address user) external view returns(uint8);
}

interface IERC721 {
    function mint(address to ,uint256 tokenId0,uint8 level) external ;
}

interface IOASGame{
    function staked(address account) external view returns (uint256,uint256 ,uint256 ,uint256 ,uint256 ,uint256 ,uint256 , uint256 , bool);
}

contract OASWorldIDO is Context, Ownable {
    
    using SafeMath for uint256;
    mapping(address => uint256) public buyer;
    mapping(address => uint256) private _balances;
    mapping(address => bool)  public whiteList;
    mapping(address => mapping (address => uint256)) private _allowances;
    struct Product {
        uint256  amountA;
        uint256  amountB;
        uint256  startTime;
        uint256  endTime;
        uint256  totalSupply;
        uint256  store;
        uint8    nftLevel;
    }///  
    uint256  nftIndex=20;
    address payable recipient;
    Product public  idoBusiness;
    Product public  idoShop;
    IOASUser  public OASUser;
    IOASGame OASGame;
    IERC20 public USDT=IERC20(0x62747217Adcba084c0Fa90494D3d423E5324Ec38);
    IERC721 public NFT=IERC721(0x0eeA249CFd2BDde5b9DbED8225049FAA596a80Bc);
    IUniswapV2Pair public WETHPair=IUniswapV2Pair(0x49f3F564D26A3BB8f0fF5101bAc425c08134e87C);
    address public WETH=0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    constructor() {
        idoBusiness=Product(350000000000000000000,350000000000000000000,1663593540,1693766340,2000,2000,5);
        idoShop=Product(3500000000,3500000000,1663593540,1693766340,2000,2000,1);
        OASUser=IOASUser(0x0Ba1e367Dae747c2fb9918690b80FbFCDb69FE6f);
        OASGame=IOASGame(0x4594fe0d40533B5A2F881C550c7b7DD75985a953);
    }  


    function updateSell(uint256 idoType,uint256 _amountA,uint256 _amountB,uint256 _start,uint256 _end,uint256 _total,uint256 _store,uint8 _nftLevel) external onlyOwner {

        Product memory _p=Product(_amountA,_amountB,_start,_end,_total,_store,_nftLevel);
        
        if(idoType==1){
            idoBusiness=_p;
        }else {
            idoShop=_p;
        }
    }

    function updateRecipient(address payable user)external onlyOwner {
        recipient=user;
    }

    function updateNftIndex(uint256 _nftIndex)external onlyOwner {
        nftIndex=_nftIndex;
    }

    function updateNft(IERC721 _addr) external  onlyOwner {
        NFT=_addr;
    }

    function claimBusiness(address inviter) external payable {
        
        uint256 amountB=idoBusiness.amountB;
        
        require(buyer[msg.sender]==0,"You have already purchased");
        require(idoBusiness.store>0,"Invalid Store");
        require(idoBusiness.startTime<block.timestamp&&idoBusiness.endTime>block.timestamp,"Not Open Sale");
        require(msg.value==needWETHByBusiness(),"Invalid WETH Amount");
        OASUser.addUser(msg.sender, inviter);
        (,,,uint256 rightLevel,,,,,)=OASGame.staked(msg.sender);
        require(rightLevel>0,"Inviter Not Staked");
        buyer[msg.sender]=amountB*2;
        recipient.transfer(msg.value);

        uint256 amount=idoBusiness.amountB;
      
        uint256 shareAmount=amount.mul(10).div(100);

        USDT.transferFrom(msg.sender,recipient,shareAmount);
        amount=amount.sub(shareAmount);
        USDT.transferFrom(msg.sender,recipient,amount);
        
        NFT.mint(msg.sender,nftIndex,5);
        nftIndex+=1;
        idoBusiness.store-=1;
    }


    function claimShop(address inviter) external payable {
        
        require(buyer[msg.sender]==0,"You have already purchased");
        require(idoShop.store>0,"Invalid Store");
        require(idoShop.startTime<block.timestamp&&idoShop.endTime>block.timestamp,"Not Open Sale");
        require(msg.value==needWETHByShop(),"Invalid WETH Amount");
         (,,,uint256 rightLevel,,,,,)=OASGame.staked(msg.sender);
        require(rightLevel>0,"Inviter Not Staked");

        OASUser.addUser(msg.sender, inviter);
        recipient.transfer(msg.value);

        buyer[msg.sender]=idoShop.amountB*2;
        uint256 amount=idoShop.amountB;
        uint256 shareAmount;
        if(rightLevel>4){
            shareAmount=amount.mul(10).div(100);
        }else{
            shareAmount=amount.mul(6).div(100);
        }
        USDT.transferFrom(msg.sender,recipient,shareAmount);
        amount=amount.sub(shareAmount);
        USDT.transferFrom(msg.sender,recipient,amount);
              
        NFT.mint(msg.sender,nftIndex,1);
        nftIndex+=1;
        idoShop.store-=1;
    }

    function updateWhiteList(address user,bool flag) external onlyOwner {
        whiteList[user]=flag;
    }

   function needWETHByShop() public view returns(uint256) {
        address token0=WETHPair.token0();
        (uint256 token0Value,uint256 token1Value,)=WETHPair.getReserves();
        if(token0==address(USDT)){
            return quote(idoShop.amountB,token0Value,token1Value);
        }else{
            return quote(idoShop.amountB,token1Value,token0Value);
        }
    }

    function needWETHByBusiness() public view returns(uint256) {
        address token0=WETHPair.token0();
        (uint256 token0Value,uint256 token1Value,)=WETHPair.getReserves();
        if(token0==address(USDT)){
            return quote(idoBusiness.amountB,token0Value,token1Value);
        }else{
            return quote(idoBusiness.amountB,token1Value,token0Value);
        }
        
    }

    function quote(uint amountA, uint reserveA, uint reserveB) public pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }
}