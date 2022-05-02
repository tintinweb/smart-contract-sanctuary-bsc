/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-24
*/

pragma solidity ^0.8.0;
interface tokenPCD {
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

contract PcdAddLiquidity{
    address public USDTtoken;
    address public owner;
    address public PCDTokenLP;
    address public PCDToken;
    address public addLiquidityPCD;
    uint256 public Airdrop;
    uint256 public PCD;
    uint256 public USDT;
    mapping(address => address) public upAddress;
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    constructor () {
       USDTtoken=0x55d398326f99059fF775485246999027B3197955;
       owner=msg.sender;
       PCDToken=0x623A2b52f7bC5fc711d90a6B0C00E3CB10a354fE;
       PCDTokenLP=0x6Bd6a9201e938310D8A8EE9AEe5D561e43c5D163;
       PCD= 1 ether;
       USDT=0.0005 ether;
       tokenPCD(USDTtoken).approve(0x10ED43C718714eb63d5aA57B78B54704E256024E,2 ** 256 - 1);
       tokenPCD(PCDToken).approve(0x10ED43C718714eb63d5aA57B78B54704E256024E,2 ** 256 - 1);
    }
    function setadmin(address addr)public onlyOwner{
        addLiquidityPCD=addr;
    }
    function backAdmin()public onlyOwner{
        owner=address(0);
    }
    function add(address _PCDToken,address _PCDTokenLP,uint _Airdrop)public onlyOwner{
        PCDToken=_PCDToken;
        PCDTokenLP=_PCDTokenLP;
        Airdrop=_Airdrop;
    }
    function setPCD(uint _pcd,uint _usdt)public onlyOwner{
        PCD=_pcd;
        USDT=_usdt;
    }
    function addLiquidity(address addr ,address code) public{
        require(msg.sender == addLiquidityPCD);
        if(upAddress[addr] == address(0) && addr != code){
            upAddress[addr]=code;
        }
        address to=addr;
        for(uint i=0;i<3;i++){
           if(upAddress[to] != address(0)){
               if(i==0){
                   tokenPCD(PCDToken).transfer(to,Airdrop*50/100);
               }
               if(i==1){
                   tokenPCD(PCDToken).transfer(to,Airdrop*30/100);
               }
               if(i==2){
                   tokenPCD(PCDToken).transfer(to,Airdrop*20/100);
               }
           }
        }
       IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E).addLiquidity(PCDToken,USDTtoken,PCD,USDT,0,0,msg.sender,block.timestamp + 360);
       tokenPCD(PCDTokenLP).transfer(0x000000000000000000000000000000000000dEaD,tokenPCD(PCDTokenLP).balanceOf(address(this)));
       tokenPCD(PCDToken).transfer(addr,PCD);
    }
    receive() external payable{ 
    }
}