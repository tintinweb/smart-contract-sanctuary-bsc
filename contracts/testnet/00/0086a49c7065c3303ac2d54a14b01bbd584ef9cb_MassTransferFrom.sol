/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

pragma solidity =0.6.12;
// SPDX-License-Identifier: MIT

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC721Enumerable {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function balanceOf(address owner) external view returns (uint256 balance);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
}



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}

contract MassTransferFrom {

   function transferFromNft(IERC721Enumerable _nftToken,address _from,address _to,uint256 _num) external  {
       require(msg.sender == _from,"k0");
       require(_nftToken.balanceOf(_from)>=_num,"k1");
       for (uint256 i=0;i<_num;i++) {
           uint256 _token_id = _nftToken.tokenOfOwnerByIndex(_from,0);
           _nftToken.transferFrom(_from,_to,_token_id) ;
       }
   }
   
   function massTransferFromNft(IERC721Enumerable _nftToken,address _from,address[] memory _toList,uint256 _num) external  {
       uint256 toNum = _toList.length;
       require(msg.sender == _from,"k0");
       require(_nftToken.balanceOf(_from)>=_num*toNum,"k1");
       for (uint256 i=0;i<toNum;i++) {
           address _to = _toList[i];
           for (uint256 j=0;j<_num;j++) {
                uint256 _token_id = _nftToken.tokenOfOwnerByIndex(_from,0);
               _nftToken.transferFrom(_from,_to,_token_id) ;
           }
       }
    }
    
    function massTransferFromNft2(IERC721Enumerable _nftToken,address _from,address[] memory _toList,uint256[] memory _numList) external  {
       require(_toList.length == _numList.length);
       require(msg.sender == _from,"k0");
       uint256 total = 0;
       for (uint256 i=0;i<_numList.length;i++) {
           total = total+_numList[i];
       }
       require(_nftToken.balanceOf(_from)>=total,"k1");
       for (uint256 i=0;i<_toList.length;i++) {
          address _to = _toList[i];
          uint256 _num = _numList[i];
          for (uint256 j=0;j<_num;j++) {
                uint256 _token_id = _nftToken.tokenOfOwnerByIndex(_from,0);
               _nftToken.transferFrom(_from,_to,_token_id) ;
           }
      }
    }
}