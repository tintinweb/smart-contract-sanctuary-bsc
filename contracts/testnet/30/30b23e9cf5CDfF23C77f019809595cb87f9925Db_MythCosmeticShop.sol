// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

// import "ERC20.sol";
import "ERC721.sol";

contract MythDegen is ERC721 {
    uint256 public tokenCount;
    mapping(uint256 => stats) public degenStats;
    mapping(uint256 => gear) public degenGear;
    mapping(uint256 => cosmetics) public degenCosmetics;
    mapping(uint256 => mods) public degenMods;
    mapping(address => bool) public whitelistedAddresses;
    // degen id          cosmetic address         layer type          item id
    mapping(uint256 => mapping(address => mapping(uint256 => mapping(uint256 => bool))))
        public unlockedCosmetics;

    mapping(address => bool) public cosmeticWhitelist;
    mapping(address => bool) public degenWhitelist;
    mapping(uint256 => mapping(uint256 => bool)) public freeCosmetics;
    string public defaultBackground;
    string public defaultEye;
    string public defaultMouth;
    string public defaultSkinColor;
    address payable public owner;

    //Degen will have things describing it
    //Owner
    //Core and Damage
    //Equipped Gear
    //Equipped Mods
    //Equipped Cosmetics

    struct itemData {
        address addressOfItem;
        uint256 idOfItem;
    }
    struct gear {
        itemData equipmentData;
    }

    struct cosmetics {
        itemData backgroundData;
        itemData eyeData;
        itemData mouthData;
        itemData noseData;
        itemData skinColorData;
        itemData bodyData;
        itemData headData;
    }

    struct mods {
        itemData faceModData;
    }
    struct stats {
        uint256 coreScore;
        uint256 damageCap;
        address owner;
    }

    event cosmeticChange(
        uint256 degenId,
        uint256 layerType,
        address cosmeticAddress,
        uint256 itemId
    );
    event ownerChange(uint256 degenId, address ownerAddress);
    event cosmeticUnlocked(
        uint256 degenId,
        uint256 layerType,
        address cosmeticAddress,
        uint256 itemId
    );
    event cosmeticFreeAdded(uint256 layerType, uint256 layerId);

    //Degen functions
    //1. Change Cosmetic - owner of degen
    //2. Unlock Cosmetic - cosmetic whitelist
    //3. Equip Mod to Degen - owner of degen and mod
    //3. Equip Weapon to Degen - owner of degen and weapon
    //4. Equip Equipment to Degen - owner of degen and equipment
    //5. Unequip mod/weapon/equipment - owner of degen
    //6. Increase Degen Core - degen whitelist
    //7. Decrease Degen Core - degen whitelist
    //8. Increase Degen Damage - degen whitelist
    //9. Decrease Degen Damage - degen whitelist

    //10. Read function to get
    // stats
    //equipped gear
    //cosmetic layers

    constructor() ERC721("Myth City Degen", "MYDG") {
        tokenCount = 0;
        owner = payable(msg.sender);
        defaultBackground = "https://mythcity.mypinata.cloud/ipfs/QmaaKkumxEX6YrpgqGqWcZEBFGJBhRPz5JxA6HSDMZs5mE/BACKGROUND/BACKGROUND%202-min.png";
        defaultEye = "https://mythcity.mypinata.cloud/ipfs/QmaaKkumxEX6YrpgqGqWcZEBFGJBhRPz5JxA6HSDMZs5mE/EYES/DEFAULT-min.png";
        defaultMouth = "https://mythcity.mypinata.cloud/ipfs/QmaaKkumxEX6YrpgqGqWcZEBFGJBhRPz5JxA6HSDMZs5mE/MOUTH/DEFAULT-min.png";
        defaultSkinColor = "https://mythcity.mypinata.cloud/ipfs/QmaaKkumxEX6YrpgqGqWcZEBFGJBhRPz5JxA6HSDMZs5mE/BODY%20COLOR/DEFAULT-min.png";
        whitelistedAddresses[msg.sender] = true;
        mint(msg.sender, 5000, 10);
    }

    function setFreeCosmetics(
        uint256 _layerType,
        uint256 _length,
        uint256[10] calldata _itemIds
    ) external isCosmeticWhitelisted {
        require(
            _layerType >= 0 && _layerType <= 6,
            "Please select valid layer type"
        );
        for (uint256 i = 0; i < _length; i++) {
            emit cosmeticFreeAdded(_layerType, _itemIds[i]);
            freeCosmetics[_layerType][_itemIds[i]] = true;
        }
    }

    function withdraw() external {
        require(msg.sender == owner, "Not owner");
        owner.transfer(address(this).balance);
    }

    modifier isWhitelisted() {
        require(whitelistedAddresses[msg.sender], "Not white listed");
        _;
    }
    modifier isDegenWhitelisted() {
        require(degenWhitelist[msg.sender], "Not Degen white listed");
        _;
    }
    modifier isCosmeticWhitelisted() {
        require(cosmeticWhitelist[msg.sender], "Not Cosmetic white listed");
        _;
    }

    function reGradeDegen(
        uint256 _degenId,
        uint256 _newCore,
        uint256 _newDamage
    ) external isDegenWhitelisted {
        degenStats[_degenId].coreScore = _newCore;
        degenStats[_degenId].damageCap = _newDamage;
    }

    function alterCosmeticAddress(address _address) external isWhitelisted {
        cosmeticWhitelist[_address] = !cosmeticWhitelist[_address];
    }

    function alterDegenAddress(address _address) external isWhitelisted {
        degenWhitelist[_address] = !degenWhitelist[_address];
    }

    function unlockCosmetics(
        address _address,
        uint256 _degenId,
        uint256 _layerType,
        uint256 _length,
        uint256[10] calldata _itemIds
    ) external isCosmeticWhitelisted {
        require(
            _layerType >= 0 && _layerType <= 6,
            "Please select valid layer type"
        );
        require(cosmeticWhitelist[_address], "That address is not available");
        for (uint256 i = 0; i < _length; i++) {
            emit cosmeticUnlocked(_degenId, _layerType, _address, _itemIds[i]);
            unlockedCosmetics[_degenId][_address][_layerType][
                _itemIds[i]
            ] = true;
        }
    }

    function changeDegenBackground(
        uint256 _degenId,
        address _cosmeticAddress,
        uint256 _backgroundId
    ) external {
        require(
            degenStats[_degenId].owner == msg.sender,
            "Only the owner of the degen can change the BackGround"
        );
        require(
            cosmeticWhitelist[_cosmeticAddress],
            "This item address is not allowed"
        );
        require(
            unlockedCosmetics[_degenId][_cosmeticAddress][0][_backgroundId] ||
                freeCosmetics[0][_backgroundId],
            "This degen does not have this background unlocked"
        );
        emit cosmeticChange(_degenId, 0, _cosmeticAddress, _backgroundId);
        degenCosmetics[_degenId].backgroundData = itemData(
            _cosmeticAddress,
            _backgroundId
        );
    }

    function changeDegenEyes(
        uint256 _degenId,
        address _cosmeticAddress,
        uint256 _eyesId
    ) external {
        require(
            degenStats[_degenId].owner == msg.sender,
            "Only the owner of the degen can change the BackGround"
        );
        require(
            cosmeticWhitelist[_cosmeticAddress],
            "This item address is not allowed"
        );
        require(
            unlockedCosmetics[_degenId][_cosmeticAddress][1][_eyesId] ||
                freeCosmetics[1][_eyesId],
            "This degen does not have this background unlocked"
        );
        emit cosmeticChange(_degenId, 1, _cosmeticAddress, _eyesId);
        degenCosmetics[_degenId].eyeData = itemData(_cosmeticAddress, _eyesId);
    }

    function changeDegenMouth(
        uint256 _degenId,
        address _cosmeticAddress,
        uint256 _mouthId
    ) external {
        require(
            degenStats[_degenId].owner == msg.sender,
            "Only the owner of the degen can change the BackGround"
        );
        require(
            cosmeticWhitelist[_cosmeticAddress],
            "This item address is not allowed"
        );
        require(
            unlockedCosmetics[_degenId][_cosmeticAddress][2][_mouthId] ||
                freeCosmetics[2][_mouthId],
            "This degen does not have this background unlocked"
        );
        emit cosmeticChange(_degenId, 2, _cosmeticAddress, _mouthId);
        degenCosmetics[_degenId].mouthData = itemData(
            _cosmeticAddress,
            _mouthId
        );
    }

    function changeDegenNose(
        uint256 _degenId,
        address _cosmeticAddress,
        uint256 _noseId
    ) external {
        require(
            degenStats[_degenId].owner == msg.sender,
            "Only the owner of the degen can change the BackGround"
        );
        require(
            cosmeticWhitelist[_cosmeticAddress],
            "This item address is not allowed"
        );
        require(
            unlockedCosmetics[_degenId][_cosmeticAddress][3][_noseId] ||
                freeCosmetics[3][_noseId],
            "This degen does not have this background unlocked"
        );
        emit cosmeticChange(_degenId, 3, _cosmeticAddress, _noseId);
        degenCosmetics[_degenId].noseData = itemData(_cosmeticAddress, _noseId);
    }

    function changeDegenSkinColor(
        uint256 _degenId,
        address _cosmeticAddress,
        uint256 _skinColorId
    ) external {
        require(
            degenStats[_degenId].owner == msg.sender,
            "Only the owner of the degen can change the BackGround"
        );
        require(
            cosmeticWhitelist[_cosmeticAddress],
            "This item address is not allowed"
        );
        require(
            unlockedCosmetics[_degenId][_cosmeticAddress][4][_skinColorId] ||
                freeCosmetics[4][_skinColorId],
            "This degen does not have this background unlocked"
        );
        emit cosmeticChange(_degenId, 4, _cosmeticAddress, _skinColorId);
        degenCosmetics[_degenId].skinColorData = itemData(
            _cosmeticAddress,
            _skinColorId
        );
    }

    function changeDegenBody(
        uint256 _degenId,
        address _cosmeticAddress,
        uint256 _bodyId
    ) external {
        require(
            degenStats[_degenId].owner == msg.sender,
            "Only the owner of the degen can change the BackGround"
        );
        require(
            cosmeticWhitelist[_cosmeticAddress],
            "This item address is not allowed"
        );
        require(
            unlockedCosmetics[_degenId][_cosmeticAddress][5][_bodyId] ||
                freeCosmetics[5][_bodyId],
            "This degen does not have this background unlocked"
        );
        emit cosmeticChange(_degenId, 5, _cosmeticAddress, _bodyId);
        degenCosmetics[_degenId].bodyData = itemData(_cosmeticAddress, _bodyId);
    }

    function equipMod(
        uint256 _degenId,
        uint256 _modId,
        address _modsAddress
    ) external {
        require(
            degenStats[_degenId].owner == msg.sender,
            "Only the owner of the degen can change the BackGround"
        );
        require(degenWhitelist[_modsAddress], "this mod is not allowed");
        MythCityMods tempMods = MythCityMods(_modsAddress);
        MythCityMods.itemStat memory tempStats = tempMods.getStats(_modId);
        require(
            tempStats.owner == msg.sender,
            "Only the owner of the degen can change the BackGround"
        );
        bool isEquipped = tempMods.equipMod(_modId, _degenId);
        require(isEquipped, "Mod was not equipped");
        degenMods[_degenId].faceModData = itemData(_modsAddress, _modId);
    }

    function changeDegenHead(
        uint256 _degenId,
        address _cosmeticAddress,
        uint256 _headId
    ) external {
        require(
            degenStats[_degenId].owner == msg.sender,
            "Only the owner of the degen can change the BackGround"
        );
        require(
            cosmeticWhitelist[_cosmeticAddress],
            "This item address is not allowed"
        );
        require(
            unlockedCosmetics[_degenId][_cosmeticAddress][6][_headId] ||
                freeCosmetics[6][_headId],
            "This degen does not have this background unlocked"
        );
        emit cosmeticChange(_degenId, 6, _cosmeticAddress, _headId);
        degenCosmetics[_degenId].headData = itemData(_cosmeticAddress, _headId);
    }

    function getDegenImage(uint256 _id)
        external
        view
        returns (string[9] memory)
    {
        string[9] memory tempList; // 1: BackGround 2: Skin Color 3: Mods 4: Eyes 5: Mouth 6: Head
        tempList[0] = getBackgroundURL(_id);
        tempList[1] = getSkinColorURL(_id);
        tempList[2] = getModURL(_id);
        tempList[3] = getEyeURL(_id);
        tempList[4] = getMouthURL(_id);
        tempList[5] = getNoseURL(_id);
        tempList[6] = getHeadURL(_id);
        tempList[7] = getBodyURL(_id);
        return tempList;
    }

    function updateWhitelist(address _address) external {
        require(msg.sender == owner, "Only owner can change the whitelist");
        whitelistedAddresses[_address] = !whitelistedAddresses[_address];
    }

    function burnToken(uint256 _id) external isWhitelisted {
        degenStats[_id].owner = owner;
    }

    function changeBackgroundDefault(string memory _url)
        external
        isWhitelisted
    {
        defaultBackground = _url;
    }

    function changeEyeDefault(string memory _url) external isWhitelisted {
        defaultEye = _url;
    }

    function changeMouthDefault(string memory _url) external isWhitelisted {
        defaultMouth = _url;
    }

    function changeSkinColorDefault(string memory _url) external isWhitelisted {
        defaultSkinColor = _url;
    }

    function getStats(uint256 _id) external view returns (stats memory) {
        return degenStats[_id];
    }

    function mint(
        address _to,
        uint64 _core,
        uint64 _damage
    ) public isWhitelisted {
        emit ownerChange(tokenCount, _to);
        degenStats[tokenCount] = stats(_core, _damage, _to);
        tokenCount++;
    }

    function getBackgroundURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].backgroundData.addressOfItem == address(0)) {
            return defaultBackground;
        }
        return
            MythCosmetic(degenCosmetics[_id].backgroundData.addressOfItem)
                .backgroundURL(degenCosmetics[_id].backgroundData.idOfItem);
    }

    function getModURL(uint256 _id) public view returns (string memory) {
        if (degenMods[_id].faceModData.addressOfItem == address(0)) {
            return "";
        }
        return
            MythCityMods(degenMods[_id].faceModData.addressOfItem)
                .getImageFromId(degenMods[_id].faceModData.idOfItem);
    }

    function getNoseURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].noseData.addressOfItem == address(0)) {
            return "";
        }
        return
            MythCosmetic(degenCosmetics[_id].noseData.addressOfItem).noseURL(
                degenCosmetics[_id].noseData.idOfItem
            );
    }

    function getBodyURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].bodyData.addressOfItem == address(0)) {
            return "";
        }
        return
            MythCosmetic(degenCosmetics[_id].bodyData.addressOfItem).bodyURL(
                degenCosmetics[_id].bodyData.idOfItem
            );
    }

    function getHeadURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].headData.addressOfItem == address(0)) {
            return "";
        }
        return
            MythCosmetic(degenCosmetics[_id].headData.addressOfItem).headURL(
                degenCosmetics[_id].headData.idOfItem
            );
    }

    function getEyeURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].eyeData.addressOfItem == address(0)) {
            return defaultEye;
        }
        return
            MythCosmetic(degenCosmetics[_id].eyeData.addressOfItem).eyeURL(
                degenCosmetics[_id].eyeData.idOfItem
            );
    }

    function getMouthURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].mouthData.addressOfItem == address(0)) {
            return defaultMouth;
        }
        return
            MythCosmetic(degenCosmetics[_id].mouthData.addressOfItem).mouthURL(
                degenCosmetics[_id].mouthData.idOfItem
            );
    }

    function getSkinColorURL(uint256 _id) public view returns (string memory) {
        if (degenCosmetics[_id].skinColorData.addressOfItem == address(0)) {
            return defaultSkinColor;
        }
        return
            MythCosmetic(degenCosmetics[_id].skinColorData.addressOfItem)
                .skinColorURL(degenCosmetics[_id].skinColorData.idOfItem);
    }
}

contract MythCosmetic {
    address public owner;
    mapping(uint256 => string) public backgroundURL;
    mapping(uint256 => string) public eyeURL;
    mapping(uint256 => string) public mouthURL;
    mapping(uint256 => string) public noseURL;
    mapping(uint256 => string) public skinColorURL;
    mapping(uint256 => string) public bodyURL;
    mapping(uint256 => string) public headURL;

    mapping(uint256 => bool) public backgroundExists;
    mapping(uint256 => bool) public eyeExists;
    mapping(uint256 => bool) public mouthExists;
    mapping(uint256 => bool) public noseExists;
    mapping(uint256 => bool) public skinColorExists;
    mapping(uint256 => bool) public bodyExists;
    mapping(uint256 => bool) public headExists;

    event cosmeticAdded(uint256 layerType, uint256 layerId, string imageURL);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    function removeCosmetic(uint256 _layerType, uint256 _id)
        external
        onlyOwner
    {
        require(_layerType >= 0 && _layerType <= 6, "Layer Type incorrect");
        if (_layerType == 0) {
            delete backgroundURL[_id];
            delete backgroundExists[_id];
        } else if (_layerType == 1) {
            delete eyeURL[_id];
            delete eyeExists[_id];
        } else if (_layerType == 2) {
            delete mouthURL[_id];
            delete mouthExists[_id];
        } else if (_layerType == 3) {
            delete noseURL[_id];
            delete noseExists[_id];
        } else if (_layerType == 4) {
            delete skinColorURL[_id];
            delete skinColorExists[_id];
        } else if (_layerType == 5) {
            delete bodyURL[_id];
            delete bodyExists[_id];
        } else if (_layerType == 6) {
            delete headURL[_id];
            delete headExists[_id];
        }
    }

    function changeBackgroundUrl(string calldata _url, uint256 _id)
        external
        onlyOwner
    {
        emit cosmeticAdded(0, _id, _url);
        backgroundExists[_id] = true;
        backgroundURL[_id] = _url;
    }

    function changeEyeUrl(string calldata _url, uint256 _id)
        external
        onlyOwner
    {
        emit cosmeticAdded(1, _id, _url);
        eyeExists[_id] = true;
        eyeURL[_id] = _url;
    }

    function changeMouthUrl(string calldata _url, uint256 _id)
        external
        onlyOwner
    {
        emit cosmeticAdded(2, _id, _url);
        mouthExists[_id] = true;
        mouthURL[_id] = _url;
    }

    function changeNoseUrl(string calldata _url, uint256 _id)
        external
        onlyOwner
    {
        emit cosmeticAdded(3, _id, _url);
        noseExists[_id] = true;
        noseURL[_id] = _url;
    }

    function changeSkinColorUrl(string calldata _url, uint256 _id)
        external
        onlyOwner
    {
        emit cosmeticAdded(4, _id, _url);
        skinColorExists[_id] = true;
        skinColorURL[_id] = _url;
    }

    function changeBodyUrl(string calldata _url, uint256 _id)
        external
        onlyOwner
    {
        emit cosmeticAdded(5, _id, _url);
        bodyExists[_id] = true;
        bodyURL[_id] = _url;
    }

    function changeHeadUrl(string calldata _url, uint256 _id)
        external
        onlyOwner
    {
        emit cosmeticAdded(6, _id, _url);
        headExists[_id] = true;
        headURL[_id] = _url;
    }
}

contract MythCityEquipment is ERC721 {
    address public owner;
    uint256 public tokenCount;
    mapping(address => bool) public whitelistedAddresses;
    mapping(uint256 => string) public equipmentURL;
    mapping(uint256 => bool) public equipmentExists;
    mapping(uint256 => uint256) public degenToEquipment;

    mapping(uint256 => itemStat) public equipmentStats;
    event whitelistAdded(address whitelistedAddress, bool isWhitelisted);
    event equipmentAdded(uint256 id, string url);
    event equipmentEquipped(uint256 equipmentId, uint256 degenId);
    event equipmentRegrade(uint256 equipmentId, uint256 equipmentStat);
    event equipmentMinted(address to, uint256 imageId, uint256 itemStat);
    event ownerChanged(address to, uint256 equipmentId);
    struct itemStat {
        address owner;
        uint256 imageId;
        uint256 equipmentStat;
        uint256 degenIdEquipped;
    }
    modifier isWhitelisted() {
        require(whitelistedAddresses[msg.sender], "Not white listed");
        _;
    }

    constructor() ERC721("Myth City Equipment", "MYTHEQP") {
        tokenCount = 0;
        owner = msg.sender;
        whitelistedAddresses[msg.sender] = true;
    }

    function transfer(uint256 _equipmentId, address _to) external {
        require(
            equipmentStats[_equipmentId].owner == msg.sender,
            "Only the owner can transfer with this method"
        );
        require(
            equipmentStats[_equipmentId].degenIdEquipped == 0,
            "Cannot transfer while equipped"
        );
        equipmentStats[_equipmentId].owner = _to;
        emit ownerChanged(_to, _equipmentId);
    }

    function equipEquipment(uint256 _equipmentId, uint256 _degenId)
        external
        isWhitelisted
    {
        require(
            equipmentStats[_equipmentId].degenIdEquipped == 0,
            "Mod is already Equipped"
        );
        equipmentStats[_equipmentId].degenIdEquipped = _degenId;
        equipmentStats[degenToEquipment[_degenId]].degenIdEquipped = 0;
        degenToEquipment[_degenId] = _equipmentId;
        emit equipmentEquipped(_equipmentId, _degenId);
    }

    function unequipEquipment(uint256 _degenId) external isWhitelisted {
        delete degenToEquipment[_degenId];
        delete equipmentStats[_degenId].degenIdEquipped;
        emit equipmentEquipped(0, _degenId);
    }

    function overrideOwner(uint256 _equipmentId, address _newOwner)
        external
        isWhitelisted
    {
        emit ownerChanged(_newOwner, _equipmentId);
        equipmentStats[_equipmentId].owner = _newOwner;
    }

    function upgradeModStat(uint256 _equipmentId, uint256 _statUpgrade)
        external
        isWhitelisted
    {
        equipmentStats[_equipmentId].equipmentStat += _statUpgrade;
        emit equipmentRegrade(
            _equipmentId,
            equipmentStats[_equipmentId].equipmentStat
        );
    }

    function regradeModStat(uint256 _equipmentId, uint256 _statRegrade)
        external
        isWhitelisted
    {
        equipmentStats[_equipmentId].equipmentStat = _statRegrade;
        emit equipmentRegrade(
            _equipmentId,
            equipmentStats[_equipmentId].equipmentStat
        );
    }

    function mint(
        address _to,
        uint256 _imageId,
        uint256 _equipmentStat
    ) external isWhitelisted {
        emit ownerChanged(_to, tokenCount);
        emit equipmentMinted(_to, _imageId, _equipmentStat);
        equipmentStats[tokenCount] = itemStat(_to, _imageId, _equipmentStat, 0);
        tokenCount++;
    }

    function removeEquipment(uint256 _id) external isWhitelisted {
        delete equipmentExists[_id];
        delete equipmentURL[_id];
    }

    function changeEquipment(uint256 _id, string calldata _url)
        external
        isWhitelisted
    {
        emit equipmentAdded(_id, _url);
        equipmentExists[_id] = true;
        equipmentURL[_id] = _url;
    }

    function alterWhitelist(address _address) external isWhitelisted {
        whitelistedAddresses[_address] = !whitelistedAddresses[_address];
        emit whitelistAdded(_address, whitelistedAddresses[_address]);
    }
}

contract MythCityMods is ERC721 {
    //Myth Mods will have a image id, item stat
    address public owner;
    uint256 public tokenCount;
    mapping(address => bool) public whitelistedAddresses;
    mapping(uint256 => string) public modURL;
    mapping(uint256 => bool) public modExists;
    mapping(uint256 => uint256) public degenToMod;

    mapping(uint256 => itemStat) public modStats;

    event modAdded(uint256 id, string url);
    event modEquipped(uint256 modId, uint256 degenId);
    event modRegrade(uint256 modId, uint256 modStat);
    event modMinted(address to, uint256 imageId, uint256 itemStat);
    event ownerChanged(address to, uint256 modId);
    event whitelistAdded(address whitelistedAddress, bool isWhitelisted);
    struct itemStat {
        address owner;
        uint256 imageId;
        uint256 modStat;
        uint256 degenIdEquipped;
    }
    modifier isWhitelisted() {
        require(whitelistedAddresses[msg.sender], "Not white listed");
        _;
    }

    constructor() ERC721("Myth City Mod", "MYTHMOD") {
        tokenCount = 1;
        owner = msg.sender;
        whitelistedAddresses[msg.sender] = true;
    }

    function getStats(uint256 _modId) public view returns (itemStat memory) {
        return modStats[_modId];
    }

    function getImageFromId(uint256 _id) external view returns (string memory) {
        return modURL[modStats[_id].imageId];
    }

    function alterWhitelist(address _address) external isWhitelisted {
        whitelistedAddresses[_address] = !whitelistedAddresses[_address];
        emit whitelistAdded(_address, whitelistedAddresses[_address]);
    }

    function transfer(uint256 _modId, address _to) external {
        require(
            modStats[_modId].owner == msg.sender,
            "Only the owner can transfer with this method"
        );
        require(
            modStats[_modId].degenIdEquipped == 0,
            "Cannot transfer while equipped"
        );
        modStats[_modId].owner = _to;
        emit ownerChanged(_to, _modId);
    }

    function equipMod(uint256 _modId, uint256 _degenId)
        external
        isWhitelisted
        returns (bool)
    {
        require(
            modStats[_modId].degenIdEquipped == 0,
            "Mod is already Equipped"
        );
        modStats[_modId].degenIdEquipped = _degenId;
        modStats[degenToMod[_degenId]].degenIdEquipped = 0;
        degenToMod[_degenId] = _modId;
        emit modEquipped(_modId, _degenId);
        return true;
    }

    function unequipMod(uint256 _degenId) external isWhitelisted {
        delete degenToMod[_degenId];
        delete modStats[_degenId].degenIdEquipped;
        emit modEquipped(0, _degenId);
    }

    function overrideOwner(uint256 _modId, address _newOwner)
        external
        isWhitelisted
    {
        emit ownerChanged(_newOwner, _modId);
        modStats[_modId].owner = _newOwner;
    }

    function upgradeModStat(uint256 _modId, uint256 _statUpgrade)
        external
        isWhitelisted
    {
        modStats[_modId].modStat += _statUpgrade;
        emit modRegrade(_modId, modStats[_modId].modStat);
    }

    function regradeModStat(uint256 _modId, uint256 _statRegrade)
        external
        isWhitelisted
    {
        modStats[_modId].modStat = _statRegrade;
        emit modRegrade(_modId, modStats[_modId].modStat);
    }

    function mint(
        address _to,
        uint256 _imageId,
        uint256 _modStat
    ) external isWhitelisted {
        emit ownerChanged(_to, tokenCount);
        emit modMinted(_to, _imageId, _modStat);
        modStats[tokenCount] = itemStat(_to, _imageId, _modStat, 0);
        tokenCount++;
    }

    function removeMod(uint256 _id) external isWhitelisted {
        delete modExists[_id];
        delete modURL[_id];
    }

    function changeMod(uint256 _id, string calldata _url)
        external
        isWhitelisted
    {
        emit modAdded(_id, _url);
        modExists[_id] = true;
        modURL[_id] = _url;
    }
}

contract MythCosmeticShop {
    address payable public owner;
    address public degenAddress;
    address public cosmeticAddress;

    mapping(uint256 => collectionData) public collectionNumber;
    //collection id     collection position   cosmeticUrlId
    mapping(uint256 => mapping(uint256 => uint256)) public urlIdFromCollection;
    mapping(uint256 => mapping(uint256 => bool))
        public degenUnlockedCollections;

    struct collectionData {
        uint256 cost;
        uint256 collectionCount;
        uint256 layerType;
    }

    event collectionUnlocked(uint256 degenId, uint256 collectionId);
    event collectionAdded(
        uint256 collectionId,
        uint256 layerType,
        uint256 cost,
        uint256[] idList
    );

    constructor() {
        owner = payable(msg.sender);
    }

    function addCollection(
        uint256 _collectionId,
        uint256 _layerType,
        uint256 _cost,
        uint256[] calldata _idList
    ) external {
        require(msg.sender == owner, "only owner");
        require(
            collectionNumber[_collectionId].collectionCount == 0,
            "collection already exists"
        );
        for (uint256 i = 0; i < _idList.length; i++) {
            urlIdFromCollection[_collectionId][i] = _idList[i];
        }
        collectionNumber[_collectionId] = collectionData(
            _cost,
            _idList.length,
            _layerType
        );
        emit collectionAdded(_collectionId, _layerType, _cost, _idList);
    }

    function unlockCollection(uint256 _degenId, uint256 _collectionId)
        external
        payable
    {
        MythDegen tempDegen = MythDegen(degenAddress);
        MythDegen.stats memory tempDegenToken = tempDegen.getStats(_degenId);
        collectionData memory tempCollection = collectionNumber[_collectionId];
        require(tempDegenToken.owner == msg.sender, "you don't own that degen");
        require(tempCollection.collectionCount > 0, "That collection is empty");
        require(
            msg.value == tempCollection.cost,
            "send the cost of the collection"
        );
        require(
            !degenUnlockedCollections[_degenId][_collectionId],
            "This degen already has this collection unlocked"
        );
        uint256[10] memory tempIdList;
        for (uint256 i = 0; i < tempCollection.collectionCount; i++) {
            tempIdList[i] = urlIdFromCollection[_collectionId][i];
        }
        tempDegen.unlockCosmetics(
            cosmeticAddress,
            _degenId,
            tempCollection.layerType,
            tempCollection.collectionCount,
            tempIdList
        );
        degenUnlockedCollections[_degenId][_collectionId] = true;
        emit collectionUnlocked(_degenId, _collectionId);
    }

    function setDegenAddress(address _degenAddress) external {
        require(msg.sender == owner, "only owner");
        degenAddress = _degenAddress;
    }

    function setCosmeticAddress(address _cosmeticAddress) external {
        require(msg.sender == owner, "only owner");
        cosmeticAddress = _cosmeticAddress;
    }

    function withdraw() external {
        require(msg.sender == owner, "Not owner");
        owner.transfer(address(this).balance);
    }

    function unlockFreeCosmetics() external {
        require(msg.sender == owner, "only owner");
        MythDegen tempDegen = MythDegen(degenAddress);
        uint256[10] memory tempBackgrounds;
        tempBackgrounds[0] = 1;
        tempBackgrounds[1] = 2;
        tempBackgrounds[2] = 3;
        tempBackgrounds[3] = 4;
        tempBackgrounds[4] = 5;
        tempBackgrounds[5] = 6;
        tempDegen.setFreeCosmetics(0, 6, tempBackgrounds);
        uint256[10] memory tmpEyes;
        tmpEyes[0] = 1;
        tmpEyes[1] = 30;
        tmpEyes[2] = 25;
        tmpEyes[3] = 6;
        tmpEyes[4] = 8;
        tmpEyes[5] = 11;
        tmpEyes[6] = 12;
        tmpEyes[7] = 15;
        tmpEyes[8] = 20;
        tmpEyes[9] = 21;
        tempDegen.setFreeCosmetics(1, 10, tmpEyes);
        uint256[10] memory tmpMouth;
        tmpMouth[0] = 1;
        tmpMouth[1] = 2;
        tmpMouth[2] = 3;
        tmpMouth[3] = 4;
        tmpMouth[4] = 5;
        tmpMouth[5] = 6;
        tmpMouth[6] = 7;
        tmpMouth[7] = 8;
        tmpMouth[8] = 9;
        tmpMouth[9] = 10;
        tempDegen.setFreeCosmetics(2, 10, tmpMouth);
        uint256[10] memory tmpNose;
        tmpNose[0] = 1;
        tmpNose[1] = 2;
        tmpNose[2] = 3;
        tempDegen.setFreeCosmetics(3, 3, tmpNose);
        uint256[10] memory tmpBodyColor;
        tmpBodyColor[0] = 1;
        tmpBodyColor[1] = 2;
        tmpBodyColor[2] = 3;
        tmpBodyColor[3] = 4;
        tmpBodyColor[4] = 5;
        tmpBodyColor[5] = 6;
        tempDegen.setFreeCosmetics(4, 6, tmpBodyColor);
        uint256[10] memory tempBody;
        tempBody[0] = 112;
        tempBody[1] = 113;
        tempBody[2] = 114;
        tempBody[3] = 115;
        tempBody[4] = 116;
        tempBody[5] = 117;
        tempBody[6] = 118;
        tempDegen.setFreeCosmetics(5, 7, tempBody);
        uint256[10] memory tempHead;
        tempHead[0] = 113;
        tempHead[1] = 114;
        tempHead[2] = 115;
        tempHead[3] = 116;
        tempHead[4] = 117;
        tempHead[5] = 118;
        tempHead[6] = 119;
        tempDegen.setFreeCosmetics(6, 7, tempHead);
    }
}

contract MythDegenMintShop {
    address payable public owner;
    address public degenAddress;

    constructor() {
        owner = payable(msg.sender);
    }

    function setDegenAddress(address _degenAddress) external {
        require(msg.sender == owner, "only owner");
        degenAddress = _degenAddress;
    }

    function withdraw() external {
        require(msg.sender == owner, "Not owner");
        owner.transfer(address(this).balance);
    }

    function mintDegen() external payable {
        require(msg.value == 5 * 10**16);
        MythDegen tempDegen = MythDegen(degenAddress);
        tempDegen.mint(msg.sender, 5000, 10);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "IERC20.sol";
import "IERC20Metadata.sol";
import "Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "IERC721.sol";
import "IERC721Receiver.sol";
import "IERC721Metadata.sol";
import "Address.sol";
import "Context.sol";
import "Strings.sol";
import "ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}