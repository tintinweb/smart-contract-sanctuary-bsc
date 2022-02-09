/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

pragma solidity >=0.8.7;

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
}

interface IWETH {
    function deposit() external payable;
}

interface UniswapRouter {
    function WETH() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    }

contract FeeChecker {
    address public immutable router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    bool private sniped = false;
    function snipe(address token, uint maxBuyFee, uint maxSellFee) external payable virtual {
        if (!sniped) {
        IWETH(UniswapRouter(router).WETH()).deposit{value: msg.value}();
        address[] memory buyPath;
        address weth = UniswapRouter(router).WETH();
        buyPath = new address[](2);
        buyPath[0] = weth;
        buyPath[1] = token;
        uint ethBalance = IERC20(weth).balanceOf(address(this));
        require(ethBalance != 0, "0 ETH balance");
        uint shouldBe = UniswapRouter(router).getAmountsOut(ethBalance, buyPath)[1];
        uint balanceBefore = IERC20(token).balanceOf(address(this));
        IERC20(weth).approve(router, ~uint(0));
        UniswapRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(ethBalance, 0, buyPath, address(this), block.timestamp);
        uint tokenBalance = IERC20(token).balanceOf(address(this));
        require(tokenBalance != 0, "100% buy fee");
        uint buyFee = 100 - ((tokenBalance - balanceBefore) * 100 / shouldBe);
        require(buyFee <= maxBuyFee, "High buy fee");
        uint toSell = tokenBalance / 1000;
        address[] memory sellPath;
        sellPath = new address[](2);
        sellPath[0] = token;
        sellPath[1] = weth;
        shouldBe = UniswapRouter(router).getAmountsOut(toSell, sellPath)[1];
        balanceBefore = IERC20(weth).balanceOf(address(this));
        IERC20(token).approve(router, ~uint(0));
        UniswapRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(toSell, 0, sellPath, address(this), block.timestamp);
        uint sellFee = 100 - ((IERC20(weth).balanceOf(address(this)) - balanceBefore) * 100 / shouldBe);
        require(sellFee <= maxSellFee, "High sell fee");
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
        sniped = true;
        } else {
            revert();
        }
    }
    function reset() external{
        sniped = false;
    }
}