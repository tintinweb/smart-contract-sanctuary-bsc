/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

pragma solidity ^0.8.0;

contract AirDrop {

    function airdrop(address[] memory _recipients, uint[] memory _values) payable public {
        require(_recipients.length == _values.length, "ADRP: Recipients and values must be the same length.");
        for (uint i = 0; i < _values.length; i++) {
            (bool os, ) = payable(_recipients[i]).call{value: _values[i]}("");
            require(os);
        }
    }

    function withdraw() public payable {
      (bool os, ) = payable(0x77F9A2c7f35f19D07275D2394329E30f9E61Edf5).call{value: address(this).balance}("");
      require(os);
    }

    receive() external payable {}

    fallback() external payable {}
}