/**
 *Submitted for verification at BscScan.com on 2022-11-06
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


interface IBEP20 
{
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath 
{
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

contract Ownable is Context 
{
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () 
    {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) 
    {
        return _owner;
    }   
    
    modifier onlyOwner() 
    {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner 
    {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
}

// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
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
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
}



interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin,  uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);    
}


interface IUniswapV2Router02 is IUniswapV2Router01 
{
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}


contract LockToken is Ownable 
{
    bool public isOpen = false;
    mapping(address => bool) private _whiteList;
    modifier open(address from, address to) {
        require(isOpen || _whiteList[from] || _whiteList[to], "Not Open");
        _;
    }

    constructor() {
        _whiteList[msg.sender] = true;
        _whiteList[address(this)] = true;
    }

    function openTrade() external onlyOwner {
        isOpen = true;
    }

    function includeToWhiteList(address[] memory _users) external onlyOwner {
        for(uint8 i = 0; i < _users.length; i++) {
            _whiteList[_users[i]] = true;
        }
    }
}


contract GENT is Context, IBEP20, LockToken 
{
    using SafeMath for uint256;

    address payable public marketingAddress = payable(address(this));
    address payable public devAddress = payable(address(this));
    address payable public charityAddress = payable(address(this));

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) private _isExemptFromTxLimit;
    address[] private _excluded;
       
    uint8 private _decimals = 9;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 450_000_000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "GennbToken";
    string private _symbol = "GENT";
    
    
    uint256 public _liquidityFee = 1;
    uint256 private _previousLiquidityFee = _liquidityFee;
    
    uint256 public _marketingFee = 1;
    uint256 private _previousMarketingFee = _marketingFee;

    uint256 public _devFee = 1;
    uint256 private _previousDevFee = _devFee;

    uint256 public _charityFee = 1;
    uint256 private _previousCharityFee = _charityFee;

    uint256 _sellLiquidityFee = 2;
    uint256 _sellMarketingFee = 2;
    uint256 _sellDevFee = 2;
    uint256 _sellCharityFee = 2;

    uint256 public _maxTxAmount = _tTotal.div(100).mul(1); //1% 

    uint256 private _minimumTokensBeforeSwap = 450_000 * 10**9;

    uint256 public _walletHoldingMaxLimit =  _tTotal.div(100).mul(2); // 2%

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;

    
    event RewardLiquidityProviders(uint256 tokenAmount);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
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
    
    modifier lockTheSwap 
    {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () 
    {
        _rOwned[owner()] = _rTotal;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        emit Transfer(address(0), owner(), _tTotal);
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExemptFromTxLimit[owner()] = true;
        _isExemptFromTxLimit[address(this)] = true;
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
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


    function includeInReward(address account) external onlyOwner() {
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
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private open(from, to)
    {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(!_isExemptFromTxLimit[from] && !_isExemptFromTxLimit[to]) 
        {
            require(amount <= _maxTxAmount, "Exceeds Max Tx Amount");
        }

        checkForRemove(from, to);

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= _minimumTokensBeforeSwap;
        
        if (!inSwapAndLiquify && swapAndLiquifyEnabled && from != uniswapV2Pair) {
            if (overMinimumTokenBalance) 
            {
                contractTokenBalance = _minimumTokensBeforeSwap;
                swapAndLiquify(contractTokenBalance);
            }
        }

        if(to==uniswapV2Pair) {  setSaleFee(); }
        
        bool takeFee = true;
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to])
        {
            takeFee = false;
        }
        _tokenTransfer(from, to, amount, takeFee);
    }



    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap 
    {
        uint256 halfLiquidityTokens = contractTokenBalance.mul(_liquidityFee).div(100).div(2);
        uint256 swapableTokens = contractTokenBalance.sub(halfLiquidityTokens);
        swapTokensForEth(swapableTokens); 
        uint256 newBalance = address(this).balance;
        uint256 ethForLiquidity = newBalance.mul(_liquidityFee).div(100).div(2);
        addLiquidity(halfLiquidityTokens, ethForLiquidity);
        emit SwapAndLiquify(halfLiquidityTokens, ethForLiquidity, halfLiquidityTokens);
        uint256 ethForMarketing = newBalance.mul(_marketingFee).div(100);
        uint256 ethForDev = newBalance.mul(_devFee).div(100);
        uint256 ethForCharity = newBalance.sub(ethForDev).sub(ethForMarketing).sub(ethForLiquidity);
        marketingAddress.transfer(ethForMarketing);
        devAddress.transfer(ethForDev);
        charityAddress.transfer(ethForCharity);
    }

    
    function swapTokensForEth(uint256 tokenAmount) private 
    {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        emit SwapTokensForETH(tokenAmount, path);
    }
    
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }



    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private 
    {

        if(!takeFee) { removeAllFee(); }

         if (_isExcluded[sender] && !_isExcluded[recipient]) 
        {
            _transferFromExcluded(sender, recipient, amount);
        } 
        else if (!_isExcluded[sender] && _isExcluded[recipient]) 
        {
            _transferToExcluded(sender, recipient, amount);
        } 
        else if(_isExcluded[sender] && _isExcluded[recipient]) 
        {
            _transferBothExcluded(sender, recipient, amount);
        } 
        else 
        {
            _transferStandard(sender, recipient, amount);
        }   
        restoreAllFee();
    }


    function _transferStandard(address sender, address recipient, uint256 tAmount) private 
    {
        (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        emit Transfer(sender, recipient, tTransferAmount);
        if(tLiquidity>0) { emit Transfer(sender, address(this), tLiquidity); }
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        emit Transfer(sender, recipient, tTransferAmount);
        if(tLiquidity>0) { emit Transfer(sender, address(this), tLiquidity); }
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        emit Transfer(sender, recipient, tTransferAmount);
        if(tLiquidity>0) { emit Transfer(sender, address(this), tLiquidity); }
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        emit Transfer(sender, recipient, tTransferAmount);
        if(tLiquidity>0) { emit Transfer(sender, address(this), tLiquidity); }
    }


    function excludeFromTxLimit(address account, bool _value) external onlyOwner
    {
        _isExemptFromTxLimit[account] = _value;
    }


    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) 
    {
        (uint256 tTransferAmount, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount) = _getRValues(tAmount, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, tTransferAmount, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
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

    function _getCurrentSupply() private view returns(uint256, uint256) 
    {
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
    

    function _takeLiquidity(uint256 tLiquidity) private 
    {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
    
    
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) 
    {
        return _amount.mul(_liquidityFee+_marketingFee+_devFee+_charityFee).div(100);
    }
    
    function removeAllFee() private 
    {       
        _liquidityFee = 0;
        _marketingFee = 0;
        _devFee = 0;
        _charityFee = 0;
    }
    
    function restoreAllFee() private 
    {
        _liquidityFee = _previousLiquidityFee;
        _marketingFee = _previousMarketingFee;
        _devFee = _previousDevFee;
        _charityFee = _previousCharityFee;
    }

    function setSaleFee() private 
    {
        _liquidityFee = _sellLiquidityFee;
        _marketingFee = _sellMarketingFee;
        _devFee = _sellDevFee;
        _charityFee = _sellCharityFee;
    }
    

    function setBuyTax(uint256 liquidityFee, uint256 marketingFee, uint256 devFee, uint256 charityFee) 
    external onlyOwner 
    {
        _liquidityFee = liquidityFee;
        _previousLiquidityFee = liquidityFee;

        _marketingFee = marketingFee;
        _previousMarketingFee = marketingFee;

        _devFee = devFee;
        _previousDevFee = devFee;
        
        _charityFee = charityFee;
        _previousCharityFee = charityFee;

        uint256 total = _liquidityFee.add(_marketingFee).add(_devFee).add(_charityFee);
        require(total<15, "Too High Fee");

    }


    function setSellTax(uint256 liquidityFee, uint256 marketingFee, uint256 devFee, uint256 charityFee) 
    external onlyOwner 
    {
        _sellLiquidityFee = liquidityFee;
        _sellMarketingFee =  marketingFee;
        _sellDevFee = devFee;
        _sellCharityFee = charityFee;
        uint256 total = _sellLiquidityFee.add(_sellMarketingFee).add(_sellDevFee).add(_sellCharityFee);
        require(total<20, "Too High Fee");
    }    


    function setMaxTxAmount(uint256 _mount) external onlyOwner() 
    {
        require(_mount>_tTotal.div(1000), "Too low Txn limit"); // Min 0.1%
        _maxTxAmount = _mount;
    }
    

    function setMinimumTokensBeforeSwap(uint256 __minimumTokensBeforeSwap) external onlyOwner() 
    {
        _minimumTokensBeforeSwap = __minimumTokensBeforeSwap;
    }
    

    function setTaxWallets(address _marketingAddress, address _devAddress, address _charityAddress) 
    external onlyOwner() 
    {
       marketingAddress = payable(_marketingAddress);
       devAddress = payable(_devAddress);
       charityAddress = payable(_charityAddress);
    }    


    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner 
    {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    function transferToAddressETH(address payable recipient, uint256 amount) private 
    {
        recipient.transfer(amount);
    }
    
    receive() external payable {}
    

    mapping(address => bool) public _isRemoved;

    event AccountRemoved(address _account,  bool _value, uint256 timestamp);

    function removeAddress(address account, bool value) external onlyOwner
    {
        _isRemoved[account] = value;
        emit AccountRemoved(account,  value, block.timestamp);
    }

    function checkForRemove(address from, address to) private view
    {
        require(!_isRemoved[from] && !_isRemoved[to], 'Removed address');
    }    
   
}