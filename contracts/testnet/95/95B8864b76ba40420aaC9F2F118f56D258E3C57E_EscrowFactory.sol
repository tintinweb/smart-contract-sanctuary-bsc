// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./escrow.sol";

contract EscrowFactory {

    event NewDeal(address _newContractAddress);

    Escrow[] private _escrowsArray;

    function createEscrow() public returns(address) {
        Escrow escrow = new Escrow();
        _escrowsArray.push(escrow); 
        emit NewDeal(address(escrow));
        return address(escrow);
    }

   function getEscrowAddress(uint256 _index) public view returns (address) {
        return address(_escrowsArray[_index]);
    }
}