/**
 *Submitted for verification at BscScan.com on 2022-02-16
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

interface IBirbNft {
    function ownerOf(uint256 tokenId) external view returns (address);
    function burnFromEnchant(uint256 id) external;
}

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract BirbRarity is Auth {

	mapping (uint256 => uint8) public idToRarity;
	mapping (uint8 => uint256[]) public rarityToIds;
	address birbNft;
    address payToken;
    address tokenReceiver = 0xf3Ea7CA781ac32960E528cc288effF64C279d678;
    uint256 public commonCost;
    uint256 public uncommonCost;
    uint256 public rareCost;
    uint256 public epicCost;
    uint256 public legendaryCost;

	constructor(address nft, address payt) Auth(msg.sender) {
		owner = msg.sender;
		birbNft = nft;
		payToken = payt;
	}

	function setRarityIds(uint8 rarity, uint256[] calldata ids) external authorized {
		rarityToIds[rarity] = ids;
	}

	function setIdRarity(uint256 id, uint8 rarity) external authorized {
		_setIdRarity(id, rarity);
	}

	function _setIdRarity(uint256 id, uint8 rarity) internal {
		idToRarity[id] = rarity;
	}

	function setIdsRarities(uint256[] calldata id, uint8[] calldata rarities) external authorized {
		require(id.length == rarities.length, "array mismatch");
		for (uint256 i = 0; i < id.length; i++) {
			_setIdRarity(id[i], rarities[i]);
		}
	}

	function getIdRarity(uint256 id) public view returns (uint8) {
		return idToRarity[id];
	}

	function getIdsRarities(uint256[] calldata ids) external view returns (uint8[] memory) {
		uint8[] memory rarities = new uint8[](ids.length);
		for (uint256 i = 0; i < ids.length; i++) {
			rarities[i] = getIdRarity(ids[i]);
		}

		return rarities;
	}

	function getRarityIds(uint8 rarity) external view returns (uint256[] memory) {
		return rarityToIds[rarity];
	}

	function enchant(uint256 card, uint256 sac) external {
        IBirbNft nft = IBirbNft(birbNft);
        // 0 Common 1 Uncommon 2 Rare 3 Epic 4 Legendary
        uint8 rar = getIdRarity(card);
		require(rar < 4, "You cannot enchant a Legendary Birb.");
        require(nft.ownerOf(card) == msg.sender, "You can only enchant your own cards.");
        require(nft.ownerOf(sac) == msg.sender, "You must own the card to burn for enchant.");
        // Rarity must be equal or higher than the card being enchanted.
        require(rar <= getIdRarity(sac), "Wrong rarity in burner card.");

        // Burn the sacrifices for the rarity break.
        nft.burnFromEnchant(sac);

        // Token cost.
		if (payToken != address(0)) {
			uint256 tokenCost = getEnchantCost(rar);
			IBEP20 token = IBEP20(payToken);
			require(token.balanceOf(msg.sender) >= tokenCost, "You don't have enough tokens.");
			token.transferFrom(msg.sender, tokenReceiver, tokenCost);
		}

        // Upgrade card rarity
        _setIdRarity(card, rar + 1);
    }

    function getEnchantCost(uint8 rarity) public view returns (uint256) {
        if (rarity == 4) {
            return legendaryCost;
        }
        if (rarity == 3) {
            return epicCost;
        }
        if (rarity == 2) {
            return rareCost;
        }
        if (rarity == 1) {
            return uncommonCost;
        }

        return commonCost;
    }

    function setCosts(uint256 common, uint256 uncommon, uint256 rare, uint256 epic, uint256 legendary) external authorized {
        commonCost = common;
        uncommonCost = uncommon;
        rareCost = rare;
        epicCost = epic;
        legendaryCost = legendary;
    }

	function setNftAddress(address nft) external authorized {
		birbNft = nft;
	}

	function setPayToken(address t) external authorized {
		payToken = t;
	}
}