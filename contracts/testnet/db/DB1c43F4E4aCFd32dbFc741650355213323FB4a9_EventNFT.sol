// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721Psi.sol";

interface i_ERC721Psi {
    function initialize() external;
    // function initialize(
    //     bytes32 hostSignature,
    //     bytes32 eventSignature,
    //     address platform,
    //     address owner,
    //     uint256 mintAmount,
    //     string memory name,
    //     string memory symbol
    // ) external;

    // function name() external view returns (string memory);
    // function symbol() external view returns (string memory);
    // function mint(address to, uint256 amount) external;
}

contract EventNFT {
    string public $version = "0.2.0";
    bytes32 $validsignature;

    event NewEventNFTCreated(
        bytes32 indexed hostSignature,
        bytes32 indexed eventSignature,
        address addr
    );

    // to deploy another contract using owner address and salt specified
    function createEventNFTContract(
        bytes32 hostSignature,
        bytes32 eventSignature,
        address platform,
        address owner,
        uint256 mintAmount,
        string memory eventName,
        string memory eventSymbol
    ) external returns (address) {
        // bytes32 salt = keccak256(
        //     abi.encodePacked(hostSignature, eventSignature)
        // );
        // ERC721Psi _contract = new ERC721Psi{salt: bytes32(salt)}(); // the number of salt determines the address of the contract that will be deployed
        ERC721Psi _contract = new ERC721Psi(address(this)); // the number of salt determines the address of the contract that will be deployed
        // ERC721Psi(address(_contract)).initialize(
        //     hostSignature,
        //     eventSignature,
        //     platform,
        //     owner,
        //     mintAmount,
        //     eventName,
        //     eventSymbol
        // );

        // emit NewEventNFTCreated(
        //     hostSignature,
        //     eventSignature,
        //     address(_contract)
        // );

        // ERC721Psi(address(_contract)).mint(
        //     owner,
        //     mintAmount
        // );

        return address(_contract);
    }

    // get the computed address before the contract DeployWithCreate2 deployed using Bytecode of contract DeployWithCreate2 and salt specified by the sender
    function getAddress(bytes memory bytecode, uint256 _salt)
        public
        view
        returns (address)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(bytecode)
            )
        );
        return address(uint160(uint256(hash)));
    }

    // get the ByteCode of the contract DeployWithCreate2
    function getBytecode(address _owner) public pure returns (bytes memory) {
        bytes memory bytecode = type(ERC721Psi).creationCode;
        return abi.encodePacked(bytecode, abi.encode(_owner));
    }
}

// SPDX-License-Identifier: MIT
/**
  ______ _____   _____ ______ ___  __ _  _  _ 
 |  ____|  __ \ / ____|____  |__ \/_ | || || |
 | |__  | |__) | |        / /   ) || | \| |/ |
 |  __| |  _  /| |       / /   / / | |\_   _/ 
 | |____| | \ \| |____  / /   / /_ | |  | |   
 |______|_|  \_\\_____|/_/   |____||_|  |_|   
                                              
                                            
 */

pragma solidity ^0.8.0;


contract ERC721Psi {
    address public $factory;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(address factory) {
        $factory = factory;
    }

    // called once by the factory contract after deployed.
    function initialize(
    ) external {
        
    }
}