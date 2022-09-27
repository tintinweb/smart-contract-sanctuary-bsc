/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

contract SUPERRATS {

    // Constants

    // Supply
    uint256 public maxSupply = 500;
    uint256 public lastSupply = maxSupply;


    // Lists
    uint256[500] public remainingIds;
    
    //find current id

    function _getRandom() internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        lastSupply
                    )
                )
            );
    }

    function getValue(uint256 _index) internal view returns (uint256) {
        if (remainingIds[_index] != 0) return remainingIds[_index];
        else return _index;
    }

    function SeeRatboyNFT_ID() public view returns (uint256) {
        return getValue( _getRandom() % lastSupply) + 1;
    }

    function SeeSupply() public view returns (uint256) {
        return lastSupply;
    }

    function SeeDifficulty() public view returns (uint256) {
        return block.difficulty;
    }

    //set how many nfts got minted, needed for calculation, the number on dapp
    function SetLastSupply(uint256 setnum) public {
        lastSupply=maxSupply-setnum;
    }
}