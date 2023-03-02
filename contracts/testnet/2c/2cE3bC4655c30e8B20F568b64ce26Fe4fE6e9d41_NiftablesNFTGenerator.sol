//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Ownable.sol";

interface NiftablesNFT {
    function clone() external returns (address);
    function __init__(
        bytes32[] calldata initValues,
        address owner
    ) external;
}

interface NiftablesDatabase {
    function add(address nft, address implementation, address creator) external;
}

/**
    Generates NFT Smart Contracts
 */
 contract NiftablesNFTGenerator is Ownable {

    // Master Proxy Implementation Contract
    NiftablesNFT public proxy;

    // NFT Database
    NiftablesDatabase public immutable database;

    // Mint Page Events
    event NFTCreated(address NFTAddress);
    event CustomNFTCreated(address NFTAddress);

    constructor(
        address proxy_,
        address database_
    ) {
        proxy = NiftablesNFT(payable(proxy_));
        database = NiftablesDatabase(database_);
    }

    function createNFT(
        bytes32[] calldata initValues
    ) external returns (address newNFT) {

        // creates new NFT Proxy
        newNFT = proxy.clone();

        // Initialize Proxy
        NiftablesNFT(payable(newNFT)).__init__(
            initValues,
            msg.sender
        );

        // add to database
        database.add(newNFT, address(proxy), msg.sender);

        // Emit Proxy Creation Event
        emit NFTCreated(newNFT);
    }

    function createNFTCustomImplementation(
        address implementation,
        bytes32[] calldata initValues
    ) external returns (address newNFT) {

        // creates new NFT Proxy
        newNFT = NiftablesNFT(implementation).clone();

        // Initialize Proxy
        NiftablesNFT(payable(newNFT)).__init__(
            initValues,
            msg.sender
        );

        // add to database
        database.add(newNFT, implementation, msg.sender);

        // Emit Proxy Creation Event
        emit CustomNFTCreated(newNFT);
    }


    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function withdrawToken(address token, uint256 amount) external onlyOwner {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, msg.sender, amount));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function setStandardProxy(address proxy_) external onlyOwner {
        proxy = NiftablesNFT(payable(proxy_));
    }

}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

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