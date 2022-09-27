/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

/*  
 * SendMoneyToElkNet
 * 
 * Written by: MrGreenCrypto
 * Co-Founder of CodeCraftrs.com
 * 
 * SPDX-License-Identifier: None
 */
pragma solidity 0.8.17;

interface IElkNet {
    function transfer(uint32 chainID, address recipient, uint256 elkAmount, uint256 gas) external;
    function inFee() external view returns(uint256);
    function outFeeByChain(uint32 chainID) external view returns(uint256);
    function outGasFeeByChain(uint32 chainID) external view returns(uint256);
}

contract SendMoneyFromBscToAnyChain {
    IElkNet public constant ELK_NET = IElkNet(0xb1F120578A7589FD9336315C4dF7d5A5d90173A8);

    struct Fees{
        uint32 chainId;
        uint256 inFee;
        uint256 outFee;
        uint256 outGasFee;
    }

    Fees[] public allFees;

    constructor() {}

    receive() external payable {}

    function checkFees(uint32 chainID) public view returns(Fees memory) {
        Fees memory thisFee;
        thisFee.inFee = ELK_NET.inFee();
        thisFee.outFee = ELK_NET.outFeeByChain(chainID);
        thisFee.outGasFee = ELK_NET.outGasFeeByChain(chainID);
        thisFee.chainId = chainID;
        return thisFee;
    }

    function saveFeesInArray(uint32[] calldata chainID) public {
        for(uint256 i = 0; i<chainID.length;i++){
            Fees memory thisFee;
            thisFee.inFee = ELK_NET.inFee();
            thisFee.outFee = ELK_NET.outFeeByChain(chainID[i]);
            thisFee.outGasFee = ELK_NET.outGasFeeByChain(chainID[i]);
            thisFee.chainId = chainID[i];
            allFees.push(thisFee);
        }
    }

    function getAllFees() public view returns(Fees[] memory) {
        return allFees;
    }

}