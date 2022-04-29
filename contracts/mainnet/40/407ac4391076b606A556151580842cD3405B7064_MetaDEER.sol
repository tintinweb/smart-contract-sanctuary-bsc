/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-24
*/

pragma solidity ^0.8.0;
interface tokenDeer {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver) external view returns(uint256);
    function approve(address spender, uint amount) external returns (bool);
}
interface Foundations {
    function sendDistribution(uint256 _value)external;
}
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract MetaDEER{
    address public USDTtoken;
    address public owner;
    address public deerTokenLP;
    address public deerToken;
    address public addLiquidityDeer;
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    constructor () {
       USDTtoken=0x55d398326f99059fF775485246999027B3197955;
       owner=msg.sender;
       deerToken=0xE7975FeBA18A9F9947A6390dDd32e17A407B6875;
       deerTokenLP=0x2D1683cbd4b1704c8A31661689b45Ea33d4B93b9;
       tokenDeer(USDTtoken).approve(0x10ED43C718714eb63d5aA57B78B54704E256024E,2 ** 256 - 1);
    }
    function setadmin(address addr)public onlyOwner{
        addLiquidityDeer=addr;
        owner=address(0);
    }
    function addLiquidity(address addr) public{
      require(msg.sender == addLiquidityDeer);
      uint  DEER=5000000 ether;
      uint  USDT=100 ether;
       IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E).addLiquidity(deerToken,USDTtoken,DEER,USDT,0,0,msg.sender,block.timestamp + 360);
       tokenDeer(deerTokenLP).transfer(0x000000000000000000000000000000000000dEaD,tokenDeer(deerTokenLP).balanceOf(address(this)));
       tokenDeer(deerToken).transfer(addr,DEER);
    }
    receive() external payable{ 
    }
}