/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.4.23 <0.9.0;

contract Foundation {
    string public name;
    address public owner;

    constructor(
        string memory _name,
        address _owner
    ) public {
        name = _name;
        owner = _owner;
    }
    
}

contract FoundationFactory {
    Foundation[] private _foundations;
    function createFoundation(
        string memory name
    ) public returns (address) {
        Foundation foundation = new Foundation(
            name,
            msg.sender
        );

        _foundations.push(foundation);

        return address(foundation);
    }
    
    function allFoundations(uint256 limit, uint256 offset)
        public
        view
        returns (Foundation[] memory coll)
    {
        return coll;
    }
}