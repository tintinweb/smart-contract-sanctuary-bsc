/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.15;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.15;

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.15;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.15;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.15;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: Contracts/Copy_AccesVestingNew.sol



/************************
Metacces Vesting Contract
************************/



pragma solidity = 0.8.15;

contract AccesVesting {
    using SafeMath for uint256;

    address public constant zeroAddress = address(0x0);
    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;
    //address private feeReceiver;
    
    ERC20 public Acces;
    address private owner;
    uint256 public constant monthly = 1;//30 days;
    uint256 public constant yearly = 1000;//365 days;
    uint256 public investorCount;
    uint256 public investorsVault;
    uint256 public teamVault;
    uint256 public teamCount;
    uint256 public totalLocked;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 public constant hPercent = 100; //100%
    uint256 private _status;
    uint256 public mP = 5; /* Monthy percentage */
    bool public samePercentage = false;
    

    event InvestorAdded(address Investor, uint256 Amount);
    event TeamAdded(address Team, uint256 Amount);
    event AccesClaimed(address Investor, uint256 Amount);
    event ChangeOwner(address NewOwner);
    event MonthlyPercentageChanged(uint256 NewPercentage);
    event WithdrawalBNB(uint256 _amount, uint256 decimal, address to); 
    event WithdrawalAcces(uint256 _amount,uint256 decimal, address to);
    event WithdrawalBEP20(address _tokenAddr, uint256 _amount,uint256 decimals, address to);
    
    struct InvestorSafe{
        uint256 amount;
        uint256 yP;
        uint256 mP;
        uint256 yearLock;
        uint256 monthLock;
        uint256 lockTime;
        uint256 firstUnlock;
        uint256 timeStart;
        bool isTeam;
    }
    struct amountCalculation{
        uint256 yearlyAllowed;
        uint256 monthlyAllowed;
        uint256 yearsCount;
        uint256 monthsCount;
        uint256 endYear;
    }
 
    mapping(address => bool) public Investor;
    mapping(address => InvestorSafe) public investor;
    mapping(address => amountCalculation) public investorAllowance;


    mapping(address => bool) public blackList; 
    

    modifier onlyOwner (){
        require(msg.sender == owner, "Only Acces owner can add Investors");
        _;
    }

    modifier isInvestor(address _investor){
        require(Investor[_investor] == true, "Not an Investor!");
        _;
    }

    modifier isNotBlackListed(address _investor){
        require(blackList[_investor] != true, "Your wallet is Blacklisted!");
        _;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
    constructor(ERC20 _Acces){ //, address _feeReceiver) {
        owner = msg.sender;
        //feeReceiver = _feeReceiver;
        investorCount = 0;
        Acces = _Acces;
        _status = _NOT_ENTERED;
    }
    function transferOwnership(address _newOwner)external onlyOwner{
        require(_newOwner != zeroAddress,"Zero Address");
        emit ChangeOwner(_newOwner);
        owner = _newOwner;
    }
    /*function changeFeeReceiver(address _newReceiver) external onlyOwner{
        feeReceiver = _newReceiver;
    }*/
    function setMonthlyPercentage(uint256 _mP) external onlyOwner{
        require(_mP > 0 && mP <= 30,"Min 1% Max 30%");
        mP = _mP;
        
        emit MonthlyPercentageChanged(_mP);
    }
    function addToBlackList(address _investor) external onlyOwner{
        blackList[_investor] = true;
    }
    function removeFromBlackList(address _investor) external onlyOwner{
        blackList[_investor] = false;
    }
    function allVaults() internal{
        totalLocked = investorsVault.add(teamVault);
    }
    function activateSamePercentage() external onlyOwner{
        samePercentage = true;
    }
    function disableSamePercentage() external onlyOwner{
        samePercentage = false;
    }
    function editInvestorLock(address _investor, uint256 _yPercent, uint256 _mPercent) external onlyOwner{
        require(_yPercent > 10 && _yPercent < 20,"Yearly percent limit!");
        require(_mPercent > 5 && _mPercent < 10,"Monthly percent limit");
        investor[_investor].yP = _yPercent;
        investor[_investor].mP = _mPercent;
        setAllowance(_investor);
    }
    function setAllowance(address _investor) internal{
        investorAllowance[_investor].yearlyAllowed = investor[_investor].amount.mul(investor[_investor].yP).div(hPercent);
        require(investorAllowance[_investor].yearlyAllowed > 0,"Year error");
        investorAllowance[_investor].monthlyAllowed = investorAllowance[_investor].yearlyAllowed .mul(investor[_investor].mP).div(hPercent);
    }
    function addInvestor(address _investor, bool _isTeam, uint256 _amount, uint256 _yPercent, uint256 _mPercent, uint256 _lockTime, uint256 _firstUnlock) external onlyOwner{
        require(_investor != zeroAddress && _investor != deadAddress,"Zero Address Dead!");
        require(_yPercent >=10 && _mPercent >=5,"Percentage!");
        uint256 availableAmount = Acces.balanceOf(address(this)).sub(investorsVault);
        require(availableAmount >= _amount,"No Acces");
        uint256 lockTime = _lockTime.mul(1);//(1 days);
        uint256 firstUnlock = _firstUnlock.mul(monthly);
        require(_amount > 0, "Amount!");
        if(investor[_investor].amount > 0){
            investor[_investor].amount += _amount;
            investorsVault += _amount;
            return;
        }
        //require(lockTime >= monthly.mul(3), "Please set a time in the future more than 90 days!");
        require(firstUnlock < lockTime,"lock error");
        emit InvestorAdded(msg.sender, _amount);
        investor[_investor].amount = _amount;
        investor[_investor].yP = _yPercent;
        investor[_investor].mP = _mPercent;
        setAllowance(_investor);
        investor[_investor].lockTime = lockTime.add(block.timestamp);
        investor[_investor].timeStart = block.timestamp;
        if(lockTime >= yearly){
            uint256 lockYears = (lockTime / yearly).mul(yearly);
            investor[_investor].yearLock = lockYears.add(block.timestamp);
            investorAllowance[_investor].endYear = yearly.add(block.timestamp);
        }
        
        investor[_investor].monthLock = monthly.add(block.timestamp);
        investor[_investor].firstUnlock = firstUnlock;
        investor[_investor].isTeam = _isTeam;
        Investor[_investor] = true;
        if(_isTeam == true){
            teamVault += _amount;
            teamCount++;
        }
        else{
           investorsVault += _amount;
           investorCount++; 
        }
    }
    function claimMonthlyAmount() external isInvestor(msg.sender) isNotBlackListed(msg.sender) nonReentrant{
        require(investor[msg.sender].firstUnlock < block.timestamp,"Unlock in not available yet");
        require(investorAllowance[msg.sender].yearlyAllowed > 0, "Insufficient allowance, until next year!");
        uint256 _mP;
        if(samePercentage == true){
            _mP = mP;
        }
        else{
            _mP = investor[msg.sender].mP;
        }
        if(investorAllowance[msg.sender].yearlyAllowed > investor[msg.sender].amount){
            investorAllowance[msg.sender].yearlyAllowed = investor[msg.sender].amount;
            investorAllowance[msg.sender].monthlyAllowed = investorAllowance[msg.sender].yearlyAllowed.mul(_mP).div(hPercent);
        }
        
        if(investorAllowance[msg.sender].endYear <= block.timestamp){
            uint256 leftOver = investorAllowance[msg.sender].yearlyAllowed;
            investorAllowance[msg.sender].yearsCount ++;
            investorAllowance[msg.sender].endYear = block.timestamp.add(yearly);
            investorAllowance[msg.sender].yearlyAllowed += leftOver;
        }
        uint256 monthLock = investor[msg.sender].monthLock;
        uint256 yearlyAmount = investorAllowance[msg.sender].yearlyAllowed;
        uint256 monthlyAmount = investorAllowance[msg.sender].monthlyAllowed;
        require(monthLock <= block.timestamp, "Not yet");
        require(monthlyAmount > 0, "No Acces");  
        uint256 amountAllowed = yearlyAmount.mul(_mP).div(hPercent);
        investor[msg.sender].amount -= amountAllowed;
        investor[msg.sender].monthLock += monthly;
        investorsVault -= amountAllowed;
        investorAllowance[msg.sender].yearlyAllowed -= amountAllowed;
        if(investor[msg.sender].amount == 0){
            Investor[msg.sender] = false;
            delete investor[msg.sender];
            investorCount--;
        }
        emit AccesClaimed(msg.sender, amountAllowed);
        Acces.transfer(msg.sender, amountAllowed);
        investorAllowance[msg.sender].monthsCount ++;
    }
    function claimRemainings() external isInvestor(msg.sender) isNotBlackListed(msg.sender) nonReentrant{
        uint256 fullTime = hPercent.div(mP).mul(monthly);
        uint256 totalTimeLock = investor[msg.sender].lockTime.add(fullTime);
        require(totalTimeLock <= block.timestamp, "Not yet");
        uint256 remainAmount = investor[msg.sender].amount;
        investor[msg.sender].amount = 0;
        investorsVault -= remainAmount;
        Investor[msg.sender] = false;
        delete investor[msg.sender];
        emit AccesClaimed(msg.sender, remainAmount);
        Acces.transfer(msg.sender, remainAmount);
        investorCount--;
    }
    function fixInvestorLock() isInvestor(msg.sender) external{
        if(investorAllowance[msg.sender].endYear <= block.timestamp){
            uint256 leftOver = investorAllowance[msg.sender].yearlyAllowed;
            investorAllowance[msg.sender].yearsCount ++;
            investorAllowance[msg.sender].endYear = block.timestamp.add(yearly);
            investorAllowance[msg.sender].yearlyAllowed += leftOver;
        }
    }
    function withdrawalAcces(uint256 _amount, uint256 _path, address to) external onlyOwner() {
        allVaults();
        uint256 amount = Acces.balanceOf(address(this)).sub(totalLocked);
        uint256 dcml = 10 ** _path;
        // can only withdraw what is not locked for investors.
        require(amount > 0 && _amount&dcml >= amount, "No Acces!");
        emit WithdrawalAcces( _amount, _path, to);
        Acces.transfer(to, _amount*dcml);
    }
    function withdrawalBEP20(address _tokenAddr, uint256 _amount, uint256 decimal, address to) external onlyOwner() {
        uint256 dcml = 10 ** decimal;
        ERC20 token = ERC20(_tokenAddr);
        require(token != Acces, "No!"); //Can't withdraw Acces using this function!
        emit WithdrawalBEP20(_tokenAddr, _amount, decimal, to);
        token.transfer(to, _amount*dcml); 
    }  
    function withdrawalBNB(uint256 _amount, uint256 decimal, address to) external onlyOwner() {
        require(address(this).balance >= _amount,"Balanace"); //No BNB balance available
        uint256 dcml = 10 ** decimal;
        emit WithdrawalBNB(_amount, decimal, to);
        payable(to).transfer(_amount*dcml);      
    }
    receive() external payable {}
}


/**********************************
 Proudly Developed by Metacces Team
***********************************/