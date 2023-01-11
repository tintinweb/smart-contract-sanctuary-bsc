// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./TheKawaiiShop.sol";

/*
                               &&&&&&&&&&&                 &&&&&&&&&&&                              
                               &&**       &&&           &&&       **&&                              
                               &&,,/**       &&       &&       ***,,&&                              
                               &&,,,,,**       &&   &&       **,.,,,&&                              
                               &&,,,,,,,**       &&&       **,,,,,,,&&                              
                                 &&,,,,,,,***       &&  ***,,,,,,,&&                                
                                   @&&,,,,,,,**       &&,,,,,,,&&%                                  
                                      &&,,,,,,,**       &&&,,&&                                     
                                        &&,,,,,,,**      &&                                       
                          &&/         &&  &&&,,,,,,,**       &&         &&&                         
                        &&,,(&&    @&&       &%,,,,,,,**       &&%    %&,,,&&                       
                        &&,,...,,       **,,,,,**%%%,,,,,,,**       ,,..,,,&&                       
                        &&,,,,,..,,   **,,,,,,,&&   &&,,,,,,,**   ,,..,,,,,&&                       
                          &&/,,,,..,,,,,,,,,,&&       &&,,,,,,,,,,..,,,,&&&                         
                            (&&,,.....,,,,&&&           &&&,,,,.....,,&&                            
                          &&(,,..,,,,,..,,&&&           &%&,,..,,,,,..,,&&&                         
                        &&,,...,,&&,,,,,..,,,&&       &&,,,..,,,,*&&,,..,,,&&                       
                      &&,,...,,&&  @&&,,,,,,,,,&&   &&,,,,,,,,,&&%  &&,,...,,&&                     
                   &&@,,..,,(&&       &&&&&&&&&       &&&&&&&&&       &&,,,..,,&&&                  
               &&&&,,,..,,&&/                                           @&&,,..,,,&&&&              
            &&&,,,,...,,&&                                                 &&,,...,,,,&&&           
            &&&,,##,,,&&                                                     &&,,,##,,&&&           
            &&&,,,,,,,&&                                                     &&,,,,,,,&&&           
               @@@@@@@                                                         @@@@@@@             
                    
*/

/* Author : pulz.eth */

library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

struct Inventory {
    Item weapon;
    uint weaponTokenID;
    Item collar;
    uint collarTokenID;
    Item armor;
    uint armorTokenID;
    Item boots;
    uint bootsTokenID;
    Item gauntlets;
    uint gauntletsTokenID;
}

struct KawaiiPet {
    uint kawaiiID;
    uint experience;
    uint currentHealth;
    uint totalHealth;
    uint strength;
    uint agility;
    uint defense;
    uint lastTimeAttack;
    uint lastTimeDefend;
}

contract TheKawaiiRing is Ownable {

    // Global Datas
    uint public hitXP = 20;
    uint public killXP = 20;
    uint public dodgeXP = 20;
    uint public hurtXP = 5;
    uint public missXP = 5;

    uint public hitCoins = 25;
    uint public killCoins = 20;
    uint public dodgeCoins = 20;
    uint public hurtCoins = 7;
    uint public missCoins = 7;

    uint public attackTime = 1;
    uint public defendTime = 1;

    // KawaiiID to its inventory
    mapping(uint => Inventory) public kawaiiInventory;

    // Shop System
    TheKawaiiShop public shop;

    SuperKawaii public collection;

    constructor(address _shopContract, address _collectionContract){
        shop = TheKawaiiShop(payable(_shopContract));
        collection = SuperKawaii(payable(_collectionContract));
    }

    modifier onlyAllowedContract() {
        require(msg.sender == address(collection) || msg.sender == owner(), "Only the allowed contract can call this function");
        _;
    }

    function setAddresses(address _collection, address newShop) public onlyOwner {
        collection = SuperKawaii(payable(_collection));
        shop = TheKawaiiShop(payable(newShop));
    }

    function setCombatTimespans(uint _newAttackTime, uint _newDefendSpan) public onlyOwner {
        attackTime = _newAttackTime;
        defendTime = _newDefendSpan;
    }

    function setCoins(uint _hit, uint _dodge, uint _downBonus, uint _gettingHit, uint _miss) public onlyOwner{
        hitCoins = _hit;
        dodgeCoins = _dodge;
        killCoins = _downBonus;
        hurtCoins = _gettingHit;
        missCoins = _miss;
    }

    function setXP(uint _hit, uint _dodge, uint _downBonus, uint _gettingHit, uint _miss) public onlyOwner{
        hitXP = _hit;
        dodgeXP = _dodge;
        killXP = _downBonus;
        hurtXP = _gettingHit;
        missXP = _miss;
    }

    function fight(uint attackingID, uint defendingID) external{
        require(KawaiiPets[attackingID].lastTimeAttack + attackTime < block.timestamp, "You cant attack now");
        require(KawaiiPets[defendingID].lastTimeDefend + defendTime < block.timestamp, "This nft got attacked recently");
        require(collection.ownerOf(attackingID) != collection.ownerOf(defendingID), "Both NFTs must be owned by different players");
        require(collection.ownerOf(attackingID) == msg.sender, "You need to own the NFT to fight with it");
        if(KawaiiPets[attackingID].currentHealth <= 0 || KawaiiPets[defendingID].currentHealth <= 0) revert("Your pet or the attacked one needs to be revived first...");

        KawaiiPet memory attacker = KawaiiPets[attackingID];
        Inventory memory attackerInventory = kawaiiInventory[attackingID];

        // Get total of all properties for the fight
        uint attackAgility = attacker.agility + attackerInventory.weapon.agilityBonus + attackerInventory.collar.agilityBonus + attackerInventory.gauntlets.agilityBonus + attackerInventory.boots.agilityBonus + attackerInventory.armor.agilityBonus;
        uint attackStrength = attacker.strength + attackerInventory.weapon.strengthBonus + attackerInventory.collar.strengthBonus + attackerInventory.gauntlets.strengthBonus + attackerInventory.boots.strengthBonus + attackerInventory.armor.strengthBonus;

        KawaiiPet memory defender = KawaiiPets[defendingID];
        Inventory memory defenderInventory = kawaiiInventory[defendingID];

        uint defendAgility = defender.agility + defenderInventory.weapon.agilityBonus + defenderInventory.collar.agilityBonus + defenderInventory.gauntlets.agilityBonus + defenderInventory.boots.agilityBonus + defenderInventory.armor.agilityBonus;
        uint defendDefense = defender.defense + defenderInventory.weapon.defenseBonus + defenderInventory.collar.defenseBonus + defenderInventory.gauntlets.defenseBonus + defenderInventory.boots.defenseBonus + defenderInventory.armor.defenseBonus;

        KawaiiPets[attackingID].lastTimeAttack = block.timestamp;
        KawaiiPets[defendingID].lastTimeDefend = block.timestamp;
        uint probability = (attackAgility * 1000) / (attackAgility + defendAgility);
        uint rdm = uint(keccak256(abi.encodePacked(block.difficulty))) % 1000;
        // Calculate the probability of the attack hitting
        if ((rdm <= probability) && (attackStrength - defendDefense) > 0) {
            // Attack hits
            uint damageamount = attackStrength - defendDefense;
            KawaiiPets[defendingID].currentHealth -= damageamount;
            if (KawaiiPets[defendingID].currentHealth <= 0) {
                // Defender fainted
                fightRewards(attackingID, defendingID, true, true);
            } else {
                // Just a hit
                fightRewards(attackingID, defendingID, true, false);
            }
        } else {
            // Attack misses
            fightRewards(attackingID, defendingID, false, false);
        }
    }

    function fightRewards(uint _attackingID, uint _defendingID, bool isHit, bool isDown) internal{
        // Calculate intial experience to track level up
        uint attackerLvl = KawaiiPets[_attackingID].experience / 100;
        uint defenderLvl = KawaiiPets[_defendingID].experience / 100;

        // Add experience amount depending on situation
        uint attackingXP;
        uint defendingXP;
        uint attackingCoin;
        uint defendingCoin;

        if(isHit){
            attackingXP += hitXP;
            defendingXP += hurtXP;
            attackingCoin += hitCoins;
            defendingCoin += hurtCoins;
            if(isDown){
                attackingXP += killXP;
                attackingCoin += killCoins;
            }
        } else {
            attackingXP += missXP;
            attackingCoin += missCoins;
            defendingXP += dodgeXP;
            defendingCoin += dodgeCoins;
        }

        // Add rewards coin
        shop.increaseCoin(attackingCoin, collection.ownerOf(_attackingID));
        shop.increaseCoin(defendingCoin, collection.ownerOf(_defendingID));

        // Add experience
        KawaiiPets[_attackingID].experience += attackingXP;
        KawaiiPets[_defendingID].experience += defendingXP;

        // Calculate intial experience to track level up
        if(attackerLvl == KawaiiPets[_attackingID].experience / 100){
            shop.mintRune(collection.ownerOf(_attackingID));
        }
        if(defenderLvl == KawaiiPets[_defendingID].experience / 100){
            shop.mintRune(collection.ownerOf(_defendingID));
        }
    }

    function useItem(uint _tokenID, uint _nftId) external {
        require(shop.ownerOf(_tokenID) == msg.sender, "You do not own this item");
        require(collection.ownerOf(_nftId) == msg.sender, "You do not own this pet");

        uint itemID = shop.tokenToItemIds(_tokenID);
        Item memory item = shop.getItem(itemID);

        if(keccak256(bytes(item.itemType)) == keccak256(bytes("Consumable"))){
            // If consumable, add permanently to pet abilities
            KawaiiPets[_nftId].totalHealth += item.healthBonus;
            if(item.healAmount > 0 && KawaiiPets[_nftId].currentHealth <= 0){
                revert("Cant use heal consumable if dead");
            }
            
            KawaiiPets[_nftId].currentHealth += item.healAmount;
            
            if(KawaiiPets[_nftId].currentHealth > KawaiiPets[_nftId].totalHealth){
                KawaiiPets[_nftId].currentHealth = KawaiiPets[_nftId].totalHealth;
            }
            KawaiiPets[_nftId].agility += item.agilityBonus;
            KawaiiPets[_nftId].defense += item.defenseBonus;
            KawaiiPets[_nftId].strength += item.strengthBonus;
            shop.transferFrom(msg.sender, address(0x000000000000000000000000000000000000dEaD), _tokenID);
            return;
        } else if(keccak256(bytes(item.itemType)) == keccak256(bytes("Weapon"))){
            if(kawaiiInventory[_nftId].weaponTokenID != 0){
                shop.unequipItem(kawaiiInventory[_nftId].weaponTokenID, msg.sender);
            }
            kawaiiInventory[_nftId].weapon = item;
            kawaiiInventory[_nftId].weaponTokenID = _tokenID;
            shop.transferFrom(msg.sender, address(this), _tokenID);
            return;
        } else if(keccak256(bytes(item.itemType)) == keccak256(bytes("Collar"))) {
            if(kawaiiInventory[_nftId].collarTokenID != 0){
                shop.unequipItem(kawaiiInventory[_nftId].collarTokenID, msg.sender);
            }
            kawaiiInventory[_nftId].collar = item;
            kawaiiInventory[_nftId].collarTokenID = _tokenID;
            shop.transferFrom(msg.sender, address(this), _tokenID);
            return;
        } else if(keccak256(bytes(item.itemType)) == keccak256(bytes("Armor"))) {
            if(kawaiiInventory[_nftId].armorTokenID != 0){
                shop.unequipItem(kawaiiInventory[_nftId].armorTokenID, msg.sender);
            }
            kawaiiInventory[_nftId].armor = item;
            kawaiiInventory[_nftId].armorTokenID = _tokenID;
            shop.transferFrom(msg.sender, address(this), _tokenID);
            return;
        } else if(keccak256(bytes(item.itemType)) == keccak256(bytes("Boots"))) {
            if(kawaiiInventory[_nftId].bootsTokenID != 0){
                shop.unequipItem(kawaiiInventory[_nftId].bootsTokenID, msg.sender);
            }
            kawaiiInventory[_nftId].boots = item;
            kawaiiInventory[_nftId].bootsTokenID = _tokenID;       
            shop.transferFrom(msg.sender, address(this), _tokenID); 
            return;
        } else if(keccak256(bytes(item.itemType)) == keccak256(bytes("Gauntlets"))) {
            if(kawaiiInventory[_nftId].gauntletsTokenID != 0){
                shop.unequipItem(kawaiiInventory[_nftId].gauntletsTokenID, msg.sender);
            }
            kawaiiInventory[_nftId].gauntlets = item;
            kawaiiInventory[_nftId].gauntletsTokenID = _tokenID;    
            shop.transferFrom(msg.sender, address(this), _tokenID);
            return;
        } 
    }

    uint randomRunenonce = 0;
    function specialItems(uint _tokenID, uint _nftId, uint _itemId) external{
        require(_itemId < 2);
        require(shop.ownerOf(_tokenID) == msg.sender, "You do not own this item");
        require(collection.ownerOf(_nftId) == msg.sender, "You do not own this pet");
        require(shop.tokenToItemIds(_tokenID) == _itemId);
        // Random Rune
        if(_itemId == 0) {
            uint randomNumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randomRunenonce))) % 4;
            randomRunenonce++;
            uint randomNumber2 = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randomRunenonce))) % 4;
            randomRunenonce++;
            KawaiiPets[_nftId].agility += randomNumber + 1;
            KawaiiPets[_nftId].strength += randomNumber2 + 1;
            KawaiiPets[_nftId].defense += randomNumber + 1;
            KawaiiPets[_nftId].totalHealth += randomNumber2 + 1;
            KawaiiPets[_nftId].currentHealth += randomNumber2 + 1;
        } else if(_itemId == 1) {
            require(KawaiiPets[_nftId].currentHealth > 0);
            uint half = KawaiiPets[_nftId].totalHealth;
            KawaiiPets[_nftId].currentHealth += half;
            if(KawaiiPets[_nftId].currentHealth > KawaiiPets[_nftId].totalHealth){
                KawaiiPets[_nftId].currentHealth = KawaiiPets[_nftId].totalHealth;
            }
        } else if(_itemId == 2) {
            require(KawaiiPets[_nftId].currentHealth <= 0);
            KawaiiPets[_nftId].currentHealth = KawaiiPets[_nftId].totalHealth;
        }
        shop.safeTransferFrom(msg.sender, address(0x000000000000000000000000000000000000dEaD), _tokenID);
    }

    // Will contain all KawaiiPets informations
    mapping(uint => KawaiiPet) public KawaiiPets;

    function initialisePet(uint id, address owner, bool isWL) external onlyAllowedContract {
        KawaiiPets[id] = KawaiiPet(id, 0, 10, 10, 1, 1, 1, block.timestamp - attackTime, block.timestamp - defendTime);
        if(isWL) shop.wlRewards(owner);
    }
}

contract SuperKawaii is Ownable, ERC721AQueryable, PaymentSplitter {

    using ECDSA for bytes32;
    using Strings for uint;

    address private signerAddressWL;

    enum Step {
        Before,
        WhitelistSale,
        PublicSale,
        SoldOut
    }

    string public baseURI;

    Step public sellingStep;

    // Mint Condition - 1 per wallet hardcoded
    uint private constant MAX_SUPPLY = 20;
    uint private max_public = 10;
    uint private max_wl = 10;
    uint public wlSalePrice = 0.001 ether;
    uint public publicSalePrice = 0.001 ether;

    mapping(address => uint) public mintedAmountNFTsperWalletWLs;
    mapping(address => uint) public mintedAmountNFTsperWalletPublic;

    uint private teamLength;

    TheKawaiiRing public ring;

    constructor(address[] memory _team, uint[] memory _teamShares, address _signerAddressWL, string memory _baseURI) ERC721A("Super Kawaii", "KAWAII")
    PaymentSplitter(_team, _teamShares) {
        signerAddressWL = _signerAddressWL;
        baseURI = _baseURI;
        teamLength = _team.length;
    }

    function setRing(address _ring) external onlyOwner{
        ring = TheKawaiiRing(payable(_ring));
    }

    function changeSigner(address _newSigner) external onlyOwner{
        signerAddressWL = _newSigner;
    }

    function mintForOpensea() external onlyOwner{
        if(totalSupply() != 0) revert("Only one mint for deployer");
        ring.initialisePet(_nextTokenId(), msg.sender, false);
        _mint(msg.sender, 1);
    }

    // TODO -- TO DELETEE !!!!!
    function toDeleteMint() external {
        ring.initialisePet(_nextTokenId(), msg.sender, true);
        _mint(msg.sender, 1);
    }

    function publicSaleMint() external payable {
        uint price = publicSalePrice;
        if(price <= 0) revert("Price is 0");
        if(msg.value < price) revert("Not enough funds");
        if(sellingStep != Step.PublicSale) revert("Public Mint not live.");
        if(totalSupply() + 1 > MAX_SUPPLY) revert("Max supply exceeded");
        if(totalSupply() + 1 > max_public + max_wl) revert("Max supply public exceeded");
        if(mintedAmountNFTsperWalletPublic[msg.sender] + 1 > 1) revert("Max exceeded for Public Sale");
        mintedAmountNFTsperWalletPublic[msg.sender] += 1;
        ring.initialisePet(_nextTokenId(), msg.sender, false);
        _mint(msg.sender, 1);
    }

    function WLMint(bytes calldata signature) external payable {
        uint price = wlSalePrice;
        if(price <= 0) revert("Price is 0");
        if(msg.value < price * 1) revert("Not enough funds"); 
        if(sellingStep != Step.WhitelistSale) revert("WL Mint not live.");
        if(totalSupply() + 1 > MAX_SUPPLY) revert("Max supply exceeded for WL");
        if(totalSupply() + 1 > max_wl) revert("Max supply wl exceeded");
        if(signerAddressWL != keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                bytes32(uint256(uint160(msg.sender)))
            )
        ).recover(signature)) revert("You are not in WL whitelist");
        if(mintedAmountNFTsperWalletWLs[msg.sender] + 1 > 1) revert("Max exceeded for Whitelist Sale");
        mintedAmountNFTsperWalletWLs[msg.sender] += 1;
        ring.initialisePet(_nextTokenId(), msg.sender, true);
        _mint(msg.sender, 1);
    }

    function currentState() external view returns (Step, uint, uint) {
        return (sellingStep, publicSalePrice, wlSalePrice);
    }

    function changeWLSupply(uint new_supply) external onlyOwner{
        max_wl = new_supply;
    }

    function changePublicSupply(uint new_supply) external onlyOwner{
        max_public = new_supply;
    }

    function changeWlSalePrice(uint256 new_price) external onlyOwner{
        wlSalePrice = new_price;
    }

    function changePublicSalePrice(uint256 new_price) external onlyOwner{
        publicSalePrice = new_price;
    }

    function setBaseUri(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function setStep(uint _step) external onlyOwner {
        sellingStep = Step(_step);
    }

    function getNumberMinted(address account) external view returns (uint256) {
        return _numberMinted(account);
    }

    function getNumberWLMinted(address account) external view returns (uint256) {
        return mintedAmountNFTsperWalletWLs[account];
    }

    function tokenURI(uint _tokenId) public view virtual override(ERC721A, IERC721A) returns (string memory) {
        require(_exists(_tokenId), "URI query for nonexistent token");
        return string(abi.encodePacked(baseURI, _toString(_tokenId)));
    }

    function releaseAll() external {
        for(uint i = 0 ; i < teamLength ; i++) {
            release(payable(payee(i)));
        }
    }
}