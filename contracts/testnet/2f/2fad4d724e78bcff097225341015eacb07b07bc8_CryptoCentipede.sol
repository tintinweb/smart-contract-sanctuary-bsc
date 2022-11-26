/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: Unlicensed

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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
  
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

contract Pausable is Ownable {
	event Pause();
	event Unpause();
	
	bool public paused = false;
	
	function pause() onlyOwner public {
		paused = true;
		emit Pause();
	}
	
	function unpause() onlyOwner public {
		paused = false;
		emit Unpause();
	}
}

interface IPancakeSwapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeSwapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IPancakeSwapV2Router02 is IPancakeSwapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

contract CryptoCentipede is Context, IBEP20, Ownable, Pausable {

	using SafeMath for uint256;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludedFromReward;
	mapping (address => bool) private _automatedMarketMakerPairs;
	mapping (address => bool) public _isWhiteListed;
    address[] private _excluded;
	address[] public _latestBuyer;
	
    address private marketingWalletAddress = address(0x2B67Ba76f34079088623BEaa91B0241cA38af837);
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "Crypto Centipede";
    string private _symbol = "CC";
    uint8 private _decimals = 18;
	
	uint256[] public liquidityFee;
	uint256[] public marketingFee;
	uint256[] public reflectionFee;
	uint256[] public latestBuyerFee;
	
	uint256 private _liquidityFee;
	uint256 private _marketingFee;
	uint256 private _reflectionFee;
	uint256 private _latestBuyerFee;
	
    IPancakeSwapV2Router02 public immutable pancakeSwapV2Router;
    address public pancakeSwapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
	
    uint256 public numTokensSellToAddToLiquidity = 10000000 * 10**18;
	
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
	event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
	event AddToWhiteList(address _address);
    event RemovedFromWhiteList(address _address);
	
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
	
    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        
        IPancakeSwapV2Router02 _pancakeSwapV2Router = IPancakeSwapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pancakeSwapV2Pair = IPancakeSwapV2Factory(_pancakeSwapV2Router.factory()).createPair(address(this), _pancakeSwapV2Router.WETH());

        pancakeSwapV2Router = _pancakeSwapV2Router;
		
		_setAutomatedMarketMakerPair(pancakeSwapV2Pair, true);
		
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
		
		_isWhiteListed[owner()] = true;
		
		liquidityFee.push(300);
		liquidityFee.push(300);
		liquidityFee.push(0);
		
		marketingFee.push(300);
		marketingFee.push(300);
		marketingFee.push(0);
		
		reflectionFee.push(200);
		reflectionFee.push(200);
		reflectionFee.push(0);
		
		latestBuyerFee.push(0);
		latestBuyerFee.push(800);
		latestBuyerFee.push(0);
		
        emit Transfer(address(0), _msgSender(), _tTotal);
    }
	
	receive() external payable {}
	
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
        if (_isExcludedFromReward[account]) return _tOwned[account];
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

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcludedFromReward[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
	
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcludedFromReward[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcludedFromReward[account] = true;
        _excluded.push(account);
    }
	
    function includeInReward(address account) external onlyOwner() {
        require(_isExcludedFromReward[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcludedFromReward[account] = false;
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
	
    function setLiquidityFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(marketingFee[0].add(reflectionFee[0]).add(latestBuyerFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(marketingFee[1].add(reflectionFee[1]).add(latestBuyerFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(marketingFee[2].add(reflectionFee[2]).add(latestBuyerFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		liquidityFee[0] = buy;
		liquidityFee[1] = sell;
		liquidityFee[2] = p2p;
	}
	
	function setMarketingFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
		require(liquidityFee[0].add(reflectionFee[0]).add(latestBuyerFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(liquidityFee[1].add(reflectionFee[1]).add(latestBuyerFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(liquidityFee[2].add(reflectionFee[2]).add(latestBuyerFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		marketingFee[0] = buy;
		marketingFee[1] = sell;
		marketingFee[2] = p2p;
	}
	
	function setReflectionFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
		require(liquidityFee[0].add(marketingFee[0]).add(latestBuyerFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(liquidityFee[1].add(marketingFee[1]).add(latestBuyerFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(liquidityFee[2].add(marketingFee[2]).add(latestBuyerFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		reflectionFee[0] = buy;
		reflectionFee[1] = sell;
		reflectionFee[2] = p2p;
	}
	
	function setLatestBuyerFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(liquidityFee[0].add(marketingFee[0]).add(reflectionFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(liquidityFee[1].add(marketingFee[1]).add(reflectionFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(liquidityFee[2].add(marketingFee[2]).add(reflectionFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		latestBuyerFee[0] = buy;
		latestBuyerFee[1] = sell;
		latestBuyerFee[2] = p2p;
	}
	
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
	
	function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != pancakeSwapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }
	
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(_automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        _automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }
	
	function whiteListAddress(address _address) external onlyOwner{
	   _isWhiteListed[_address] = true;
	   emit AddToWhiteList(_address);
    }
	
	function removeWhiteListAddress (address _address) external onlyOwner{
	   _isWhiteListed[_address] = false;
	   emit RemovedFromWhiteList(_address);
	}
	
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tMarketing) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tMarketing, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity, tMarketing);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
        uint256 tFee = calculateReflectionFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tMarketing = calculateMarketingFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity).sub(tMarketing);
        return (tTransferAmount, tFee, tLiquidity, tMarketing);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 tMarketing, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rMarketing = tMarketing.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(rMarketing);
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
        if(_isExcludedFromReward[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
	
    function _takeMarketing(uint256 tMarketing) private {
        uint256 currentRate =  _getRate();
        uint256 rMarketing = tMarketing.mul(currentRate);
        _rOwned[marketingWalletAddress] = _rOwned[marketingWalletAddress].add(rMarketing);
        if(_isExcludedFromReward[marketingWalletAddress])
            _tOwned[marketingWalletAddress] = _tOwned[marketingWalletAddress].add(tMarketing);
    }
	
	function setMarketingWalletAddress(address _marketingWalletAddress) external onlyOwner{
	   require(_marketingWalletAddress != address(0), "Zero address");
	   marketingWalletAddress = _marketingWalletAddress;
    }
	
	function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
  	     require(amount <= totalSupply(), "Amount cannot be over the total supply.");
		 numTokensSellToAddToLiquidity = amount;
  	}
	
	function _takeBuyerFee(uint256 buyerShare, address buyer) private {
		uint256 currentRate =  _getRate();
		uint256 rbuyerShare = buyerShare.mul(currentRate);
		_rOwned[buyer] = _rOwned[buyer].add(rbuyerShare);
		if(_isExcludedFromReward[buyer])
			_tOwned[buyer] = _tOwned[buyer].add(buyerShare);
	}

    function calculateReflectionFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_reflectionFee).div(10**4);
    }

    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_marketingFee).div(10**4);
    }
	
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(10**4);
    }
	
	function calculateLatestBuyerFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_latestBuyerFee).div(10**4);
    }
	
    function removeAllFee() private {
       _reflectionFee = 0;
       _marketingFee = 0;
       _liquidityFee = 0;
	   _latestBuyerFee = 0;
    }
	
    function applyBuyFee() private {
	   _reflectionFee = reflectionFee[0];
       _marketingFee = marketingFee[0];
       _liquidityFee = liquidityFee[0];
	   _latestBuyerFee = latestBuyerFee[0];
    }
	
	function applySellFee() private {
	   _reflectionFee = reflectionFee[1];
       _marketingFee = marketingFee[1];
       _liquidityFee = liquidityFee[1];
	   _latestBuyerFee = latestBuyerFee[1];
    }
	
	function applyP2PFee() private {
	   _reflectionFee = reflectionFee[2];
       _marketingFee = marketingFee[2];
       _liquidityFee = liquidityFee[2];
	   _latestBuyerFee = latestBuyerFee[2];
    }
	
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
		
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
		if(paused) 
		{
		    require(_isWhiteListed[from], "Sender not whitelist to transfer");
		}
		
        uint256 contractTokenBalance = balanceOf(address(this));
		
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (overMinTokenBalance && !inSwapAndLiquify && _automatedMarketMakerPairs[to] && swapAndLiquifyEnabled) 
		{
            contractTokenBalance = numTokensSellToAddToLiquidity;
            swapAndLiquify(contractTokenBalance);
        }
		
        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
		
        _tokenTransfer(from,to,amount,takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = address(this).balance;

        swapTokensForBNB(half);
        uint256 newBalance = address(this).balance.sub(initialBalance);
        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }
	
    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeSwapV2Router.WETH();

        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);

        pancakeSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);
		
        pancakeSwapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }
	
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
		if(!takeFee) 
		{
		    removeAllFee();
		}
		else if(!_automatedMarketMakerPairs[sender] && !_automatedMarketMakerPairs[recipient])
		{
			applyP2PFee();
		}
		else if(_automatedMarketMakerPairs[recipient])
		{
		    applySellFee();
		}
		else
		{
		    applyBuyFee();
		}
		
		if(_automatedMarketMakerPairs[recipient]) 
		{
		   for (uint256 i = 0; i < _latestBuyer.length; i++) 
		   {
			  if (_latestBuyer[i] == sender)
			  {
				 removeBuyer(i);
			  }
		   }
		}
		
		uint256 tLatestBuyerFee = calculateLatestBuyerFee(amount);
		if(tLatestBuyerFee > 0) 
		{
		    if(_latestBuyer.length > 0)
			{
			    uint256 buyerShare = tLatestBuyerFee / _latestBuyer.length;
				for (uint256 i = 0; i < _latestBuyer.length; i++) 
				{
			        _takeBuyerFee(buyerShare, _latestBuyer[i]);
				}
			}
			else
			{
			    _takeBuyerFee(tLatestBuyerFee, address(this));
			}
		}
		
		if(_automatedMarketMakerPairs[sender]) 
		{
		   if(exists(recipient)) 
		   {
		       for (uint256 i = 0; i < _latestBuyer.length; i++) 
			   {
				  if (_latestBuyer[i] == recipient)
				  {
					  removeBuyer(i);
				  }
			   }
			   _latestBuyer.push(recipient);
		   } 
		   else
		   {
		       if(_latestBuyer.length >= 10)
			   {
			      removeBuyer(0);
				  _latestBuyer.push(recipient);
			   }
			   else
			   {
			      _latestBuyer.push(recipient);
			   }
		   }
		}
		
        if (_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) 
		{
            _transferFromExcluded(sender, recipient, amount.sub(tLatestBuyerFee));
        } 
		else if (!_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) 
		{
            _transferToExcluded(sender, recipient, amount.sub(tLatestBuyerFee));
        } 
		else if (!_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) 
		{
            _transferStandard(sender, recipient, amount.sub(tLatestBuyerFee));
        } 
		else if (_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) 
		{
            _transferBothExcluded(sender, recipient, amount.sub(tLatestBuyerFee));
        } 
		else {
            _transferStandard(sender, recipient, amount.sub(tLatestBuyerFee));
        }
		
        applyBuyFee();
    }
	
	function removeBuyer(uint256 index) internal 
	{
        for (uint i = index; i < _latestBuyer.length - 1; i++) 
		{
            _latestBuyer[i] = _latestBuyer[i+1];
        }
        _latestBuyer.pop();
    }
	
	function exists(address recipient) public view returns (bool) {
		for (uint i = 0; i < _latestBuyer.length; i++) {
			if (_latestBuyer[i] == recipient) {
				return true;
			}
		}
		return false;
	}
	
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tMarketing) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeMarketing(tMarketing);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tMarketing) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        _takeMarketing(tMarketing);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tMarketing) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _takeMarketing(tMarketing);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
	
	function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tMarketing) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _takeMarketing(tMarketing);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}