/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage {

    uint256 public number;
    uint256 public total;
    string public id;
    string public itemType;
    string public extraType;
    uint256 public price;
    address public tokenAddress;
    string public nonce;
    bytes public signature;

    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function store(uint256 num) public {
        number = num;
    }

     function totalFourNumber(uint256 num1, uint256 num2, uint256 num3, uint256 num4) public {
         total = num1 + num2 + num3 + num4;

     }
    function retrieve() public view returns (uint256){
        return number;
    }

    function retrieveTotal() public view returns (uint256) {
        return total;
    }

    function testRedeem(string memory id_1, string memory itemType_1, string memory extraType_1, uint256 price_1, address tokenAddress_1, string memory nonce_1, bytes calldata signature_1) public {
        id = id_1;
        itemType = itemType_1;
        extraType = extraType_1;
        price = price_1;
        tokenAddress = tokenAddress_1;
        nonce = nonce_1;
        signature = signature_1;
    }
}