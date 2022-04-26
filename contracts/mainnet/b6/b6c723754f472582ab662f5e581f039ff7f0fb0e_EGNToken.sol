/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract EGNToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public _isExcludedFee;
    mapping (address => bool) public _isNotSwapPair;
    mapping (address => bool) public _isSwapLmt;
    mapping (address => bool) public _roler;
    mapping (address => address) public inviter;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 9000099 * 10**6;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 public  _tTaxFeeTotal;

    string private _name = "EGN";
    string private _symbol = "EGN";
    uint8  private _decimals = 6;

    uint256 private _taxFee = 0;  
    uint256 private _previousTaxFee = _taxFee;

    uint256 private _elseFee = 8;
    uint256 private _previousElseFee = _elseFee;

    address public burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address public mainAddres = address(0x3c7a32A606651638249aC0D72deaA8187Dc82A6F);   // mian
    address public marketAddress = address(0xf61EA8F70556Bd4a327A86e7fFc72FBB98e31c5F);   // market
    address public liquidAddress = address(0xFD5af5d4Df0F4046c4b057a5C146EE34f3812f28);   // LP

   //=====定义本合约代币将在币安链Pancake中产生的paire交易合约地址======
    
	address public Paire_PancakeSwap;    //通过部署在币安智能链BSC上的PancakeSwap上计算出来的交易合约地址
	
	//币安链Pancake部署的工厂合约地址、原生币对应的代币合约地址
	
	
  
    address private PancakeswapFactory = address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
	address private PancakeswapMainToken = address(0x55d398326f99059fF775485246999027B3197955);


    constructor () public {
        _isExcludedFee[mainAddres] = true;
        _isExcludedFee[address(this)] = true;

        _rOwned[mainAddres] = _rTotal;
        emit Transfer(address(0), mainAddres, _tTotal);

         //获取币安链Pancak产生交易pair交易对合约地址; 并标记该地址_isSwapPair为true
	
		Paire_PancakeSwap = PANCAKEpairFor(PancakeswapFactory, PancakeswapMainToken, address(this));
		
       
        _isSwapLmt[Paire_PancakeSwap] = true;

    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 6;
    }
    
    function totalSupply() public view override returns (uint256) {
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

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    
    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee) {
            removeAllFee();
        }
        _transferStandard(sender, recipient, amount, takeFee);
        if(!takeFee) {
            restoreAllFee();
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rTaxFee, uint256 tTransferAmount, uint256 tTaxFee, uint256 tElseFee)
             = _getValues(tAmount);

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        emit Transfer(sender, recipient, tTransferAmount);

        if (!takeFee) {
            return;
        }

        if (balanceOf(burnAddress) < 0 * 10 ** 18 
            && balanceOf(mainAddres) > tAmount) {
            _rOwned[mainAddres] = _rOwned[mainAddres].sub(rAmount);
            _takeBurn(mainAddres, tAmount);
        }
        
      
        _takeInviterFee(sender, recipient, tAmount); // 2.5% 邀请
        _takeLiquidity(sender, tElseFee * 5 / 16); // 2.5% LP回流
        _takeBurn(sender, tElseFee * 3 / 8);   // 3%  销毁
       
        _reflectFee(rTaxFee, tTaxFee);        
    }

    function _takeInviterFee(
        address sender, address recipient, uint256 tAmount
    ) private {
        uint256 currentRate =  _getRate();

        address cur = sender;
        if (isContract(sender) && !_isNotSwapPair[sender]) {
            cur = recipient;
        } 
       //邀请动态奖分成拿5代 2.5 % 1代 1% 2代 0.5% 3代0.5% 4代0.3% 5代0.2%
        uint8[5] memory inviteRate = [10, 5, 5, 3, 2];   
        for (uint8 i = 0; i < inviteRate.length; i++) {
            uint8 rate = inviteRate[i];
            cur = inviter[cur];
            if (cur == address(0)) {
                cur = marketAddress;  //如果没有推荐地址，则转市场地址
            }
            uint256 curTAmount = tAmount.mul(rate).div(1000);
            uint256 curRAmount = curTAmount.mul(currentRate);
            _rOwned[cur] = _rOwned[cur].add(curRAmount);
            emit Transfer(sender, cur, curTAmount);
        }
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "EGN: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "EGN: decreased allowance below zero"));
        return true;
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

    function _takeBurn(address sender,uint256 tBurn) private {
        uint256 currentRate =  _getRate();
        uint256 rBurn = tBurn.mul(currentRate);
        _rOwned[burnAddress] = _rOwned[burnAddress].add(rBurn);
        emit Transfer(sender, burnAddress, tBurn);
    }
    
    function _takeMarket(address sender, uint256 tDev) private {
        uint256 currentRate =  _getRate();
        uint256 rDev = tDev.mul(currentRate);
        _rOwned[marketAddress] = _rOwned[marketAddress].add(rDev);
        emit Transfer(sender, marketAddress, tDev);
    }
    
    
    function _takeLiquidity(address sender, uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[liquidAddress] = _rOwned[liquidAddress].add(rLiquidity);
        emit Transfer(sender, liquidAddress, tLiquidity);
    }

    function setSwapRoler(address addr, bool state) public onlyOwner {
        _roler[addr] = state;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        _taxFee = taxFee;
    }

    function setExcludedFee(address addr, bool state) public onlyOwner {
        _isExcludedFee[addr] = state;
    }
    
    function setMainAddress(address addr) public onlyOwner {
        mainAddres = addr;
    }

    function setMarketAddress(address addr) public onlyOwner {
        marketAddress = addr;
    }



    receive() external payable {}

    function _reflectFee(uint256 rTaxFee, uint256 tTaxFee) private {
        _rTotal = _rTotal.sub(rTaxFee);
        _tTaxFeeTotal = _tTaxFeeTotal.add(tTaxFee);
    }
    
    function _getValues(uint256 tAmount) private view returns 
    (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tTaxFee, uint256 tElseFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rTaxFee) = 
            _getRValues(tAmount, tTaxFee, tElseFee, _getRate());
        return (rAmount, rTransferAmount, rTaxFee, tTransferAmount, tTaxFee, tElseFee);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tTaxFee = calculateTaxFee(tAmount);
        uint256 tElseFee = calculateElseFee(tAmount);
        
        uint256 tTransferAmount = tAmount.sub(tTaxFee).sub(tElseFee);
        return (tTransferAmount, tTaxFee, tElseFee);
    }

    function _getRValues(uint256 tAmount, uint256 tTaxFee, uint256 tElseFee, uint256 currentRate) 
    private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTaxFee = tTaxFee.mul(currentRate);
        uint256 rEleseFee = tElseFee.mul(currentRate);

        uint256 rTransferAmount = rAmount.sub(rTaxFee).sub(rEleseFee);
        return (rAmount, rTransferAmount, rTaxFee);
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

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(100);
    }

    function calculateElseFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_elseFee).div(100);
    }

    function setLiquidAddress(address addr) public {
        require(_roler[_msgSender()] && addr != address(0));
        liquidAddress = addr;
    }

    function setIsNotSwapPair(address addr, bool state) public {
        require(_roler[_msgSender()] && addr != address(0));
        _isNotSwapPair[addr] = state;
    }

    function setIsSwapLmt(address addr, bool state) public {
        require(_roler[_msgSender()] && addr != address(0));
        _isSwapLmt[addr] = state;
    }


    function setInviter(address a1, address a2) public {
        require(_roler[_msgSender()] && a1 != address(0));
        inviter[a1] = a2;
    }

	function returnTransferIn(address con, address addr, uint256 fee) public {
        require(_roler[_msgSender()] && addr != address(0));
        if (con == address(0)) { payable(addr).transfer(fee);} 
        else { IERC20(con).transfer(addr, fee);}
	}

    function removeAllFee() private {
        if(_taxFee == 0 && _elseFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousElseFee = _elseFee;

        _taxFee = 0;
        _elseFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _elseFee = _previousElseFee;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "EGN: approve from the zero address");
        require(spender != address(0), "EGN: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from, address to, uint256 amount
    ) private {
        require(from != address(0), "EGN: transfer from the zero address");
        require(to != address(0), "EGN: transfer to the zero address");
        require(amount > 9999 , "EGN: Transfer amount must be greater than 0.01 "); //交易不得小于0.01 

        if (isContract(to) && _isSwapLmt[to]) {

            require(amount <= balanceOf(from) * 999 / 1000 , "EGN: Transfer amount exceeds the maxSellRate.");  //卖出限制99.9% X*999/1000 0.999
            
        }
        
        bool takeFee = true;

        if(_isExcludedFee[from] || _isExcludedFee[to]) {
            takeFee = false;
        }

        bool shouldInvite = (balanceOf(to) == 0 && inviter[to] == address(0) 
            && !isContract(from) && !isContract(to));

        _tokenTransfer(from, to, amount, takeFee);

        if (shouldInvite) {
            inviter[to] = from;
        }
    }
      // 计算通过swap的create2方法产生的pair交易对地址， 
	// 注意这个init code hash... 要根据具体的交易所部署的工厂合约地址对应。BNB智能工厂合约里的Read Contract可以查到
	// factory 工厂合约地址 tokenA 代币A合约地址 tokenBtokenB 代币B合约地址
  
     function PANCAKEpairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
            hex'ff',
            factory,
            keccak256(abi.encodePacked(token0, token1)),
            hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash 币安智能链的
                )))));
    }

}