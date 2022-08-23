// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721Psi.sol";

interface i_ERC721Psi {
    function initialize() external;
}

contract EventNFT {
  string $version = "0.1.0";
  bytes32 $validsignature;

  event NewEventNFTCreated(address addr, bytes32 hostSignature, bytes32 eventSignature);

  // to deploy another contract using owner address and salt specified
  function createEventNFTContract(
    bytes32 hostSignature,
    bytes32 eventSignature,
    string memory eventName,
    string memory eventSymbol
) external {
        bytes32 salt = keccak256(abi.encodePacked(hostSignature, eventSignature));
        ERC721Psi _contract = new ERC721Psi{
            salt: bytes32(salt)    // the number of salt determines the address of the contract that will be deployed
        }();
        ERC721Psi(address(_contract)).initialize(hostSignature, eventSignature, eventName, eventSymbol);
        emit NewEventNFTCreated(address(_contract), hostSignature, eventSignature);
  }

  // get the computed address before the contract DeployWithCreate2 deployed using Bytecode of contract DeployWithCreate2 and salt specified by the sender
  function getAddress(bytes memory bytecode, uint _salt) 
    public 
    view 
    returns (address) 
  {
      bytes32 hash = keccak256(
          abi.encodePacked(
              bytes1(0xff), address(this), _salt, keccak256(bytecode)
          )
      );
      return address (uint160(uint(hash)));
  }
  // get the ByteCode of the contract DeployWithCreate2
  function getBytecode(address _owner) public pure returns (bytes memory) {
      bytes memory bytecode = type(ERC721Psi).creationCode;
      return abi.encodePacked(bytecode, abi.encode(_owner));
  }

  // function createNFTContract() external returns (address nft) {
  //   // Create the NFT contract
  //   bytes32 salt = keccak256(abi.encode("12345"));
  //   // bytes32 salt = keccak256(abi.encodePacked($validsignature));
  //   // bytes memory bytecode = _bytecode();
  //   bytes memory bytecode = type(ERC721Psi).creationCode;
  //   assembly {
  //     nft := create2(0, add(bytecode, 32), mload(bytecode), salt)
  //   }
  //   i_ERC721Psi(nft).initialize();
  // }

  // NFT Contract Bytecode: ERC-721Psi
//   function _bytecode() private pure returns (bytes memory) {
//     return bytes("60806040523480156200001157600080fd5b5060405162001c0f38038062001c0f8339810160408190526200003491620001d3565b8151620000499060019060208501906200007a565b5080516200005f9060029060208401906200007a565b5050600380546001600160a01b03191633179055506200028d565b82805462000088906200023a565b90600052602060002090601f016020900481019282620000ac5760008555620000f7565b82601f10620000c757805160ff1916838001178555620000f7565b82800160010185558215620000f7579182015b82811115620000f7578251825591602001919060010190620000da565b506200010592915062000109565b5090565b5b808211156200010557600081556001016200010a565b600082601f83011262000131578081fd5b81516001600160401b03808211156200014e576200014e62000277565b604051601f8301601f19908116603f0116810190828211818310171562000179576200017962000277565b8160405283815260209250868385880101111562000195578485fd5b8491505b83821015620001b8578582018301518183018401529082019062000199565b83821115620001c957848385830101525b9695505050505050565b60008060408385031215620001e6578182fd5b82516001600160401b0380821115620001fd578384fd5b6200020b8683870162000120565b9350602085015191508082111562000221578283fd5b50620002308582860162000120565b9150509250929050565b6002810460018216806200024f57607f821691505b602082108114156200027157634e487b7160e01b600052602260045260246000fd5b50919050565b634e487b7160e01b600052604160045260246000fd5b611972806200029d6000396000f3fe608060405234801561001057600080fd5b506004361061010b5760003560e01c80634f6ccce7116100a257806395d89b411161007157806395d89b4114610212578063a22cb4651461021a578063b88d4fde1461022d578063c87b56dd14610240578063e985e9c5146102535761010b565b80634f6ccce7146101d15780636352211e146101e457806370a08231146101f75780638129fc1c1461020a5761010b565b806318160ddd116100de57806318160ddd1461018357806323b872dd146101985780632f745c59146101ab57806342842e0e146101be5761010b565b806301ffc9a71461011057806306fdde0314610139578063081812fc1461014e578063095ea7b31461016e575b600080fd5b61012361011e366004611145565b610266565b6040516101309190611241565b60405180910390f35b6101416102c9565b604051610130919061124c565b61016161015c36600461117d565b61035b565b60405161013091906111f0565b61018161017c36600461111c565b6103a7565b005b61018b61043f565b60405161013091906116ff565b6101816101a6366004610fd2565b610445565b61018b6101b936600461111c565b61047d565b6101816101cc366004610fd2565b610510565b61018b6101df36600461117d565b61052b565b6101616101f236600461117d565b6105a7565b61018b610205366004610f86565b6105bb565b610181610644565b610141610670565b6101816102283660046110e2565b61067f565b61018161023b36600461100d565b61074d565b61014161024e36600461117d565b61078c565b610123610261366004610fa0565b61080f565b60006001600160e01b031982166380ac58cd60e01b148061029757506001600160e01b03198216635b5e139f60e01b145b806102b257506001600160e01b0319821663780e9d6360e01b145b806102c157506102c18261083d565b90505b919050565b6060600180546102d890611777565b80601f016020809104026020016040519081016040528092919081815260200182805461030490611777565b80156103515780601f1061032657610100808354040283529160200191610351565b820191906000526020600020905b81548152906001019060200180831161033457829003601f168201915b5050505050905090565b600061036682610856565b61038b5760405162461bcd60e51b8152600401610382906112ee565b60405180910390fd5b506000908152600660205260409020546001600160a01b031690565b60006103b2826105a7565b9050806001600160a01b0316836001600160a01b031614156103e65760405162461bcd60e51b8152600401610382906114cf565b806001600160a01b03166103f861085d565b6001600160a01b0316148061041457506104148161026161085d565b6104305760405162461bcd60e51b815260040161038290611656565b61043a8383610861565b505050565b60055490565b61045661045061085d565b826108cf565b6104725760405162461bcd60e51b815260040161038290611567565b61043a838383610954565b60008060005b6005548110156104f15761049681610856565b80156104bb57506104a6816105a7565b6001600160a01b0316856001600160a01b0316145b156104df57838214156104d157915061050a9050565b816104db816117b2565b9250505b806104e9816117b2565b915050610483565b5060405162461bcd60e51b815260040161038290611416565b92915050565b61043a8383836040518060200160405280600081525061074d565b600061053561043f565b82106105535760405162461bcd60e51b8152600401610382906112a9565b6000805b6005548110156105a05761056a81610856565b1561058e57838214156105805791506102c49050565b8161058a816117b2565b9250505b80610598816117b2565b915050610557565b5050919050565b6000806105b383610ac0565b509392505050565b60006001600160a01b0382166105e35760405162461bcd60e51b81526004016103829061133d565b6000805b60055481101561063d576105fa81610856565b1561062d57610608816105a7565b6001600160a01b0316846001600160a01b0316141561062d5761062a826117b2565b91505b610636816117b2565b90506105e7565b5092915050565b6003546001600160a01b0316331461066e5760405162461bcd60e51b81526004016103829061145a565b565b6060600280546102d890611777565b61068761085d565b6001600160a01b0316826001600160a01b031614156106b85760405162461bcd60e51b81526004016103829061138a565b80600760006106c561085d565b6001600160a01b03908116825260208083019390935260409182016000908120918716808252919093529120805460ff19169215159290921790915561070961085d565b6001600160a01b03167f17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31836040516107419190611241565b60405180910390a35050565b61075e61075861085d565b836108cf565b61077a5760405162461bcd60e51b815260040161038290611567565b61078684848484610b12565b50505050565b606061079782610856565b6107b35760405162461bcd60e51b81526004016103829061125f565b60006107bd610b47565b905060008151116107dd5760405180602001604052806000815250610808565b806107e784610b59565b6040516020016107f89291906111c1565b6040516020818303038152906040525b9392505050565b6001600160a01b03918216600090815260076020908152604080832093909416825291909152205460ff1690565b6001600160e01b031981166301ffc9a760e01b14919050565b6005541190565b3390565b600081815260066020526040902080546001600160a01b0319166001600160a01b0384169081179091558190610896826105a7565b6001600160a01b03167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b92560405160405180910390a45050565b60006108da82610856565b6108f65760405162461bcd60e51b815260040161038290611607565b6000610901836105a7565b9050806001600160a01b0316846001600160a01b0316148061093c5750836001600160a01b03166109318461035b565b6001600160a01b0316145b8061094c575061094c818561080f565b949350505050565b60008061096083610ac0565b91509150846001600160a01b0316826001600160a01b0316146109955760405162461bcd60e51b8152600401610382906115bb565b6001600160a01b0384166109bb5760405162461bcd60e51b815260040161038290611488565b6109c88585856001610786565b6109d3600084610861565b60006109e0846001611708565b90506109ed600082610c74565b1580156109fb575060055481105b15610a3157600081815260046020526040812080546001600160a01b0319166001600160a01b038916179055610a319082610c9b565b600084815260046020526040902080546001600160a01b0319166001600160a01b038716179055818414610a6a57610a6a600085610c9b565b83856001600160a01b0316876001600160a01b03167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef60405160405180910390a4610ab88686866001610786565b505050505050565b600080610acc83610856565b610ae85760405162461bcd60e51b8152600401610382906116b3565b610af183610cc7565b6000818152600460205260409020546001600160a01b031694909350915050565b610b1d848484610954565b610b2b848484600185610cd3565b6107865760405162461bcd60e51b8152600401610382906113c1565b60408051602081019091526000815290565b606081610b7e57506040805180820190915260018152600360fc1b60208201526102c4565b8160005b8115610ba85780610b92816117b2565b9150610ba19050600a83611720565b9150610b82565b60008167ffffffffffffffff811115610bd157634e487b7160e01b600052604160045260246000fd5b6040519080825280601f01601f191660200182016040528015610bfb576020820181803683370190505b5090505b841561094c57610c10600183611734565b9150610c1d600a866117cd565b610c28906030611708565b60f81b818381518110610c4b57634e487b7160e01b600052603260045260246000fd5b60200101906001600160f81b031916908160001a905350610c6d600a86611720565b9450610bff565b600881901c600090815260208390526040902054600160ff1b60ff83161c16151592915050565b600881901c600090815260209290925260409091208054600160ff1b60ff9093169290921c9091179055565b60006102c18183610e24565b6000610ce7856001600160a01b0316610ecf565b15610e1757506001835b610cfb8486611708565b811015610e1157856001600160a01b031663150b7a02610d1961085d565b8984876040518563ffffffff1660e01b8152600401610d3b9493929190611204565b602060405180830381600087803b158015610d5557600080fd5b505af1925050508015610d85575060408051601f3d908101601f19168201909252610d8291810190611161565b60015b610ddf573d808015610db3576040519150601f19603f3d011682016040523d82523d6000602084013e610db8565b606091505b508051610dd75760405162461bcd60e51b8152600401610382906113c1565b805181602001fd5b828015610dfc57506001600160e01b03198116630a85bd0160e11b145b92505080610e09816117b2565b915050610cf1565b50610e1b565b5060015b95945050505050565b600881901c60008181526020849052604081205490919060ff808516919082181c8015610e6657610e5481610ede565b60ff168203600884901b179350610ec6565b60008311610e865760405162461bcd60e51b815260040161038290611513565b506000199091016000818152602086905260409020549091908015610ec157610eae81610ede565b60ff0360ff16600884901b179350610ec6565b610e66565b50505092915050565b6001600160a01b03163b151590565b6000604051806101200160405280610100815260200161183d610100913960f87e818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff610f2785610f57565b02901c81518110610f4857634e487b7160e01b600052603260045260246000fd5b016020015160f81c9050919050565b6000808211610f6557600080fd5b5060008190031690565b80356001600160a01b03811681146102c457600080fd5b600060208284031215610f97578081fd5b61080882610f6f565b60008060408385031215610fb2578081fd5b610fbb83610f6f565b9150610fc960208401610f6f565b90509250929050565b600080600060608486031215610fe6578081fd5b610fef84610f6f565b9250610ffd60208501610f6f565b9150604084013590509250925092565b60008060008060808587031215611022578081fd5b61102b85610f6f565b935061103960208601610f6f565b925060408501359150606085013567ffffffffffffffff8082111561105c578283fd5b818701915087601f83011261106f578283fd5b8135818111156110815761108161180d565b604051601f8201601f19908116603f011681019083821181831017156110a9576110a961180d565b816040528281528a60208487010111156110c1578586fd5b82602086016020830137918201602001949094529598949750929550505050565b600080604083850312156110f4578182fd5b6110fd83610f6f565b915060208301358015158114611111578182fd5b809150509250929050565b6000806040838503121561112e578182fd5b61113783610f6f565b946020939093013593505050565b600060208284031215611156578081fd5b813561080881611823565b600060208284031215611172578081fd5b815161080881611823565b60006020828403121561118e578081fd5b5035919050565b600081518084526111ad81602086016020860161174b565b601f01601f19169290920160200192915050565b600083516111d381846020880161174b565b8351908301906111e781836020880161174b565b01949350505050565b6001600160a01b0391909116815260200190565b6001600160a01b038581168252841660208201526040810183905260806060820181905260009061123790830184611195565b9695505050505050565b901515815260200190565b6000602082526108086020830184611195565b6020808252602a908201527f4552433732315073693a2055524920717565727920666f72206e6f6e657869736040820152693a32b73a103a37b5b2b760b11b606082015260800190565b60208082526025908201527f4552433732315073693a20676c6f62616c20696e646578206f7574206f6620626040820152646f756e647360d81b606082015260800190565b6020808252602f908201527f4552433732315073693a20617070726f76656420717565727920666f72206e6f60408201526e3732bc34b9ba32b73a103a37b5b2b760891b606082015260800190565b6020808252602d908201527f4552433732315073693a2062616c616e636520717565727920666f722074686560408201526c207a65726f206164647265737360981b606082015260800190565b6020808252601c908201527f4552433732315073693a20617070726f766520746f2063616c6c657200000000604082015260600190565b60208082526035908201527f4552433732315073693a207472616e7366657220746f206e6f6e20455243373260408201527418a932b1b2b4bb32b91034b6b83632b6b2b73a32b960591b606082015260800190565b60208082526024908201527f4552433732315073693a206f776e657220696e646578206f7574206f6620626f604082015263756e647360e01b606082015260800190565b60208082526014908201527322a9219b9918a839b49d102327a92124a22222a760611b604082015260600190565b60208082526027908201527f4552433732315073693a207472616e7366657220746f20746865207a65726f206040820152666164647265737360c81b606082015260800190565b60208082526024908201527f4552433732315073693a20617070726f76616c20746f2063757272656e74206f6040820152633bb732b960e11b606082015260800190565b60208082526034908201527f4269744d6170733a205468652073657420626974206265666f7265207468652060408201527334b73232bc103237b2b9b713ba1032bc34b9ba1760611b606082015260800190565b60208082526034908201527f4552433732315073693a207472616e736665722063616c6c6572206973206e6f6040820152731d081bdddb995c881b9bdc88185c1c1c9bdd995960621b606082015260800190565b6020808252602c908201527f4552433732315073693a207472616e73666572206f6620746f6b656e2074686160408201526b3a1034b9903737ba1037bbb760a11b606082015260800190565b6020808252602f908201527f4552433732315073693a206f70657261746f7220717565727920666f72206e6f60408201526e3732bc34b9ba32b73a103a37b5b2b760891b606082015260800190565b6020808252603b908201527f4552433732315073693a20617070726f76652063616c6c6572206973206e6f7460408201527f206f776e6572206e6f7220617070726f76656420666f7220616c6c0000000000606082015260800190565b6020808252602c908201527f4552433732315073693a206f776e657220717565727920666f72206e6f6e657860408201526b34b9ba32b73a103a37b5b2b760a11b606082015260800190565b90815260200190565b6000821982111561171b5761171b6117e1565b500190565b60008261172f5761172f6117f7565b500490565b600082821015611746576117466117e1565b500390565b60005b8381101561176657818101518382015260200161174e565b838111156107865750506000910152565b60028104600182168061178b57607f821691505b602082108114156117ac57634e487b7160e01b600052602260045260246000fd5b50919050565b60006000198214156117c6576117c66117e1565b5060010190565b6000826117dc576117dc6117f7565b500690565b634e487b7160e01b600052601160045260246000fd5b634e487b7160e01b600052601260045260246000fd5b634e487b7160e01b600052604160045260246000fd5b6001600160e01b03198116811461183957600080fd5b5056fe0001020903110a19042112290b311a3905412245134d2a550c5d32651b6d3a7506264262237d468514804e8d2b95569d0d495ea533a966b11c886eb93bc176c9071727374353637324837e9b47af86c7155181ad4fd18ed32c9096db57d59ee30e2e4a6a5f92a6be3498aae067ddb2eb1d5989b56fd7baf33ca0c2ee77e5caf7ff0810182028303840444c545c646c7425617c847f8c949c48a4a8b087b8c0c816365272829aaec650acd0d28fdad4e22d6991bd97dfdcea58b4d6f29fede4f6fe0f1f2f3f4b5b6b607b8b93a3a7b7bf357199c5abcfd9e168bcdee9b3f1ecf5fd1e3e5a7a8aa2b670c4ced8bbe8f0f4fc3d79a1c3cde7effb78cce6facbf9f8a2646970667358221220ebb106bb3b36a3ae65a0123062fc4a8cf68d3890f41dbf3d42e4091a94055a6f64736f6c63430008010033");
//   }
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

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";
import "solidity-bits/contracts/BitMaps.sol";


contract ERC721Psi is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using Address for address;
    using Strings for uint256;
    using BitMaps for BitMaps.BitMap;

    BitMaps.BitMap private _batchHead;

    address private $factory;
    string private $name;
    string private $symbol;
    bytes32 private $hostSignature;
    bytes32 private $eventSignature;

    // Mapping from token ID to owner address
    mapping(uint256 => address) internal _owners;
    uint256 internal _minted;

    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor() {
        $factory = msg.sender;
    }

    // called once by the factory contract after deployed.
    function initialize(
        bytes32 hostSignature,
        bytes32 eventSignature,
        string memory name,
        string memory symbol
    ) external {
        require(msg.sender == $factory, 'ERC721Psi: FORBIDDEN'); // sufficient check
        $name = name;
        $symbol = symbol;
        $hostSignature = hostSignature;
        $eventSignature = eventSignature;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) 
        public 
        view 
        virtual 
        override 
        returns (uint) 
    {
        require(owner != address(0), "ERC721Psi: balance query for the zero address");

        uint count;
        for( uint i; i < _minted; ++i ){
            if(_exists(i)){
                if( owner == ownerOf(i)){
                    ++count;
                }
            }
        }
        return count;
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        (address owner, ) = _ownerAndBatchHeadOf(tokenId);
        return owner;
    }

    function _ownerAndBatchHeadOf(uint256 tokenId) internal view returns (address owner, uint256 tokenIdBatchHead){
        require(_exists(tokenId), "ERC721Psi: owner query for nonexistent token");
        tokenIdBatchHead = _getBatchHead(tokenId);
        owner = _owners[tokenIdBatchHead];
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return $name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return $symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Psi: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }


    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721Psi: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721Psi: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721Psi: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        require(operator != _msgSender(), "ERC721Psi: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721Psi: transfer caller is not owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721Psi: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, 1,_data),
            "ERC721Psi: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return tokenId < _minted;
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721Psi: operator query for nonexistent token"
        );
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called for each safe transfer.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 quantity) internal virtual {
        _safeMint(to, quantity, "");
    }

    
    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal virtual {
        uint256 startTokenId = _minted;
        _mint(to, quantity);
        require(
            _checkOnERC721Received(address(0), to, startTokenId, quantity, _data),
            "ERC721Psi: transfer to non ERC721Receiver implementer"
        );
    }


    function _mint(
        address to,
        uint256 quantity
    ) internal virtual {
        uint256 tokenIdBatchHead = _minted;
        
        require(quantity > 0, "ERC721Psi: quantity must be greater 0");
        require(to != address(0), "ERC721Psi: mint to the zero address");
        
        _beforeTokenTransfers(address(0), to, tokenIdBatchHead, quantity);
        _minted += quantity;
        _owners[tokenIdBatchHead] = to;
        _batchHead.set(tokenIdBatchHead);
        _afterTokenTransfers(address(0), to, tokenIdBatchHead, quantity);
        
        // Emit events
        for(uint256 tokenId=tokenIdBatchHead;tokenId < tokenIdBatchHead + quantity; tokenId++){
            emit Transfer(address(0), to, tokenId);
        } 
    }


    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        (address owner, uint256 tokenIdBatchHead) = _ownerAndBatchHeadOf(tokenId);

        require(
            owner == from,
            "ERC721Psi: transfer of token that is not own"
        );
        require(to != address(0), "ERC721Psi: transfer to the zero address");

        _beforeTokenTransfers(from, to, tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);   

        uint256 nextTokenId = tokenId + 1;

        if(!_batchHead.get(nextTokenId) &&  
            nextTokenId < _minted
        ) {
            _owners[nextTokenId] = from;
            _batchHead.set(nextTokenId);
        }

        _owners[tokenId] = to;
        if(tokenId != tokenIdBatchHead) {
            _batchHead.set(tokenId);
        }

        emit Transfer(from, to, tokenId);

        _afterTokenTransfers(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param startTokenId uint256 the first ID of the tokens to be transferred
     * @param quantity uint256 amount of the tokens to be transfered.
     * @param _data bytes optional data to send along with the call
     * @return r bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity,
        bytes memory _data
    ) private returns (bool r) {
        if (to.isContract()) {
            r = true;
            for(uint256 tokenId = startTokenId; tokenId < startTokenId + quantity; tokenId++){
                try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                    r = r && retval == IERC721Receiver.onERC721Received.selector;
                } catch (bytes memory reason) {
                    if (reason.length == 0) {
                        revert("ERC721Psi: transfer to non ERC721Receiver implementer");
                    } else {
                        assembly {
                            revert(add(32, reason), mload(reason))
                        }
                    }
                }
            }
            return r;
        } else {
            return true;
        }
    }

    function _getBatchHead(uint256 tokenId) internal view returns (uint256 tokenIdBatchHead) {
        tokenIdBatchHead = _batchHead.scanForward(tokenId); 
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _minted;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256 tokenId) {
        require(index < totalSupply(), "ERC721Psi: global index out of bounds");
        
        uint count;
        for(uint i; i < _minted; i++){
            if(_exists(i)){
                if(count == index) return i;
                else count++;
            }
        }
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256 tokenId) {
        uint count;
        for(uint i; i < _minted; i++){
            if(_exists(i) && owner == ownerOf(i)){
                if(count == index) return i;
                else count++;
            }
        }

        revert("ERC721Psi: owner index out of bounds");
    }


    /**
     * @dev Hook that is called before a set of serially-ordered token ids are about to be transferred. This includes minting.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     */
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    /**
     * @dev Hook that is called after a set of serially-ordered token ids have been transferred. This includes
     * minting.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
/**
   _____       ___     ___ __           ____  _ __      
  / ___/____  / (_)___/ (_) /___  __   / __ )(_) /______
  \__ \/ __ \/ / / __  / / __/ / / /  / __  / / __/ ___/
 ___/ / /_/ / / / /_/ / / /_/ /_/ /  / /_/ / / /_(__  ) 
/____/\____/_/_/\__,_/_/\__/\__, /  /_____/_/\__/____/  
                           /____/                        

- npm: https://www.npmjs.com/package/solidity-bits
- github: https://github.com/estarriolvetch/solidity-bits

 */
pragma solidity ^0.8.0;

import "./BitScan.sol";

/**
 * @dev This Library is a modified version of Openzeppelin's BitMaps library.
 * Functions of finding the index of the closest set bit from a given index are added.
 * The indexing of each bucket is modifed to count from the MSB to the LSB instead of from the LSB to the MSB.
 * The modification of indexing makes finding the closest previous set bit more efficient in gas usage.
*/

/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, providing the keys are sequential.
 * Largelly inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 */

library BitMaps {
    using BitScan for uint256;
    uint256 private constant MASK_INDEX_ZERO = (1 << 255);
    uint256 private constant MASK_FULL = type(uint256).max;

    struct BitMap {
        mapping(uint256 => uint256) _data;
    }

    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(BitMap storage bitmap, uint256 index) internal view returns (bool) {
        uint256 bucket = index >> 8;
        uint256 mask = MASK_INDEX_ZERO >> (index & 0xff);
        return bitmap._data[bucket] & mask != 0;
    }

    /**
     * @dev Sets the bit at `index` to the boolean `value`.
     */
    function setTo(
        BitMap storage bitmap,
        uint256 index,
        bool value
    ) internal {
        if (value) {
            set(bitmap, index);
        } else {
            unset(bitmap, index);
        }
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = MASK_INDEX_ZERO >> (index & 0xff);
        bitmap._data[bucket] |= mask;
    }

    /**
     * @dev Unsets the bit at `index`.
     */
    function unset(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = MASK_INDEX_ZERO >> (index & 0xff);
        bitmap._data[bucket] &= ~mask;
    }


    /**
     * @dev Consecutively sets `amount` of bits starting from the bit at `startIndex`.
     */    
    function setBatch(BitMap storage bitmap, uint256 startIndex, uint256 amount) internal {
        uint256 bucket = startIndex >> 8;

        uint256 bucketStartIndex = (startIndex & 0xff);

        unchecked {
            if(bucketStartIndex + amount < 256) {
                bitmap._data[bucket] |= MASK_FULL << (256 - amount) >> bucketStartIndex;
            } else {
                bitmap._data[bucket] |= MASK_FULL >> bucketStartIndex;
                amount -= (256 - bucketStartIndex);
                bucket++;

                while(amount > 256) {
                    bitmap._data[bucket] = MASK_FULL;
                    amount -= 256;
                    bucket++;
                }

                bitmap._data[bucket] |= MASK_FULL << (256 - amount);
            }
        }
    }


    /**
     * @dev Consecutively unsets `amount` of bits starting from the bit at `startIndex`.
     */    
    function unsetBatch(BitMap storage bitmap, uint256 startIndex, uint256 amount) internal {
        uint256 bucket = startIndex >> 8;

        uint256 bucketStartIndex = (startIndex & 0xff);

        unchecked {
            if(bucketStartIndex + amount < 256) {
                bitmap._data[bucket] &= ~(MASK_FULL << (256 - amount) >> bucketStartIndex);
            } else {
                bitmap._data[bucket] &= ~(MASK_FULL >> bucketStartIndex);
                amount -= (256 - bucketStartIndex);
                bucket++;

                while(amount > 256) {
                    bitmap._data[bucket] = 0;
                    amount -= 256;
                    bucket++;
                }

                bitmap._data[bucket] &= ~(MASK_FULL << (256 - amount));
            }
        }
    }


    /**
     * @dev Find the closest index of the set bit before `index`.
     */
    function scanForward(BitMap storage bitmap, uint256 index) internal view returns (uint256 setBitIndex) {
        uint256 bucket = index >> 8;

        // index within the bucket
        uint256 bucketIndex = (index & 0xff);

        // load a bitboard from the bitmap.
        uint256 bb = bitmap._data[bucket];

        // offset the bitboard to scan from `bucketIndex`.
        bb = bb >> (0xff ^ bucketIndex); // bb >> (255 - bucketIndex)
        
        if(bb > 0) {
            unchecked {
                setBitIndex = (bucket << 8) | (bucketIndex -  bb.bitScanForward256());    
            }
        } else {
            while(true) {
                require(bucket > 0, "BitMaps: The set bit before the index doesn't exist.");
                unchecked {
                    bucket--;
                }
                // No offset. Always scan from the least significiant bit now.
                bb = bitmap._data[bucket];
                
                if(bb > 0) {
                    unchecked {
                        setBitIndex = (bucket << 8) | (255 -  bb.bitScanForward256());
                        break;
                    }
                } 
            }
        }
    }

    function getBucket(BitMap storage bitmap, uint256 bucket) internal view returns (uint256) {
        return bitmap._data[bucket];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
/**
   _____       ___     ___ __           ____  _ __      
  / ___/____  / (_)___/ (_) /___  __   / __ )(_) /______
  \__ \/ __ \/ / / __  / / __/ / / /  / __  / / __/ ___/
 ___/ / /_/ / / / /_/ / / /_/ /_/ /  / /_/ / / /_(__  ) 
/____/\____/_/_/\__,_/_/\__/\__, /  /_____/_/\__/____/  
                           /____/                        

- npm: https://www.npmjs.com/package/solidity-bits
- github: https://github.com/estarriolvetch/solidity-bits

 */

pragma solidity ^0.8.0;


library BitScan {
    uint256 constant private DEBRUIJN_256 = 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff;
    bytes constant private LOOKUP_TABLE_256 = hex"0001020903110a19042112290b311a3905412245134d2a550c5d32651b6d3a7506264262237d468514804e8d2b95569d0d495ea533a966b11c886eb93bc176c9071727374353637324837e9b47af86c7155181ad4fd18ed32c9096db57d59ee30e2e4a6a5f92a6be3498aae067ddb2eb1d5989b56fd7baf33ca0c2ee77e5caf7ff0810182028303840444c545c646c7425617c847f8c949c48a4a8b087b8c0c816365272829aaec650acd0d28fdad4e22d6991bd97dfdcea58b4d6f29fede4f6fe0f1f2f3f4b5b6b607b8b93a3a7b7bf357199c5abcfd9e168bcdee9b3f1ecf5fd1e3e5a7a8aa2b670c4ced8bbe8f0f4fc3d79a1c3cde7effb78cce6facbf9f8";

    /**
        @dev Isolate the least significant set bit.
     */ 
    function isolateLS1B256(uint256 bb) pure internal returns (uint256) {
        require(bb > 0);
        unchecked {
            return bb & (0 - bb);
        }
    } 

    /**
        @dev Isolate the most significant set bit.
     */ 
    function isolateMS1B256(uint256 bb) pure internal returns (uint256) {
        require(bb > 0);
        unchecked {
            bb |= bb >> 128;
            bb |= bb >> 64;
            bb |= bb >> 32;
            bb |= bb >> 16;
            bb |= bb >> 8;
            bb |= bb >> 4;
            bb |= bb >> 2;
            bb |= bb >> 1;
            
            return (bb >> 1) + 1;
        }
    } 

    /**
        @dev Find the index of the lest significant set bit. (trailing zero count)
     */ 
    function bitScanForward256(uint256 bb) pure internal returns (uint8) {
        unchecked {
            return uint8(LOOKUP_TABLE_256[(isolateLS1B256(bb) * DEBRUIJN_256) >> 248]);
        }   
    }

    /**
        @dev Find the index of the most significant set bit.
     */ 
    function bitScanReverse256(uint256 bb) pure internal returns (uint8) {
        unchecked {
            return 255 - uint8(LOOKUP_TABLE_256[((isolateMS1B256(bb) * DEBRUIJN_256) >> 248)]);
        }   
    }

    function log2(uint256 bb) pure internal returns (uint8) {
        unchecked {
            return uint8(LOOKUP_TABLE_256[(isolateMS1B256(bb) * DEBRUIJN_256) >> 248]);
        } 
    }
}