/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;



interface beans {
    function transferFrom(address src, address dst, uint wad) external returns (bool);
    function ownerTokenCfo() external view returns(address);
    function burn(address from, uint256 amount) external;
}


contract pledgeRunMain {
    beans be = beans(0x27f8125c2cc73667A88EB941586A78863e3B2514);

    // when to calculate egg
    uint32 public sinceTs;

    uint public nextEgg;

    uint256 public constant maxSupply = 1000000;

    //质押开始时间
    function setUpSinceTs() external {
        sinceTs = uint32(block.timestamp);
    }

    function getPledgeable() public view returns (uint256) {
        // uint256 deltaSeconds = block.timestamp - sinceTs;
        uint256 deltaSeconds = 259199;
        if (deltaSeconds >= 86400) {
            return (deltaSeconds / 86400) * 10000;
        } else {
            return 10000;
        }
    }

    function stakingMining(uint256 numberOfToken) external {
        require(tx.origin == _msgSender(), "Only EOA");
        require(nextEgg + numberOfToken <= maxSupply);
        // pledgeable
        require(nextEgg + numberOfToken <= getPledgeable());
        uint256 totalBeansCost = 0;
        for (uint i = 0; i < numberOfToken; i++) {
            nextEgg++;
            totalBeansCost += mintCost(nextEgg);
        }
        //TODO 
        be.transferFrom(address(this), _msgSender(), totalBeansCost);
    }

    /** 
    * the next 50% are 40000 $BEANS
    * the final 50% are 20000 $BEANS
    * @param tokenId the ID to check the cost of to mint
    * @return the cost of the given token ID
    */
    function mintCost(uint256 tokenId) public view returns (uint256) {
        if (tokenId <= maxSupply / 2) return 40000 ether;
        if (tokenId <= maxSupply) return 20000 ether;
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

}