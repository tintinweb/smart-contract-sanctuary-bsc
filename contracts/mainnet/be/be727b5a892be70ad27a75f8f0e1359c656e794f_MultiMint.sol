/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IERC721Receiver {
  function onERC721Received(
    address operator,
    address from,
    uint tokenId,
    bytes calldata data
  ) external returns (bytes4);
}

interface IMysteriousCrates {
    function mintCrate(address user, uint[] memory cardIds) external;
}

interface ILandCrates {
    function mintCrateTeam(uint16 numCrates, uint8 _crateType) external;
    function getAllCratesOfUser(address user) external view returns(uint[] memory crateIds);
    function safeTransferFrom(address from, address to, uint tokenId) external;
    function balanceOf(address owner) external view returns (uint balance);
}

interface ISamuraiRising {
    function teamMintSingle(uint8 packId, address recipient) external;
}

interface ISpecialCrates {
    function mintCrate(address _user, uint _crateType) external;
}

contract MultiMint is Auth, IERC721Receiver {
    IMysteriousCrates public samuraiCrates;
    ILandCrates public landCrates;
    ISamuraiRising public samurai;
    ISpecialCrates public specialCrates;

    uint public mintLimit = 100;
    
    enum LandCrateType { Hill, Mountain, Coast }
    enum SpecialCrateType { Monk, Ninja, Archer }
    
    event SamuraiCrateMinted(address indexed user, uint crateStars, uint numCrates);
    event LandCrateMinted(address indexed user, LandCrateType crateType, uint numCrates);
    event SamuraiDirectMinted(address indexed user, uint numSamurai);
    event SpecialCrateMinted(address indexed user, SpecialCrateType crateType, uint numCrates);
    
    constructor() Auth(msg.sender) {
		samuraiCrates = IMysteriousCrates(0xbeE7a5a2FE488B38C05e1ccd4815e3447C7eB015);
		landCrates = ILandCrates(0x56Bc09B7aCBf8C1376a564f0e0AB9c77782d037d);
        samurai = ISamuraiRising(0xC3c3B849ED5164Fb626c4a4F78e0675907B2C94E);
        specialCrates = ISpecialCrates(0xCd5cFa3cA466560767213c2297Eb4617aD5f5DBd);
	}
    
    function multiMintSamuraiCrates(address user, uint crateStars, uint numCrates) external authorized {
        require(numCrates <= mintLimit, "too many at once");
        require(crateStars <= 3 && crateStars >= 0, "invalid star count");
        
        uint[] memory cardIds = new uint[](3);
        
        if (crateStars == 0) {
            cardIds[0] = 5000;
            cardIds[1] = 5000;
            cardIds[2] = 5000;
        } else if (crateStars == 1) {
            cardIds[0] = 5000;
            cardIds[1] = 5000;
            cardIds[2] = 1;
        } else if (crateStars == 2) {
            cardIds[0] = 5000;
            cardIds[1] = 1;
            cardIds[2] = 1;
        } else {
            cardIds[0] = 1;
            cardIds[1] = 1;
            cardIds[2] = 1;
        }
        
        for (uint i = 0; i < numCrates; i++) {
            samuraiCrates.mintCrate(user, cardIds);
        }
        
        emit SamuraiCrateMinted(user, crateStars, numCrates);
    }
    
    function multiMintLand(address user, LandCrateType crateType, uint16 numCrates) external authorized {
        require(numCrates <= mintLimit, "too many at once");
        require(landCrates.balanceOf(address(this)) == 0, "landcrate balance must be 0");
        
        landCrates.mintCrateTeam(numCrates, uint8(crateType));
        
        uint[] memory crateIds = landCrates.getAllCratesOfUser(address(this));
        
        for (uint i = 0; i < crateIds.length; i++) {
            landCrates.safeTransferFrom(
                address(this),
                user,
                crateIds[i]
            );
        }
        
        emit LandCrateMinted(user, crateType, numCrates);
    }

    function multiMintSamuraiDirect(address user, uint numSamurai) external authorized {
        require(numSamurai <= mintLimit, "too many at once");

        for (uint i = 0; i < numSamurai; i++) {
            samurai.teamMintSingle(0, user);
        }

        emit SamuraiDirectMinted(user, numSamurai);
    }

    function multiMintSpecialCrate(address user, SpecialCrateType crateType, uint numCrates) external authorized {
        require(numCrates <= mintLimit, "too many at once");

        for (uint i = 0; i < numCrates; i++) {
            specialCrates.mintCrate(user, uint(crateType));
        }

        emit SpecialCrateMinted(user, crateType, numCrates);
    }

    function setMintLimit(uint limit) external onlyOwner {
        mintLimit = limit;
    }
    
    function onERC721Received(address, address, uint, bytes calldata) public pure override returns (bytes4) {
        return 0x150b7a02;
    }
}