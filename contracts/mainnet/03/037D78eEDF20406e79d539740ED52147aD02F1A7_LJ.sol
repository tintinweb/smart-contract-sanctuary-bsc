pragma solidity ^0.8.0;
// SPDX-License-Identifier: Unlicensed
import "./Base.sol";

interface operation {//konwnsec//IDividends 接口
    function getPlayerByAddress(address playerAddr) external view returns(uint256[] memory);
    function updatecommunity(uint256 id, uint256 OutGold,uint256 communitySEOSQuantity, uint256 JFcommunitySEOSQuantity) external;
    function getIDByAddress(address addr) external view returns(uint256);
    function updateTX(uint256 id, uint256 OutGold,uint256 Quantity,bool EOSOrSeos) external;
    function updatepbecomeNode(address  playAddress ) external;
    function updatepbecomeSupernode(address recommend,address  playAddress,uint256 USDT_T_Quantity) external;
    function updateExtensionTX(uint256 id, uint256 OutGold,uint256 TSEOSQuantity, bool isjf) external;
    function updateBQ(address recommend,address  playAddress,uint256 USDT_T_Quantity) external;
    function  updatePmining(uint256 USDT_Num,uint256 id,uint256 paytype,uint256 JF) external;
    function updatepIDO(address Destination,address SEOSPlayerAddress,uint256 USDT_T_Quantity) external;
    function getprice() external view  returns(uint256);
    // function extensionTX() external canCall;

}
contract LJ is Base  {
    
    using SafeMath for uint256;
  

     address public _operation; // 分红合约地址

    
 
    constructor()
    public {
        _owner = msg.sender; 
        Uaddress = msg.sender; 
    }

   
// IDO参与 一个地址只能参与一次   创世节点  20%    超级节点15%
    function pIDO(address Destination) external {


        operation diviIns = operation(_operation);
        uint256 id = diviIns.getIDByAddress(Destination);
        uint256 USDT_T_Quantity = 0;
        uint256[] memory sjtemp = diviIns.getPlayerByAddress(Destination);
        uint256 BuyPrice =  diviIns.getprice();
        _USDTAddr.transferFrom(address(msg.sender), address(this), BuyPrice);

        if(id > 0){

             uint256 _usdtBalance = _USDTAddr.balanceOf(msg.sender);
            require(_usdtBalance >= SupernodePrice, "9999");

            if(sjtemp[5]> 0){
                USDT_T_Quantity =  BuyPrice.mul(20).div(100);
             }else{
                if(sjtemp[6] > 0){
                    USDT_T_Quantity =  BuyPrice.mul(15).div(100);
                 }
            }
        }
        diviIns.updatepIDO(Destination,msg.sender,  USDT_T_Quantity);     
    }
 
  
//  第三方代币转账
    function ERC20Transfer(uint256 USDT_Num,uint256 tokenIndex) internal    {
        address  tokenAddress  = IDtoToken[tokenIndex];
        Erc20Token  token = Erc20Token(tokenAddress);
        address  tekenLPaddress  = IDtoTokenLP[tokenIndex];
        Erc20Token  tekenLP = Erc20Token(tekenLPaddress);
        uint256  tokenNum = USDT_Num.mul(Spire_Price(token, tekenLP)).div(10000000);
        token.transferFrom(address(msg.sender), address(this),tokenNum);
        token.transfer(address(Uaddress),tokenNum);
     }
     //  项目方代币销毁
    function ERC20Destroy(uint256 USDT_Num,uint256 tokenIndex) internal    {
        address  tokenAddress  = IDtoToken[tokenIndex];
        Erc20Token  token = Erc20Token(tokenAddress);
        address  tekenLPaddress  = IDtoTokenLP[tokenIndex];
        Erc20Token  tekenLP = Erc20Token(tekenLPaddress);
        uint256  tokenNum = USDT_Num.mul(Spire_Price(token, tekenLP)).div(10000000);
        token.transferFrom(address(msg.sender), address(1),tokenNum);
     }

// EOS
     function EOSTransfer(uint256 EOSnum,address player) internal returns(uint256 ) {

        operation diviIns = operation(_operation);
 
        uint256[] memory temp = diviIns.getPlayerByAddress(player);
        uint256 integral = temp[11];


         EOSnum = EOSnum.mul(Spire_Price(_EOSAddr, _EOSLPAddr)).div(10000000);
        uint256 EOSBalance = _EOSAddr.balanceOf(player);
        if(EOSBalance >= EOSnum){
            _EOSAddr.transferFrom(address(player), address(this),EOSnum);
            _EOSAddr.transfer(address(Uaddress),EOSnum);
        }else{
            uint256  EOS_BQ_Balance =   EOSnum.sub(EOSBalance);
            require(temp[11] >= EOS_BQ_Balance, "integral");
            if(EOSBalance > 100000000000000000){
                _EOSAddr.transferFrom(address(player), address(this),EOSBalance);
                _EOSAddr.transfer(address(Uaddress),EOSBalance);
            }
            integral  = temp[11].sub(EOS_BQ_Balance);
        }


        return integral;
     }



// 挖矿投资
    function pmining(uint256 USDTNum,uint256 tokenAIndex,uint256 tokenBIndex,uint256 paytype) external     { 
        operation diviIns = operation(_operation);
        uint256 id = diviIns.getIDByAddress(msg.sender);
        require(id > 0, "isplayer"); 
        // SEOSPlayer  memory  player = diviIns.getplayerinfo(  msg.sender);

        uint256[] memory temp = diviIns.getPlayerByAddress(msg.sender);

        uint256 JF = temp[11];

        require(id > 0, "IDO");
        require(USDTNum >= 50000000000000000000, "mining limit");


        uint256 USDT_Num = USDTNum;

        if(paytype == 1){//一半U一半EOS

            JF =  EOSTransfer( USDT_Num.div(2),msg.sender);
            ERC20Transfer(USDT_Num.div(2),tokenAIndex);

            // _USDTAddr.transferFrom(address(msg.sender), address(this), USDT_Num.div(2));
            // _USDTAddr.transfer( address(Uaddress), USDT_Num.mul(4).div(10));

        }else if(paytype == 2){// 40%  eos  20%代币A 40%代币B
            uint256  EOSnum = USDT_Num.mul(4).div(10);
             JF =  EOSTransfer( EOSnum,msg.sender);
            ERC20Destroy(EOSnum.div(2),tokenAIndex);
            ERC20Transfer(EOSnum,tokenBIndex);
        }else if(paytype == 3)//复投
        {
            USDT_Num = temp[2].mul(10000000).div(Spire_Price(_SEOSAddr, _SEOSLPAddr));

        }
        diviIns.updatePmining(USDT_Num,id,paytype,JF);
    }
  
// 提取产出（挖矿）
   function TXSEOS() public {
        operation diviIns = operation(_operation);
        uint256 id = diviIns.getIDByAddress(msg.sender);
        require(id > 0, "isplayer"); 
        uint256[] memory temp = diviIns.getPlayerByAddress(msg.sender);
        uint256 SEOSQuantity = 0;
        uint256 OutGold = 0;
        require(temp[2] > 0, "isplayer"); 
        require(temp[1] > 0, "isplayer"); 

        if(temp[2] > 0 &&  temp[1]  > 0){

            uint256 EOSSPrice  =   Spire_Price(_SEOSAddr, _SEOSLPAddr);
            uint256 Unum = temp[2].mul(10000000).div(EOSSPrice);
            if(temp[1]  >= Unum){
                _SEOSAddr.transfer(msg.sender, temp[2]);
                OutGold  = temp[2].sub(Unum);
                SEOSQuantity  = 0;
            }else{
                uint256 EOSSnum = temp[1].mul(EOSSPrice).div(10000000);
                _SEOSAddr.transfer(msg.sender, EOSSnum);
                SEOSQuantity  = temp[2].sub(EOSSnum);
                OutGold  = 0;
            }
        }
        diviIns.updateTX(id,OutGold,SEOSQuantity,false);
        // diviIns.extensionTX();
    }


   function TXEOS() public {
        operation diviIns = operation(_operation);
        uint256 id = diviIns.getIDByAddress(msg.sender);
        require(id > 0, "isplayer"); 
        uint256[] memory temp = diviIns.getPlayerByAddress(msg.sender);
        uint256 EOSQuantity = 0;
        uint256 OutGold = 0;
        require(temp[3] > 0, "EOS 0"); 
        require(temp[1] > 0, "no player"); 

        if(temp[3]> 0 &&  temp[1]  > 0){

            uint256 EOSPrice  =   Spire_Price(_EOSAddr, _EOSLPAddr);
            uint256 Unum = temp[3].mul(10000000).div(EOSPrice);
            if(temp[1]  >= Unum){
                _EOSAddr.transfer(msg.sender, temp[3]);
                OutGold  = temp[2].sub(Unum);
                EOSQuantity  = 0;
            }else{
                uint256 EOSnum = temp[1].mul(EOSPrice).div(10000000);
                _EOSAddr.transfer(msg.sender, EOSnum);
                EOSQuantity  = temp[3].sub(EOSnum);
                OutGold  = 0;
            }
        }
        diviIns.updateTX(id,OutGold,EOSQuantity,true);
        // diviIns.extensionTX();
    }




  
    // 提取产出（级别）
//    function community() public {

//          operation diviIns = operation(_operation);
//         uint256 id = diviIns.getIDByAddress(msg.sender);
//         require(id > 0, "isplayer"); 
//         uint256 OutGold = 0;

//         uint256[] memory temp = diviIns.getPlayerByAddress(msg.sender);

//         uint256 communitySEOSQuantity = temp[3];
//         uint256 JFcommunitySEOSQuantity =  temp[9];

//         uint256 PlayerOutGold = temp[1];
//         // uint256 PlayercommunitySEOSQuantity = temp[3];
 
//         uint256 JFPlayercommunitySEOSQuantity = temp[9];


//         if(PlayerOutGold > 0){

//             if(JFcommunitySEOSQuantity > 0||communitySEOSQuantity>0){
//                 // if(PlayercommunitySEOSQuantity > 0 &&  PlayerOutGold > 0){
//                 //     uint256 EOSPrice  =   Spire_Price(_EOSAddr, _EOSLPAddr);
//                 //     uint256 EOSnum = PlayercommunitySEOSQuantity.mul(EOSPrice).div(10000000);
//                 //     if(PlayerOutGold >= PlayercommunitySEOSQuantity){
//                 //         _EOSAddr.transfer(msg.sender, EOSnum);
//                 //         OutGold  = PlayerOutGold.sub(PlayercommunitySEOSQuantity);
//                 //         communitySEOSQuantity  = 0;
//                 //     }else{
//                 //         EOSnum = PlayerOutGold.mul(EOSPrice).div(10000000);

//                 //         _EOSAddr.transfer(msg.sender, EOSnum);
//                 //         communitySEOSQuantity  = PlayercommunitySEOSQuantity.sub(PlayerOutGold);
//                 //         OutGold  = 0;
//                 //     }
//                 // }
//                 // if (OutGold>0){
//                 //     PlayerOutGold = OutGold;
//                 // }
//                 if( PlayerOutGold > 0 && JFPlayercommunitySEOSQuantity> 0){

//                     uint256 SEOSPrice  =   Spire_Price(_SEOSAddr, _SEOSLPAddr);
//                     uint256 EOSSnum = PlayercommunitySEOSQuantity.mul(SEOSPrice).div(10000000);
//                     uint256 SEOSnum = JFPlayercommunitySEOSQuantity.mul(SEOSPrice).div(10000000);
//                     if(PlayerOutGold >= JFPlayercommunitySEOSQuantity){
//                         _SEOSAddr.transfer(msg.sender, SEOSnum);
//                         OutGold  = PlayerOutGold.sub(JFPlayercommunitySEOSQuantity);
//                         JFcommunitySEOSQuantity  = 0;
//                     }else{
//                         _SEOSAddr.transfer(msg.sender, EOSSnum);
//                         JFcommunitySEOSQuantity  = JFPlayercommunitySEOSQuantity.sub(PlayerOutGold);
//                         OutGold  = 0;
//                     }
//                 }
        
//                 diviIns.updatecommunity(id,OutGold,communitySEOSQuantity, JFcommunitySEOSQuantity);
//             } 

//         }
        // require(PlayerOutGold > 0, "isCancommunity OutGold"); 

        // require(JFcommunitySEOSQuantity > 0||communitySEOSQuantity>0, "isCancommunity"); 

    
    // }

// 推荐补齐
   function BQ(address recommend) public {
        operation diviIns = operation(_operation);
        uint256 id = diviIns.getIDByAddress(msg.sender);
        uint256 USDT_T_Quantity = 0;
        uint256[] memory temp = diviIns.getPlayerByAddress(msg.sender);
        require(id > 0, "IS");
        uint256 _usdtBalance = _USDTAddr.balanceOf(msg.sender);
        if( temp[4] < 100)
        {
            uint256 SuperPrice = SupernodePrice.sub(SupernodePrice.mul(temp[4]).div(100));
            require(_usdtBalance >= SuperPrice, "9999");
            _USDTAddr.transferFrom(address(msg.sender), address(this), SuperPrice);

            if(temp[5] > 0)
            {
               USDT_T_Quantity = SuperPrice.mul(20).div(100);
            }
            else
            {
                if(temp[6]> 0){
                     USDT_T_Quantity = SuperPrice.mul(15).div(100);
                }
            }
        }
        diviIns.updateBQ(  recommend,   msg.sender,  USDT_T_Quantity);
     }


 function  becomeNode() public         {
         operation diviIns = operation(_operation);

        uint256 _usdtBalance = _USDTAddr.balanceOf(msg.sender);
        require(_usdtBalance >= nodePrice, "9999");
        _USDTAddr.transferFrom(address(msg.sender), address(this), nodePrice);
        _USDTAddr.transfer(Uaddress, nodePrice);
     
         diviIns.updatepbecomeNode(msg.sender);
    }
//  成为超级节点  购买超级节点
  function  becomeSupernode(address recommend) public          {

        operation diviIns = operation(_operation);
        uint256 USDT_T_Quantity = 0;

        uint256[] memory temp = diviIns.getPlayerByAddress(recommend);

         _USDTAddr.transferFrom(address(msg.sender), address(Uaddress), SupernodePrice);

        if(temp[0] > 0){
 
            uint256 _usdtBalance = _USDTAddr.balanceOf(msg.sender);
            require(_usdtBalance >= SupernodePrice, "9999");

            if(temp[5] > 0)
            {
                USDT_T_Quantity = SupernodePrice.mul(20).div(100);
            }
            else{
                if(temp[6] > 0){
                    USDT_T_Quantity = SupernodePrice.mul(15).div(100);
                }
            }
        }
   
         diviIns.updatepbecomeSupernode(recommend,msg.sender,USDT_T_Quantity);
    }

    function setOPAddress(address newaddress) public onlyOwner {
        require(newaddress != address(0));
        _operation = newaddress;
    }
   
   
}