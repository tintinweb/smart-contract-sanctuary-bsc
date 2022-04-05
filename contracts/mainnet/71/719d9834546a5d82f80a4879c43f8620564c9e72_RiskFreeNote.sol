// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.5;

import './ERC721.sol';
import './Counters.sol';
import './IERC20.sol';
import './Ownable.sol';

contract RiskFreeNote is ERC721, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using Strings for uint256;
 
    struct LockInfo {
        uint256 amount;
        uint256 wRingReward;
        uint256 busdReward;
        uint256 endTime;
    }

    IERC20 public wRING;
    IERC20 public BUSD;
    bool public unlockedAll;
    uint256 public lockPeriod; // in seconds
    uint256 public busdMultiplier;
    uint256 public wRingMultiplier;
    uint256 public denominator = 10000; // 1.5 = 15000 / 10000
    uint256 public amountMin;
    uint256 public rewardBalance;

    mapping(uint256 => LockInfo) public lockInfos; // token id => lock info
    Counters.Counter private _tokenIdTracker;

    // Events
    event NftEvent(
        uint256 tokenId,
        uint256 wRingLocked,
        uint256 wRingReward,
        uint256 busdReward,
        uint256 dueDate,
        bool created
    );

    constructor(
        string memory name, 
        string memory symbol, 
        string memory baseURI, 
        address _wRING, 
        address _busd, 
        uint256 _lockPeriod, 
        uint256 _wRingMultiplier, 
        uint256 _busdMultiplier, 
        uint256 _amountMin
    ) ERC721(name, symbol) {
        unlockedAll = false;

        _setBaseURI(baseURI);

        require(_wRING != address(0));
        wRING = IERC20(_wRING);

        require(_busd != address(0));
        BUSD = IERC20(_busd);

        require(_lockPeriod > 0, 'RiskFreeNote: lockPeriod can not be 0');
        lockPeriod = _lockPeriod;

        require(_wRingMultiplier >= 1, 'RiskFreeNote: wRING multiplier must be higher or equal to 1');
        wRingMultiplier = _wRingMultiplier;

        require(_busdMultiplier >= 1, 'RiskFreeNote: BUSD multiplier must be higher or equal to 1');
        busdMultiplier = _busdMultiplier;

        require(_amountMin > 0, 'RiskFreeNote: minimum amount must be higher than 0');
        amountMin = _amountMin;
    }

    /**
        @notice filling BUSD and wRING reward balances
        @param _busdAmount uint256
        @return bool
     */
    function fillRewardBalances(uint256 _busdAmount) public onlyOwner returns (bool) {
        require(_busdAmount > 0, 'RiskFreeNote: reward amount must be higher than 0');
        uint256 _wRingAmount = _busdAmount.mul(wRingMultiplier).div(busdMultiplier);

        BUSD.transferFrom(msg.sender, address(this), _busdAmount);
        wRING.transferFrom(msg.sender, address(this), _wRingAmount);

        rewardBalance = rewardBalance.add(_busdAmount);
        return true;
    }

    /**
        @notice claim not assigned tokens
        @return bool
     */
    function claimBackDust() public onlyOwner returns (bool) {
        require(rewardBalance > 0, 'RiskFreeNote: there is nothing to claim back');

        uint256 _wRingRewardBalance = rewardBalance.mul(wRingMultiplier).div(busdMultiplier);
        wRING.transfer(msg.sender, _wRingRewardBalance);
        BUSD.transfer(msg.sender, rewardBalance);

        rewardBalance = 0;
        return true;
    }

    /**
        @notice get current baseURI filtered by tokenId
        @param tokenId uint256
        @return string
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), 'RiskFreeNote: URI query for non-existent token');
        return
            string(
                abi.encodePacked(
                    super.baseURI(),
                    toString(address(this)),
                    '/',
                    tokenId.toString()
                )
            );
    }

    /**
        @notice get wRING amount locked filtered by tokenId
        @param tokenId uint256
        @return uint256
     */
    function lockAmount(uint256 tokenId) external view returns (uint256) {
        return lockInfos[tokenId].amount;
    }

    /**
        @notice get nft unlocking timestamp filtered by tokenId
        @param tokenId uint256
        @return uint256
     */
    function endTime(uint256 tokenId) external view returns (uint256) {
        return lockInfos[tokenId].endTime;
    }

    /**
        @notice get assigned wRING reward filtered by tokenId
        @param tokenId uint256
        @return uint256
     */
    function wRingRewardAmount(uint256 tokenId) external view returns (uint256) {
        return lockInfos[tokenId].wRingReward;
    }

    /**
        @notice get assigned BUSD reward filtered by tokenId
        @param tokenId uint256
        @return uint256
     */
    function busdRewardAmount(uint256 tokenId) external view returns (uint256) {
        return lockInfos[tokenId].busdReward;
    }

    /**
        @notice get remaining wRING that may still be locked
        @return uint256
     */
    function remainingRING() public view returns (uint256) {
        return rewardBalance.mul(denominator).div(busdMultiplier);
    }

    /*
        @notice set new baseURI
        @param string uri_
     */
    function setBaseURI(string memory uri_) external onlyOwner {
        _setBaseURI(uri_);
    }

    /*
        @notice mint new nft and store nft data
        @param address _user
        @param uint256 _amount
        @return uint256
     */
    function mint(address _user, uint256 _amount) external returns (uint256) {
        require(_amount >= amountMin, "RiskFreeNote: can not mint under min amount");
        wRING.transferFrom(msg.sender, address(this), _amount);

        uint256 tokenId = _tokenIdTracker.current();
        uint256 _endTime = block.timestamp.add(lockPeriod);
        uint256 _wRingReward = _amount.mul(wRingMultiplier).div(denominator);
        uint256 _busdReward = _amount.mul(busdMultiplier).div(denominator);

        require(_busdReward <= rewardBalance, 'RiskFreeNote: Max nft minted');
        rewardBalance = rewardBalance.sub(_busdReward);

        lockInfos[tokenId] = LockInfo({amount: _amount, wRingReward: _wRingReward, busdReward: _busdReward, endTime: _endTime});

        _safeMint(_user, _tokenIdTracker.current());
        _tokenIdTracker.increment();

        emit NftEvent(tokenId, _amount, _wRingReward, _busdReward, _endTime, true);
        return tokenId;
    }

    /*
        @notice burn an existing nft and delete nft data
        @param uint256 tokenId
        @return uint256
     */
    function burn(uint256 tokenId) external returns (uint256) {
        LockInfo memory lockInfo = lockInfos[tokenId];
        if (!unlockedAll) {
            require(block.timestamp >= lockInfo.endTime, 'RiskFreeNote: the note is not available for unlocking yet');
        }
        address nftOwner = ownerOf(tokenId);
        uint256 transferAmount = lockInfo.amount.add(lockInfo.wRingReward);

        require(msg.sender == nftOwner, 'RiskFreeNote: only the nft owner can burn it');

        wRING.transfer(nftOwner, transferAmount);
        BUSD.transfer(nftOwner, lockInfo.busdReward);
        _burn(tokenId);

        emit NftEvent(tokenId, 0, 0, 0, 0, false);

        delete lockInfos[tokenId];
        return transferAmount;
    }

    /// @dev Emergency use
    function unlockAll() external onlyOwner {
        unlockedAll = true;
    }
}

function toString(address x) pure returns (string memory) {
    bytes memory s = new bytes(40);
    for (uint256 i = 0; i < 20; i++) {
        bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2**(8 * (19 - i)))));
        bytes1 hi = bytes1(uint8(b) / 16);
        bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
        s[2 * i] = char(hi);
        s[2 * i + 1] = char(lo);
    }
    return string(abi.encodePacked('0x', string(s)));
}

function char(bytes1 b) pure returns (bytes1 c) {
    if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
    else return bytes1(uint8(b) + 0x57);
}