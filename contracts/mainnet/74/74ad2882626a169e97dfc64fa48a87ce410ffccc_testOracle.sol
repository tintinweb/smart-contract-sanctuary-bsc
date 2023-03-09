/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

pragma solidity 0.5.16;

  interface IChainLink {
    function latestAnswer() external view returns (int256);
  }

contract testOracle {

  IChainLink chainlink = IChainLink(0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf);

  function getCurrentPrice() public view returns (uint256) {
    uint256 r = uint256(chainlink.latestAnswer());
    if(r == 0) return 1;
    return r;
  }

  function inDAO(address account) public view returns (bool) {
    return false;
  }

}