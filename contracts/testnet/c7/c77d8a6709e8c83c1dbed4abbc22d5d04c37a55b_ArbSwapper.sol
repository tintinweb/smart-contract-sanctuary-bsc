/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

//unique comment to change bytecode 25893

pragma solidity 0.8.13;

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
      require(_owner == _msgSender(), "Owner access only");
      _;
    }

}

interface IUniswapV2Router01 {
    function WETH() external pure returns (address);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface ApprovalInterface{
    function approve(address spender, uint256 value) external returns (bool);
}

contract ArbSwapper is Context, Ownable {

    function estimateProfitability(address buyRouterAddress, address sellRouterAddress, address tokenToArb, uint buyAmountETH) public view returns (uint totalProfit) {
        IUniswapV2Router01 dex1Router = IUniswapV2Router01(buyRouterAddress);
        IUniswapV2Router01 dex2Router = IUniswapV2Router01(sellRouterAddress);

        address dexWETH = dex1Router.WETH();

        address[] memory buyPath = new address[](2);
        buyPath[0] = dexWETH;
        buyPath[1] = tokenToArb;

        uint buyTokenOutput = dex1Router.getAmountsOut(buyAmountETH, buyPath)[1];

        address[] memory sellPath = new address[](2);
        sellPath[0] = tokenToArb;
        sellPath[1] = dexWETH;

        uint sellOutput = dex2Router.getAmountsOut(buyTokenOutput, sellPath)[1];

        if (sellOutput < buyAmountETH) {
            return 0;
        }
        else {
            uint returnAmount = sellOutput - buyAmountETH;
            return returnAmount;
        }
        

    }

  function killContract() public onlyOwner {
      address payable caller = payable(msg.sender);
      selfdestruct(caller);
  }

  receive() payable external {}
}