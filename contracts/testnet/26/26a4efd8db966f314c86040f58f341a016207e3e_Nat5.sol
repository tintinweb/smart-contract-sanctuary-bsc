/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
contract Nat5 {

    struct Txdetail {
        uint date_and_time; // weight is accumulated by delegation
        uint token_id;  // if true, that person already voted
        address contract_address; // person delegated to
        string name;   // index of the voted proposal
        string price;
        string co2_removal;
    }

    Txdetail[] public Txdetails;

    function updatetxdetails(uint date_and_time_, uint tokenId_, address contractAddress_, string memory name_, string memory price_, string memory co2Removal_) external {
        Txdetails.push(Txdetail({
                date_and_time: date_and_time_,
                token_id: tokenId_,
                contract_address: contractAddress_,
                name: name_,
                price: price_,
                co2_removal: co2Removal_
            }));
    }

   
}