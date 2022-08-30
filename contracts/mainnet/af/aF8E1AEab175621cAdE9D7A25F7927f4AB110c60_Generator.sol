/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 */
contract Cloneable {

    /**
        @dev Deploys and returns the address of a clone of address(this
        Created by DeFi Mark To Allow Clone Contract To Easily Create Clones Of Itself
        Without redundancy
     */
    function clone() external returns(address) {
        return _clone(address(this));
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function _clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

}

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

interface IStaking {
    function __init__(address TeamWallet_, address thotty_, address owner_) external;
}

contract Generator is Ownable {

    mapping ( address => address ) public getThottyContract;

    address public teamWallet;

    address public implementation;

    event ThottyCreated(address thot, address thotContract);

    constructor(address teamWallet_, address implementation_) {
        teamWallet = teamWallet_;
        implementation = implementation_;
    }

    function setTeamWallet(address newWallet) external onlyOwner {
        teamWallet = newWallet;
    }

    function setImplementation(address implementation_) external onlyOwner {
        implementation = implementation_;
    }

    function createThottyWallet(address thotty) external onlyOwner returns (address) {
        require(
            thotty != address(0),
            'Zero Address'
        );
        
        // clone thotty
        address thottyContract = Cloneable(implementation).clone();

        // init thotty
        IStaking(thottyContract).__init__(teamWallet, thotty, this.getOwner());

        // register thotty
        getThottyContract[thotty] = thottyContract;

        // emit event
        emit ThottyCreated(thotty, thottyContract);

        return thottyContract;
    }

}