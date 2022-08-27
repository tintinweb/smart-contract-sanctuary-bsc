/**
 *Submitted for verification at BscScan.com on 2022-08-26
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
    function TOKEN_ID() external view returns (uint);
}

interface IStaker {     
    function compoundAndDistribute() external;
}

interface IDrFrankenstein {
    function pendingZombie(uint256 _pid, address _user) external view returns (uint256);
}

contract EternalZombiesDistributor is Ownable, ReentrancyGuard {

    address public ZMBE;
    address public MINTER;
    address public STAKER;
    address public DR_FRANKENSTEIN;

    uint public TOTAL_ZMBE_DISTRIBUTED;

    uint public POOL_ID = 11;
    uint public CYCLE_COUNT; // total cycle count, starts from one
    uint public CYCLE_DURATION = 86400 * 14; // 14 DAYS
    uint public CYCLE_STARTS_FROM;

    struct DistributionCycle {
        uint amountReceived; // total tokens received for this cycle
        uint lastTokenId; // tokens ids less than or equal to eligible to claim this cycle amount
        uint distributionAmount; // tokens to distribute for each EZ token
        uint createdAt; // creation timestamp of this cycle
    }

    // mapping to keep track of each cycle, latest ID is the CYCLE_COUNT
    mapping (uint => DistributionCycle) public distributionCycles;

    // mapping from token id to last cycle claimed
    mapping (uint => uint) public lastCycleClaimed;

    constructor(
        address minter,
        address zmbe,
        address staker,
        address drFrankenstein
    ) {
        MINTER = minter;
        ZMBE = zmbe;
        STAKER = staker;
        DR_FRANKENSTEIN = drFrankenstein;
    }

    function setMinterAddress(address minter) public onlyOwner {
        MINTER = minter;
    }

    function setStakerAddress(address staker) public onlyOwner {
        STAKER = staker;
    }

    function setDrFrankenstein(address drFrankenstein) public onlyOwner {
        DR_FRANKENSTEIN = drFrankenstein;
    }

    function setCycleDuration(uint duration) public onlyOwner {
        CYCLE_DURATION = duration;
    }

    function setCycleStart() public {
        require(msg.sender == MINTER || msg.sender == owner(), "EZ: not owner");
        CYCLE_STARTS_FROM = block.timestamp;
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
        require(tokenId > 0 && tokenId <= IMinter(MINTER).TOKEN_ID(), "EZ: Invalid token id");
        uint index = lastCycleClaimed[tokenId]; 
        uint zmbeAmount = 0;
        if (index == CYCLE_COUNT) {
            // it means user has already claimed till this cycle, so, returning zero 
            return zmbeAmount;
        }
        for (index; index <= CYCLE_COUNT; index++) {
            // Handling starting edge case because there is no cycle at 0
            if (index > 0) {
                // check if token id was minted before cycle creation
                if (tokenId <= distributionCycles[index].lastTokenId) {
                    // check if the token id hasn't claimed already for this cycle iteration
                    if (lastCycleClaimed[tokenId] < index) {
                        zmbeAmount += distributionCycles[index].distributionAmount;
                    }
                }
            }
        }
        return zmbeAmount;
    }

    // for frontend, if a cycle hasn't been created after 14 days then use this function to calculate pending earnings.
    function calculateMissingCycleEarnings() public view returns(uint amount) {
        if (block.timestamp > (CYCLE_STARTS_FROM + CYCLE_DURATION)) {
            // if the user hasn't claimed since last cycle duration and distribution cycle hasn't been created yet too
            if (block.timestamp > (distributionCycles[CYCLE_COUNT].createdAt + CYCLE_DURATION)) {
                return IDrFrankenstein(DR_FRANKENSTEIN).pendingZombie(POOL_ID, STAKER) / IMinter(MINTER).TOKEN_ID();
            }
        } 
        return 0;
    }

    // a distribution cycle can be created through the Staking contract, because the Staker knows how much its sending but the
    // distributor doesn't know how much its receiving 
    // a distribution cycle will only be created if cycle creation is due
    function triggerCycleCreation() public {
        // check if its past first cycle duration
        if (block.timestamp > (CYCLE_STARTS_FROM + CYCLE_DURATION)) {
            // check if it has been more than cycle duration since last cycle created
            if (block.timestamp > (distributionCycles[CYCLE_COUNT].createdAt + CYCLE_DURATION)) {
                IStaker(STAKER).compoundAndDistribute();
            }
        }
    }

    function claim(uint tokenId) public nonReentrant {
        require(msg.sender == IMinter(MINTER).ownerOf(tokenId), "EZ: not your token");
        // check if token ids doesn't exceed total supply of EZ
        require(tokenId <= IMinter(MINTER).TOKEN_ID(), "EZ: invalid token id");
        triggerCycleCreation();
        uint zmbeAmount = calculateEarnings(tokenId);
        // if a user has already claimed till this cycle, then zmbeAmount will be zero
        require(zmbeAmount > 0, "EZ: not enough to claim");
        // set last claimed cycle as current one to avoid reclaiming all tokens again
        lastCycleClaimed[tokenId] = CYCLE_COUNT;
        sendZmbe(IMinter(MINTER).ownerOf(tokenId), zmbeAmount);
    }

    function claimAll() public nonReentrant {
        uint ezBalance = IMinter(MINTER).balanceOf(msg.sender);
        require(ezBalance > 0, "EZ: Not an EZ holder");
        uint zmbeAmount = 0;
        for (uint index = 0; index < ezBalance; index++) {
            uint tokenId = IMinter(MINTER).tokenOfOwnerByIndex(msg.sender, index);
            triggerCycleCreation();
            uint zmbeEarned = calculateEarnings(tokenId);
            if (zmbeEarned > 0) {
                zmbeAmount += zmbeEarned;
                lastCycleClaimed[tokenId] = CYCLE_COUNT;
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