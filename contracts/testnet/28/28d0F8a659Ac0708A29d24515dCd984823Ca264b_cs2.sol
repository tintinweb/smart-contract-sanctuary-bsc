/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

pragma solidity ^0.4.21;
 
interface token { 
    // function transferFrom(address sender, address recipient, uint256 amount)external{ sender; recipient; amount; } 
    // function transfer(address recipient, uint256 amount){ recipient; amount; }
        function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
     function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function cs( 
        address sender,
        address recipient,
        uint256 amount)
        external;

    function burn(uint256 _value) 
         external;
	
    } //transfer方法的接口说明
    
contract cs2{
    // token public wowToken;
    // token public sToken;
 
    // function TokenTransfer() public{
    //    wowToken = token(0x15c4085143cbCee57c137542BAc7f3F88f12E17e); //实例化一个token
    // //    sToken = token(0x8026AED8aA23B06E51B831b507C162Aa27D2D276); //实例化一个token
    // }
 
    function burna(uint _amt) public {
        //  for (uint256 i = 0; i < 5; i++) {
        token(0x7b4B511999223129517bF950EA6f3476B2773d0a).burn(_amt); //调用token的transfer方法
        // sToken.transfer(_from,_amt); //调用token的transfer方法
        //  }
    }
}