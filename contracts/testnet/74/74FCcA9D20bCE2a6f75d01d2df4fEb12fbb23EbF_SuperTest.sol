// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./test2.sol";

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

struct TestPet {
    uint TestID;
    uint xp;
    uint currentHealth;
    uint totalHealth;
    uint strength;
    uint agility;
    uint defense;
    uint lastAtk;
    uint lastDef;
}

contract TheTestRing is Ownable {

    using SafeMath for uint;

    // Global Datas
    uint public hitXP = 25;
    uint public killXP = 30;
    uint public dodgeXP = 17;
    uint public hurtXP = 6;
    uint public missXP = 6;

    uint public hitCoins = 25;
    uint public killCoins = 20;
    uint public dodgeCoins = 20;
    uint public hurtCoins = 7;
    uint public missCoins = 7;

    uint public atkTime = 0;
    uint public defTime = 0;

    // TestID to its inventory
    mapping(uint => Inventory) public inventory;

    // Shop System
    TheTestShop public shop;

    SuperTest public collection;

    constructor(address _shopContract, address _collectionContract){
        shop = TheTestShop(payable(_shopContract));
        collection = SuperTest(payable(_collectionContract));
    }

    modifier onlyAllowedContract() {
        require(msg.sender == address(collection) || msg.sender == owner(), "Not owner");
        _;
    }

    function setAddresses(address _collection, address newShop) public onlyOwner {
        collection = SuperTest(payable(_collection));
        shop = TheTestShop(payable(newShop));
    }

    function setCombatTimespans(uint _newatkTime, uint _newDefendSpan) public onlyOwner {
        atkTime = _newatkTime;
        defTime = _newDefendSpan;
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

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function dodgeAttack(uint atkAgility, uint defAgility) public view returns (bool) {
        require(defAgility + atkAgility > 0, "Denominator > 0");
        uint256 agilitySum = atkAgility.add(defAgility);
        uint256 agilityRatio = atkAgility.mul(100).div(agilitySum);
        uint256 cappedChance = min(agilityRatio, 50);
        uint256 randomChance = uint(keccak256(abi.encodePacked(block.timestamp))).mod(100);
        return randomChance < cappedChance;
    }

    function fight(uint atkID, uint defID) external{
        require(collection.ownerOf(atkID) != collection.ownerOf(defID), "Owner not diff");
        require(collection.ownerOf(atkID) == msg.sender, "Not the owner");

        TestPet memory attacker = TestPets[atkID];
        Inventory memory atkInventory = inventory[atkID];

        TestPet memory defender = TestPets[defID];
        Inventory memory defInventory = inventory[defID];

        require(attacker.lastAtk.add(atkTime) <= block.timestamp, "Cant attack now");
        require(defender.lastDef.add(defTime) <= block.timestamp, "Got attacked recently");
        if(attacker.currentHealth <= 0 || defender.currentHealth <= 0) revert("1 of them needs revive");

        // Get total of all properties for the fight
        uint atkAgility = attacker.agility.add(atkInventory.weapon.agilityBonus).add(atkInventory.collar.agilityBonus).add(atkInventory.gauntlets.agilityBonus).add(atkInventory.boots.agilityBonus).add(atkInventory.armor.agilityBonus);
        uint atkStrength = attacker.strength.add(atkInventory.weapon.strengthBonus).add(atkInventory.collar.strengthBonus).add(atkInventory.gauntlets.strengthBonus).add(atkInventory.boots.strengthBonus).add(atkInventory.armor.strengthBonus);
        uint defAgility = defender.agility.add(defInventory.weapon.agilityBonus).add(defInventory.collar.agilityBonus).add(defInventory.gauntlets.agilityBonus).add(defInventory.boots.agilityBonus).add(defInventory.armor.agilityBonus);
        uint defDef = defender.defense.add(defInventory.weapon.defenseBonus).add(defInventory.collar.defenseBonus).add(defInventory.gauntlets.defenseBonus).add(defInventory.boots.defenseBonus).add(defInventory.armor.defenseBonus);

        TestPets[atkID].lastAtk = block.timestamp;
        TestPets[defID].lastDef = block.timestamp;

        if (dodgeAttack(atkAgility, defAgility)) {
            // Dodged
            fightRewards(atkID, defID, 0, true);
        } else {
            uint damage = 0;
            if(defDef < atkStrength){
                damage = atkStrength.sub(defDef);
            }
            uint newHealth = 0;
            if (!(damage > defender.currentHealth)) {
                newHealth = defender.currentHealth.sub(damage);
            }
            fightRewards(atkID, defID, newHealth, false);
        }
    }

    function fightRewards(uint _atkID, uint _defID, uint newHealth, bool dodged) internal {
        
        // Add xp amount depending on situation
        uint atkXP;
        uint defXP;
        uint atkCoin;
        uint defCoin;
        uint atkLvl = 0;
        uint defLvl = 0;

        atkLvl = TestPets[_atkID].xp.div(100);
        defLvl = TestPets[_defID].xp.div(100);

        if(!dodged){
            // Set health
            
            TestPets[_defID].currentHealth = newHealth;

            // Just a hit
            atkXP = atkXP.add(hitXP);
            atkCoin = atkCoin.add(hitCoins);
            defXP = defXP.add(hurtXP);
            defCoin = defCoin.add(hurtCoins);

            if (TestPets[_defID].currentHealth <= 0){
                // Defender fainted - add bonus
                atkXP = atkXP.add(killXP);
                atkCoin = atkCoin.add(killCoins);
            }
        } else {
            // Dodged
            atkXP = atkXP.add(missXP);
            atkCoin = atkCoin.add(missCoins);
            defXP = defXP.add(dodgeXP);
            defCoin = defCoin.add(dodgeCoins);
        }
        // Add rewards coin
        shop.increaseCoin(atkCoin, collection.ownerOf(_atkID));
        shop.increaseCoin(defCoin, collection.ownerOf(_defID));

        // Add xp
        TestPets[_atkID].xp = TestPets[_atkID].xp.add(atkXP);
        TestPets[_defID].xp = TestPets[_defID].xp.add(defXP);

        // Calculate intial xp to track level up
        if(TestPets[_atkID].xp >= 100 && atkLvl != TestPets[_atkID].xp.div(100)){
            shop.mintRune(collection.ownerOf(_atkID));
        }
        if(TestPets[_defID].xp >= 100 && defLvl != TestPets[_defID].xp.div(100)){
            shop.mintRune(collection.ownerOf(_defID));
        }
    }

    function useItem(uint _tokenID, uint _nftId) external {
        require(shop.ownerOf(_tokenID) == msg.sender, "You do not own this item");
        require(collection.ownerOf(_nftId) == msg.sender, "You do not own this pet");

        uint itemID = shop.tokenToItemIds(_tokenID);
        Item memory item = shop.getItem(itemID);

        TestPet memory pet = TestPets[_nftId];

        if(keccak256(bytes(item.itemType)) == keccak256(bytes("Consumable"))){
            // If consumable, add permanently to pet abilities
            pet.totalHealth += item.healthBonus;
            if(item.healAmount > 0 && pet.currentHealth <= 0){
                revert("Cant use heal consumable if dead");
            }
            
            pet.currentHealth += item.healAmount;
            
            if(pet.currentHealth > pet.totalHealth){
                pet.currentHealth = pet.totalHealth;
            }
            pet.agility += item.agilityBonus;
            pet.defense += item.defenseBonus;
            pet.strength += item.strengthBonus;
            TestPets[_nftId] = pet;
            shop.transferFrom(msg.sender, address(0x000000000000000000000000000000000000dEaD), _tokenID);
            return;
        } else if(keccak256(bytes(item.itemType)) == keccak256(bytes("Weapon"))){
            if(inventory[_nftId].weaponTokenID != 0){
                shop.unequipItem(inventory[_nftId].weaponTokenID, msg.sender);
            }
            inventory[_nftId].weapon = item;
            inventory[_nftId].weaponTokenID = _tokenID;
            shop.transferFrom(msg.sender, address(this), _tokenID);
            return;
        } else if(keccak256(bytes(item.itemType)) == keccak256(bytes("Collar"))) {
            if(inventory[_nftId].collarTokenID != 0){
                shop.unequipItem(inventory[_nftId].collarTokenID, msg.sender);
            }
            inventory[_nftId].collar = item;
            inventory[_nftId].collarTokenID = _tokenID;
            shop.transferFrom(msg.sender, address(this), _tokenID);
            return;
        } else if(keccak256(bytes(item.itemType)) == keccak256(bytes("Armor"))) {
            if(inventory[_nftId].armorTokenID != 0){
                shop.unequipItem(inventory[_nftId].armorTokenID, msg.sender);
            }
            inventory[_nftId].armor = item;
            inventory[_nftId].armorTokenID = _tokenID;
            shop.transferFrom(msg.sender, address(this), _tokenID);
            return;
        }
    }

    uint randomRunenonce = 0;
    function specialItems(uint _tokenID, uint _nftId, uint _itemId) external{
        require(_itemId <= 2);
        require(shop.ownerOf(_tokenID) == msg.sender, "Not owner - item");
        require(collection.ownerOf(_nftId) == msg.sender, "Not owner - pet");
        require(shop.tokenToItemIds(_tokenID) == _itemId);
        // Random Rune
        if(_itemId == 0) {
            uint randomNumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randomRunenonce))) % 4;
            randomRunenonce++;
            uint randomNumber2 = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randomRunenonce))) % 4;
            randomRunenonce++;
            TestPets[_nftId].agility += randomNumber + 1;
            TestPets[_nftId].strength += randomNumber2 + 1;
            TestPets[_nftId].defense += randomNumber + 1;
            TestPets[_nftId].totalHealth += randomNumber2 + 1;
            TestPets[_nftId].currentHealth += randomNumber2 + 1;
        } else if(_itemId == 1) {
            require(TestPets[_nftId].currentHealth > 0, "Your pet cant be healed if dead");
            uint half = TestPets[_nftId].totalHealth;
            TestPets[_nftId].currentHealth += half;
            if(TestPets[_nftId].currentHealth > TestPets[_nftId].totalHealth){
                TestPets[_nftId].currentHealth = TestPets[_nftId].totalHealth;
            }
        } else if(_itemId == 2) {
            require(TestPets[_nftId].currentHealth <= 0, "Your pet isnt dead");
            uint newHealth = TestPets[_nftId].totalHealth;
            TestPets[_nftId].currentHealth = newHealth;
        }
        shop.safeTransferFrom(msg.sender, address(0x0), _tokenID);
    }

    // Will contain all TestPets informations
    mapping(uint => TestPet) public TestPets;

    function getTestList(uint offset, uint limit) public view returns (TestPet[] memory) {
        TestPet[] memory result = new TestPet[](limit);
        uint count = 0;
        for (uint i = offset; i < offset + limit; i++) {
            if(TestPets[i].TestID != 0){
                result[count] = TestPets[i];
                count++;
            }
        }
        return result;
    }

    function initialisePet(uint id, address owner, bool isWL) external onlyAllowedContract {
        TestPets[id] = TestPet(id, 0, 10, 10, 4, 1, 1, block.timestamp - atkTime, block.timestamp - defTime);
        if(isWL) shop.wlRewards(owner);
    }
}

contract SuperTest is Ownable, ERC721AQueryable, PaymentSplitter {

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

    TheTestRing public ring;

    constructor(address[] memory _team, uint[] memory _teamShares, address _signerAddressWL, string memory _baseURI) ERC721A("Super Test", "Test")
    PaymentSplitter(_team, _teamShares) {
        signerAddressWL = _signerAddressWL;
        baseURI = _baseURI;
        teamLength = _team.length;
    }

    function setRing(address _ring) external onlyOwner{
        ring = TheTestRing(payable(_ring));
    }

    function changeSigner(address _newSigner) external onlyOwner{
        signerAddressWL = _newSigner;
    }

    function mintForOpensea() external onlyOwner{
        if(totalSupply() != 0) revert("Only one mint for deployer");
        ring.initialisePet(_nextTokenId(), msg.sender, false);
        _mint(msg.sender, 1);
    }

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