/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

// SPDX-License-Identifier: MIT
/**
 * @title EternalZombiesDistributor
 * @author : saad sarwar
 */


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;

        _status = _NOT_ENTERED;
    }
}

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface IMinter {
    function balanceOf(address owner) external returns (uint256);
    function ownerOf(uint256 tokenId) external returns (address);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function totalSupply() external returns (uint256);
    function TOKEN_ID() external returns (uint);
}

contract EternalZombiesDistributor is Ownable, ReentrancyGuard {

    address public ZMBE;
    address public MINTER;
    address public STAKER;

    uint public TOTAL_ZMBE_DISTRIBUTED;

    uint public CYCLE_COUNT; // total cycle count, starts from one

    struct DistributionCycle {
        uint amountReceived; // total zmbe received for this cycle
        uint lastTokenId; // tokens ids less than or equal to eligible to claim this cycle amount
        uint distributionAmount; // zmbe to distribute for each token
        uint timeStamp; // creation timestamp of this cycle
    }

    // mapping to keep track of each cycle, latest ID is the CYCLE_COUNT
    mapping (uint => DistributionCycle) public distributionCycles;

    // mapping from token id to last claimed at timestamp
    mapping (uint => uint) public lastClaimedTimestamp;

    // mapping from token id to last cycle claimed
    mapping (uint => uint) public lastClaimed;

    constructor(
        address minter,
        address zmbe,
        address staker
    ) {
        MINTER = minter;
        ZMBE = zmbe;
        STAKER = staker;
    }

    function setMinterAddress(address minter) public onlyOwner {
        MINTER = minter;
    }

    function setStakerAddress(address staker) public onlyOwner {
        STAKER = staker;
    }

    function createDistributionCycle(uint amount) external {
        require(msg.sender == STAKER || msg.sender == owner(), "EZ: not owner");
        CYCLE_COUNT += 1;
        uint lastTokenId = IMinter(MINTER).TOKEN_ID();
        distributionCycles[CYCLE_COUNT] = DistributionCycle(
            amount,
            lastTokenId,
            amount / lastTokenId,
            block.timestamp
        );
    }

    function calculateEarnings(uint tokenId) public view returns (uint) {
        uint index = lastClaimed[tokenId]; // 1
        uint zmbeAmount = 0;
        if (index == CYCLE_COUNT) {
            // it means user has already claimed till this cycle, so, returning zero to avoid exception
            return zmbeAmount;
        } //  1      1 < 2 (true) ; + on next iteration
        for (index; index <= CYCLE_COUNT; index++) {
            // Handling starting edge case because there is no cycle at 0
            if (index > 0) {
                // check if token id was minted before cycle creation
                if (tokenId <= distributionCycles[index].lastTokenId) {
                    // check if the token id hasn't claimed already for this cycle iteration
                    if (lastClaimed[tokenId] < index) {
                        zmbeAmount += distributionCycles[index].distributionAmount;
                    }
                }
            }
        }
        return zmbeAmount;
    }

    function claim(uint tokenId) public {
        require(msg.sender == IMinter(MINTER).ownerOf(tokenId), "EZ: not your token");
        // check if token ids doesn't exceed total supply of EZ
        require(tokenId <= IMinter(MINTER).TOKEN_ID(), "EZ: invalid token id");
        // check if token id is less than or equal to current distribution cycles last token id, if its more than that , then
        // this token id will be rewarded on next cycle because the token was minted after creation of the current distribution cycle
        require(tokenId <= distributionCycles[CYCLE_COUNT].lastTokenId, "EZ: not eligible for claim yet");
        uint zmbeAmount = calculateEarnings(tokenId);
        require(zmbeAmount > 0, "EZ: not enough to claim");
        // set last claimed cycle as current one to avoid reclaiming all tokens again
        lastClaimed[tokenId] = CYCLE_COUNT;
        sendZmbe(IMinter(MINTER).ownerOf(tokenId), zmbeAmount);
    }

    function claimAll() public {
        require(IMinter(MINTER).balanceOf(msg.sender) > 0, "EZ: Not an EZ holder");
        uint ezBalance = IMinter(MINTER).balanceOf(msg.sender);
        uint zmbeAmount = 0;
        for (uint index = 0; index < ezBalance; index++) {
            uint tokenId = IMinter(MINTER).tokenOfOwnerByIndex(msg.sender, index);
            uint zmbeEarned = calculateEarnings(tokenId);
            // there is a chance that > 1 token holders might claim individual tokens first and then call this function to claim the rest
            if (zmbeEarned > 0) {
                zmbeAmount += zmbeEarned;
                lastClaimed[tokenId] = CYCLE_COUNT;
            }
        }
        require(zmbeAmount > 0, "EZ: not enough to claim");
        sendZmbe(msg.sender, zmbeAmount);
    }

    function sendZmbe(address _address, uint amount) private {
        IBEP20(ZMBE).transfer(_address, amount);
        updateTotalZmbeDistributed(amount);
    }

    function updateTotalZmbeDistributed(uint amount) private {
        TOTAL_ZMBE_DISTRIBUTED += amount;
    }

    // emergency withdrawal function in case of any bug
    function withdrawZmbe() public onlyOwner() {
        IBEP20(ZMBE).transfer(msg.sender, IBEP20(ZMBE).balanceOf(address(this)));
    }
}