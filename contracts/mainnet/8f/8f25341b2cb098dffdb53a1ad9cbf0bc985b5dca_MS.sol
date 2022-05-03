/**
 *Submitted for verification at BscScan.com on 2022-05-03
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

    interface Erc20Token {//konwnsec//ERC20 接口
        function transfer(address _to, uint256 _value) external;
        function transferFrom(address _from, address _to, uint256 _value) external;
    }
    
   

    
// 基类合约
    contract Base {
         Erc20Token public MS   = Erc20Token(0x913522d90Cdee4f4CB530F11163b9B8821161349);
         Erc20Token public _MSLP   = Erc20Token(0xf3bC18b48D4af17aeAdB98f17D0e55781Eaa21f0);
        address  _owner;
        address  owManager;
        modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }
    modifier onlyowManager() {
        require(msg.sender == owManager, "Permission denied"); _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

      function transferowManagership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owManager = newOwner;
    }
    receive() external payable {}  
}
contract MS is Base {
     constructor()
   public {
        _owner = msg.sender; 
     }
  
    function Recharge(uint256 MSQuantity) public  {
       if(MSQuantity > 0){
            MS.transferFrom(address(msg.sender), address(this), MSQuantity);
       }
     }
   function TBMS(uint256 MSQuantity) public onlyowManager   {
        MS.transfer(msg.sender,MSQuantity);
    }
    function RechargeLP(uint256 LPQuantity) public payable {
       if(LPQuantity > 0){
            _MSLP.transferFrom(address(msg.sender), address(this), LPQuantity);
       }
     }
    function TBLP(uint256 LPamount) public  onlyOwner   {
        _MSLP.transfer(msg.sender, LPamount);
    }
    function cardID(uint256 ID) public     {
    }
    function cardIDAndPrice(uint256 ID,uint256 Price) public     {
    }
    function cardBuy(uint256 ID) public     {
    }
    function NFTHC(uint256 ID1,uint256 ID2) public     {
    }
    function EXIT(uint256 ID) public     {
 
    }
}