/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;

interface ICrossChainBridge {

    event ContractAllowed(address contractAddress, uint256 toChain);
    event ContractDisallowed(address contractAddress, uint256 toChain);
    event ConsensusChanged(address consensusAddress);
    event TokenImplementationChanged(address consensusAddress);
    event BondImplementationChanged(address consensusAddress);

    struct Metadata {
        bytes32 symbol;
        bytes32 name;
        uint256 originChain;
        address originAddress;
        bytes32 bondMetadata; // encoded metadata version, bond type
    }

    event DepositLocked(
        uint256 chainId,
        address indexed fromAddress,
        address indexed toAddress,
        address fromToken,
        address toToken,
        uint256 totalAmount,
        Metadata metadata
    );
    event DepositBurned(
        uint256 chainId,
        address indexed fromAddress,
        address indexed toAddress,
        address fromToken,
        address toToken,
        uint256 totalAmount,
        Metadata metadata,
        address originToken
    );

    event WithdrawMinted(
        bytes32 receiptHash,
        address indexed fromAddress,
        address indexed toAddress,
        address fromToken,
        address toToken,
        uint256 totalAmount
    );
    event WithdrawUnlocked(
        bytes32 receiptHash,
        address indexed fromAddress,
        address indexed toAddress,
        address fromToken,
        address toToken,
        uint256 totalAmount
    );

    enum InternetBondType {
        NOT_BOND,
        REBASING_BOND,
        NONREBASING_BOND
    }

    function isPeggedToken(address toToken) external returns (bool);

    function deposit(uint256 toChain, address toAddress) payable external;

    function deposit(address fromToken, uint256 toChain, address toAddress, uint256 amount) external;

    function withdraw(bytes calldata encodedProof, bytes calldata rawReceipt, bytes calldata receiptRootSignature) external;

    function factoryPeggedToken(uint256 fromChain, Metadata calldata metaData) external;

    function factoryPeggedBond(uint256 fromChain, Metadata calldata metaData) external;

    function getTokenImplementation() external returns (address);

    function getBondImplementation() external returns (address);

    }


contract InternetBondProxy {

    bytes32 private constant BEACON_SLOT = bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1);

    fallback() external {
        address bridge;
        bytes32 slot = BEACON_SLOT;
        assembly {
            bridge := sload(slot)
        }
        address impl = ICrossChainBridge(bridge).getBondImplementation();
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {revert(0, returndatasize())}
            default {return (0, returndatasize())}
        }
    }

    function setBeacon(address newBeacon) external {
        address beacon;
        bytes32 slot = BEACON_SLOT;
        assembly {
            beacon := sload(slot)
        }
        require(beacon == address(0x00));
        assembly {
            sstore(slot, newBeacon)
        }
    }
}