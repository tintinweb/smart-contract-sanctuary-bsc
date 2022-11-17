// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./interface/INationNFT.sol";
import "./interface/INationFactory.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Fannations is ReentrancyGuard {
    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    struct Snapshot {
        uint256 latestId;
        INationNFT.COUNTRY[] countries;
        uint256 poolReward;
        uint256 participant;
    }

    mapping(uint8 => Snapshot) public snapshots;

    INationNFT public nationNFT;
    INationFactory public nationFactory;
    address public observer;

    modifier onlyObserver() {
        require(msg.sender == observer, "not observer");
        _;
    }

    modifier onlyOwner(uint256 _tokenId) {
        require(msg.sender == nationNFT.ownerOf(_tokenId), "not owner");
        _;
    }

    constructor(address _nationNFT, address _nationFactory) {
        nationNFT = INationNFT(_nationNFT);
        nationFactory = INationFactory(_nationFactory);
        observer = msg.sender;
    }

    function takeSnapshot1(INationNFT.COUNTRY[] memory _countries) external onlyObserver {
        require(snapshots[0].latestId == 0, "tampered");
        uint256 numberOfParticipant = 0;
        for (uint256 index = 0; index < _countries.length; index++) {
            numberOfParticipant += nationNFT.numberOfIssuedNFT(_countries[index]);
        }

        uint256 currentPoolReward = address(this).balance * 800 / 10000;

        snapshots[0] = Snapshot({
            latestId: nationNFT.latestTokenId(),
            countries: _countries,
            poolReward: currentPoolReward,
            participant: numberOfParticipant
        });
    }

    function takeSnapshot2(INationNFT.COUNTRY[] memory _countries) external onlyObserver {
        require(snapshots[1].latestId == 0, "tampered");
        uint256 numberOfParticipant = 0;
        for (uint256 index = 0; index < _countries.length; index++) {
            numberOfParticipant += nationNFT.numberOfIssuedNFT(_countries[index]);
        }

        uint256 currentPoolReward = address(this).balance * 2700 / 10000;

        snapshots[1] = Snapshot({
            latestId: nationNFT.latestTokenId(),
            countries: _countries,
            poolReward: currentPoolReward,
            participant: numberOfParticipant
        });
    }

    function takeSnapshot3(INationNFT.COUNTRY[] memory _winner) external onlyObserver {
        require(snapshots[2].latestId == 0, "tampered");
        uint256 numberOfParticipant = nationNFT.numberOfIssuedNFT(_winner[0]);

        uint256 currentPoolReward = address(this).balance * 5400 / 10000;

        snapshots[2] = Snapshot({
            latestId: nationNFT.latestTokenId(),
            countries: _winner,
            poolReward: currentPoolReward,
            participant: numberOfParticipant
        });
    }

    function claimRewardPool1(uint256 _tokenId) external onlyOwner(_tokenId) nonReentrant {
        require(snapshots[0].latestId != 0, "not open");
        require(_tokenId <= snapshots[0].latestId);
        INationNFT.COUNTRY nftCountry = nationNFT.nftMetadata(_tokenId).country;
        bool valid = false;
        for (uint256 index = 0; index < snapshots[0].countries.length; index++) {
            if(nftCountry == snapshots[0].countries[index]) {
                valid = true;
            }
        }
        require(valid, "not valid");
        nationFactory.burnNFT(_tokenId);
        (bool sent,) = payable(msg.sender).call{value: snapshots[0].poolReward / snapshots[0].participant}("");
        require(sent, "not enough bnb");
    }

    function claimRewardPool2(uint256 _tokenId) external onlyOwner(_tokenId) nonReentrant {
        require(snapshots[1].latestId != 0, "not open");
        require(_tokenId <= snapshots[1].latestId);
        INationNFT.COUNTRY nftCountry = nationNFT.nftMetadata(_tokenId).country;
        bool valid = false;
        for (uint256 index = 0; index < snapshots[1].countries.length; index++) {
            if(nftCountry == snapshots[1].countries[index]) {
                valid = true;
            }
        }
        require(valid, "not valid");
        nationFactory.burnNFT(_tokenId);
        (bool sent,) = payable(msg.sender).call{value: snapshots[1].poolReward / snapshots[1].participant}("");
        require(sent, "not enough bnb");
    }

    function claimRewardPool3(uint256 _tokenId) external onlyOwner(_tokenId) nonReentrant {
        require(snapshots[2].latestId != 0, "not open");
        require(_tokenId <= snapshots[2].latestId);
        INationNFT.COUNTRY nftCountry = nationNFT.nftMetadata(_tokenId).country;
        bool valid = false;
        for (uint256 index = 0; index < snapshots[2].countries.length; index++) {
            if(nftCountry == snapshots[2].countries[index]) {
                valid = true;
            }
        }
        require(valid, "not valid");
        nationFactory.burnNFT(_tokenId);
        (bool sent,) = payable(msg.sender).call{value: snapshots[2].poolReward / snapshots[2].participant}("");
        require(sent, "not enough bnb");
    }

    function referralRequest(uint256 _amount) external {
        require(msg.sender == address(nationFactory), "not factory contract");
        (bool sent,) = payable(msg.sender).call{value: _amount}("");
        require(sent, "not enough bnb");
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

interface INationNFT {
    enum RARITY {
        TIER_1,
        TIER_2,
        TIER_3,
        TIER_4,
        TIER_5,
        TIER_6,
        TIER_7,
        TIER_8
    }
    enum COUNTRY {
        ENGLAND,
        FRANCE,
        BRAZIL,
        SPAIN,
        GERMANY,
        ARGENTINA,
        BELGIUM,
        PORTUGAL,
        NETHERLANDS,
        DENMARK,
        CROATIA,
        URUGUAY,
        POLAND,
        SENEGAL,
        USA,
        SERBIA,
        SWITZERLAND,
        MEXICO,
        WALES,
        GHANA,
        ECUADOR,
        MOROCCO,
        CAMEROON,
        CANADA,
        JAPAN,
        QATAR,
        TUNISIA,
        SOUTH_KOREA,
        IR_IRAN,
        SAUDI_ARABIA,
        AUSTRALIA,
        COSTA_RICA
    }

    struct metadata {
        COUNTRY country;
        RARITY rarity;
    }
    function mintNationNFT(address _to, uint8 _country) external;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;
    function latestTokenId() external returns (uint256);
    function nftMetadata(uint256 _id) external returns (metadata memory);
    function ownerOf(uint256 _id) external returns (address);
    function fuseNFT(uint256[4] memory _id, COUNTRY _country, address _to) external;
    function numberOfIssuedNFT(COUNTRY _country) external returns (uint256);
    function burn(uint256 _id) external;
    function NATION_FACTORY() external returns (address);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

interface INationFactory {
    function burnNFT(uint256 _id) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}