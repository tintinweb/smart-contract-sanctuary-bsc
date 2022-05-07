/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;



interface bean {
    function transferFrom(address src, address dst, uint wad) external returns (bool);
}

interface egg {
    function goldenEggTransferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}


contract PledgeRunMain {
    bean be = bean(0x79209967d6D90836D85fa10c07fD640d03165767);
    egg eg = egg(0xD027F342d3FE984ee62A878F2f966F99413021C5);

    // when to calculate egg
    uint32 public sinceTs = uint32(block.timestamp);

    uint public nextEgg;

    uint256 public constant maxSupply = 300000;

    uint8 public constant decimals = 18;

    address private _owner;

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    function setUpSinceTs() onlyOwner external {
        sinceTs = uint32(block.timestamp);
    }

    function getPledgeable() public view returns (uint256) {
        uint256 deltaSeconds = block.timestamp - sinceTs;
        if (deltaSeconds >= 86400) {
            if ((((deltaSeconds / 86400) * 10000) + 10000) >= maxSupply) {
                return maxSupply;
            }
            return ((deltaSeconds / 86400) * 10000) + 10000;
        } else {
            return 10000;
        }
    }

    function stakingMining(uint256 numberOfToken) external {
        require(tx.origin == _msgSender(), "Only EOA");
        require(numberOfToken > 0);
        require(nextEgg + numberOfToken <= maxSupply);
        // pledgeable
        require(nextEgg + numberOfToken <= getPledgeable());
        uint256 totalBeansCost = 0;
        for (uint i = 0; i < numberOfToken; i++) {
            nextEgg++;
            totalBeansCost += mintCost(nextEgg);
        }
        eg.goldenEggTransferFrom(_msgSender(), address(this), numberOfToken * 1 * 10 ** uint256(decimals));
        //TODO  address为持币人
        be.transferFrom(address(0xF0C509199d6C8D75a241921840d1a959b349BAb0), _msgSender(), totalBeansCost);
    }

    /** 
    * the next 50% are 100000 $BEAN
    * the final 50% are 50000 $BEAN
    * @param tokenId the ID to check the cost of to mint
    * @return the cost of the given token ID
    */
    function mintCost(uint256 tokenId) public view returns (uint256) {
        if (tokenId <= maxSupply / 2) return 100000 * 10 ** uint256(decimals);
        if (tokenId <= maxSupply) return 50000 * 10 ** uint256(decimals);
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

}