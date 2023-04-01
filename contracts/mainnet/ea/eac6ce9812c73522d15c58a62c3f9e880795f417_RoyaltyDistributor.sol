/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

//SPDX-License-Identifier: MIT


pragma solidity ^0.8.19;

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


contract RoyaltyDistributor {
    address public IncineratorRoyaltyWallet;
    address public ServerMaintenanceWallet;
    address public ProjectRoyaltyWallet;
    address public tokenAddress;
    uint256 public royaltyAmount = 30;
    IUniswapV2Router02 private uniswapRouter;
    address public owner;

    constructor(address _routerAddress) {
        uniswapRouter = IUniswapV2Router02(_routerAddress);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function.");
        _;
    }

    function setWalletAddresses(
        address _incineratorWallet, 
        address _maintenanceWallet, 
        address _projectWallet
    ) external onlyOwner {
        IncineratorRoyaltyWallet = _incineratorWallet;
        ServerMaintenanceWallet = _maintenanceWallet;
        ProjectRoyaltyWallet = _projectWallet;
    }

    function rewardTimerAirdrop() public payable {
        require(
            IncineratorRoyaltyWallet != address(0) &&
            ServerMaintenanceWallet != address(0) &&
            ProjectRoyaltyWallet != address(0),
            "Wallet addresses not set"
        );

        uint256 totalBalance = address(this).balance;
        uint256 royaltyAmountInWei = (totalBalance * royaltyAmount) / 100;

        payable(IncineratorRoyaltyWallet).transfer(royaltyAmountInWei / 3);
        payable(ServerMaintenanceWallet).transfer(royaltyAmountInWei / 3);
        payable(ProjectRoyaltyWallet).transfer(royaltyAmountInWei / 3);
    }

    function withdrawFunds(address payable _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "Invalid recipient address");
        require(_amount <= address(this).balance, "Insufficient funds in the contract");

        _to.transfer(_amount);
    }

    function setRoyaltyAmount(uint256 _newRoyaltyAmount) external onlyOwner {
    royaltyAmount = _newRoyaltyAmount;
    emit RoyaltyAmountChanged(msg.sender, _newRoyaltyAmount);
}

    event RoyaltyAmountChanged(address indexed owner, uint256 indexed newRoyaltyAmount);


    function setTokenAddress(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(0), "Invalid token address");
        tokenAddress = _tokenAddress;
    }

 function buyTokens() external payable {
    require(tokenAddress != address(0), "Token address not set");
    require(msg.value >= 0.01 ether, "Minimum BNB amount not met");

    IBEP20 token = IBEP20(tokenAddress);

    // Calculate the amount of tokens that we need to receive from the router
    uint256 tokensToReceive = uniswapRouter.getAmountsOut(msg.value, getPath())[1];

    // Call the swapExactETHForTokens function of the router
    uniswapRouter.swapExactETHForTokens{ value: msg.value }(
        tokensToReceive,
        getPath(),
        address(this),
        block.timestamp + 60 * 10 // Deadline in 10 minutes
    );

    require(token.transfer(msg.sender, tokensToReceive), "Token transfer failed");
}



function getPath() private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = uniswapRouter.WETH();
    path[1] = tokenAddress;
    return path;
}


   function airdropTokens(address[] calldata _recipients, uint256[] calldata _tokenAmounts) external onlyOwner {
    require(_recipients.length == _tokenAmounts.length, "Arrays length mismatch");
    
    IBEP20 token = IBEP20(tokenAddress);
    uint256 totalTokens = token.balanceOf(address(this));
    
    for (uint i = 0; i < _recipients.length; i++) {
        require(totalTokens >= _tokenAmounts[i], "Not enough tokens in contract balance");
        require(token.transfer(_recipients[i], _tokenAmounts[i]), "Token transfer failed");
        totalTokens -= _tokenAmounts[i];
    }
}

    fallback() external payable {}

    receive() external payable {}
}