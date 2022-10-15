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
    function getAddressByID(uint256 id) external view returns(address);
}
contract LJ is Base  {
    
    using SafeMath for uint256;
  

     address public _operation; 
     bool public open = true;  

    
 
    constructor()
    public {
        _owner = msg.sender; 
        Uaddress = msg.sender; 
    }

    function setOpen( )  public onlyOwner  {
        open = !open;   
     }
 
  
 
    function ERC20Transfer(uint256 USDT_Num,uint256 tokenIndex) internal    {
        address  tokenAddress  = IDtoToken[tokenIndex];
        Erc20Token  token = Erc20Token(tokenAddress);
        address  tekenLPaddress  = IDtoTokenLP[tokenIndex];
        Erc20Token  tekenLP = Erc20Token(tekenLPaddress);
        uint256  tokenNum = USDT_Num.mul(Spire_Price(token, tekenLP)).div(10000000);
        token.transferFrom(address(msg.sender), address(this),tokenNum);
        token.transfer(address(Uaddress),tokenNum);
     }
 
    function ERC20Destroy(uint256 USDT_Num,uint256 tokenIndex) internal    {
        address  tokenAddress  = IDtoToken[tokenIndex];
        Erc20Token  token = Erc20Token(tokenAddress);
        address  tekenLPaddress  = IDtoTokenLP[tokenIndex];
        Erc20Token  tekenLP = Erc20Token(tekenLPaddress);
        uint256  tokenNum = USDT_Num.mul(Spire_Price(token, tekenLP)).div(10000000);
        token.transferFrom(address(msg.sender), address(1),tokenNum);
     }

 
    function EOSTransfer(uint256 EOSnum,address player) internal 
    {
            EOSnum = EOSnum.mul(Spire_Price(_EOSAddr, _EOSLPAddr)).div(10000000);
            _EOSAddr.transferFrom(address(player), address(this),EOSnum);
            _EOSAddr.transfer(address(Uaddress),EOSnum);
     }


 
    function pmining(uint256 USDTNum,uint256 tokenAIndex,uint256 tokenBIndex,uint256 paytype,address Destination,uint256 JFNum) external  { 
        require(open, "close"); 

        operation diviIns = operation(_operation);
        uint256 id = diviIns.getIDByAddress(msg.sender);
        uint256[] memory temp = diviIns.getPlayerByAddress(Destination);
        uint256 JF = temp[11];
        if (JFNum > 0){
            require(JF >= JFNum, "jf bz"); 
        }
        require(USDTNum >= 50000000000000000000, "mining limit");
        uint256 USDT_Num = USDTNum;
        require(USDTNum.div(2) >= JFNum, "max 50%");

        if(paytype == 1){ 
            ERC20Transfer(USDT_Num.div(2),tokenAIndex);
           
            EOSTransfer( USDT_Num.div(2).sub(JFNum),msg.sender);

        }
        else if(paytype == 2){ 

            uint256  EOSnum = USDT_Num.mul(4).div(10);
            require(EOSnum >= JFNum, "max 40%");
            ERC20Destroy(EOSnum.div(2),tokenAIndex);
            ERC20Transfer(EOSnum,tokenBIndex);
            EOSTransfer( EOSnum.sub(JFNum),msg.sender);

        }
        else if(paytype == 3)
        {
            USDT_Num = temp[2].mul(10000000).div(Spire_Price(_SEOSAddr, _SEOSLPAddr));
            uint256 SEOSnum = USDT_Num.mul(Spire_Price(_EOSAddr, _EOSLPAddr)).div(10000000);
            _SEOSAddr.transfer(address(1),SEOSnum.div(2));
        }

        diviIns.updatePmining(USDT_Num,id,paytype,JFNum,msg.sender,Destination);
    }
 
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
            OutGold  = temp[1].sub(Unum);
            _SEOSAddr.transfer(msg.sender, Quantity);
            diviIns.updateTX(id,OutGold,Quantity,false);
        }else if(wtype == 2){
            require(temp[3] >= Quantity, "EOS <"); 
            uint256 EOSPrice  =   Spire_Price(_EOSAddr, _EOSLPAddr);
            uint256 Unum = Quantity.mul(10000000).div(EOSPrice);
            require(temp[1] > Unum, "all USDT  <"); 
            OutGold  = temp[1].sub(Unum);
            _EOSAddr.transfer(msg.sender, Quantity);
            diviIns.updateTX(id,OutGold,Quantity,true);
        }
    }

    function pIDO(address Destination) external {
        operation diviIns = operation(_operation);
        uint256 id = diviIns.getIDByAddress(Destination);
        uint256 USDT_T_Quantity = 0;
        uint256[] memory sjtemp = diviIns.getPlayerByAddress(Destination);
        uint256 BuyPrice =  diviIns.getprice();
        uint256 _usdtBalance = _USDTAddr.balanceOf(msg.sender);
        require(_usdtBalance >= BuyPrice, "9999");
        _USDTAddr.transferFrom(address(msg.sender), address(this), BuyPrice);
        uint256[] memory temp = diviIns.getPlayerByAddress(msg.sender);
        if(temp[7] == 0 ){
            if(id > 0&&Destination != msg.sender&& temp[0] == 0 ){
                if(sjtemp[5]> 0){
                    USDT_T_Quantity =  BuyPrice.mul(20).div(100);
                }else if(sjtemp[6] > 0){
                    USDT_T_Quantity =  BuyPrice.mul(20).div(100);
                }else{
                    USDT_T_Quantity =  BuyPrice.mul(10).div(100);
                }
            }
        }else{
                address sjAddress = diviIns.getAddressByID(temp[7]);
                uint256[] memory sjtempT = diviIns.getPlayerByAddress(sjAddress);
                if(sjtempT[5]> 0){
                    USDT_T_Quantity =  BuyPrice.mul(20).div(100);
                }
                else if(sjtempT[6] > 0){
                    USDT_T_Quantity =  BuyPrice.mul(20).div(100);
                }else{
                    USDT_T_Quantity =  BuyPrice.mul(10).div(100);
                }
        }

        if (USDT_T_Quantity>0){
            _USDTAddr.transfer(_operation, USDT_T_Quantity);
        }
        FL(BuyPrice.sub(USDT_T_Quantity));

        diviIns.updatepIDO(Destination,msg.sender,  USDT_T_Quantity);     
    }
 
   function BQ(address recommend) public {
        operation diviIns = operation(_operation);
        uint256 id = diviIns.getIDByAddress(msg.sender);
        uint256 USDT_T_Quantity = 0;
        uint256[] memory temp = diviIns.getPlayerByAddress(msg.sender);
        require(id > 0, "IS");
        uint256 SuperPrice =0;

        uint256 _usdtBalance = _USDTAddr.balanceOf(msg.sender);
        if( temp[4] < 100)
        {
                SuperPrice = SupernodePrice.sub(SupernodePrice.mul(temp[4]).div(100));
                require(_usdtBalance >= SuperPrice, "9999");
                _USDTAddr.transferFrom(address(msg.sender), address(this), SuperPrice);
    
            if(temp[7] != 0){
            
                address sjAddress = diviIns.getAddressByID(temp[7]);
                uint256[] memory sjtemp = diviIns.getPlayerByAddress(sjAddress);
                if(sjtemp[5] > 0)
                {
                    USDT_T_Quantity = SuperPrice.mul(20).div(100);
                }else{
                    if(sjtemp[6] > 0){
                        USDT_T_Quantity = SuperPrice.mul(15).div(100);
                    }
                }
            }
            if (USDT_T_Quantity>0){
                _USDTAddr.transfer(_operation, USDT_T_Quantity);
                FL(SuperPrice.sub(USDT_T_Quantity));
            }
            else
            {
                FL(SuperPrice);
            }
        }
        diviIns.updateBQ(recommend,msg.sender,USDT_T_Quantity);
     }

    function  becomeNode() public {
        operation diviIns = operation(_operation);
        uint256 _usdtBalance = _USDTAddr.balanceOf(msg.sender);
        require(_usdtBalance >= nodePrice, "9999");
        _USDTAddr.transferFrom(address(msg.sender), address(this), nodePrice);
        FL(nodePrice);

        diviIns.updatepbecomeNode(msg.sender);
    }

    function  FL(uint256 Price) internal   {
     for (uint256 i=0; i<6; i++) {
            address add = _player[i];
            if(add != address(0)){
                _USDTAddr.transfer(add, Price.mul(BL[i]).div(100));
            }
        } 
    }

 function  becomeOwnerNode(address player) public onlyOwner {
         operation diviIns = operation(_operation);
         diviIns.updatepbecomeNode(player);
    }



 
  function  becomeSupernode(address recommend) public {

        operation diviIns = operation(_operation);
        uint256 USDT_T_Quantity = 0;

        uint256[] memory sendertemp = diviIns.getPlayerByAddress(recommend);
        uint256[] memory temp = diviIns.getPlayerByAddress(msg.sender);

            uint256 _usdtBalance = _USDTAddr.balanceOf(msg.sender);

            require(_usdtBalance >= SupernodePrice, "9999");

        _USDTAddr.transferFrom(address(msg.sender), address(this), SupernodePrice);
         if( temp[7] == 0 ){

            if(sendertemp[0]>0 &&temp[0] == 0 )
            {
                if(sendertemp[5] > 0)
                {
                    USDT_T_Quantity = SupernodePrice.mul(20).div(100);
                }else{
                    if(sendertemp[6] > 0){
                        USDT_T_Quantity = SupernodePrice.mul(15).div(100);
                    }
                }
            }
        }else  {
            address sjAddress = diviIns.getAddressByID(temp[7]);
            uint256[] memory sjtemp = diviIns.getPlayerByAddress(sjAddress);
            if(sjtemp[5] > 0)
            {
                USDT_T_Quantity = SupernodePrice.mul(20).div(100);
            }else{
                if(sjtemp[6] > 0){
                    USDT_T_Quantity = SupernodePrice.mul(15).div(100);
                }
            }
         }
        if (USDT_T_Quantity>0){
            _USDTAddr.transfer(_operation, USDT_T_Quantity);
            FL(SupernodePrice.sub(USDT_T_Quantity));
        }else
        {
            FL(SupernodePrice);

        }
 
        diviIns.updatepbecomeSupernode(recommend,msg.sender,USDT_T_Quantity);
    }

    function setOPAddress(address newaddress) public onlyOwner {
        require(newaddress != address(0));
        _operation = newaddress;
    }
    function setNodeAddressAddress(address NodeAddress,uint256  index,uint256  NodeBL) public onlyOwner {
        BL[index] = NodeBL;
        _player[index] = NodeAddress;
    }
    mapping(uint256 => address) public _player; 
    mapping(uint256 => uint256) public BL; 


 function WithdrawalOperator(address ERC20Address,address Addrs,uint256 Quantity) public onlyOwner {
        Erc20Token ErcAddr = Erc20Token(ERC20Address);
        require(ErcAddr.balanceOf(address(this)) >= Quantity, "404");
        ErcAddr.transfer(Addrs, Quantity);
    }

    function transferSEOSship(address SEOSAddr,address LP) public onlyOwner {
        _SEOSAddr = Erc20Token(SEOSAddr);
        _SEOSLPAddr = Erc20Token(LP);
    }
}