// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <=0.8.0;

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

pragma solidity >=0.6.0 <=0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <=0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;


import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/introspection/IERC165.sol";
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
     * - If `to` refers to a smart contract, it must implement {IIERC721eceiver-onIERC721eceived}, which is called upon a safe transfer.
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
     * - If `to` refers to a smart contract, it must implement {IIERC721eceiver-onIERC721eceived}, which is called upon a safe transfer.
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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
// 
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
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

interface Iluckblocks {
    
    function getLatestPrice() external view returns (uint);    
    function amountOfRegisters() external view returns(uint);
    function currentJackpotInWei() external view returns(uint256);
    function autoSpinTimestamp() external view returns(uint256);
    function getJackpotWinnerByLotteryId(uint256 _requestCounter) external view returns (address);
    function ourLastWinner() external view returns(address);
    function ourLastJackpotWinner() external view returns(address);
    function lastJackpotTimestamp() external view returns(uint256);

}

// Staking Smart contract that receives the luckblockNodes NFTs and works with the lotteries for automation and rewards
contract luckBlocksNodesCFG is Ownable,ReentrancyGuard {
  using SafeMath for uint256;

  IERC721 lbNodesNFTs;

  Iluckblocks public luckblocksB;
  Iluckblocks public luckblocksK;
  Iluckblocks public luckblocksE;
  Iluckblocks public luckblocksM;

  address internal luckblocksBAddr;
  address internal luckblocksKAddr;
  address internal luckblocksEAddr;
  address internal luckblocksMAddr;

    // define NFT struct
    struct Node {
      address owner;
      uint256 totalProfit;
    }

   uint[] public activenodes;

   uint[] public waitingnodes;
    
   // tokenId to Node Info
   mapping(uint256 => Node) public nodes;

  // Mapping of active node staker address
  mapping(address => bool) public activeAddress;

  // Events list
  event NftStaked(uint256 indexed tokenId, address indexed owner);
  event NftUnstaked(uint256 indexed tokenId, address indexed owner);
  event NftRewarded(uint256 indexed tokenId, uint256 amount, address indexed owner);

  // initialize contract while deployment
    constructor (address _lbnodes){
      
      lbNodesNFTs = IERC721(_lbnodes);

    }

    function setLuckblocksAddrs(address lbb, address lbk, address lbe , address lbm) public onlyOwner{
     luckblocksB = Iluckblocks(lbb);
     luckblocksBAddr = lbb;
     luckblocksK = Iluckblocks(lbk);
     luckblocksKAddr = lbk;
     luckblocksE = Iluckblocks(lbe);
     luckblocksEAddr = lbe;
     luckblocksM = Iluckblocks(lbm);
     luckblocksMAddr = lbm;
    }

    // Move the last element to the deleted spot.
    // Remove the last element.
    function clearActiveElement(uint index) internal {
        activenodes[index] = activenodes[activenodes.length-1];
        activenodes.pop();
    }

    function clearWaitingElement(uint index) internal {
        waitingnodes[index] = waitingnodes[waitingnodes.length-1];
        waitingnodes.pop();
    }
      
    function stake(uint256 tokenId) public virtual nonReentrant {
        
        require(lbNodesNFTs.ownerOf(tokenId) == msg.sender, "caller is not owner nor approved");

        //Stake token to participate in the node automation rewards
        // Transfer the token from the wallet to the Smart contract
        lbNodesNFTs.transferFrom(msg.sender,address(this),tokenId);

        // Create node Token configuration
        Node memory node = Node(msg.sender, 0);

        nodes[tokenId] = node;        
        
        activeAddress[msg.sender] = false;

        emit NftStaked(tokenId, msg.sender);

    }

    function unstake(uint256 tokenId) public virtual nonReentrant {
              
        // Wallet must own the token they are trying to withdraw
        require(nodes[tokenId].owner == msg.sender, "You don't own this token!");

        // Find the index of this token id in the nodes array
        uint256 index = 0;
        uint[] memory _activenodes = activenodes;
        uint[] memory _waitingnodes = waitingnodes;

        bool didDisabled = false;

        for (uint256 i = 0; i < _activenodes.length; i++) {
            if (
                _activenodes[i] == tokenId
            ) {
                index = i;
                clearActiveElement(index);
                // Update the mapping of the tokenId to the be address(0) to indicate that the token is no longer staked
                Node memory node = Node(address(0), 0);
                nodes[tokenId] = node;
                didDisabled = true;
            }
        }
        
        if(didDisabled == false){
          for (uint256 i = 0; i < _waitingnodes.length; i++) {
              if (
                  _waitingnodes[i] == tokenId
              ) {
                  index = i;
                  clearWaitingElement(index);
                  // Update the mapping of the tokenId to the be address(0) to indicate that the token is no longer staked
                  Node memory node = Node(address(0), 0);
                  nodes[tokenId] = node;
              }
          }
        }
        // Transfer the token back to the withdrawer
        lbNodesNFTs.transferFrom(address(this), msg.sender, tokenId);

        activeAddress[msg.sender] = false;

        emit NftUnstaked(tokenId, msg.sender);

    }

   function getUserActivation(address _caller) external view returns (bool) {
       return activeAddress[_caller];
   }

   function activateNodes(address caller, uint256[] calldata _nodes , uint lottery) external {

        if(lottery == 1){
          require(block.timestamp > luckblocksB.autoSpinTimestamp() + 300,"autoSpin parameters not met");
        } else if(lottery == 2) {
          require(block.timestamp > luckblocksK.autoSpinTimestamp() + 600,"autoSpin parameters not met");
        } else if(lottery == 3) {
          require(block.timestamp > luckblocksE.autoSpinTimestamp() + 900,"autoSpin parameters not met");
        } else if(lottery == 4) {
          require(block.timestamp > luckblocksM.autoSpinTimestamp() + 1800,"autoSpin parameters not met");
        }

        uint[] memory _activenodes = activenodes;
        uint[] memory _waitingnodes = waitingnodes;

        for (uint i = 0; i < _nodes.length; i++) {
          
            if (caller == nodes[_nodes[i]].owner) {
                // Find the index of this token id in the nodes array to reset user list in case already active with others nodes
              uint256 index = 0;
              for (uint t = 0; t < _activenodes.length; t++) {
                  if (
                      _activenodes[t] == _nodes[i]
                  ) {
                      index = t;
                      clearActiveElement(index);
                  }
              }
              
              for (uint y = 0; y < _waitingnodes.length; y++) {
                  if (
                      _waitingnodes[y] == _nodes[i]
                  ) {
                      index = y;
                      clearWaitingElement(index);
                  }
              }

                // Add the token to the waitingQueue Array
                waitingnodes.push(_nodes[i]);
            }
        }
        //activate adress state
        activeAddress[caller] = true;
   }

  function resetQueue(uint lottery) external {

        if(lottery == 1){
          require(block.timestamp > luckblocksB.autoSpinTimestamp() + 360,"autoSpin parameters not met");
        } else if(lottery == 2) {
          require(block.timestamp > luckblocksK.autoSpinTimestamp() + 660,"autoSpin parameters not met");
        } else if(lottery == 3) {
          require(block.timestamp > luckblocksE.autoSpinTimestamp() + 960,"autoSpin parameters not met");
        } else if(lottery == 4) {
          require(block.timestamp > luckblocksM.autoSpinTimestamp() + 1860,"autoSpin parameters not met");
        }

   //send the waiting nodes to the active nodes array and delist the active stucked nodes
        uint[] memory _activenodes = activenodes;
        uint[] memory _waitingnodes = waitingnodes;

        for(uint a = 0; a < _activenodes.length; a++){
          
          uint256 node = _activenodes[a];

          address ownerOfNode = nodes[node].owner;

          //activate adress state
          activeAddress[ownerOfNode] = false;

          clearActiveElement(a);

        }

        for(uint i = 0; i < _waitingnodes.length; i++){
          
          uint256 nodeId = _waitingnodes[i];

          clearWaitingElement(i);

          activenodes.push(nodeId);

        }
  }

   function updateNodeInfoB(address caller, uint256 reward) external returns(bool success) {

        require(block.timestamp > luckblocksB.autoSpinTimestamp() + 300,"autoSpin parameters not met");

        // pseudo random as the random result is not crucial for anything
        uint256 randomNum = uint256(
            keccak256(
                abi.encode(
                    caller,
                    tx.gasprice,
                    block.number,
                    block.timestamp,
                    block.difficulty,
                    blockhash(block.number - 1),
                    address(this),
                    _msgSender()
                )
            )
        );

     //change from active to the waiting queue
     if(activenodes.length > 0){

        uint256 randomIndex = randomNum % activenodes.length;

        // get choosen node infos
        uint256 choosenNode = activenodes[randomIndex];
        
        address ownerOfNode = nodes[choosenNode].owner;

        require(ownerOfNode == caller , "the caller setup is not the owner of the token");

        nodes[choosenNode].totalProfit += reward;        

        clearActiveElement(randomIndex);

        waitingnodes.push(choosenNode);

        emit NftRewarded(choosenNode, reward, ownerOfNode);

        return true;


     } else if(waitingnodes.length > 0) {
      //send the waiting nodes to the active nodes array

        uint256 randomIndex = randomNum % waitingnodes.length;

        // get choosen node infos
        uint256 choosenNode = waitingnodes[randomIndex];
        
        address ownerOfNode = nodes[choosenNode].owner;

        require(ownerOfNode == caller , "the caller setup is not the owner of the token");
        
        nodes[choosenNode].totalProfit += reward;

        uint[] memory _waitingnodes = waitingnodes;

        for(uint i = 0; i < _waitingnodes.length; i++){
          
          uint256 nodeId = _waitingnodes[i];

          clearWaitingElement(i);

          activenodes.push(nodeId);

        }
       
       emit NftRewarded(choosenNode, reward, ownerOfNode);

       return true;

     } else {

       return false;

     }
      
   }

     function updateNodeInfoK(address caller, uint256 reward) external returns(bool success) {

        require(block.timestamp > luckblocksK.autoSpinTimestamp() + 600,"autoSpin parameters not met");

        // pseudo random as the random result is not crucial for anything
        uint256 randomNum = uint256(
            keccak256(
                abi.encode(
                    caller,
                    tx.gasprice,
                    block.number,
                    block.timestamp,
                    block.difficulty,
                    blockhash(block.number - 1),
                    address(this),
                    _msgSender()
                )
            )
        );

     //change from active to the waiting queue
     if(activenodes.length > 0){

        uint256 randomIndex = randomNum % activenodes.length;

        // get choosen node infos
        uint256 choosenNode = activenodes[randomIndex];
        
        address ownerOfNode = nodes[choosenNode].owner;

        require(ownerOfNode == caller , "the caller setup is not the owner of the token");
        
        nodes[choosenNode].totalProfit += reward;

        clearActiveElement(randomIndex);

        waitingnodes.push(choosenNode);

        emit NftRewarded(choosenNode, reward, ownerOfNode);

        return true;

     } else if(waitingnodes.length > 0) {
      //send the waiting nodes to the active nodes array

        uint256 randomIndex = randomNum % waitingnodes.length;

        // get choosen node infos
        uint256 choosenNode = waitingnodes[randomIndex];
        
        address ownerOfNode = nodes[choosenNode].owner;

        require(ownerOfNode == caller , "the caller setup is not the owner of the token");
        
        nodes[choosenNode].totalProfit += reward;

        uint[] memory _waitingnodes = waitingnodes;

        for(uint i = 0; i < _waitingnodes.length; i++){
          
          uint256 nodeId = _waitingnodes[i];

          clearWaitingElement(i);

          activenodes.push(nodeId);

        }

       emit NftRewarded(choosenNode, reward, ownerOfNode);

       return true;

     } else {

       return false;

     }
   }

      function updateNodeInfoE(address caller, uint256 reward) external returns(bool success) {

        require(block.timestamp > luckblocksE.autoSpinTimestamp() + 900,"autoSpin parameters not met");

        // pseudo random as the random result is not crucial for anything
        uint256 randomNum = uint256(
            keccak256(
                abi.encode(
                    caller,
                    tx.gasprice,
                    block.number,
                    block.timestamp,
                    block.difficulty,
                    blockhash(block.number - 1),
                    address(this),
                    _msgSender()
                )
            )
        );

     //change from active to the waiting queue
     if(activenodes.length > 0){

        uint256 randomIndex = randomNum % activenodes.length;

        // get choosen node infos
        uint256 choosenNode = activenodes[randomIndex];
        
        address ownerOfNode = nodes[choosenNode].owner;

        require(ownerOfNode == caller , "the caller setup is not the owner of the token");
        
        nodes[choosenNode].totalProfit += reward;

        clearActiveElement(randomIndex);

        waitingnodes.push(choosenNode);

        emit NftRewarded(choosenNode, reward, ownerOfNode);

        return true;

     } else if(waitingnodes.length > 0) {
      //send the waiting nodes to the active nodes array

        uint256 randomIndex = randomNum % waitingnodes.length;

        // get choosen node infos
        uint256 choosenNode = waitingnodes[randomIndex];
        
        address ownerOfNode = nodes[choosenNode].owner;

        require(ownerOfNode == caller , "the caller setup is not the owner of the token");
        
        nodes[choosenNode].totalProfit += reward;

        uint[] memory _waitingnodes = waitingnodes;

        for(uint i = 0; i < _waitingnodes.length; i++){
          
          uint256 nodeId = _waitingnodes[i];

          clearWaitingElement(i);

          activenodes.push(nodeId);

        }
       
       emit NftRewarded(choosenNode, reward, ownerOfNode);

       return true;

     } else {

       return false;

     }
   }

      function updateNodeInfoM(address caller, uint256 reward) external returns(bool success) {

        require(block.timestamp > luckblocksM.autoSpinTimestamp() + 1800,"autoSpin parameters not met");

        // pseudo random as the random result is not crucial for anything
        uint256 randomNum = uint256(
            keccak256(
                abi.encode(
                    caller,
                    tx.gasprice,
                    block.number,
                    block.timestamp,
                    block.difficulty,
                    blockhash(block.number - 1),
                    address(this),
                    _msgSender()
                )
            )
        );

     //change from active to the waiting queue
     if(activenodes.length > 0){

        uint256 randomIndex = randomNum % activenodes.length;

        // get choosen node infos
        uint256 choosenNode = activenodes[randomIndex];
        
        address ownerOfNode = nodes[choosenNode].owner;

        require(ownerOfNode == caller , "the caller setup is not the owner of the token");
        
        nodes[choosenNode].totalProfit += reward;

        clearActiveElement(randomIndex);

        waitingnodes.push(choosenNode);
        
        emit NftRewarded(choosenNode, reward, ownerOfNode);

        return true;

     } else if(waitingnodes.length > 0) {
      //send the waiting nodes to the active nodes array

        uint256 randomIndex = randomNum % waitingnodes.length;

        // get choosen node infos
        uint256 choosenNode = waitingnodes[randomIndex];
        
        address ownerOfNode = nodes[choosenNode].owner;

        require(ownerOfNode == caller , "the caller setup is not the owner of the token");
        
        nodes[choosenNode].totalProfit += reward;

        uint[] memory _waitingnodes = waitingnodes;

        for(uint i = 0; i < _waitingnodes.length; i++){
          
          uint256 nodeId = _waitingnodes[i];

          clearWaitingElement(i);

          activenodes.push(nodeId);

        }
        
       emit NftRewarded(choosenNode, reward, ownerOfNode);

       return true;

     } else {

       return false;

     }
   }

}