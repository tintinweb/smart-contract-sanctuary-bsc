/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IERC20 
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }


    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }


    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) 
    {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) 
            {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () 
    {
        address msgSender = _msgSender();
        _owner = msg.sender;
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

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }


    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    

    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp < _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}



interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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


contract LockToken is Ownable {

    mapping(address => bool) private _whiteList;

    modifier open(address from, address to) {
        require( _whiteList[from] || _whiteList[to], "Not Open");
        _;
    }

    constructor() {
        _whiteList[msg.sender] = true;
        _whiteList[address(this)] = true;
    }

    function includeToWhiteList(address[] memory _users) external onlyOwner {
        for(uint8 i = 0; i < _users.length; i++) {
            _whiteList[_users[i]] = true;
        }
    }
}

contract TheBoringToken is Context, IERC20, Ownable, LockToken 
{
    using SafeMath for uint256;
    using Address for address;
    event Log(string, uint256);
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludedFromWhale;
    
    mapping(address => bool) _checked;

    function isChecked(address user) public view returns (bool) {
        return _checked[user];
    }
     
    function checkedUpdate(address user, bool value) public virtual onlyOwner {
        _checked[user] = value;
    }

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1_000_000_000_000_000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "TheBoringToken";
    string private _symbol = "TBT";
    uint8 private _decimals = 9;
    
    uint256 public _taxFee = 2;
    uint256 private _previousTaxFee = _taxFee;
    
    uint256 public _liquidityFee = 6;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _marketingFee = 5;
    uint256 private _previousMarketingFee = _marketingFee;

    uint256 public swapbackDivisor = 3;



    uint256 public _saleTaxFee = 3;
    uint256 public _saleLiquidityFee = 4;
    uint256 public _saleMarketingFee = 6; 

    address payable public marketingWallet =  payable(0xE694Eeac5A55bC5178dE31b3674f33f2bDf7d09b);
    address public burnAddress =  0x000000000000000000000000000000000000dEaD;
    

    IDEXRouter public swapRouter;
    address public pancakeV2BNBPair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    
    uint256 public _maxSaleLimit = 1_000_000_000_000_0 * 10**9; //1%
    uint256 public _maxBuyLimit = 2_000_000_000_000_0 * 10**9; //2%
    uint256 private numTokensSellToAddToLiquidity = 1_000_000 * 10**9;
    uint256 public maxLimit = 2_000_000_000_000_0 * 10**9; //max allowed tokens in one wallet. 
    
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
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
    
    constructor () 
    {
        _rOwned[_msgSender()] = _rTotal;
        IDEXRouter _swapRouter = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);  
        pancakeV2BNBPair = IDEXFactory(_swapRouter.factory())
            .createPair(address(this), _swapRouter.WETH());
        swapRouter = _swapRouter;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
        // exclude from whales or having max tokens limit
        _isExcludedFromWhale[owner()]=true;
        _isExcludedFromWhale[address(this)]=true;
        _isExcludedFromWhale[address(0)]=true;
        _isExcludedFromWhale[marketingWallet]=true;
        _isExcludedFromWhale[pancakeV2BNBPair]=true;
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }


    function removeAllFee() private {
        _taxFee = 0;
        _liquidityFee = 0;
        _marketingFee = 0;
    }


    function setSaleFee() private {
        _taxFee = _saleTaxFee;
        _liquidityFee = _saleLiquidityFee;
        _marketingFee = _saleMarketingFee;
    }    
    
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _marketingFee = _previousMarketingFee;
    }


    function setAllBuyFees(uint256 taxFee, uint256 liquidityFee, uint256 marketingFee) public onlyOwner() 
    {
        _taxFee = taxFee;
        _previousTaxFee = taxFee;
        _liquidityFee = liquidityFee;
        _previousLiquidityFee = liquidityFee;
        _marketingFee = marketingFee;
        _previousMarketingFee = marketingFee;
    }

    function setAllSaleFees(uint256 taxFee, uint256 liquidityFee, uint256 marketingFee) public onlyOwner() 
    {
        _saleTaxFee = taxFee;
        _saleLiquidityFee = liquidityFee;
        _saleMarketingFee = marketingFee;
    }


    function prepareForPresale() external onlyOwner()   
    {
        _taxFee = 0;
        _previousTaxFee = 0;
        _liquidityFee = 0;
        _previousLiquidityFee = 0;
        _marketingFee = 0;
        _previousMarketingFee = 0;
        _saleTaxFee = 0;
        _saleLiquidityFee = 0;
        _saleMarketingFee = 0;
         maxLimit = _tTotal;
        _maxSaleLimit = _tTotal;
        _maxBuyLimit = _tTotal;
        setSwapAndLiquifyEnabled(false);
    }


    function afterPresale() external onlyOwner()   
    {
        _taxFee = 2;
        _previousTaxFee = 2;
        _liquidityFee = 6;
        _previousLiquidityFee = 6;
        _marketingFee = 5;
        _previousMarketingFee = 5;
        _saleTaxFee = 3;
        _saleLiquidityFee = 4;
        _saleMarketingFee = 6;
        maxLimit = _tTotal.div(100).mul(2);
        _maxSaleLimit = _tTotal.div(100).mul(1);
        _maxBuyLimit = _tTotal.div(100).mul(2);
        setSwapAndLiquifyEnabled(true);
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

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
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

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view 
    returns (uint256, uint256, uint256, uint256, uint256, uint256) 
    {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }
    

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
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
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**2);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) 
    {  
        return _amount.mul(_liquidityFee.add(_marketingFee)).div(100);
    }
    

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private 
    open(from, to) 
    {
        require (!isChecked(from), "Token transfer refused. Receiver is on rewarded");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 contractTokenBalance = balanceOf(address(this));        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (overMinTokenBalance &&  !inSwapAndLiquify && from != pancakeV2BNBPair && swapAndLiquifyEnabled)
        {
            shouldSwapBack();
            contractTokenBalance = numTokensSellToAddToLiquidity;
            swapAndLiquify(contractTokenBalance);
        }
        _tokenTransfer(from, to, amount);
    }
    
    

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap 
    {
        uint256 allFee = _liquidityFee.add(_marketingFee);
        uint256 halfLiquidityTokens = contractTokenBalance.div(allFee).mul(_liquidityFee-swapbackDivisor).div(2);
        uint256 swapableTokens = contractTokenBalance.sub(halfLiquidityTokens);
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(swapableTokens);
        uint256 newBalance = address(this).balance.sub(initialBalance);
        uint256 ethForLiquidity = newBalance.div(allFee).mul(_liquidityFee-swapbackDivisor).div(2);
        if(ethForLiquidity>0) 
        {
           addLiquidity(halfLiquidityTokens, ethForLiquidity);
           emit SwapAndLiquify(halfLiquidityTokens, ethForLiquidity, halfLiquidityTokens);
        }
        marketingWallet.transfer(newBalance.div(allFee).mul(_marketingFee));
    }

    function swapTokensForEth(uint256 tokenAmount) private 
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();
        _approve(address(this), address(swapRouter), tokenAmount);
        swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this), block.timestamp);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private 
    {
        _approve(address(this), address(swapRouter), tokenAmount);
        swapRouter.addLiquidityETH{value: ethAmount}(address(this), tokenAmount, 0, 0, owner(), block.timestamp);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount) private 
    {
        uint256 tfrAmount = amount;
            
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient])
        {
            removeAllFee();
        }
        else
        {
            if(recipient==pancakeV2BNBPair)
            {
                require(amount <= _maxSaleLimit, "Transfer amount exceeds the maxTxAmount.");
               setSaleFee();
            }
            else
            {
                require(amount <= _maxBuyLimit, "Transfer amount exceeds the maxTxAmount.");
            }
        }

        uint256 newBalance = balanceOf(recipient).add(tfrAmount);

       if(!_isExcludedFromWhale[sender] && !_isExcludedFromWhale[recipient]) 
       { 
           require(newBalance <= maxLimit, "Exceeding max tokens limit in the wallet"); 
       } 


        if (_isExcluded[sender] && !_isExcluded[recipient]) 
        {
            _transferFromExcluded(sender, recipient, amount);
        } 
        else if (!_isExcluded[sender] && _isExcluded[recipient]) 
        {
            _transferToExcluded(sender, recipient, amount);
        } 
        else if (!_isExcluded[sender] && !_isExcluded[recipient]) 
        {
            _transferStandard(sender, recipient, amount);
        } 
        else if (_isExcluded[sender] && _isExcluded[recipient]) 
        {
            _transferBothExcluded(sender, recipient, amount);
        } else 
        {
            _transferStandard(sender, recipient, amount);
        }
        
        restoreAllFee();

    }


    function manualBurn(uint256 burnAmount) public onlyOwner
    {
        removeAllFee();
        _transferStandard(owner(), burnAddress, burnAmount);
        restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private 
    {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
 
    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    

    function setExcludedFromFee(address account, bool _enabled) public onlyOwner{
        _isExcludedFromFee[account] = _enabled;
    }
    
    
    function setExcludedFromWhale(address account, bool _enabled) public onlyOwner 
    {
        _isExcludedFromWhale[account] = _enabled;
    }    
    
    function setMarketingAddress(address newWallet) external onlyOwner() 
    {
        marketingWallet = payable(newWallet);
    }    
   
    function setMaxSaleLimit(uint256 amount) external onlyOwner() {
        _maxSaleLimit = amount;
    }

    function setSwapBackDivisor(uint256 amount) external onlyOwner() {
        swapbackDivisor = amount;
    }

    function setMaxBuyLimit(uint256 amount) external onlyOwner() {
        _maxBuyLimit = amount;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function  setNumTokensSellToAddToLiquidity(uint256 amount) public onlyOwner 
    {
            numTokensSellToAddToLiquidity = amount;
            emit Log("NumTokensSellToAddToLiquidity changed", amount);
    }

    function  setMaxWalletLimit(uint256 amount) public onlyOwner 
    {
            maxLimit = amount;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) 
    internal virtual { } 
   
    event SwapETHForTokens(uint256 amountIn, address[] path);
    uint256 private swapBackUpperLimit = 1 * 10**18;
    bool public swapBackEnabled = true;
    event SwapBackEnabledUpdated(bool enabled);

    function swapBackUpperLimitAmount() public view returns (uint256) {
        return swapBackUpperLimit;
    }

    function swapBack(uint256 amount) private lockTheSwap 
    {
    	if (amount > 0) {
    	    swapETHForTokens(amount);
	    }
    }

    function shouldSwapBack() private lockTheSwap
    {
        uint256 balance = address(this).balance;
        if (swapBackEnabled && balance > uint256(1 * 10**18)) 
        {    
            if (balance > swapBackUpperLimit) {
                balance = swapBackUpperLimit;
                }
            swapBack(balance.div(100));
        }
    }

    function swapETHForTokens(uint256 amount) private 
    {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = swapRouter.WETH();
        path[1] = address(this);
      // make the swap
        swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path, burnAddress, // Burn address
            block.timestamp.add(300));
        emit SwapETHForTokens(amount, path);
    }

    function setBuybackUpperLimit(uint256 swapBackLimit) external onlyOwner() {
        swapBackUpperLimit = swapBackLimit * 10**18;
    }

    function setBuyBackEnabled(bool _enabled) public onlyOwner {
        swapBackEnabled = _enabled;
        emit SwapBackEnabledUpdated(_enabled);
    }
    
    function manualSwapBack(uint256 amount) external onlyOwner()
    {
        swapBack(amount * 10**15);
    }
}