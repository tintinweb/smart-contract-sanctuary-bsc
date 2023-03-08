/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

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

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
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

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function burn(uint256 amount) public virtual returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    //Called only once during token creation to create the token supply
    function _createSupply(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: token to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface IUniswapV2Factory {

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
        
}

interface IUniswapV2Router01 {
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
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (
            uint amountToken,
            uint amountETH,
            uint liquidity
        );
        
}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract SHOOTER is ERC20, Ownable {
    uint256 public liquidityFeeOnBuy = 1;
    uint256 public liquidityFeeOnSell = 3;

    uint256 public marketingFeeOnBuy = 1;
    uint256 public marketingFeeOnSell = 3;

    uint256 private _totalFeesOnBuy = 2;
    uint256 private _totalFeesOnSell = 6;

    address public marketingWallet = 0x6ED750FD60F0449bB318B7c1796EB8D4649b6D71;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    address private DEAD = 0x000000000000000000000000000000000000dEaD;

    address private USDTAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    bool private swapping;
    uint256 public swapTokensAtAmount;

    address public operator;

    bool public liquifyDisable = false;

    bool public taxDisable = false;

    mapping (address => bool) private _isBlacklisted;
    bool public blacklistDisable = false;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event BuyFeesUpdate(uint256 liquidityFeeOnBuy, uint256 marketingFeeOnBuy);
    event SellFeesUpdate(
        uint256 liquidityFeeOnSell,
        uint256 marketingFeeOnSell
    );
    event MarketingWalletChanged(address marketingWallet);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbReceived,
        uint256 tokensIntoLiqudity
    );
    event SwapAndSendMarketing(uint256 tokensSwapped, uint256 bnbSend);
    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    constructor() ERC20("SHOOTER", "SHOOTER") {

        transferOwnership(msg.sender);
        operator = msg.sender;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), USDTAddress);

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        IERC20 _USDTToken = IERC20(
            USDTAddress
        );
        _USDTToken.approve(address(uniswapV2Router), type(uint256).max);

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[address(this)] = true;

        _createSupply(owner(), 10_000_000_000 * (10**18));
        swapTokensAtAmount = totalSupply() / 10000;
    }

    receive() external payable {}

    modifier onlyOperator() {
        require(operator == _msgSender(), "Caller is not the Operator");
        _;
    }

    modifier onlyAuth() {
        require(
            operator == _msgSender() || _msgSender() == owner(),
            "Caller is not the Operator or Owner"
        );
        _;
    }

    function claimStuckTokens(address token) external onlyOwner {
        if(!liquifyDisable){
            require(token != address(this), "Owner cannot claim native tokens");
        }
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendBNB(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function updateUniswapV2Router(address newAddress) external onlyOperator {
        require(
            newAddress != address(uniswapV2Router),
            "The router already has that address"
        );
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), USDTAddress);
        uniswapV2Pair = _uniswapV2Pair;
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
        external
        onlyOperator
    {
        require(
            pair != uniswapV2Pair,
            "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    //=======FeeManagement=======//
    function excludeFromFees(address account)
        external
        onlyOwner
    {
        require(!_isExcludedFromFees[account], "Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = true;

        emit ExcludeFromFees(account,true);
    }

    function includeInFees(address account)
        external
        onlyOwner
    {
        require(_isExcludedFromFees[account], "Account is already the value of 'included'");
        _isExcludedFromFees[account] = false;

        emit ExcludeFromFees(account,false);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function updateBuyFees(
        uint256 _liquidityFeeOnBuy,
        uint256 _marketingFeeOnBuy
    ) external onlyOwner {
        require(
            _liquidityFeeOnBuy + _marketingFeeOnBuy <= 25,
            "Fees must be less than 25%"
        );
        liquidityFeeOnBuy = _liquidityFeeOnBuy;
        marketingFeeOnBuy = _marketingFeeOnBuy;
        _totalFeesOnBuy = liquidityFeeOnBuy + marketingFeeOnBuy;
        emit BuyFeesUpdate(_liquidityFeeOnBuy, _marketingFeeOnBuy);
    }

    function updateSellFees(
        uint256 _liquidityFeeOnSell,
        uint256 _marketingFeeOnSell
    ) external onlyOwner {
        require(
            _liquidityFeeOnSell + _marketingFeeOnSell <= 25,
            "Fees must be less than 25%"
        );
        liquidityFeeOnSell = _liquidityFeeOnSell;
        marketingFeeOnSell = _marketingFeeOnSell;
        _totalFeesOnSell = liquidityFeeOnSell + marketingFeeOnSell;
        emit SellFeesUpdate(_liquidityFeeOnSell, _marketingFeeOnSell);
    }
    
    function blacklistAccount(address[] memory blacklist) external onlyOwner() {
        for (uint256 i = 0; i < blacklist.length; i++) {
            if (!_isBlacklisted[blacklist[i]]) {
                _isBlacklisted[blacklist[i]] = true;
            } else {
                continue;
            }
        }
    }
    
    function removeBlacklist(address[] memory blacklist) external onlyOwner() {
        for (uint256 i = 0; i < blacklist.length; i++) {
            if (_isBlacklisted[blacklist[i]]) {
                _isBlacklisted[blacklist[i]] = false;
            } else {
                continue;
            }
        }
    }

    function isBlacklisted(address account) external view returns (bool) {
        return _isBlacklisted[account];
    }

    function setBlacklistDisable() external onlyOwner {
        require(!blacklistDisable, "Blacklist fuction already disabled");
        blacklistDisable = true;
    }

    function setLiquifyDisable(bool liquifyDisableval) external onlyOwner {
       liquifyDisable = liquifyDisableval;
    }

    function setTaxDisable(bool taxDisableval) external onlyOwner {
       taxDisable = taxDisableval;
    }

    function getBlacklistDisable() external view returns (bool) {
        return blacklistDisable;
    }

    function getLiquifyDisable() external view returns (bool) {
        return liquifyDisable;
    }

    function getTaxDisable() external view returns (bool) {
        return taxDisable;
    }

    function changeMarketingWallet(address _marketingWallet)
        external
        onlyOwner
    {
        require(
            _marketingWallet != marketingWallet,
            "Marketing wallet is already that address"
        );
        require(
            !isContract(_marketingWallet),
            "Marketing wallet cannot be a contract"
        );
        marketingWallet = _marketingWallet;
        emit MarketingWalletChanged(marketingWallet);
    }

    function changeOperatorWallet(address _operatorWallet)
        external
        onlyOperator
    {
        operator = _operatorWallet;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (!blacklistDisable) {
            require(!_isBlacklisted[from], "ERC20: sender address blacklisted");
            require(!_isBlacklisted[to], "ERC20: transfer to blacklisted address");
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (canSwap && !swapping && !automatedMarketMakerPairs[from]) {
            swapping = true;

            uint256 totalFee = _totalFeesOnBuy + _totalFeesOnSell;
            uint256 liquidityShare = liquidityFeeOnBuy + liquidityFeeOnSell;
            uint256 marketingShare = marketingFeeOnBuy + marketingFeeOnSell;

            if (contractTokenBalance > 0 && totalFee > 0) {
                if(!liquifyDisable){
                    if (liquidityShare > 0) {
                        uint256 liquidityTokens = (contractTokenBalance *
                            liquidityShare) / totalFee;
                        swapAndLiquify(liquidityTokens);
                    }
                    
                    if (marketingShare > 0) {
                        uint256 marketingTokens = (contractTokenBalance *
                            marketingShare) / totalFee;
                        swapAndSendMarketing(marketingTokens);
                    }
                }
            }

            swapping = false;
        }

        bool takeFee = !swapping;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (
            from != uniswapV2Pair &&
            to != uniswapV2Pair
        ) {
            takeFee = false;
        }

        if(taxDisable){
            takeFee = false;
        }

        if (takeFee) {
            uint256 _totalFees;
            if (from == uniswapV2Pair) {
                _totalFees = _totalFeesOnBuy;
            } else {
                _totalFees = _totalFeesOnSell;
            }
            if(_totalFees > 0){
            uint256 fees = (amount * _totalFees) / 100;

            amount = amount - fees;

            super._transfer(from, address(this), fees);
            }
        }

        super._transfer(from, to, amount);
    }

    //=======Swap=======//
    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        IERC20 _USDTToken = IERC20(
            USDTAddress
        );

        uint256 initialBalance = _USDTToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDTAddress;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            half,
            0, // accept any amount of Token
            path,
            address(this),
            block.timestamp
        );

        uint256 newBalance = _USDTToken.balanceOf(address(this)) - initialBalance;
        
        uniswapV2Router.addLiquidity(
            address(this),
            USDTAddress,
            otherHalf,
            newBalance,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            DEAD,
            block.timestamp
        );

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapAndSendMarketing(uint256 tokenAmount) private {
        IERC20 _USDTToken = IERC20(
            USDTAddress
        );

        uint256 initialBalance = _USDTToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDTAddress;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of Token
            path,
            address(this),
            block.timestamp
        );

        uint256 newBalance = _USDTToken.balanceOf(address(this)) - initialBalance;

        _USDTToken.transfer(marketingWallet, newBalance);

        emit SwapAndSendMarketing(tokenAmount, newBalance);
    }

    function setSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
        require(
            newAmount > totalSupply() / 200000,
            "SwapTokensAtAmount must be greater than 0.001% of total supply"
        );
        swapTokensAtAmount = newAmount;
    }
}