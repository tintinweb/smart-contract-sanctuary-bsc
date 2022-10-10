/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: MIT
/**
 * @title EternalCakesDistributor
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

contract EternalCakesDistributor is Ownable, ReentrancyGuard {

    address public CAKE = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    address public MINTER;
    address public BOUNTY = 0x07c569b26A820C99A136ec6f7d684db5815b7f43;
    uint public TOTAL_CAKE_DISTRIBUTED;

    uint public CYCLE_COUNT; // total cycle count, starts from one
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

    constructor() {}

    function setMinterAddress(address minter) public onlyOwner {
        MINTER = minter;
    }

    function setBountyAddress(address bounty) public onlyOwner {
        BOUNTY = bounty;
    }

    function setCycleStart() public {
        require(msg.sender == MINTER || msg.sender == owner(), "EC: not owner");
        CYCLE_STARTS_FROM = block.timestamp;
    }

    function createDistributionCycle(uint amount) external {
        require(msg.sender == BOUNTY || msg.sender == owner(), "EC: not owner or bounty");
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
        require(tokenId > 0 && tokenId <= IMinter(MINTER).TOKEN_ID(), "EC: Invalid token id");
        uint index = lastCycleClaimed[tokenId]; 
        uint cakeAmount = 0;
        if (index == CYCLE_COUNT) {
            // it means user has already claimed till this cycle, so, returning zero 
            return cakeAmount;
        }
        for (index; index <= CYCLE_COUNT; index++) {
            // Handling starting edge case because there is no cycle at 0
            if (index > 0) {
                // check if token id was minted before cycle creation
                if (tokenId <= distributionCycles[index].lastTokenId) {
                    // check if the token id hasn't claimed already for this cycle iteration
                    if (lastCycleClaimed[tokenId] < index) {
                        cakeAmount += distributionCycles[index].distributionAmount;
                    }
                }
            }
        }
        return cakeAmount;
    }

    function claim(uint tokenId) public nonReentrant {
        require(msg.sender == IMinter(MINTER).ownerOf(tokenId), "EC: not your token");
        uint cakeAmount = calculateEarnings(tokenId);
        require(cakeAmount > 0, "EC: not enough to claim");
        lastCycleClaimed[tokenId] = CYCLE_COUNT;
        sendCake(IMinter(MINTER).ownerOf(tokenId), cakeAmount);
    }

    function claimAll() public nonReentrant {
        uint ecBalance = IMinter(MINTER).balanceOf(msg.sender);
        require(ecBalance > 0, "EC: Not an EC holder");
        uint cakeAmount = 0;
        for (uint index = 0; index < ecBalance; index++) {
            uint tokenId = IMinter(MINTER).tokenOfOwnerByIndex(msg.sender, index);
            uint cakeEarned = calculateEarnings(tokenId);
            if (cakeEarned > 0) {
                cakeAmount += cakeEarned;
                lastCycleClaimed[tokenId] = CYCLE_COUNT;
            }
        }
        require(cakeAmount > 0, "EC: not enough to claim");
        sendCake(msg.sender, cakeAmount);
    }

    function sendCake(address _address, uint amount) private {
        IBEP20(CAKE).transfer(_address, amount);
        TOTAL_CAKE_DISTRIBUTED += amount;
    }

    // emergency withdrawal function in case of any bug or v2
    function withdrawTokens() public onlyOwner() {
        IBEP20(CAKE).transfer(msg.sender, IBEP20(CAKE).balanceOf(address(this)));
    }
}