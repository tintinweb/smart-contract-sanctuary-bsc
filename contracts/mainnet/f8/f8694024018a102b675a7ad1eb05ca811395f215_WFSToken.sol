/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


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

pragma solidity ^0.8.0;




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

// File: contracts/WFSToken.sol


pragma solidity 0.8.15;





/**
*   @dev Blacklist, Direct Push to Superior, Direct Push to Subordinate
*/
contract WFSBase is Context, Ownable {

    // Is it a blacklist
    mapping(address => bool) public isBlacker;
    // @require 2270
    // Direct promotion to superior
    mapping(address => address) public isConnected;
    // @require 2270
    // Direct Push Subordinate
    mapping(address => address[]) internal _downLine;

    event AddedList(address _account);
    event RemovedList(address _account);

    modifier isBlackList(address _maker) {
        require(!(isBlacker[_maker]), "IBL");
        _;
    }

    // @dev Query whether it is a blacklist member
    // @return true/false
    function getBlacker(address _maker) external view returns(bool) {
        return isBlacker[_maker];
    }

    // @dev Query Subordinates
    // @return Subordinate member address array
    function getDownLine() public view returns(address[] memory) {        
        return _downLine[_msgSender()];
    }

    // @dev Add blacklist
    function addBlackeList (address _maker) public onlyOwner {
        isBlacker[_maker] = true;
        emit AddedList(_maker);
    }

    // @dev Remove blacklist
    function removeBlackList (address _maker) public onlyOwner {
        isBlacker[_maker] = false;
        emit RemovedList(_maker);
    }  

    // @require 2270
    // @dev Bind Parent
    function addUpLine(address payable _uper) public returns(bool) {          
        address _account = _msgSender();

        // The superior cannot be the address 0
        require(_uper != address(0), "AUL0");
        // You cannot bind yourself
        require(_account != _uper, "AUL1");
        // No superior
        require(isConnected[_account] == address(0), "AUL2");
        // You have no subordinates (you cannot join other communities if you have a community)
        require(_downLine[_account].length == 0, "AUL3");

        // Put yourself on the superior community list
        _downLine[_uper].push(_account);
        // Associated Direct Push to Parent
        isConnected[_account] = _uper;

        return true;
    }

}

/**
*   @dev Calculation contract
*          Arithmetic air drop, Arithmetic transfer, Arithmetic generation, Arithmetic destruction
*          Calculation force holder record
*          Main calculation force query, temporary calculation force query, platform total calculation force query
*          Service charge currency setting, service charge setting for air drop, service charge setting for transfer and service charge setting for receiving dividends
*          Close airdrop
*          CALCULAR TRANSFER EVENT
*/
contract WFSPower is WFSBase {
    // Force calculation accuracy
    uint256 public powDecimals = 2;
    // The total amount of air drop is 150 million, and the precision is 100
    uint256 public airDropSupply = 15000000000;
    // Service charge currency
    address public tokenFee;
    // Calculate the import service charge, and the tokenFee in the service charge currency
    uint256 public airDropFee = 0;
    // @require 2268
    // Calculate the transfer service charge. The service charge currency is the primary currency of the chain by default
    uint256 public powTransferFee = 0;
    // Receive the dividend service charge, and the tokenFee in the service charge currency
    uint256 public receiveFee = 0;
    // Total amount of computing power that the platform takes effect
    uint256 public powTotalSupply;
    // Number of users
    uint256 private _userCount = 0;
    // Whether air drop is enabled
    bool public openAirDrop = true;

    // Accumulated service charge (WBNB)
    uint256 internal _totalFee = 0;
    // Accumulated service charge for transfer of accounting force (BNB)
    uint256 internal _totalPowTransferFee = 0;

    // Principal computing force
    mapping(address => uint256) private _maBalances;
    // Secondary computing force
    mapping(address => uint256) private _seBalances;
    // Account user ID
    mapping(address => uint256) internal _isSharer;

    // @require 2266
    // @dev CALCULAR TRANSFER EVENT
    // @param: from Transfer out address
    // @param: to Transfer address
    // @param: amount Quantity of calculation force
    // @param: powType Force type
    event PTransfer(address indexed from, address indexed to, uint256 amount, uint256 powType);

    // @require 2266
    // @dev Query the real-time "master computing power" of the account according to the address
    // @param: _account Query account address
    function powMaBalanceOf(address _account) public view returns (uint256) {
        return _maBalances[_account];
    }

    // @require 2266
    // @dev Query the real-time "temporary computing power" of the account according to the address
    // @param: _account Query account address
    function powSeBalanceOf(address _account) public view returns (uint256) {
        return _seBalances[_account];
    }

    // @dev Add numeracy holder
    // @param：account List of holders
    function getPowSharer(address _account) public view onlyOwner returns(uint256) {
        return _isSharer[_account];
    }

    // @dev Setting service charge 
    // @param: _airDropFee Calculate the import service charge, 18 digits of tokenFee USDT in the service charge currency
    // @param：_powTransferFee Calculate the transfer service charge. The service charge currency is the primary currency of the chain, tokenFee USDT, 18 digits by default
    // @param：_receiveFee 18 numbers of tokenFee USDT in the currency of service charge for receiving dividend
    function setFee(uint256 _airDropFee, uint256 _powTransferFee, uint256 _receiveFee) public onlyOwner {
        airDropFee = _airDropFee;
        powTransferFee = _powTransferFee;
        receiveFee = _receiveFee;
    }

    // @dev Close airdrop
    function closeAirDrop() public onlyOwner {
        openAirDrop = false;
    }

     // @dev The platform checks the service charge received from the contract (WBNB)
    function getFee() external view onlyOwner returns(uint256) {
        return _totalFee;
    }

    // @dev Service charge received from platform withdrawal contract (WBNB)
    function reFee() external onlyOwner returns(bool) {
        uint256 _amount = _totalFee;
        _totalFee = 0;
        IERC20(tokenFee).transfer(_msgSender(), _amount);        
        return true;
    }

     // @dev The platform checks the service charge (BNB) for the transfer of accounting power received by the contract
    function getPowTransferFee() external view onlyOwner returns(uint256) {
        return _totalPowTransferFee;
    }

    // @dev Service charge for transfer of accounting force (BNB) received from platform withdrawal contract
    function rePowTransferFee() external onlyOwner returns(bool) {
        uint256 _amount = _totalPowTransferFee;
        _totalPowTransferFee = 0;
        payable(_msgSender()).transfer(_amount);       
        return true;
    }
    
    // @require 2265
    // @dev The administrator imports computing power and binds the superior
    // @param：_account User address of air drop
    // @param：_amount The number of air drops should be multiplied by 100 (calculation accuracy)
    // @param：_uper Superior address, if no superior passes in 0x0000000000000000000000000000000000000000
    // @return Documents
    function powAirDrop(address _account, uint256 _amount, address _uper) public onlyOwner returns(bool) {
        // CALI airdrop is on
        require(openAirDrop, "PAD1");
        // Total remaining airdrop
        uint256 _supply = airDropSupply;
        require(_supply >= _amount, "PAD2");
        // Collect the handling charge for the introduction of computing power
        IERC20(tokenFee).transferFrom(_account, address(this), airDropFee);
        // Subtract Total
        unchecked {
            airDropSupply = _supply - _amount;
        }
        // Casting calculation force, 1 is permanent calculation force
        _powMint(_account, _amount, 1);

        if(_uper != address(0)) {
            // Put yourself on the superior community list
            _downLine[_uper].push(_account);
            // Associated Direct Push to Parent
            isConnected[_account] = _uper;
        }
        
		// Total handling charge increase (WBNB)
        _totalFee += airDropFee;
        
        return true;
    }

    // @require 2268
    // @dev Transfer of calculation force (only permanent calculation force transfer is allowed, and temporary calculation force transfer is not allowed)
    // @param：from Transfer out address
    // @param：to Transfer in address
    // @param：amount Transfer quantity
    function powTransfer(address _to, uint256 _amount) public payable isBlackList(_msgSender()) returns(bool) {
        require(msg.value >= powTransferFee, "PT1");
        
        require(_to != address(0), "PT2");
        address _from = _msgSender();
        // Permanent balance
        uint256 _fromBalance = _maBalances[_from];
        require(_fromBalance >= _amount, "PT3");
        // Deduct the permanent calculation force of the billing address
        unchecked {
            _maBalances[_from] = _fromBalance - _amount;
        }

        // Increase the permanent calculation force of the collection address
        _maBalances[_to] += _amount;
        // Add payee to the list of accounting holders
        _addPowSharer(_to);

        emit PTransfer(_from, _to, _amount, 1);

        // Increase in handling charge for transfer of final accounting force (BNB)
		_totalPowTransferFee += msg.value;

        return true;
    }

    // @dev Casting calculation
    // @param：account Collection user
    // @param：amount Initial calculation force quantity
    // @param：pType Initial calculation force type,=1 is permanent calculation force,=2 is secondary calculation force
    function _powMint(address _account, uint256 _amount, uint256 _powType) internal {
        require(_account != address(0), "_PM1");
        require(_powType == 1 || _powType == 2, "_PM2");
        
        // Increase in total computing power
        powTotalSupply += _amount;
        
        // If it is 1, increase the permanent calculation force; Otherwise, it is 2, and the temporary calculation force is increased
        if(_powType == 1) {
            _maBalances[_account] += _amount;
        }else {
            _seBalances[_account] += _amount;
        }

        // Add payee to the list of accounting holders
        _addPowSharer(_account);

        emit PTransfer(address(0), _account, _amount, _powType);
    }

    // @dev Calculation of temporary destruction
    // @param：account Transfer out address
    // @param：amount Destroyed quantity
    function _powBurn(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), "_PB1");

        // User's temporary balance
        uint256 _accountBalance = _seBalances[_account];
        require(_accountBalance >= _amount, "_PB2");
        
        // Decrease in user's temporary calculation balance
        unchecked {
            _seBalances[_account] = _accountBalance - _amount;
        }
        // The total computing power of the platform decreases
        powTotalSupply -= _amount;
        
        emit PTransfer(_account, address(0), _amount, 2);
    }

    // @dev Add numeracy holder
    // @param：account List of holders
    function _addPowSharer(address _account) internal {        
        if(!(_isSharer[_account] > 0)) {            
            _userCount++;
            _isSharer[_account] = _userCount;
        }
    }  

}

/**
*   @dev WFC Business contract
*          Destroy, store, retrieve, reward, lose reward
*          Fund dividends, users receiving dividends, dividend deflation
*          Destruction events, storage events, retrieval events, and dividend collection events
*          Storage order query
*
*          Freeze address setting and freeze amount query
*          Re WFC transfer, re WFC third party transfer
*          
*/
contract WFSToken is ERC20, WFSPower {
    // Basic business structure
    struct BC {
        // Business base
        uint256 base;
        // Calculated force ratio obtained
        uint256 rate;
    }

    // Store Order Structure
    struct SO {
        // Storage amount
        uint256 amount;
        // Quantity of calculation force obtained
        uint256 pow;
        // Storage time
        uint256 storageDate;
    }

    // Token storage order
    SO[] private _storageOrders;
    // List of foundations
    address[] private _funders;

    // Dividend deflation ratio 50%
    uint256 constant public ShareDeflation = 50;
    // The daily dividend amount is 500000 WFC = 500,000 * 10 ** 8
    uint256 public shareAmount = 50000000000000;
    // Last fixed dividend date
    uint256 public shareDate = block.timestamp;
    // Number of dividends
    uint256 public shareCount = 0;
    // Minimum storage amount，3000 * 10 ** 8
    uint256 public storageBase = 300000000000;  

    // @dev: Recommend reward configuration, and obtain reward configuration according to recommended interval algebra
    // @param: Algebra 1-13
    // @return: base The minimum amount of your own computing power required to obtain rewards
    // @return: decimals Force calculation accuracy
    // @return: rate Calculated force ratio obtained, 50 represents 50%
    // @return: powType Force type,=1 is permanent force,=2 is temporary force
    mapping(uint256 => BC) public rewardConf;
    // @dev: Transaction pair address, transaction pair address on pancake
    mapping(address => bool) public pairAddress;
    // @dev: Destroy the configuration and obtain the configuration according to the burnType
    // @param: burnType Destruction business type:=50 is 50% destruction,=100 is 100% destruction
    // @return: Minimum destruction quantity
    mapping(uint256 => uint256) public burnBase;
    // @dev: Amount of dividends to be received by users
    mapping(address => uint256) public accToReAmt;
    // @dev: The last time the user received the dividend
    mapping(address => uint256) public accToReDay;
    // @dev: Frozen amount
    // @param: User address
    // @return: Frozen amount
    mapping(address => uint256) private _freezeBalances;
    // @dev: Query the amount not retrieved from the order according to the order number
    // @param: Order ID
    // @return: Unretrieved amount
    mapping(uint256 => uint256) private _soToAmt;
    // @dev: Query order user according to order ID
    // @param: Order ID
    // @return: User address
    mapping(uint256 => address) private _soToAcc;     
        
    // Destruction event
    // @param: burner Destroyer
    // @param: amount Destroyed quantity
    // @param: amountType Account type of destruction amount:=1 is balance destruction,=2 is freeze destruction
    // @param: burnType Destruction business type:=50 is 50% destruction,=100 is 100% destruction
    event Burned(address indexed burner, uint256 amount, uint256 amountType, uint256 burnType);
    // Storage Events
    // @param: id Storage record ID
    // @param: stroager Stored by
    // @param: amount  quantity
    event Storaged(uint256 indexed id, address indexed stroager, uint256 amount);
    // Retrieve storage events
    // @param: id Retrieve record ID
    // @param: retriever Retrieved by
    // @param: amount quantity
    event Retrieved(uint256 indexed id, address indexed retriever, uint256 amount);   
    // Dividend receiving event
    // @param: account Recipient
    // @param: amount quantity
    event Received(address indexed receiver, uint256 amount);

    constructor() ERC20("WFCD", "WFCD") {

        // Service charge currency, WBNB as formal service charge
        tokenFee = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

        burnBase[50] = 50000000000;
        burnBase[100] = 10000000000;

        rewardConf[1] = BC(100, 100);
        rewardConf[2] = BC(200, 30);
        rewardConf[3] = BC(300, 20);
        rewardConf[4] = BC(400, 5);
        rewardConf[5] = BC(500, 5);
        rewardConf[6] = BC(600, 5);
        rewardConf[7] = BC(700, 5);
        rewardConf[8] = BC(800, 5);
        rewardConf[9] = BC(900, 5);
        rewardConf[10] = BC(1000, 5);
        rewardConf[11] = BC(1100, 5);
        rewardConf[12] = BC(1200, 5);
        rewardConf[13] = BC(1300, 5);
    }

    // @dev Override WFC accuracy
    function decimals() public pure override returns (uint8) {
        return 8;
    }

    // @dev Query of frozen amount
    function freezeBalanceOf(address account) public view returns (uint256) {
        return _freezeBalances[account];
    }

    // @dev Query storage order
    // @param: _id Store order number
    function getStorageOrder(uint256 _id) public view returns(SO memory) {
        require(_msgSender() == _soToAcc[_id]);
        return _storageOrders[_id];
    }

    // @dev Re, covering WFC transfer
    function transfer(address to, uint256 amount) public override returns(bool) {
        address owner = _msgSender();

        // If the transfer out address is a transaction pair address, freeze the transaction; Otherwise, it is normal transfer business
        if(pairAddress[owner]) {
            _burn(owner, amount);
            _freezeBalances[to] += amount;
        } else {
            _transfer(owner, to, amount);
        }

        return true;
    }

    // @dev Rewritten, covering WFC third party transfers
    function transferFrom(address from, address to, uint256 amount) public override returns(bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amount);
        // If the transfer initiating address is a transaction pair address, freeze the transaction
        if(pairAddress[spender]) {
            _burn(from, amount);
            _freezeBalances[to] += amount;
        }else {
            _transfer(from, to, amount);
        }
        
        return true;
    }

    // @dev Configure the list of foundations
    // @param: _members List of foundations
    function setFunders(address[] calldata _members) public onlyOwner {
        _funders = _members;
    }

    // @dev Set transfer freezing address
    function addPairAddress(address _pair) public onlyOwner {
       pairAddress[_pair] = true;
    }

    // @dev Remove Transfer Blocking Address
    function removePairAddress(address _pair) public onlyOwner {
        pairAddress[_pair] = false;
    }

    // @require 2273
    // @dev Destroy WFC to obtain permanent computing power
    // @param: _amount Destruction amount, the value passed in=the quantity entered by the user * 10 * * 8 (WFC currency precision)
    // @param: _amountType Type of destruction account:=1 is balance destruction (_burnType can only be transferred in=100),=2 is freeze destruction
    // @param: _burnType Destruction business type:=50 is 50% destruction,=100 is 100% destruction
    // @return Success Status 
    function burned(uint256 _amount, uint256 _amountType, uint256 _burnType) public returns(bool) {
        // Restricted account type
        require(_amountType == 1 || _amountType == 2, "B1");
        // Restricted business type
        require(_burnType == 50 || _burnType == 100, "B2");
        // Read the storage parameter configurations of different business types
        uint256 _base = burnBase[_burnType];        
        address _burner = _msgSender();
        // The destruction quantity must be greater than or equal to the configured minimum destruction quantity
        require(_amount >= _base, "B3");
        // The amount of calculation force obtained. The default is 100% of permanent calculation force
        uint256 _pow = _amount / _base;
        
        // If account type=1 (balance destroyed)
        if(_amountType == 1) {          
            // Balance destruction can only be 100% destruction (burnType=2)
            require(_burnType == 100, "B4");
            // Destroy WFC in balance
            _burn(_burner, _amount);  
        }else {
            // Otherwise, it is frozen and destroyed
            // Freeze Balance
            uint256 accountBalance = _freezeBalances[_burner];        
            // The frozen balance is greater than or equal to the destruction amount
            require(accountBalance >= _amount, "B5");
            // Update frozen balance
            unchecked {
                _freezeBalances[_burner] = accountBalance - _amount;
            }
            // In case of 50% destruction (half of the destruction is converted into permanent accounting force, and half is put into the account balance)
            if(_burnType == 50) {
                // 50% included in the balance
                _mint(_burner, (_amount / 2));
                // 50% included in permanent calculation force
                _pow = (_amount  / 2) / _base;
            }
        }

        // The calculation accuracy is 2 digits, so it needs to be multiplied by 100
        _pow = _pow * 100;
        // Distribution of calculation force:_ Burner Destroyer_ Quantity of pow calculation force,=1 permanent calculation force
        _powMint(_burner, _pow, 1);
        // Reward calculation:_ Burner Destroyer_ Pow basic computing power,=1 permanent computing power,=1 incentive business
        _reward(_burner, _pow, 1, 1);

        emit Burned(_burner, _amount, _amountType, _burnType);
        
        return true;
    }

    // @require 2274
    // @dev To store tokens for temporary computing power, users can store WFC or USDT
    // @param: _amount Storage quantity
    // @return Documents    
    function storaged(uint256 _amount) public returns(bool) {
        // The storage quantity is greater than or equal to the minimum storage quantity
        require(_amount >= storageBase, "S1");
        
        address _storager = _msgSender();
        // The depositor cannot be a transaction pair address
        require(!(pairAddress[_storager]), "S2");
        // Quantity of calculation force obtained
        uint256 _pow = _amount * 100 / storageBase;
        // Execute transfer  
        _transfer(_storager, address(this), _amount); 
        // Store order information
        _storageOrders.push(SO(_amount, _pow, block.timestamp));

         // Order ID
        uint256 _id = _storageOrders.length - 1;
        // The storage user corresponding to the order ID
        _soToAcc[_id] = _storager;
        // Amount to be retrieved corresponding to order ID
        _soToAmt[_id] = _amount;

        // Distribution of calculation force:_ Storager_ Quantity of pow calculation force,=2 temporary calculation force
        _powMint(_storager, _pow, 2);
        // Arithmetic reward:_ Storager_ Pow basic calculation force,=2 temporary calculation force,=1 reward calculation force
        _reward(_storager, _pow, 2, 1);

        emit Storaged(_id, _storager, _amount);

        return true;
    }

    // @require 2274
    // @dev Take out the stored tokens and lose the temporary computing power
    // @param: _id Storage record ID
    // @return Documents
    function retrieved(uint256 _id) public returns(bool) {
        address _retriever = _msgSender();
        // You can only retrieve your own order
        require(_retriever == _soToAcc[_id], "RT1");
        // Get the order information
        SO storage _so = _storageOrders[_id];

        // The current time is greater than the storage time+7 days
        require(block.timestamp >= _so.storageDate + 7 days, "RT2");
        // Amount to be retrieved
        uint256 _amount = _soToAmt[_id];
        // The order's amount to be retrieved is greater than 0, that is, it has not been retrieved
        require(_amount > 0, "RT3");

        // Amount to be retrieved is returned to 0
        _soToAmt[_id] = 0;
        // Return the token stored by the user
        _transfer(address(this), _retriever, _amount);

        // The user subtracts the temporary computing power obtained during storage
        _powBurn(_retriever, _so.pow);
        // Calculation force retrieval:_ Retriever_ Pow foundation calculation force,=2 temporary calculation force,=2 retrieval calculation force
        _reward(_retriever, _so.pow, 2, 2);

        emit Retrieved(_id, _retriever, _amount);

        return true;
    }   

    // @dev Query the daily dividend   
    // @param: _account Query account address
    function getDailyBonus(address _account) public view returns(uint256) {
        // User ID, ID also exists
        uint256 _id = _isSharer[_account];
        require(_id > 0, "GDB");

        // Total user computing power
        uint256 _pow = powMaBalanceOf(_account) + powSeBalanceOf(_account);
        // Initialize the number of user dividends today
        uint256 _amount = 0;
        // If the user's calculation force is>=100 (i.e. 1 calculation force, accuracy 2)
        if(_pow >= 100) {
            // Calculate the current dividend of the user=total dividend amount of the day * (1 - dividend proportion of the foundation) * user's total computing power/platform's total computing power
            _amount = (shareAmount * _pow * 96) / (powTotalSupply * 100);
        }

        return _amount;
    }

    // @require 2275
    // @dev The Foundation distributes dividends every day, which needs to be called once a day
    // @dev Deflation every 360 days
    function shareBonus() public onlyOwner returns(bool) {
        // The current days are greater than the last dividend days
        require((block.timestamp / 1 days) > (shareDate / 1 days), "SB1");
        
        // Dividend time+1 day
        shareDate += 1 days;
        // Number of dividends+1
        shareCount += 1;

        // Number of foundations        
        uint256 _num = _funders.length;

        if(_num > 0) {
            // Fund member dividend=total dividend amount of the day * Fund dividend ratio/number of fund dividends
            uint256 _amount = (shareAmount * 4) / (_num * 100) ;
            for(uint256 i = 0; i <_num; i++) {
                // Cyclic increase
                _mint(_funders[i], _amount);
            }
        }

        // Deflation: 50% reduction every 360 days
        if((shareCount % 360) == 0) {
            shareAmount = (shareAmount * ShareDeflation) / 100;
        }

        return true;
    }

    // @require 2272
    // @dev Receive dividends
    // @param: _account Receiving user
    // @param: _amount Amount received
    function receivedBonus(address _account, uint256 _amount) public isBlackList(_account) onlyOwner returns(bool) {
        uint256 _id = getPowSharer(_account);

        require(_id > 0, "RB1");
        require(_amount > 0, "RB2");
        // Charge service charge
        IERC20(tokenFee).transferFrom(_account, address(this), receiveFee);
        // Cast WFC
        _mint(_account, _amount);

        emit Received(_account, _amount);

        // Total handling charge increase (WBNB)
        _totalFee += receiveFee;

        return true;
    }

    // @require 2276
    // @dev Reward calculation force and recovery of reward calculation force
    // @param: _account Users with business
    // @param: _pow Calculation quantity of basic business
    // @param: _powType Calculation type:=1 permanent calculation force,=2 temporary calculation force
    // @param: _powType Business type:=1 reward,=2 cancel reward
    function _reward(address _account, uint256 _pow, uint256 _powType, uint256 _buniessType) private {
        require(_powType == 1 || _powType ==2, "R1");
        require(_buniessType == 1 || _buniessType ==2, "R2");

        // Initialize user: directly push the parent user
        address _cur = isConnected[_account];
        // Initialization algebra: Generation 1
        uint256 _count = 1;

        while(_cur != address(0) && _count <= 13){
            // Calculation power of reward rewardConf reward allocation
            uint256 _curpow = _pow * rewardConf[_count].rate / 100;
            if(_curpow > 0) {
                if(_buniessType == 1) {       
                    // Reward calculation             
                    _powMint(_cur, _curpow, _powType);
                } else {
                    // Take back the reward calculation
                    _powBurn(_cur,_curpow);
                }
            }

            // Switch to the superior of the superior, and issue or withdraw prizes circularly
            _cur = isConnected[_cur];
            // Algebra+1
            _count++;
        }    
    }

}