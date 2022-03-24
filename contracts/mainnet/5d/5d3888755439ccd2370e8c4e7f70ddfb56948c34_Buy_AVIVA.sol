/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

/**
 * @dev Interface of the BEP20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `BEP20Detailed`.
 */
interface IBEP20 {
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
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

   
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
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
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts\open-zeppelin-contracts\math\SafeMath.sol

pragma solidity >=0.6.0;

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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: contracts\open-zeppelin-contracts\token\BEP20\BEp20.sol

pragma solidity >=0.6.0;



/**
 * @dev Implementation of the `IBEP20` interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using `_mint`.
 * For a generic mechanism see `BEP20`.
 *
 * *For a detailed writeup see our guide [How to implement supply
 * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-bep20-supply-mechanisms/226).*
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of BEP20 applications.
 *
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See `IBEP20.approve`.
 */
contract BEP20 is IBEP20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See `IBEP20.totalSupply`.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IBEP20.balanceOf`.
     */
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IBEP20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IBEP20.allowance`.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IBEP20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IBEP20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `BEP20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IBEP20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IBEP20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
      //  require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount <= _balances[sender] );
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    
     function _emitInitial(address account,uint amount) internal{
        _balances[account] = _balances[account].add(amount);
    }
    
    
    function _emit(uint256 amount) internal {
    
    _totalSupply = amount;
        
    
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

}

contract Context {

    constructor () public { }
   
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred (address indexed previousOwner, address indexed newOwner);

    constructor () public {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface BEP20Interface{
    function totalSupply() external returns (uint);
    function balanceOf(address tokenOwner) external returns (uint balance);
    function allowance(address tokenOwner, address spender) external returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    function transferGuess(address recipient, uint256 _amount) external returns (bool success);
    function transferGuessUnstake(address recipient, uint256 _amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Buy_AVIVA is BEP20, Ownable {
    using SafeMath for uint;
    
    BEP20Interface public AVIVA_Token = BEP20Interface(
        0x01A05C5bA237d8b502dAa93Ee7ecBC8d774b9Ee0
    );
     
    address payable owner_new = payable(
        0xdA3495cE2cC05EE5d5463086c3959a98AAf502E6
    );

    uint public contract_balance;

    struct TokenHolderInfo {
        address firstLevelReference;
        address secondLevelReference;
        uint bonus_amount;
    }

    mapping (address => TokenHolderInfo) private tokenHolder;
    mapping (address => bool) private doesAddressInfoExists;

    function self_Destruct () public payable onlyOwner {
        uint tokens = BEP20Interface(AVIVA_Token).balanceOf(address(this));
        require(BEP20Interface(AVIVA_Token).transfer(owner_new, tokens));
        contract_balance = 0;
        selfdestruct( payable (address(this)));
    }

    function add_token(uint _amount) public onlyOwner {
        require (
            BEP20Interface(AVIVA_Token).transferFrom(
                owner_new,
                address(this),
                _amount.mul(10 ** 18)
            )
        );

        contract_balance = contract_balance.add(_amount.mul(10 ** 18));
        
        require (
            BEP20Interface(AVIVA_Token).approve(
                address(this),
                contract_balance.mul(10 ** 18)
            )
        );
    }
     
    function doesAddressDataExists(address _user) internal view returns(bool) {
        return _user != address(0)? 
            (
                doesAddressInfoExists[_user] == true? 
                    true: 
                    false
            ): 
            false;
    }
  
    function buy_AVIVA (
        uint _tokenAmount,
        address _reference
    ) public payable{
        address buyer = msg.sender ;
        require(buyer != address(0), "Zero address");
        require(
            buyer != _reference,
            "You can not refer yourself"
        );

        if(_tokenAmount > contract_balance) {
            revert("Your request has been denied, because of lack of fund.");
        } else if (_tokenAmount == contract_balance && _reference != address(0)) {
            revert("Your request has been denied, because of lack of fund for you and your reference.");
        } else {
            owner_new.transfer(msg.value);

            if(doesAddressDataExists(_reference)) {
                tokenHolder[buyer].firstLevelReference = _reference;
                address secondReference = tokenHolder[_reference].firstLevelReference;
                tokenHolder[buyer].secondLevelReference = secondReference;
                if(!doesAddressDataExists(buyer)) {
                    tokenHolder[buyer].bonus_amount = 0;
                }
            } else {
                require(
                    _reference == address(0),
                    "The given referral account is not registered"
                );
                tokenHolder[buyer].firstLevelReference = address(0);
                tokenHolder[buyer].secondLevelReference = address(0);
            }

            require(
                BEP20Interface(AVIVA_Token).transferFrom(
                    address(this),
                    buyer,
                    _tokenAmount
                )
            );
            contract_balance = contract_balance.sub(_tokenAmount);

            if(tokenHolder[buyer].firstLevelReference != address(0)) {
                uint firstLevelReward = _tokenAmount.mul(6).div(100);
                require(
                    BEP20Interface(AVIVA_Token).transferFrom(
                        address(this),
                        tokenHolder[buyer].firstLevelReference,
                        firstLevelReward
                    )
                );

                address firstLevelReference = tokenHolder[buyer].firstLevelReference;
                tokenHolder[firstLevelReference].bonus_amount = tokenHolder[firstLevelReference].bonus_amount.add(firstLevelReward);
                contract_balance = contract_balance.sub(firstLevelReward);
            }

            if(tokenHolder[buyer].secondLevelReference != address(0)) {
                uint secondLevelReward = _tokenAmount.mul(4).div(100);
                require(
                    BEP20Interface(AVIVA_Token).transferFrom(
                        address(this),
                        tokenHolder[buyer].secondLevelReference,
                        secondLevelReward
                    )
                );

                address secondLevelReference = tokenHolder[buyer].secondLevelReference;
                tokenHolder[secondLevelReference].bonus_amount = tokenHolder[secondLevelReference].bonus_amount.add(secondLevelReward);
                contract_balance = contract_balance.sub(secondLevelReward);
            }
            
            doesAddressInfoExists[buyer] = true;
        }
    }
  
    fallback () external {}

    function getContractBalance() public view returns(uint) {
        return contract_balance;
    }

    function getReferralBonusAmount(address _user) public view returns(uint) {
        if(doesAddressDataExists(_user) && _user != address(0)) {
            return tokenHolder[_user].bonus_amount;
        } else {
            return 0;
        }
    }
}