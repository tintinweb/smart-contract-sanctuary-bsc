/**
 *Submitted for verification at BscScan.com on 2022-02-22
*/

pragma solidity =0.8.11;


// SPDX-License-Identifier: MIT 
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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

//  
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

//  
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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

//  
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)
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

//  
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)
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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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

// 
contract WCoin is ERC20("WCoin", "WCOIN"), Ownable {

    uint256 private tokenPrice;
    uint256 private constant initialSupply = 100000000e18;

    uint256 public privateSellSupply = 7000000e18;
    address private immutable privateSellAddress;
    mapping(uint256 => uint256[2]) private privateSupplyMapping;

    uint256 public IDOSupply = 6000000e18;
    address private immutable IDOAddress;
    mapping(uint256 => uint256[]) private IDOSupplyMapping;

    uint256 public pancakeSwapSupply = 1000000e18;

    uint256 public p2eSupply = 55000000e18;
    address private immutable p2eAddress;

    uint256 public marketingSupply = 5000000e18;
    address private immutable marketingAddress;
    mapping(uint256 => uint256[]) private marketingSupplyMapping;

    uint256 public constant teamSupply = 10000000e18;
    uint256 private currentTeamSupply = teamSupply;
    address private immutable teamAddress;

    uint256 public advisorsSupply = 3000000e18;
    address private immutable advisorsAddress;
    mapping(uint256 => uint256[]) private advisorsSupplyMapping;

    uint256 public stakingSupply = 5000000e18;
    address private immutable stakingAddress;
    mapping(uint256 => uint256[]) private stakingSupplyMapping;

    uint256 public treasurySupply = 8000000e18;
    address private immutable treasuryAddress;
    mapping(uint256 => uint256[]) private treasurySupplyMapping;

    uint256 public creationTime = block.timestamp;

    /// @notice Boolean to permanently disable minting of new tokens
    bool public mintingPermanentlyDisabled = false;

    // Event that logs every buy operation
    event BuyTokens(address _buyer, uint256 _price, uint256 _amountTokens);
    event SoldTokens(address _seller, uint256 _amountTokens);

    event WithDrawn(uint256 _amount, address _recipient);

    constructor(
        uint256 _price,
        address _privateSellAddress,
        address _IDOAddress,
        address _p2eAddress,
        address _marketingAddress,
        address _teamAddress,
        address _advisorsAddress,
        address _stakingAddress,
        address _treasuryAddress
    ) {
        tokenPrice = _price;
        teamAddress = _teamAddress;

        privateSellAddress = _privateSellAddress;
        // Private Sell: 4 months 20% each (starting from moment of deploy 0). Then 10% for 2 more months
        privateSupplyMapping[0]= [0 days, privateSellSupply - privateSellSupply / 5];
        privateSupplyMapping[1]= [30 days, privateSupplyMapping[0][1] - privateSellSupply / 5];
        privateSupplyMapping[2]= [60 days, privateSupplyMapping[1][1] - privateSellSupply / 5];
        privateSupplyMapping[3]= [90 days, privateSupplyMapping[2][1] - privateSellSupply / 5];
        privateSupplyMapping[4] = [120 days, privateSupplyMapping[3][1] - privateSellSupply / 10];
        privateSupplyMapping[5] = [150 days, privateSupplyMapping[4][1] - privateSellSupply / 10];

        IDOAddress = _IDOAddress;
        // IDO: 4 months 20% each (starting from moment of deploy 0). Then 10% for 2 more months
        IDOSupplyMapping[0]= [0 days, IDOSupply - IDOSupply / 5];
        IDOSupplyMapping[1]= [30 days, IDOSupplyMapping[0][1] - IDOSupply / 5];
        IDOSupplyMapping[2]= [60 days, IDOSupplyMapping[1][1] - IDOSupply / 5];
        IDOSupplyMapping[3]= [90 days, IDOSupplyMapping[2][1] - IDOSupply / 5];
        IDOSupplyMapping[4] = [120 days, IDOSupplyMapping[3][1] - IDOSupply / 10];
        IDOSupplyMapping[5] = [150 days, IDOSupplyMapping[4][1] - IDOSupply / 10];

        marketingAddress = _marketingAddress;
        // Marketing: 11 % per month for the first 8 months. Last month 12% (TBC)
        for (uint i = 0; i < 8; i++) {
            if (i == 0) {
                marketingSupplyMapping[i] = [(i * 30 days) + 30 days, marketingSupply - ((marketingSupply / 10) + (marketingSupply / 100))];
            } else {
                marketingSupplyMapping[i] = [(i * 30 days) + 30 days, marketingSupplyMapping[i-1][1] - ((marketingSupply / 10) + (marketingSupply / 100))];
            }
            
        }
        // 12% last month
        marketingSupplyMapping[8] = [(8 * 30 days) + 30 days, marketingSupplyMapping[7][1] - ((marketingSupply / 10) + (marketingSupply / 100) * 2)];

        treasuryAddress = _treasuryAddress;
        // Treasury: 1 Year Locked. Then 10 % per month (10 months)
        for (uint i = 0; i < 10; i++) {
            if (i==0) { 
                treasurySupplyMapping[i] = [(i * 30 days), treasurySupply - (treasurySupply / 10)];
            } else {
                treasurySupplyMapping[i] = [(i * 30 days), treasurySupplyMapping[i-1][1] - (treasurySupply / 10)];
            }
        }

        advisorsAddress = _advisorsAddress;
        // Advisors: 1 Year locked. Then 30 % per month. Then last month 10%.
        for (uint i = 0; i < 3; i++) {
            if (i==0) {
                advisorsSupplyMapping[i] = [(i * 30 days), advisorsSupply - ((advisorsSupply / 10) * 3)];
            } else {
                advisorsSupplyMapping[i] = [(i * 30 days), advisorsSupplyMapping[i-1][1] - ((advisorsSupply / 10) * 3)];
            }
        }
        advisorsSupplyMapping[3] = [90 days, advisorsSupplyMapping[2][1] - (advisorsSupply / 10)];

        stakingAddress = _stakingAddress;
        // 3 Months blocked. Then 33%, 33%, 34%
        stakingSupplyMapping[0] = [(0 * 30 days) + 30 days, stakingSupply - (stakingSupply * 33 / 100)];
        stakingSupplyMapping[1] = [(1 * 30 days) + 30 days, stakingSupplyMapping[0][1] - (stakingSupply * 33 / 100)];
        stakingSupplyMapping[2] = [(2 * 30 days) + 30 days, stakingSupplyMapping[1][1] - (stakingSupply * 34 / 100)];
        
        p2eAddress = _p2eAddress;
    }

    /**
     * @notice Mint new tokens to owner
     *
     * Requirements:
     *
     * - Minting must not be permanently disabled
     */
    function mint() public onlyOwner {
        require(!mintingPermanentlyDisabled, "Minting permanently disabled!");
        _mint(p2eAddress, p2eSupply); // Minting to p2eAddress - SHOULD NOT BE OWNED BY CREATORS
        _mint(msg.sender, pancakeSwapSupply); //Mint only pancakeswap to owner for staking
        _mint(address(this), initialSupply - p2eSupply - pancakeSwapSupply);
        disableMintingPermanently(); // Disabling minting forever
    }
    
    function buy() payable public {
        uint256 amountTobuy = msg.value;
        uint256 contractBalance = balanceOf(address(this));
        require(amountTobuy <= contractBalance, "Not enough tokens in the reserve.");
        require(tokenPrice > 0, "You need to send some BNB");

        transfer(msg.sender, amountTobuy);
        emit BuyTokens(msg.sender, tokenPrice, amountTobuy);
    }

    function sell(uint256 _amount) public {
        require(_amount > 0, "More than 0 tokens must be sold");

        uint256 allowance = allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check token allowance");

        transferFrom(msg.sender, address(this), _amount);

        transfer(msg.sender, _amount);
        emit SoldTokens(msg.sender, _amount);
    }

    function getCurrentBalance() external view returns(uint256) {
        uint256 balance = address(this).balance;
        return balance;
    }

    /**
     * @notice Disable minting permanently
     */
    function disableMintingPermanently() private onlyOwner {
        mintingPermanentlyDisabled = true;
    }

    function setTokenPrice(uint256 _price) external onlyOwner() {
        tokenPrice = _price;
    }

    function getTokenPrice() public view returns (uint256) {
        return tokenPrice;
    }

    function checkCanRelease(uint256 _allowed, uint256 _supply, uint256 _amount) private pure returns (bool) {
        return _allowed <= (_supply - _amount);
    }

    function releasePrivateSellFunds(uint256 _amount) public onlyOwner {
        require(privateSellSupply > 0, "Not enough private sell supply");
        require(privateSellSupply - _amount > 0, "Amount can not exceed private sell supply");

        uint256 releaseAllowed;
        bool isAllowed = false;
    
        for(uint i = 0; i < 6; i++) {
            if (block.timestamp >= (creationTime + privateSupplyMapping[i][0])) {
                releaseAllowed = privateSupplyMapping[i][1];
                isAllowed = true;
            }
        }

        require(isAllowed, "Timelock active, not yet allowed!");
        require(checkCanRelease(releaseAllowed, privateSellSupply, _amount), "Amount not allowed!");
        transfer(privateSellAddress, _amount);
        privateSellSupply = privateSellSupply - _amount;
        emit WithDrawn(_amount, privateSellAddress);
    }

    function releaseIDOFunds(uint256 _amount) public onlyOwner {
        require(IDOSupply > 0, "Not enough IDO supply");
        require(IDOSupply - _amount > 0, "Amount can not exceed IDO supply");

        uint256 releaseAllowed;
        bool isAllowed = false;
    
        for(uint i = 0; i < 6; i++) {
            if (block.timestamp >= (creationTime + IDOSupplyMapping[i][0])) {
                releaseAllowed = IDOSupplyMapping[i][1];
                isAllowed = true;
            }
        }

        require(isAllowed, "Timelock active, not yet allowed!");
        require(checkCanRelease(releaseAllowed, IDOSupply, _amount), "Amount not allowed!");
        transfer(IDOAddress, _amount);
        IDOSupply = IDOSupply - _amount;
        emit WithDrawn(_amount, IDOAddress);
    }

    function releaseMarketingFunds(uint256 _amount) public onlyOwner {
        require(marketingSupply > 0, "Not enough Marketing supply");
        require(marketingSupply - _amount > 0, "Amount can not exceed Marketing supply");

        uint256 releaseAllowed;
        bool isAllowed = false;
    
        for(uint i = 0; i < 9; i++) {
            if (block.timestamp >= (creationTime + marketingSupplyMapping[i][0])) {
                releaseAllowed = marketingSupplyMapping[i][1];
                isAllowed = true;
            }
        }

        require(isAllowed, "Timelock active, not yet allowed!");
        require(checkCanRelease(releaseAllowed, marketingSupply, _amount), "Amount not allowed!");
        transfer(marketingAddress, _amount);
        marketingSupply = marketingSupply - _amount;
        emit WithDrawn(_amount, marketingAddress);
    }

    function releaseAdvisorsFunds(uint256 _amount) public onlyOwner {
        require(advisorsSupply > 0, "Not enough Advisors supply");
        require(advisorsSupply - _amount > 0, "Amount can not exceed Advisors supply");

        bool isAllowed = false;
        uint256 releaseAllowed;
        uint256 restrictedTime = creationTime + 365 days;
    
        if (block.timestamp >= restrictedTime) {
            for(uint i = 0; i < 4; i++) {
                if (block.timestamp >= (restrictedTime + advisorsSupplyMapping[i][0])) {
                    releaseAllowed = advisorsSupplyMapping[i][1];
                    isAllowed = true;
                }
            }
        }

        require(isAllowed, "Timelock active, not yet allowed!");
        require(checkCanRelease(releaseAllowed, advisorsSupply, _amount), "Amount not allowed!");
        transfer(advisorsAddress, _amount);
        advisorsSupply = advisorsSupply - _amount;
        emit WithDrawn(_amount, advisorsAddress);
    }

    function releaseTreasuryFunds(uint256 _amount) public onlyOwner {
        require(treasurySupply > 0, "Not enough Treasury supply");
        require(treasurySupply - _amount > 0, "Amount can not exceed Treasury supply");

        bool isAllowed = false;
        uint256 releaseAllowed;
        uint256 restrictedTime = creationTime + 365 days;
    
        if (block.timestamp >= restrictedTime) {
            for(uint i = 0; i < 10; i++) {
                if (block.timestamp >= (restrictedTime + treasurySupplyMapping[i][0])) {
                    releaseAllowed = treasurySupplyMapping[i][1];
                    isAllowed = true;
                }
            }
        }

        require(isAllowed, "Timelock active, not yet allowed!");
        require(checkCanRelease(releaseAllowed, treasurySupply, _amount), "Amount not allowed!");
        transfer(treasuryAddress, _amount);
        treasurySupply = treasurySupply - _amount;
        emit WithDrawn(_amount, treasuryAddress);
    }


    function releaseStakingFunds(uint256 _amount) public onlyOwner {
        require(stakingSupply > 0, "Not enough Staking supply");
        require(stakingSupply - _amount > 0, "Amount can not exceed Staking supply");

        bool isAllowed = false;
        uint256 releaseAllowed;
        uint256 restrictedTime = creationTime + 90 days;
    
        for(uint i = 0; i < 3; i++) {
            if (block.timestamp >= (restrictedTime + stakingSupplyMapping[i][0])) {
                releaseAllowed = stakingSupplyMapping[i][1];
                isAllowed = true;
            }
        }

        require(isAllowed, "Timelock active, not yet allowed!");
        require(checkCanRelease(releaseAllowed, stakingSupply, _amount), "Amount not allowed!");
        transfer(stakingAddress, _amount);
        stakingSupply = stakingSupply - _amount;
        emit WithDrawn(_amount, stakingAddress);
    }

    function getTeamFundsAllowed() private view returns (uint256) {
        uint256 releaseAllowed = 0;
        uint256 restrictedTime = creationTime + 365 days;

        for (uint i = 0; i < 365; i++) {
            if (block.timestamp >= (restrictedTime + (i * 1 days))) {
                releaseAllowed = releaseAllowed + teamSupply / 365;
            }
        }

        return releaseAllowed;
    }

    function releaseTeamFunds(uint256 _amount) public onlyOwner {
        require(currentTeamSupply > 0, "Not enough Team supply");
        require(currentTeamSupply - _amount > 0, "Amount can not exceed Team supply");

        bool isAllowed = false;
        uint256 releaseAllowed;
        uint256 restrictedTime = creationTime + 365 days;
    
        if (block.timestamp >= restrictedTime) {
            isAllowed = true;
            releaseAllowed = getTeamFundsAllowed();
        }

        require(isAllowed, "Timelock active, not yet allowed!");
        require(checkCanRelease(releaseAllowed, currentTeamSupply, _amount), "Amount not allowed!");
        transfer(teamAddress, _amount);
        currentTeamSupply = currentTeamSupply - _amount;
        emit WithDrawn(_amount, teamAddress);
    }
}