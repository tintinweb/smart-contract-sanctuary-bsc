/**
 *Submitted for verification at BscScan.com on 2022-10-22
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

interface IPool {
    function addTotalTxFee(uint256 fee) external;
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

contract MDS is IERC20, Ownable {

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;

    IPancakeRouter02 internal uniswapV2Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IERC20 private c_usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    address public pair;
    address public pool;
    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;
    mapping (address => bool) public isExcludedFromFees;

    constructor() public {
        address _pair = pairFor(uniswapV2Router.factory(), address(this), address(c_usdt));
        pair = _pair;

        uint256 total = 10**26;
        _balances[msg.sender] = total;
        _totalSupply = total;
        emit Transfer(address(0), msg.sender, total);
    }

    function name() public pure returns (string memory) {
        return "MDS";
    }

    function symbol() public pure returns (string memory) {
        return "MDS";
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
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

        if(isExcludedFromFees[sender] || isExcludedFromFees[recipient]) {
            receiveAmount(sender, recipient, amount);
            return;
        }

        address _pair = pair;
        if(sender != _pair && recipient != _pair) {
            receiveAmount(sender, recipient, amount);
            return;
        }

        if(recipient == _pair) {
            address _pool = pool;
            if( _pool != address(0) ) {
                uint256 fee = 8*amount/100;
                receiveAmount(sender, pool, fee);
                receiveAmount(sender, recipient, amount - fee);
                IPool(_pool).addTotalTxFee(fee);
            }else {
                receiveAmount(sender, recipient, amount);
            }
            return;
        }

        require(recipient == pool, "ERC20: only pool can buy");
        senderBalance = amount/2;
        receiveAmount(sender, deadAddress, senderBalance);
        receiveAmount(sender, recipient, amount - senderBalance);
    }

    function receiveAmount(address sender, address recipient, uint256 amount) private {
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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

    function setPool(address _pool) external onlyOwner {
        pool = _pool;
    }

    function setExcludeFee(address a, bool b) external onlyOwner {
        isExcludedFromFees[a] = b;
    }
}

interface IPancakeRouter02 {
    function factory() external pure returns (address);
}