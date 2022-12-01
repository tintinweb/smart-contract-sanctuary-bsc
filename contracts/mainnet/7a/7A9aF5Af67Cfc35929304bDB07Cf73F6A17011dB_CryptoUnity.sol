// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

import "./Ownable.sol";
import "./IERC20.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router02.sol";

contract CryptoUnity is IERC20, Ownable {
    // Multisig Protocol Wallets
    address public marketingAddress; 
    address public researchAddress; 

    address public liquidityWallet = address(this); 
    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1000000000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private constant _name = "CryptoUnity";
    string private constant _symbol = "CUT";
    uint8 private constant _decimals = 9;
    
    // Used in variable fee calculations
    uint256 private _tempHolderRewardFee = 0;
    uint256 private _tempLiquidityFee = 0;
    uint256 private _tempMarketingFee = 0;
    uint256 private _tempResearchFee = 0;

    uint256 private _marketingToken;
    uint256 private _researchToken;

    uint256 public _buyHolderRewardFee = 2;
    uint256 public _buyMarketingFee = 1;
    uint256 public _buyResearchFee = 1;
    uint256 private _buyLiquidityFee = 6;

    uint256 public _holderRewardFee = 2;
    uint256 private _liquidityFee = 11;

    uint256 public _sellHolderRewardFee = 2;
    uint256 public _sellMarketingFee = 3;
    uint256 public _sellResearchFee = 3;
    uint256 private _sellLiquidityFee = 9;

    bool public transferFee = false;
    bool public tradingOpen = true;

    address public tradingSetter;


    // Protocol Fees
    uint256 public _bMaxTxAmount = 1000000000  * 10**9;
    uint256 public _sMaxTxAmount = 1000000000  * 10**9;
    uint256 private minimumTokensBeforeSwap = 100000  * 10**9; 
    uint256 public minTokenLiqSwap = 0; 


    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquifyTokens(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapTokensForBNB(
        uint256 amountIn,
        address[] path
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor (address _marketingAddress, address _researchAddress) {
        require(_marketingAddress != address(0), "Zero Address Error");
        marketingAddress = _marketingAddress;
        require(_researchAddress != address(0), "Zero Address Error");
        researchAddress = _researchAddress;

        _rOwned[_msgSender()] = _rTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        tradingSetter = owner();

        // Protocol Multisig Wallets
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[liquidityWallet] = true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[researchAddress] = true;
        _isExcludedFromFee[deadAddress] = true;

        excludeFromReward(uniswapV2Pair);
        excludeFromReward(deadAddress);
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    /* PUBLIC FUNCTION STARTS */

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), (_allowances[sender][_msgSender()] - amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, (_allowances[_msgSender()][spender] + addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, (_allowances[_msgSender()][spender] - subtractedValue));
        return true;
    }

    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }
    
    function minimumTokensBeforeSwapAmount() external view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }

    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account];
    }
    

    /* PUBLIC FUNCTION ENDS */

    /* PRIVATE FUNCTION STARTS */

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(!tradingOpen){
            require( _isExcludedFromFee[to] || _isExcludedFromFee[from], "Trading Not Yet Started.");
        }
        
        if(from != owner() && to != owner() && ! _isExcludedFromFee[to] && ! _isExcludedFromFee[from]) {
            
            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to]) {
                require(amount <= _bMaxTxAmount, "Transfer amount exceeds max buy amount.");
                
            }
            if (to == uniswapV2Pair && ! _isExcludedFromFee[from]){
                require(amount <= _sMaxTxAmount, "Transfer amount exceeds the max sell amount.");
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;    

        // Sell tokens for BNB
        if (!inSwapAndLiquify && swapAndLiquifyEnabled && balanceOf(uniswapV2Pair) > 0) {
            if (to == uniswapV2Pair) {
                if (overMinimumTokenBalance) {
                    uint256 liquidityToken = contractTokenBalance - _marketingToken - _researchToken;

                    require(IERC20(address(this)).transfer(marketingAddress,_marketingToken), "ERC20: Transfer to marketing address failed");
                    require(IERC20(address(this)).transfer(researchAddress,_researchToken), "ERC20: Transfer to research address failed");

                    _marketingToken = 0;
                    _researchToken = 0;

                    // Remove Hate Swap and Liquidity by breaking Token in proportion
                    addLiquidityToToken(liquidityToken);

                }  

            }
            
        }
        
        _tempHolderRewardFee = 0;
        _tempLiquidityFee = 0;
        // If any account belongs to _isExcludedFromFee account then remove the fee
        if(!_isExcludedFromFee[from] || !_isExcludedFromFee[to]){
            // defaults transfer fees:
            if(transferFee){
                _tempHolderRewardFee = _holderRewardFee;
                _tempMarketingFee = 0;
                _tempResearchFee = 0;
                _tempLiquidityFee = _liquidityFee;
            }

            // Buy
            if(from == uniswapV2Pair){
                _tempHolderRewardFee = _buyHolderRewardFee;
                _tempMarketingFee = _buyMarketingFee;
                _tempResearchFee = _buyResearchFee;
                _tempLiquidityFee = _buyLiquidityFee;
            }
            // Sell
            if(to == uniswapV2Pair){
                _tempHolderRewardFee = _sellHolderRewardFee;
                _tempMarketingFee = _sellMarketingFee;
                _tempResearchFee = _sellResearchFee;
                _tempLiquidityFee = _sellLiquidityFee;
            }
            
        }
        
        _tokenTransfer(from,to,amount);
    }

    function swapTokensForBnb(uint256 tokenAmount) private {
        // Generate the uniswap pair path of token -> WBNB
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // Make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            minTokenLiqSwap, 
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForBNB(tokenAmount, path);
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // Approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // Add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // Slippage is unavoidable
            0, // Slippage is unavoidable
            address(this), //Contract Address
            block.timestamp
        );
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
	    _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;           
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
    	_tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + (rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
    	_tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + (tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient] + (rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateHolderRewardFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount - tFee - tLiquidity;
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rLiquidity = tLiquidity * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rLiquidity;
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < (_rTotal / _tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity * currentRate;
        if (_tempMarketingFee != 0 || _tempResearchFee != 0) {
            _marketingToken = _marketingToken + (tLiquidity * _tempMarketingFee / _tempLiquidityFee);
            _researchToken = _researchToken + (tLiquidity * _tempResearchFee / _tempLiquidityFee);
        }
        _rOwned[liquidityWallet] = _rOwned[liquidityWallet] + rLiquidity;
        if(_isExcluded[liquidityWallet])
            _tOwned[liquidityWallet] = _tOwned[liquidityWallet] + tLiquidity;
    }
    
    function calculateHolderRewardFee(uint256 _amount) private view returns (uint256) {
        return (_amount * _tempHolderRewardFee) / (
            10**2
        );
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return (_amount * _tempLiquidityFee) / (
            10**2
        );
    }


     // To receive BNB from uniswapV2Router when swapping
    receive() external payable {}


    function addLiquidityToToken(uint256 tokenLiquifyAmount) private lockTheSwap{
        // split the contract balance into halves
        uint256 half = tokenLiquifyAmount / 2; //staking tokens to be swaped
        uint256 otherHalf = tokenLiquifyAmount - half; //staking tokens not swapped

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        swapTokensForBnb(half); // <- this breaks the BNB -> HATE swap when swap+liquify is triggered

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquifyTokens(half, newBalance, otherHalf);
    }

    /* PRIVATE FUNCTION ENDS */

    /* OWNER FUNCTION STARTS */

    
    //Use when new router is released and pair HAS been created already.
    function setRouterAddress(address newRouter) external onlyOwner() {
        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        uniswapV2Router = _newPancakeRouter;
    }
    
    //Use when new router is released and pair HAS been created already.
    function setPairAddress(address newPair) external onlyOwner() {
        require(newPair != address(0), "Zero Address Error");
        uniswapV2Pair = newPair;
    }


    function excludeFromReward(address account) public onlyOwner() {

        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setBuyMaxTxAmount(uint256 bMaxTxAmount) external onlyOwner {
        require(bMaxTxAmount >= (_tTotal/1000),"Amount Should be greater than 0.1% of the total Supply");
        _bMaxTxAmount = bMaxTxAmount;
    }

    function setSellMaxTxAmount(uint256 sMaxTxAmount) external onlyOwner {
        require(sMaxTxAmount >= (_tTotal/1000),"Amount Should be greater than 0.1% of the total Supply");
        _sMaxTxAmount = sMaxTxAmount;
    }

    function setMinTokensToInitiateSwap(uint256 _minimumTokensBeforeSwap) external onlyOwner {
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
    }

    function setMarketingAddress(address _marketingAddress) external onlyOwner {
        require(_marketingAddress != address(0), "Zero Address Error");
        marketingAddress = _marketingAddress;
        _isExcludedFromFee[marketingAddress] = true;
    }

    function setResearchAddress(address _researchAddress) external onlyOwner {
        require(_researchAddress != address(0), "Zero Address Error");
        researchAddress = _researchAddress;
        _isExcludedFromFee[researchAddress] = true;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function enableTransferFee(bool _enabled) external onlyOwner {
        transferFee = _enabled;
    }

    function changeRouterVersion(address _router) external onlyOwner returns(address _pair) {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
        
        _pair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH());
        if(_pair == address(0)){
            // Pair doesn't exist
            _pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        }
        uniswapV2Pair = _pair;

        // Set the router of the contract variables
        uniswapV2Router = _uniswapV2Router;
    }
    

    // for stuck tokens of other types
    function transferForeignToken(address _token, address _to) external onlyOwner returns(bool _sent){
        require(_token != address(this), "Can't let you take all native token");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

    //Create additional liquidity using  tokens in contract
    function manualSwapAndLiquifyTokens(uint256 tokenLiquifyAmount) external lockTheSwap onlyOwner{
        addLiquidityToToken(tokenLiquifyAmount);
    }

    /* Renounce Trading Setter Address */
    /* Note : Once Renounced trading cant be closed */
    function renounceTradingOwner() external onlyOwner {
        require(tradingOpen, "Trading Must be turned on before Renouncing Ownership");
        tradingSetter = address(0);
    }

    function setRewardMarketingDevFee(uint256 _sellHolderPercent,uint256 _sellMarketingPercent, uint256 _sellResearchPercent, uint256 _sellLiquidityPercent, uint256 _buyHolderPercent, uint256 _buyMarketingPercent, uint256 _buyResearchPercent, uint256 _buyLiquidityPercent ) external onlyOwner {
        require((_sellHolderPercent + _sellLiquidityPercent+ _sellMarketingPercent+_sellResearchPercent)<=35,"Total Sell Percent Should be less than 35%");
        require((_buyHolderPercent + _buyLiquidityPercent+_buyMarketingPercent+_buyResearchPercent)<=35,"Total Buy Percent Should be less than 35%");
        _sellHolderRewardFee = _sellHolderPercent;
        _sellMarketingFee = _sellMarketingPercent;
        _sellResearchFee = _sellResearchPercent;
        
        _buyHolderRewardFee = _buyHolderPercent;
        _buyMarketingFee = _buyMarketingPercent;
        _buyResearchFee = _buyResearchPercent;
        
        _buyLiquidityFee = _buyLiquidityPercent+_buyMarketingPercent+_buyResearchPercent;
        _sellLiquidityFee = _sellLiquidityPercent+ _sellMarketingPercent+_sellResearchPercent;
    }

    function setTransferFee(uint256 _holderPercent, uint256 _liquidityPercent) external onlyOwner{
        require((_holderPercent + _liquidityPercent)<=35,"Total Tax Percent Should be less than 35%");
        _holderRewardFee = _holderPercent;
        _liquidityFee = _liquidityPercent;
    }

    /* Turn on or Off the Trading Option */
    function setTradingOpen(bool _status) external onlyOwner {
        require(tradingSetter == msg.sender,"Ownership of Trade Setter Renounced");
        tradingOpen = _status;
    }

    // Recommended : For stuck tokens (as a result of slight miscalculations/rounding errors) 
    function SweepStuck(uint256 _amount) external onlyOwner {
        (bool sent, bytes memory data) = payable(owner()).call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    function changeMinTokenLiqSwap(uint256 _amount) external onlyOwner {
        minTokenLiqSwap = _amount;
    }

    /* OWNER FUNCTION ENDS */
    
}

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

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

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

interface IUniswapV2Factory {
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

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

import "./Context.sol";

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() external view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() external view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) external virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() external virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}