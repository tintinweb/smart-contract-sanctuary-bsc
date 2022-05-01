/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

pragma solidity 0.6.12;

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

contract Ownable {
    address public owner;

    constructor () public{
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract MKT is IERC20, Ownable {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;

    address public marketAddress = 0x9D2625195F0d1C46161190e014824F2a07B19BBE;

    address public pair;
    uint256 public minRefNum = 10;
    mapping (address => address) public uplines;

    mapping (address => bool) public isExcludedFromFees;
   
    constructor() public {
        uint256 total = 23600*10**6;
        _balances[msg.sender] = total;
        _totalSupply = total;
        emit Transfer(address(0), msg.sender, total);

        address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address usdt = 0x55d398326f99059fF775485246999027B3197955;
        address _pair = pairFor(IPancakeRouter(router).factory(), address(this), usdt);
        pair = _pair;
    }

    function symbol() external pure returns (string memory) {
        return "MKT";
    }

    function name() external pure returns (string memory) {
        return "MKT";
    }

    function decimals() external pure returns (uint8) {
        return 6;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;

        address _pair = pair;
        if(uplines[recipient]==address(0) && sender != _pair && sender != recipient && amount >= minRefNum) {
            uplines[recipient] = sender;
        }

        uint256 receiveAmount = amount;
        if ((sender == _pair || recipient == _pair) && !isExcludedFromFees[sender] && !isExcludedFromFees[recipient]) {
            uint256 marketAmount = amount/25;
            _balances[marketAddress] += marketAmount;
            emit Transfer(sender, marketAddress, marketAmount);
            receiveAmount -= marketAmount;

            address addr = sender;
            if(sender == _pair) {
                addr = recipient;
            }
            addr = uplines[addr];
            
            uint256 upAmount = amount/50;
            _balances[addr] += upAmount;
            emit Transfer(sender, addr, upAmount);
            receiveAmount -= upAmount;
        }

        _balances[recipient] += receiveAmount;
        emit Transfer(sender, recipient, receiveAmount);
    }

    function setPair(address _pair) external onlyOwner {
        pair = _pair;
    }
    
    function setMinRefNum(uint256 newMinRefNum) external onlyOwner {
        minRefNum = newMinRefNum;
    }

    function setExcludeFee(address a, bool b) external onlyOwner {
        isExcludedFromFees[a] = b;
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair_) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair_ = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5'
            )))));
    }
}

interface IPancakeRouter {
    function factory() external pure returns (address);
}