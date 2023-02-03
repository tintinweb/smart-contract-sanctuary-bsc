/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.9;

interface IPancakeSwapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeSwapV2Router02 is IPancakeSwapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IERC20 {
    function MaxSupply() external view returns (uint256);
    function Balance_Of(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function Allowance(address Owner, address spender) external view returns (uint256);
    function Approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed Owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function TokenName() external view returns (string memory);
    function Symbol() external view returns (string memory);
    function Decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _Allowances;

    uint256 private _MaxSupply;

    string private _TokenName;
    string private _Symbol;

    constructor(string memory TokenName_, string memory Symbol_) public {
        _TokenName = TokenName_;
        _Symbol = Symbol_;
    }

    function TokenName() public view virtual override returns (string memory) {
        return _TokenName;
    }

    function Symbol() public view virtual override returns (string memory) {
        return _Symbol;
    }

    function Decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function MaxSupply() public view virtual override returns (uint256) {
        return _MaxSupply;
    }

    function Balance_Of(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function Allowance(address Owner, address spender) public view virtual override returns (uint256) {
        return _Allowances[Owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function Approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated Allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have Allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _Allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds Allowance"));
        return true;
    }
   /**
     * @dev Atomically decreases the Allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated Allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have Allowance for the caller of at least
     * `subtractedValue`.
     */
    function DecreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _Allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased Allowance below zero"));
        return true;
    }

    /**
     * @dev Atomically increases the Allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated Allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function IncreaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _Allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

 
    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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

        _MaxSupply = _MaxSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
   /**
     * @dev Sets `amount` as the Allowance of `spender` over the `Owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic Allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `Owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address Owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(Owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _Allowances[Owner][spender] = amount;
        emit Approval(Owner, spender, amount);
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

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _MaxSupply = _MaxSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

 

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
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
}

contract Ownable is Context {
    address private _Owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial Owner.
     */
    constructor () public {
        address msgSender = _msgSender();
        _Owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current Owner.
     */
    function Owner() public view returns (address) {
        return _Owner;
    }

  
    /**
     * @dev Transfers Ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current Owner.
     */
    function ChangeOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new Owner is the zero address");
        emit OwnershipTransferred(_Owner, newOwner);
        _Owner = newOwner;
    }
      /**
     * @dev Throws if called by any account other than the Owner.
     */
    modifier onlyOwner() {
        require(_Owner == _msgSender(), "Ownable: caller is not the Owner");
        _;
    }

    function RenounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_Owner, address(0));
        _Owner = address(0);
    }

}

contract GGO is ERC20, Ownable {
    using SafeMath for uint256;

    IPancakeSwapV2Router02 public PancakeSwapV2Router;
    address public immutable PancakeSwapV2Pair;
    address public immutable DeadWallet_Address = 0x000000000000000000000000000000000000dEaD;

    mapping (address => bool) public CheckBlacklisted;

    bool public _isPaused;

    bool private swapping;

   GGODividendTracker public Check_DividendTracker;

    address public LiqudityAddress;

    uint256 public MaxSellTransactionLimit = 1000000000000000 * (10**9);
    uint256 public SwapTokensAtValue = 100000000000 * (10**9);

    uint256 public  RewardsFees ;
    uint256 public  Check_BuyBackFee;
    uint256 public MarketingFees;
    uint256 public  TotalFees;

    uint256 public BuyBack_MaxLimit = 1 * 10**15;
    bool public Check_BuyBackEnabled = true;
    bool public SwapAvailable = false;

    address payable _marketingWallet;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public GasFee_ForProcessing = 300000;

    mapping (address => bool) private _CheckAddressExcludedFromFees;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public CheckMarketPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UpdatePancakeSwapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiqudityAddressUpdated(address indexed newLiqudityAddress, address indexed oldLiqudityAddress);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );

    event SendDividends(
    	uint256 tokensSwapped,
    	uint256 amount
    );

    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );

     modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    constructor() public ERC20("GGO", "GGO") {
        uint256 _RewardsFees  = 3;
        uint256 _Check_BuyBackFee = 1;
        uint256 _MarketingFees= 1;

        RewardsFees  = _RewardsFees ;
        Check_BuyBackFee = _Check_BuyBackFee;
        MarketingFees = _MarketingFees;
        TotalFees = _RewardsFees .add(_Check_BuyBackFee).add(_MarketingFees);

        _marketingWallet = 0x3A421EA0032e27B30c2Ac564Ff6B788c97B50723;
    	Check_DividendTracker = new GGODividendTracker();

    	LiqudityAddress = Owner();


    	IPancakeSwapV2Router02 _PancakeSwapV2Router = IPancakeSwapV2Router02( 0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a PancakeSwap pair for this new token
        address _PancakeSwapV2Pair = IPancakeSwapV2Factory(_PancakeSwapV2Router.factory())
            .createPair(address(this), _PancakeSwapV2Router.WETH());

        PancakeSwapV2Router = _PancakeSwapV2Router;
        PancakeSwapV2Pair = _PancakeSwapV2Pair;

        _setAutomatedMarketMakerPair(_PancakeSwapV2Pair, true);

        // exclude from receiving dividends
        Check_DividendTracker.excludeFromDividends(address(Check_DividendTracker));
        Check_DividendTracker.excludeFromDividends(address(this));
        Check_DividendTracker.excludeFromDividends(Owner());
        Check_DividendTracker.excludeFromDividends(address(_PancakeSwapV2Router));

        // exclude from paying fees or having max transaction amount
        excludeFromFees(LiqudityAddress, true);
        excludeFromFees(address(this), true);

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(Owner(), 2000000000 * (10**9));
    }

    receive() external payable {

  	}

    function Decimals() public view override returns (uint8) {
        return 9;
    }

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(Check_DividendTracker), "GGO: The dividend tracker already has that address");

        GGODividendTracker newDividendTracker = GGODividendTracker(payable(newAddress));

        require(newDividendTracker.Owner() == address(this), "GGO: The new dividend tracker must be owned by the GGO token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(Owner());
        newDividendTracker.excludeFromDividends(address(PancakeSwapV2Router));

        emit UpdateDividendTracker(newAddress, address(Check_DividendTracker));

        Check_DividendTracker = newDividendTracker;
    }

    function updatePancakeSwapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(PancakeSwapV2Router), "GGO: The router already has that address");
        emit UpdatePancakeSwapV2Router(newAddress, address(PancakeSwapV2Router));
        PancakeSwapV2Router = IPancakeSwapV2Router02(newAddress);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_CheckAddressExcludedFromFees[account] != excluded, "GGO: Account is already the value of 'excluded'");
        _CheckAddressExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _CheckAddressExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }


    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != PancakeSwapV2Pair, "GGO: The PancakeSwap pair cannot be removed from CheckMarketPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(CheckMarketPairs[pair] != value, "GGO: Automated market maker pair is already set to that value");
        CheckMarketPairs[pair] = value;

        if(value) {
            Check_DividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }


    function updateLiqudityAddress(address newLiqudityAddress) public onlyOwner {
        require(newLiqudityAddress != LiqudityAddress, "GGO: The liquidity wallet is already this address");
        excludeFromFees(newLiqudityAddress, true);
        emit LiqudityAddressUpdated(newLiqudityAddress, LiqudityAddress);
        LiqudityAddress = newLiqudityAddress;
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "GGO: GasFee_ForProcessing must be between 200,000 and 500,000");
        require(newValue != GasFee_ForProcessing, "GGO: Cannot update GasFee_ForProcessing to same value");
        emit GasForProcessingUpdated(newValue, GasFee_ForProcessing);
        GasFee_ForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        Check_DividendTracker.updateClaimWait(claimWait);
    }

    function CheckClaimWait_Duration() external view returns(uint256) {
        return Check_DividendTracker.claimWait();
    }

    function CheckTotalDividendsReleased() external view returns (uint256) {
        return Check_DividendTracker.totalDividendsDistributed();
    }

    function CheckAddressExcludedFromFees(address account) public view returns(bool) {
        return _CheckAddressExcludedFromFees[account];
    }

    function CheckWithdrawableDividendOf(address account) public view returns(uint256) {
    	return Check_DividendTracker.CheckWithdrawableDividendOf(account);
  	}

	function Check_DividendTokenBalanceOf(address account) public view returns (uint256) {
		return Check_DividendTracker.Balance_Of(account);
	}

    function CheckAccountDividendsDetails(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return Check_DividendTracker.getAccount(account);
    }

	function CheckAccountDividendsDetails_AtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	return Check_DividendTracker.getAccountAtIndex(index);
    }

    function withdraw(uint256 weiAmount) external onlyOwner {
         require(address(this).balance >= weiAmount);
        msg.sender.transfer(weiAmount);
    }

	function processDividendTracker(uint256 gas) external {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = Check_DividendTracker.process(gas);
		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function Claim() external {
		Check_DividendTracker.processAccount(msg.sender, false);
    }

    function CheckLastProcessedIndex() external view returns(uint256) {
    	return Check_DividendTracker.CheckLastProcessedIndex();
    }

    function CheckTotalDividendTokenHolders() external view returns(uint256) {
        return Check_DividendTracker.getNumberOfTokenHolders();
    }

    function setMaxSellTxAMount(uint256 amount) external onlyOwner{
        MaxSellTransactionLimit = amount;
    }

    function setSwapTokensAmt(uint256 amt) external onlyOwner{
        SwapTokensAtValue = amt;
    }

    function setRewardsFees (uint256 value) external onlyOwner{
        RewardsFees  = value;
    }

    function setMarketingFees(uint256 value) external onlyOwner{
        MarketingFees = value;
    }

    function setMarketingWallet(address newWallet) external onlyOwner{
        _marketingWallet = payable(newWallet);
    }

   

     function RevokeFromBanList(address account) external onlyOwner {
        CheckBlacklisted[account] = false;
    }

    function activateTrading() external onlyOwner {
        _isPaused = true;
    }

    function deactivateTrading() external onlyOwner {
        _isPaused = false;
    }

    function setSwapAvailable(bool value) external onlyOwner{
        SwapAvailable = value;
    }
     function AddToBanList(address[] calldata addresses) external onlyOwner {
      for (uint256 i; i < addresses.length; ++i) {
        CheckBlacklisted[addresses[i]] = true;
      }
    }
    function setBuyBackFee(uint256 value) external onlyOwner{
        Check_BuyBackFee = value;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(!_isPaused, "ERC20: cannot do the transaction now");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!CheckBlacklisted[from] && !CheckBlacklisted[to], "This address is blacklisted");

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if(
        	!swapping &&
            CheckMarketPairs[to] && // sells only by detecting transfer to automated market maker pair
        	from != address(PancakeSwapV2Router) && //router -> pair is removing liquidity which shouldn't have max
            !_CheckAddressExcludedFromFees[to] //no max for those excluded from fees
        ) {
            require(amount <= MaxSellTransactionLimit, "Sell transfer amount exceeds the MaxSellTransactionLimit.");
        }


        uint256 contractTokenBalance = Balance_Of(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= SwapTokensAtValue;
        if(SwapAvailable && !swapping && to == PancakeSwapV2Pair ) {
            uint256 balance = address(this).balance;
            if (Check_BuyBackEnabled && balance > uint256(1 * 10**15)) {

                if (balance > BuyBack_MaxLimit)
                    balance = BuyBack_MaxLimit;

                buyBackTokens(balance.div(100));
            }



           if (overMinimumTokenBalance) {
                contractTokenBalance = SwapTokensAtValue;

                uint256 swapTokens = contractTokenBalance.mul(MarketingFees).div(TotalFees);
                swapAndSendToMarketing(swapTokens);

                contractTokenBalance = Balance_Of(address(this));

                uint256 buyBackTokens = contractTokenBalance.mul(Check_BuyBackFee).div(TotalFees);
                swapBuyBackTokens(buyBackTokens);

                uint256 sellTokens = Balance_Of(address(this));
                swapAndSendDividends(sellTokens);
           }

        }


        bool takeFee = true;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_CheckAddressExcludedFromFees[from] || _CheckAddressExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
        	uint256 fees = amount.mul(TotalFees).div(100);
        	amount = amount.sub(fees);

            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);

        try Check_DividendTracker.setBalance(payable(from), Balance_Of(from)) {} catch {}
        try Check_DividendTracker.setBalance(payable(to), Balance_Of(to)) {} catch {}

        if(!swapping) {
	    	uint256 gas = GasFee_ForProcessing;

	    	try Check_DividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	}
	    	catch {

	    	}
        }
    }

     function swapAndSendToMarketing(uint256 tokens) private lockTheSwap {

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(tokens);
        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);
         _marketingWallet.transfer(newBalance);
    }

    function swapTokensForEth(uint256 tokenAmount) private {


        // generate the PancakeSwap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = PancakeSwapV2Router.WETH();

        _approve(address(this), address(PancakeSwapV2Router), tokenAmount);

        // make the swap
        PancakeSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }

    function buyBackTokens(uint256 amount) private lockTheSwap{
    	if (amount > 0) {
    	    swapETHForTokens(amount);
	    }
    }

    function swapETHForTokens(uint256 amount) private {
        // generate the PancakeSwap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = PancakeSwapV2Router.WETH();
        path[1] = address(this);

      // make the swap
        PancakeSwapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path,
            DeadWallet_Address, // Burn address
            block.timestamp.add(300)
        );

        emit SwapETHForTokens(amount, path);
    }

    function swapBuyBackTokens(uint256 tokens) private lockTheSwap{
        swapTokensForEth(tokens);
    }

    function setBuyBackEnabled(bool _enabled) public onlyOwner {
        Check_BuyBackEnabled = _enabled;
    }

    function setBuybackUpperLimit(uint256 buyBackLimit) external onlyOwner() {
        BuyBack_MaxLimit = buyBackLimit * 10**15;
    }

    function swapAndSendDividends(uint256 tokens) private lockTheSwap{
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(tokens);
        uint256 dividends = address(this).balance.sub(initialBalance);
        (bool success,) = address(Check_DividendTracker).call{value: dividends}("");

        if(success) {
   	 		emit SendDividends(tokens, dividends);
        }
    }
}

interface DividendPayingTokenInterface {
  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _Owner The address of a token holder.
  /// @return The amount of dividend in wei that `_Owner` can withdraw.
  function dividendOf(address _Owner) external view returns(uint256);

  /// @notice Distributes ether to token holders as dividends.
  /// @dev SHOULD distribute the paid ether to token holders as dividends.
  ///  SHOULD NOT directly transfer ether to token holders in this function.
  ///  MUST emit a `DividendsDistributed` event when the amount of distributed ether is greater than 0.
  function distributeDividends() external payable;

  /// @notice Withdraws the ether distributed to the sender.
  /// @dev SHOULD transfer `dividendOf(msg.sender)` wei to `msg.sender`, and `dividendOf(msg.sender)` SHOULD be 0 after the transfer.
  ///  MUST emit a `DividendWithdrawn` event if the amount of ether transferred is greater than 0.
  function withdrawDividend() external;

  /// @dev This event MUST emit when ether is distributed to token holders.
  /// @param from The address which sends ether to this contract.
  /// @param weiAmount The amount of distributed ether in wei.
  event DividendsDistributed(
    address indexed from,
    uint256 weiAmount
  );

  /// @dev This event MUST emit when an address withdraws their dividend.
  /// @param to The address which withdraws ether from this contract.
  /// @param weiAmount The amount of withdrawn ether in wei.
  event DividendWithdrawn(
    address indexed to,
    uint256 weiAmount
  );
}

interface DividendPayingTokenOptionalInterface {
  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _Owner The address of a token holder.
  /// @return The amount of dividend in wei that `_Owner` can withdraw.
  function CheckWithdrawableDividendOf(address _Owner) external view returns(uint256);

  /// @notice View the amount of dividend in wei that an address has withdrawn.
  /// @param _Owner The address of a token holder.
  /// @return The amount of dividend in wei that `_Owner` has withdrawn.
  function withdrawnDividendOf(address _Owner) external view returns(uint256);

  /// @notice View the amount of dividend in wei that an address has earned in total.
  /// @dev accumulativeDividendOf(_Owner) = CheckWithdrawableDividendOf(_Owner) + withdrawnDividendOf(_Owner)
  /// @param _Owner The address of a token holder.
  /// @return The amount of dividend in wei that `_Owner` has earned in total.
  function accumulativeDividendOf(address _Owner) external view returns(uint256);
}

contract DividendPayingToken is ERC20, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {
  using SafeMath for uint256;
  using SafeMathUint for uint256;
  using SafeMathInt for int256;

  // With `magnitude`, we can properly distribute dividends even if the amount of received ether is small.
  // For more discussion about choosing the value of `magnitude`,
  //  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
  uint256 constant internal magnitude = 2**128;

  uint256 internal magnifiedDividendPerShare;

  // About dividendCorrection:
  // If the token balance of a `_user` is never changed, the dividend of `_user` can be computed with:
  //   `dividendOf(_user) = dividendPerShare * Balance_Of(_user)`.
  // When `Balance_Of(_user)` is changed (via minting/burning/transferring tokens),
  //   `dividendOf(_user)` should not be changed,
  //   but the computed value of `dividendPerShare * Balance_Of(_user)` is changed.
  // To keep the `dividendOf(_user)` unchanged, we add a correction term:
  //   `dividendOf(_user) = dividendPerShare * Balance_Of(_user) + dividendCorrectionOf(_user)`,
  //   where `dividendCorrectionOf(_user)` is updated whenever `Balance_Of(_user)` is changed:
  //   `dividendCorrectionOf(_user) = dividendPerShare * (old Balance_Of(_user)) - (new Balance_Of(_user))`.
  // So now `dividendOf(_user)` returns the same value before and after `Balance_Of(_user)` is changed.
  mapping(address => int256) internal magnifiedDividendCorrections;
  mapping(address => uint256) internal withdrawnDividends;

  uint256 public totalDividendsDistributed;

  constructor(string memory _TokenName, string memory _Symbol) public ERC20(_TokenName, _Symbol) {

  }

  /// @dev Distributes dividends whenever ether is paid to this contract.
  receive() external payable {
    distributeDividends();
  }

  /// @notice Distributes ether to token holders as dividends.
  /// @dev It reverts if the total supply of tokens is 0.
  /// It emits the `DividendsDistributed` event if the amount of received ether is greater than 0.
  /// About undistributed ether:
  ///   In each distribution, there is a small amount of ether not distributed,
  ///     the magnified amount of which is
  ///     `(msg.value * magnitude) % MaxSupply()`.
  ///   With a well-chosen `magnitude`, the amount of undistributed ether
  ///     (de-magnified) in a distribution can be less than 1 wei.
  ///   We can actually keep track of the undistributed ether in a distribution
  ///     and try to distribute it in the next distribution,
  ///     but keeping track of such data on-chain costs much more than
  ///     the saved ether, so we don't do that.
  function distributeDividends() public override payable {
    require(MaxSupply() > 0);

    if (msg.value > 0) {
      magnifiedDividendPerShare = magnifiedDividendPerShare.add(
        (msg.value).mul(magnitude) / MaxSupply()
      );
      emit DividendsDistributed(msg.sender, msg.value);

      totalDividendsDistributed = totalDividendsDistributed.add(msg.value);
    }
  }

  /// @notice Withdraws the ether distributed to the sender.
  /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
  function withdrawDividend() public virtual override {
    _withdrawDividendOfUser(msg.sender);
  }

  /// @notice Withdraws the ether distributed to the sender.
  /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
  function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
    uint256 _withdrawableDividend = CheckWithdrawableDividendOf(user);
    if (_withdrawableDividend > 0) {
      withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
      emit DividendWithdrawn(user, _withdrawableDividend);
      (bool success,) = user.call{value: _withdrawableDividend, gas: 3000}("");

      if(!success) {
        withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
        return 0;
      }

      return _withdrawableDividend;
    }

    return 0;
  }


  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _Owner The address of a token holder.
  /// @return The amount of dividend in wei that `_Owner` can withdraw.
  function dividendOf(address _Owner) public view override returns(uint256) {
    return CheckWithdrawableDividendOf(_Owner);
  }

  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _Owner The address of a token holder.
  /// @return The amount of dividend in wei that `_Owner` can withdraw.
  function CheckWithdrawableDividendOf(address _Owner) public view override returns(uint256) {
    return accumulativeDividendOf(_Owner).sub(withdrawnDividends[_Owner]);
  }

  /// @notice View the amount of dividend in wei that an address has withdrawn.
  /// @param _Owner The address of a token holder.
  /// @return The amount of dividend in wei that `_Owner` has withdrawn.
  function withdrawnDividendOf(address _Owner) public view override returns(uint256) {
    return withdrawnDividends[_Owner];
  }


  /// @notice View the amount of dividend in wei that an address has earned in total.
  /// @dev accumulativeDividendOf(_Owner) = CheckWithdrawableDividendOf(_Owner) + withdrawnDividendOf(_Owner)
  /// = (magnifiedDividendPerShare * Balance_Of(_Owner) + magnifiedDividendCorrections[_Owner]) / magnitude
  /// @param _Owner The address of a token holder.
  /// @return The amount of dividend in wei that `_Owner` has earned in total.
  function accumulativeDividendOf(address _Owner) public view override returns(uint256) {
    return magnifiedDividendPerShare.mul(Balance_Of(_Owner)).toInt256Safe()
      .add(magnifiedDividendCorrections[_Owner]).toUint256Safe() / magnitude;
  }

  /// @dev Internal function that transfer tokens from one address to another.
  /// Update magnifiedDividendCorrections to keep dividends unchanged.
  /// @param from The address to transfer from.
  /// @param to The address to transfer to.
  /// @param value The amount to be transferred.
  function _transfer(address from, address to, uint256 value) internal virtual override {
    require(false);

    int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
    magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
    magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
  }

  /// @dev Internal function that mints tokens to an account.
  /// Update magnifiedDividendCorrections to keep dividends unchanged.
  /// @param account The account that will receive the created tokens.
  /// @param value The amount that will be created.
  function _mint(address account, uint256 value) internal override {
    super._mint(account, value);

    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
      .sub( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
  }

  /// @dev Internal function that burns an amount of the token of a given account.
  /// Update magnifiedDividendCorrections to keep dividends unchanged.
  /// @param account The account whose tokens will be burnt.
  /// @param value The amount that will be burnt.
  function _burn(address account, uint256 value) internal override {
    super._burn(account, value);

    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
      .add( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
  }

  function _setBalance(address account, uint256 newBalance) internal {
    uint256 currentBalance = Balance_Of(account);

    if(newBalance > currentBalance) {
      uint256 mintAmount = newBalance.sub(currentBalance);
      _mint(account, mintAmount);
    } else if(newBalance < currentBalance) {
      uint256 burnAmount = currentBalance.sub(newBalance);
      _burn(account, burnAmount);
    }
  }
}

contract GGODividendTracker is DividendPayingToken, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() public DividendPayingToken("GGO_Dividend_Tracker", "GGO_Dividend_Tracker") {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 1000 * (10**15); //must hold 1000+ tokens
    }

    function _transfer(address, address, uint256) internal override {
        require(false, "GGO_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public override {
        require(false, "GGO_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main GGO contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "GGO_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "GGO_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function CheckLastProcessedIndex() external view returns(uint256) {
    	return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }



    function getAccount(address _account)
        public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable) {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ?
                                                        tokenHoldersMap.keys.length.sub(lastProcessedIndex) :
                                                        0;


                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }


        withdrawableDividends = CheckWithdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(claimWait) :
                                    0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
    }

    function getAccountAtIndex(uint256 index)
        public view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
    	if(lastClaimTime > block.timestamp)  {
    		return false;
    	}

    	return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
    	if(excludedFromDividends[account]) {
    		return;
    	}

    	if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
    		tokenHoldersMap.set(account, newBalance);
    	}
    	else {
            _setBalance(account, 0);
    		tokenHoldersMap.remove(account);
    	}

    	processAccount(account, true);
    }

    function process(uint256 gas) public returns (uint256, uint256, uint256) {
    	uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

    	if(numberOfTokenHolders == 0) {
    		return (0, 0, lastProcessedIndex);
    	}

    	uint256 _lastProcessedIndex = lastProcessedIndex;

    	uint256 gasUsed = 0;

    	uint256 gasLeft = gasleft();

    	uint256 iterations = 0;
    	uint256 claims = 0;

    	while(gasUsed < gas && iterations < numberOfTokenHolders) {
    		_lastProcessedIndex++;

    		if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
    			_lastProcessedIndex = 0;
    		}

    		address account = tokenHoldersMap.keys[_lastProcessedIndex];

    		if(canAutoClaim(lastClaimTimes[account])) {
    			if(processAccount(payable(account), true)) {
    				claims++;
    			}
    		}

    		iterations++;

    		uint256 newGasLeft = gasleft();

    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
    		}

    		gasLeft = newGasLeft;
    	}

    	lastProcessedIndex = _lastProcessedIndex;

    	return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

    	if(amount > 0) {
    		lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
    		return true;
    	}

    	return false;
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */



/// @title Dividend-Paying Token Optional Interface
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev OPTIONAL functions for a dividend-paying token contract.


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
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the Allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {IncreaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * Allowances. See {IERC20-approve}.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */


library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) public view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }



    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

interface IPancakeSwapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IPancakeSwapV2Pair {
    event Approval(address indexed Owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function TokenName() external pure returns (string memory);
    function Symbol() external pure returns (string memory);
    function Decimals() external pure returns (uint8);
    function MaxSupply() external view returns (uint);
    function Balance_Of(address Owner) external view returns (uint);
    function Allowance(address Owner, address spender) external view returns (uint);

    function Approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address Owner) external view returns (uint);

    function permit(address Owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}



library SafeMath {
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

/**
 * @title SafeMathUint
 * @dev Math operations with safety checks that revert on error
 */
library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}