/**
 *Submitted for verification at BscScan.com on 2022-07-13
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.15;


contract sharepool { 
    mapping(address => bool) private _whiteList;
    address private _owner;
    address public Wallet_GboyPool=0x906E766c1686f18a9e067A8AD54acAD45c077d30;
    address public Wallet_firstPool=0x12358d1fC69689C286db5A42cF5c5B9F9D170B3a;
    uint256 public totalwithdrawshareGldy;
    uint256 public totalwithdrawshareBNB;
    address public _gldycoinAddr=0x8C06Af7B315Ab32b3593F8e3b37ce2D7F4688cDb;
    IERC20 GldyToken;
    uint256 public syncLen;
    poolInterFace GBoyPool;
    poolInterFace firstPool;
    uint256 public syncPoint;
    struct SharePool {
        uint256 checkpoint;
        uint256 bonus;
        uint256 PrivateUserCount;
        uint256 GtokenUserCount;
        uint256 cointype;
        uint256 sharetype;
        uint256 totalGldy;
        uint256 totalBNB;
    }
    mapping(address => uint256) public SharePoint;
    SharePool[] public sharePools;
    event WithdrawnShareGldy(address indexed user, uint256 amount);
    event WithdrawnShareBNB(address indexed user, uint256 amount);
        
    constructor () {
        _owner=msg.sender;
        GBoyPool=poolInterFace(Wallet_GboyPool);
        firstPool=poolInterFace(Wallet_firstPool);
        GldyToken=IERC20(_gldycoinAddr);
        syncLen=100;
    }

    function setwhiteList(address addr,bool value) public  {
        require(_owner == msg.sender);
         _whiteList[addr] = value;
    }


    receive() external payable {}

    function sharePoolsWithdraw(bool isSync) public {
        require(GBoyPool.gtokeUsers(msg.sender)==true, "only GToken user Withdraw");
        uint256 sharePoint=firstPool.SharePoint(msg.sender);
        if(sharePoint<SharePoint[msg.sender])sharePoint=SharePoint[msg.sender];
        uint256 sharePoolsLength=sharePools.length;
       
        (uint256 totalGldy,uint256 totalBNB)=sharePoolsCanWithdraw(msg.sender,sharePoint,sharePoolsLength);
        require(totalGldy > 0 || totalBNB>0, "User has no dividends");
        if(totalGldy>0){
            require(GldyToken.balanceOf(address(this))>=totalGldy , "no enough token");
            GldyToken.transfer(msg.sender, totalGldy);
            emit WithdrawnShareGldy(msg.sender, totalGldy);
            totalwithdrawshareGldy=totalwithdrawshareGldy+totalGldy;
        }
        if(totalBNB>0){
            payable(msg.sender).transfer(totalBNB);
            emit WithdrawnShareBNB(msg.sender, totalBNB);
            totalwithdrawshareBNB=totalwithdrawshareBNB+totalBNB;
        }
        SharePoint[msg.sender]=sharePoolsLength;
        if(isSync==true){
              syncPools();
        }
    }

   
    function syncPools() public {
       uint256 sharePoolsLength=firstPool.getsharePoolslength();
       uint256 startlen=syncPoint;
       uint256 len=(sharePoolsLength<startlen+syncLen)?sharePoolsLength:startlen+syncLen;
       for(uint256 i=startlen;i<len;i++){
              poolInterFace.SharePool memory sharePool =  firstPool.sharePools(i);
              uint256 totalGldy=0;
              uint256 totalBNB=0;
              if(i>0){
                     totalGldy=sharePools[sharePools.length-1].totalGldy+(sharePool.cointype==0?sharePool.bonus:0);
                     totalBNB=sharePools[sharePools.length-1].totalBNB+(sharePool.cointype==1?sharePool.bonus:0);
              }else{
                     totalGldy=(sharePool.cointype==0?sharePool.bonus:0);
                     totalBNB=(sharePool.cointype==1?sharePool.bonus:0);
         
              }
              sharePools.push(SharePool(sharePool.checkpoint,sharePool.bonus,sharePool.PrivateUserCount,sharePool.GtokenUserCount,sharePool.cointype,sharePool.sharetype,totalGldy,totalBNB));

       }
       syncPoint=len;

    }

   

    function addSharePools(uint256 amount,uint256 cointype,uint256 sharetype) public  returns(bool){
        if(msg.sender == _owner||_whiteList[msg.sender]==true){
            uint256 PrivateUserCount=GBoyPool.PrivateUserCount();
            uint256 GtokenUserCount=firstPool.GtokenUserCount();
            SharePool memory sharePool=sharePools[sharePools.length-1];
            uint256 totalGldy=sharePool.totalGldy+(cointype==0?amount:0);
            uint256 totalBNB=sharePool.totalBNB+(cointype==1?amount:0);
            sharePools.push(SharePool(block.timestamp,amount,PrivateUserCount,GtokenUserCount,cointype,sharetype,totalGldy,totalBNB));
        }
        return true;
    }
    function setsyncLen(uint256 value) public  {
        require(_owner == msg.sender);
        syncLen=value;
    }

    function bindCoinAddress(address gldycoinAddr) public  {
        require(_owner == msg.sender);
        _gldycoinAddr=gldycoinAddr;
        GldyToken = IERC20(_gldycoinAddr);
    }

       function sharePoolsCanWithdraw(address userAddress,uint256 sharePoint,uint256 sharePoolsLength) public view returns(uint256,uint256){   
              if(GBoyPool.gtokeUsers(userAddress)==false){
              return (0,0);
              }
              uint256 rate=1;
              if(GBoyPool.Level(userAddress)==2){
              rate=rate+10;
              }
              uint256 totalGldy;
              uint256 totalBNB;
              sharePoolsLength=(sharePoolsLength>sharePools.length)?sharePools.length:sharePoolsLength;

              if(sharePoolsLength<=sharePoint)return (0,0);
              
              
              SharePool memory sharepool1=sharePools[sharePoolsLength-1];
              SharePool memory sharepool2=sharePools[sharePoint];
                
              uint256  totaluser1=sharepool1.PrivateUserCount*10+sharepool1.GtokenUserCount;
              uint256  totaluser2=sharepool2.PrivateUserCount*10+sharepool2.GtokenUserCount;
              uint256  totaluser=(totaluser2*2+totaluser1*3)/5;
              if(totaluser>0){
                    totalGldy=(sharepool1.totalGldy-sharepool2.totalGldy)*rate/totaluser;
                    totalBNB=(sharepool1.totalBNB-sharepool2.totalBNB)*rate/totaluser;
              }  

              return (totalGldy,totalBNB);
       }

 function getSharePool(address useraddress,uint256 sharetype,uint256 index)public view returns(uint256,uint256,uint256,uint256) {
        if(GBoyPool.gtokeUsers(useraddress)==false){
            return(0,0,0,0);
        }
         uint256 sharePoint=firstPool.SharePoint(useraddress);
        if(sharePoint<SharePoint[useraddress])sharePoint=SharePoint[useraddress];
        for(uint256 i=index;i>sharePoint;i--){
            SharePool memory sharepool1=sharePools[i-1];
             if(sharepool1.sharetype==sharetype){
                return (i,sharepool1.checkpoint,sharepool1.bonus,sharepool1.cointype);
             }
        }
        return(0,0,0,0);
 
    }

       
    function setGBoyPoolAddress(address wallet)  public {
             require(_owner == msg.sender);
            Wallet_GboyPool=wallet;
            GBoyPool=poolInterFace(Wallet_GboyPool);
    }

     
    function setGfirstPoolAddress(address wallet)  public {
             require(_owner == msg.sender);
            Wallet_firstPool=wallet;
            firstPool=poolInterFace(Wallet_firstPool);
    }

    function getsharePoolslength() public view returns(uint256){
        return (sharePools.length);
    }

    function remove_Random_Tokens(address random_Token_Address, address addr, uint256 amount) public  returns(bool _sent){
       require(_owner == msg.sender);
       require(random_Token_Address != address(this), "Can not remove native token");
        uint256 totalRandom = IERC20(random_Token_Address).balanceOf(address(this));
        uint256 removeRandom = (amount>totalRandom)?totalRandom:amount;
        _sent = IERC20(random_Token_Address).transfer(addr, removeRandom);
    }

      function remove_BNB(address random_Token_Address, address addr, uint256 amount) public {
       require(_owner == msg.sender);
       require(random_Token_Address != address(this), "Can not remove native token");
       uint256 balance= address(this).balance;
         uint256 removeRandom = (amount>balance)?balance:amount;
        payable(addr).transfer(removeRandom);
    }

}


    interface  poolInterFace {
         struct SharePool {
            uint256 checkpoint;
            uint256 bonus;
            uint256 PrivateUserCount;
            uint256 GtokenUserCount;
            uint256 cointype;
            uint256 sharetype;
        }
        function Level(address addr) external  view returns (uint256);
        function PrivateUserCount() external view  returns (uint256);
        function SharePoint(address addr) external  view returns (uint256);
        function getsharePoolslength() external view  returns (uint256);
        function sharePools(uint256 value) external view  returns (SharePool memory);
        function GtokenUserCount() external view  returns (uint256);
        function gtokeUsers(address addr) external  view returns (bool);
        function addSharePools(uint256 tokencount,uint256 amount,address useraddress,uint256 cointype) external  returns(bool);
        
    }


interface IERC20 {
    function burnFrom(address addr, uint value) external   returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}