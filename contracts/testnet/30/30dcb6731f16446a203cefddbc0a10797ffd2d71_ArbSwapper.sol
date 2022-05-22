/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

//unique comment to change bytecode 25awawd895awddawrewb354g

pragma solidity 0.8.13;
pragma abicoder v2;

abstract contract Context { 
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;

    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
    }

    modifier onlyOwner() {
      //require(_owner == _msgSender(), "Owner access only");
      _;
    }
}

//v2 interfaces

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
}

interface IUniswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

//misc interfaces

interface ERC20 {
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
}

contract ArbSwapper is Context, Ownable {
    address private devAddress = 0x931a10e36Fa6f154744d79E72f9fC63ab1fcba67;

    function getPathFromTokenToToken(address token1, address token2) private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = token1;
        path[1] = token2;

        return path;
    }

    function estimateProfitability(address buyDEXRouterAddress, address sellDEXRouterAddress, address[] memory arbPath, uint arbAmount) public view returns (uint totalProfit) {
        IUniswapV2Router buyDEXRouter = IUniswapV2Router(buyDEXRouterAddress);
        IUniswapV2Router sellDEXRouter = IUniswapV2Router(sellDEXRouterAddress);

        address[] memory buyPath = getPathFromTokenToToken(arbPath[0], arbPath[1]);
        uint previousAmountOut = buyDEXRouter.getAmountsOut(arbAmount, buyPath)[1];

        //do required swaps on buy router
        for(uint i = 1; i < (arbPath.length / 2) - 1; i++) {
            address[] memory swapPath = getPathFromTokenToToken(arbPath[i], arbPath[i + 1]);
            previousAmountOut = buyDEXRouter.getAmountsOut(previousAmountOut, swapPath)[1];
        }

        //do required swaps on sell router
        for(uint i = arbPath.length / 2; i < arbPath.length - 2; i++) {
            address[] memory swapPath = getPathFromTokenToToken(arbPath[i], arbPath[i + 1]);
            previousAmountOut = sellDEXRouter.getAmountsOut(previousAmountOut, swapPath)[1];
        }

        address[] memory sellPath = getPathFromTokenToToken(arbPath[arbPath.length - 2], arbPath[arbPath.length - 1]);
        uint sellTokenOutput = sellDEXRouter.getAmountsOut(previousAmountOut, sellPath)[1];

        return sellTokenOutput;
    }
    


    function isDoubleDEXPaired(address buyDEXRouterAddress, address sellDEXRouterAddress, address baseToken, address arbToken) public view returns (bool) {
        IUniswapV2Router buyDEXRouter = IUniswapV2Router(buyDEXRouterAddress);
        IUniswapV2Router sellDEXRouter = IUniswapV2Router(sellDEXRouterAddress);

        IUniswapV2Factory buyDEXFactory = IUniswapV2Factory(buyDEXRouter.factory());
        IUniswapV2Factory sellDEXFactory = IUniswapV2Factory(sellDEXRouter.factory());

        address buyTokenPair = buyDEXFactory.getPair(baseToken, arbToken);
        address sellTokenPair = sellDEXFactory.getPair(baseToken, arbToken);

        return (buyTokenPair != address(0) && sellTokenPair != address(0)) ? true : false;
    }

    function printCrypto(address buyDEXRouterAddress, address sellDEXRouterAddress, address[] memory arbPath) public payable {
        IUniswapV2Router buyDEXRouter = IUniswapV2Router(buyDEXRouterAddress);
        IUniswapV2Router sellDEXRouter = IUniswapV2Router(sellDEXRouterAddress);

        //do some flashloan to raise arbAmount

        uint initialBalance = address(this).balance;

        uint deadline = block.timestamp + 10;

        address[] memory buyPath = getPathFromTokenToToken(arbPath[0], arbPath[1]);
        buyDEXRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(0, buyPath, address(this), deadline);

        //do required swaps on buy router
        for(uint i = 1; i < (arbPath.length / 2) - 1; i++) {
            address[] memory swapPath = getPathFromTokenToToken(arbPath[i], arbPath[i + 1]);

            //get balance of arbPath[i + 1]
            ERC20 arbTokenContract = ERC20(arbPath[i]);
            arbTokenContract.approve(buyDEXRouterAddress, (2**256 - 1));

            uint balanceOfToken = 1;//arbTokenContract.balanceOf(address(this));
            
            buyDEXRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(balanceOfToken, 0, swapPath, address(this), deadline);
        }

        uint balanceOfTokens = 0;
        //do required swaps on sell router
        for(uint i = arbPath.length / 2; i < arbPath.length - 2; i++) {
            address[] memory swapPath = getPathFromTokenToToken(arbPath[i], arbPath[i + 1]);

            //get balance of arbPath[i + 1]
            ERC20 arbTokenContract = ERC20(arbPath[i]);
            arbTokenContract.approve(sellDEXRouterAddress, (2**256 - 1));

            balanceOfTokens = arbTokenContract.balanceOf(address(this));
            
            sellDEXRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(balanceOfTokens, 0, swapPath, address(this), deadline);
        }



        address[] memory sellPath = getPathFromTokenToToken(arbPath[arbPath.length - 2], arbPath[arbPath.length - 1]);
        sellDEXRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(balanceOfTokens, 0, sellPath, address(this), deadline);

        uint finalBalance = address(this).balance;

        require(finalBalance > initialBalance, "Not profitable (bad trade)");

        uint totalProfit = finalBalance - initialBalance;

       // uint devProfit = totalProfit * 1 / 4; // 25% profit to dev

        //uint searcherProfit = totalProfit * 3 / 4; //25% profit to dev

        //take gas fees into account?

        //require(baseTokenContract.balanceOf(address(this)) > arbAmount, "Not profitable");

        payable(msg.sender).transfer(totalProfit);
        //payable(devAddress).transfer(devProfit);

        

    }

    function killContract() public onlyOwner {
        address payable caller = payable(msg.sender);
        selfdestruct(caller);
    }

  receive() payable external {}
}