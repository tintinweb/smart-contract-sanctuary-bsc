/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// SPDX-License-Identifier: MIT
/**
 * @title Mainstreet Distributor
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

contract MainstreetDistributor is Ownable, ReentrancyGuard {

    address public MAINSTREET;
    address public MINTER;
    address public STAKER;

    uint public TOTAL_MAINST_DISTRIBUTED;

    uint public CYCLE_COUNT; 

    struct DistributionCycle {
        uint amountReceived; 
        uint lastTokenId; 
        uint distributionAmount;
        uint timeStamp; 
    }

    // mapping to keep track of each cycle, latest ID is the CYCLE_COUNT
    mapping (uint => DistributionCycle) public distributionCycles;

    // mapping from token id to last claimed at timestamp
    mapping (uint => uint) public lastClaimedTimestamp;

    // mapping from token id to last cycle claimed
    mapping (uint => uint) public lastClaimed;

    constructor(
        address minter,
        address mainst,
        address staker
    ) {
        MINTER = minter;
        MAINSTREET = mainst;
        STAKER = staker;
    }

    function setMinterAddress(address minter) public onlyOwner {
        MINTER = minter;
    }

    function setStakerAddress(address staker) public onlyOwner {
        STAKER = staker;
    }

    function createDistributionCycle(uint amount) external {
        require(msg.sender == STAKER || msg.sender == owner());
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
        uint index = lastClaimed[tokenId];
        uint amount = 0;
        if (index == CYCLE_COUNT) {
            // it means user has already claimed till this cycle, so, returning zero to avoid exception
            return amount;
        }
        for (index; index <= CYCLE_COUNT; index++) {
            // Handling starting edge case because there is no cycle at 0
            if (index > 0) {
                amount += distributionCycles[index].distributionAmount;
            }
        }
        return amount;
    }

    function claim(uint tokenId) public {
        require(msg.sender == IMinter(MINTER).ownerOf(tokenId), "MAINSTREET: not your token");
        require(tokenId > 0 && tokenId <= IMinter(MINTER).TOKEN_ID(), "MAINSTREET: invalid token id");
        require(tokenId <= distributionCycles[CYCLE_COUNT].lastTokenId, "MAINSTREET: not eligible for claim yet");
        uint amount = calculateEarnings(tokenId);
        require(amount > 0, "MAINSTREET: already claimed");
        lastClaimed[tokenId] = CYCLE_COUNT;
        sendMainst(IMinter(MINTER).ownerOf(tokenId), amount);
    }

    function claimAll() public {
        require(IMinter(MINTER).balanceOf(msg.sender) > 0, "MAINSTREET: Not an MAINSTREET holder");
        uint balance = IMinter(MINTER).balanceOf(msg.sender);
        uint amount = 0;
        for (uint index = 0; index < balance; index++) {
            uint tokenId = IMinter(MINTER).tokenOfOwnerByIndex(msg.sender, index);
            uint earned = calculateEarnings(tokenId);
            // there is a chance that > 1 token holders might claim individual tokens first and then call this function to claim the rest
            if (earned > 0) {
                amount += earned;
                lastClaimed[tokenId] = CYCLE_COUNT;
            }
        }
        sendMainst(msg.sender, amount);
    }

    function sendMainst(address _address, uint amount) private {
        IBEP20(MAINSTREET).transfer(_address, amount);
        updateTotalMainstDistributed(amount);
    }

    function updateTotalMainstDistributed(uint amount) private {
        TOTAL_MAINST_DISTRIBUTED += amount;
    }

    // emergency withdrawal function in case of any bug
    function withdrawMainst() public onlyOwner() {
        IBEP20(MAINSTREET).transfer(msg.sender, IBEP20(MAINSTREET).balanceOf(address(this)));
    }
}