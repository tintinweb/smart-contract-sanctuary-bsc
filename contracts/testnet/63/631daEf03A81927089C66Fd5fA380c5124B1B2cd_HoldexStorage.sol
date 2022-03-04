/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
   
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract HoldexStorage {
    using SafeMath for uint256;

    /**************************|
    |          Events          |
    |_________________________*/

    event NewPool(
        uint256 indexed poolCounter,
        uint256 totalRaised,
        uint256 startDate,
        uint256 endDate,
        uint256 price,
        address ido,
        string name,
        string logoHash,
        string infoHash,
        bool isDeleted     
    ); 
    event NewSocials(
        uint256 indexed poolCounter,
        string[5] social
    ); 
    event PoolStatus(
        uint256 poolId,
        bool isDeleted
    );

    /**************************|
    |          Structs         |
    |_________________________*/

    struct SocialLinks {
        string browser;
        string telegram;
        string discord;
        string medium;
        string twitter;
    }
    struct PoolReq {
        uint256 totalRaised;
        uint256 startDate;
        uint256 endDate;
        uint256 price;
        address ido;
        string name;
        string logoHash;
        string infoHash;
        bool isDeleted;
        SocialLinks social;
    }
    struct PoolData{
        string name;
        uint256 totalRaised;
        uint256 startDate;
        uint256 endDate;
        uint256 price;
        address ido;
        string logoHash;
        string infoHash;
        bool isDeleted;
    }
    struct SocialData{
        string browser;
        string telegram;
        string discord;
        string medium;
        string twitter;
    }

    mapping(uint256 => PoolData) public poolData; // Store pools Data
    mapping(uint256 => SocialData) public socialData; // store all socials Data
    uint256 public poolCounter; // counter for pools

    /**************************|
    |          Start           |
    |_________________________*/

    function initiatePool(PoolReq calldata pool)
        public
        returns (uint256)
    { 
        poolCounter = poolCounter.add(1);

        socialData[poolCounter] = SocialData(
            pool.social.browser,
            pool.social.telegram,
            pool.social.discord,
            pool.social.medium,
            pool.social.twitter 
        );
            poolData[poolCounter] = PoolData(
                pool.name,
                pool.totalRaised,
                pool.startDate,
                pool.endDate,
                pool.price,
                pool.ido,
                pool.logoHash,
                pool.infoHash,
                pool.isDeleted
            );

        /**
        * socials[0] = webiste link 
        * socials[1] = description 
        * socials[2] = telegram link 
        * socials[3] = discord link 
        * socials[4] = medium link 
        * socials[5] = twitter link 
        **/    
        string[5] memory Socials = [
            pool.social.browser,
            pool.social.telegram,
            pool.social.discord,
            pool.social.medium,
            pool.social.twitter
        ];

        emit NewPool(
            poolCounter,
            pool.totalRaised,
            pool.startDate,
            pool.endDate,
            pool.price,
            pool.ido,
            pool.name,
            pool.logoHash,
            pool.infoHash,
            pool.isDeleted
        );  
        emit NewSocials(
            poolCounter,
            Socials
        ); 
            return poolCounter;      
    }

    /**************************|
    |          Setters         |
    |_________________________*/

    function getPoolStatus(uint256 poolId) public view returns (bool) {
        return poolData[poolId].isDeleted;
    }
    function setBrowser(uint256 poolId, string memory _browser) public {
        socialData[poolId].browser = _browser;
    }
    function setTelegram(uint256 poolId, string memory _telegram) public {
        socialData[poolId].telegram = _telegram;
    }
    function setDiscord(uint256 poolId, string memory _discord) public {
        socialData[poolId].discord = _discord;
    }
    function setMedium(uint256 poolId, string memory _medium) public {
        socialData[poolId].medium = _medium;
    }
    function setTwitter(uint256 poolId, string memory _twitter) public {
        socialData[poolId].twitter = _twitter;
    }
    function setName(uint256 poolId, string memory _name) public {
        poolData[poolId].name = _name;
    }
    function setTotalRaised(uint256 poolId, uint256 _totalRaised) public {
        poolData[poolId].totalRaised = _totalRaised;
    }
    function setStartDate(uint256 poolId, uint256 _startDate) public {
        poolData[poolId].startDate = _startDate;
    }
    function setEndDate(uint256 poolId, uint256 _endDate) public {
        poolData[poolId].endDate = _endDate;
    }
    function setPrice(uint256 poolId, uint256 _price) public {
        poolData[poolId].price = _price;
    }
    function setIdo(uint256 poolId, address _ido) public {
        poolData[poolId].ido = _ido;
    }
    function setLogoHash(uint256 poolId, string memory _logoHash) public {
        poolData[poolId].logoHash = _logoHash;
    }
    function setInfoHash(uint256 poolId, string memory _infoHash) public {
        poolData[poolId].infoHash = _infoHash;
    }
    function setIsDeleted(uint256 poolId, bool _isDeleted) public {
        poolData[poolId].isDeleted = _isDeleted;
        emit PoolStatus(
            poolId,
            _isDeleted
        );
    }
  }