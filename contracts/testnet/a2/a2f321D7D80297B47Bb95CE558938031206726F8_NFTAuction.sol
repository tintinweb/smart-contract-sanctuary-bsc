pragma solidity ^0.8.0;
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { ProofsVerifier } from "./ProofsVerifier.sol";

contract NFTAuction is ProofsVerifier{

    bytes32 public root;
    uint256 public start;
    uint256 constant PERIOD_LENGTH = 7*24*3600;
    uint256 constant BID_TIMEOUT = 3600;
    IERC20 public paymentToken;
    uint256 public currentRound;
    uint256 public startPrice;
    uint256 public nextStartPrice;
    using MerkleProof for bytes32[];

    mapping(bytes32=>address) public tokenOwner;
    mapping(bytes32=>uint256) public highestPrice;
    mapping(bytes32=>uint256) public lastBidTime;

    constructor(bytes32 _root, address _payment ){
        root = _root;
        paymentToken = IERC20(_payment);
        startPrice = 10**18;
        nextStartPrice = 10**18;
        currentRound =1;
        start = block.timestamp;
        emit NewRound(currentRound);
    }

    function burnTokens() public onlyOwner {
        paymentToken.transfer(address(1), paymentToken.balanceOf(address(this)));
    }

    function changeRound() internal {
        currentRound = currentRound+1;
        startPrice = nextStartPrice;
        emit NewRound(currentRound);
    }

    function expectedRound() public view returns(uint256){
        return 1+(block.timestamp - start)/PERIOD_LENGTH;
    }

    function setNextPrice(uint256 price) onlyOwner public{
        nextStartPrice = price;
    }

    function getHash(int x, int y, uint256 round) public pure returns(bytes32){
        return keccak256(abi.encodePacked(x, y, round));
    }

    function getPlotRound(int x, int y) public view returns(uint256){
        return highestPrice[getHash(x, y, 0)];
    } 

    function timeSinceLastBid(int x, int y) public view returns(uint256){
        uint256 plotRound = getPlotRound(x, y);
        if(plotRound == 0){
            return 0;
        }
        bytes32 plotSlotHash = getHash(x, y, plotRound);
        if(lastBidTime[plotSlotHash] == 0){
            return 0;
        }
        return block.timestamp - lastBidTime[plotSlotHash];
    }

    function startAuction(int x, int y, bytes32[] calldata proof) public {
        while(expectedRound()>currentRound){
            changeRound();
        }
        uint256 plotRound = getPlotRound(x, y);
        //require(verify(root, proof, getHash(x, y, currentRound)), "invalid-proof");
        require(plotRound == 0,"already-sold");
        paymentToken.transferFrom(msg.sender, address(this), startPrice);
        highestPrice[getHash(x, y, 0)] = currentRound;
        tokenOwner[getHash(x, y, currentRound)] = msg.sender;
        lastBidTime[getHash(x, y, currentRound)] = block.timestamp;
        highestPrice[getHash(x, y, currentRound)] = startPrice;
        emit NewBid(x, y, msg.sender, startPrice);
        emit StartAuction(x, y,currentRound, msg.sender, startPrice);
    }

    function bidPlot(int x, int y, uint256 amount) public{
        while(expectedRound()>currentRound){
            changeRound();
        }
        uint256 plotRound = getPlotRound(x, y);
        bytes32 plotSlotHash = getHash(x, y, plotRound);
        require(plotRound > 0, "not-started");
        require(plotRound == currentRound, "finished");
        require(highestPrice[plotSlotHash] * 11/10 <= amount, "bid-at-least-10-percent");
        require(timeSinceLastBid(x, y) < BID_TIMEOUT, "bid-too-late");
        paymentToken.transferFrom(msg.sender, address(this), amount);
        paymentToken.transfer(
            tokenOwner[plotSlotHash], 
            highestPrice[plotSlotHash]);
        lastBidTime[plotSlotHash] = block.timestamp;
        tokenOwner[plotSlotHash] = msg.sender;
        highestPrice[plotSlotHash] = amount;
        emit NewBid(x, y, msg.sender, amount);
    }

    function tradeStatus(int x, int y) public view returns(bool started, bool finished){
        uint256 round = getPlotRound(x, y);
        started = (round != 0);
        finished = (round != currentRound);
        return (started, finished);
    }

    function getPlotPrice(int x, int y) public view returns(uint256){
        uint256 round = getPlotRound(x, y);
        if(round==0){
            return 0;
        }
        return highestPrice[getHash(x,y,round)];
    }

    function getPlotOwner(int x, int y) public view returns(address){
        uint256 round = getPlotRound(x, y);
        if(round==0){
            return address(0);
        }
        return tokenOwner[getHash(x,y,round)];
    }

    function timeLeft(int x, int y) public view returns(int256){
        uint256 round = getPlotRound(x, y);
        if(round != currentRound){
            return 0;
        }
        return int256(BID_TIMEOUT) - (int256(block.timestamp) - int256(lastBidTime[getHash(x, y, round)]));
    }

    function getPlotDetails(int x, int y) public view  returns(uint256 price, address owner, bool isFinal){
        uint256 round = highestPrice[getHash(x, y, 0)];
        return (highestPrice[getHash(x,y,round)], tokenOwner[getHash(x,y,round)], timeLeft(x, y)<=0);
    }

    event NewRound(uint256 indexed round);
    event StartAuction(int indexed x, int indexed y,uint256 indexed round, address firstOwner, uint256 amount);
    event NewBid(int indexed x, int indexed y, address owner, uint256 amount);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}

pragma solidity ^0.8.0;
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

interface Mintable {
    function mint(address to, uint256 tokenId) external;
}

contract ProofsVerifier is Ownable{

    using MerkleProof for bytes32[];
    
    function getNode(uint256 nft_id, address owner) public pure returns(bytes32) {
        return keccak256(abi.encode(nft_id,owner));
    }

    function verify(bytes32 root, bytes32[] calldata proof, bytes32 leaf) public pure returns(bool){
        return proof.verify(root, leaf);
    }

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