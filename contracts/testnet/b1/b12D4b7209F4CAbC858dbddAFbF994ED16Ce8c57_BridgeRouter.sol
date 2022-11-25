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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IERC20PeggedToken is IERC20, IERC20Metadata {
    function getOrigin() external view returns (uint256, address);

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
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