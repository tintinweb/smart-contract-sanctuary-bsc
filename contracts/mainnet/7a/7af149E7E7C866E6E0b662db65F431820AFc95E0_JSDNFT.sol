/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

pragma solidity >=0.6.0 <0.8.0;
 interface ERC20 {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver)external returns(uint256);
}
interface NFTToken{
    function ownerOf(uint256 _tokenId) external view returns (address);
    function transferFrom(address _from, address _to, uint256 _value)external;
    function mint(address toAddress)external;
    function balanceOf(address _owner) external view returns (uint256);
    function tokenNextId()external view returns (uint256);
    function myTokens(address _owner)external view returns ( uint256[] memory);
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}
}
contract JSDNFT{
    using SafeMath for uint256;
    address public owner;
    uint256 public allPower;//全网算力
    uint256 public allToken;//全网日产量
    ERC20 public JSDToken;
    NFTToken public NFTTokens;
    mapping(uint => uint) public STOP;
    mapping(uint => uint) public START;
    mapping(uint => uint) public startMiner;
    mapping(uint =>user) public users;
    mapping(uint => address)public tokens;
    mapping(address => uint256) public userPower;//个人算力
    mapping(address => uint)public powerTime;
    uint256 mnus;
    struct user{
        uint256 DirectPushTime;
       }
    modifier onlyOwner() {
        require(owner==msg.sender, "Not an administrator");
        _;
    }
    constructor()public{
         owner=msg.sender;
         JSDToken=ERC20(tokens[1]);//JSD币
         NFTTokens=NFTToken(tokens[2]);//NFT交易所
         startMiner[1]=1651334400;//每天24：00发放
         startMiner[2]=1651334400;//每天24：00发放
         startMiner[3]=1651334400;//每天24：00发放
         START[1]=1;
         START[2]=1;
         START[3]=1;
     }
     function AllPowerNFT()public{
          allPower=getSumPower();
          //这里在增加SS SSS级别累计算力
          if(allPower < 100000){
             allToken=1000000 ether;
          }else if(allPower < 500000){
              allToken=2000000 ether;
          }else if(allPower < 1000000){
              allToken=3000000 ether;
          }else if(allPower < 5000000){
              allToken=4000000 ether;
          }else if(allPower > 5000000){
              allToken=500000 ether;
          }     
    }
    function setTokens(address addr,uint a)public onlyOwner{
         tokens[a]=addr;
         //1=JSD代币，2=基金会，3=算力挖
     }
     function setjsd()public onlyOwner{
         JSDToken=ERC20(tokens[1]);//JSD币
         NFTTokens=NFTToken(tokens[2]);//NFT交易所
     }
    //S=1 SS=2 SSS=3发放挖矿收益
    function getMiner(uint256 a)public{
    AllPowerNFT();
     address nftAddress=getNFTlevel(a);
      if(block.timestamp > startMiner[a]){
        STOP[a]=START[a]+50;
         if(STOP[a] > NFTToken(nftAddress).tokenNextId()){
           STOP[a]=NFTToken(nftAddress).tokenNextId();
          }
         for(START[a];START[a] < STOP[a];START[a]++){
            address addr=NFTToken(nftAddress).ownerOf(START[a]);
            if(block.timestamp > powerTime[addr]){
            JSDToken.transfer(addr,getMinerValue(addr));
            powerTime[addr]=block.timestamp + 10000;
            }
            if(START[a] == NFTToken(nftAddress).tokenNextId()-1){
            START[a]=1;
            startMiner[a] += 1 days;
            break;
           }
          }       
       }
    }
    function setStratStop(uint a,uint b,uint stop)public onlyOwner{
        START[a]=b;
        STOP[a]=stop;
    }
    function setToken(address _JSDToken,address _NFTTokens)public onlyOwner{
        JSDToken=ERC20(_JSDToken);//JSD币
        NFTTokens=NFTToken(_NFTTokens);//NFT交易所
    }
    function setTime(uint _time)public onlyOwner{
        startMiner[1]=_time;
        startMiner[2]=_time;
        startMiner[3]=_time;
    }
    function giveUpAdmin()public onlyOwner{
        owner=address(0);//放弃管理员权限
    }
    function getMinerValue(address addr)public view returns(uint){
        uint _power=getUserPower(addr);
        uint sl=_power *allToken.div(allPower);
        return sl;
    }
    //统计总算力
    function getSumPower()public view returns(uint){
        uint power;
        //S-NFT
        power+=NFTToken(0xEd59Bd702c581BdA60C360B53206F0238a9B6F09).tokenNextId().mul(100).sub(100);
        //SS-NFT
        power+=NFTToken(0x1b2bD14F24B6B5176182c853bb73ce9229b57E7d).tokenNextId().mul(500).sub(500);
        //SSS-NFT
        power+=NFTToken(0x729A1007dF175b97A0fb83EAa53f237db64C140f).tokenNextId().mul(1000).sub(1000);
        return power;
    }
    function getUserPower(address addr)public view returns(uint){
        uint sl;
        //S-NFT
        sl+=NFTToken(0xEd59Bd702c581BdA60C360B53206F0238a9B6F09).balanceOf(addr).mul(100);
        //SS-NFT
        sl+=NFTToken(0x1b2bD14F24B6B5176182c853bb73ce9229b57E7d).balanceOf(addr).mul(500);
        //SSS-NFT
        sl+=NFTToken(0x729A1007dF175b97A0fb83EAa53f237db64C140f).balanceOf(addr).mul(1000);
        return sl;
    }
    //1=s  2=ss 3=sss
    function getNFTlevel(uint256 a)public view returns(address){
        if(a == 1){
            //S-NFT
            return 0xEd59Bd702c581BdA60C360B53206F0238a9B6F09;
        }else if(a == 2){
            //SS-NFT
            return 0x1b2bD14F24B6B5176182c853bb73ce9229b57E7d;
        }else if(a == 3){
            //sss-NFT
            return 0x729A1007dF175b97A0fb83EAa53f237db64C140f;
        }
    }
    //查询是否可以执行挖矿收益
    function getMinerTime(uint a)public view returns(uint){
        if(block.timestamp > startMiner[a]){
            return 1;//可以发送挖矿收益
        }else{
            return 0;//执行完毕
        }
    }   
    receive() external payable {}
}