//SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./Address.sol";
import "./Ownable.sol";
import "./IUniswapV2Router02.sol";

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address receiver, uint256 amount) external;

    function sell(uint256 amount) external returns(bool);
}

contract myToken is IERC20, ReentrancyGuard, Ownable {

    // Token data
    string constant _name = "BSCtrader Token";
    string constant _symbol = "BTOKEN";
    uint8 private constant _decimals = 18;
    
    // 1 initial supply
    uint256 private _totalSupply = 10**18; 

    // Contract deployer is owner
    address public owner;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    // Initialize Pancakeswap Router
    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public usdc = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;

    // Events
    event Transfer(address from, address to, uint amount);
    event Approval(address owner, address spender, uint256 value);
    event SentUSDCBackToContract(address owner, address spender, uint256 value);

    // Contract functions
    function totalSupply() external view override returns (uint256) { return _totalSupply; }

    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }

    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function name() public pure override returns (string memory) {return _name;}

    function symbol() public pure override returns (string memory) {return _symbol;}

    function decimals() public pure override returns (uint8) {return _decimals;}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function swapForUSDC(address receiver, uint256 amount) internal {
        
        // how many Tokens did we have in this contract already
        uint256 initalTokenBalance = IERC20(usdc).balanceOf(address(this));
        
        // Uniswap Pair Path for BNB -> Token
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = usdc;
        
        // Swap BNB for Token
        uniswapV2Router.swapExactETHForTokens{value: amount}(
            0, // accept as many tokens as we can
            path,
            address(this), // Send To Recipient
            block.timestamp + 300
        );
        
        // how many tokens did we just purchase?
        uint256 balance = IERC20(usdc).balanceOf(address(this));
        uint256 tokensPurchased = balance - initalTokenBalance;
        
        // Mint the tokens
        mint(receiver, tokensPurchased);

        emit SentUSDCBackToContract(usdc, address(this), amount);
    }

    // Mint tokens to an address
    function mint(address receiver, uint256 amount) internal {
        _balances[receiver] += amount;
        _totalSupply += amount;
        emit Transfer(address(this), receiver, amount);
    }
    
    function purchase(address receiver, uint256 amount) internal returns (bool) {
        // revert if if not larger than 0
        if (amount < 0) {
            revert('Cant buy 0 tokens');
        }
        swapForUSDC(receiver, amount);
        return true;
    }

    function sell(uint256 amount) public nonReentrant returns (bool) { 
        address seller = msg.sender;
            
        // Check if seller has sufficent balance
        require(_balances[seller] >= amount, 'Insuficcent balance');

        address[] memory path = new address[](2);
        path[0] = usdc;
        path[1] = uniswapV2Router.WETH();

        //Swap usdc for bnb and send to seller
        uniswapV2Router.swapExactTokensForETH(
            amount,
            0, // accept as many tokens as we can
            path,
            seller, // Send To Recipient
            block.timestamp + 300
        );

        burn(seller, amount);

        emit Transfer(seller, address(this), amount);
        return true;
    }

    function burn(address target, uint256 amount) internal {
        _balances[target] -= amount;
        _totalSupply -= amount;
        emit Transfer(address(this), target, amount);
    }   

    function transfer(address receiver, uint amount) public {
        require(amount <= _balances[msg.sender], "Insufficient Balance");
        _balances[msg.sender] -= amount;
        _balances[receiver] += amount;
        emit Transfer(msg.sender, receiver, amount);
    }

    receive() external payable {
        address receiver = msg.sender;
        uint256 amount = msg.value;
        purchase(receiver, amount);
    }
}