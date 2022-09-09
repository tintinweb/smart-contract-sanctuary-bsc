/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
}

contract Modifier {
    address internal owner; // Constract creater
    address internal approveAddress;

    modifier onlyOwner(){
        require(msg.sender == owner, "Modifier: The caller is not the creator");
        _;
    }

    modifier onlyApprove(){
        require(msg.sender == approveAddress || msg.sender == owner, "Modifier: The caller is not the approveAddress");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setApproveAddress(address externalAddress) public onlyOwner(){
        approveAddress = externalAddress;
    }

    /*
     * @dev Get approve address
     */
    function getApproveAddress() internal view returns(address){
        return approveAddress;
    }

    fallback () payable external {}
    receive () payable external {}
}

contract MobiusBatchTransfer is Modifier {

    ERC20 private mobToken;

    constructor() {
        mobToken = ERC20(0x0Ab6Be2477B4eCd7501bF8469a1bA06B7Da5cfba);
    }

    function setMobToken(address _token) public onlyOwner {
        mobToken = ERC20(_token);
    }

    function transfer(address [] memory addressList, uint256 [] memory amountToWei) public onlyApprove {
        for(uint8 i=0; i<addressList.length; i++) {
            mobToken.transfer(addressList[i], amountToWei[i]);
        }
    }

    function transferAmount(address [] memory addressList, uint256 [] memory amountToWei) public onlyApprove {
        for(uint8 i=0; i<addressList.length; i++) {
            mobToken.transfer(addressList[i], amountToWei[i]);
        }
    }

}