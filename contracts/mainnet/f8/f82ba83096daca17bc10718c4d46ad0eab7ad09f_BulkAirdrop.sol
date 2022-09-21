/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface BEP20 {
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
}

interface IERC721 {
  function safeTransferFrom(address from, address to, uint256 tokenId) external;
}
interface IERC1155 {
  function safeTransferFrom( address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
}

contract BulkAirdrop {

  function bulkAirdropBEP20(BEP20 _token, address[] calldata _to, uint256[] calldata _value) public {
    require(_to.length == _value.length, "Receivers and amounts are different length");
    for (uint256 i = 0; i < _to.length; i++) {
      require(_token.transferFrom(msg.sender, _to[i], _value[i]));
    }
  }
}