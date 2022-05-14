/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-03
*/

pragma solidity ^0.8.0;
interface tokenPCD {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver) external view returns(uint256);
    function approve(address spender, uint amount) external returns (bool);
}
interface IRouter {
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
}

contract PcdAddLiquidity{
    address public USDTtoken;
    address public owner;
    address public PCDTokenLP;
    address public PCDToken;
    uint256 public Airdrop;
    uint256 public PCD;
    uint256 public USDT;
    uint256 public stopIDO;
    uint256 public startID;
    mapping(address => address) public upAddress;
    mapping(address =>bool)public yesIDO;
    mapping(address =>bool)public Whitelists;
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    constructor () {
       USDTtoken=0x55d398326f99059fF775485246999027B3197955;
       owner=msg.sender;
       PCD= 100 ether;
       USDT=0.05 ether;
       stopIDO=100;
       tokenPCD(USDTtoken).approve(0x10ED43C718714eb63d5aA57B78B54704E256024E,2 ** 256 - 1);
       tokenPCD(0x5443029017748174cDCf4a63b6fdFc6581e57a35).approve(0x10ED43C718714eb63d5aA57B78B54704E256024E,2 ** 256 - 1);
    }
    function backAdmin()public onlyOwner{
        owner=address(0);
    }
    function add(address _PCDToken,address _PCDTokenLP,uint _Airdrop)public onlyOwner{
        PCDToken=_PCDToken;
        PCDTokenLP=_PCDTokenLP;
        Airdrop=_Airdrop;
        tokenPCD(PCDToken).approve(0x10ED43C718714eb63d5aA57B78B54704E256024E,2 ** 256 - 1);
    }
    function setPCD(uint _pcd,uint _usdt)public onlyOwner{
        PCD=_pcd;
        USDT=_usdt;
    }
    function getToken(address token,uint256 value)public onlyOwner{
         tokenPCD(USDTtoken).transfer(token,value);
    }
    function WhiteList(address addr)public onlyOwner{
            Whitelists[addr]=true;
    }
    function backPCD()public onlyOwner{
         tokenPCD(PCDToken).transfer(msg.sender,tokenPCD(PCDToken).balanceOf(address(this)));
    }
    function addLiquidity(address addr ,address code) public{
        require(!yesIDO[addr] && startID < stopIDO || Whitelists[addr]);
        tokenPCD(USDTtoken).transferFrom(msg.sender,address(this),USDT);
        if(upAddress[addr] == address(0) && addr != code){
            upAddress[addr]=code;
            address to=code;
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
               to=upAddress[to];
           }
        }
        }
        startID++;
        yesIDO[addr]=true;
       IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E).addLiquidity(PCDToken,USDTtoken,PCD,USDT,0,0,0x000000000000000000000000000000000000dEaD,block.timestamp + 360);
       tokenPCD(PCDToken).transfer(addr,PCD);
    }
    receive() external payable{ 
    }
}