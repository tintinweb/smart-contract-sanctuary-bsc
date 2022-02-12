// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.10;

import "./interface/ILayerZeroOracle.sol";

// this is a mocked LayerZero network that receives the blockHash and receiptsRoot
contract LayerZeroNetwork {
    struct BlockData {
        uint256 confirmations;
        bytes data;
    }

    mapping(address => mapping(uint16 => mapping(bytes => BlockData))) public blockHeaderLookup;

    // _srcChainId - the source layerzero chainId the data is coming from
    // _oracle - an ILayerZeroOracle.sol implementation
    // _blockHash - the source blockHash (for EVM: 32 bytes in length)
    // _confirmations - the number of confirmations the oracle waited before delivering the data
    // _data - for EVM, this is the receiptsRoot for the blockHash being delivered (for EVM: 32 bytes in length)
    function updateBlockHeader(
        uint16 _srcChainId,
        address _oracle,
        bytes calldata _blockHash,
        uint256 _confirmations,
        bytes calldata _data
    ) external {
        require(
            ILayerZeroOracle(_oracle).isApproved(msg.sender),
            "LayerZero: the calling Oracle is not approved for updateBlockHeader()"
        );
        BlockData storage bd = blockHeaderLookup[_oracle][_srcChainId][_blockHash];
        require(
            bd.data.length == 0 || bd.confirmations < _confirmations,
            "LayerZero: oracle data can only update if it has more confirmations"
        );

        // set the new information into storage
        bd.confirmations = _confirmations;
        bd.data = _data;
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.10;

// LayerZero oracle interface.
interface ILayerZeroOracle {
    // the qty of native gas token (on source) for initiating the oracle with notifyOracleOfBlock()
    function getPrice(uint16 dstChainId) external view returns (uint256 priceInWei);

    // initiates the offchain oracle to do its job
    function notifyOracleOfBlock(
        uint16 chainId,
        bytes calldata endpointAddress,
        uint256 blockConfirmations,
        bytes32 payloadHash
    ) external;

    // return true if the address is allowed to call updateBlockHeader()
    function isApproved(address oracleSigner) external view returns (bool approved);
}