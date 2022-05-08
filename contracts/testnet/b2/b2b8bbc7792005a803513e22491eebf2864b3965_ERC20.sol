// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./PancakeSwap.sol";

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
contract ERC20 is Context, Ownable, IERC20{

    // Modifiers in swap, reentrant
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) isFeeExempt;           // Addresses exempt from paying fees
    mapping(address => bool) isBot;                 // Bot Addresses

    // Time between trades10 seconds
    bool private cooldownenabled;
    uint256 private constant cooldowntime = 10 seconds;
    mapping(address => uint256) private cooldown;

    // Token identify
    string private _name;
    string private _symbol;

    // Token state
    uint256 private launchedAt;

    // Token supply
    uint8   private constant _decimals = 18;                      // Token decimals
    uint256 private constant _supplywithoutdecimals = 1000000;    // Supply without decimals
    uint256 private constant _totalSupply = _supplywithoutdecimals * (10 ** _decimals); // Supply with decimals
    uint256 private constant _walletMax = _totalSupply * 4 / 100; // (40k) Max tokens cuantity per wallet (4% of supply)

    // Token fees, are constant variables, modification is not possible
    uint256 private constant _feemarketing = 1;     // Token fee for marketing
    uint256 private constant _feeliquidity = 1;     // Token fee for liquidity pair
    uint256 private constant _feedeveloper = 1;     // Token fee for developer
    uint256 private constant _feetotal = _feemarketing + _feeliquidity + _feedeveloper; // Total fee is 3% for transaction

    uint256 public swapThreshold = _walletMax / 4;  // (10k) minimun tokens in contract to convert fees in bnb

    // Wallets
    address _walletmarketing = 0xac917B6aF391AB8fF05293954DaDC8eEDF2D34ae;  // Destiny for marketing fees
    address _walletdev       = 0xDa32e02f806e40d592880b529D8B49b676295175;  // Destiny for developer fees
    address _walletliquidity = 0x0AEb952F69aC1c923a3C167F2bD722b9f162199a;  // Destiny for liquidity fees

    // Pancake
    address private routeraddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // Router address testnet todo cambiar en mainnet
    address private WBNB;
    IPancakeSwapRouter private router;
    IPancakeSwapFactory private factory;
    address public pair;

    // Events
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

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
        // Token identify
        _name = name_;
        _symbol = symbol_;

        // Token state
        launchedAt = 0;             // Not launched
        cooldownenabled = false;    // Time between trades protection unabled

        // Initial tokens
        _balances[owner()] += _totalSupply;
        emit Transfer(address(0), owner(), _totalSupply);

        // Fee exceptions
        isFeeExempt[owner()] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[_walletmarketing] = true;
        isFeeExempt[_walletdev] = true;
        isFeeExempt[_walletliquidity] = true;

        // Pancake data
        router = IPancakeSwapRouter(routeraddress);
        factory = IPancakeSwapFactory(router.factory());

        // Pancake router allowance
        _allowances[address(this)][address(router)] = type(uint256).max;
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
        return _decimals;
    }

    /**
     * @dev Returns the number of existing tokens created without decimals
     */
    function totalSupplyWithoutDecimals() external pure returns (uint256) {
        return _supplywithoutdecimals;
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
     * @dev Set address fee exception state.
     */
    function setFeeException(address account, bool except) external onlyOwner(){
        isFeeExempt[account] = except;
    }

    /**
     * @dev See address fee exception state.
     */
    function getFeeException(address account) external view returns(bool){
        return isFeeExempt[account];
    }

    /**
     * @dev Set address blacklisted state.
     */
    function setBotlistAccount(address account, bool boolean) external onlyOwner(){
        isBot[account] = boolean;
    }

    /**
     * @dev See address fee exception state.
     */
    function getBotlistAccount(address account) external view returns(bool){
        return isBot[account];
    }

    /**
     * @dev Activate or deactivate the cooldown between buy and sell.
     */
    function setCooldownEnabled(bool boolean) external onlyOwner() {
        cooldownenabled = boolean;
    }

    /**
     * @dev See address fee exception state.
     */
    function isCooldownEnabled() external view onlyOwner() returns(bool){
        return cooldownenabled;
    }

    /**
     * @dev See if the token is launched and tradeable
     */
    function launched() external view returns (bool){
        return _launched();
    }

    function _launched() internal view returns (bool){
        return launchedAt != 0;
    }

    /**
     * @dev Execute token launch and make it tradable
     */
    function _launch() external onlyOwner() {
        require(!_launched(), "Token has already been launched");
        // Save the launch blok
        launchedAt = block.number;
        // Get pair
        WBNB = router.WETH();
        pair = factory.createPair(WBNB, address(this));
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
        _transfer(_msgSender(), to, amount);
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
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
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
    function _transfer(address from, address to, uint256 amount) internal returns(bool){
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Transfer amount must be greater than zero");
        require(!isBot[from] && !isBot[to], "ERC20: Address is blacklisted");

        // Launch when owner provide liquidity
        //if(!_launched() && from == owner()) { _launch(); }
        require(_launched(), "ERC20: The token has not been launched yet");

        // Active cooldown
        if (from == pair && to != routeraddress && !isFeeExempt[to] && cooldownenabled){   // Buying
            cooldown[to] = block.timestamp + cooldowntime;
        }
        if (to == pair && from != routeraddress && !isFeeExempt[from] && cooldownenabled){ // Selling
            require(cooldown[to] < block.timestamp);
        }

        // Executed if is a reentrant transfer
        if(inSwap){ return _basicTransfer(from, to, amount); }

        // Check the wallet max limit if reciver is not contract or liquidity pair
        if (to != pair && to != address(this)) {
            require(_balances[to] + amount <= _walletMax, "Transfer amount exceeds limit wallet size.");
        }

        // Manage contract tokens fees balance
        if(msg.sender != pair && !inSwap && _balances[address(this)] >= swapThreshold){ swapBack(); }

        // Balance sender
        require(_balances[from] >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] -= amount;
        }

        // Take fees from transfer amount
        uint256 finalAmount = !isFeeExempt[from] && !isFeeExempt[to] ? takeFee(from, amount) : amount;
        _balances[to] += finalAmount;

        emit Transfer(from, to, amount);
        return true;
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
        require(_balances[from] >= amount, "ERC20: transfer amount exceeds balance");
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Token fees go to the contract. When contract balance amount exceeds 'swapThreshold',
     *      transfer method execute this and contract balance is swapped to bnb and transfered to
     *      configured wallets.
     */
    function swapBack() internal swapping {
        // Calcule ammount liquidity in our tokens, and ammount to swap in BNB
        uint256 contractbalance = balanceOf(address(this));
        uint256 amountToLiquify = contractbalance * _feeliquidity / _feetotal / 2;
        uint256 amountToSwap = contractbalance - amountToLiquify;

        uint256 balanceBefore = address(this).balance;

        // Swap 'amountToSwap' tokens balance in contract, to BNB
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance - balanceBefore;

        uint256 totalBNBFee = _feetotal - (_feeliquidity / 2);
        uint256 amountBNBLiquidity = amountBNB * _feeliquidity / totalBNBFee / 2;
        uint256 amountBNBMarketing = amountBNB * _feemarketing / totalBNBFee;
        uint256 amountBNBDeveloper = amountBNB * _feedeveloper / totalBNBFee;

        (bool MarketingSuccess,) = payable(_walletmarketing).call{ value: amountBNBMarketing, gas: 30000}("");
        require(MarketingSuccess, "Marketing receiver rejected ETH transfer");
        (bool DeveloperSuccess,) = payable(_walletdev).call{ value: amountBNBDeveloper, gas: 30000}("");
        require(DeveloperSuccess, "Developer receiver rejected ETH transfer");

        // Adding liquidity fee to pair
        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                _walletliquidity,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    /**
     * @dev Swapback executed by owner to convert fees
     */
    function manualSwapBack() external onlyOwner(){
        if(!inSwap){ swapBack(); }
    }

    /**
     * @dev Calcule the fee amount of transation `amount`, an add it to contract.
     *      The fees taken when buying and sell are same
     *
     * Emits an {Transfer} event.
     */
    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        // Amount of fees
        uint256 feeAmount = amount * _feetotal / 100;
        // Fees to contract
        _balances[address(this)] = _balances[address(this)] + feeAmount;
        emit Transfer(sender, address(this), feeAmount);
        // Returns amount of transaction without fees
        return amount - feeAmount;
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
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
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}