/**
 *Submitted for verification at BscScan.com on 2022-02-24
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

contract holdexStorage {
    using SafeMath for uint256;

    event NewPool(
        uint256 indexed poolCounter,
        uint256 totalRaised,
        uint256 startDate,
        uint256 endDate,
        uint256 price,
        address ido     
    ); 
    event NewSocials(
        uint256 indexed poolCounter,
        string[5] social,
        bool isDeleted,
        string name,
        string logoHash,
        string infoHash 
    ); 

    struct socialsLinks {
        string browser;
        string telegram;
        string discord;
        string medium;
        string twitter;
        bool isDeleted;
        string name;
        string logoHash;
        string infoHash;
    }
    struct PoolReq {
        uint256 totalRaised;
        uint256 startDate;
        uint256 endDate;
        uint256 price;
        address ido;
        socialsLinks social;
    }

    struct PoolData {
        string browser;
        string telegram;
        string discord;
        string medium;
        string twitter;
        // string name;
        // uint256 totalRaised;
        // uint256 startDate;
        // uint256 endDate;
        // uint256 price;
        // address ido;
        // string logoHash;
        // string infoHash;
        // bool isDeleted;
    }

    // struct PoolData {
    //     string website;
    //     string description;
    //     string telegram;
    //     string discord;
    //     string medium;
    //     string twitter;
    //     string name;
    //     string poolingSymbol;
    //     uint256 totalRaised;
    //     bool isDeleted;

    // }

    mapping(uint256 => PoolData) public poolData; // Store pools Data
    uint256 public poolCounter; // counter for pools

    function initiatePool(PoolReq calldata pool)
        public
        returns (uint256)
    { 
        poolCounter = poolCounter.add(1); 

        poolData[poolCounter] = PoolData(
                pool.social.browser,
                pool.social.telegram,
                pool.social.discord,
                pool.social.medium,
                pool.social.twitter
                // pool.social.name,
                // pool.totalRaised,
                // pool.startDate,
                // pool.endDate,
                // pool.price,
                // pool.ido,
                // pool.social.logoHash,
                // pool.social.infoHash,
                // pool.social.isDeleted
            );
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
            pool.ido
        );  
        emit NewSocials(
            poolCounter,
            Socials,
            pool.social.isDeleted,
            pool.social.name,
            pool.social.logoHash,
            pool.social.infoHash
        ); 
            return poolCounter;      
    }

    // function getPoolStatus(uint256 poolId) public view returns (bool) {
    //     return poolData[poolId].isDeleted;
    // }
    // function setBrowser(uint256 poolId, string memory _browser) public {
    //     poolData[poolId].browser = _browser;
    // }
    // function setTelegram(uint256 poolId, string memory _telegram) public {
    //     poolData[poolId].telegram = _telegram;
    // }
    // function setDiscord(uint256 poolId, string memory _discord) public {
    //     poolData[poolId].discord = _discord;
    // }
    // function setMedium(uint256 poolId, string memory _medium) public {
    //     poolData[poolId].medium = _medium;
    // }
    // function setTwitter(uint256 poolId, string memory _twitter) public {
    //     poolData[poolId].twitter = _twitter;
    // }
    // function setName(uint256 poolId, string memory _name) public {
    //     poolData[poolId].name = _name;
    // }
    // function setTotalRaised(uint256 poolId, uint256 _totalRaised) public {
    //     poolData[poolId].totalRaised = _totalRaised;
    // }
    // function setIsDeleted(uint256 poolId, bool _isDeleted) public {
    //     poolData[poolId].isDeleted = _isDeleted;
    // }
  }