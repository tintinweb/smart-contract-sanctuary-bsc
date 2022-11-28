/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.15;

abstract contract Context 
{
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = 0x7a2C9f333f4F72FAA7613024eb98c0ceE5D4F127;
        _owner = msgSender;
        emit OwnershipTransferred(address(0),  _owner);
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


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


interface IUniswapV2Pair 
{
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
}


interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 
{
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract DigitalMetaToken is Context, IBEP20, Ownable 
{
    using SafeMath for uint256;
    address payable public marketingAddress = payable(0x0638585f6f60fFaf1A1931b078Ac2C0Efa5F1c1F);
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) private _isExemptFromTxLimit;
    address[] private _excluded;
       
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1010000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "Digital Meta Token";
    string private _symbol = "DMT";
    uint8 private _decimals = 18;
    
    uint256 public _marketingFee = 3;
    uint256 private _previousMarketingFee = _marketingFee;

    uint256 _sellmarketingFee = 5;


    uint256 public _maxBuyTxAmount = _tTotal.div(100).mul(2); 
    uint256 public _maxSaleTxAmount = 1500000  * 10**18; 

    uint256 private _minimumTokensBeforeSwap = 10100 * 10**18;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;
    
    bool inSwap;
    bool public swapEnabled = false;
    
    event RewardLiquidityProviders(uint256 tokenAmount);
    event SwapEnabledUpdated(bool enabled);
    event Swap(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    
    constructor () 
    {
        _rOwned[owner()] = _rTotal;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        emit Transfer(address(0), owner(), _tTotal);

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingAddress] = true;
        excludeWalletsFromWhales();
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

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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

    function isExcludedFromReward(address account) public view returns (bool) 
    {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) 
    {
        return _tFeeTotal;
    }
    
    function _minimumTokensBeforeSwapAmount() public view returns (uint256) 
    {
        return _minimumTokensBeforeSwap;
    }


    function tokenFromReflection(uint256 rAmount) public view returns(uint256) 
    {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() 
    {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }


    function includeInReward(address account) external onlyOwner() 
    {
        require(_isExcluded[account], "Account is already excluded");
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


    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }


    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private 
    {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(!_isExemptFromTxLimit[from] && !_isExemptFromTxLimit[to]) 
        {
            if(to==uniswapV2Pair) 
            {
                require(amount <= _maxSaleTxAmount, "Exceeds Max Sale Txn Amount");
            }
            else
            {
                require(amount <= _maxBuyTxAmount, "Exceeds Max Tx Amount");
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= _minimumTokensBeforeSwap;
        
        if (!inSwap && swapEnabled && from != uniswapV2Pair) {
            if (overMinimumTokenBalance) 
            {
                contractTokenBalance = _minimumTokensBeforeSwap;
                swap(contractTokenBalance);
            }
        }
        
        checkForWhale(from, to, amount);

        if(to==uniswapV2Pair) {  
            setsellFee(); 
            
        }
        
        bool takeFee = true;
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to])
        {
            takeFee = false;
        }
        _tokenTransfer(from, to, amount, takeFee);
    }



    function swap(uint256 contractTokenBalance) private lockTheSwap 
    {
        swapTokensForEth(contractTokenBalance); 
        uint256 newBalance = address(this).balance;
        marketingAddress.transfer(newBalance);
    }


    
    function swapTokensForEth(uint256 tokenAmount) private 
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        emit SwapTokensForETH(tokenAmount, path);
    }
    
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private 
    {
        if(!takeFee) 
        { 
            removeAllFee(); 
        }
        _transferStandard(sender, recipient, amount);
        restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private 
    {
        (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeWalletFee(tLiquidity);
        emit Transfer(sender, recipient, tTransferAmount);
        if(tLiquidity>0) { emit Transfer(sender, address(this), tLiquidity); }
    }


    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) 
    {
        (uint256 tTransferAmount, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount) = _getRValues(tAmount, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, tTransferAmount, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tLiquidity = calculateWalletFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tLiquidity);
        return (tTransferAmount, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rLiquidity);
        return (rAmount, rTransferAmount);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }



    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    

    function _takeWalletFee(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
    
    
    function calculateWalletFee(uint256 _amount) private view returns (uint256) 
    {
        return _amount.mul(_marketingFee).div(100);
    }
    
    function removeAllFee() private 
    {       
        _marketingFee = 0;
    }
    
    function restoreAllFee() private 
    {
        _marketingFee = _previousMarketingFee;
    }

    function setsellFee() private 
    {
        _marketingFee = _sellmarketingFee;
    }


    function setAllFeePercentages(uint256 buyMarketingFee, uint256 sellMarketingFee) external onlyOwner()
    {
        _marketingFee = buyMarketingFee;
        _previousMarketingFee = buyMarketingFee;
        _sellmarketingFee = sellMarketingFee;
        require(buyMarketingFee<=10, "Too High Fee");
        require(sellMarketingFee<=15, "Too High Fee");
    }


    function setMaxBuyTxAmount(uint256 _mount) external onlyOwner() 
    {
        require(_mount>_tTotal.div(1000), "Too low Txn limit"); // Min 0.1%
        _maxBuyTxAmount = _mount;
    }
    
    function setMaxSaleTxAmount(uint256 _mount) external onlyOwner() 
    {
        require(_mount>_tTotal.div(1000), "Too low Txn limit"); // Min 0.1%
        _maxSaleTxAmount = _mount;
    }
    
    function setMinimumTokensBeforeSwap(uint256 minimumTokensBeforeSwap) external onlyOwner() 
    {
        _minimumTokensBeforeSwap = minimumTokensBeforeSwap;
    }

    function setMarketingAddress(address _marketingAddress) external onlyOwner() 
    {
        marketingAddress = payable(_marketingAddress);
    }

    function setSwapEnabled(bool _enabled) public onlyOwner 
    {
        swapEnabled = _enabled;
        emit SwapEnabledUpdated(_enabled);
    }
    receive() external payable {}

//////--------  ANTI WHALE -------/////--------



    mapping (address => bool) private _isExcludedFromWhale;
    uint256 public _walletHoldingMaxLimit =  _tTotal.div(100).mul(2); //2%

    function excludeWalletsFromWhales() private 
    {
        _isExcludedFromWhale[owner()]=true;
        _isExcludedFromWhale[address(this)]=true;
        _isExcludedFromWhale[address(0)]=true;
        _isExcludedFromWhale[uniswapV2Pair]=true;
    }


    function checkForWhale(address from, address to, uint256 amount) 
    private view
    {
        uint256 newBalance = balanceOf(to).add(amount);
        if(!_isExcludedFromWhale[from] && !_isExcludedFromWhale[to]) 
        { 
            require(newBalance <= _walletHoldingMaxLimit, "Exceeding max tokens limit in the wallet"); 
        } 
        if(from==uniswapV2Pair && !_isExcludedFromWhale[to]) 
        { 
            require(newBalance <= _walletHoldingMaxLimit, "Exceeding max tokens limit in the wallet"); 
        } 
    }
 
    function setExcludedFromWhale(address account, bool _enabled) public onlyOwner 
    {
        _isExcludedFromWhale[account] = _enabled;
    } 

    function  setWalletMaxHoldingLimit(uint256 _amount) public onlyOwner 
    {
        _walletHoldingMaxLimit = _amount;
        require(_walletHoldingMaxLimit>_tTotal.div(1000), "Too less limit");
            
    }


}