/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

pragma solidity ^0.8.0;
contract TNFT { 
       uint256 latestTokenId;
       function onemint(address recipient_, uint level) external returns(uint256){ 
            uint256 tokenId = _getNextTokenId(); 
            _incrementTokenId();
           return tokenId; 
     }

       function twomint(address recipient_, uint level) external returns(uint256){ 
            uint256 tokenId = _getNextTokenId(); 
            _incrementTokenId();
             return tokenId; 
     }

       function threemint (address recipient_, uint level) external returns(uint256){ 
            uint256 tokenId = _getNextTokenId(); 
            _incrementTokenId();
            return tokenId; 
     }

      function _getNextTokenId() internal view returns (uint256) {
        return latestTokenId + 1;
    }

     function _incrementTokenId() internal {
        latestTokenId++;
    }
}