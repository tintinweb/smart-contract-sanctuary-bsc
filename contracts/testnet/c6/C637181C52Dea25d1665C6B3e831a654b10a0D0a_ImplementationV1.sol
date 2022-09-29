// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import {Implementation} from "./Implementation.sol";

contract ImplementationV1 is Implementation{
    
    /**    
     * @dev depositNFTs fractor deposit NFTs to lock these NFTs
     * ** Params **
     *  addrs collection address
     *  tokenIds tokenId
     *  tokenTypes 0: ERC721, 1: ERC1155
     *  amount NFT amount: If token type is ERC721, amount = 1
     */
    function depositNFTs(
        address [] memory ,
        uint256 [] memory ,
        uint256 [] memory ,
        uint256 [] memory ,
        bytes memory 
    ) public{
        _delegatecall(DepositHandler);
    }

    /**
     * @dev claimNFTs fractor claim back her NFTs or user who owned 100% FNFT claim her NFTs
     * ** Params **
     * collectionAddrs collection addresses
     * tokenIds tokenId
     *  nftTypes 0: ERC721, 1: ERC1155
     *  tokenAmounts NFT amount: If token type is ERC721, amount = 1
     *  claimer address of the claimer
     *  signature ClaimRequest signature
     *  internalTxId internal transaction id
     */
    function claimNFTs(
            address [] memory ,
            uint256 [] memory ,
            uint256 [] memory ,
            uint256 [] memory ,
            address ,
            bytes memory ,
            bytes memory 
    ) public{
        _delegatecall(DepositHandler);
    }

    function redeemNFT(
        uint256[] memory ,
        uint256[] memory ,
        uint256[] memory ,
        address[] memory ,
        address 
    ) public{
        _delegatecall(DepositHandler);      
    }

    /** 
     * @dev mintNFT mint NFT that represent for fractor 's asset
     * ** Params **
     * chainId chainId of the NFT
     *  collectionAddresses collection address
     *  tokenIds tokenId
     *  nftTypes 0: ERC721, 1: ERC1155
     *  tokenAmounts NFT amount: If token type is ERC721, amount = 1
     */
    function mintNFT(
        uint256 ,
        uint256[] memory ,
        uint256[] memory ,
        uint256[] memory ,
        address[] memory 

    ) public{
        _delegatecall(NFTHandler);
    }

    function mintFNFT(
        uint256[] memory ,
        uint256 ,
        bytes memory,
        string memory,
        string memory
        ) public{
            _delegatecall(NFTHandler);

    }

    /**
     * @dev getNFT user who own 100% FNFT of an IAO event can claim the NFTs
     * ** Params **
     * tokenAddr FNFT contract address
     */
    function getNFT(address) public{
        _delegatecall(NFTHandler);

    }

    /**
     * @dev createIAOEvent
     * ** Params **
     * @param (0) threshold, (1) startDate, (2) endDate, (3) limit
     * @param (0) tokenAddr token used to buy FNFT, if tokenAddr = address(0) => native token (1) FNFT address
     * @param (0) fractorId, (1) iaoId
     */
    function createIAOEvent(
        uint256 [] memory,
        address[] memory,
        bytes[] memory
    ) public{
        _delegatecall(IAOHandler);
    }


    /**
     * @dev buyFNFT user buy FNFT, in vault period, user can claim their FNFT after the event end
     * ** Params **
     * @param (0) tokenAmount, (1) fund
     * @param (0) buyer
     * BuyRequest signature
     * internal transaction id
     */
    function buyFNFT(
        uint256[] memory, 
        address[] memory,
        bytes memory,
        bytes memory,
        bytes memory
    ) public payable{
        _delegatecall(IAOHandler);

    }


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import {Upgradeable} from "../common/Upgradeable.sol";

contract Implementation is Upgradeable{

    /**
     * @dev setToken721Address
     * ** Params **
     * @param _addr address
     */
    function setToken721Address(address _addr) public onlyOwner {
        require(_addr != address(0), "Controller: The address can not be address 0");
        require(_addr != token721Address, "Controller: The address can not be the old address");
        token721Address = _addr;
    }

    /**
     * @dev setToken721Address
     * ** Params **
     * @param _addr address
     */
    function setSignatureUtils(address _addr) public onlyOwner {
        require(_addr != address(0), "Controller: The address can not be address 0");
        require(_addr != signatureUtils, "Controller: The address can not be the old address");
        signatureUtils = _addr;
    }

    /**
     * @dev setToken721Address
     * ** Params **
     * @param _addr address
     */
    function setIAOHandler(address _addr) public onlyOwner {
        require(_addr != address(0), "Controller: The address can not be address 0");
        require(_addr != IAOHandler, "Controller: The address can not be the old address");
        IAOHandler = _addr;
    }

    /**
     * @dev setToken721Address
     * ** Params **
     * @param _addr address
     */
    function setNFTHandler(address _addr) public onlyOwner {
        require(_addr != address(0), "Controller: The address can not be address 0");
        require(_addr != NFTHandler, "Controller: The address can not be the old address");
        NFTHandler = _addr;
    }


    /**
     * @dev setToken721Address
     * ** Params **
     * @param _addr address
     */
    function setDepositHandler(address _addr) public onlyOwner {
        require(_addr != address(0), "Controller: The address can not be address 0");
        require(_addr != DepositHandler, "Controller: The address can not be the old address");
        DepositHandler = _addr;
    }
        
    /**
     * @dev setSigner
     * ** Params **
     * @param addr address
     */
    function setSigner(address addr) public onlyOwner {
        require(addr != address(0), "Controller: The address can not be address 0");
        require(addr != signer, "Controller: The address can not be the old address");
        signer = addr;
        emit SetSignerEvent(addr);
    }

    /**
     * @dev setAdmin
     * ** Params **
     * @param addr address
     * @param adminRole role
     * @param setBy set by 
     */
    function setAdmin(address addr, uint256 adminRole, string memory setBy) public onlySuperAdmins {
        require(addr != address(0), "Controller: The address can not be address 0");
        require(!blackList[addr], "Controller: The address was blocked");
        require(adminRole >0, "Controller: Invalid role");
        require(adminRole !=1 || msg.sender == owner(), "Controller: Only Owner can set SuperAdmin");
        role[addr] = adminRole; 
        emit SetAdminEvent(addr, adminRole, setBy);
    }

        /**
     * @dev revokeAdmin
     * ** Params **
     * @param addr address
     * @param setBy set by 
     */
    function revokeAdmin(address addr, string memory setBy) public onlySuperAdmins{
        require(addr != address(0), "Controller: The address can not be address 0");
        require(role[addr] > 0, "Controller: The address is not admin");
        require(role[addr] != 1 || msg.sender == owner(), "Controller: Only Owner can revoke SuperAdmin");
        role[addr] = 0; 
        blackList[addr] = true;
        emit SetAdminEvent(addr, 0, setBy);
    }

    /**
     * @dev getAdminRole
     * ** Params **
     * @param addr address
     */
    function getAdminRole(address addr) public view returns(uint256) {
        if (blackList[addr]) {
            return 0;}
        else if (addr == owner()){
            return 100;
        }
        else{
            return role[addr];}
    }

    /**
     * @dev setBlacklist
     * ** Params **
     * @param addr address
     * @param value bool (true) blacklisted, (false) not blacklisted
     */
    function setBlacklist(address addr, bool value) public onlySuperAdmins{
        blackList[addr] = value;
        emit SetBlacklistEvent(addr, value);
    }

    /**
     * @dev isBlacklisted
     * ** Params **
     * @param addr address
     */
    function isBlacklisted(address addr) public view returns(bool) {
        return blackList[addr];
    }



    function getIAOEventById(bytes memory id) public view returns(
        uint256[5] memory, address[2] memory, bytes memory ){
            return (
                [iaos[id].threshold,
                iaos[id].startDate,
                iaos[id].endDate,
                iaos[id].amount,
                iaos[id].limit],
                [iaos[id].tokenAddr,
                iaos[id].fractTokenAddr],
                iaos[id].fractorId
            );
    }

        function getNFTsOfNFT(uint256 tokenId) public view returns (
        uint256[] memory, uint256[]memory,
        uint256[] memory, uint256, address[] memory) 
    {
        return (NFTs[tokenId].tokenIds,
                NFTs[tokenId].nftTypes,
                NFTs[tokenId].tokenAmounts,
                NFTs[tokenId].chainId,
                NFTs[tokenId].collectionAddresses);
    }

    function getNFTsDepositedByFractor(bytes memory fractorId) public view returns(
        uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory, address[] memory
    ){  
        uint256 leng = len[fractorId];
        uint256[] memory index = new uint256[](leng);
        uint256[] memory tokenIds= new uint256[](leng);
        uint256[] memory nftTypes= new uint256[](leng);
        uint256[] memory tokenAmounts= new uint256[](leng);
        address[] memory collectionAddrs= new address[](leng);
        for (uint256 i = 0; i < len[fractorId]; i++){
            index[i] = i;
            tokenIds[i] = fractorNFT[fractorId][i].tokenId;
            nftTypes[i] = fractorNFT[fractorId][i].nftType;
            tokenAmounts[i] = fractorNFT[fractorId][i].tokenAmount;
            collectionAddrs[i] = fractorNFT[fractorId][i].collectionAddress;
        }
        return (index, tokenIds, nftTypes, tokenAmounts, collectionAddrs);
    }

    


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Upgradeable is Ownable, ReentrancyGuard, IERC721Receiver{
    address public token721Address;    
    address signer;
    address public signatureUtils;
    address public IAOHandler;
    address public NFTHandler;
    address public DepositHandler;

    mapping(address => uint256) role; // (1) SuperAdmin (2) OperationAdmin (3) HeadOfBD (4) FractorBD (5) MasterBD
    mapping(address => bool) blackList;
    mapping(bytes => IAO) public iaos;
    mapping(bytes => bool) isClosed; //IAO Event
    mapping(uint256 => bool) nftIsInEvent;

    mapping(bytes =>mapping(address => uint256)) fundDeposited;
    mapping(bytes =>mapping(address => uint256)) fnftFromFund;
    mapping(bytes => uint256) totalFundOfEvent;
    mapping(bytes => uint256) totalFNFTFromFundOfEvent;


    mapping(bytes => uint256) public len;
    mapping(bytes => mapping(uint256 => DepositedNFT)) public fractorNFT;
    mapping(uint256 => NFT) NFTs;

    mapping(address => bool) public isDeactivated;
    
    
        struct IAO {
        uint256 threshold; 
        uint256 startDate;
        uint256 endDate;
        uint256 amount;
        uint256 limit;
        address tokenAddr;
        address fractTokenAddr;
        bytes fractorId;
    }

    struct DepositedNFT{
        uint256 tokenId;
        uint256 nftType;
        uint256 tokenAmount;
        address collectionAddress;
    }
    struct  NFT{
        uint256[] tokenIds;
        uint256[] nftTypes;
        uint256[] tokenAmounts;
        address[] collectionAddresses;
        uint256 chainId;
    }

    event SetAdminEvent(address addr, uint256 role, string setBy);
    event SetBlacklistEvent(address addr, bool value);
    event SetSignerEvent(address addr);
    event DepositFundEvent(address addr, uint256 id, uint256 totalTokenAmount, bytes internalTxId);
    event DepositNFTEvent(address sender, address nftAddr, uint256 tokenId, uint256 tokenType, uint256 tokenAmount, bytes fractorId, uint256 index);
    event ClaimNFTsEvent(uint256 [] tokenIds, uint256[] nftTypes, uint256 [] tokenAmounts, address [] collectionAddrs, address claimer, bytes internalTxId);
    event WithdrawNFNTEvent(address sender, bytes id, uint256 amount, bytes internalTxId);
    event WithdrawFundEvent(address sender, bytes id, uint256 amount, bytes internalTxId);
    event MintNFTEvent(uint256 nftId, uint256 chainId, uint256 [] tokenIds, uint256 [] nftTypes, uint256 [] tokenAmounts);
    event MintFNFTEvent(uint256 []tokenIds, uint256 amount, address fracTokenAddr, bytes fractorId, string name, string symbol);

    event CreateIAOEventEvent(
        bytes iaoId,
        uint256 threshold,
        uint256 startDate,
        uint256 endDate,
        uint256 amount,
        uint256 limit,
        address tokenAddress,
        address fracTokenAddress,
        bytes fractorId    );

    modifier notBlacklisted(){
        require(!blackList[msg.sender],"Controller: Blocked");
        _;
    }

    modifier onlySuperAdmins(){
        require(msg.sender == owner() || role[msg.sender] == 1,
        "Controller: The caller is not owner or super admin");
        _;
    }

    
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override pure returns (bytes4){
        return IERC721Receiver.onERC721Received.selector;
    }

    // == COMMON FUNCTIONS == //
    function _delegatecall(address _impl) internal virtual {
        require(
            _impl != address(0),
            "Implementation: impl address is zero address"
        );
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(
                sub(gas(), 10000),
                _impl,
                0,
                calldatasize(),
                0,
                0
            )
            let size := returndatasize()
            returndatacopy(0, 0, size)
            switch result
            case 0 {
                revert(0, size)
            }
            default {
                return(0, size)
            }
        }
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
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