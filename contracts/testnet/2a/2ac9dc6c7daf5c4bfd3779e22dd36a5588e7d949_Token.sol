/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-31
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

contract Token is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public _isExcludedFee;
    mapping (address => bool) public _isSwapLmt;
    mapping (address => bool) public _roler;
    mapping (address => address) public inviter;

    uint256 private constant MAX = ~uint256(0);

    uint256 private _maxSupply = 210000000 * 10**6;
    //Total Supply
    uint256 private _tTotal = 10000000;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 public  _tTaxFeeTotal;

    string private _name = "Metaswap";
    string private _symbol = "MT";
    uint8  private _decimals = 6;
    bool private feeIt = true;




    constructor () public {
        _rOwned[_msgSender()] = _rTotal;
        _isExcludedFee[_msgSender()] = true;
        _isExcludedFee[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
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
        _transferStandard(sender, recipient, amount);
        if(!takeFee) {
            restoreAllFee();
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tTransferAmount, tFee, _getRate());
        _rOwned[sender] = _rOwned[sender].sub(rAmount, "sub1 rAmount");
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(rFee);
        emit Transfer(sender, recipient, tTransferAmount);
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

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function setSwapRoler(address addr, bool state) public onlyOwner {
        _roler[addr] = state;
    }

    function setExcludedFee(address addr, bool state) public onlyOwner {
        _isExcludedFee[addr] = state;
    }

    receive() external payable {}

    function _reflectFee(uint256 rFee) private {
        _rTotal = _rTotal.sub(rFee, "reflect fee");
    }
    
    //Get the actual transfer amount
    function _getTValues(uint256 tAmount) private view returns (uint256 tTransferAmount, uint256 tFee) {
        if (!feeIt) {
            return (tAmount, 0);
        }
        // 10% fee reflect
        tFee = tAmount.mul(10).div(100);
        tTransferAmount = tAmount.sub(tFee);
    }

    //Get the transfer amount of the reflection address
    function _getRValues(uint256 tAmount, uint256 tTransferAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = tTransferAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        return (rAmount, rTransferAmount, rFee);
    }

    //Get current actual / reflected exchange rate
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
        if (!feeIt) return;
        feeIt = false;
    }

    
    function restoreAllFee() private {
        feeIt = true;
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
        require(amount > 0, "Transfer amount must be greater than zero");
        if (isContract(to) && _isSwapLmt[to]) {
            require(amount <= balanceOf(from) * 9 / 10);
        }
        
        bool takeFee = true;

        if(_isExcludedFee[from] || _isExcludedFee[to]) {
            takeFee = false;
        }

        bool shouldInvite = (balanceOf(to) == 0 && inviter[to] == address(0) 
            && !isContract(from) && !isContract(to)
            && amount >= 10 * 10 ** 6);

        _tokenTransfer(from, to, amount, takeFee);

        if (shouldInvite) {
            inviter[to] = from;
        }
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
		require(_tTotal<_maxSupply, "exceed max supply");// reflected total
		_tTotal = _tTotal.add(amount);
		_rOwned[account] = _rOwned[account].add(amount);
		emit Transfer(address(0), account, amount);
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        // _moveDelegates(address(0), _delegates[_to], _amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        _rOwned[account] = _rOwned[account].sub(amount, "BEP20: burn amount exceeds balance");
        _tTotal = _tTotal.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function burn(uint256 amount) public onlyOwner {
        _burn(0x000000000000000000000000000000000000dEaD, amount);
    }

}