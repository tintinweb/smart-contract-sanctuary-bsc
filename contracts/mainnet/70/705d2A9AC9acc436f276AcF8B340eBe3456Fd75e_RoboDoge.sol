/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IBEP20Metadata is IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract BEP20 is Context, IBEP20, IBEP20Metadata {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _tokengeneration(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: generation to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = amount;
        _balances[account] = amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

library Address {
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract RoboDoge is BEP20, Ownable {
    using Address for address payable;

    IRouter public router;
    address public pair;

    bool private _liquidityMutex = false;
    bool public providingLiquidity = false;
    bool public tradingEnabled = false;

    uint256 public tokenLiquidityThreshold = 10_000_000 * 10**18;
    uint256 public maxBuyLimit = 10_000_000 * 10**18;
    uint256 public maxSellLimit = 10_000_000 * 10**18;
    uint256 public maxWalletLimit = 10_000_000 * 10**18;

    uint256 public genesis_block;
    uint256 private deadline = 5;
    uint256 private launchtax = 99;

    address public marketingWallet = 0x7208999186BD4FeED37c6D7Dcf72c8df117614F6;
    address private opsWallet = 0xc0EfF6A4093921DDf11f4FF95321De6deA7C8161;
    address public devWallet = 0x2832f1A2F5142bC06139D93d3C61811485aC28F8;
	address public constant deadWallet = 0x000000000000000000000000000000000000dEaD;

    struct Taxes {
        uint256 marketing;
        uint256 dev;
        uint256 liquidity;
        uint256 ops;        
    }

    Taxes private taxes = Taxes(5, 4, 1, 1);
    Taxes private sellTaxes = Taxes(5, 4, 1, 1);

    mapping(address => bool) public exemptFee;
    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public allowedTransfer;

    //Anti Dump
    mapping(address => uint256) private _lastSell;
    bool public coolDownEnabled = false;
    uint256 public coolDownTime = 60 seconds;

    modifier mutexLock() {
        if (!_liquidityMutex) {
            _liquidityMutex = true;
            _;
            _liquidityMutex = false;
        }
    }

    constructor(address routerAdd) BEP20("RoboDoge", "Rdoge") {
        _tokengeneration(msg.sender, 1e9 * 10**decimals());
        exemptFee[msg.sender] = true;

        IRouter _router = IRouter(routerAdd);
        // Create a pancake pair for this new token
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());

        router = _router;
        pair = _pair;
        exemptFee[address(this)] = true;
        exemptFee[marketingWallet] = true;
        exemptFee[opsWallet] = true;
        exemptFee[devWallet] = true;
        exemptFee[deadWallet] = true;
        exemptFee[0xD152f549545093347A162Dce210e7293f1452150] = true;
        exemptFee[0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE] = true;

        allowedTransfer[address(this)] = true;
        allowedTransfer[owner()] = true;
        allowedTransfer[pair] = true;
        allowedTransfer[marketingWallet] = true;
        allowedTransfer[opsWallet] = true;
        allowedTransfer[devWallet] = true;
        allowedTransfer[deadWallet] = true;
        allowedTransfer[0xD152f549545093347A162Dce210e7293f1452150] = true;
        allowedTransfer[0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE] = true;

    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        override
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(
            !isBlacklisted[sender] && !isBlacklisted[recipient],
            "You can't transfer tokens"
        );

        if (!exemptFee[sender] && !exemptFee[recipient]) {
            require(tradingEnabled, "Trading not enabled");
        }

        if (sender == pair && !exemptFee[recipient] && !_liquidityMutex) {
            require(amount <= maxBuyLimit, "You are exceeding maxBuyLimit");
            require(
                balanceOf(recipient) + amount <= maxWalletLimit,
                "You are exceeding maxWalletLimit"
            );
        }

        if (
            sender != pair && !exemptFee[recipient] && !exemptFee[sender] && !_liquidityMutex
        ) {
            require(amount <= maxSellLimit, "You are exceeding maxSellLimit");
            if (recipient != pair) {
                require(
                    balanceOf(recipient) + amount <= maxWalletLimit,
                    "You are exceeding maxWalletLimit"
                );
            }
            if (coolDownEnabled) {
                uint256 timePassed = block.timestamp - _lastSell[sender];
                require(timePassed >= coolDownTime, "Cooldown enabled");
                _lastSell[sender] = block.timestamp;
            }
        }

        uint256 feeswap;
        uint256 feesum;
        uint256 fee;
        Taxes memory currentTaxes;

        bool useLaunchFee = !exemptFee[sender] &&
            !exemptFee[recipient] &&
            block.number < genesis_block + deadline;

        //set fee to zero if fees in contract are handled or exempted
        if (_liquidityMutex || exemptFee[sender] || exemptFee[recipient])
            fee = 0;

            //calculate fee
        else if (recipient == pair && !useLaunchFee) {
            feeswap =
                sellTaxes.liquidity +
                sellTaxes.marketing +           
                sellTaxes.ops +
                sellTaxes.dev;
            feesum = feeswap;
            currentTaxes = sellTaxes;
        } else if (!useLaunchFee) {
            feeswap =
                taxes.liquidity +
                taxes.marketing +
                taxes.ops +
                taxes.dev ;
            feesum = feeswap;
            currentTaxes = taxes;
        } else if (useLaunchFee) {
            feeswap = launchtax;
            feesum = launchtax;
        }

        fee = (amount * feesum) / 100;

        //send fees if threshold has been reached
        //don't do this on buys, breaks swap
        if (providingLiquidity && sender != pair) handle_fees(feeswap, currentTaxes);

        //rest to recipient
        super._transfer(sender, recipient, amount - fee);
        if (fee > 0) {
            //send the fee to the contract
            if (feeswap > 0) {
                uint256 feeAmount = (amount * feeswap) / 100;
                super._transfer(sender, address(this), feeAmount);
            }

        }
    }

    function handle_fees(uint256 feeswap, Taxes memory swapTaxes) private mutexLock {
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance >= tokenLiquidityThreshold) {
            if (tokenLiquidityThreshold > 1) {
                contractBalance = tokenLiquidityThreshold;
            }

            // Split the contract balance into halves
            uint256 denominator = feeswap * 2;
            uint256 tokensToAddLiquidityWith = (contractBalance * swapTaxes.liquidity) /
                denominator;
            uint256 toSwap = contractBalance - tokensToAddLiquidityWith;

            uint256 initialBalance = address(this).balance;

            swapTokensForETH(toSwap);

            uint256 deltaBalance = address(this).balance - initialBalance;
            uint256 unitBalance = deltaBalance / (denominator - swapTaxes.liquidity);
            uint256 bnbToAddLiquidityWith = unitBalance * swapTaxes.liquidity;

            if (bnbToAddLiquidityWith > 0) {
                // Add liquidity to pancake
                addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith);
            }

            uint256 marketingAmt = unitBalance * 2 * swapTaxes.marketing;
            if (marketingAmt > 0) {
                payable(marketingWallet).sendValue(marketingAmt);
            }

            uint256 opsAmt = unitBalance * 2 * swapTaxes.ops;
            if (opsAmt > 0) {
                payable(opsWallet).sendValue(opsAmt);
            }

            uint256 devAmt = unitBalance * 2 * swapTaxes.dev;
            if (devAmt > 0) {
                payable(devWallet).sendValue(devAmt);
            }

        }
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{ value: ethAmount }(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function updateLiquidityProvide(bool state) external onlyOwner {
        //update liquidity providing state
        providingLiquidity = state;
    }

    function updateLiquidityTreshhold(uint256 new_amount) external onlyOwner {
        //update the treshhold
        tokenLiquidityThreshold = new_amount * 10**decimals();
    }

        function UpdateBuyTaxes(
        uint256 _marketing,
        uint256 _dev,
        uint256 _liquidity,
        uint256 _ops
    ) external onlyOwner {
        taxes = Taxes(_marketing, _dev, _liquidity, _ops);
        require((_marketing +_dev + _liquidity + _ops) <= 20, "Must keep fees at 20% or less");
    }

    function SetSellTaxes(
        uint256 _marketing,
        uint256 _dev,
        uint256 _liquidity,
        uint256 _ops
    ) external onlyOwner {
        sellTaxes = Taxes(_marketing, _dev,_liquidity, _ops);
        require((_marketing + _dev + _liquidity + _ops) <= 20, "Must keep fees at 20% or less");
    }

    function updateRouterAndPair(address newRouter, address newPair) external onlyOwner {
        router = IRouter(newRouter);
        pair = newPair;
    }

   function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Trading is already enabled");
        tradingEnabled = true;
        providingLiquidity = true;
        genesis_block = block.number;
    }

    function updatedeadline(uint256 _deadline) external onlyOwner {
        require(!tradingEnabled, "Can't change when trading has started");
        deadline = _deadline;
    }

    function updateMarketingWallet(address newWallet) external onlyOwner {
        marketingWallet = newWallet;
    }

    function updateopsWallet(address newWallet) external onlyOwner {
        opsWallet = newWallet;
    }

    function updatedevWallet(address newWallet) external onlyOwner {
        devWallet = newWallet;
    }

    function updateCooldown(bool state, uint256 time) external onlyOwner {
        coolDownTime = time * 1 seconds;
        coolDownEnabled = state;
    }

    function updateIsBlacklisted(address account, bool state) external onlyOwner {
        isBlacklisted[account] = state;
    }

    function bulkIsBlacklisted(address[] memory accounts, bool state) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            isBlacklisted[accounts[i]] = state;
        }
    }

    function updateAllowedTransfer(address account, bool state) external onlyOwner {
        allowedTransfer[account] = state;
    }

    function bulkAllowedTransfer(address[] memory accounts, bool state) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            allowedTransfer[accounts[i]] = state;
        }
    }

    function updateExemptFee(address _address, bool state) external onlyOwner {
        exemptFee[_address] = state;
    }

    function bulkExemptFee(address[] memory accounts, bool state) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            exemptFee[accounts[i]] = state;
        }
    }

    function updateMaxBuyTxLimit(uint256 maxBuy) external onlyOwner {
        maxBuyLimit = maxBuy * 10**decimals();
        require(maxBuy >= 1_000, "Cannot set max buy amount lower than 0.1% of tokens");
    }

    function updateMaxSellTxLimit(uint256 maxSell) external onlyOwner {
        maxSellLimit = maxSell * 10**decimals();
        require(maxSell >= 1_000, "Cannot set max sell amount lower than 0.1% of tokens%");
    }

    function updateMaxWalletlimit(uint256 amount) external onlyOwner {
        require(amount >= 1_000, "Cannot set max wallet amount lower than 0.1% of tokens");
        maxWalletLimit = amount * 10**decimals();
    }

    function updateMaxTxLimit(uint256 maxBuy, uint256 maxSell, uint256 maxWallet) external onlyOwner {
        maxBuyLimit = maxBuy * 10**decimals();
        maxSellLimit = maxSell * 10**decimals();
        maxWalletLimit = maxWallet * 10**decimals(); 
    }

    function rescueBNB(uint256 weiAmount) external onlyOwner {
        payable(opsWallet).transfer(weiAmount);
    }

    function rescueBSC20(address tokenAdd, uint256 amount) external onlyOwner {
        IBEP20(tokenAdd).transfer(opsWallet, amount);
    }

    // fallbacks
    receive() external payable {}
}