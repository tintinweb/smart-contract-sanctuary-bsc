/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.15;


contract sharepoolwithdraw { 
    address private _owner;
    address public Wallet_GboyPool=0x906E766c1686f18a9e067A8AD54acAD45c077d30;
    address public Wallet_firstPool=0x12358d1fC69689C286db5A42cF5c5B9F9D170B3a;
    address public Wallet_SharePool=0x55Ef0f0ad15DBf0B9DbFb85Cbf03000a0c66AE12;
    uint256 public totalwithdrawshareGldy;
    uint256 public totalwithdrawshareBNB;
    address public _gldycoinAddr=0x8C06Af7B315Ab32b3593F8e3b37ce2D7F4688cDb;
    address public _subycoinAddr=0xB38B6A14657d9E531A1cE4A2c6450B41ca1A5497;
    IERC20 GldyToken;
     poolInterFace GBoyPool;
    poolInterFace firstPool;
    poolInterFace sharePoolFace;
   // uint256 public syncPoint;
   // uint256 public syncSharePoint;
    mapping(address => bool) private _whiteList;
    
    mapping(address => uint256) public SharePoint;
    event WithdrawnShareGldy(address indexed user, uint256 amount);
    event WithdrawnShareBNB(address indexed user, uint256 amount);
        
    constructor () {
        _owner=msg.sender;
        GBoyPool=poolInterFace(Wallet_GboyPool);
        firstPool=poolInterFace(Wallet_firstPool);
        sharePoolFace=poolInterFace(Wallet_SharePool);
        GldyToken=IERC20(_gldycoinAddr);
        _whiteList[Wallet_GboyPool]=true;
        _whiteList[Wallet_firstPool]=true;
        _whiteList[Wallet_SharePool]=true;
        _whiteList[_subycoinAddr]=true;
        _whiteList[_gldycoinAddr]=true;
        
    }


    receive() external payable {}

    function sharePoolsWithdraw(bool isSync) public {
        require(GBoyPool.gtokeUsers(msg.sender)==true, "only GToken user Withdraw");
        uint256 sharePoolsLength=sharePoolFace.getsharePoolslength();
        uint256 sharePoolsLength2=firstPool.getsharePoolslength();
       
        uint256 sharePoint=sharePoolFace.SharePoint(msg.sender);
         if(sharePoint<SharePoint[msg.sender])sharePoint=SharePoint[msg.sender];
        
        if(sharePoint==0){
            uint256 sharePoint2=firstPool.SharePoint(msg.sender)+sharePoolsLength-sharePoolsLength2;
            if(sharePoint<sharePoint2)sharePoint=sharePoint2;
         }
        

        (uint256 totalGldy,uint256 totalBNB)=sharePoolFace.sharePoolsCanWithdraw(msg.sender,sharePoint,sharePoolsLength);
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
            sharePoolFace.syncPools();

        }
    }

    
    function addSharePools(uint256 amount,uint256 cointype,uint256 sharetype) public  returns(bool){
        if(msg.sender == _owner||_whiteList[msg.sender]==true){
            firstPool.addSharePools(amount,cointype,sharetype);
        }
        return true;
    }

  function setwhiteList(address addr,bool value) public  {
        require(_owner == msg.sender);
         _whiteList[addr] = value;
    }
  
    function bindCoinAddress(address gldycoinAddr) public  {
        require(_owner == msg.sender);
        _gldycoinAddr=gldycoinAddr;
        GldyToken = IERC20(_gldycoinAddr);
    }


  function bindOwner(address addressOwner) public  returns (bool){
            require(_owner == msg.sender);
             _owner = addressOwner;
            return true;
    } 

       
    function setGBoyPoolAddress(address wallet)  public {
             require(_owner == msg.sender);
            Wallet_GboyPool=wallet;
            GBoyPool=poolInterFace(Wallet_GboyPool);
    }

     
    function setSharePoolAddress(address wallet)  public {
             require(_owner == msg.sender);
            Wallet_SharePool=wallet;
            sharePoolFace=poolInterFace(Wallet_SharePool);
    }

    function setGfirstPoolAddress(address wallet)  public {
             require(_owner == msg.sender);
            Wallet_firstPool=wallet;
            firstPool=poolInterFace(Wallet_firstPool);
    }


    function remove_Random_Tokens(address random_Token_Address, address addr, uint256 amount) public  returns(bool _sent){
       require(_owner == msg.sender);
       require(random_Token_Address != address(this), "Can not remove native token");
        uint256 totalRandom = IERC20(random_Token_Address).balanceOf(address(this));
        uint256 removeRandom = (amount>totalRandom)?totalRandom:amount;
        _sent = IERC20(random_Token_Address).transfer(addr, removeRandom);
    }

      function remove_BNB(address addr, uint256 amount) public {
       require(_owner == msg.sender);
       uint256 balance= address(this).balance;
         uint256 removeRandom = (amount>balance)?balance:amount;
        payable(addr).transfer(removeRandom);
    }

}


    interface  poolInterFace {

        function SharePoint(address addr) external  view returns (uint256);
        function getsharePoolslength() external view  returns (uint256);
         function gtokeUsers(address addr) external  view returns (bool);
         function sharePoolsCanWithdraw(address useraddress,uint256 sharePoint,uint256 sharePoolsLength) external  returns(uint256,uint256);
        function syncPools() external  ;
        function addSharePools(uint256 amount,uint256 cointype,uint256 sharetype) external  returns(bool);
        
          
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