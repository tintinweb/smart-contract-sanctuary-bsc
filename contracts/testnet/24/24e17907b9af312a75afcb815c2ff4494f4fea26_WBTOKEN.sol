/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;

// SPDX-License-Identifier:MIT

interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address payable private _owner;
    address payable private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = payable(0x74C1F2bEA2686c38933Ddf5D7BDEF243455b6D4A);
        emit OwnershipTransferred(address(0), _owner);
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
        _owner = payable(address(0));
    }

    function transferOwnership(address payable newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

interface IDEXFactory {
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

interface IDEXPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

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

interface IDEXRouter01 {
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

interface IDEXRouter02 is IDEXRouter01 {
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

         

contract WBTOKEN is Context, IBEP20, Ownable {

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;

    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 70_000_000 * 10**8;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "O TOKEN"; // token name
    string private _symbol = "oWB"; // token ticker
    uint8 private _decimals = 8; // token decimals

    IDEXRouter02 public DEXRouter;
    address public DEXPair;
    address payable public marketWallet = payable(0xabc4B357D7419cfD3747DC1338e9e6308612D87c);
        address payable public presaleWallet = payable(0xabc4B357D7419cfD3747DC1338e9e6308612D87c);
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 minTokenNumberToSell = _tTotal / 1000; // 0.1% of total supply
    uint256 public maxFee = 200; // 20% max fees limit per transaction
    bool public swapAndLiquifyEnabled = false; // should be true to turn on to liquidate the pool
    bool inSwapAndLiquify = false;
    
    
    // buy tax fee
    uint256 public redistributionFeeOnBuying = 20; // 2% will be distributed among holder as token divideneds
    uint256 public liquidityFeeOnBuying = 40; // 4% will be added to the liquidity pool
    uint256 public marketingwalletFeeOnBuying = 40; // 2% will go to the marketingwallet address
    uint256 public autoburnFeeOnBuying = 0; // 0% will go to the earth burn wallet address

    // sell tax fee
    uint256 public redistributionFeeOnSelling = 20; // 2% will be distributed among holder as token divideneds
    uint256 public liquidityFeeOnSelling = 40; // 4% will be added to the liquidity pool
    uint256 public marketingwalletFeeOnSelling = 40; // 1% will go to the market address
    uint256 public autoburnFeeOnSelling = 0; // 0% will go to the earth autoburn wallet address

    // normal tax fee
    uint256 public redistributionFee = 20; // 2% will be distributed among holder as token divideneds
    uint256 public liquidityFee = 40; // 4% will be added to the liquidity pool
    uint256 public marketingwalletFee = 40; // 2% will go to the market address
    uint256 public autoburnFee = 0; // 0% will go to the earth autoburn wallet address

    // for smart contract use
    uint256 private _currentRedistributionFee = 20;
    uint256 private _currentLiquidityFee = 40;
    uint256 private _currentmarketingwalletFee = 20;
    uint256 private _currentautoburnFee;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
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

    constructor (
    ) {
        _rOwned[owner()] = _rTotal;

        IDEXRouter02 _DEXRouter = IDEXRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);//test
        //IDEXRouter02 _DEXRouter = IDEXRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);//main
        // Create a DEX pair for this new token
        DEXPair = IDEXFactory(_DEXRouter.factory())
        .createPair(address(this), _DEXRouter.WETH());

        // set the rest of the contract variables
        DEXRouter = _DEXRouter;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[presaleWallet] = true;//presale wallet
        _isExcludedFromFee[marketWallet] = true;
        _isExcludedFromFee[address(this)] = true;


        emit Transfer(address(0), owner(), _tTotal);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address _owner, address spender) public view override returns (uint256) {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()]-(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender]+(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender]-(subtractedValue));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        uint256 rAmount = tAmount*(_getRate());
        _rOwned[sender] = _rOwned[sender]-(rAmount);
        _rTotal = _rTotal-(rAmount);
        _tFeeTotal = _tFeeTotal+(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns (uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            uint256 rAmount = tAmount*(_getRate());
            return rAmount;
        } else {
            uint256 rAmount = tAmount*(_getRate());
            uint256 rTransferAmount = rAmount-(totalFeePerTx(tAmount)*(_getRate()));
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount/(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _rOwned[account] = _tOwned[account]*(_getRate());
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    
    function setMinTokenNumberToSell(uint256 _amount) public onlyOwner {
        minTokenNumberToSell = _amount;
    }


    function setSwapAndLiquifyEnabled(bool _state) public onlyOwner {
        swapAndLiquifyEnabled = _state;
        emit SwapAndLiquifyEnabledUpdated(_state);
    }

    
    function setmarketWallet(address payable _marketWallet) external onlyOwner {
        require(_marketWallet!=address(0),"Market wallet cannot be address zero");
        marketWallet = _marketWallet;
    }
    
    function setpresaleWallet(address payable _presaleWallet) external onlyOwner {
        require(_presaleWallet!=address(0),"Market wallet cannot be address zero");
        presaleWallet = _presaleWallet;
    }
    
    function setRoute(IDEXRouter02 _router, address _pair) external onlyOwner {
        require(address(_router) !=address(0) , "Router adress cannot be address zero");
        require(_pair != address(0), "Pair adress cannot be address zero");
        DEXRouter = _router;
        DEXPair = _pair;
    }

    function withdrawBNB(uint _amount) external onlyOwner {
        require(address(this).balance>= _amount , "Invalid Amount");
         payable(msg.sender).transfer(_amount);

    }

      function withdrawToken(IBEP20 _token , uint _amount) external onlyOwner {
        require(_token.balanceOf(address(this))>= _amount , "Invalid Amount");
        _token.transfer(msg.sender,_amount);

    }

    //to receive BNB from DEXRouter when swapping
    receive() external payable {}
    
    function totalFeePerTx(uint256 tAmount) internal view returns(uint256) {
        uint256 percentage = tAmount*(_currentRedistributionFee+(_currentLiquidityFee)+(_currentmarketingwalletFee)+(_currentautoburnFee))/(1e3);
        return percentage;
    }

    function _reflectFee(uint256 tAmount) private {
        uint256 tFee = tAmount*(_currentRedistributionFee)/(1e3);
        uint256 rFee = tFee*(_getRate());
        _rTotal = _rTotal-(rFee);
        _tFeeTotal = _tFeeTotal+(tFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply/(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply-(_rOwned[_excluded[i]]);
            tSupply = tSupply-(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal/(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidityPoolFee(uint256 tAmount, uint256 currentRate) internal {
        uint256 tPoolFee = tAmount*(_currentLiquidityFee)/(1e3);
        uint256 rPoolFee = tPoolFee*(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)]+(rPoolFee);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)]+(tPoolFee);
        emit Transfer(_msgSender(), address(this), tPoolFee);
    }
    
    function _takeMarketFee(uint256 tAmount, uint256 currentRate) internal {
        uint256 tCharityFee = tAmount*(_currentmarketingwalletFee)/(1e3);
        uint256 rCharityFee = tCharityFee*(currentRate);
        _rOwned[marketWallet] = _rOwned[marketWallet]+(rCharityFee);
        if (_isExcluded[marketWallet])
            _tOwned[marketWallet] = _tOwned[marketWallet]+(tCharityFee);
        emit Transfer(_msgSender(), marketWallet, tCharityFee);
    }
    
    function _takeBurnFee(uint256 tAmount, uint256 currentRate) internal {
        uint256 burnFee = tAmount*(_currentautoburnFee)/(1e3);
        uint256 rBurnFee = burnFee*(currentRate);
        _rOwned[burnAddress] = _rOwned[burnAddress]+(rBurnFee);
        if (_isExcluded[burnAddress])
            _tOwned[burnAddress] = _tOwned[burnAddress]+(burnFee);
        emit Transfer(_msgSender(), burnAddress, burnFee);
    }

    function removeAllFee() private {
        _currentRedistributionFee = 0;
        _currentLiquidityFee = 0;
        _currentmarketingwalletFee = 0;
        _currentautoburnFee = 0;
    }

    function setBuyFee() private {
        _currentRedistributionFee = redistributionFeeOnBuying;
        _currentLiquidityFee = liquidityFeeOnBuying;
        _currentmarketingwalletFee = marketingwalletFeeOnBuying;
        _currentautoburnFee = autoburnFeeOnBuying;
    }

    function setSellFee() private {
        _currentRedistributionFee = redistributionFeeOnSelling;
        _currentLiquidityFee = liquidityFeeOnSelling;
        _currentmarketingwalletFee = marketingwalletFeeOnSelling;
        _currentautoburnFee = autoburnFeeOnSelling;
    }

    function setNormalFee() private {
        _currentRedistributionFee = redistributionFee;
        _currentLiquidityFee = liquidityFee;
        _currentmarketingwalletFee = marketingwalletFee;
        _currentautoburnFee = autoburnFee;
    }

    function setautoburnFee(uint256 _autoburnFee) external onlyOwner() {
        autoburnFeeOnBuying = _autoburnFee;
        autoburnFeeOnSelling = _autoburnFee;
        autoburnFee = _autoburnFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address _owner, address spender, uint256 amount) private {
        require(_owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "BEP20: Transfer amount must be greater than zero");

        // swap and liquify
        swapAndLiquify(from, to);

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] ) {
            takeFee = false;
        }
        if (!takeFee){
            removeAllFee();
        }
            
            // buying handler
        else if (from == DEXPair) {
            setBuyFee();
        }

            // selling handler
        else if (to == DEXPair) {
            setSellFee();

        }
        
            // normal transaction handler
        else {
            setNormalFee();
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount);
    }

    //this method is responsible for taking all fee, if takeFee is true
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
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount-(totalFeePerTx(tAmount));
        uint256 rAmount = tAmount*(currentRate);
        uint256 rTransferAmount = rAmount-(totalFeePerTx(tAmount)*(currentRate));
        _rOwned[sender] = _rOwned[sender]-(rAmount);
        _rOwned[recipient] = _rOwned[recipient]+(rTransferAmount);
        _takeLiquidityPoolFee(tAmount, currentRate);
        _takeMarketFee(tAmount, currentRate);
    
        _takeBurnFee(tAmount, currentRate);
        _reflectFee(tAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount-(totalFeePerTx(tAmount));
        uint256 rAmount = tAmount*(currentRate);
        uint256 rTransferAmount = rAmount-(totalFeePerTx(tAmount)*(currentRate));
        _rOwned[sender] = _rOwned[sender]-(rAmount);
        _tOwned[recipient] = _tOwned[recipient]+(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient]+(rTransferAmount);
        _takeLiquidityPoolFee(tAmount, currentRate);
        _takeMarketFee(tAmount, currentRate);
    
        _takeBurnFee(tAmount, currentRate);
        _reflectFee(tAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount-(totalFeePerTx(tAmount));
        uint256 rAmount = tAmount*(currentRate);
        uint256 rTransferAmount = rAmount-(totalFeePerTx(tAmount)*(currentRate));
        _tOwned[sender] = _tOwned[sender]-(tAmount);
        _rOwned[sender] = _rOwned[sender]-(rAmount);
        _rOwned[recipient] = _rOwned[recipient]+(rTransferAmount);
        _takeLiquidityPoolFee(tAmount, currentRate);
        _takeMarketFee(tAmount, currentRate);
    
        _takeBurnFee(tAmount, currentRate);
        _reflectFee(tAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount-(totalFeePerTx(tAmount));
        uint256 rAmount = tAmount*(currentRate);
        uint256 rTransferAmount = rAmount-(totalFeePerTx(tAmount)*(currentRate));
        _tOwned[sender] = _tOwned[sender]-(tAmount);
        _rOwned[sender] = _rOwned[sender]-(rAmount);
        _tOwned[recipient] = _tOwned[recipient]+(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient]+(rTransferAmount);
        _takeLiquidityPoolFee(tAmount, currentRate);
        _takeMarketFee(tAmount, currentRate);
    
        _takeBurnFee(tAmount, currentRate);
        _reflectFee(tAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function swapAndLiquify(address from, address to) private {
        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is DEX pair.
        uint256 contractTokenBalance = balanceOf(address(this));

        bool shouldSell = contractTokenBalance >= minTokenNumberToSell;

        if (
            !inSwapAndLiquify &&
            shouldSell &&
            from != DEXPair &&
            swapAndLiquifyEnabled &&
            !(from == address(this) && to == address(DEXPair)) // swap 1 time
        ) {
            // only sell for minTokenNumberToSell, decouple from _maxTxAmount
            // split the contract balance into 4 pieces
            
            contractTokenBalance = minTokenNumberToSell;
            // approve contract
            _approve(address(this), address(DEXRouter), contractTokenBalance);
                       
            uint256 otherPiece = contractTokenBalance/(2);
            uint256 tokenAmountToBeSwapped = contractTokenBalance-(otherPiece);
            
            uint256 initialBalance = address(this).balance;

            Utils.swapTokensForEth(address(DEXRouter), tokenAmountToBeSwapped);

            uint256 bnbToBeAddedToLiquidity = address(this).balance-(initialBalance);

            Utils.addLiquidity(address(DEXRouter), owner(), otherPiece, bnbToBeAddedToLiquidity);
            
            emit SwapAndLiquify(tokenAmountToBeSwapped, bnbToBeAddedToLiquidity, otherPiece);
        }
    }
    
    
}

library Utils {

    function swapTokensForEth(
        address routerAddress,
        uint256 tokenAmount
    ) internal {
        IDEXRouter02 DEXRouter = IDEXRouter02(routerAddress);

        // generate the DEX pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = DEXRouter.WETH();

        // make the swap
        DEXRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp + 300
        );
    }

    function swapETHForTokens(
        address routerAddress,
        address recipient,
        uint256 ethAmount
    ) internal {
        IDEXRouter02 DEXRouter = IDEXRouter02(routerAddress);

        // generate the DEX pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = DEXRouter.WETH();
        path[1] = address(this);

        // make the swap
        DEXRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0, // accept any amount of BNB
            path,
            address(recipient),
            block.timestamp + 300
        );
    }

    function addLiquidity(
        address routerAddress,
        address owner,
        uint256 tokenAmount,
        uint256 ethAmount
    ) internal {
        IDEXRouter02 DEXRouter = IDEXRouter02(routerAddress);

        // add the liquidity
        DEXRouter.addLiquidityETH{value : ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp + 300
        );
    }
}