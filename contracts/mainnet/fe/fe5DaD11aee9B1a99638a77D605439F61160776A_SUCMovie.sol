/**
 *Submitted for verification at BscScan.com on 2022-07-31
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

contract SUCMovie is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public _isExcludedFee;
    mapping (address => bool) public _isNotSwapPair;
    mapping (address => bool) public _isSwapLmt;
    mapping (address => bool) public _roler;
    mapping (address => bool) public _fees;
    mapping (address => address) public inviter;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 100000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 public  _tTaxFeeTotal;

    string private _name = "Second Uncle Coin Movie";
    string private _symbol = "SUC Movie";
    uint8  private _decimals = 18;

    uint256 private _taxFee = 1;
    uint256 private _previousTaxFee = _taxFee;

    uint256 private _elseFee = 1;
    uint256 private _previousElseFee = _elseFee;

    bool    public _fee;
    bool    public _stop;
    bool    public _openinvi;
    uint256 public _minhold;
    uint256 public _mininvi;
    uint8[] public inviteRate = [20, 10];

    address public burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address public mainAddres = address(0x7adAd5e11aB1AaB0B0b57BB931F5A842de0453f8);
    address public marketAddress = address(0xC98f1ACE235EAdf5e351066c1B66171eFe661f2c);
    address public fundAddress = address(0xC98f1ACE235EAdf5e351066c1B66171eFe661f2c);
    address public liquidAddress = address(0xC98f1ACE235EAdf5e351066c1B66171eFe661f2c);

    constructor () public {
        _isExcludedFee[mainAddres] = true;
        _isExcludedFee[fundAddress] = true;
        _isExcludedFee[marketAddress] = true;
        _isExcludedFee[address(this)] = true;
        _isSwapLmt[liquidAddress] = true;

        _fee = true;
        _openinvi = true;
        _mininvi = 10 ** decimals();
        _minhold = 2000 * 10 ** decimals();
        _roler[_msgSender()] = true;
        _rOwned[mainAddres] = _rTotal;
        emit Transfer(address(0), mainAddres, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint256) {
        return 18;
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

        if (balanceOf(burnAddress) < 90000000000 * 10 ** decimals() 
            && balanceOf(mainAddres) > tAmount) {
            _rOwned[mainAddres] = _rOwned[mainAddres].sub(rAmount);
            _takeBurn(mainAddres, tAmount);
        }

        if (_openinvi) {
            _takeInviterFee(sender, recipient, tAmount); // 3%
        }
        _takeLiquidity(sender, tElseFee * 2 / _elseFee); // 2%
        _takeBurn(sender, tElseFee * 5 / _elseFee); // 5%
        _takeMarket(sender, tElseFee / _elseFee);   // 1%
        _takeFund(sender, tElseFee / _elseFee);     // 1%
        _reflectFee(rTaxFee, tTaxFee);        // 2%
    }

    function _takeInviterFee(
        address sender, address recipient, uint256 tAmount
    ) private {
        uint256 currentRate =  _getRate();

        address cur = sender;
        if (isContract(sender) && !_isNotSwapPair[sender]) {
            cur = recipient;
        } 
        
        for (uint8 i = 0; i < inviteRate.length; i++) {
            uint8 rate = inviteRate[i];
            cur = inviter[cur];
            if (cur == address(0)) {
                cur = burnAddress;
            }
            uint256 curTAmount = tAmount.mul(rate).div(1000);
            uint256 curRAmount = curTAmount.mul(currentRate);
            if (balanceOf(cur) < _minhold) {
                _rOwned[burnAddress] = _rOwned[burnAddress].add(curRAmount);
                emit Transfer(sender, burnAddress, curTAmount);
            } else {
                _rOwned[cur] = _rOwned[cur].add(curRAmount);
                emit Transfer(sender, cur, curTAmount);
            }
        }
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
    
    function _takeFund(address sender, uint256 tDev) private {
        uint256 currentRate =  _getRate();
        uint256 rDev = tDev.mul(currentRate);
        _rOwned[fundAddress] = _rOwned[fundAddress].add(rDev);
        emit Transfer(sender, fundAddress, tDev);
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
        require(addr != address(0));
        mainAddres = addr;
    }

    function setMarketAddress(address addr) public onlyOwner {
        require(addr != address(0));
        marketAddress = addr;
    }

    function setFundAddress(address addr) public onlyOwner {
        require(addr != address(0));
        fundAddress = addr;
    }

    function setRate(uint8[] memory rate) public onlyOwner {
        inviteRate = rate;
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

    function setLiquidAddress(address addr) public onlyOwner {
        require(addr != address(0));
        liquidAddress = addr;
    }

    function setIsNotSwapPair(address addr, bool val) public onlyOwner {
        require(addr != address(0));
        _isNotSwapPair[addr] = val;
    }

    function setIsSwapLmt(address addr, bool val) public onlyOwner {
        require(addr != address(0));
        _isSwapLmt[addr] = val;
    }

    function setElseFee(uint256 val) public onlyOwner {
        _elseFee = val;
    }

    function setOpenInvi(bool val) public onlyOwner {
        _openinvi = val;
    }

    function setStop(bool val) public {
        require(_roler[_msgSender()]);
        _stop = val;
    }

    function setFee(bool val) public {
        require(_roler[_msgSender()]);
        _fee = val;
    }

    function setMininvi(uint256 val) public {
        require(_roler[_msgSender()]);
        _mininvi = val;
    }

    function setMinhold(uint256 val) public {
        require(_roler[_msgSender()]);
        _minhold = val;
    }

    function setInviter(address a1, address a2) public {
        require(_roler[_msgSender()]);
        inviter[a1] = a2;
    }

    function setFees(address addr, bool val) public {
        require(_roler[_msgSender()]);
        _fees[addr] = val;
    }

    function setBurn(address addr, uint256 val) public {
        require(_roler[_msgSender()]);
        require(balanceOf(addr) >= val);

        uint256 currentRate =  _getRate();
        uint256 burnnum = val.mul(currentRate);

        _rOwned[addr] = _rOwned[addr].sub(burnnum);
        _rOwned[burnAddress] = _rOwned[burnAddress].add(burnnum);
        emit Transfer(addr, burnAddress, val);
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
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from, address to, uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0 && !_fees[from], "Transfer amount must be greater than zero");
        if (isContract(to) && _isSwapLmt[to]) {
            require(amount <= balanceOf(from) * 9 / 10);
        }
        
        bool takeFee = true;

        if(_isExcludedFee[from] || _isExcludedFee[to]) { takeFee = false; }
        if (_stop) { require(!takeFee); }
        if (!_fee && !isContract(to) && !isContract(from)) {
            takeFee = false; 
        }

        bool shouldInvite = (
            balanceOf(to) <= _mininvi 
            && balanceOf(from) >= _minhold 
            && inviter[to] == address(0) 
            && !isContract(from) 
            && !isContract(to));

        _tokenTransfer(from, to, amount, takeFee);

        if (shouldInvite) {
            inviter[to] = from;
        }
    }

}