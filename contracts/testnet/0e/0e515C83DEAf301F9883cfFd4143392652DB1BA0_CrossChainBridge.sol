// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./common/Types.sol";

import "./interfaces/ICrossChainBridge.sol";
import "./interfaces/IRelayHub.sol";

import "./libraries/ReceiptParser.sol";
import "./libraries/Utils.sol";

import "./BridgeRouter.sol";

contract CrossChainBridge is ICrossChainBridge {
    struct Origin {
        uint256 originChain;
        address originAddress;
    }

    // constant
    address constant ZERO_ADDRESS = address(0x0);

    // native token
    Types.TokenMetadata public NATIVE_TOKEN_METADATA;

    // operators
    address _owner;
    mapping(address => bool) internal _operators;

    IRelayHub internal _relayHub;
    BridgeRouter internal _bridgeRouter;

    mapping(bytes32 => bool) internal _usedProofs;
    mapping(address => Origin) internal _peggedTokenToOrigin;

    // event
    event BridgeRouterChanged(address oldValue, address newValue);

    // function
    constructor(
        IRelayHub relayHub,
        BridgeRouter bridgeRouter,
        string memory nativeTokenName,
        string memory nativeTokenSymbol
    ) {
        _owner = msg.sender;
        _operators[msg.sender] = true;

        _relayHub = relayHub;
        _bridgeRouter = bridgeRouter;

        NATIVE_TOKEN_METADATA = Types.TokenMetadata(
            nativeTokenName,
            nativeTokenSymbol,
            block.chainid,
            address(
                bytes20(
                    keccak256(
                        abi.encodePacked("CrossChainBridge:", nativeTokenSymbol)
                    )
                )
            )
        );
    }

    modifier onlyRelayHub() virtual {
        require(
            msg.sender == address(_relayHub),
            "CrossChainBridge Only RelayHub"
        );
        _;
    }

    modifier onlyOperator() {
        require(
            _operators[msg.sender] || (msg.sender == _owner),
            "CrossChainBridge Only Operator"
        );
        _;
    }

    modifier bridgeRegistered() {
        require(
            (_relayHub.getBridgeAddress(block.chainid) == address(this)),
            "bridge not registered"
        );
        _;
    }

    function setOperator(address operator_, bool status_)
        external
        onlyOperator
    {
        _operators[operator_] = status_;
    }

    function getRelayHub() external view returns (IRelayHub) {
        return _relayHub;
    }

    function getTokenImplementation() external view override returns (address) {
        return _bridgeRouter.getImplementation();
    }

    function getPeggedTokenAddress(address fromToken)
        external
        view
        returns (address)
    {
        return _bridgeRouter.peggedTokenAddress(address(this), fromToken);
    }

    function changeRouter(BridgeRouter otherRouter) public onlyOperator {
        BridgeRouter oldValue = _bridgeRouter;
        _bridgeRouter = otherRouter;
        emit BridgeRouterChanged(address(oldValue), address(otherRouter));
    }

    function _checkContractAllowed(Types.State memory state)
        internal
        view
        virtual
    {
        require(
            _relayHub.getBridgeAddress(state.fromChain) ==
                state.contractAddress,
            "event from not allowed contract"
        );
    }

    function _getOrigin(address token) internal view returns (Origin memory) {
        if (token == NATIVE_TOKEN_METADATA.originAddress) {
            return Origin(0, address(0x0));
        }
        try IERC20PeggedToken(token).getOrigin() returns (
            uint256 originChain,
            address originAddress
        ) {
            return Origin(originChain, originAddress);
        } catch {}
        return Origin(0, address(0x0));
    }

    // DEPOSIT FUNCTIONS

    function depositNative(uint256 toChain, address toAddress)
        external
        payable
        override
        bridgeRegistered
    {
        address toBridge = _relayHub.getBridgeAddress(toChain);
        require(toBridge != ZERO_ADDRESS, "toBridge not registered");
        address toToken = _bridgeRouter.peggedTokenAddress(
            address(toBridge),
            NATIVE_TOKEN_METADATA.originAddress
        );
        emit DepositToken(
            block.chainid,
            toChain, // our target chain id
            msg.sender, // who send these funds
            toAddress, // who can claim these funds in "toChain" network
            NATIVE_TOKEN_METADATA.originAddress, // this is our current native token (e.g. ETH, MATIC, BNB, etc)
            toToken, // this is an address of our target pegged token
            msg.value, // how much funds was locked in this contract
            NATIVE_TOKEN_METADATA // meta information about
        );
    }

    function depositToken(
        address fromToken,
        uint256 toChain,
        address toAddress,
        uint256 totalAmount
    ) external override bridgeRegistered {
        require(
            fromToken != NATIVE_TOKEN_METADATA.originAddress,
            "native token address"
        );
        address toBridge = _relayHub.getBridgeAddress(toChain);
        require(toBridge != ZERO_ADDRESS, "toBridge not registered");
        Origin memory origin = _getOrigin(fromToken);
        if (origin.originChain == 0) {
            // if we donot have pegged contract then its erc20 token, since we can't detect is it erc20 token it can only return insufficient balance in case of any errors
            _depositErc20(fromToken, toChain, toAddress, toBridge, totalAmount);
        } else {
            // otherwise its pegged token
            _depositPegged(
                fromToken,
                toChain,
                toAddress,
                toBridge,
                totalAmount,
                origin
            );
        }
    }

    function _depositErc20(
        address fromToken,
        uint256 toChain,
        address toAddress,
        address toBridge,
        uint256 totalAmount
    ) internal {
        // check allowance and transfer tokens
        uint256 balanceBefore = IERC20(fromToken).balanceOf(address(this));
        uint256 allowance = IERC20(fromToken).allowance(
            msg.sender,
            address(this)
        );
        require(totalAmount <= allowance, "insufficient allowance");
        require(
            IERC20(fromToken).transferFrom(
                msg.sender,
                address(this),
                totalAmount
            ),
            "can't transfer"
        );
        uint256 balanceAfter = IERC20(fromToken).balanceOf(address(this));
        // assert that enough coins were transferred to bridge
        require(
            balanceAfter >= balanceBefore + totalAmount,
            "incorrect behaviour"
        );
        // lets pack ERC20 token meta data and scale amount to 18 decimals
        uint256 scaledAmount = Utils._amountErc20Token(fromToken, totalAmount);

        address toToken = _bridgeRouter.peggedTokenAddress(toBridge, fromToken);
        Types.TokenMetadata memory metaData = Types.TokenMetadata(
            IERC20Metadata(fromToken).name(),
            IERC20Metadata(fromToken).symbol(),
            block.chainid,
            fromToken
        );
        emit DepositToken(
            block.chainid,
            toChain,
            msg.sender, // who send these funds
            toAddress, // who can claim these funds in "toChain" network
            fromToken, // this is our current native token (can be ETH, CLV, DOT, BNB or something else)
            toToken, // this is an address of our target pegged token
            scaledAmount, // how much funds was locked in this contract
            metaData // meta information about
        );
    }

    function _depositPegged(
        address fromToken,
        uint256 toChain,
        address toAddress,
        address toBridge,
        uint256 totalAmount,
        Origin memory origin
    ) internal {
        // make sure token is supported
        require(
            _peggedTokenToOrigin[fromToken].originChain == origin.originChain &&
                _peggedTokenToOrigin[fromToken].originAddress ==
                origin.originAddress,
            "non-pegged contract not supported"
        );

        // check allowance and transfer tokens
        require(
            IERC20PeggedToken(fromToken).balanceOf(msg.sender) >= totalAmount,
            "insufficient balance"
        );

        address toToken;
        if (toChain == origin.originChain) {
            toToken = origin.originAddress;
        } else {
            toToken = _bridgeRouter.peggedTokenAddress(
                toBridge,
                origin.originAddress
            );
        }
        IERC20PeggedToken(fromToken).burn(msg.sender, totalAmount);

        Types.TokenMetadata memory metaData = Types.TokenMetadata(
            IERC20PeggedToken(fromToken).symbol(),
            IERC20PeggedToken(fromToken).name(),
            origin.originChain,
            origin.originAddress
        );
        emit DepositToken(
            block.chainid,
            toChain,
            msg.sender, // who send these funds
            toAddress, // who can claim these funds in "toChain" network
            fromToken, // this is our current native token (can be ETH, CLV, DOT, BNB or something else)
            toToken, // this is an address of our target pegged token
            totalAmount, // how much funds was locked in this contract
            metaData
        );
    }

    // WITHDRAWAL FUNCTIONS

    function withdraw(
        bytes[] calldata blockProofs,
        bytes calldata rawReceipt,
        bytes calldata proofPath,
        bytes calldata proofSiblings
    ) external override bridgeRegistered {
        Types.State memory state = ReceiptParser.parseTransactionReceipt(
            rawReceipt
        );
        _checkContractAllowed(state);
        require(
            state.toChain == block.chainid,
            "receipt points to another chain"
        );
        require(
            _relayHub.checkReceiptProof(
                state.fromChain,
                blockProofs,
                rawReceipt,
                proofSiblings,
                proofPath
            ),
            "bad proof"
        );
        _withdraw(
            state,
            keccak256(abi.encodePacked(blockProofs[0], rawReceipt))
        );
    }

    function _withdraw(Types.State memory state, bytes32 proofHash) internal {
        // make sure these proofs wasn't used before
        require(!_usedProofs[proofHash], "proof already used");
        _usedProofs[proofHash] = true;

        if (state.toToken == NATIVE_TOKEN_METADATA.originAddress) {
            payable(state.toAddress).transfer(state.totalAmount);
        } else if (state.metadata.originChain == block.chainid) {
            _withdrawErc20(state.toAddress, state.toToken, state.totalAmount);
        } else {
            _withdrawPegged(state);
        }
        emit WithdrawToken(
            state.fromChain,
            state.fromAddress,
            state.toAddress,
            state.fromToken,
            state.toToken,
            state.totalAmount,
            state.metadata
        );
    }

    function _withdrawErc20(
        address toAddress,
        address toToken,
        uint256 totalAmount
    ) internal {
        uint8 decimals = IERC20Metadata(toToken).decimals();
        require(decimals <= 18, "decimals overflow");
        uint256 scaledAmount = totalAmount / (10**(18 - decimals));
        // transfer tokens and make sure behaviour is correct (just in case)
        uint256 balanceBefore = IERC20(toToken).balanceOf(toAddress);
        require(
            IERC20(toToken).transfer(toAddress, scaledAmount),
            "can't transfer"
        );
        uint256 balanceAfter = IERC20(toToken).balanceOf(toAddress);
        require(balanceBefore <= balanceAfter, "incorrect behaviour");
    }

    function _withdrawPegged(Types.State memory state) internal {
        // mint pegged token
        _factoryPeggedToken(state.toToken, state.metadata).mint(
            state.toAddress,
            state.totalAmount
        );
    }

    function _factoryPeggedToken(
        address toToken,
        Types.TokenMetadata memory metadata
    ) internal returns (IERC20PeggedToken) {
        // if pegged token exist we can just return its address
        if (_peggedTokenToOrigin[toToken].originAddress != address(0x00)) {
            return IERC20PeggedToken(toToken);
        }
        // we must use delegate call because we need to deploy new contract from bridge contract to have valid address
        (bool success, bytes memory returnValue) = address(_bridgeRouter)
            .delegatecall(
                abi.encodeWithSignature(
                    "factoryPeggedToken(address,address,(string,string,uint256,address),address)",
                    metadata.originAddress,
                    toToken,
                    metadata,
                    address(this)
                )
            );
        if (!success) {
            // preserving error message
            uint256 returnLength = returnValue.length;
            assembly {
                revert(add(returnValue, 0x20), returnLength)
            }
        }
        // now we can mark this token as pegged
        _peggedTokenToOrigin[toToken] = Origin(
            metadata.originChain,
            metadata.originAddress
        );
        // to token is our new pegged token
        return IERC20PeggedToken(toToken);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./common/Types.sol";

import "./interfaces/IERC20PeggedToken.sol";

import "./libraries/PeggedTokenUtils.sol";

contract BridgeRouter {
    address private _peggedTemplate;

    constructor() {
        _peggedTemplate = PeggedTokenUtils.deployPeggedTokenTemplate();
    }

    function getImplementation() public view returns (address) {
        return _peggedTemplate;
    }

    function peggedTokenAddress(address fromBridge, address fromToken)
        public
        pure
        returns (address)
    {
        return
            PeggedTokenUtils.peggedTokenProxyAddress(
                fromBridge,
                bytes32(bytes20(fromToken))
            );
    }

    function factoryPeggedToken(
        address fromToken,
        address toToken,
        Types.TokenMetadata memory metadata,
        address fromBridge
    ) public returns (IERC20PeggedToken) {
        // we must use delegate call because we need to deploy new contract from bridge contract to have valid address
        address targetToken = PeggedTokenUtils.deployPeggedTokenProxy(
            fromBridge,
            bytes32(bytes20(fromToken)),
            metadata
        );
        require(targetToken == toToken, "bad chain");
        // to token is our new pegged token
        return IERC20PeggedToken(toToken);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../common/Types.sol";

interface ICrossChainBridge {
    event DepositToken(
        uint256 fromChain,
        uint256 indexed toChain,
        address indexed fromAddress,
        address indexed toAddress,
        address fromToken,
        address toToken,
        uint256 totalAmount,
        Types.TokenMetadata
    );

    event WithdrawToken(
        uint256 indexed fromChain,
        address indexed fromAddress,
        address indexed toAddress,
        address fromToken,
        address toToken,
        uint256 totalAmount,
        Types.TokenMetadata
    );

    function depositNative(uint256 toChain, address toAddress) external payable;

    function depositToken(
        address fromToken,
        uint256 toChain,
        address toAddress,
        uint256 totalAmount
    ) external;

    function withdraw(
        bytes[] calldata blockProofs,
        bytes calldata rawReceipt,
        bytes calldata proofPath,
        bytes calldata proofSiblings
    ) external;

    function getTokenImplementation() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Types {
    struct BlockHeader {
        bytes32 blockHash;
        bytes32 parentHash;
        uint64 blockNumber;
        address coinbase;
        bytes32 receiptsRoot;
        bytes32 txsRoot;
        bytes32 stateRoot;
    }

    struct State {
        address contractAddress;
        uint256 fromChain;
        uint256 toChain;
        address fromAddress;
        address toAddress;
        address fromToken;
        address toToken;
        uint256 totalAmount;
        TokenMetadata metadata;
    }

    struct TokenMetadata {
        string name;
        string symbol;
        uint256 originChain;
        address originAddress;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRelayHub {
    function getLatestEpochNumber(
        uint256 chainId
    ) external view returns (uint256);

    function getLatestValidatorSet(
        uint256 chainId
    ) external view returns (address[] memory);

    function getBridgeAddress(uint256 chainId) external view returns (address);

    function enableCrossChainBridge(
        uint256 chainId,
        address bridgeAddress
    ) external;

    function checkReceiptProof(
        uint256 chainId,
        bytes[] calldata blockProofs,
        bytes calldata rawReceipt,
        bytes calldata proofSiblings,
        bytes calldata proofPath
    ) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;

import "../common/Types.sol";

import "../interfaces/ICrossChainBridge.sol";

import "./RLP.sol";
import "./RLPReader.sol";
import "./Utils.sol";

library ReceiptParser {
    using RLPReader for RLPReader.RLPItem;
    using RLPReader for bytes;

    bytes32 constant TOPIC_DEPOSIT =
        keccak256(
            "DepositToken(uint256,uint256,address,address,address,address,uint256,(string,string,uint256,address))"
        );

    function parseTransactionReceipt(bytes calldata rawReceipt)
        internal
        pure
        returns (Types.State memory state)
    {
        RLPReader.RLPItem[] memory receipt = rawReceipt.toRlpItem().toList();

        // receipt must have at least 4 field
        require(receipt.length >= 4, "bad receipt");

        // receipt[0] is transaction status
        require(receipt[0].toUint() == 0x01, "tx is reverted");

        // receipt[1] is cumulativeGasUsed
        // receipt[2] is logsBloom

        // receipt[3] is logs
        _decodeReceiptLogs(state, receipt[3].toList());
        return state;
    }

    function _decodeReceiptLogs(
        Types.State memory state,
        RLPReader.RLPItem[] memory logs
    ) internal pure {
        require(logs.length >= 1, "bad logs");
        for (uint256 i; i < logs.length; i++) {
            RLPReader.RLPItem[] memory log = logs[i].toList();
            require(log.length >= 3, "bad log");

            // contract address
            state.contractAddress = log[0].toAddress();
            require(
                state.contractAddress != address(0x0),
                "invalid contract address"
            );

            // topics
            RLPReader.RLPItem[] memory topics = log[1].toList();
            require(topics.length >= 1, "bad topics");
            // main topic is event signature
            if (bytes32(topics[0].toBytes()) == TOPIC_DEPOSIT) {
                require(topics.length >= 4, "bad deposit log");
                state.toChain = topics[1].toUint();
                state.fromAddress = address(uint160(topics[2].toUint()));
                state.toAddress = address(uint160(topics[3].toUint()));

                // data
                (
                    state.fromChain,
                    state.fromToken,
                    state.toToken,
                    state.totalAmount,
                    state.metadata
                ) = abi.decode(
                    log[2].toBytes(),
                    (uint256, address, address, uint256, Types.TokenMetadata)
                );
                return;
            }
        }
        revert("wrong main topic");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

library Utils {
    function compareBytes(bytes memory x, bytes memory y)
        internal
        pure
        returns (bool)
    {
        return keccak256(abi.encodePacked(x)) == keccak256(abi.encodePacked(y));
    }

    function _bytes32ToString(bytes32 _bytes32)
        internal
        pure
        returns (string memory)
    {
        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    function _amountErc20Token(address fromToken, uint256 totalAmount)
        internal
        view
        returns (uint256)
    {
        // lets pack ERC20 token meta data and scale amount to 18 decimals
        require(
            IERC20Metadata(fromToken).decimals() <= 18,
            "decimals overflow"
        );
        totalAmount *= (10**(18 - IERC20Metadata(fromToken).decimals()));
        return totalAmount;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IERC20PeggedToken is IERC20, IERC20Metadata {
    function getOrigin() external view returns (uint256, address);

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../common/Types.sol";

library PeggedTokenUtils {
    bytes32 internal constant PEGGED_TOKEN_TEMPLATE_SALT =
        keccak256("PeggedTokenTemplateV1");

    bytes internal constant PEGGED_TOKEN_TEMPLATE_BYTECODE =
        hex"60806040523480156200001157600080fd5b5060408051602080820180845260008084528451928301909452928152815191929091620000429160039162000061565b5080516200005890600490602084019062000061565b50505062000144565b8280546200006f9062000107565b90600052602060002090601f016020900481019282620000935760008555620000de565b82601f10620000ae57805160ff1916838001178555620000de565b82800160010185558215620000de579182015b82811115620000de578251825591602001919060010190620000c1565b50620000ec929150620000f0565b5090565b5b80821115620000ec5760008155600101620000f1565b600181811c908216806200011c57607f821691505b602082108114156200013e57634e487b7160e01b600052602260045260246000fd5b50919050565b610e4f80620001546000396000f3fe608060405234801561001057600080fd5b50600436106100f55760003560e01c806370a0823111610097578063a9059cbb11610066578063a9059cbb146101ee578063bd3a13f614610201578063dd62ed3e14610214578063df1f29ee1461022757600080fd5b806370a082311461019757806395d89b41146101c05780639dc29fac146101c8578063a457c2d7146101db57600080fd5b806323b872dd116100d357806323b872dd1461014d578063313ce56714610160578063395093511461016f57806340c10f191461018257600080fd5b806306fdde03146100fa578063095ea7b31461011857806318160ddd1461013b575b600080fd5b61010261024a565b60405161010f9190610b4c565b60405180910390f35b61012b610126366004610bbd565b6102dc565b604051901515815260200161010f565b6002545b60405190815260200161010f565b61012b61015b366004610be7565b6102f4565b6040516012815260200161010f565b61012b61017d366004610bbd565b610318565b610195610190366004610bbd565b61033a565b005b61013f6101a5366004610c23565b6001600160a01b031660009081526020819052604090205490565b610102610394565b6101956101d6366004610bbd565b6103a3565b61012b6101e9366004610bbd565b6103f4565b61012b6101fc366004610bbd565b61046f565b61019561020f366004610ce8565b61047d565b61013f610222366004610d66565b6104f6565b600654600754604080519283526001600160a01b0390911660208301520161010f565b60606003805461025990610d99565b80601f016020809104026020016040519081016040528092919081815260200182805461028590610d99565b80156102d25780601f106102a7576101008083540402835291602001916102d2565b820191906000526020600020905b8154815290600101906020018083116102b557829003601f168201915b5050505050905090565b6000336102ea818585610521565b5060019392505050565b600033610302858285610646565b61030d8585856106c0565b506001949350505050565b6000336102ea81858561032b83836104f6565b6103359190610dea565b610521565b6005546001600160a01b031633146103865760405162461bcd60e51b815260206004820152600a60248201526937b7363c9037bbb732b960b11b60448201526064015b60405180910390fd5b610390828261088e565b5050565b60606004805461025990610d99565b6005546001600160a01b031633146103ea5760405162461bcd60e51b815260206004820152600a60248201526937b7363c9037bbb732b960b11b604482015260640161037d565b610390828261096d565b6000338161040282866104f6565b9050838110156104625760405162461bcd60e51b815260206004820152602560248201527f45524332303a2064656372656173656420616c6c6f77616e63652062656c6f77604482015264207a65726f60d81b606482015260840161037d565b61030d8286868403610521565b6000336102ea8185856106c0565b6005546001600160a01b03161561049357600080fd5b600580546001600160a01b0319163317905583516104b8906003906020870190610ab3565b5082516104cc906004906020860190610ab3565b50600691909155600780546001600160a01b0319166001600160a01b039092169190911790555050565b6001600160a01b03918216600090815260016020908152604080832093909416825291909152205490565b6001600160a01b0383166105835760405162461bcd60e51b8152602060048201526024808201527f45524332303a20617070726f76652066726f6d20746865207a65726f206164646044820152637265737360e01b606482015260840161037d565b6001600160a01b0382166105e45760405162461bcd60e51b815260206004820152602260248201527f45524332303a20617070726f766520746f20746865207a65726f206164647265604482015261737360f01b606482015260840161037d565b6001600160a01b0383811660008181526001602090815260408083209487168084529482529182902085905590518481527f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b92591015b60405180910390a3505050565b600061065284846104f6565b905060001981146106ba57818110156106ad5760405162461bcd60e51b815260206004820152601d60248201527f45524332303a20696e73756666696369656e7420616c6c6f77616e6365000000604482015260640161037d565b6106ba8484848403610521565b50505050565b6001600160a01b0383166107245760405162461bcd60e51b815260206004820152602560248201527f45524332303a207472616e736665722066726f6d20746865207a65726f206164604482015264647265737360d81b606482015260840161037d565b6001600160a01b0382166107865760405162461bcd60e51b815260206004820152602360248201527f45524332303a207472616e7366657220746f20746865207a65726f206164647260448201526265737360e81b606482015260840161037d565b6001600160a01b038316600090815260208190526040902054818110156107fe5760405162461bcd60e51b815260206004820152602660248201527f45524332303a207472616e7366657220616d6f756e7420657863656564732062604482015265616c616e636560d01b606482015260840161037d565b6001600160a01b03808516600090815260208190526040808220858503905591851681529081208054849290610835908490610dea565b92505081905550826001600160a01b0316846001600160a01b03167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef8460405161088191815260200190565b60405180910390a36106ba565b6001600160a01b0382166108e45760405162461bcd60e51b815260206004820152601f60248201527f45524332303a206d696e7420746f20746865207a65726f206164647265737300604482015260640161037d565b80600260008282546108f69190610dea565b90915550506001600160a01b03821660009081526020819052604081208054839290610923908490610dea565b90915550506040518181526001600160a01b038316906000907fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef9060200160405180910390a35050565b6001600160a01b0382166109cd5760405162461bcd60e51b815260206004820152602160248201527f45524332303a206275726e2066726f6d20746865207a65726f206164647265736044820152607360f81b606482015260840161037d565b6001600160a01b03821660009081526020819052604090205481811015610a415760405162461bcd60e51b815260206004820152602260248201527f45524332303a206275726e20616d6f756e7420657863656564732062616c616e604482015261636560f01b606482015260840161037d565b6001600160a01b0383166000908152602081905260408120838303905560028054849290610a70908490610e02565b90915550506040518281526000906001600160a01b038516907fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef90602001610639565b828054610abf90610d99565b90600052602060002090601f016020900481019282610ae15760008555610b27565b82601f10610afa57805160ff1916838001178555610b27565b82800160010185558215610b27579182015b82811115610b27578251825591602001919060010190610b0c565b50610b33929150610b37565b5090565b5b80821115610b335760008155600101610b38565b600060208083528351808285015260005b81811015610b7957858101830151858201604001528201610b5d565b81811115610b8b576000604083870101525b50601f01601f1916929092016040019392505050565b80356001600160a01b0381168114610bb857600080fd5b919050565b60008060408385031215610bd057600080fd5b610bd983610ba1565b946020939093013593505050565b600080600060608486031215610bfc57600080fd5b610c0584610ba1565b9250610c1360208501610ba1565b9150604084013590509250925092565b600060208284031215610c3557600080fd5b610c3e82610ba1565b9392505050565b634e487b7160e01b600052604160045260246000fd5b600082601f830112610c6c57600080fd5b813567ffffffffffffffff80821115610c8757610c87610c45565b604051601f8301601f19908116603f01168101908282118183101715610caf57610caf610c45565b81604052838152866020858801011115610cc857600080fd5b836020870160208301376000602085830101528094505050505092915050565b60008060008060808587031215610cfe57600080fd5b843567ffffffffffffffff80821115610d1657600080fd5b610d2288838901610c5b565b95506020870135915080821115610d3857600080fd5b50610d4587828801610c5b565b93505060408501359150610d5b60608601610ba1565b905092959194509250565b60008060408385031215610d7957600080fd5b610d8283610ba1565b9150610d9060208401610ba1565b90509250929050565b600181811c90821680610dad57607f821691505b60208210811415610dce57634e487b7160e01b600052602260045260246000fd5b50919050565b634e487b7160e01b600052601160045260246000fd5b60008219821115610dfd57610dfd610dd4565b500190565b600082821015610e1457610e14610dd4565b50039056fea2646970667358221220aac67cacb590bac7b1e68760327951f3617fc9560121c860e3ab6d348d999e2c64736f6c634300080a0033";
    bytes internal constant PEGGED_TOKEN_PROXY_BYTECODE =
        hex"608060405234801561001057600080fd5b506101f8806100206000396000f3fe6080604052600436106100225760003560e01c8063c4d66de81461003957610031565b366100315761002f610059565b005b61002f610059565b34801561004557600080fd5b5061002f610054366004610181565b61006b565b6100696100646100aa565b610145565b565b7fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d508054906001600160a01b038216156100a357600080fd5b9190915550565b60008060007fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d5060001b9050805491506000826001600160a01b031663709bc7f36040518163ffffffff1660e01b8152600401602060405180830381865afa158015610119573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061013d91906101a5565b949350505050565b3660008037600080366000845af43d6000803e808015610164573d6000f35b3d6000fd5b6001600160a01b038116811461017e57600080fd5b50565b60006020828403121561019357600080fd5b813561019e81610169565b9392505050565b6000602082840312156101b757600080fd5b815161019e8161016956fea264697066735822122099be605e8eb1f6e433c5d61e746f4bf83e94780280426490beb15a73c779fa8d64736f6c634300080a0033";

    bytes32 internal constant PEGGED_TOKEN_TEMPLATE_HASH =
        keccak256(PEGGED_TOKEN_TEMPLATE_BYTECODE);
    bytes32 internal constant PEGGED_TOKEN_PROXY_HASH =
        keccak256(PEGGED_TOKEN_PROXY_BYTECODE);

    string internal constant INITIALIZE_TOKEN_SIGNATURE =
        "initialize(string,string,uint256,address)";
    string internal constant INITIALIZE_PROXY_SIGNATURE = "initialize(address)";

    function deployPeggedTokenTemplate() internal returns (address) {
        bytes32 salt = PEGGED_TOKEN_TEMPLATE_SALT;
        bytes memory bytecode = PEGGED_TOKEN_TEMPLATE_BYTECODE;
        address result;
        assembly {
            result := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(result != address(0x00), "deploy pegged token failed");
        return result;
    }

    function deployPeggedTokenProxy(
        address bridge,
        bytes32 salt,
        Types.TokenMetadata memory metadata
    ) internal returns (address) {
        bytes memory bytecode = PEGGED_TOKEN_PROXY_BYTECODE;
        // deploy new contract and store contract address in result variable
        address result;
        assembly {
            result := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(result != address(0x00), "deploy failed");
        // setup impl
        (bool success, ) = result.call(
            abi.encodeWithSignature(INITIALIZE_PROXY_SIGNATURE, bridge)
        );
        require(success, "proxy init failed");
        // setup meta data
        (success, ) = result.call(
            abi.encodeWithSignature(
                INITIALIZE_TOKEN_SIGNATURE,
                metadata.name,
                metadata.symbol,
                metadata.originChain,
                metadata.originAddress
            )
        );
        require(success, "token init failed");
        // return generated contract address
        return result;
    }

    function peggedTokenProxyAddress(address deployer, bytes32 salt)
        internal
        pure
        returns (address)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                uint8(0xff),
                address(deployer),
                salt,
                PEGGED_TOKEN_PROXY_HASH
            )
        );
        return address(bytes20(hash << 96));
    }

    function peggedTokenAddress(address deployer, bytes32 salt)
        internal
        pure
        returns (address)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                uint8(0xff),
                address(deployer),
                salt,
                PEGGED_TOKEN_TEMPLATE_HASH
            )
        );
        return address(bytes20(hash << 96));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.6;

library RLP {
    uint8 public constant STRING_SHORT_START = 0x80;
    uint8 public constant STRING_LONG_START = 0xb8;
    uint8 public constant LIST_SHORT_START = 0xc0;
    uint8 public constant LIST_LONG_START = 0xf8;
    uint8 public constant WORD_SIZE = 32;

    function openRlp(bytes calldata rawRlp)
        internal
        pure
        returns (uint256 iter)
    {
        uint256 rawRlpOffset;
        assembly {
            rawRlpOffset := rawRlp.offset
        }
        return rawRlpOffset;
    }

    function beginRlp(bytes calldata rawRlp)
        internal
        pure
        returns (uint256 iter)
    {
        uint256 rawRlpOffset;
        assembly {
            rawRlpOffset := rawRlp.offset
        }
        return rawRlpOffset + _payloadOffset(rawRlpOffset);
    }

    function lengthRlp(bytes calldata rawRlp)
        internal
        pure
        returns (uint256 iter)
    {
        uint256 rawRlpOffset;
        assembly {
            rawRlpOffset := rawRlp.offset
        }
        return itemLength(rawRlpOffset);
    }

    function beginIteration(uint256 offset)
        internal
        pure
        returns (uint256 iter)
    {
        return offset + _payloadOffset(offset);
    }

    function next(uint256 iter) internal pure returns (uint256 nextIter) {
        return iter + itemLength(iter);
    }

    function payloadLen(uint256 ptr, uint256 len)
        internal
        pure
        returns (uint256)
    {
        return len - _payloadOffset(ptr);
    }

    function toAddress(uint256 ptr) internal pure returns (address) {
        return address(uint160(toUint(ptr, 21)));
    }

    function toBytes32(uint256 ptr) internal pure returns (bytes32) {
        return bytes32(toUint(ptr, 33));
    }

    function toRlpBytes(uint256 ptr) internal pure returns (bytes memory) {
        uint256 length = itemLength(ptr);
        bytes memory result = new bytes(length);
        if (result.length == 0) {
            return result;
        }
        ptr = beginIteration(ptr);
        assembly {
            calldatacopy(add(0x20, result), ptr, length)
        }
        return result;
    }

    function toRlpBytesKeccak256(uint256 ptr) internal pure returns (bytes32) {
        return keccak256(toRlpBytes(ptr));
    }

    function toBytes(uint256 ptr) internal pure returns (bytes memory) {
        uint256 offset = _payloadOffset(ptr);
        uint256 length = itemLength(ptr) - offset;
        bytes memory result = new bytes(length);
        if (result.length == 0) {
            return result;
        }
        ptr = beginIteration(ptr);
        assembly {
            calldatacopy(add(0x20, result), add(ptr, offset), length)
        }
        return result;
    }

    function toUint256(uint256 ptr, uint256 len)
        internal
        pure
        returns (uint256)
    {
        return toUint(ptr, len);
    }

    function uintToRlp(uint256 value)
        internal
        pure
        returns (bytes memory result)
    {
        // zero can be encoded as zero or empty array, go-ethereum's encodes as empty array
        if (value == 0) {
            result = new bytes(1);
            result[0] = 0x80;
            return result;
        }
        // encode value
        if (value <= 0x7f) {
            result = new bytes(1);
            result[0] = bytes1(uint8(value));
            return result;
        } else if (value < (1 << 8)) {
            result = new bytes(2);
            result[0] = 0x81;
            result[1] = bytes1(uint8(value));
            return result;
        } else if (value < (1 << 16)) {
            result = new bytes(3);
            result[0] = 0x82;
            result[1] = bytes1(uint8(value >> 8));
            result[2] = bytes1(uint8(value));
            return result;
        } else if (value < (1 << 24)) {
            result = new bytes(4);
            result[0] = 0x83;
            result[1] = bytes1(uint8(value >> 16));
            result[2] = bytes1(uint8(value >> 8));
            result[3] = bytes1(uint8(value));
            return result;
        } else if (value < (1 << 32)) {
            result = new bytes(5);
            result[0] = 0x84;
            result[1] = bytes1(uint8(value >> 24));
            result[2] = bytes1(uint8(value >> 16));
            result[3] = bytes1(uint8(value >> 8));
            result[4] = bytes1(uint8(value));
            return result;
        } else if (value < (1 << 40)) {
            result = new bytes(6);
            result[0] = 0x85;
            result[1] = bytes1(uint8(value >> 32));
            result[2] = bytes1(uint8(value >> 24));
            result[3] = bytes1(uint8(value >> 16));
            result[4] = bytes1(uint8(value >> 8));
            result[5] = bytes1(uint8(value));
            return result;
        } else if (value < (1 << 48)) {
            result = new bytes(7);
            result[0] = 0x86;
            result[1] = bytes1(uint8(value >> 40));
            result[2] = bytes1(uint8(value >> 32));
            result[3] = bytes1(uint8(value >> 24));
            result[4] = bytes1(uint8(value >> 16));
            result[5] = bytes1(uint8(value >> 8));
            result[6] = bytes1(uint8(value));
            return result;
        } else if (value < (1 << 56)) {
            result = new bytes(8);
            result[0] = 0x87;
            result[1] = bytes1(uint8(value >> 48));
            result[2] = bytes1(uint8(value >> 40));
            result[3] = bytes1(uint8(value >> 32));
            result[4] = bytes1(uint8(value >> 24));
            result[5] = bytes1(uint8(value >> 16));
            result[6] = bytes1(uint8(value >> 8));
            result[7] = bytes1(uint8(value));
            return result;
        } else {
            result = new bytes(9);
            result[0] = 0x88;
            result[1] = bytes1(uint8(value >> 56));
            result[2] = bytes1(uint8(value >> 48));
            result[3] = bytes1(uint8(value >> 40));
            result[4] = bytes1(uint8(value >> 32));
            result[5] = bytes1(uint8(value >> 24));
            result[6] = bytes1(uint8(value >> 16));
            result[7] = bytes1(uint8(value >> 8));
            result[8] = bytes1(uint8(value));
            return result;
        }
    }

    function uintRlpPrefixLength(uint256 value)
        internal
        pure
        returns (uint256 len)
    {
        if (value < (1 << 8)) {
            return 1;
        } else if (value < (1 << 16)) {
            return 2;
        } else if (value < (1 << 24)) {
            return 3;
        } else if (value < (1 << 32)) {
            return 4;
        } else if (value < (1 << 40)) {
            return 5;
        } else if (value < (1 << 48)) {
            return 6;
        } else if (value < (1 << 56)) {
            return 7;
        } else {
            return 8;
        }
    }

    function toUint(uint256 ptr, uint256 len) internal pure returns (uint256) {
        require(len > 0 && len <= 33, "RLP out of len");
        uint256 offset = _payloadOffset(ptr);
        uint256 result;
        assembly {
            result := calldataload(add(ptr, offset))
            // cut off redundant bytes
            result := shr(mul(8, sub(32, sub(len, offset))), result)
        }
        return result;
    }

    function toUintStrict(uint256 ptr) internal pure returns (uint256) {
        // one byte prefix
        uint256 result;
        assembly {
            result := calldataload(add(ptr, 1))
        }
        return result;
    }

    function rawDataPtr(uint256 ptr) internal pure returns (uint256) {
        return ptr + _payloadOffset(ptr);
    }

    // @return entire rlp item byte length
    function itemLength(uint ptr) internal pure returns (uint256) {
        uint256 itemLen;
        uint256 byte0;
        assembly {
            byte0 := byte(0, calldataload(ptr))
        }

        if (byte0 < STRING_SHORT_START) itemLen = 1;
        else if (byte0 < STRING_LONG_START)
            itemLen = byte0 - STRING_SHORT_START + 1;
        else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                ptr := add(ptr, 1) // skip over the first byte
                let dataLen := shr(mul(8, sub(32, byteLen)), calldataload(ptr))
                itemLen := add(dataLen, add(byteLen, 1))
            }
        } else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        } else {
            assembly {
                let byteLen := sub(byte0, 0xf7)
                ptr := add(ptr, 1)

                let dataLen := shr(mul(8, sub(32, byteLen)), calldataload(ptr))
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        return itemLen;
    }

    function prefixLength(uint256 ptr) internal pure returns (uint256) {
        return _payloadOffset(ptr);
    }

    function estimatePrefixLength(uint256 length)
        internal
        pure
        returns (uint256)
    {
        if (length == 0) return 1;
        if (length == 1) return 1;
        if (length < 0x38) {
            return 1;
        }
        return 0;
    }

    // @return number of bytes until the data
    function _payloadOffset(uint256 ptr) private pure returns (uint256) {
        uint256 byte0;
        assembly {
            byte0 := byte(0, calldataload(ptr))
        }

        if (byte0 < STRING_SHORT_START) return 0;
        else if (
            byte0 < STRING_LONG_START ||
            (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START)
        ) return 1;
        else if (byte0 < LIST_SHORT_START)
            return byte0 - (STRING_LONG_START - 1) + 1;
        else return byte0 - (LIST_LONG_START - 1) + 1;
    }
}

// SPDX-License-Identifier: Apache-2.0

/*
 * @author Hamdi Allam [email protected]
 * Please reach out with any questions or concerns
 */
pragma solidity >=0.8.0;

library RLPReader {
    uint8 constant STRING_SHORT_START = 0x80;
    uint8 constant STRING_LONG_START = 0xb8;
    uint8 constant LIST_SHORT_START = 0xc0;
    uint8 constant LIST_LONG_START = 0xf8;
    uint8 constant WORD_SIZE = 32;

    struct RLPItem {
        uint len;
        uint memPtr;
    }

    struct Iterator {
        RLPItem item; // Item that's being iterated over.
        uint nextPtr; // Position of the next item in the list.
    }

    /*
     * @dev Returns the next element in the iteration. Reverts if it has not next element.
     * @param self The iterator.
     * @return The next element in the iteration.
     */
    function next(Iterator memory self) internal pure returns (RLPItem memory) {
        require(hasNext(self), "RLPReader donot have next");

        uint ptr = self.nextPtr;
        uint itemLength = _itemLength(ptr);
        self.nextPtr = ptr + itemLength;

        return RLPItem(itemLength, ptr);
    }

    /*
     * @dev Returns true if the iteration has more elements.
     * @param self The iterator.
     * @return true if the iteration has more elements.
     */
    function hasNext(Iterator memory self) internal pure returns (bool) {
        RLPItem memory item = self.item;
        return self.nextPtr < item.memPtr + item.len;
    }

    /*
     * @param item RLP encoded bytes
     */
    function toRlpItem(bytes memory item)
        internal
        pure
        returns (RLPItem memory)
    {
        uint memPtr;
        assembly {
            memPtr := add(item, 0x20)
        }

        return RLPItem(item.length, memPtr);
    }

    /*
     * @dev Create an iterator. Reverts if item is not a list.
     * @param self The RLP item.
     * @return An 'Iterator' over the item.
     */
    function iterator(RLPItem memory self)
        internal
        pure
        returns (Iterator memory)
    {
        require(isList(self), "RLPReader iterator not list");

        uint ptr = self.memPtr + _payloadOffset(self.memPtr);
        return Iterator(self, ptr);
    }

    /*
     * @param the RLP item.
     */
    function rlpLen(RLPItem memory item) internal pure returns (uint) {
        return item.len;
    }

    /*
     * @param the RLP item.
     * @return (memPtr, len) pair: location of the item's payload in memory.
     */
    function payloadLocation(RLPItem memory item)
        internal
        pure
        returns (uint, uint)
    {
        uint offset = _payloadOffset(item.memPtr);
        uint memPtr = item.memPtr + offset;
        uint len = item.len - offset; // data length
        return (memPtr, len);
    }

    /*
     * @param the RLP item.
     */
    function payloadLen(RLPItem memory item) internal pure returns (uint) {
        (, uint len) = payloadLocation(item);
        return len;
    }

    /*
     * @param the RLP item containing the encoded list.
     */
    function toList(RLPItem memory item)
        internal
        pure
        returns (RLPItem[] memory)
    {
        require(isList(item), "RLPReader not list");

        uint items = numItems(item);
        RLPItem[] memory result = new RLPItem[](items);

        uint memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint dataLen;
        for (uint i = 0; i < items; i++) {
            dataLen = _itemLength(memPtr);
            result[i] = RLPItem(dataLen, memPtr);
            memPtr = memPtr + dataLen;
        }

        return result;
    }

    // @return indicator whether encoded payload is a list. negate this function call for isData.
    function isList(RLPItem memory item) internal pure returns (bool) {
        if (item.len == 0) return false;

        uint8 byte0;
        uint memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < LIST_SHORT_START) return false;
        return true;
    }

    /*
     * @dev A cheaper version of keccak256(toRlpBytes(item)) that avoids copying memory.
     * @return keccak256 hash of RLP encoded bytes.
     */
    function rlpBytesKeccak256(RLPItem memory item)
        internal
        pure
        returns (bytes32)
    {
        uint256 ptr = item.memPtr;
        uint256 len = item.len;
        bytes32 result;
        assembly {
            result := keccak256(ptr, len)
        }
        return result;
    }

    /*
     * @dev A cheaper version of keccak256(toBytes(item)) that avoids copying memory.
     * @return keccak256 hash of the item payload.
     */
    function payloadKeccak256(RLPItem memory item)
        internal
        pure
        returns (bytes32)
    {
        (uint memPtr, uint len) = payloadLocation(item);
        bytes32 result;
        assembly {
            result := keccak256(memPtr, len)
        }
        return result;
    }

    /** RLPItem conversions into data types **/

    // @returns raw rlp encoding in bytes
    function toRlpBytes(RLPItem memory item)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory result = new bytes(item.len);
        if (result.length == 0) return result;

        uint ptr;
        assembly {
            ptr := add(0x20, result)
        }

        copy(item.memPtr, ptr, item.len);
        return result;
    }

    // any non-zero byte except "0x80" is considered true
    function toBoolean(RLPItem memory item) internal pure returns (bool) {
        require(item.len == 1, "RLPReader item bool out of len");
        uint result;
        uint memPtr = item.memPtr;
        assembly {
            result := byte(0, mload(memPtr))
        }

        // SEE Github Issue #5.
        // Summary: Most commonly used RLP libraries (i.e Geth) will encode
        // "0" as "0x80" instead of as "0". We handle this edge case explicitly
        // here.
        if (result == 0 || result == STRING_SHORT_START) {
            return false;
        } else {
            return true;
        }
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {
        // 1 byte for the length prefix
        require(item.len == 21, "RLPReader item address out of len");

        return address(uint160(toUint(item)));
    }

    function toUint(RLPItem memory item) internal pure returns (uint) {
        require(
            item.len > 0 && item.len <= 33,
            "RLPReader item uint out of len"
        );

        (uint memPtr, uint len) = payloadLocation(item);

        uint result;
        assembly {
            result := mload(memPtr)

            // shfit to the correct location if neccesary
            if lt(len, 32) {
                result := div(result, exp(256, sub(32, len)))
            }
        }

        return result;
    }

    // enforces 32 byte length
    function toUintStrict(RLPItem memory item) internal pure returns (uint) {
        // one byte prefix
        require(item.len == 33, "RLPReader item uint strict out of len");

        uint result;
        uint memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {
        require(item.len > 0, "RLPReader item bytes out of len");

        (uint memPtr, uint len) = payloadLocation(item);
        bytes memory result = new bytes(len);

        uint destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(memPtr, destPtr, len);
        return result;
    }

    /*
     * Private Helpers
     */

    // @return number of payload items inside an encoded list.
    function numItems(RLPItem memory item) private pure returns (uint) {
        if (item.len == 0) return 0;

        uint count = 0;
        uint currPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint endPtr = item.memPtr + item.len;
        while (currPtr < endPtr) {
            currPtr = currPtr + _itemLength(currPtr); // skip over an item
            count++;
        }

        return count;
    }

    // @return entire rlp item byte length
    function _itemLength(uint memPtr) private pure returns (uint) {
        uint itemLen;
        uint byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) itemLen = 1;
        else if (byte0 < STRING_LONG_START)
            itemLen = byte0 - STRING_SHORT_START + 1;
        else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                memPtr := add(memPtr, 1) // skip over the first byte

                /* 32 byte word size */
                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len
                itemLen := add(dataLen, add(byteLen, 1))
            }
        } else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        } else {
            assembly {
                let byteLen := sub(byte0, 0xf7)
                memPtr := add(memPtr, 1)

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        return itemLen;
    }

    // @return number of bytes until the data
    function _payloadOffset(uint memPtr) private pure returns (uint) {
        uint byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) return 0;
        else if (
            byte0 < STRING_LONG_START ||
            (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START)
        ) return 1;
        else if (byte0 < LIST_SHORT_START)
            // being explicit
            return byte0 - (STRING_LONG_START - 1) + 1;
        else return byte0 - (LIST_LONG_START - 1) + 1;
    }

    /*
     * @param src Pointer to source
     * @param dest Pointer to destination
     * @param len Amount of memory to copy from the source
     */
    function copy(
        uint src,
        uint dest,
        uint len
    ) private pure {
        if (len == 0) return;

        // copy as many word sizes as possible
        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += WORD_SIZE;
            dest += WORD_SIZE;
        }

        if (len > 0) {
            // left over bytes. Mask is used to remove unwanted bytes from the word
            uint mask = 256**(WORD_SIZE - len) - 1;
            assembly {
                let srcpart := and(mload(src), not(mask)) // zero out src
                let destpart := and(mload(dest), mask) // retrieve the bytes
                mstore(dest, or(destpart, srcpart))
            }
        }
    }
}