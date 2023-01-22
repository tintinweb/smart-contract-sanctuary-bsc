/**
 *Submitted for verification at BscScan.com on 2023-01-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-13
*/

pragma solidity 0.8.13;
// SPDX-License-Identifier: UNLICENSED

interface IERC20 {
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

interface PancakeSwapFactoryV2 {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface PancakeSwapRouterV2 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Empireum is Ownable {
    string public name = "Empireum Token";
    string public symbol = "ETOM";
    uint256 public totalSupply = 20000000000e18;
    uint8 public decimals = 18;
    uint256 public deadBlocks = 5;
    bool public isTradingEnabled = false;
    uint256 private startBlock;
    uint256 public startPrice = 7e15;
    bool public antibot = true;
    uint256 public fee = 2;
    uint256 public blockTimeout = 10;
    uint256 public maxTxAmount = 2000000e18;
    PancakeSwapRouterV2 private _pancakeRouterV2 = PancakeSwapRouterV2(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
    address public _dead = 0x000000000000000000000000000000000000dEaD;
    IERC20 private _busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 
    address public pair;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public isWhitelisted;
    mapping(address => bool) public isDisabledFee;
    mapping(address => uint256) public lastTransfer;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        isWhitelisted[msg.sender] = true;
        isWhitelisted[address(this)] = true;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function _burn(address _from, uint256 _amount) internal returns (bool success) {
        balanceOf[_from] -= _amount;
        balanceOf[_dead] += _amount;
        emit Transfer(_from, _dead, _amount);
        return true;
    }

    function _beforeTransfer(address _from, address _to, uint256 _value) internal returns (uint256 _newValue) {
        if (!isWhitelisted[_from] && !isWhitelisted[_to]) {
            require(isTradingEnabled, "Trading is disabled");
            require(balanceOf[_from] > _value);
            require(!isBlacklisted[_from] && !isBlacklisted[_to], "Blacklisted address");
            require(_value <= maxTxAmount, "amount must be lower maxTxAmount");
            if (_from == pair) lastTransfer[_to] = block.number;
            if (_to == pair) require(lastTransfer[_from] + blockTimeout <= block.number, "not time yet");
            if (antibot) {
                if (startBlock + deadBlocks >= block.number) {
                    isBlacklisted[_to] = true;
                } else {
                    antibot = false;
                }
            }
            if(!isDisabledFee[_from]) {
                uint256 feeAmount = _value * fee / 100;
                _burn(_from, feeAmount);
                uint256 newAmount = _value - feeAmount;
                return newAmount;
            } else {
                return _value;
            }
        }
        return _value;
    }


    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
        uint256 _newValue = _beforeTransfer(_from, _to, _value);
        balanceOf[_from] -= _newValue;
        balanceOf[_to] += _newValue;
        emit Transfer(_from, _to, _newValue);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        _transfer(_from, _to, _value);
        allowance[_from][msg.sender] -= _value;
        return true;
    }

    function setDeadBlocks(uint256 _deadBlocks) public onlyOwner {
        deadBlocks = _deadBlocks;
    }

    function setisBlacklisted(address account, bool value) public onlyOwner {
        isBlacklisted[account] = value;
    }

    function setisDisabledFee(address account, bool value) public onlyOwner {
        isDisabledFee[account] = value;
    }

    function multisetisBlacklisted(address[] calldata accounts, bool value) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            isBlacklisted[accounts[i]] = value;
        }
    }

    function setisWhitelisted(address account, bool value) public onlyOwner {
        isWhitelisted[account] = value;
    }

    function setFee(uint256 value) public onlyOwner {
        require(value <= 5, "must be lower 5");
        fee = value;
    }

    function setAntibot(bool value) public onlyOwner {
        antibot = value;
    }

    function openTrade() public onlyOwner {
        require(!isTradingEnabled, "Trading is already enabled!");
        allowance[address(this)][address(_pancakeRouterV2)] = totalSupply;
        uint256 _busdAmount = _busd.balanceOf(address(this));
        _busd.approve(address(_pancakeRouterV2), ~uint256(0));
        uint256 _tokenAmount = _busdAmount / startPrice * 1e18;
        pair = PancakeSwapFactoryV2(_pancakeRouterV2.factory()).createPair(address(this), address(_busd));
        _pancakeRouterV2.addLiquidity(address(this),address(_busd),_tokenAmount,_busdAmount,_tokenAmount,_busdAmount,owner(),block.timestamp);
        IERC20(pair).approve(address(_pancakeRouterV2), ~uint256(0));
        isTradingEnabled = true;
        startBlock = block.number;
    }

    function setRouter(address newRouter) public onlyOwner returns (bool success) {
        _pancakeRouterV2 = PancakeSwapRouterV2(newRouter);
        return true;
    }

    function setBUSD(address newBusd) public onlyOwner returns (bool success) {
        _busd = IERC20(newBusd);
        return true;
    }

    function setMaxTxAmount(uint256 amount) public onlyOwner returns (bool success) {
        require(amount < totalSupply, "cant be more than totalSupply");
        require(amount > 0, "cant be zero!");
        maxTxAmount = amount;
        return true;
    }

    function setStartPrice(uint256 newPrice) public onlyOwner returns (bool success) {
        startPrice = newPrice;
        return true;
    }

    function setBlockTimeout(uint256 newBlockTimeout) public onlyOwner returns (bool success) {
        require(newBlockTimeout <= 28800, "cant be more when 1 day!");
        blockTimeout = newBlockTimeout;
        return true;
    }

    function setDead(address newDead) public onlyOwner returns (bool success) {
        _dead = newDead;
        return true;
    }

    function setPair(address newPair) public onlyOwner returns (bool success) {
        pair = newPair;
        return true;
    }
}