/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: MIT

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

// File: contracts/WFS.sol

// contracts/GLDToken.sol

pragma solidity 0.8.15;




contract WFSBase is Context, Ownable {

    mapping(address => bool) public isBlacker;
    mapping(address => address) public isConnected;
    mapping(address => address[]) private _downLine;

    event AddedList(address _account);
    event RemovedList(address _account);

    modifier isBlackList(address _maker) {
        require(!(isBlacker[_maker]), "IBL");
        _;
    }

    function getBlacker(address _maker) external view returns(bool) {
        return isBlacker[_maker];
    }

    function getUper() external view returns(address) {
        return isConnected[_msgSender()];
    }

    function getDownLine() public view returns(address[] memory) {        
        return _downLine[_msgSender()];
    }

    function addBlackeList (address _maker) public onlyOwner {
        isBlacker[_maker] = true;
        emit AddedList(_maker);
    }

    function removeBlackList (address _maker) public onlyOwner {
        isBlacker[_maker] = false;
        emit RemovedList(_maker);
    }  

    function addUpLine(address payable _uper) public returns(bool) {          
        address _account = _msgSender();

        require(_uper != address(0), "AUL0");
        require(_account != _uper, "AUL1");
        require(isConnected[_account] == address(0), "AUL2");
        require(_downLine[_account].length == 0, "AUL3");

        _downLine[_uper].push(_account);
        isConnected[_account] = _uper;

        return true;    
    }

}


contract WFSPower is WFSBase  {

    uint256 public powDecimals = 2;
    uint256 public airDropSupply = 15000000000;
    uint256 public airDropFee = 0;
    uint256 public powTransferFee = 0;
    uint256 public receiveFee = 0;
    uint256 public powTotalSupply;
    uint256 private _userCount = 0;
    bool public openAirDrop = true;
  
    mapping(address => uint256) private _maBalances;
    mapping(address => uint256) private _seBalances;
    mapping(address => uint256) private _isSharer;
    // 平台某天的总算力
    mapping(uint256 => uint256) public dayToPow;
    // 用户某天的总算力
    mapping(address => mapping(uint256 => uint256)) public accToPow;

    event PTransfer(address from, address to, uint256 amount, uint256 powType);

    function powMaBalanceOf(address _account) public view returns (uint256) {
        return _maBalances[_account];
    }

    function powSeBalanceOf(address _account) public view returns (uint256) {
        return _seBalances[_account];
    }

    function getPowSharer(address _account) public view onlyOwner returns(uint256) {
        return _isSharer[_account];
    }

    function setFee(uint256 _airDropFee, uint256 _powTransferFee, uint256 _receiveFee) external onlyOwner {
        airDropFee = _airDropFee;
        powTransferFee = _powTransferFee;
        receiveFee = _receiveFee;        
    }

    function closeAirDrop() external onlyOwner {
        openAirDrop = false;
    }

    function powAirDrop(address _account, uint256 _amount) external onlyOwner returns(bool) {
        require(openAirDrop, "PAD1");
        
        uint256 _supply = airDropSupply;
        require(_supply >= _amount, "PAD2");

        unchecked {
            airDropSupply = _supply - _amount;
        }
       
        _powMint(_account, _amount, 1);

        return true;
    }

    function powTransfer(address _to, uint256 _amount) public payable isBlackList(_msgSender()) returns(bool) {
        require(msg.value >= powTransferFee, "PT1");
        
        require(_to != address(0), "PT2");
        address _from = _msgSender();

        uint256 _fromBalance = _maBalances[_from];
        require(_fromBalance >= _amount, "PT3");
        unchecked {
            _maBalances[_from] = _fromBalance - _amount;
        }

        _maBalances[_to] += _amount;
        _addPowSharer(_to);

        _powRecord(_from, _to, _amount, 1);       

        return true;
    }

    function _powMint(address _account, uint256 _amount, uint256 _powType) internal {
        require(_account != address(0), "_PM1");
        require(_powType == 1 || _powType == 2, "_PM2");
        
        if(_powType == 1) {
            _maBalances[_account] += _amount;
        }else {
            _seBalances[_account] += _amount;
        }

        powTotalSupply += _amount;
        _addPowSharer(_account);
        
        // _powRecord(address(0), _account, _amount, _powType);
    }

    function _powBurn(address _account, uint256 _amount) internal {
        require(_account != address(0), "_PB1");
        uint256 _accountBalance = _seBalances[_account];
        require(_accountBalance >= _amount, "_PB2");

        unchecked {
            _seBalances[_account] = _accountBalance - _amount;
        }

        powTotalSupply -= _amount;

        _powRecord(_account, address(0), _amount, 2);        
    }

    function _addPowSharer(address _account) internal {        
        if(!(_isSharer[_account] > 0)) {            
            _userCount++;
            _isSharer[_account] = _userCount;
        }
    }  

    function _powRecord(address _from, address _to, uint256 _amount, uint256 _powType) internal {
        uint256 _day = block.timestamp / 1 days;

        if(_from != address(0)) {
            accToPow[_from][_day] = _maBalances[_from] + _seBalances[_from];
        }
        if(_to != address(0)) {
            accToPow[_to][_day] = _maBalances[_to] + _seBalances[_to];
        }

        dayToPow[_day] = powTotalSupply;

        emit PTransfer(_from, _to, _amount, _powType);
    }

}

contract WFSToken is ERC20, WFSPower {
    struct BC {
        uint256 base;
        uint256 rate;
    }

    struct SO {
        uint256 amount;
        uint256 pow;
        uint256 storageDate;
    }

    SO[] private _storageOrders;
    address[] private _funders;

    uint256 constant public ShareDeflation = 5;
    uint256 public shareAmount = 50000000000000;
    uint256 public shareDate = block.timestamp;
    // 合约发布日期
    uint256 constant public StartDate = 19222;
    uint256 public shareCount = 0;
    uint256 public storageBase = 300000000000;  
    
    mapping(uint256 => BC) public rewardConf;
    mapping(address => bool) public pairAddress;
    mapping(uint256 => uint256) public burnBase;
    
    mapping(address => uint256) public accToReAmt;
    mapping(address => uint256) public accToReDay;

    mapping(address => uint256) private _freezeBalances;
    mapping(uint256 => uint256) private _soToAmt;
    mapping(uint256 => address) private _soToAcc;
    
    
    event Burned(address indexed burner, uint256 amount, uint256 amountType, uint256 burnType);
    event Storaged(uint256 indexed id, address indexed stroager, uint256 amount);
    event Retrieved(uint256 indexed id, address indexed retriever, uint256 amount);   
    event Received(address indexed receiver, uint256 amount);

    constructor() ERC20("WFCD", "WFCD") {
        _mint(msg.sender, 1000000000000000000);

        burnBase[50] = 100000000000;
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

    function decimals() public pure override returns (uint8) {
        return 8;
    }

    function freezeBalanceOf(address account) public view returns (uint256) {
        return _freezeBalances[account];
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();

        if(pairAddress[owner]) {
            _burn(owner, amount);
            _freezeBalances[to] += amount;
        } else {
            _transfer(owner, to, amount);
        }

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amount);
        if(pairAddress[spender]) {
            _burn(from, amount);
            _freezeBalances[to] += amount;
        }else {
            _transfer(from, to, amount);
        }
        
        return true;
    }

    function getStorageOrder(uint256 _id) public view returns(SO memory) {
        require(_msgSender() == _soToAcc[_id]);
        return _storageOrders[_id];
    }

    function setFunders(address[] calldata _members) public onlyOwner {
        _funders = _members;
    }

    function addPairAddress(address _pair) public onlyOwner {
       pairAddress[_pair] = true;
    }

    function removePairAddress(address _pair) public onlyOwner {
        pairAddress[_pair] = false;
    }

    function burned(uint256 _amount, uint256 _amountType, uint256 _burnType) public returns(bool) { 
        require(_amountType == 1 || _amountType == 2, "B1");
        require(_burnType == 50 || _burnType == 100, "B2");

        uint256 _base = burnBase[_burnType];        
        address _burner = _msgSender();

        require(_amount >= _base, "B3");

        uint256 _pow = _amount * 100 / _base;

        if(_amountType == 1) {            
            require(_burnType == 100, "B4");
            _burn(_burner, _amount);  
        }else {               

            uint256 accountBalance = _freezeBalances[_burner];        
            require(accountBalance >= _amount, "B5");
            unchecked {
                _freezeBalances[_burner] = accountBalance - _amount;
            }

            if(_burnType == 50) {
                _mint(_burner, (_amount / 2));
                _pow = _amount * 50 / _base;
            }
        }

        _powMint(_burner, _pow, 1);
        _reward(_burner, _pow, 1, 1);

        emit Burned(_burner, _amount, _amountType, _burnType);
        
        return true;
    }

    function storaged(uint256 _amount) public returns(bool) {
        require(_amount >= storageBase, "S1");
        
        address _storager = _msgSender();
        require(!(pairAddress[_storager]), "S2");

        uint256 _pow = _amount * 100 / storageBase;
        
        _transfer(_storager, address(this), _amount); 
        _storageOrders.push(SO(_amount, _pow, block.timestamp));

        uint256 _id = _storageOrders.length - 1;
        _soToAcc[_id] = _storager;
        _soToAmt[_id] = _amount;

        _powMint(_storager, _pow, 2);
        _reward(_storager, _pow, 2, 1);

        emit Storaged(_id, _storager, _amount);

        return true;
    }

    function retrieved(uint256 _id) public returns(bool) {
        address _retriever = _msgSender();
        require(_retriever == _soToAcc[_id], "RT1");

        SO storage _so = _storageOrders[_id];

        require(block.timestamp >= _so.storageDate + 7 days, "RT2");

        uint256 _amount = _soToAmt[_id];
        require(_amount > 0, "RT3");

        _soToAmt[_id] = 0;
        _transfer(address(this), _retriever, _amount);

        _powBurn(_retriever, _so.pow);
        _reward(_retriever, _so.pow, 2, 2);

        emit Retrieved(_id, _retriever, _amount);

        return true;
    }   

    function getDailyBonus(address _account) public view returns(uint256) {
        uint256 _id = getPowSharer(_account);
        require(_id > 0, "GDB");

        uint256 _pow = powMaBalanceOf(_account) + powSeBalanceOf(_account);
        uint256 _amount = 0;
        if(_pow >= 100) {
            _amount = (shareAmount * _pow * 96) / (powTotalSupply * 100);
        }

        return _amount;
    }
    
    function shareBonus() public onlyOwner returns(bool) {
        require((block.timestamp / 1 days) > (shareDate / 1 days), "SB1");
        
        shareDate += 1 days;
        shareCount += 1;
           
        uint256 _num = _funders.length;

        if(_num > 0) {
            uint256 _amount = (shareAmount * 4) / (_num * 100) ;
            for(uint256 i = 0; i <_num; i++) {
                _mint(_funders[i], _amount);
            }
        }

        if((shareCount % 360) == 0) {
            shareAmount = 500000 * 10 ** 8 * (100 - (shareCount / 360) * ShareDeflation) / 100;
        }

        return true;
    }

    function dailyBouns() public isBlackList(_msgSender()) returns(bool) {
        address _account = _msgSender();

        uint256 _id = getPowSharer(_account);
        require(_id > 0, "UB1");

        // 用户最后领取分红的日期
        uint256 _rday = accToReDay[_account];
        // 当前日期
        uint256 _cday = block.timestamp / 1 days;

        _rday = (_rday > StartDate) ? _rday : StartDate;
        _rday = (_rday > _cday) ? _rday : _cday;
        
        // 可以领取的分红
        // uint256 _bouns = 0;
        
        // 从当前天领取之前所有没有领取的，最大30天的分红
        for(uint256 i=_cday; i>=_rday; i--) {

        }

        accToReDay[_account] = _cday;

        return true;
    }
  
    function _reward(address _account, uint256 _pow, uint256 _powType, uint256 _buniessType) private {
        require(_powType == 1 || _powType ==2, "R1");
        require(_buniessType == 1 || _buniessType ==2, "R2");
   
        address _cur = isConnected[_account];
        uint256 _count = 1;

        while(_cur != address(0) && _count <= 13){
            uint256 _curpow = _pow * rewardConf[_count].rate / 100;
            if(_curpow > 0) {
                if(_buniessType == 1) {                    
                    _powMint(_cur, _curpow, _powType);
                } else {
                    _powBurn(_cur,_curpow);
                }
            }
            
            _cur = isConnected[_cur];
            _count++;
        }    
    }

}