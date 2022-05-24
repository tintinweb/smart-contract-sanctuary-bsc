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
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract BSCtrader is IERC20, ReentrancyGuard, Ownable {

    using Address for address;

    // Token data
    string constant _name = "BSCtrader Token";
    string constant _symbol = "BTOKEN";
    uint8 private constant _decimals = 18;
    
    // 1 initial supply
    uint256 private _totalSupply = 0; 

    // Contract deployer is owner
    address public owner;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;


    // Initialize Pancakeswap Router
    address public UniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(UniswapV2Router);

    address public usdc = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;

    // Events
    event SentUSDCBackToContract(address owner, address spender, uint256 value);

    // Contract functions
    function totalSupply() external view override returns (uint256) { return _totalSupply; }

    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }

    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function name() public pure returns (string memory) {return _name;}

    function symbol() public pure returns (string memory) {return _symbol;}

    function decimals() public pure returns (uint8) {return _decimals;}

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
            address(this),
            block.timestamp + 300
        );
        
        // how many tokens did we just purchase?
        uint256 balance = IERC20(usdc).balanceOf(address(this));
        uint256 usdcPurchased = balance - initalTokenBalance;
        
        // Mint the tokens
        uint256 tokensToMint = usdcPurchased;
        mint(receiver, tokensToMint);

        emit SentUSDCBackToContract(usdc, address(this), amount);
    }

    // Mint tokens to an address
    function mint(address receiver, uint256 amount) internal {
        // Add tokens to account
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

    receive() external payable {
        address receiver = msg.sender;
        uint256 amount = msg.value;
        purchase(receiver, amount);
    }

    function sell(uint256 amountIn) public nonReentrant returns (bool) { 
        address seller = msg.sender;
            
        // Check if seller has sufficent balance
        require(_balances[seller] >= amountIn, 'Insuficcent balance');

        address[] memory path = new address[](2);
        path[0] = usdc;
        path[1] = uniswapV2Router.WETH();

        // Allow Uniswap to spend tokens
        IERC20(usdc).approve(UniswapV2Router, amountIn);

        // Get minimum amount of tokens guaranteed
        uint256[] memory amountOutMins = uniswapV2Router.getAmountsOut(amountIn, path);
        uint256 amountOutMin = amountOutMins[path.length -1];

        //Swap usdc for bnb and send to seller
        uniswapV2Router.swapExactTokensForETH(
            amountIn,
            amountOutMin, 
            path,
            seller, // Send To Recipient
            block.timestamp + 300
        );
        destroy(seller, amountIn);

        emit Transfer(seller, address(this), amountIn);
        return true;
    }

    function sellForUSDC(uint256 amountIn) public nonReentrant returns (bool) { 
        address seller = msg.sender;
            
        // Check if seller has sufficent balance
        require(_balances[seller] >= amountIn, 'Insuficcent balance');

        destroy(seller, amountIn);

    	IERC20(usdc).transfer(seller, amountIn);
        
        emit Transfer(seller, address(this), amountIn);
        return true;
    }

    // Deduct tokens from account and remove from supply
    function destroy(address target, uint256 amount) internal {
        _balances[target] -= amount;
        _totalSupply -= amount;
        emit Transfer(target, address(this), amount);
    }   

    function transfer(address recipent, uint amount) external override returns (bool) {
        require(amount <= _balances[msg.sender], "Insufficient Balance");
        _balances[msg.sender] -= amount;
        _balances[recipent] += amount;
        emit Transfer(msg.sender, recipent, amount);
        return true;
    }

    function transferFrom(address holder, address receiver, uint amount) external override returns (bool) {
        require(holder == msg.sender, "Transacting from other wallet's not allowed!");
        require(amount <= _balances[msg.sender], "Insufficient Balance");
        _balances[msg.sender] -= amount;
        _balances[receiver] += amount;
        emit Transfer(msg.sender, receiver, amount);
        return true;
    }

    // Allow owner to withdraw any token from contract, except underlying asset
    function withdraw(address tokenContract, uint256 amount) external onlyOwner {
        require(tokenContract != usdc, "Cannot withdraw USDC!");
	    IERC20(tokenContract).transfer(msg.sender, amount);
    }

    function upgradeRouter(address router) external onlyOwner {
        UniswapV2Router = router;
        uniswapV2Router = IUniswapV2Router02(UniswapV2Router);
    }
}