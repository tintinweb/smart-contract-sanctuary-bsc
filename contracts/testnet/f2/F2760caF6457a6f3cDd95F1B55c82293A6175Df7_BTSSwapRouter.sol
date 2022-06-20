/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

/*
BlockchainTokenSniper Swap Router v1

Website: blockchaintokensniper.com
Telegram: t.me/blockchaintokensniper
*/

pragma solidity ^0.8.14;

interface IUniswapRouter {
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface ERC20 {
    function balanceOf(address _owner) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract BTSSwapRouter {
    address public ownerAddress;
    address public devFeeAddress;

    address public wethAddress;

    mapping(address => mapping(address => uint)) private previousBalance;

    modifier onlyOwner() {
        require(msg.sender == ownerAddress, "Owner only");
        _;
    }

    constructor() {
        ownerAddress = payable(msg.sender);
        devFeeAddress = payable(msg.sender);

        wethAddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    }

    function getTokenValue(address routerAddress, address baseToken, address snipeToken) public view returns (uint) {
        return IUniswapRouter(routerAddress).getAmountsOut(ERC20(snipeToken).balanceOf(msg.sender), getTokenPath(snipeToken, baseToken))[1];
    }

    function getTokenPath(address token1, address token2) private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = token1;
        path[1] = token2;

        return path;
    }

    function Snipe(address routerAddress, address baseToken, address snipeToken, uint buyAmount, uint txRevertTime, uint testSwapAmount, uint testSwapFailThreshold) public {
        IUniswapRouter snipeDEXRouter = IUniswapRouter(routerAddress);

        if (baseToken == wethAddress) {
            if (testSwapAmount > 0) {
                uint initialBalance = msg.sender.balance;
                uint startGas = gasleft();

                snipeDEXRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: testSwapAmount}(0, getTokenPath(baseToken, snipeToken), msg.sender, block.timestamp + txRevertTime);
                uint tokenBalance = ERC20(snipeToken).balanceOf(msg.sender);
                ERC20(snipeToken).approve(routerAddress, 2**256 - 1);
                snipeDEXRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenBalance, 0, getTokenPath(snipeToken, baseToken), msg.sender, block.timestamp + txRevertTime);
                require((msg.sender.balance +  startGas - gasleft()) >= (initialBalance - uint((testSwapAmount * testSwapFailThreshold) / 100)), "Test swap failed");           
            }
            uint initialBalance = msg.sender.balance;
            snipeDEXRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: buyAmount}(0, getTokenPath(baseToken, snipeToken), msg.sender, block.timestamp + txRevertTime);
            
            uint totalCost = initialBalance - msg.sender.balance;
            previousBalance[msg.sender][snipeToken] = totalCost;
        } 

        else {
            if (testSwapAmount > 0) {
                uint initialBalance = ERC20(snipeToken).balanceOf(msg.sender);

                snipeDEXRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(testSwapAmount, 0, getTokenPath(baseToken, snipeToken), msg.sender, block.timestamp + txRevertTime);
                uint tokenBalance = ERC20(snipeToken).balanceOf(msg.sender);
                ERC20(snipeToken).approve(routerAddress, 2**256 - 1);
                snipeDEXRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenBalance, 0, getTokenPath(snipeToken, baseToken), msg.sender, block.timestamp + txRevertTime);

                require(ERC20(snipeToken).balanceOf(msg.sender) >= (initialBalance - uint((testSwapAmount * testSwapFailThreshold) / 100)), "Test swap failed");           
            }

            uint initialBalance = ERC20(baseToken).balanceOf(msg.sender);
            snipeDEXRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(0, buyAmount, getTokenPath(baseToken, snipeToken), msg.sender, block.timestamp + txRevertTime);

            uint totalCost = initialBalance - ERC20(baseToken).balanceOf(msg.sender);
            previousBalance[msg.sender][snipeToken] = totalCost;
        }
    }

    function Sell(address routerAddress, address baseToken, address snipeToken, uint sellPercentage, uint txRevertTime, uint devFeePercentage) public payable {
        IUniswapRouter snipeDEXRouter = IUniswapRouter(routerAddress);

        uint sellAmount = uint((ERC20(snipeToken).balanceOf(msg.sender) * sellPercentage) / 100);

        if (ERC20(snipeToken).allowance(msg.sender, routerAddress) < (2**256 / 2)) {
            ERC20(snipeToken).approve(routerAddress, (2**256 -1));
        }

        if (baseToken == wethAddress) {          
            uint initialBalance = msg.sender.balance;
            snipeDEXRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(sellAmount, 0, getTokenPath(baseToken, snipeToken), address(this), block.timestamp + txRevertTime);

            uint finalBalance = msg.sender.balance;
            uint totalGained = finalBalance - initialBalance;

            if(totalGained > previousBalance[msg.sender][snipeToken] && devFeePercentage > 0) {
                uint totalProfit = totalGained - previousBalance[msg.sender][snipeToken];
                uint devFee = uint((uint((totalProfit * devFeePercentage) / 100) * sellPercentage) / 100);

                uint sniperProfit = address(this).balance - devFee;

                ERC20(snipeToken).transfer(msg.sender, sniperProfit);
                ERC20(snipeToken).transfer(msg.sender, ERC20(snipeToken).balanceOf(address(this)));

                previousBalance[msg.sender][snipeToken] = uint((previousBalance[msg.sender][snipeToken] * sellPercentage) / 100);           
            }

            else {
                previousBalance[msg.sender][snipeToken] = 0;
            }
        } 

        else {
            uint initialBalance = ERC20(snipeToken).balanceOf(msg.sender);
            snipeDEXRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(sellAmount, 0, getTokenPath(baseToken, snipeToken), address(this), block.timestamp + txRevertTime);

            uint finalBalance = ERC20(snipeToken).balanceOf(msg.sender);
            uint totalGained = finalBalance - initialBalance;

            if (totalGained > previousBalance[msg.sender][snipeToken] && devFeePercentage > 0) {
                uint totalProfit = totalGained - previousBalance[msg.sender][snipeToken];
                uint devFee = uint((uint((totalProfit * devFeePercentage) / 100) * sellPercentage) / 100);

                uint sniperProfit = ERC20(snipeToken).balanceOf(address(this)) - devFee;

                payable(address(msg.sender)).transfer(sniperProfit);
                payable(devFeeAddress).transfer(address(this).balance);

                previousBalance[msg.sender][snipeToken] = uint((previousBalance[msg.sender][snipeToken] * sellPercentage) / 100);                  
            }

            else {
                previousBalance[msg.sender][snipeToken] = 0;
            }
        }
    }

    function changeOwner(address newOwnerAddress) public onlyOwner {
        ownerAddress = newOwnerAddress;
    }

    function changeDevFeeAddress(address newDevFeeAddress) public onlyOwner {
        devFeeAddress = newDevFeeAddress;
    }
}