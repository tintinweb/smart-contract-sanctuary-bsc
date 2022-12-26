/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/[email protected]/utils/Context.sol


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

// File: @openzeppelin/[email protected]/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;



/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;


/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// File: contracts/RewardXp.sol


pragma solidity ^0.8.4;



/**
 * 
 * Title twity.io
 ggggggggggggggg                                                            
dP""""""88"""""""                    I8                                      
Yb,_    88                           I8                                      
 `""    88                    gg  88888888                  gg               
        88                    ""     I8                     ""               
        88  gg    gg    gg    gg     I8    gg     gg        gg     ,ggggg,   
        88  I8    I8    88bg  88     I8    I8     8I        88    dP"  "Y8ggg
  gg,   88  I8    I8    8I    88    ,I8,   I8,   ,8I        88   i8'    ,8I  
   "Yb,,8P ,d8,  ,d8,  ,8I  _,88,_ ,d88b, ,d8b, ,d8I  d8b _,88,_,d8,   ,d8'  
     "Y8P' P""Y88P""Y88P"   8P""Y888P""Y88P""Y88P"888 Y8P 8P""Y8P"Y8888P"    
                                                ,d8I'                        
                                              ,dP'8I                         
                                             ,8"  8I                         
                                             I8   8I                         
                                             `8, ,8I                         
                                              `Y8P"                          
 **/




interface IERC1155{

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

}

interface IERC20 {
    function balanceOf(address _account) external view returns (uint256);
    function transferFrom( address from,address to, uint256 amount) external   returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external  returns (bool);
}
 

contract RewardXp  is ERC1155Holder,  Ownable {

    address private nftContractAddress ;
    address private erc20ContractAddress;
    address private miningContractAddress;
    mapping(address => uint) private nftStakeBlcokTimeMap;  //address => time
    mapping(address => uint) private nftStakedMap;    //address => tokenid
    uint private _time = 24*60*60;
     

    mapping(address =>uint) private rewardXpMap;
    mapping(address =>uint) private firstRewardMap; 

    event stakeEvent(address from,address to,uint tokenid);
    event withEvent(address from,address to,uint tookenid);
    event rewardXpEvent(address _address,uint _xp);
    event claimRewardEvent(address _address,uint _xp,uint _rate,uint _token);


    struct Reward{
        address _address;
        uint _xp;
    }

    /**
     * stake nft
     */
    function stake(uint256 id) public{
        uint balanceOf = IERC1155(nftContractAddress).balanceOf(msg.sender, id);
        require(balanceOf > 0,"Insufficient token balance.");
        require(nftStakedMap[msg.sender] == 0 ,"It has already been stake.");
        IERC1155(nftContractAddress).safeTransferFrom(msg.sender, address(this), id, 1, "0x");
        nftStakeBlcokTimeMap[msg.sender] = block.timestamp;
        nftStakedMap[msg.sender] = id;
        emit stakeEvent(msg.sender,address(this),id);

    }
    /**
     * with nft
     */
    function with(uint256 id) public{
        require(nftStakedMap[msg.sender] > 0,"No stake has occurred.");
        uint _stakeTime =  nftStakeBlcokTimeMap[msg.sender] ;
        require(_stakeTime > 0 ,"No stake has occurred by tokenId.");
        require((block.timestamp - _stakeTime) > _time,"stake is not more than 24 hours.");
        uint balanceOf = IERC1155(nftContractAddress).balanceOf(address(this), id);
        require(balanceOf > 0,"Insufficient token balance.");
        IERC1155(nftContractAddress).safeTransferFrom(address(this), msg.sender, id, 1, "0x");
        delete nftStakedMap[msg.sender];
        delete nftStakeBlcokTimeMap[msg.sender];
        emit stakeEvent(address(this),msg.sender,id);
    }

    /**
     * Registration incentive
     */
    function setRewardXp(Reward[] memory rewards) public onlyOwner{
        for(uint256 i =0 ;i<rewards.length ; i++){
            uint xp = rewardXpMap[rewards[i]._address];
            if(xp == 0){
                firstRewardMap[rewards[i]._address] = block.timestamp;
            }
            rewardXpMap[rewards[i]._address] = xp + rewards[i]._xp;
            emit rewardXpEvent(rewards[i]._address,  rewardXpMap[rewards[i]._address]);
        }
    }

    /**
     * claim reward xp 
     */
    function claimRewardXp() public {
        require(miningContractAddress != address(0),"The claim has not yet been opened.");
        uint rewardXp = rewardXpMap[msg.sender];
        require(rewardXp > 0 ,"No reward to claim.");
        uint rate = getRate(msg.sender);
        uint reward = rate > 0 ? rewardXp - (rewardXp * rate / 100) : rewardXp;
        require(reward > 0,"No reward to claim.");
       //换算成TTY
       uint tty = reward/10;
       uint balance = IERC20(erc20ContractAddress).balanceOf(miningContractAddress);
       require(balance > tty,"Insufficient balance.");
       IERC20(erc20ContractAddress).transferFrom(miningContractAddress,msg.sender, tty);
       delete rewardXpMap[msg.sender] ;
       delete firstRewardMap[msg.sender] ;
       emit claimRewardEvent(msg.sender,reward,rate,tty);

    }


    function getRewardXp(address _address) public view returns(uint){
        uint xp = rewardXpMap[_address];
        return xp;
    }
    //20% - 15% -10% -5% -0%
    function getRate(address _address) public view returns(uint){
        uint firstTime = firstRewardMap[msg.sender];
        if(block.timestamp - firstTime > 4*24*60*60){  
            return  0;
        } 
        if(block.timestamp - firstTime > 3*24*60*60){  
           return 5;

        } 
        if(block.timestamp - firstTime > 2*24*60*60){  
            return 10;
        } 
        if(block.timestamp - firstTime > 24*60*60){  
            return 15;
        }
        return 20;
    }

    function getStakeNft(address _address) public view returns(uint){
        return nftStakedMap[_address];
    }

    function getWithNft(address _address)public view returns(bool){
        uint _stakeTime =  nftStakeBlcokTimeMap[msg.sender] ;
        return (block.timestamp - _stakeTime) > _time;
    }


    function setNftContractAddress(address _address) public onlyOwner{
        nftContractAddress = _address;
    }

    function setErc20ContractAddress(address _address) public onlyOwner{
        erc20ContractAddress = _address;
    }
    function setMiningContractAddress(address _address) public onlyOwner{
        miningContractAddress = _address;
    }



}