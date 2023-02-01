/**
 *Submitted for verification at BscScan.com on 2023-01-30
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 ________      ___    ___ ________   ________  _____ ______   ___  ________     
|\   ___ \    |\  \  /  /|\   ___  \|\   __  \|\   _ \  _   \|\  \|\   ____\    
\ \  \_|\ \   \ \  \/  / | \  \\ \  \ \  \|\  \ \  \\\__\ \  \ \  \ \  \___|    
 \ \  \ \\ \   \ \    / / \ \  \\ \  \ \   __  \ \  \\|__| \  \ \  \ \  \       
  \ \  \_\\ \   \/  /  /   \ \  \\ \  \ \  \ \  \ \  \    \ \  \ \  \ \  \____  
   \ \_______\__/  / /      \ \__\\ \__\ \__\ \__\ \__\    \ \__\ \__\ \_______\
    \|_______|\___/ /        \|__| \|__|\|__|\|__|\|__|     \|__|\|__|\|_______|
             \|___|/                                                            
 */

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

contract Dynamic is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee; // wallets excluded from fee
    mapping(address => uint256) private _tokenSold;

    mapping(address => uint256) private _startTime;
    mapping(address => uint256) private _blockTime;

    uint256 public _maxSoldAmount;
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    uint256 public _taxFee;
    uint256 public _minBalance;

    uint256 public defaultTaxFee;
    uint256 public defaultLiquidity;
    uint256 public defaultTreasury;
    uint256 public defaultMarketing;

    address public uniswapV2Pair;
    address payable public _treasuryWallet;
    address payable public _marketingWallet;

    bool public inSwap = false;
    bool public swapEnabled = true;

    IUniswapV2Router02 public uniswapV2Router; // pancakeswap v2 router

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    /**
     * @dev Initialize params for tokenomics
     */

    constructor() {
        _name = unicode"Dynamic";
        _symbol = "DYNA";
        _decimals = 18;
        _totalSupply = 10**9 * 10**18;
        _balances[msg.sender] = _totalSupply;

        defaultTaxFee = 600; // 6%
        defaultLiquidity = 200;
        defaultTreasury = 200;
        defaultMarketing = 200;

        _taxFee = defaultTaxFee;
        _minBalance = 10**6 * 10**18; // 0.1% total supply
        _maxSoldAmount = 5 * 10**6 * 10**18;

        _treasuryWallet = payable(0xA8Ff6C807654c5B2B55f188e9a7Ce31C8d192353);
        _marketingWallet = payable(0xcCdc33e238E091fF10824D80829aEb41dd1f8712);

        // BSC MainNet router
        //0x10ED43C718714eb63d5aA57B78B54704E256024E
        // BSC TestNet router
        // 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_treasuryWallet] = true;
        _isExcludedFromFee[_marketingWallet] = true;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
     * @dev Returns the bep token owner.
     */

    function getOwner() external view override returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
     */

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */

    function name() external view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */

    //function balanceOf(address account) external override view returns (uint256) {
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setDefaultTaxFee(
        uint256 _defaultTaxFee,
        uint256 _defaultLiquidity,
        uint256 _defaultTreasury,
        uint256 _defaultMarketing
    ) public onlyOwner {
        require(
            _defaultTaxFee ==
                _defaultLiquidity.add(_defaultTreasury).add(_defaultMarketing),
            "_defaultTaxFee must equal to sum of _defaultLiquidity, _defaultTreasury and _defaultMarketing"
        );
        require(
            _defaultTaxFee <= 2000,
            "_defaultTaxFee must less than or equal to 20%"
        );
        defaultTaxFee = _defaultTaxFee;
        defaultLiquidity = _defaultLiquidity;
        defaultTreasury = _defaultTreasury;
        defaultMarketing = _defaultMarketing;
        _taxFee = defaultTaxFee;
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}
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
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        bool takeFee = true;

        if (!inSwap && swapEnabled && to == uniswapV2Pair) {
            // limit max sold
            if (_tokenSold[from] == 0) {
                _startTime[from] = block.timestamp;
            }

            _tokenSold[from] = _tokenSold[from] + amount;

            if (block.timestamp < _startTime[from] + (1 days)) {
                require(
                    _tokenSold[from] <= _maxSoldAmount,
                    "Sold amount exceeds the maxTxAmount."
                );
            } else {
                _startTime[from] = block.timestamp;
                _tokenSold[from] = 0;
            }

            // transfer tokens
            uint256 dynaBalance = balanceOf(address(this));
            if (dynaBalance > _minBalance) {
                transferTokens(dynaBalance);
            }

            if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
                takeFee = false;
            }
        } else {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
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
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev transfer tokens to liqudity, treasury wallet and marketing wallet
     */

    function transferTokens(uint256 tokenBalance) private lockTheSwap {
        uint256 liquidityTokens = tokenBalance.mul(defaultLiquidity).div(
            defaultTaxFee.mul(2)
        );
        uint256 otherBNBTokens = tokenBalance.sub(liquidityTokens);
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(otherBNBTokens);

        uint256 newBalance = address(this).balance.sub(initialBalance);
        uint256 liquidityCapacity = newBalance.mul(defaultLiquidity).div(
            defaultLiquidity.add(defaultTreasury.mul(2)).add(defaultMarketing.mul(2))
        ); // liquidity = 1/3 total
        addLiqudity(liquidityTokens, liquidityCapacity);

        uint256 treasuryCapacity = newBalance.sub(liquidityCapacity);
        uint256 treasuryBNB = treasuryCapacity.mul(defaultTreasury).div(
            defaultTreasury.add(defaultMarketing)
        ); // 2% for the treasury wallet, 2% for the marketing wallet
        _treasuryWallet.transfer(treasuryBNB);

        uint256 marketingBNB = treasuryCapacity.sub(treasuryBNB);
        _marketingWallet.transfer(marketingBNB);
    }

    /**
     * @dev Swap tokens from dyna to bnb
     */

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    /**
     * @dev Add dyna token and bnb as same ratio on pancakeswap router
     */

    function addLiqudity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add amount to contract
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    /**
     * @dev the Owner can swap regarding the dyna token's amount of contract balance
     * this is for manual function
     */

    function contractBalanceSwap() external onlyOwner {
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    /**
     * @dev the Owner can send regarding the dyna token's amount of contract balance
     * this is for manual function
     * 0.1BNB will remain in contract balance for swap and transfer fees.
     */

    function contractBalanceSend(uint256 amount, address payable _destAddr)
        external
        onlyOwner
    {
        uint256 contractETHBalance = address(this).balance - 1 * 10**17;
        if (contractETHBalance > amount) {
            _destAddr.transfer(amount);
        }
    }

    /**
     * @dev remove all fees
     */

    function removeAllFee() private {
        if (_taxFee == 0) return;
        _taxFee = 0;
    }

    /**
     * @dev set all fees
     */

    function restoreAllFee() private {
        _taxFee = defaultTaxFee;
    }

    /**
     * @dev transfer tokens with amount
     */

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool isTakeFee
    ) private {
        if (!isTakeFee) removeAllFee();
        _transferStandard(sender, recipient, amount);
        if (!isTakeFee) restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256 fee = amount.mul(_taxFee).div(10000); // for 3% fee
        //_beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "BEP20: transfer amount exceeds balance"
        );
        _balances[sender] = senderBalance - amount;
        uint256 amountnew = amount - fee;
        _balances[recipient] += (amountnew);

        if (fee > 0) {
            _balances[address(this)] += (fee);
            emit Transfer(sender, address(this), fee);
        }

        emit Transfer(sender, recipient, amountnew);
    }

    /**
     * @dev set Max sold amount
     */

    function _setMaxSoldAmount(uint256 maxvalue) external onlyOwner {
        require(maxvalue >= 10**6 * 10**18, "_maxSoldAmount must be greater than or equal to 0.1% total supply");
        _maxSoldAmount = maxvalue;
    }

    /**
     * @dev set min balance for transferring
     */

    function _setMinBalance(uint256 minValue) external onlyOwner {
        _minBalance = minValue;
    }

    /**
     * @dev determine whether we apply tax fee or not
     */

    function _setApplyContractFee(bool isFee) external onlyOwner {
        if (isFee) {
            _taxFee = defaultTaxFee;
        } else {
            _taxFee = 0;
        }
    }

    function _setTreasuryWalletAddress(address treasuryWalletAddr) external onlyOwner {
        _treasuryWallet = payable(treasuryWalletAddr);
    }

    function _setMarketingWalletAddress(address marketingWalletAddr)
        external
        onlyOwner
    {
        _marketingWallet = payable(marketingWalletAddr);
    }

    receive() external payable {}
}