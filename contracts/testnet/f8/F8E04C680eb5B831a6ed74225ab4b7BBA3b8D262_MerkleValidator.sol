pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;
//import "./interfaces/OrderItem.sol";

interface IWyvernProxyRegistry{

    function proxies(address a)  external view returns (address);

}

interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

interface IERC1155 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) external;
}

interface ERC20Basic{
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface ERC20 is ERC20Basic {
    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IRoyaltyFeeManager {
    function calculateRoyaltyFeeAndGetRecipient(
        address collection,
        uint256 tokenId,
        uint256 amount
    ) external view returns (address, uint256);
}

contract Ownable {
    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }
}


/// @title MerkleValidator enables matching trait-based and collection-based orders for ERC721 and ERC1155 tokens.
/// @author 0age
/// @dev This contract is intended to be called during atomicMatch_ via DELEGATECALL.
contract MerkleValidator is Ownable{
    struct Item {
        address from;
        address to;
        address tokenAddress;
        uint256 tokenId;
        uint256 price;
        bytes32[] proof;
    }

    function getTargetProxies(address contractAddr,address target)  external view returns (address){
        return    IWyvernProxyRegistry(contractAddr).proxies(target);

    }


    function toStringNOPre(bytes memory data)
    public
    pure
    returns (string memory)
    {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(data.length * 2);

        for (uint256 i = 0; i < data.length; i++) {
            str[i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[1 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    function toStringNoPre(address account)
    public
    pure
    returns (string memory)
    {
        return toStringNOPre(abi.encodePacked(account));
    }

    function append(string memory _a, string memory _b)
    internal
    pure
    returns (string memory)
    {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory bab = new bytes(_ba.length + _bb.length);
        uint256 k = 0;
        for (uint256 i = 0; i < _ba.length; i++) {
            bab[k++] = _ba[i];

        }


        for (uint256 y = 0; y < _bb.length; y++){
            bab[k++] = _bb[y];

        }
        return string(bab);
    }

    function genLeaf(
        address tokenAddress,
        uint256 tokenId,
        uint256 price
    ) public view returns (bytes32) {
        bytes32 leaf = keccak256(abi.encode(tokenAddress, tokenId, price));
        return leaf;
    }

    address public transferNFTManagerAddress;

    function setExchangeAddr(address _transferNFTManagerAddress) public onlyOwner {
        transferNFTManagerAddress = _transferNFTManagerAddress;
    }


    address public wyvernProxyRegistry;

    function setWyvernProxyRegistry(address _wyvernProxyRegistry) public onlyOwner {
        wyvernProxyRegistry = _wyvernProxyRegistry;
    }

    address public royaltyFeeManager;

    function setIRoyaltyFeeManager(address _royaltyFeeManager) public onlyOwner {
        royaltyFeeManager = _royaltyFeeManager;
    }

    address public currency;

    function setCurrency(address _currency) public onlyOwner {
        currency = _currency;
    }


    /* Cancelled / finalized orders, by hash. */
    mapping(bytes32 => bool) public cancelledOrFinalized;

    function batch(Item[] memory orderItems, bytes32 root)
    external payable
    returns (bool)
    {
        Item memory itemVerify = orderItems[0];
        address proxyForFrom = IWyvernProxyRegistry(wyvernProxyRegistry).proxies(itemVerify.from);

        require(msg.sender == proxyForFrom, "Only owner's proxy can process nft transfer!");

        for (uint256 i = 0; i < orderItems.length; i++) {
            Item memory item = orderItems[i];

            //matchERC721UsingCriteria(item.from,item.to,IERC721(item.tokenAddress),item.tokenId,item.root,item.proof);
            if (root != bytes32(0)) {
                //string using encodePacked
                string memory xx = toStringNOPre(
                    abi.encodePacked(
                        item.tokenAddress,
                        item.tokenId,
                        item.price
                    )
                );

                bytes32 leaf = keccak256(
                    abi.encode(item.tokenAddress, item.tokenId, item.price)
                );
                emit ResultHash(leaf, xx);

                //这里用leaf的值 来代替 order的hash
                //bytes memory leaf = abi.encodePacked(abcStr);
                if (cancelledOrFinalized[leaf]==false&&verify(leaf, root, item.proof)) {
                    emit ResultHash(leaf, xx);

                    (address royaltyFeeRecipient,
                    uint256 royaltyFeeAmount) =IRoyaltyFeeManager(royaltyFeeManager).calculateRoyaltyFeeAndGetRecipient(item.tokenAddress,
                        item.tokenId, item.price);

                    //这里为了方便操作 改变了opensea的收手续费的方式
                    //由买家给齐10元 卖家收钱后出中介费变成 买家给9元 买家再出1元中介费
                    //但是金额逻辑不变 仍然是 买家只出卖家的标价 卖家出中介费和版税
                    //0x545d6230190Fd9Ef2F67086b5cB9ef43161860ba usdk
                    //item.to 买家  ——> royaltyFeeRecipient 版税收取地址  版税金额
                    ERC20(currency).
                        transferFrom( item.to, royaltyFeeRecipient, royaltyFeeAmount);

                    ERC20(currency).
                        transferFrom( item.to, item.from, (item.price - royaltyFeeAmount));

                    // Transfer the token.
                    IERC721(item.tokenAddress).transferFrom(
                        item.from,
                        item.to,
                        item.tokenId
                    );

                    cancelledOrFinalized[leaf] = true;
                }
            }
        }

        return true;
    }



    function stringToBytes32(string memory source)
    internal
    returns (bytes32 result)
    {
        assembly {
            result := mload(add(source, 32))
        }
    }

    event ResultHash(bytes32 leaf, string abcStr);

    function verify(
        bytes32 leaf,
        bytes32 root,
        bytes32[] memory proof
    ) public pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(
                    abi.encode(computedHash, proofElement)
                );
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(
                    abi.encode(proofElement, computedHash)
                );
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == root;
    }




    /// @dev Ensure that a given tokenId is contained within a supplied merkle root using a supplied proof.
    /// @param leaf The tokenId.
    /// @param root A merkle root derived from each valid tokenId.
    /// @param proof A proof that the supplied tokenId is contained within the associated merkle root.
    function _verifyProof(
        uint256 leaf,
        bytes32 root,
        bytes32[] memory proof
    ) private pure {
        bytes32 computedHash = bytes32(leaf);

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }

        if (computedHash != root) {
            revert();
        }
    }

    /// @dev Efficiently hash two bytes32 elements using memory scratch space.
    /// @param a The first element included in the hash.
    /// @param b The second element included in the hash.
    /// @return value The resultant hash of the two bytes32 elements.
    function _efficientHash(bytes32 a, bytes32 b)
    private
    pure
    returns (bytes32 value)
    {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}