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
    function  updatePmining(uint256 USDT_Num,uint256 id,uint256 paytype,uint256 JF,address SEOSPlayerAddress,address Destination) external;
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
     function EOSTransfer(uint256 EOSnum,address player) internal 
    //  returns(uint256 )
      {

        // operation diviIns = operation(_operation);
 
        // uint256[] memory temp = diviIns.getPlayerByAddress(player);
        // uint256 integral = temp[11];


  
        // if(integral > 0) {


        // if(integral >= EOSnum){
        //     integral = integral.sub(EOSnum);

        // }else{
        //     uint256 SYintegral = EOSnum.sub(integral);
        //     SYintegral = SYintegral.mul(Spire_Price(_EOSAddr, _EOSLPAddr)).div(10000000);
        //     integral = 0;
        //     _EOSAddr.transferFrom(address(player), address(this),SYintegral);
        //     _EOSAddr.transfer(address(Uaddress),SYintegral);
        // }
        //     }
        //     else{
             EOSnum = EOSnum.mul(Spire_Price(_EOSAddr, _EOSLPAddr)).div(10000000);
            _EOSAddr.transferFrom(address(player), address(this),EOSnum);
            _EOSAddr.transfer(address(Uaddress),EOSnum);
    // }
    
   

        // return integral;
     }



// 挖矿投资
    function pmining(uint256 USDTNum,uint256 tokenAIndex,uint256 tokenBIndex,uint256 paytype,address Destination) external { 
        operation diviIns = operation(_operation);
        uint256 id = diviIns.getIDByAddress(msg.sender);

        uint256[] memory temp = diviIns.getPlayerByAddress(msg.sender);


 
        require(USDTNum >= 50000000000000000000, "mining limit");


        uint256 USDT_Num = USDTNum;

        if(paytype == 1){//一半U一半EOS

            EOSTransfer( USDT_Num.div(2),msg.sender);
            ERC20Transfer(USDT_Num.div(2),tokenAIndex);

            // _USDTAddr.transferFrom(address(msg.sender), address(this), USDT_Num.div(2));
            // _USDTAddr.transfer( address(Uaddress), USDT_Num.mul(4).div(10));

        }else if(paytype == 2){// 40%  eos  20%代币A 40%代币B
            uint256  EOSnum = USDT_Num.mul(4).div(10);
             EOSTransfer( EOSnum,msg.sender);
            ERC20Destroy(EOSnum.div(2),tokenAIndex);
            ERC20Transfer(EOSnum,tokenBIndex);
        }else if(paytype == 3)//复投
        {
            USDT_Num = temp[2].mul(10000000).div(Spire_Price(_SEOSAddr, _SEOSLPAddr));

            uint256 SEOSnum = USDT_Num.mul(Spire_Price(_EOSAddr, _EOSLPAddr)).div(10000000);

            _SEOSAddr.transfer(address(1),SEOSnum.div(2));

        }
        diviIns.updatePmining(USDT_Num,id,paytype,0,msg.sender,Destination);
    }
  


// 挖矿投资
    function pminingJF(uint256 USDTNum,uint256 tokenAIndex,uint256 JFNum,address Destination) external { 
        operation diviIns = operation(_operation);
        uint256 id = diviIns.getIDByAddress(msg.sender);
        require(id > 0, "isplayer"); 
        // SEOSPlayer  memory  player = diviIns.getplayerinfo(  msg.sender);

        uint256[] memory temp = diviIns.getPlayerByAddress(msg.sender);

        uint256 JF = temp[11];

 
        require(USDTNum >= 50000000000000000000, "mining limit");
        require(USDTNum.div(2) >= JFNum, "max 50%");
        require(JF >= JFNum, "integral out max ");


        uint256 USDT_Num = USDTNum;

   


        uint256 SYintegral = USDTNum.sub(JFNum);
            // SYintegral = SYintegral.mul(Spire_Price(_EOSAddr, _EOSLPAddr)).div(10000000);



          EOSTransfer( SYintegral,msg.sender);
        ERC20Transfer(USDT_Num.div(2),tokenAIndex);
     
        diviIns.updatePmining(USDT_Num,id,4,JFNum,msg.sender,Destination);
    }
  










// 提取产出（挖矿）
   function TXSEOSOrEos(uint256 Quantity ,uint256 wtype) public {
        operation diviIns = operation(_operation);
        uint256 id = diviIns.getIDByAddress(msg.sender);
        require(id > 0, "isplayer"); 
        uint256[] memory temp = diviIns.getPlayerByAddress(msg.sender);
 
        uint256 OutGold = 0;
        require(temp[1] > 0, "isplayer"); 


        if( wtype == 1){

             require(temp[2] >= Quantity, "SEOS <"); 

            uint256 EOSSPrice  =   Spire_Price(_SEOSAddr, _SEOSLPAddr);

            uint256 Unum = Quantity.mul(10000000).div(EOSSPrice);
            require(temp[1] > Unum, "all USDT  <"); 
            OutGold  = temp[2].sub(Unum);
            _SEOSAddr.transfer(msg.sender, Quantity);
            diviIns.updateTX(id,OutGold,Quantity,false);

       
        }else if( wtype == 2){

             require(temp[3] >= Quantity, "EOS <"); 

            uint256 EOSPrice  =   Spire_Price(_EOSAddr, _EOSLPAddr);

            uint256 Unum = Quantity.mul(10000000).div(EOSPrice);
            require(temp[1] > Unum, "all USDT  <"); 
            OutGold  = temp[2].sub(Unum);
            _EOSAddr.transfer(msg.sender, Quantity);


            diviIns.updateTX(id,OutGold,Quantity,true);


        }
 
    }


//    function TXEOS(uint256 Quantity) public {
//         operation diviIns = operation(_operation);
//         uint256 id = diviIns.getIDByAddress(msg.sender);
//         require(id > 0, "isplayer"); 
//         uint256[] memory temp = diviIns.getPlayerByAddress(msg.sender);
//         uint256 EOSQuantity = 0;
//         uint256 OutGold = 0;
//         require(temp[3] > Quantity, "EOS <"); 
//         require(temp[1] > 0, "no player"); 
//         uint256 EOSPrice  =   Spire_Price(_EOSAddr, _EOSLPAddr);

//         uint256 EOSnum = Quantity.mul(EOSPrice).div(10000000);

//         if(temp[3]> Quantity &&  temp[1]  > 0){

//             uint256 Unum = temp[3].mul(10000000).div(EOSPrice);
//             if(temp[1]  >= Unum){
//                 _EOSAddr.transfer(msg.sender, temp[3]);
//                 OutGold  = temp[2].sub(Unum);
//                 EOSQuantity  = 0;
//             }else{
//                 uint256 EOSnum = temp[1].mul(EOSPrice).div(10000000);
//                 _EOSAddr.transfer(msg.sender, EOSnum);
//                 EOSQuantity  = temp[3].sub(EOSnum);
//                 OutGold  = 0;
//             }
//         }
//         diviIns.updateTX(id,OutGold,EOSQuantity,true);

//     }





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