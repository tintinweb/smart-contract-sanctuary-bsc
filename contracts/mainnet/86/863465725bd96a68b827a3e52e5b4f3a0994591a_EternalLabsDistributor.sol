/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

// SPDX-License-Identifier: MIT
/**
 * @title EternalLabsDistributor
 * @author : saad sarwar
 * @website : eternallabs.finance
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
}

interface IMinter {
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external returns (address);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function totalSupply() external view returns (uint256);
}

interface ISnapshot {
    function earnings(address) external view returns(uint);
}

// for eternal cakes
contract EternalLabsDistributor is Ownable, ReentrancyGuard {

    address public TOKEN = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    address public MINTER = 0xE4cE0E5b3B70B5132807CE725eC93d6eE33B5Eca;
    address public BOUNTY = 0x07c569b26A820C99A136ec6f7d684db5815b7f43;
    address public STAKER_PROXY = 0xa343F13f56A4575676451Bf434a44f28a1c5B8cC;
    
    uint public TOTAL_DISTRIBUTED;
    uint public TOTAL_RECEIVED;
    uint public TO_DISTRIBUTE;

    mapping (uint => uint) public tokenDebt;
    mapping (address => bool) public previousEarningsClaimed;
    mapping (address => uint80) public previousEarnings;

    constructor() {
        previousEarnings[0x773B573a68318Eb5506016981452b249EbCd4443] = 1341531540899915502;
        previousEarnings[0x6B1402e648F350409d7024CD0687F24909f61786] = 2442036251144091950;
        previousEarnings[0xC4238AF9A2F7563d8a9717380a8C9291Eb0328B6] = 128792833675537758;
        previousEarnings[0x91668f398100200D4E28Cb225E4c5A9a774b9f7B] = 128792833675537758;
        previousEarnings[0x7C3580Aa19B88151628f870bce6F158726bdfeAa] = 707025736197539534;
        previousEarnings[0x9FA03326cC51885539142EA568406B97a77Ce599] = 257585667351075516;
        previousEarnings[0x791D4fdb021fB213895b58ef4609630E3fF23242] = 27074443958914026;
        previousEarnings[0xacD480D63A6773CBC13355F66c794dd5238faD96] = 64396416837768879;
        previousEarnings[0x725100B54f3842779Be8C02C5925dE8b63c71419] = 227279457891721052;
        previousEarnings[0xbC6359d32889743B9838580692E554f47B777E07] = 128792833675537758;
        previousEarnings[0xaFd164d218a00C04A3d3b6b5ce2F22Db7F1d26A8] = 146522175068645517;
        previousEarnings[0xEF667C250AeB276d7Ada9941fDa4f25EA0099D4A] = 64396416837768879;
        previousEarnings[0xe059B4EAf566b68ce5966DaB7eFF60778A6e65D8] = 53603204144537922;
        previousEarnings[0x990a62424BE3F6bC5Fe0839480C38Aa36521FE63] = 57611212229679607;
        previousEarnings[0x4259F075C41f0df3842Cc6e0Efe93c720cb9bCF6] = 57611212229679607;
        previousEarnings[0xC542ba836C11735D21142f8D85da006423D939F2] = 57611212229679607;
        previousEarnings[0xa6cDA8249f60FCb8B1DDb84DBF53e8bcC91B2098] = 53603204144537922;
        previousEarnings[0x22b986B28cb317a17eD4D8E8a348365574b71F9C] = 233414102659551696;
        previousEarnings[0xD64304D96B8Af808E940a75d8e5C5dB664AE54c1] = 77804700886517232;
        previousEarnings[0x36de6d01ab563d3E0Fd7661c75dcE8202AA82649] = 33331939939651976;
        previousEarnings[0x148e36Ff47b9653De75b3D54B5796009De1879f2] = 13537221979457013;
    }

    function setTokenAddress(address token) public onlyOwner {
        TOKEN = token;
    }

    function setMinterAddress(address minter) public onlyOwner {
        MINTER = minter;
    }

    function setBountyAddress(address bounty) public onlyOwner {
        BOUNTY = bounty;
    }

    function setStakerProxy(address proxy) public onlyOwner {
        STAKER_PROXY = proxy;
    }

    function addDistributionAmount(uint amount) external {
        require(msg.sender == BOUNTY || msg.sender == owner(), "EL: not owner or bounty");
        TOTAL_RECEIVED += amount;
        TO_DISTRIBUTE += amount / IMinter(MINTER).totalSupply();
    }

    function calculateEarnings(uint tokenId) public view returns (uint) {
        require(tokenId > 0 && tokenId <= IMinter(MINTER).totalSupply(), "EL: Invalid token id");
        return TO_DISTRIBUTE - tokenDebt[tokenId];
    }

    function calculateAllEarned() public view returns (uint) {
        uint balance = IMinter(MINTER).balanceOf(msg.sender);
        uint total = 0;
        for (uint index = 0; index < balance; index++) {
            total += TO_DISTRIBUTE - tokenDebt[IMinter(MINTER).tokenOfOwnerByIndex(msg.sender, index)];
        }
        if (!previousEarningsClaimed[msg.sender]) {
            total += previousEarnings[msg.sender];
        }
        return total;
    }

    function claim(uint tokenId) public nonReentrant {
        require(msg.sender == IMinter(MINTER).ownerOf(tokenId), "EL: not your token");
        uint amount = calculateEarnings(tokenId);
        require(amount > 0, "EL: not enough to claim");
        tokenDebt[tokenId] += amount;
        sendTokens(IMinter(MINTER).ownerOf(tokenId), amount);
    }

    function claimAll() public nonReentrant {
        uint balance = IMinter(MINTER).balanceOf(msg.sender);
        require(balance > 0, "EL: Not an Eternal token holder");
        uint total = 0;
        for (uint index = 0; index < balance; index++) {
            uint tokenId = IMinter(MINTER).tokenOfOwnerByIndex(msg.sender, index);
            uint amount = TO_DISTRIBUTE - tokenDebt[tokenId];
            tokenDebt[tokenId] += amount;
            total += amount;
        }
        if (!previousEarningsClaimed[msg.sender]) {
            total += previousEarnings[msg.sender];
            previousEarningsClaimed[msg.sender] = true;
        }
        require(total > 0, "EL: not enough to claim");
        sendTokens(msg.sender, total);
    }

    function sendTokens(address _address, uint amount) internal {
        IBEP20(TOKEN).transfer(_address, amount);
        TOTAL_DISTRIBUTED += amount;
    }

    function establishTokenDebt(uint tokenId) public {
        require(msg.sender == STAKER_PROXY, "EL: not allowed");
        tokenDebt[tokenId] += TO_DISTRIBUTE;
    }

    // emergency withdrawal function in case of any bug or v2
    function withdrawTokens() public onlyOwner() {
        IBEP20(TOKEN).transfer(msg.sender, IBEP20(TOKEN).balanceOf(address(this)));
    }
}