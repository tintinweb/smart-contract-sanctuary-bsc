/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

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

interface Token {
    function transferFrom(address, address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function transferOwnership(address newOwner) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

interface ILotteryPool {
    function setRewardToken(address _TokenAddress) external;
    function rewardToken(address recipient, uint256 amount) external;
    function random(address recipient) external view returns(uint);
}

contract BunnyJackpot is Context, IERC20, Ownable {
    

    using SafeMath for uint256;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 10000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    
    uint256 private _LotteryPoolFeeOnBuy = 8;
    uint256 private _marketingFeeOnBuy = 2;
    
    uint256 private _LotteryPoolFeeOnSell = 8;
    uint256 private _marketingFeeOnSell = 2;
    
    uint256 private _LotteryPoolFee;
    uint256 private _marketingFee;
    
    string private constant _name = "BunnyJackpot";
    string private constant _symbol = "BJ";
    uint8 private constant _decimals = 9;
    
    address payable private _marketingAddress = payable(0x77671746ece792a346676c180a06239193817129);

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    ILotteryPool LotteryPoolAddress;

    bool enableLottery = false;

    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingAddress] = true;

        emit Transfer(address(0x0000000000000000000000000000000000000000), _msgSender(), _tTotal);
    }

    function setEnableLottery(bool _enableLottery) external onlyOwner {
        enableLottery = _enableLottery;
    }
    
    function getEnableLottery() public view returns (bool) {
        return enableLottery;
    }


    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
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

    function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        _LotteryPoolFee = 0;
        _marketingFee = 0;
        
        if (from != owner() && to != owner()) {
            
            if(from == uniswapV2Pair && to != address(uniswapV2Router)) {
                _LotteryPoolFee = _LotteryPoolFeeOnBuy;
                _marketingFee = _marketingFeeOnBuy;
            }
    
            if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
                _LotteryPoolFee = _LotteryPoolFeeOnSell;
                _marketingFee = _marketingFeeOnSell;
            }
            
            if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {
                _LotteryPoolFee = 0;
                _marketingFee = 0;
            }
            
        }

        _tokenTransfer(from,to,amount);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        if (recipient == uniswapV2Pair && enableLottery && LotteryPoolAddress.random(sender) <= 3100) {
            _transferStandard(sender, recipient, amount);
            LotteryPoolAddress.rewardToken(sender,amount);
        } else if (sender == uniswapV2Pair && enableLottery && LotteryPoolAddress.random(recipient) <= 3100) {
            _transferStandard(sender, recipient, amount);
            LotteryPoolAddress.rewardToken(recipient,amount);  
        } else {
            _transferStandard(sender, recipient, amount);
        }
        

    }

    function setNewLotteryPool(address _LotteryPoolAddress) public onlyOwner() {	
        LotteryPoolAddress = ILotteryPool(_LotteryPoolAddress);
        _isExcludedFromFee[address(LotteryPoolAddress)] = true;
    }
    

    function setNewMarketingAddress(address payable markt) public onlyOwner() {
        _marketingAddress = markt;
        _isExcludedFromFee[_marketingAddress] = true;
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount); 
        _takeTeam(tTeam);
        _takeLotterypool(tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeTeam(uint256 tTeam) private {
        uint256 currentRate =  _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[_marketingAddress] = _rOwned[_marketingAddress].add(rTeam);
    }

    function _takeLotterypool(uint256 tFee) private {
        uint256 currentRate =  _getRate();
        uint256 rFee = tFee.mul(currentRate);
        _rOwned[address(LotteryPoolAddress)] = _rOwned[address(LotteryPoolAddress)].add(rFee);
    }

    receive() external payable {}
    
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getTValues(tAmount, _LotteryPoolFee, _marketingFee);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tTeam, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }

    function _getTValues(uint256 tAmount, uint256 marketingFee, uint256 LotteryPoolFee) private pure returns (uint256, uint256, uint256) {
        uint256 tFee = tAmount.mul(LotteryPoolFee).div(100);
        uint256 tTeam = tAmount.mul(marketingFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
        return (tTransferAmount, tFee, tTeam);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tTeam, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
        return (rAmount, rTransferAmount, rFee);
    }

	function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function setFee(uint256 LotteryPoolFeeOnBuy, uint256 LotteryPoolFeeOnSell, uint256 marketingFeeOnBuy, uint256 marketingFeeOnSell) public onlyOwner {
	    require(LotteryPoolFeeOnBuy < 10, "Development cannot be more than 10.");
	    require(LotteryPoolFeeOnSell < 10, "Development cannot be more than 10.");
	    require(marketingFeeOnBuy < 10, "Tax cannot be more than 10.");
	    require(marketingFeeOnSell < 10, "Tax cannot be more than 10.");
        _LotteryPoolFeeOnBuy = LotteryPoolFeeOnBuy;
        _LotteryPoolFeeOnSell = LotteryPoolFeeOnSell;
        _marketingFeeOnBuy = marketingFeeOnBuy;
        _marketingFeeOnSell = marketingFeeOnSell;
    }
    
    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }
}