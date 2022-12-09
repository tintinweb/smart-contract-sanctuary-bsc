/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;


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

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
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
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

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
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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

contract EngineBusdMiner is ERC20 {
    uint256 public TokenPrice = 0.1 ether;
    uint256 Min_Invest = 50 ether;
    uint256 Price_Increase = 0.0000025 ether;
    uint256 Price_Decrease = 0.000004 ether; 
    uint256[] ROI = [1.25 ether, 1.5 ether, 1.75 ether, 2 ether, 2.25 ether, 2.55 ether, 3 ether];
    uint256[] UpgradeROI = [150 ether, 250 ether, 500 ether, 1000 ether, 5000 ether, 10000 ether];
    uint256 public Profit = 2;
    uint256 ReferrelFEE = 8;
    uint256 Fee = 6;
    uint256 MarketingFee = 2;
    uint256 WithdrawFEE = 4;
    uint256 div = 100;
    address public wallet1 = 0x42D33d3738E7432bEF57542e4cfC89700534Ba73;
    address public wallet2 = 0xdab8970B41D70B8Ae5ff88D3Bf2281ae06C4B775;
    address public TradeBot = 0xb17b6Ba014994693F346B81f56e76b7f70F04852;
    address public owner;
    address public TokenAddress;
    IERC20 public BUSD;
    bool Launch = false;
    bool runBot = false;

    struct userLock {
        address user_address;
        uint256 _amount;
    }

    struct ClaimTimeUser {
        address user_address;
        uint256 init_time;
        uint256 deadline;
    }

    struct WithdrawTime {
        address user_address;
        uint256 init_time;
        uint256 deadline;
     }

    struct Collection {
        address user_address;
        uint256 _amount;
    }

    struct TotalWithdraw {
        address user_address;
        uint256 _amount;
        uint256 _tokenAmount;
    }

    struct InvestedBusd {
        address user_address;
        uint256 _amount;
    }

    mapping(address => userLock) public lockQuery;
    mapping(address => ClaimTimeUser) public claimQuery;
    mapping(address => WithdrawTime) public withdrawQuery;
    mapping(address => Collection) public collectQuery;
    mapping(address => TotalWithdraw) public TDquery;
    mapping(address => InvestedBusd) public InvestedBUSDQuery;

    constructor() ERC20("EngineBusd", "ENGINE"){
        TokenAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // BUSD-MAINNET
        BUSD = IERC20(TokenAddress);
        owner = msg.sender;
    }

    function Launch_ENGINE() public {
        require(!Launch, "already started");
        Launch = true;
    }

    function Invest(address ref, uint256 _amtx) public  {
      require(Min_Invest<=_amtx,"You cannot Deposit less than 50 BUSD");
      require(ref != msg.sender && ref != address(0),"Change your Referral");
      require(Launch,"Project is not Started Yet");
      uint256 _depositFee = FeeView(_amtx);
      uint256 _MarketFee = FeeView2(_amtx);
      uint256 _totalFee = SafeMath.add(_depositFee,_MarketFee);
      uint256 _amount = SafeMath.sub(_amtx,_totalFee);  
      uint256 TokenGet = _amount/TokenPrice;

      TokenGet = TokenGet * 10 ** 18;

      _mint(msg.sender,TokenGet);
      BUSD.transferFrom(msg.sender,address(this),_amount);
      BUSD.transferFrom(msg.sender,wallet1,_depositFee);
      BUSD.transferFrom(msg.sender,wallet2,_MarketFee);


      uint256 previousBusd = InvestedBUSDQuery[msg.sender]._amount;
      uint256 totalBusd = SafeMath.add(previousBusd,_amount);

      InvestedBUSDQuery[msg.sender] = InvestedBusd(msg.sender,totalBusd);

       uint256 _power = BuyPower(_amount);
       TokenPrice = SafeMath.add(TokenPrice,_power);

             // ref setting
        uint256 previousRefAmount = lockQuery[ref]._amount;
        uint256 refReward = RefViewer(_amount);
        uint256 totalRefGet = SafeMath.add(previousRefAmount,refReward);
        lockQuery[ref] = userLock(ref,totalRefGet);
    }

    function LockEngines(uint256 _amtx) public {
        require(balanceOf(msg.sender)>= _amtx,"You don't have Engines");
        require(Launch,"Project is not Started Yet");
        uint256 value = lockQuery[msg.sender]._amount;
        uint256 total = SafeMath.add(_amtx,value);
        lockQuery[msg.sender] = userLock(msg.sender,total);
        uint256 TimeInit = claimQuery[msg.sender].init_time;
        if(TimeInit == 0) {

         // MainNet   
           claimQuery[msg.sender] = ClaimTimeUser(msg.sender,block.timestamp,block.timestamp + 1 days);
           withdrawQuery[msg.sender] = WithdrawTime(msg.sender,block.timestamp,block.timestamp + 1 days);

        // testnet 

      //  claimQuery[msg.sender] = ClaimTimeUser(msg.sender,block.timestamp,block.timestamp + 1 minutes);
      //  withdrawQuery[msg.sender] = WithdrawTime(msg.sender,block.timestamp,block.timestamp + 1 minutes);
        }
        _burn(msg.sender,_amtx);
    }

    function REINVEST() public {
     require(Launch,"Project is not Started Yet");
     uint256 userLockedTokens = lockQuery[msg.sender]._amount;
     require(userLockedTokens>0, "Your balance in locked amount is Zero");   
     uint256 currentEarned = User_ROI(msg.sender);
     uint256 totalNow = SafeMath.add(userLockedTokens,currentEarned);
     lockQuery[msg.sender] = userLock(msg.sender,totalNow);
     // mainnet
     claimQuery[msg.sender] = ClaimTimeUser(msg.sender,block.timestamp,block.timestamp + 1 days);

     // testnet
   // claimQuery[msg.sender] = ClaimTimeUser(msg.sender,block.timestamp,block.timestamp + 1 minutes);

     }

     function COLLECT() public {
        require(Launch,"Project is not Started Yet"); 
        uint256 userLockedTokens = lockQuery[msg.sender]._amount;
        require(userLockedTokens>0, "Your balance in locked amount is Zero");
        uint256 currentEarned = User_ROI(msg.sender);
        uint256 previousCollect = collectQuery[msg.sender]._amount;
        uint256 total = SafeMath.add(currentEarned,previousCollect);

        collectQuery[msg.sender] = Collection(msg.sender,total);   
        // Mainnet
        claimQuery[msg.sender] = ClaimTimeUser(msg.sender,block.timestamp,block.timestamp + 1 days);
        // Testnet
    //    claimQuery[msg.sender] = ClaimTimeUser(msg.sender,block.timestamp,block.timestamp + 1 minutes);


     }

     function Withdraw(uint256 _amtx) public  {
         require(Launch,"Project is not Started Yet");
         require(collectQuery[msg.sender]._amount>=_amtx);
         require(block.timestamp>=withdrawQuery[msg.sender].deadline);
         require(AntiWhale(msg.sender)>=_amtx);
         uint256 totalValue = SafeMath.mul(_amtx,TokenPrice);
         totalValue = SafeMath.div(totalValue,10**18);


         uint256 withdrawFeeQuery = FeeView(totalValue);

         uint256 userGet = SafeMath.sub(totalValue,withdrawFeeQuery);
         BUSD.transfer(msg.sender,userGet);
         BUSD.transfer(wallet1,withdrawFeeQuery);


         
        uint256 previousCollect = collectQuery[msg.sender]._amount;

        uint256 leftNow = SafeMath.sub(previousCollect,_amtx);
        collectQuery[msg.sender] = Collection(msg.sender,leftNow);  

        uint256 _power = SellPower(totalValue);
        TokenPrice = SafeMath.sub(TokenPrice,_power);
        // Mainnet
       withdrawQuery[msg.sender] = WithdrawTime(msg.sender,block.timestamp,block.timestamp + 1 days);
        //Testnet 
      // withdrawQuery[msg.sender] = WithdrawTime(msg.sender,block.timestamp,block.timestamp + 1 minutes);

        uint256 lastWithdraw = TDquery[msg.sender]._amount;
        uint256 lastToken = TDquery[msg.sender]._tokenAmount;
        uint256 totalNowWithdraw = SafeMath.add(userGet,lastWithdraw);
        uint256 totalTokenNow = SafeMath.add(_amtx,lastToken);
        TDquery[msg.sender] = TotalWithdraw(msg.sender,totalNowWithdraw,totalTokenNow);

        if(ProfitStop(msg.sender)) {
            lockQuery[msg.sender]._amount = 0;
        }

     }

      function AntiWhale(address _userAddr) public view returns(uint256) {
        uint256 _amount = collectQuery[_userAddr]._amount;
         uint256 output = SafeMath.mul(_amount,TokenPrice);
        uint256 _output = SafeMath.div(output,10**18);
        _output = SafeMath.mul(_output,10);
        uint256 TVL = TVL_NOW();
        

        uint256 total = SafeMath.div(SafeMath.mul(TVL,2),100);

        if(total>=_output) {
            return _amount;
        }
        else {
           
            return SafeMath.div(SafeMath.mul(total,10**18),TokenPrice);
        }
     }


    

    function ROI_COUNTER(address _addr) public view returns(uint256) {
        uint256 userLockedTokens = lockQuery[_addr]._amount;
        uint256 ROI2 = userLockedTokens * TokenPrice;
        ROI2 = ROI2 / 10**18;
        if (ROI2>=UpgradeROI[5]) {
            return ROI[6];
        }
        else if(ROI2>=UpgradeROI[4]) {
            return ROI[5];
        }
        else if(ROI2>=UpgradeROI[3]) {
            return ROI[4];
        }
         else if(ROI2>=UpgradeROI[2]) {
            return ROI[3];
        }
        else if(ROI2>=UpgradeROI[1]) {
            return ROI[2];
        }
         else if(ROI2>=UpgradeROI[0]) {
            return ROI[1];
        }
        else {
            return ROI[0];
        }
    }


    function User_ROI(address _addr) public view returns(uint256) {
        
        uint256 userDailyReturn = DailyROI(_addr);
        // automatic process 
        uint256 claimInvestTime = claimQuery[_addr].init_time;
        uint256 claimInvestEnd = claimQuery[_addr].deadline;

        uint256 totalTime = SafeMath.sub(claimInvestEnd,claimInvestTime);

        uint256 value = SafeMath.div(userDailyReturn,totalTime);

        uint256 nowTime = block.timestamp;

        if(claimInvestEnd>= nowTime) {
        uint256 earned = SafeMath.sub(nowTime,claimInvestTime);

        uint256 totalEarned = SafeMath.mul(earned, value);

        return totalEarned;
        }
        else {
            return userDailyReturn;
        }

    }

    function DailyROI(address _addr) public view returns(uint256) {
         uint256 userLockedTokens = lockQuery[_addr]._amount;
         userLockedTokens = userLockedTokens / 10**18;
        uint256 totalReturn = SafeMath.mul(userLockedTokens,ROI_COUNTER(_addr));
        return SafeMath.div(totalReturn,100);
    }

    function SupplyBot() public {
         require(msg.sender == owner, "Owner");
         require(!runBot,"Cannot call anymore");
         runBot = true;
         uint256 BotSupplyPass = TVL_NOW();
         uint256 limit = SafeMath.mul(BotSupplyPass,20);
         limit = SafeMath.div(limit,100);
         BUSD.transfer(TradeBot,limit);
     }

    function FeeView(uint256 _amtx) public view returns(uint256){
          uint256 _amount = SafeMath.mul(_amtx,Fee);
          return SafeMath.div(_amount,div);
    }
     function FeeView2(uint256 _amtx) public view returns(uint256){
          uint256 _amount = SafeMath.mul(_amtx,MarketingFee);
          return SafeMath.div(_amount,div);
    }

    function RefViewer(uint256 _amtx) public view returns(uint256) {
        uint256 _amount = SafeMath.mul(_amtx,ReferrelFEE);
          return SafeMath.div(_amount,div);
    }

     function BuyPower(uint256 _amount) public view returns(uint256) {
        uint256 _value =  SafeMath.mul(_amount,Price_Increase);
         uint256 _output = SafeMath.div(_value,10**18);
        return SafeMath.div(_output,100);
     }

     function SellPower(uint256 _amount) public view returns(uint256) {
         uint256 _value =  SafeMath.mul(_amount,Price_Decrease);
         uint256 _output = SafeMath.div(_value,10**18);
         return SafeMath.div(_output,100);
     }

     function TVL_NOW() public view returns(uint256) {
        return BUSD.balanceOf(address(this));
     }

     function ProfitStop(address addr) public view returns(bool) {
         uint256 _userLock = lockQuery[addr]._amount;
          uint256 TotalWithdrawToken = TDquery[addr]._tokenAmount;
         if(TotalWithdrawToken>=_userLock * Profit) {
           return true;
         }
         else {
             return false;
         }
     } 
  
}