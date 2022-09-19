// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./EcoGames.sol";
import "./TokensVesting.sol";

contract Crowdsale {

    TokensVesting public vestingContract;
    EcoGames public ecoGamesContract;

    address _owner;
    address public busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public usdc = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;

    bool public startCrowdsale = true;
    uint256 public tokensRaised;

    uint256[] public limit = [300000000000000000000000000, 1200000000000000000000000000, 2700000000000000000000000000]; // 300m, 1200m, 2700m
    uint256[] public usdRATE = [375, 500, 750]; // 0.00375, 0.005, 0.0075
    uint256 round;

    uint256 public saleEndDate; // timestamp when sale round ends
    uint256 public bnbPrice = 280;

    mapping(address=>uint256) private balances;

    event TokenBought(address indexed buyer, uint256 value, uint256 amount, string token, uint256 round);

    modifier onlyWhenNotPaused() {
        require(startCrowdsale, "Crowdsale: crowdsale has paused");
        _;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Crowdsale: Caller is not the owner");
        _;
    }

    constructor(
        address payable _ecoGamesContract,
        address payable _vestingContract
    ) {
        vestingContract = TokensVesting(_vestingContract);
        ecoGamesContract = EcoGames(_ecoGamesContract);
        _owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _owner = newOwner;
    }

    function buyWithBUSD(uint256 amount)
        public
        onlyWhenNotPaused
    {
        require(amount + tokensRaised <= limit[round], "Amount exceeds sale round limit");
        require(saleEndDate >= block.timestamp, "Sale round is over or has not started");
        
        uint256 usdAmount = getTotalPriceInUSD(amount);
        require(usdAmount >= 10000000000000000000, "Buy amount must be above 10 USD");
        
        bool success = vestingContract._vest(msg.sender, amount, round);
        require(success, "Vesting: failed to vest");
        balances[msg.sender] += usdAmount;

        require(balances[msg.sender] <= 1000000000000000000000, "Balance cannot exceed 1000 USD");
        tokensRaised += amount;

        success = IERC20(busd).transferFrom(msg.sender, _owner, usdAmount);
        require(success, "Transfer has failed");
        emit TokenBought(msg.sender, usdAmount, amount, "BUSD", round);
    }

    function buyWithUSDT(uint256 amount)
        public
        onlyWhenNotPaused
    {
        require(amount + tokensRaised <= limit[round], "Amount exceeds sale round limit");
        require(saleEndDate >= block.timestamp, "Sale round is over or has not started");
        
        uint256 usdAmount = getTotalPriceInUSD(amount);
        require(usdAmount >= 10000000000000000000, "Buy amount must be above 10 USD");

        bool success = vestingContract._vest(msg.sender, amount, round);
        require(success, "Vesting: failed to vest");
        balances[msg.sender] += usdAmount;

        require(balances[msg.sender] <= 1000000000000000000000, "Balance cannot exceed 1000 USD");
        tokensRaised += amount;

        success = IERC20(usdt).transferFrom(msg.sender, _owner, usdAmount);
        require(success, "Transfer has failed");
        emit TokenBought(msg.sender, usdAmount, amount, "USDT", round);
    }

    function buyWithUSDC(uint256 amount)
        public
        onlyWhenNotPaused
    {
        require(amount + tokensRaised <= limit[round], "Amount exceeds sale round limit");
        require(saleEndDate >= block.timestamp, "Sale round is over or has not started");
        
        uint256 usdAmount = getTotalPriceInUSD(amount);
        require(usdAmount >= 10000000000000000000, "Buy amount must be above 10 USD");

        bool success = vestingContract._vest(msg.sender, amount, round);
        require(success, "Vesting: failed to vest");
        balances[msg.sender] += usdAmount;

        require(balances[msg.sender] <= 1000000000000000000000, "Balance cannot exceed 1000 USD");
        tokensRaised += amount;

        success = IERC20(usdc).transferFrom(msg.sender, _owner, usdAmount);
        require(success, "Transfer has failed");
        emit TokenBought(msg.sender, usdAmount, amount, "USDC", round);
    }
    
    function buyWithBNB(uint256 amount)
        public payable onlyWhenNotPaused
    {
        require(amount + tokensRaised <= limit[round], "Amount exceeds sale round limit");
        require(saleEndDate >= block.timestamp, "Sale round is over or has not started");

        uint256 usdAmount = getTotalPriceInUSD(amount);
        require(usdAmount >= 10000000000000000000, "Buy amount must be above 10 USD");
        require(msg.value * bnbPrice >= usdAmount, "Not enough BNBs sent");

        bool success = vestingContract._vest(msg.sender, amount, round);
        require(success, "Vesting: failed to vest");
        
        balances[msg.sender] += usdAmount;
        require(balances[msg.sender] <= 1000000000000000000000, "Balance cannot exceed 1000 USD");

        tokensRaised += amount;
        emit TokenBought(msg.sender, msg.value, amount, "BNB", round);
    }

    function setBnbPrice(uint256 newBnbPrice) public onlyOwner {
        bnbPrice = newBnbPrice;
    }

    function setusdt(address newAddress) public onlyOwner {
        usdt = newAddress;
    }

    function setBusd(address newAddress) public onlyOwner {
        busd = newAddress;
    }

    function setUSDC(address newAddress) public onlyOwner {
        usdc = newAddress;
    }

    function initiateRound(uint256 newRound) public onlyOwner {
        round = newRound;
    }

    function startSalePeriod(uint256 _salePeriod) public onlyOwner {
        saleEndDate = block.timestamp + _salePeriod;
    }

    function togglePauseCrowdsale() public onlyOwner {
        startCrowdsale = !startCrowdsale;
    }

    function endCrowdsale() public onlyOwner {
        vestingContract.initiateVesting();
        togglePauseCrowdsale();
        uint256 bal = address(this).balance;
        if (bal > 0) {
            (bool success, ) = payable(vestingContract).call{value: bal}("");
            require(success, "Failed to send ether to vesting contract");
        }
    }

    function withdraw() public onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "Contract has no balance.");
        (bool success, ) = payable(msg.sender).call{value: bal}("");
        require(success, "Withdrawal has failed.");
    }

    function getTotalPriceInUSD(uint256 _amount) 
        public view returns (uint256) 
    {
        return (_amount * usdRATE[round]) / 100000;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function getRound() public view returns (uint256) {
        return round + 1;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./EcoGames.sol";

contract TokensVesting {
    
    event Received(address, uint);
    event UnlockVest(address indexed holder, uint256 amount);

    EcoGames public ecoGamesContract;
    address public crowdsaleAddress;

    bool locked; // against re-entrancy attacks
    bool startVesting;
    address owner_;
    address[] vesters;

    uint256 public initialPeriod = 90 days;
    uint256 public vestPeriod = 30 days;

    struct vestCore {
        uint256 totalVest;
        uint256 round1;
        uint256 round2;
        uint256 round3;
        uint256 lockedAmount; // remaining vest after initial unlock
        uint256 unlockedAmount;
        uint256 unlockDate;
    }

    mapping(address => vestCore) public vests;

    modifier onlyWhenStarted() {
        require(startVesting, "Vesting: Crowdsale has not ended yet");
        _;
    }

    modifier onlyCrowdsale() {
        require(msg.sender == crowdsaleAddress, "Vesting: Only crowdsale contract can call this function");
        _;
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner_, "Vesting: Caller is not the owner");
        _;
    }

    constructor(address payable _ecoGamesContract) {
        owner_ = msg.sender;
        ecoGamesContract = EcoGames(_ecoGamesContract);
    }

    function setCrowdsaleAddress(address _crowdsaleAddress) public onlyOwner {
        crowdsaleAddress = _crowdsaleAddress;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner_ = newOwner;
    }
    
    function initiateVesting() public onlyCrowdsale {
        require(!startVesting, "TokensVesting: already initiated!");
        startVesting = true;
    }

    function _vest(address to, uint256 amount, uint256 round) 
        public onlyCrowdsale returns (bool)
    {
        vestCore storage vest = vests[to];
        if (vest.totalVest == 0) {
            vesters.push(to);
        }

        if (round == 0) {
            vest.round1 += amount;
        } else if (round == 1) {
            vest.round2 += amount;
        } else {
            vest.round3 += amount;
        }

        vest.totalVest += amount;
        return true;
    }
    
    function initialUnlock() public onlyWhenStarted noReentrant returns (bool) {
        
        vestCore memory vest = vests[msg.sender];
        require(vest.lockedAmount == 0, "Initial unlock has already been done");
        uint256 transferAmount;

        transferAmount += vest.round1 / 20; // 5%
        transferAmount += vest.round2 * 75 / 1000; // 7.5%
        transferAmount += vest.round3 / 10; // 10%

        bool success = ecoGamesContract.transfer(msg.sender, transferAmount);
        require(success, "Transfer has failed");

        vest.round1 = 0;
        vest.round2 = 0;
        vest.round3 = 0;

        vest.lockedAmount = vest.totalVest - transferAmount;
        vest.unlockDate = block.timestamp + initialPeriod;
        
        vests[msg.sender] = vest;
        emit UnlockVest(msg.sender, transferAmount);
        return true;
    }

    function monthlyUnlock() public onlyWhenStarted noReentrant returns (bool) {

        vestCore memory vest = vests[msg.sender];
        require(vest.lockedAmount > 0, "Initial unlock has not been completed");
        require(vest.unlockDate <= block.timestamp, "Unlock date has not passed");

        uint256 unlockAmount = vest.lockedAmount / 21;
        vest.unlockedAmount += unlockAmount;
        require(vest.unlockedAmount <= vest.lockedAmount, "All vests have been unlocked");
        
        bool success = ecoGamesContract.transfer(msg.sender, unlockAmount);
        require(success, "Transfer has failed");

        vest.unlockDate = block.timestamp + vestPeriod;
        vests[msg.sender] = vest;

        emit UnlockVest(msg.sender, unlockAmount);
        return true;
    }

    function setInitialPeriod(uint256 newPeriod) public onlyOwner {
        initialPeriod = newPeriod;
    }

    function setVestPeriod(uint256 newPeriod) public onlyOwner {
        vestPeriod = newPeriod;
    }

    function getMyVest() public view returns (vestCore memory) {
        return vests[msg.sender];
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    } 

    function withdraw() public onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "Contract has no balance.");
        (bool success, ) = payable(msg.sender).call{value: bal}("");
        require(success, "Withdrawal has failed.");
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20/ERC20.sol";

contract EcoGames is ERC20 {

    address owner;
    uint256 public totalBurnt;
    uint256 burnDate;

    constructor() ERC20("Eco Games - Testnet", "EGA test") {
    // constructor() ERC20("Eco Games", "EGA") {
        _mint(msg.sender, 12000000000000000000000000000); 
        owner = msg.sender;
        burnDate = block.timestamp;
    }

    function burn() public returns (bool) {
        require(msg.sender == owner, "Eco Games: Caller is not the owner");
        require(burnDate <= block.timestamp, "Burn date has not reached");
        uint256 amount = 50000000000000000000000000;
        totalBurnt += amount;
        require(totalBurnt <= 3000000000000000000000000000, "Total burnt cannot exceed 3 billion tokens");
        _burn(msg.sender, amount);
        burnDate = 30 days + block.timestamp;
        return true;
    }

    function transferOwnership(address newOwner) public returns (bool) {
        require(owner == msg.sender, "Eco Games: Caller is not the owner");
        owner = newOwner;
        return true;
    }

    receive() external payable {
        (bool success, ) = payable(owner).call{value: msg.value}("");
        require(success, "Transfer has failed.");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "./extensions/Context.sol";

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