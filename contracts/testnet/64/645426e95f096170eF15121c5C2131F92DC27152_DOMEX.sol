/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

// "SPDX-License-Identifier:MIT" 
pragma solidity ^0.8.7; 
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
abstract contract Context { 
  function _msgSender() internal view returns (address payable) { 
    return payable(msg.sender); 
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
abstract contract Ownable is Context { 
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
/* 
 * @title DOMEX Token Contract 
 * @author [email protected] 
 * @notice DOMEX 토큰은 BEP20 표준을 구현하였습니다. 
 */ 
contract DOMEX is Context, IBEP20, Ownable { 
  // uint256 자료형에 대해 SafeMath 라이브러리를 적용한다 
  using SafeMath for uint256; 
  // 잔액을 저장할 스토리지 
  mapping (address => uint256) private _balances; 
  // 승인 내역을 저장할 스토리지 
  mapping (address => mapping (address => uint256)) private _allowances; 
  // 총 공급량 
  uint256 private _totalSupply; 
  // 자릿수 
  uint8 private _decimals; 
  // 토큰 심볼 
  string private _symbol; 
  // 토큰 이름 
  string private _name; 
  // 생성자 - 컨트랙트를 배포할 때 한번만 실행 된다 
  constructor() { 
    _name = "DOMEX"; 
    _symbol = "DMX"; 
    _decimals = 18; 
    _totalSupply = 10000000000 * 10 ** 18; 
    _balances[msg.sender] = _totalSupply; 
    emit Transfer(address(0), msg.sender, _totalSupply); 
  } 
  /** 
   * @notice 토큰 이름을 반환한다 
   */ 
  function name() override external view returns (string memory) { 
    return _name; 
  } 
  /** 
   * @notice 토큰 심볼을 반환한다 
   */ 
  function symbol() override external view returns (string memory) { 
    return _symbol; 
  } 
  /** 
   * @notice 토큰 자릿수를 반환한다 
   */ 
  function decimals() override external view returns (uint8) { 
    return _decimals; 
  } 
  /** 
   * @notice 토큰 총 공급량을 반환한다 
   */ 
  function totalSupply() override external view returns (uint256) { 
    return _totalSupply; 
  } 
  /** 
   * @notice 인수로 받은 계정의 토큰 잔액을 반환한다 
   */ 
  function balanceOf(address account) override external view returns (uint256) { 
    return _balances[account]; 
  }   
  /** 
   * @notice 토큰 소유자를 반환한다 
   */ 
  function getOwner() override external view returns (address) { 
    return owner(); 
  } 
  /** 
   * @notice 함수 호출자의 토큰을 토큰 수령자에게 입력한 수량 만큼 전송한다 
   * @dev  
   *  - 토큰 수령자의 주소가 0 이 되면 안된다 
   *  - 함수 호출자의 잔액이 보내려는 수량 보다 많아야 한다 
   *  - 위의 확인 로직들은 private _transfer 함수에 구현한다 
   */ 
  function transfer(address recipient, uint256 amount) override external returns (bool) { 
    _transfer(_msgSender(), recipient, amount); 
    return true; 
  } 
  /** 
   * @notice sender 의 토큰을 recipient 에게 압력한 수량 만큼 전송한다 
   * @dev 
   *  - 보내는 사람의 주소와 받는 사람의 주소가 0이 되면 안된다 
   *  - 보내는 사람의 잔액이 보내는 금액 보다 작으면 안된다 
   *  - 함수 호출자는 보내는 사람의 토큰에 대해서 amount 이상의 허가가 있어야 한다 
   *  - Approve 이벤트도 호출해야 한다 
   */ 
  function transferFrom(address sender, address recipient, uint256 amount) override external returns (bool) { 
    _transfer(sender, recipient, amount); 
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance")); 
    return true; 
  } 
  /** 
   * @notice sender 의 토큰을 recipient 에게 amount 만큼 전송한다 
   * @dev 이 함수는 transfer 함수의 실제 구현부 이다. trasferFrom 의 구현부와 중복되는 로직을 메소드화 시켰다 
   *  - sender 의 주소가 0 이 되면 안된다  
   *  - recipient 의 주소가 0 이 되면 안된다 
   *  - sender 의 잔액이 반드시 보내려는 수량 보다 많아야 한다 
   */ 
  function _transfer(address sender, address recipient, uint256 amount) internal { 
    // sender 의 주소가 0 인지 확인하고, 0 이라면 에러를 반환한다 
    require(sender != address(0), "The address of sender must not be 0."); 
    // recipient 의 주소가 0 인지 확인하고, 0 이라면 에러를 반환한다 
    require(recipient != address(0), "The address of recipient must not be 0."); 
    // sender 의 잔액을 amount 만큼 차감한다.  
    // 동시에 sender 의 잔액이 amount 보다 작으면 에러를 반환한다 
    // 에러는 SafeMath 에 require 로 구현되어 있다 
    _balances[sender] = _balances[sender].sub(amount, "The balance of sender must be greater than the amount to be sent"); 
    // recipient 의 잔액을 전송액 만큼 가산한다. 
    _balances[recipient] = _balances[recipient].add(amount); 
    // 전송 이벤트를 호출한다 
    emit Transfer(sender, recipient, amount); 
  } 
  /** 
   * @notice 함수 호출자의 토큰을 토큰 수령자에게 입력한 금액에서 수수료를 차감한 만큼 전송한다 
   * @dev  
   *  - 토큰 수령자의 주소가 0 이 되면 안된다 
   *  - 함수 호출자의 잔액이 보내려는 수량 보다 많아야 한다 
   *  - 위의 확인 로직들은 private _transfer 함수에 구현한다 
   */ 
  function transferWithFee(address recipient, uint256 amount, uint256 fee) external returns (bool) { 
    _transferWithFee(_msgSender(), recipient, amount, fee); 
    return true; 
  } 
  /** 
   * @notice sender 의 토큰을 recipient 에게 압력한 금액에서 수수료를 차감한 만큼 전송한다 
   * @dev 
   *  - 보내는 사람의 주소와 받는 사람의 주소가 0이 되면 안된다 
   *  - 보내는 사람의 잔액이 보내는 금액 보다 작으면 안된다 
   *  - 함수 호출자는 보내는 사람의 토큰에 대해서 amount 이상의 허가가 있어야 한다 
   *  - Approve 이벤트도 호출해야 한다 
   */ 
  function transferFromWithFee(address sender, address recipient, uint256 amount, uint256 fee) external returns (bool) { 
    _transferWithFee(sender, recipient, amount, fee); 
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance")); 
    return true; 
  } 
  /** 
   * @notice sender 의 토큰을 recipient 에게 amount 에서 수수료를 차감한 만큼 전송한다. 
   * @dev  
   *  - sender 의 주소가 0 이 되면 안된다  
   *  - recipient 의 주소가 0 이 되면 안된다 
   *  - sender 의 잔액이 반드시 보내려는 수량 보다 많아야 한다 
   */ 
  function _transferWithFee(address sender, address recipient, uint256 amount, uint256 fee) internal { 
    // sender 의 주소가 0 인지 확인하고, 0 이라면 에러를 반환한다 
    require(sender != address(0), "The address of sender must not be 0."); 
    // recipient 의 주소가 0 인지 확인하고, 0 이라면 에러를 반환한다 
    require(recipient != address(0), "The address of recipient must not be 0."); 
    // 수수료 차감 전송액을 구한다 
    uint transferAmount = amount.sub(fee); 
    // sender 의 잔액을 amount 만큼 차감한다.  
    // 동시에 sender 의 잔액이 amount 보다 작으면 에러를 반환한다 
    // 에러는 SafeMath 에 require 로 구현되어 있다 
    _balances[sender] = _balances[sender].sub(amount, "The balance of sender must be greater than the amount to be sent"); 
    // recipient 의 잔액을 수수료 차감 전송액 만큼 가산한다. 
    _balances[recipient] = _balances[recipient].add(transferAmount); 
    // 전송 이벤트를 호출한다 
    emit Transfer(sender, recipient, transferAmount); 
    // owner 의 잔액을 전송 수수료 만큼 가산한다 
    _balances[owner()] = _balances[owner()].add(fee); 
    // 전송 이벤트를 호출한다 
    emit Transfer(sender, owner(), fee); 
  } 
  /** 
   * @dev spender 에게 amount 만큼의 토큰을 인출할 권리를 부여한다.  
   * 
   *  - `spender` 의 주소는 0 이 되면 안된다 
   */ 
  function approve(address spender, uint256 amount) override external returns (bool) { 
    _approve(_msgSender(), spender, amount); 
    return true; 
  } 
  /** 
   * @dev 토큰 소유자인 owner 가  spender 에게 amount 만큼의 토큰을 인출할 권리를 부여한다 
   * 
   *  - `owner` 의 주소는 0 이 되면 안된다 
   *  - `spender` 의 주소는 0 이 되면 안된다 
   */ 
  function _approve(address owner, address spender, uint256 amount) internal { 
    require(owner != address(0), "BEP20: approve from the zero address"); 
    require(spender != address(0), "BEP20: approve to the zero address"); 
    _allowances[owner][spender] = amount; 
    emit Approval(owner, spender, amount); 
  } 
  /** 
   * @dev owner 가 spender 에게 인출을 허락한 토큰의 개수를 반환한다 
   */ 
  function allowance(address owner, address spender) override external view returns (uint256) { 
    return _allowances[owner][spender]; 
  } 
  /** 
   * @dev 함수 호출자가 spender 에게 addedValue 만큼의 allowance 를 추가한다 
   *  - Approval 이벤트를 호출해야만 한다  
   */ 
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) { 
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue)); 
    return true; 
  } 
  /** 
   * @dev 함수 호출자가 spender 에게 subtractedValue 만큼의 allowance 를 차감한다 
   *  - `spender` 주소는 0 이 되면 안된다 
   *  - `spender` 가 이미 가진 allowance 가 subtractedValue 보다 작으면 안된다 
   *  - Approval 이벤트를 호출해야만 한다  
   */ 
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) { 
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero")); 
    return true; 
  } 
  /** 
   * @dev amount 만큼 토큰을 추가 발행하고, 그 토큰을 함수 호출자에게 전송한다 
   *  - `msg.sender` 는 토큰 owner 여야 한다 
   */ 
  function mint(uint256 amount) public onlyOwner returns (bool) { 
    _mint(_msgSender(), amount); 
    return true; 
  } 
  /**  
   * @dev mint  
   * - Transfer 이벤트를 호출해야 한다. 이때 from 인수로는 0 을 넣는다. 
   * - account 주소는 0 이 되면 안된다 
   */ 
  function _mint(address account, uint256 amount) internal { 
    require(account != address(0), "BEP20: mint to the zero address"); 
    _totalSupply = _totalSupply.add(amount); 
    _balances[account] = _balances[account].add(amount); 
    emit Transfer(address(0), account, amount); 
  } 
  /** 
   * @dev 함수 호출자의 토큰을 amount 만큼 소각 한다 
   */ 
  function burn(uint256 amount) public returns (bool) { 
    _burn(_msgSender(), amount); 
    return true; 
  } 
  /** 
   * @dev 함수 호출자의 토큰을 amount 만큼 소각 한다 
   */ 
  function burnFrom(address account, uint256 amount) public returns (bool) { 
    _burnFrom(account, amount); 
    return true; 
  } 
  /** 
   * @dev account 주소에서 amount 만큼 토큰을 소각한다 
   * - Transfer 이벤트를 호출해야한다. 이때 to 인자로 0 을 넣는다 
   * 
   * - `account` 주소는 0 이 되면 안된다 
   * - `account` 주소가 amount 이상의 토큰을 가지고 있어야 한다 
   */ 
  function _burn(address account, uint256 amount) internal { 
    require(account != address(0), "BEP20: burn from the zero address"); 
    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance"); 
    _totalSupply = _totalSupply.sub(amount); 
    emit Transfer(account, address(0), amount); 
  } 
  /** 
   * @dev account 주소에서 amount 만큼 토큰을 소각한다 
   * - 이 함수는 account 주소의 owner 가 아닌 제 3자가 호출한다 
   * - 그래서 approve 가 필요하다 
   * - amount 만큼 allowance 를 차감해야 한다 
   */ 
  function _burnFrom(address account, uint256 amount) internal { 
    _burn(account, amount); 
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance")); 
  } 
}