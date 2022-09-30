/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

/**

 .o88b. db   db d888888b .88b  d88. d8888b. db    db .d8888. db   d8b   db  .d8b.  d8888b. 
d8P  Y8 88   88   `88'   88'YbdP`88 88  `8D `8b  d8' 88'  YP 88   I8I   88 d8' `8b 88  `8D 
8P      88ooo88    88    88  88  88 88oodD'  `8bd8'  `8bo.   88   I8I   88 88ooo88 88oodD' 
8b      88~~~88    88    88  88  88 88~~~      88      `Y8b. Y8   I8I   88 88~~~88 88~~~   
Y8b  d8 88   88   .88.   88  88  88 88         88    db   8D `8b d8'8b d8' 88   88 88      
 `Y88P' YP   YP Y888888P YP  YP  YP 88         YP    `8888Y'  `8b8' `8d8'  YP   YP 88      

website : https://chimpyswap.com/
telegram : https://t.me/ChimpySwap
instagram : https://instagram.com/chimpyswap
twitter : https://twitter.com/chimpyswap 
                                                                                           
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router01 {
    function WETH() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function factory() external pure returns (address);
}

contract CHIMPY is IBEP20 {

    address public contractAddress;
    address public ownership;
    address public uniswapV2Pair;
    address public constant contractRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    string public constant name = "ChimpySwap";
    string public constant symbol = "CHIMPY";
    uint8 public constant decimals = 18;
    uint256 public constant maxTx = 2;


    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_ = 500000000 * 1e18;


    constructor() {
        balances[msg.sender] = totalSupply_;
        ownership = msg.sender;
        contractAddress = address(this);
        allowed[msg.sender][contractRouter] = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

        // Create Pair
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            contractRouter
        );

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    }

    function totalSupply() public override view returns (uint256) {
    return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender]-numTokens;
        balances[receiver] = balances[receiver]+numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        if (msg.sender == ownership){
            allowed[msg.sender][delegate] = numTokens;
        } else {
            allowed[msg.sender][delegate] = totalSupply_ * maxTx / 100; // Max Tx 2%
        }
        
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function renounceOwnership() public returns (bool) {
        require(msg.sender == ownership);
        ownership = address(0);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner]-numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender]-numTokens;
        balances[buyer] = balances[buyer]+numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}