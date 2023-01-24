/**
 *Submitted for verification at BscScan.com on 2023-01-24
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

// for eternal zombies
contract EternalLabsDistributor is Ownable, ReentrancyGuard {

    address public TOKEN = 0x50ba8BF9E34f0F83F96a340387d1d3888BA4B3b5;
    address public MINTER = 0x5a87d0173a2A22579b878A27048C8A9b09bFf496;
    address public BOUNTY = 0x07c569b26A820C99A136ec6f7d684db5815b7f43;
    address public STAKER_PROXY = 0x4acdF3495193F39915977ab6939ED5e1665A0B4E;
    
    uint public TOTAL_DISTRIBUTED;
    uint public TOTAL_RECEIVED;
    uint public TO_DISTRIBUTE;

    mapping (uint => uint) public tokenDebt;
    mapping (address => bool) public previousEarningsClaimed;
    mapping (address => uint80) public previousEarnings;

    constructor() {
        previousEarnings[0x26DC7dDECDa2Dd5b03206a9b78aa9D98Afd7877E] = 6138804741518459576454;
        previousEarnings[0xB7287cf7734D4d22C6C8e41bC24117541a1e4c1D] = 14086321883837548863332;
        previousEarnings[0x424A868821298c91313A673D7aF704B469264b9F] = 14086321883837548863332;
        previousEarnings[0x773B573a68318Eb5506016981452b249EbCd4443] = 12078119632004983105402;
        previousEarnings[0xB8C1FFF8b915232067c1e7449870e397E43B143b] = 36609535510816368404420;
        previousEarnings[0x489CAF6518c28804E31CaE58a1429341D739b73f] = 12126702728708232596779;
        previousEarnings[0x725100B54f3842779Be8C02C5925dE8b63c71419] = 15802476252867812107955;
        previousEarnings[0x6B1402e648F350409d7024CD0687F24909f61786] = 13803631796521961806935;
        previousEarnings[0x2Ac5e9bb7421496Bb55Cb215C33B705C7a4aA28c] = 12126702728708232596779;
        previousEarnings[0xC0624DC709fB60669b62eDa4432EbFA103c656A7] = 14086321883837548863332;
        previousEarnings[0x91668f398100200D4E28Cb225E4c5A9a774b9f7B] = 2455617701084823292757;
        previousEarnings[0xE83ABCAE79e65d0e57869e7C242e8FDDB6fB2dD5] = 10644589789224225832161;
        previousEarnings[0x837999898cAb31a677F46AC23aE72D1cD18DA3c4] = 10174323771889054627167;
        previousEarnings[0xA79ad820ED1fbE3fF1BbBcEB7Da8bB5E199E1Eda] = 7795079277014743826120;
        previousEarnings[0x4259F075C41f0df3842Cc6e0Efe93c720cb9bCF6] = 7321907102163273680884;
        previousEarnings[0x9FA03326cC51885539142EA568406B97a77Ce599] = 3067273688106471751538;
        previousEarnings[0x7C3580Aa19B88151628f870bce6F158726bdfeAa] = 3069402370759229788227;
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