/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: MIT
/**
 * @title MainstreetDistributor
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

contract MainstreetDistributor is Ownable, ReentrancyGuard {

    address public MAINST = 0x8FC1A944c149762B6b578A06c0de2ABd6b7d2B89;
    address public MINTER = 0xa36c806c13851F8B27780753563fdDAA6566f996;
    address public BOUNTY = 0xa5832013B1A950fD5cab1B0034a57EC3cb647874;
    uint public TOTAL_MAINST_DISTRIBUTED;

    uint public CYCLE_COUNT; // total cycle count, starts from one
    uint public CYCLE_STARTS_FROM;

    struct DistributionCycle {
        uint amountReceived; // total tokens received for this cycle
        uint lastTokenId; // tokens ids less than or equal to eligible to claim this cycle amount
        uint distributionAmount; // tokens to distribute for each NFT token
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
        require(msg.sender == MINTER || msg.sender == owner(), "MAINSTREET: not owner");
        CYCLE_STARTS_FROM = block.timestamp;
    }

    function createDistributionCycle(uint amount) external {
        require(msg.sender == BOUNTY || msg.sender == owner(), "MAINSTREET: not owner or bounty");
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
        require(tokenId > 0 && tokenId <= IMinter(MINTER).TOKEN_ID(), "MAINSTREET: Invalid token id");
        uint index = lastCycleClaimed[tokenId]; 
        uint mainstAmount = 0;
        if (index == CYCLE_COUNT) {
            // it means user has already claimed till this cycle, so, returning zero 
            return mainstAmount;
        }
        for (index; index <= CYCLE_COUNT; index++) {
            // Handling starting edge case because there is no cycle at 0
            if (index > 0) {
                // check if token id was minted before cycle creation
                if (tokenId <= distributionCycles[index].lastTokenId) {
                    // check if the token id hasn't claimed already for this cycle iteration
                    if (lastCycleClaimed[tokenId] < index) {
                        mainstAmount += distributionCycles[index].distributionAmount;
                    }
                }
            }
        }
        return mainstAmount;
    }

    function claim(uint tokenId) public nonReentrant {
        require(msg.sender == IMinter(MINTER).ownerOf(tokenId), "MAINSTREET: not your token");
        uint mainstAmount = calculateEarnings(tokenId);
        require(mainstAmount > 0, "MAINSTREET: not enough to claim");
        lastCycleClaimed[tokenId] = CYCLE_COUNT;
        sendTokens(IMinter(MINTER).ownerOf(tokenId), mainstAmount);
    }

    function claimAll() public nonReentrant {
        uint mmBalance = IMinter(MINTER).balanceOf(msg.sender);
        require(mmBalance > 0, "MAINSTREET: Not a Money Monkey holder");
        uint mainstAmount = 0;
        for (uint index = 0; index < mmBalance; index++) {
            uint tokenId = IMinter(MINTER).tokenOfOwnerByIndex(msg.sender, index);
            uint mainstEarned = calculateEarnings(tokenId);
            if (mainstEarned > 0) {
                mainstAmount += mainstEarned;
                lastCycleClaimed[tokenId] = CYCLE_COUNT;
            }
        }
        require(mainstAmount > 0, "MAINSTREET: not enough to claim");
        sendTokens(msg.sender, mainstAmount);
    }

    function sendTokens(address _address, uint amount) private {
        IBEP20(MAINST).transfer(_address, amount);
        TOTAL_MAINST_DISTRIBUTED += amount;
    }

    // emergency withdrawal function in case of any bug or v2
    function withdrawTokens() public onlyOwner() {
        IBEP20(MAINST).transfer(msg.sender, IBEP20(MAINST).balanceOf(address(this)));
    }
}