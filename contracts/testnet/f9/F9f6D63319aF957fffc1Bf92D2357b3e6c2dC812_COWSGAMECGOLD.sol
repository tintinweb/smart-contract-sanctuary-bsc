// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import {IERC20} from './IERC20.sol';
import {SafeMath} from './SafeMath.sol';
import {IUserVBG} from './IUserVBG.sol';
import {IVerifySignature} from './IVerifySignature.sol';
import './ReentrancyGuard.sol';


contract COWSGAMECGOLD is ReentrancyGuard {
    using SafeMath for uint256;
    address public operator;
    address public owner;
    bool public _paused = false;

    address public CGOLD_TOKEN;   
    address public VERIFY_SIGNATURE;
    address public USER_VBG;

    uint256 public constant DECIMAL_18 = 10**18;
    struct UserInfo {
            uint256 tokenDeposit;
            uint256 lastUpdatedAt;
            uint256 tokenRewardClaimed;
            uint8 status;  // 0 : not active ; 1 active ; 2 is lock ; 2 is ban
    }
    mapping(address => UserInfo) public userInfo;
    //user => sign => status
    mapping(address => mapping(bytes => bool)) userSigned;
  
    //events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ChangeOperator(address indexed previousOperator, address indexed newOperator);
    event TokenDeposit(address token, address depositor, uint256 amount);
    event TokenWithdraw(
        address token,
        address withdrawer,
        uint256 amount,
        uint256 balance,
        uint256 spent,
        uint256 win
    );
    
    modifier onlyOwner() {
        require(msg.sender == owner, 'INVALID owner');
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operator, 'INVALID operator');
        _;
    }

    constructor() public {
        owner  = tx.origin;
        operator = tx.origin;
        CGOLD_TOKEN = 0xCeC6763CEd8D27359B72CA1Ce67A33889C3523f1;
        USER_VBG = 0xa7F21421bf8C6DAF7452cdDaa0CB419fc6436537;
        VERIFY_SIGNATURE = 0x4f0736236903E5042abCc5F957fD0ae32f142405;
    }

    fallback() external {

    }

    receive() payable external {
        
    }

    function pause() public onlyOwner {
        _paused=true;
    }

    function unpause() public onlyOwner {
        _paused=false;
    }

    
    modifier ifPaused(){
        require(_paused,"");
        _;
    }

    modifier ifNotPaused(){
        require(!_paused,"");
        _;
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
    function _transferOwnership(address newOwner) internal onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Transfers operator of the contract to a new account (`operator`).
     * Can only be called by the current owner.
     */
    function transferOperator(address _operator) public onlyOwner {
        emit ChangeOperator(operator , _operator);
        operator = _operator;
    }

    /**
    * @dev Withdraw Token to an address, revert if it fails.
    * @param recipient recipient of the transfer
    */
    function clearToken(address recipient, address token, uint256 amount ) public onlyOwner {
        require(IERC20(token).balanceOf(address(this)) >= amount , "INVALID balance");
        IERC20(token).transfer(recipient, amount);
    }

    /**
    * @dev Withdraw  BNB to an address, revert if it fails.
    * @param recipient recipient of the transfer
    */
    function clearBNB(address payable recipient) public onlyOwner {
        _safeTransferBNB(recipient, address(this).balance);
    }

    /**
    * @dev transfer BNB to an address, revert if it fails.
    * @param to recipient of the transfer
    * @param value the amount to send
    */
    function _safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'BNB_TRANSFER_FAILED');
    }
    
    function getUserInfo (address account) public view returns(
            uint256 tokenDeposit,
            uint256 lastUpdatedAt,
            uint256 tokenRewardClaimed
            ) {

            UserInfo storage _user = userInfo[account];      
            return (
                _user.tokenDeposit,
                _user.lastUpdatedAt,
                _user.tokenRewardClaimed);
    }

    
    function depositTokenToVBG(uint256 amount) public ifNotPaused returns (bool)
    {
        require(IUserVBG(USER_VBG).isRegister(msg.sender) == true , "Address not whitelist registed system");
        uint256 allowance = IERC20(CGOLD_TOKEN).allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        uint256 balance = IERC20(CGOLD_TOKEN).balanceOf(msg.sender);
        require(balance >= amount, "Sorry : not enough balance to deposit ");
        _depositTokenToGame(msg.sender,CGOLD_TOKEN,amount);
        return true;
    }

    

    function _depositTokenToGame(address depositor , address token, uint256 _amount) internal {
        require(token == CGOLD_TOKEN ," Invalid token deposit");
        IERC20(token).transferFrom(depositor, address(this), _amount);
        userInfo[depositor].tokenDeposit += _amount;
        userInfo[depositor].lastUpdatedAt = block.timestamp;
        emit TokenDeposit(token,depositor,_amount);
    }


    function isSignOperator(uint256 _amount, string memory _message, uint256 _expiredTime, bytes memory _signature) public view returns (bool) 
    {
        return IVerifySignature(VERIFY_SIGNATURE).verify(operator, msg.sender, _amount, _message, _expiredTime, _signature);    
    }
        
    function withdrawTokens(
        uint256 _amount,
        uint256 _amountSpent, // Spent in game 
        uint256 _amountWin, // Profit in game 
        string memory _message,
        uint256 _expiredTime,
        bytes memory signature
    ) public ifNotPaused returns (bool) {
        require(IUserVBG(USER_VBG).isRegister(msg.sender) == true , "Address not whitelist registed system");
        require(userSigned[msg.sender][signature] == false, "withdrawTokens: invalid signature");
        require(block.timestamp < _expiredTime, "withdrawTokens: !expired");
        require(
            IVerifySignature(VERIFY_SIGNATURE).verify(operator, msg.sender, _amount, _message, _expiredTime, signature) == true ,
            "invalid operator"
        );
        
        uint256 amount = _amount * DECIMAL_18;
        UserInfo storage _user = userInfo[msg.sender];

        require(_user.tokenDeposit - _amountSpent + _amountWin > 0 , "invalid balance ");
        require(_user.tokenDeposit - _amountSpent + _amountWin >= amount, "invalid amount");
        
        //return token 
        IERC20(CGOLD_TOKEN).transfer(msg.sender, amount);

       emit TokenWithdraw(
        CGOLD_TOKEN,
        msg.sender,
        amount,
        _user.tokenDeposit,
        _amountSpent,
        _amountWin);
        _user.tokenDeposit = _user.tokenDeposit - _amountSpent + _amountWin -  amount;
        _user.tokenRewardClaimed += amount;
        _user.lastUpdatedAt = block.timestamp;
        userSigned[msg.sender][signature] = true;
        return true;
    }
    
    
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

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
    require(c >= a, 'SafeMath: addition overflow');

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
    return sub(a, b, 'SafeMath: subtraction overflow');
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
    require(c / a == b, 'SafeMath: multiplication overflow');

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
    return div(a, b, 'SafeMath: division by zero');
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
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
    return mod(a, b, 'SafeMath: modulo by zero');
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
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;


contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        
        _notEntered = true;
    }

    
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        
        _notEntered = true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
 * @dev Interface of the SellToken standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
 */
interface IVerifySignature {
  
  function verify( address _signer, address _to, uint256 _amount, string memory _message, uint256 _expiredTime, bytes memory signature) 
  external view returns (bool);
  
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
 * @dev Interface of the SellToken standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
 */
interface IUserVBG {
  /**
   * @dev Returns the  info of user in existence.
   */
  function isRegister(address account) external view returns (bool);
  function getReff(address account) external view returns (address);

}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
 */
interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
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
  function transfer(address recipient, uint256 amount) external returns (bool);

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
  event Approval(address indexed owner, address indexed spender, uint256 value);
}