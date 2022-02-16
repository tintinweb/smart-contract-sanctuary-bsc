/**
 *Submitted for verification at BscScan.com on 2022-02-15
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
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// 
contract WCoin is ERC20("WCoin", "WCOIN"), Ownable {

    uint256 private tokenPrice;
    uint256 private constant initialSupply = 100000000e18;

    uint256 private privateSellSupply = 7000000e18;
    address private immutable privateSellAddress;
    mapping(uint256 => uint256[2]) private privateSupplyMapping;

    uint256 private IDOSupply = 6000000e18;
    address private immutable IDOAddress;
    mapping(uint256 => uint256[]) private IDOSupplyMapping;

    uint256 private pancakeSwapSupply = 1000000e18;

    uint256 private p2eSupply = 55000000e18;
    address private immutable p2eAddress;

    uint256 private marketingSupply = 5000000e18;
    address private immutable marketingAddress;
    mapping(uint256 => uint256[]) private marketingSupplyMapping;

    uint256 private constant teamSupply = 10000000e18;
    uint256 private currentTeamSupply = teamSupply;
    address private immutable teamAddress;

    uint256 private advisorsSupply = 3000000e18;
    address private immutable advisorsAddress;
    mapping(uint256 => uint256[]) private advisorsSupplyMapping;

    uint256 private stakingSupply = 5000000e18;
    address private immutable stakingAddress;
    mapping(uint256 => uint256[]) private stakingSupplyMapping;

    uint256 private treasurySupply = 8000000e18;
    address private immutable treasuryAddress;
    mapping(uint256 => uint256[]) private treasurySupplyMapping;

    uint256 private creationTime = block.timestamp;

    /// @notice Boolean to permanently disable minting of new tokens
    bool public mintingPermanentlyDisabled = false;

    // Event that logs every buy operation
    event BuyTokens(address _buyer, uint256 _price, uint256 _amountTokens);
    event SoldTokens(address _seller, uint256 _amountTokens);

    event WithDrawn(uint256 _amount, address _recipient);

    AggregatorV3Interface private priceFeed;

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

        // Build mappings accordingly
        privateSellAddress = _privateSellAddress;
        for (uint i = 0; i < 4; i++) {
            privateSupplyMapping[i] = [(i * 30 days) + 30 days, (privateSellSupply / 5) * (i + 1)];
        }
        privateSupplyMapping[3] = [150 days, privateSellSupply / 10];

        IDOAddress = _IDOAddress;
        for (uint i = 0; i < 4; i++) {
            IDOSupplyMapping[i]= [(i * 30 days) + 30 days, (IDOSupply / 5 ) * (i + 1)];
        }
        IDOSupplyMapping[3] = [150 days, IDOSupply / 10];

        marketingAddress = _marketingAddress;
        // 11 % per month for first 8 months
        for (uint i = 0; i < 8; i++) {
            marketingSupplyMapping[i] = [(i * 30 days) + 30 days, (marketingSupply / 10) + (marketingSupply / 100)];
        }
        // 12% last month
        marketingSupplyMapping[8] = [(8 * 30 days) + 30 days, (marketingSupply / 10) + (marketingSupply / 100) * 2];

        treasuryAddress = _treasuryAddress;
        // 10 % per month
        for (uint i = 0; i < 10; i++) {
            treasurySupplyMapping[i] = [(i * 30 days) + 30 days, treasurySupply / 10];
        }

        advisorsAddress = _advisorsAddress;
        // 30 % per month
        for (uint i = 0; i < 3; i++) {
            advisorsSupplyMapping[i] = [(i * 30 days) + 30 days, (advisorsSupply / 10) * 3];
        }
        // Last month 10%
        advisorsSupplyMapping[3] = [(3 * 30 days) + 30 days, advisorsSupply / 10];

        stakingAddress = _stakingAddress;
        // 30 % per month
        for (uint i = 0; i < 3; i++) {
            stakingSupplyMapping[i] = [(i * 30 days) + 30 days, (stakingSupply / 10) * 3];
        }
        // Last month 10%
        stakingSupplyMapping[3] = [(3 * 30 days) + 30 days, stakingSupply / 10];

        p2eAddress = _p2eAddress;

        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE); // Chainlink BNB/USD Price Feed
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
    

    function getLatestBNBPrice() private view returns (uint256) {
        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    function getBNBFee() private view returns (uint256) {
        uint256 BNBFee = uint256(19) / uint256(20) / getLatestBNBPrice(); // $0.95 fee
        return BNBFee;
    }
    
    function buy() payable public {
        uint256 contractBalance = balanceOf(address(this));
        require(msg.value <= contractBalance, "Not enough tokens in the reserve.");

        uint256 finalPrice = tokenPrice + getBNBFee(); // TokenPrice + $0.95
        require(finalPrice > 0, "You need to send some BNB");

        transfer(msg.sender, msg.value);
        emit BuyTokens(msg.sender, finalPrice, msg.value);
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
    function disableMintingPermanently() public onlyOwner {
        mintingPermanentlyDisabled = true;
    }

    function setTokenPrice(uint256 _price) external onlyOwner() {
        tokenPrice = _price;
    }

    function getTokenPrice() external view returns (uint256) {
        return tokenPrice;
    }

    function checkCanRelease(uint256 _allowed, uint256 _supply, uint256 _amount) private pure returns (bool) {
        return _allowed <= (_supply - _amount);
    }
   
    function withdraw() public onlyOwner {
        uint256 balance = balanceOf(address(this));
        transfer(msg.sender, balance);
    }

    function releasePrivateSellFunds(uint256 _amount) public onlyOwner {
        require(privateSellSupply > 0, "Not enough private sell supply");

        uint256 releaseAllowed = 0;
        bool isAllowed = false;
    
        for(uint i = 0; i < 4; i++) {
            if (block.timestamp >= (creationTime + privateSupplyMapping[i][0])) {
                releaseAllowed = releaseAllowed + privateSupplyMapping[i][1];
                isAllowed = true;
            }
        }

        if (isAllowed) {
            require(checkCanRelease(releaseAllowed, privateSellSupply, _amount), "Amount not allowed!");
            transfer(privateSellAddress, _amount);
            privateSellSupply = privateSellSupply - _amount;
            emit WithDrawn(_amount, privateSellAddress);
        }
    }

    function releaseIDOFunds(uint256 _amount) public onlyOwner {
        require(IDOSupply > 0, "Not enough IDO supply");

        uint256 releaseAllowed = 0;
        bool isAllowed = false;
    
        for(uint i = 0; i < 4; i++) {
            if (block.timestamp >= (creationTime + IDOSupplyMapping[i][0])) {
                releaseAllowed = releaseAllowed + IDOSupplyMapping[i][1];
                isAllowed = true;
            }
        }

        if (isAllowed) {
            require(checkCanRelease(releaseAllowed, IDOSupply, _amount), "Amount not allowed!");
            transfer(IDOAddress, _amount);
            privateSellSupply = privateSellSupply - _amount;
            emit WithDrawn(_amount, IDOAddress);
        }
    }

    function releaseMarketingFunds(uint256 _amount) public onlyOwner {
        require(marketingSupply > 0, "Not enough Marketing supply");

        uint256 releaseAllowed = 0;
        bool isAllowed = false;
    
        for(uint i = 0; i < 8; i++) {
            if (block.timestamp >= (creationTime + marketingSupplyMapping[i][0])) {
                releaseAllowed = releaseAllowed + marketingSupplyMapping[i][1];
                isAllowed = true;
            }
        }

        if (isAllowed) {
            require(checkCanRelease(releaseAllowed, marketingSupply, _amount), "Amount not allowed!");
            transfer(marketingAddress, _amount);
            marketingSupply = marketingSupply - _amount;
            emit WithDrawn(_amount, marketingAddress);
        }
    }

    function releaseTreasuryFunds(uint256 _amount) public onlyOwner {
        require(treasurySupply > 0, "Not enough Treasury supply");

        bool isAllowed = false;
        uint256 releaseAllowed = 0;
        uint256 restrictedTime = creationTime + 365 days;
    
        if (block.timestamp >= restrictedTime) {
            for(uint i = 0; i <= 10; i++) {
                if (block.timestamp >= (restrictedTime + treasurySupplyMapping[i][0])) {
                    releaseAllowed = releaseAllowed + treasurySupplyMapping[i][1];
                    isAllowed = true;
                }
            }
        }

        if (isAllowed) {
            require(checkCanRelease(releaseAllowed, treasurySupply, _amount), "Amount not allowed!");
            transfer(treasuryAddress, _amount);
            treasurySupply = treasurySupply - _amount;
            emit WithDrawn(_amount, treasuryAddress);
        }
    }


    function releaseStakingFunds(uint256 _amount) public onlyOwner {
        require(stakingSupply > 0, "Not enough Staking supply");

        bool isAllowed = false;
        uint256 releaseAllowed = 0;
        uint256 restrictedTime = creationTime + 365 days;
    
        for(uint i = 0; i < 4; i++) {
            if (block.timestamp >= (restrictedTime + stakingSupplyMapping[i][0])) {
                releaseAllowed = releaseAllowed + stakingSupplyMapping[i][1];
                isAllowed = true;
            }
        }

        if (isAllowed) {
            require(checkCanRelease(releaseAllowed, stakingSupply, _amount), "Amount not allowed!");
            transfer(stakingAddress, _amount);
            stakingSupply = stakingSupply - _amount;
            emit WithDrawn(_amount, stakingAddress);
        }
    }


    function getTeamFundsAllowed() private returns (uint256) {
        uint256 releaseAllowed = 0;
        uint256 restrictedTime = creationTime + 365 days;

        for (uint i = 0; i < 365; i++) {
            if (block.timestamp >= (restrictedTime + (i * 1 days))) {
                releaseAllowed = releaseAllowed + ( teamSupply / 365 );
            }
        }

        return releaseAllowed;
    }
    

    function releaseTeamFunds(uint256 _amount) public onlyOwner {
        require(currentTeamSupply > 0, "Not enough Team supply");

        bool isAllowed = false;
        uint256 releaseAllowed = 0;
        uint256 restrictedTime = creationTime + 365 days;
    
        if (block.timestamp >= restrictedTime) {
            isAllowed = true;
            releaseAllowed = getTeamFundsAllowed();
        }

        if (isAllowed) {
            require(checkCanRelease(releaseAllowed, currentTeamSupply, _amount), "Amount not allowed!");
            transfer(teamAddress, _amount);
            currentTeamSupply = currentTeamSupply - _amount;
            emit WithDrawn(_amount, teamAddress);
        }
    }

}