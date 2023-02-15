// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "./GasRestrictor.sol";
import "./Gamification.sol";
import "./WalletRegistry.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract SubscriptionModule is Initializable, OwnableUpgradeable {
    // uint256 public chainId;
    uint256 public defaultCredits;
    uint256 public renewalPeriod;
    GasRestrictor public gasRestrictor;
    Gamification public gamification;
    WalletRegistry public walletRegistry;
    // --------------------- DAPPS STORAGE -----------------------

    struct Dapp {
        string appName;
        bytes32 appId;
        address appAdmin; //primary
        string appUrl;
        string appIcon;
        string appSmallDescription;
        string appLargeDescription;
        string appCoverImage;
        string[] appScreenshots; // upto 5
        string[] appCategory; // upto 7
        string[] appTags; // upto 7
        string[] appSocial;
        bool isVerifiedDapp; // true or false
        uint256 credits;
        uint256 renewalTimestamp;    }

    struct Notification {
        bytes32 appID;
        address walletAddressTo; // primary
        string message;
        string buttonName;
        string cta;
        uint256 timestamp;
        bool isEncrypted;
    }

    struct List {
        uint256 listId;
        string listname;
    }

    mapping(bytes32 => mapping(uint256 => bool)) public isValidList;
    mapping(bytes32 => mapping(uint256 => uint256)) public listUserCount;
    mapping(bytes32 => uint256) public listsOfDappCount;
    mapping(bytes32 => mapping(uint256=> List)) public listsOfDapp;

    mapping(bytes32 => Dapp) public dapps;

    // all dapps count
    uint256 public dappsCount;
    uint256 public verifiedDappsCount;

    mapping(bytes32=>mapping(address=>bool)) hasPreviouslysubscribed;

    mapping(address => Notification[]) public notificationsOf;

    // dappId => count
    mapping(bytes32 => uint256) public notificationsCount;
    // dappId => listIndex => bool

    // dappId => count
    mapping(bytes32 => uint256) public subscriberCount;

    // user=>subscribeAppsCount
    mapping(address => uint256) public subscriberCountUser;
    mapping(address => uint256) public appCountUser;

    // account => dappId => role // 0 means no role, 1 meaning only notif, 2 meaning only add admin, 3 meaning both
    mapping(address => mapping(bytes32 => uint8)) public accountRole;

    // dappId =>list=> address => bool(true/false)
    mapping(bytes32 => mapping(uint256 => mapping(address => bool)))
        public isSubscribed;

    bytes32 public constant EIP712_DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 public constant SUBSC_PERMIT_TYPEHASH =
        keccak256(
            "SubscPermit(address user,bytes32 appID,bool subscriptionStatus,uint256 nonce,uint256 deadline)"
        );
    bytes32 public DOMAIN_SEPARATOR;
    // bytes32 public DOMAIN_SEPARATOR = keccak256(abi.encode(
    //     EIP712_DOMAIN_TYPEHASH,
    //     keccak256(bytes("Dapps")),
    //     keccak256(bytes("1")),
    //     chainId,
    //     address(this)
    // ));

    mapping(address => uint256) public nonce;

    uint256 public noOfSubscribers;
    uint256 public noOfNotifications;

    // dappId => dapp contract address => status
    mapping(bytes32 => mapping(address => bool)) public registeredDappContracts;
    
    // to keep a count of contracts that are using our sdk
    uint256 public regDappContractsCount;

    modifier onlySuperAdmin() {
        _onlySuperAdmin();
        _;
    }
    modifier isValidSenderOrRegDappContract(address from, bytes32 dappId) {
        _isValidSenderOrRegDappContract(from, dappId);
        _;
    }

    modifier superAdminOrDappAdmin(bytes32 appID) {
        _superAdminOrDappAdmin(appID);
        _;
    }

    modifier superAdminOrDappAdminOrAddedAdmin(bytes32 appID) {
        _superAdminOrDappAdminOrAddedAdmin(appID);
        _;
    }

    modifier superAdminOrDappAdminOrSendNotifRoleOrRegDappContract(bytes32 appID) {
        _superAdminOrDappAdminOrSendNotifRoleOrRegDappContract(appID);
        _;
    }

    modifier GasNotZero(address user, bool isOauthUser) {
        _gasNotZero(user, isOauthUser);
        _;
    }

    // modifier isRegisteredDappContract(
    //     bytes32 _dappId
    // ) {
    //     require(registeredDappContracts[_dappId][_msgSender()], "UNREGISTERED");
    //     _;
    // }

    event NewAppRegistered(
        bytes32 appID,
        address appAdmin,
        string appName,
        uint256 dappCount
    );

    event AppUpdated(bytes32 appID);

    event AppRemoved(bytes32 appID, uint256 dappCount);

    event AppAdmin(bytes32 appID, address appAdmin, address admin, uint8 role);

    event AppSubscribed(
        bytes32 appID,
        address subscriber,
        uint256 count,
        uint256 totalCount
    );

    event ListCreated(bytes32 appID, uint256 listId);

    event AppUnSubscribed(
        bytes32 appID,
        address subscriber,
        uint256 count,
        uint256 totalCount
    );

    event UserMovedFromList(
        bytes32 appID,
        address user,
        uint256 listIdFrom,
        uint256 listIdTo
    );
    event UserAddedToList(
        bytes32 appID,
        address user,
        uint256 listIdTo
    );
    event UserRemovedFromList(
        bytes32 appID,
        address user,
        uint256 listIdTo
    );

    event NewNotification(
        bytes32 appId,
        address walletAddress,
        string message,
        string buttonName,
        string cta,
        bool isEncrypted,
        uint256 count,
        uint256 totalCount
    );

    function __subscription_init(
        uint256 _defaultCredits,
        uint256 _renewalPeriod,
        address _trustedForwarder,
        WalletRegistry _wallet
    ) public initializer {
        walletRegistry = _wallet;
        defaultCredits = _defaultCredits;
        renewalPeriod = _renewalPeriod;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes("Dapps")),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
        __Ownable_init(_trustedForwarder);
    }

    function _onlySuperAdmin() internal view {
        require(
            _msgSender() == owner() ||
                _msgSender() == getSecondaryWalletAccount(owner()),
            "INVALID_SENDER"
        );
    }

    function _superAdminOrDappAdmin(bytes32 _appID) internal view {
        address appAdmin = getDappAdmin(_appID);
        require(
            _msgSender() == owner() ||
                _msgSender() == getSecondaryWalletAccount(owner()) ||
                _msgSender() == appAdmin ||
                _msgSender() == getSecondaryWalletAccount(appAdmin),
            "INVALID_SENDER"
        );
    }

    // function _superAdminOrDappAdminOrSendNotifRole(bytes32 _appID)
    //     internal
    //     view
    // {
    //     address appAdmin = getDappAdmin(_appID);
    //     require(
    //         _msgSender() == owner() ||
    //             _msgSender() == getSecondaryWalletAccount(owner()) ||
    //             _msgSender() == appAdmin ||
    //             _msgSender() == getSecondaryWalletAccount(appAdmin) ||
    //             accountRole[_msgSender()][_appID] == 1 ||
    //             accountRole[_msgSender()][_appID] == 3,
    //         "INVALID_SENDER"
    //     );
    // }

    function _superAdminOrDappAdminOrSendNotifRoleOrRegDappContract(bytes32 _appID)
        internal
        view
    {
        address appAdmin = getDappAdmin(_appID);
        require(
            _msgSender() == owner() ||
                _msgSender() == getSecondaryWalletAccount(owner()) ||
                _msgSender() == appAdmin ||
                _msgSender() == getSecondaryWalletAccount(appAdmin) ||
                accountRole[_msgSender()][_appID] == 1 ||
                accountRole[_msgSender()][_appID] == 3 ||
                registeredDappContracts[_appID][_msgSender()],
            "INVALID_SENDER"
        );
    }

    function _superAdminOrDappAdminOrAddedAdmin(bytes32 _appID) internal view {
        address appAdmin = getDappAdmin(_appID);
        require(
            _msgSender() == owner() ||
                _msgSender() == getSecondaryWalletAccount(owner()) ||
                _msgSender() == appAdmin ||
                _msgSender() == getSecondaryWalletAccount(appAdmin) ||
                accountRole[_msgSender()][_appID] == 2 ||
                accountRole[_msgSender()][_appID] == 3,
            "INVALID_SENDER"
        );
    }

    function _isValidSenderOrRegDappContract(address _from, bytes32 _dappId) internal view {
        require(
            _msgSender() == _from ||
                _msgSender() == getSecondaryWalletAccount(_from) ||
                registeredDappContracts[_dappId][_msgSender()],
            "INVALID_SENDER"
        );
    }

    function addGasRestrictorAndGamification(
        GasRestrictor _gasRestrictor,
        Gamification _gamification
    ) external onlyOwner {
        gasRestrictor = _gasRestrictor;
        gamification = _gamification;
    }

    function _gasNotZero(address user, bool isOauthUser) internal view {
        if (isTrustedForwarder[msg.sender]) {
            if (!isOauthUser) {
                if (getPrimaryFromSecondary(user) == address(0)) {} else {
                    (, , uint256 u) = gasRestrictor.gaslessData(
                        getPrimaryFromSecondary(user)
                    );
                    require(u != 0, "0_GASBALANCE");
                }
            } else {
                (, , uint256 u) = gasRestrictor.gaslessData(user);
                require(u != 0, "0_GASBALANCE");
            }
        }
    }

    // -------------------- DAPP FUNCTIONS ------------------------

    // function addNewDapp(
    //     string memory _appName,
    //     address _appAdmin, //primary
    //     string memory _appUrl,
    //     string memory _appIcon,
    //     string memory _appCoverImage,
    //     string memory _appSmallDescription,
    //     string memory _appLargeDescription,
    //     string[] memory _appScreenshots,
    //     string[] memory _appCategory,
    //     string[] memory _appTags,
    //     string[] memory _appSocial,
    //     bool isOauthUser
    // ) external GasNotZero(_msgSender(), isOauthUser) {
    //     uint256 gasLeftInit = gasleft();
    //     require(_appAdmin != address(0), "ADMIN CAN'T BE 0 ADDRESS");
    //     require(_appScreenshots.length < 6, "SURPASSED IMAGE LIMIT");
    //     require(_appCategory.length < 8, "SURPASSED CATEGORY LIMIT");
    //     require(_appTags.length < 8, "SURPASSED TAG LIMIT");

    //     checkFirstApp();
    //     _addNewDapp(
    //         _appName,
    //         _appAdmin,
    //         _appUrl,
    //         _appIcon,
    //         _appCoverImage,
    //         _appSmallDescription,
    //         _appLargeDescription,
    //         _appScreenshots,
    //         _appCategory,
    //         _appTags,
    //         _appSocial
    //     );

    //     _updateGaslessData(gasLeftInit);
    // }

    // function _addNewDapp(
    //     string memory _appName,
    //     address _appAdmin, //primary
    //     string memory _appUrl,
    //     string memory _appIcon,
    //     string memory _appCoverImage,
    //     string memory _appSmallDescription,
    //     string memory _appLargeDescription,
    //     string[] memory _appScreenshots,
    //     string[] memory _appCategory,
    //     string[] memory _appTags,
    //     string[] memory _appSocial
    // ) internal {
    //     bytes32 _appID;
    //     Dapp memory dapp = Dapp({
    //         appName: _appName,
    //         appId: _appID,
    //         appAdmin: _appAdmin,
    //         appUrl: _appUrl,
    //         appIcon: _appIcon,
    //         appCoverImage: _appCoverImage,
    //         appSmallDescription: _appSmallDescription,
    //         appLargeDescription: _appLargeDescription,
    //         appScreenshots: _appScreenshots,
    //         appCategory: _appCategory,
    //         appTags: _appTags,
    //         appSocial: _appSocial,
    //         isVerifiedDapp: false,
    //         credits: defaultCredits,
    //         renewalTimestamp: block.timestamp  });
    //     _appID = keccak256(
    //         abi.encode(
    //             dapp,
    //             block.number,
    //             _msgSender(),
    //             dappsCount,
    //             block.chainid
    //         )
    //     );
    //     dapp.appId = _appID;

    //     dapps[_appID] = dapp;
    //     isValidList[_appID][listsOfDappCount[_appID]++] = true;
    //     emit NewAppRegistered(_appID, _appAdmin, _appName, ++dappsCount);
    // }

    function addNewDapp(
        Dapp memory _dapp,
        bool isOauthUser
    ) external GasNotZero(_msgSender(), isOauthUser) {
        uint256 gasLeftInit = gasleft();
        require(_dapp.appAdmin != address(0), "ADMIN CAN'T BE 0 ADDRESS");
        require(_dapp.appScreenshots.length < 6, "SURPASSED IMAGE LIMIT");
        require(_dapp.appCategory.length < 8, "SURPASSED CATEGORY LIMIT");
        require(_dapp.appTags.length < 8, "SURPASSED TAG LIMIT");

        checkFirstApp();
        _addNewDapp(
            _dapp,
            false
        );

        _updateGaslessData(gasLeftInit);
    }

    function _addNewDapp(
        Dapp memory _dapp,
        bool _isAdmin
    ) internal {
        bytes32 _appID;
        Dapp memory dapp = Dapp({
            appName: _dapp.appName,
            appId: _appID,
            appAdmin: _dapp.appAdmin,
            appUrl: _dapp.appUrl,
            appIcon: _dapp.appIcon,
            appCoverImage: _dapp.appCoverImage,
            appSmallDescription: _dapp.appSmallDescription,
            appLargeDescription: _dapp.appLargeDescription,
            appScreenshots: _dapp.appScreenshots,
            appCategory: _dapp.appCategory,
            appTags: _dapp.appTags,
            appSocial: _dapp.appSocial,
            isVerifiedDapp: false,
            credits: defaultCredits,
            renewalTimestamp: block.timestamp
        });
        if(!_isAdmin)
            _appID = keccak256(
                abi.encode(dapp, block.number, _msgSender(), dappsCount, block.chainid)
            );
        else
            _appID = _dapp.appId;
        dapp.appId = _appID;

        dapps[_appID] = dapp;
        isValidList[_appID][listsOfDappCount[_appID]++] = true;
        emit NewAppRegistered(_appID, _dapp.appAdmin, _dapp.appName, ++dappsCount);
    }

    function addNewDappOnNewChain(
        Dapp memory _dapp
    ) external onlySuperAdmin {
        // uint256 gasLeftInit = gasleft();
        require(_dapp.appAdmin != address(0), "ADMIN CAN'T BE 0 ADDRESS");
        require(_dapp.appScreenshots.length < 6, "SURPASSED IMAGE LIMIT");
        require(_dapp.appCategory.length < 8, "SURPASSED CATEGORY LIMIT");
        require(_dapp.appTags.length < 8, "SURPASSED TAG LIMIT");
        require(_dapp.appId != "", "INVALID_APP_ID");
        // checkFirstApp();
        _addNewDapp(
            _dapp,
            true
        );

        // _updateGaslessData(gasLeftInit);
    }

    function checkFirstApp() internal {
        address primary = getPrimaryFromSecondary(_msgSender());
        if (primary != address(0)) {
            if (appCountUser[primary] == 0) {
                // add 5 karma points of primarywallet
                gamification.addKarmaPoints(primary, 5);
            }
            appCountUser[primary]++;
        } else {
            if (appCountUser[_msgSender()] == 0) {
                // add 5 karma points of _msgSender()
                gamification.addKarmaPoints(_msgSender(), 5);
            }
            appCountUser[_msgSender()]++;
        }
    }

    function changeDappAdmin(
        bytes32 _appId,
        address _newAdmin,
        bool isOauthUser
    )
        external
        superAdminOrDappAdmin(_appId)
        GasNotZero(_msgSender(), isOauthUser)
    {
        uint256 gasLeftInit = gasleft();

        require(dapps[_appId].appAdmin != address(0), "INVALID_DAPP");
        require(_newAdmin != address(0), "INVALID_OWNER");
        dapps[_appId].appAdmin = _newAdmin;

        // if (msg.sender == trustedForwarder)
        //     gasRestrictor._updateGaslessData(_msgSender(), gasLeftInit);
        _updateGaslessData(gasLeftInit);
    }

    function updateDapp(
        bytes32 _appId,
        string memory _appName,
        string memory _appUrl,
        string[] memory _appImages, // [icon, cover_image]
        // string memory _appSmallDescription,
        // string memory _appLargeDescription,
        string[] memory _appDesc, // [small_desc, large_desc]
        string[] memory _appScreenshots,
        string[] memory _appCategory,
        string[] memory _appTags,
        string[] memory _appSocial, // [twitter_url]
        bool isOauthUser
    )
        external
        superAdminOrDappAdminOrAddedAdmin(_appId)
        GasNotZero(_msgSender(), isOauthUser)
    {
        uint256 gasLeftInit = gasleft();

        require(_appImages.length == 2, "IMG_LIMIT_EXCEED");
        require(_appScreenshots.length < 6, "SS_LIMIT_EXCEED");
        require(_appCategory.length < 8, "CAT_LIMIT_EXCEED");
        require(_appTags.length < 8, "TAG_LIMIT_EXCEED");
        require(_appDesc.length == 2, "DESC_LIMIT_EXCEED");

        // _updateDappTextInfo(_appId, _appName, _appUrl, _appSmallDescription, _appLargeDescription, _appCategory, _appTags, _appSocial);
        _updateDappTextInfo(
            _appId,
            _appName,
            _appUrl,
            _appDesc,
            _appCategory,
            _appTags,
            _appSocial
        );
        _updateDappImageInfo(_appId, _appImages, _appScreenshots);

        // if(isTrustedForwarder(msg.sender)) {
        //     gasRestrictor._updateGaslessData(_msgSender(), gasLeftInit);
        // }
        _updateGaslessData(gasLeftInit);
    }

    function _updateDappTextInfo(
        bytes32 _appId,
        string memory _appName,
        string memory _appUrl,
        // string memory _appSmallDescription,
        // string memory _appLargeDescription,
        string[] memory _appDesc,
        string[] memory _appCategory,
        string[] memory _appTags,
        string[] memory _appSocial
    ) internal {
        Dapp storage dapp = dapps[_appId];
        require(dapp.appAdmin != address(0), "INVALID_DAPP");
        if (bytes(_appName).length != 0) dapp.appName = _appName;
        if (bytes(_appUrl).length != 0) dapp.appUrl = _appUrl;
        if (bytes(_appDesc[0]).length != 0)
            dapp.appSmallDescription = _appDesc[0];
        if (bytes(_appDesc[1]).length != 0)
            dapp.appLargeDescription = _appDesc[1];
        // if(_appCategory.length != 0)
        dapp.appCategory = _appCategory;
        // if(_appTags.length != 0)
        dapp.appTags = _appTags;
        // if(_appSocial.length != 0)
        dapp.appSocial = _appSocial;
    }

    function _updateDappImageInfo(
        bytes32 _appId,
        string[] memory _appImages,
        string[] memory _appScreenshots
    ) internal {
        Dapp storage dapp = dapps[_appId];
        // if(bytes(_appImages[0]).length != 0)
        dapp.appIcon = _appImages[0];
        // if(bytes(_appImages[1]).length != 0)
        dapp.appCoverImage = _appImages[1];
        // if(_appScreenshots.length != 0)
        dapp.appScreenshots = _appScreenshots;

        emit AppUpdated(_appId);
    }

    function removeDapp(bytes32 _appId, bool isOauthUser)
        external
        superAdminOrDappAdmin(_appId)
        GasNotZero(_msgSender(), isOauthUser)
    {
        uint256 gasLeftInit = gasleft();

        require(dapps[_appId].appAdmin != address(0), "INVALID_DAPP");
        if (dapps[_appId].isVerifiedDapp) --verifiedDappsCount;
        delete dapps[_appId];
        --dappsCount;

        emit AppRemoved(_appId, dappsCount);

        _updateGaslessData(gasLeftInit);
    }

    function createDappList(
        bytes32 appId,
        string memory listName,
        bool isOauthUser
    )
        public
        GasNotZero(_msgSender(), isOauthUser)
        superAdminOrDappAdminOrAddedAdmin(appId)
    {
        uint id = listsOfDappCount[appId];
        isValidList[appId][id] = true;
        listsOfDapp[appId][id] =  List(id, listName);
        emit ListCreated(appId, listsOfDappCount[appId]++);

    }


    function addOrRemoveSubscriberToList(
        bytes32 appId, 
        address subscriber, 
        uint listID, 
        bool addOrRemove, 
        bool isOauthUser
    ) public GasNotZero(_msgSender(), isOauthUser) superAdminOrDappAdminOrAddedAdmin(appId) {
        
        require(isSubscribed[appId][0][subscriber] == true, "address not subscribed");
        require(isValidList[appId][listID] == true, "not valid list");

        isSubscribed[appId][listID][subscriber] = addOrRemove;

        if(addOrRemove) {
            listUserCount[appId][listID]++;
            emit UserAddedToList(appId, subscriber, listID);
        }
        else {
            listUserCount[appId][listID]--;
             emit UserRemovedFromList(appId, subscriber, listID);

        }
    }

    function updateRegDappContract(
        bytes32 _dappId,
        address _dappContractAddress,
        bool _status
    ) external superAdminOrDappAdmin(_dappId) {
        require(registeredDappContracts[_dappId][_dappContractAddress] != _status, "UNCHANGED");
        registeredDappContracts[_dappId][_dappContractAddress] = _status;
        if(_status)
            ++regDappContractsCount;
        else
            --regDappContractsCount;
    }

    // function subscribeToDappByContract(
    //     address user,
    //     bytes32 appID,
    //     bool subscriptionStatus,
    //     uint256[] memory _lists
    // ) external 
    // isRegisteredDappContract(appID)
    // {
    //     _subscribeToDappInternal(user, appID, subscriptionStatus, _lists);
    // }

    // function _subscribeToDappInternal(
    //     address user,
    //     bytes32 appID,
    //     bool subscriptionStatus,
    //     uint256[] memory _lists
    // ) internal {
    //     require(dapps[appID].appAdmin != address(0), "INVALID DAPP ID");

    //     if (_lists.length == 0) {
    //         require(
    //             isSubscribed[appID][0][user] != subscriptionStatus,
    //             "UNCHANGED"
    //         );
    //         _subscribeToDapp(user, appID, 0, subscriptionStatus);
    //     } else {
    //         if (isSubscribed[appID][0][user] == false) {
    //             _subscribeToDapp(user, appID, 0, true);
    //         }

    //         for (uint256 i = 0; i < _lists.length; i++) {
    //             _subscribeToDapp(user, appID, _lists[i], subscriptionStatus);
    //         }
    //     }
    // }

    function subscribeToDapp(
        address user,
        bytes32 appID,
        bool subscriptionStatus,
        bool isOauthUser,
        uint256[] memory _lists
    ) external 
    isValidSenderOrRegDappContract(user, appID) 
    GasNotZero(_msgSender(), isOauthUser) 
    {
        uint256 gasLeftInit = gasleft();
        require(dapps[appID].appAdmin != address(0), "INVALID DAPP ID");

        if (_lists.length == 0) {
            require(
                isSubscribed[appID][0][user] != subscriptionStatus,
                "UNCHANGED"
            );
            _subscribeToDapp(user, appID, 0, subscriptionStatus);
        } else {
            if (isSubscribed[appID][0][user] == false) {
                _subscribeToDapp(user, appID, 0, true);
            }

            for (uint256 i = 0; i < _lists.length; i++) {
                _subscribeToDapp(user, appID, _lists[i], subscriptionStatus);
            }
        }
        // _subscribeToDappInternal(user, appID, subscriptionStatus, _lists);

        _updateGaslessData(gasLeftInit);
    }

    function _subscribeToDapp(
        address user,
        bytes32 appID,
        uint256 listID,
        bool subscriptionStatus
    ) internal {
        require(isValidList[appID][listID] == true, "not valid list");
        isSubscribed[appID][listID][user] = subscriptionStatus;

        address appAdmin = dapps[appID].appAdmin;

        if (listID == 0) {
            if (subscriptionStatus) {

                if (dapps[appID].isVerifiedDapp && !hasPreviouslysubscribed[appID][user] && dapps[appID].credits != 0) {
                    string memory message; 
                    string memory cta; 
                    string memory butonN;
                  
                        (message, cta, butonN) = gamification.getWelcomeMessage(appID);

                    // (string memory message,string memory cta, string memory butonN) = gamification.welcomeMessage(appID);
                    _sendAppNotification(
                        appID,
                        user,
                        message,
                        butonN,
                        cta,
                        false
                    );
                    hasPreviouslysubscribed[appID][user] = true;

                }
                uint256 subCountUser = ++subscriberCountUser[user];
                uint256 subCountDapp = ++subscriberCount[appID];
                emit AppSubscribed(
                    appID,
                    user,
                    subCountDapp,
                    ++noOfSubscribers
                );
                listUserCount[appID][0]++;
                subscriberCountUser[user]++;

                if (subCountDapp == 100) {
                    // add 10 karma point to app admin

                    gamification.addKarmaPoints(appAdmin, 10);
                } else if (subCountDapp == 500) {
                    // add 50 karma point to app admin
                    gamification.addKarmaPoints(appAdmin, 50);
                } else if (subCountDapp == 1000) {
                    // add 100 karma point to app admin

                    gamification.addKarmaPoints(appAdmin, 100);
                }

                if (subCountUser == 0) {
                    // add 1 karma point to subscriber
                    gamification.addKarmaPoints(user, 1);
                } else if (subCountUser == 5) {
                    // add 5 karma points to subscriber
                    gamification.addKarmaPoints(user, 5);
                }
            } else {
                listUserCount[appID][0]--;

                uint256 subCountUser = --subscriberCountUser[user];
                emit AppUnSubscribed(
                    appID,
                    user,
                    --subscriberCount[appID],
                    --noOfSubscribers
                );
                if (subCountUser == 0) {
                    // remove 1 karma point to app admin
                    gamification.removeKarmaPoints(user, 1);
                } else if (subCountUser == 4) {
                    // remove 5 karma points to app admin
                    gamification.removeKarmaPoints(user, 5);
                }
                // if (subCountDapp == 99) {
                //     // remove 10 karma point
                //     gamification.removeKarmaPoints(dapps[appID].appAdmin, 10);
                // } else if (subCountDapp == 499) {
                //     // remove 50 karma point
                //     gamification.removeKarmaPoints(dapps[appID].appAdmin, 50);
                // } else if (subCountDapp == 999) {
                //     // remove 100 karma point
                //     gamification.removeKarmaPoints(dapps[appID].appAdmin, 100);
                // }
            }
        } else {
            if (subscriptionStatus) {
                listUserCount[appID][listID]++;
            } else {
                listUserCount[appID][listID]--;
            }
        }

        // if (address(0) != getSecondaryWalletAccount(user)) {
        //     isSubscribed[appID][
        //         getSecondaryWalletAccount(user)
        //     ] = subscriptionStatus;
        // }
    }

    // function subscribeToDapp(
    //     address user,
    //     bytes32 appID,
    //     bool subscriptionStatus
    // ) external onlyOwner {
    //     require(dapps[appID].appAdmin != address(0), "INVALID DAPP ID");
    //     require(isSubscribed[appID][user] != subscriptionStatus, "UNCHANGED");

    //     _subscribeToDapp(user, appID, subscriptionStatus);
    // }

    // function _subscribeToDapp(
    //     address user,
    //     bytes32 appID,
    //     bool subscriptionStatus
    // ) internal {
    //     isSubscribed[appID][user] = subscriptionStatus;

    //     if (subscriptionStatus)
    //         emit AppSubscribed(appID, user, ++subCountDapp, ++noOfSubscribers);
    //     else
    //         emit AppUnSubscribed(appID, user, --subCountDapp, --noOfSubscribers);

    //     if (address(0) != getSecondaryWalletAccount(user)) {
    //         isSubscribed[appID][
    //             getSecondaryWalletAccount(user)
    //         ] = subscriptionStatus;
    //     }
    // }

    // function subscribeWithPermit(
    //     address user,
    //     bytes32 appID,
    //     uint256[] memory _lists,
    //     bool subscriptionStatus,
    //     uint256 deadline,
    //     bytes32 r,
    //     bytes32 s,
    //     uint8 v
    // ) external {
    //     require(dapps[appID].appAdmin != address(0), "INVALID DAPP ID");
    //     // require(isSubscribed[appID][user] != subscriptionStatus, "UNCHANGED");

    //     require(user != address(0), "ZERO_ADDRESS");
    //     require(deadline >= block.timestamp, "EXPIRED");

    //     bytes32 digest = keccak256(
    //         abi.encodePacked(
    //             "\x19\x01",
    //             DOMAIN_SEPARATOR,
    //             keccak256(
    //                 abi.encode(
    //                     SUBSC_PERMIT_TYPEHASH,
    //                     user,
    //                     appID,
    //                     subscriptionStatus,
    //                     nonce[user]++,
    //                     deadline
    //                 )
    //             )
    //         )
    //     );

    //     address recoveredUser = ecrecover(digest, v, r, s);
    //     require(
    //         recoveredUser != address(0) &&
    //             (recoveredUser == user ||
    //                 recoveredUser == getSecondaryWalletAccount(user)),
    //         "INVALID_SIGN"
    //     );

    //     if (_lists.length == 0) {
    //         require(
    //             isSubscribed[appID][0][user] != subscriptionStatus,
    //             "UNCHANGED"
    //         );
    //         _subscribeToDapp(user, appID, 0, subscriptionStatus);
    //     } else {
    //         if (isSubscribed[appID][0][user] == false) {
    //             _subscribeToDapp(user, appID, 0, true);
    //         }

    //         for (uint256 i = 0; i < _lists.length; i++) {
    //             _subscribeToDapp(user, appID, _lists[i], subscriptionStatus);
    //         }
    //     }
    // }

    function appVerification(
        bytes32 appID,
        bool verificationStatus,
        bool isOauthUser
    ) external GasNotZero(_msgSender(), isOauthUser) onlySuperAdmin {
        uint256 gasLeftInit = gasleft();

        require(dapps[appID].appAdmin != address(0), "INVALID DAPP ID");
        // require(appID < dappsCount, "INVALID DAPP ID");
        if (
            dapps[appID].isVerifiedDapp != verificationStatus &&
            verificationStatus
        ) {
            verifiedDappsCount++;
            dapps[appID].isVerifiedDapp = verificationStatus;
        } else if (
            dapps[appID].isVerifiedDapp != verificationStatus &&
            !verificationStatus
        ) {
            verifiedDappsCount--;
            dapps[appID].isVerifiedDapp = verificationStatus;
        }

        _updateGaslessData(gasLeftInit);
    }

    function getDappAdmin(bytes32 _dappId) public view returns (address) {
        return dapps[_dappId].appAdmin;
    }

    // -------------------- WALLET FUNCTIONS -----------------------
    function addAccountsRole(
        bytes32 appId,
        address account, // primary address
        uint8 _role, // 0 means no role, 1 meaning only notif, 2 meaning only add admin, 3 meaning both
        bool isOauthUser
    )
        external
        superAdminOrDappAdminOrAddedAdmin(appId)
        GasNotZero(_msgSender(), isOauthUser)
    {
        uint256 gasLeftInit = gasleft();

        require(dapps[appId].appAdmin != address(0), "INVALID DAPP ID");
        require(dapps[appId].appAdmin != account, "IS_SUPERADMIN");
        require(_role < 4, "INVALID_ROLE");
        require(_role != accountRole[account][appId], "SAME_ROLE");

        accountRole[account][appId] = _role;
        accountRole[getSecondaryWalletAccount(account)][appId] = _role;

        emit AppAdmin(appId, getDappAdmin(appId), account, _role);

        _updateGaslessData(gasLeftInit);
    }

    // primary wallet address.
    function sendAppNotification(
        bytes32 _appId,
        address walletAddress,
        string memory _message,
        string memory buttonName,
        string memory _cta,
        bool _isEncrypted,
        bool isOauthUser
    )
        external
        superAdminOrDappAdminOrSendNotifRoleOrRegDappContract(_appId)
        GasNotZero(_msgSender(), isOauthUser)
    {
        uint256 gasLeftInit = gasleft();

        require(dapps[_appId].appAdmin != address(0), "INVALID DAPP ID");
        require(dapps[_appId].credits != 0, "0_CREDITS");
        require(
            isSubscribed[_appId][0][walletAddress] == true,
            "NOT_SUBSCRIBED"
        );

        if (notificationsOf[walletAddress].length == 0) {
            // add 1 karma point
            gamification.addKarmaPoints(walletAddress, 1);
        }

        _sendAppNotification(
            _appId,
            walletAddress,
            _message,
            buttonName,
            _cta,
            _isEncrypted
        );

        _updateGaslessData(gasLeftInit);
    }

    function _sendAppNotification(
        bytes32 _appId,
        address walletAddress,
        string memory _message,
        string memory buttonName,
        string memory _cta,
        bool _isEncrypted
    ) internal {
        Notification memory notif = Notification({
            appID: _appId,
            walletAddressTo: walletAddress,
            message: _message,
            buttonName: buttonName,
            cta: _cta,
            timestamp: block.timestamp,
            isEncrypted: _isEncrypted
        });

        notificationsOf[walletAddress].push(notif);

        emit NewNotification(
            _appId,
            walletAddress,
            _message,
            buttonName,
            _cta,
            _isEncrypted,
            ++notificationsCount[_appId],
            ++noOfNotifications
        );
        --dapps[_appId].credits;
    }

    // // primary wallet address.
    // function sendAppNotification(
    //     bytes32 _appId,
    //     address walletAddress,
    //     string memory _message,
    //     string memory buttonName,
    //     string memory _cta,
    //     bool _isEncrypted
    // ) external onlyOwner {
    //     require(dapps[_appId].appAdmin != address(0), "INVALID DAPP ID");
    //     require(dapps[_appId].credits != 0, "NOT_ENOUGH_CREDITS");
    //     // require(isSubscribed[_appId][walletAddress] == true, "NOT_SUBSCRIBED");

    //     _sendAppNotification(_appId, walletAddress, _message, buttonName, _cta, _isEncrypted);
    // }

    // function _sendAppNotification(
    //     bytes32 _appId,
    //     address walletAddress,
    //     string memory _message,
    //     string memory buttonName,
    //     string memory _cta,
    //     bool _isEncrypted
    // ) internal {
    //     Notification memory notif = Notification({
    //         appID: _appId,
    //         walletAddressTo: walletAddress,
    //         message: _message,
    //         buttonName: buttonName,
    //         cta: _cta,
    //         timestamp: block.timestamp,
    //         isEncrypted: _isEncrypted
    //     });

    //     notificationsOf[walletAddress].push(notif);

    //     emit NewNotification(
    //         _appId,
    //         walletAddress,
    //         _message,
    //         buttonName,
    //         _cta,
    //         _isEncrypted,
    //         ++notificationsCount[_appId],
    //         ++noOfNotifications
    //     );
    //     --dapps[_appId].credits;
    // }

    function getNotificationsOf(address user)
        external
        view
        returns (Notification[] memory)
    {
        return notificationsOf[user];
    }

    function getSecondaryWalletAccount(address _account)
        public
        view
        returns (address)
    {
        (address account, , ) = walletRegistry.userWallets(_account);

        return account;
    }

    function getPrimaryFromSecondary(address _account)
        public
        view
        returns (address)
    {
        return walletRegistry.getPrimaryFromSecondary(_account);
    }

    function getDapp(bytes32 dappId) public view returns (Dapp memory) {
        return dapps[dappId];
    }

    // function upgradeCreditsByAdmin( bytes32 dappId,uint amount ) external onlySuperAdmin() {
    //     dapps[dappId].credits = defaultCredits + amount;
    // }

    // function renewCredits(bytes32 dappId, bool isOauthUser)
    //     external
    //     superAdminOrDappAdminOrAddedAdmin(dappId)
    //     GasNotZero(_msgSender(), isOauthUser)
    // {
    //     uint256 gasLeftInit = gasleft();

    //     require(dapps[dappId].appAdmin != address(0), "INVALID_DAPP");
    //     require(
    //         block.timestamp - dapps[dappId].renewalTimestamp == renewalPeriod,
    //         "RPNC"
    //     ); // RENEWAL_PERIOD_NOT_COMPLETED
    //     dapps[dappId].credits = defaultCredits;

    //     _updateGaslessData(gasLeftInit);
    // }

    // function deleteWallet(address _account) external onlySuperAdmin {
    //     require(userWallets[_msgSender()].account != address(0), "NO_ACCOUNT");
    //     delete userWallets[_account];
    //     delete getPrimaryFromSecondary[_account];
    // }
    // ------------------------ TELEGRAM FUNCTIONS -----------------------------------

    // function getTelegramChatID(address userWallet) public view returns (string memory) {
    //     return telegramChatID[userWallet];
    // }

    // function setDomainSeparator() external onlyOwner {
    //     DOMAIN_SEPARATOR = keccak256(abi.encode(
    //         EIP712_DOMAIN_TYPEHASH,
    //         keccak256(bytes("Dapps")),
    //         keccak256(bytes("1")),
    //         chainId,
    //         address(this)
    //     ));
    // }

    function _updateGaslessData(uint256 _gasLeftInit) internal {
        if (isTrustedForwarder[msg.sender]) {
            gasRestrictor._updateGaslessData(_msgSender(), _gasLeftInit);
        }
    }

    //    function createWallet(
    //     address _account,
    //     string calldata _encPvtKey,
    //     string calldata _publicKey,
    //     string calldata oAuthEncryptedUserId,
    //     bool isOauthUser,
    //     address referer
    // ) external {

    // }

    // function userWallets(address _account)
    //     public
    //     view
    //     returns (address, string memory, string memory)
    // {
    //    (address account, string memory encPvKey,string memory pubKey) =  walletRegistry.userWallets(_account);

    //    return (account, encPvKey,pubKey );
    // }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./OwnableUpgradeable.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// import {UnifarmAccountsUpgradeable} from "./UnifarmAccountsUpgradeable.sol";
import "./SubscriptionModule.sol";
contract GasRestrictor is Initializable, OwnableUpgradeable {
    uint256 public initialGasLimitInNativeCrypto; // i.e matic etc
    SubscriptionModule public subscriptionModule;
    struct GaslessData {
        address userSecondaryAddress;
        address userPrimaryAddress;
        uint256 gasBalanceInNativeCrypto;
    }

    // primary to gaslessData
    mapping(address => GaslessData) public gaslessData;

// mapping of contract address who are allowed to do changes
    mapping(address=>bool) public isDappsContract;

    
      modifier isDapp(address dapp) {
      
        require(
                isDappsContract[dapp] == true,
                "Not_registred_dapp"
        );
          _;

        
    }
   
    function init_Gasless_Restrictor(
        address _subscriptionModule,
        uint256 _gaslimit,
        address _trustedForwarder
    ) public initializer {
        initialGasLimitInNativeCrypto = _gaslimit;
        subscriptionModule = SubscriptionModule(_subscriptionModule);
        isDappsContract[_subscriptionModule] = true;
        __Ownable_init(_trustedForwarder);

    }
    

    function updateInitialGasLimit(uint256 _gaslimit) public onlyOwner {
        initialGasLimitInNativeCrypto = _gaslimit;
    }

    function getGaslessData(address _user) view virtual external returns(GaslessData memory) {
      return  gaslessData[_user];
    }

    function initUser(address primary, address secondary, bool isOauthUser) external isDapp(msg.sender){
        if(isOauthUser) {
        gaslessData[secondary].gasBalanceInNativeCrypto = initialGasLimitInNativeCrypto;
        gaslessData[secondary].userSecondaryAddress = secondary;
        }
        else {
        gaslessData[primary].gasBalanceInNativeCrypto = initialGasLimitInNativeCrypto;
        gaslessData[primary].userPrimaryAddress = primary;
        gaslessData[primary].userSecondaryAddress = secondary;
        }
      
    }

    function _updateGaslessData(address user, uint initialGasLeft) external isDapp(msg.sender){
      address primary = subscriptionModule.getPrimaryFromSecondary(user);
        if (primary == address(0)) {
            return;
        } else {
            gaslessData[primary].gasBalanceInNativeCrypto =
                gaslessData[primary].gasBalanceInNativeCrypto -
                (initialGasLeft - gasleft()) *
                tx.gasprice;
         
        }
    }

   function addDapp(address dapp) external onlyOwner {
    isDappsContract[dapp] = true;
   }

    function addGas(address userPrimaryAddress) external payable{ 
      require(msg.value> 0 , "gas should be more than 0");
      gaslessData[userPrimaryAddress].gasBalanceInNativeCrypto =   gaslessData[userPrimaryAddress].gasBalanceInNativeCrypto + msg.value;

    }

     function withdrawGasFunds(uint amount, address to) external onlyOwner {
     require(amount <= address(this).balance);
      payable(to).transfer(amount);
    }

    
}

// import "./sdkInterFace/subscriptionModulesI.sol";
import "./OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./SubscriptionModule.sol";

contract Gamification is Initializable, OwnableUpgradeable {
 
    struct Reaction {
        string reactionName;
        uint256 count;
    }

    struct EbookDetails {
        string title;
        string summary;
        string assetFile;
        string assetSampleFile;
        string coverImage;
        bool isSendNotif;
        bool isShowApp;
        string aboutCompany;
        string aboutImage;
    }

    struct Message {
        address sender;
        bytes32 senderDappID; // encrypted using receiver's public key
        bytes32 receiverDappId;
        string textMessageEncryptedForReceiver; // encrypted using sender's public key
        string textMessageEncryptedForSender; // encrypted using sender's public key
        uint256 timestamp;
    }


    struct WelcomeMessage {
        string message;
        string cta;
        string buttonName;
    }

    struct EbookMessage {
        string message;
        string cta;
        string buttonName;
    }

    struct Token {
        bytes32 appId;
        address _tokenAddress;
        uint256 _tokenType; // ERC20, ERC721 (20, 721)
    }

    struct TokenNotif {
        bytes32 _id;
        string message;
        uint256 reactionCounts;
        address _token;
    }
    mapping(bytes32 => EbookMessage) public ebookMessage;
    mapping(bytes32 => WelcomeMessage) public welcomeMessage;

    // dappId => ebook
    mapping(bytes32 => EbookDetails) public ebooks;

    // from -> to -> messageID
    mapping(bytes32 => mapping(bytes32 => uint256)) public messageIdOfDapps; //
    uint256 public messageIdCount;
    mapping(uint256 => Message[]) public messages;

    mapping(address => bool) public isDappsContract;
    GasRestrictor public gasRestrictor;

    SubscriptionModule public subscriptionModule;

    mapping(address => uint256) public karmaPoints;
    //tokenNotifID => tokenNotif
    mapping(bytes32 => TokenNotif) public singleTokenNotif;
    // tokenNotifId=>react=>count
    mapping(bytes32 => mapping(string => uint256))
        public reactionsOfTokenNotifs;
    // tokenNotifId => user => reactionStatus;
    mapping(bytes32 => mapping(address => bool)) public reactionStatus;

    // string ReactionName => isValid bool
    mapping(string => bool) public isValidReaction;

    // appId => Tokens
    mapping(bytes32 => Token[]) public tokenOfVerifiedApp;
    // tokenAddress => tokenDetails
    mapping(address => Token) public tokenByTokenAddress;

    event NewTokenNotif(bytes32 appID, bytes32 _id, address token);

    event NewDappMessage(bytes32 from, bytes32 to, uint256 messageId);

    modifier GasNotZero(address user, bool isOauthUser) {
        _gasNotZero(user, isOauthUser);
        _;
    }

    modifier isDapp(address dapp) {
        require(isDappsContract[dapp] == true, "Not_registred_dapp");
        _;
    }
    modifier isValidApp(bytes32 dappId) {
        _isValidApp(dappId);
        _;
    }
    modifier onlySuperAdmin() {
        _onlySuperAdmin();
        _;
    }

    modifier superAdminOrDappAdmin(bytes32 appID) {
        _superAdminOrDappAdmin(appID);
        _;
    }

    modifier superAdminOrDappAdminOrAddedAdmin(bytes32 appID) {
        _superAdminOrDappAdminOrAddedAdmin(appID);
        _;
    }

    function init_Gamification(
        address _subscriptionModule,
        address _trustedForwarder,
        GasRestrictor _gasRestrictor
    ) public initializer {
        subscriptionModule = SubscriptionModule(_subscriptionModule);
        isDappsContract[_subscriptionModule] = true;
        __Ownable_init(_trustedForwarder);
        gasRestrictor = _gasRestrictor;
    }

    function _isValidApp(bytes32 _appId) internal view {
        address a = subscriptionModule.getDappAdmin(_appId);
        require(a != address(0), "INVALID_DAPP");
    }

    function _gasNotZero(address user, bool isOauthUser) internal view {
        if (isTrustedForwarder[msg.sender]) {
            if (!isOauthUser) {
                if (
                    subscriptionModule.getPrimaryFromSecondary(user) == address(0)
                ) {} else {
                    (, , uint256 u) = gasRestrictor.gaslessData(
                        subscriptionModule.getPrimaryFromSecondary(user)
                    );
                    require(u != 0, "0_GASBALANCE");
                }
            } else {
                (, , uint256 u) = gasRestrictor.gaslessData(user);
                require(u != 0, "0_GASBALANCE");
            }
        }
    }

    function _onlySuperAdmin() internal view {
        require(
            _msgSender() == owner() ||
                _msgSender() ==
                subscriptionModule.getSecondaryWalletAccount(owner()),
            "INVALID_SENDER"
        );
    }

    function _superAdminOrDappAdmin(bytes32 _appID) internal view {
        address appAdmin = subscriptionModule.getDappAdmin(_appID);
        require(
            _msgSender() == owner() ||
                _msgSender() ==
                subscriptionModule.getSecondaryWalletAccount(owner()) ||
                _msgSender() == appAdmin ||
                _msgSender() ==
                subscriptionModule.getSecondaryWalletAccount(appAdmin),
            "INVALID_SENDER"
        );
    }

    function _superAdminOrDappAdminOrAddedAdmin(bytes32 _appID) internal view {
        address appAdmin = subscriptionModule.getDappAdmin(_appID);
        require(
            _msgSender() == owner() ||
                _msgSender() ==
                subscriptionModule.getSecondaryWalletAccount(owner()) ||
                _msgSender() == appAdmin ||
                _msgSender() ==
                subscriptionModule.getSecondaryWalletAccount(appAdmin) ||
                subscriptionModule.accountRole(_msgSender(), _appID) == 2 ||
                subscriptionModule.accountRole(_msgSender(), _appID) == 3,
            "INVALID_SENDER"
        );
    }

    function addDapp(address dapp) external onlyOwner {
        isDappsContract[dapp] = true;
    }

    function addKarmaPoints(address _for, uint256 amount)
        public
        isDapp(msg.sender)
    {
        karmaPoints[_for] = karmaPoints[_for] + amount;
    }

    function removeKarmaPoints(address _for, uint256 amount)
        public
        isDapp(msg.sender)
    {
        require(karmaPoints[_for] > amount, "not enough karma points");
        karmaPoints[_for] = karmaPoints[_for] - amount;
    }

    function sendNotifTokenHolders(
        bytes32 _appID,
        string memory _message,
        address _tokenAddress,
        bool isOAuthUser
    )
        public
        GasNotZero(_msgSender(), isOAuthUser)
        superAdminOrDappAdmin(_appID)
    {
        uint256 gasLeftInit = gasleft();
        address _token = tokenByTokenAddress[_tokenAddress]._tokenAddress;
        require(_token != address(0), "NOT_VERIFIED");
        require(
            tokenByTokenAddress[_tokenAddress].appId == _appID,
            "Not Token Of App"
        );
        // check if msg.sender is tokenAdmin/superAdmin

        bytes32 _tokenNotifID;
        _tokenNotifID = keccak256(
            abi.encode(block.number, _msgSender(), block.timestamp)
        );

        singleTokenNotif[_tokenNotifID] = TokenNotif(
            _tokenNotifID,
            _message,
            0,
            _tokenAddress
        );

        emit NewTokenNotif(_appID, _tokenNotifID, _token);

        _updateGaslessData(gasLeftInit);
    }

    function reactToTokenNotif(bytes32 tokenNotifId, string memory reaction)
        external
    {
        require(singleTokenNotif[tokenNotifId]._id == tokenNotifId, "WRONG_ID");
        require(
            reactionStatus[tokenNotifId][_msgSender()] == false,
            "WRONG_ID"
        );
        require(isValidReaction[reaction] == true, "WRONG_R");
        uint256 gasLeftInit = gasleft();

        uint256 _type = tokenByTokenAddress[
            singleTokenNotif[tokenNotifId]._token
        ]._tokenType;
        address token = singleTokenNotif[tokenNotifId]._token;
        if (_type == 20 || _type == 721) {
            require(IERC20(token).balanceOf(_msgSender()) > 0);
        }

        reactionsOfTokenNotifs[tokenNotifId][reaction]++;
        singleTokenNotif[tokenNotifId].reactionCounts++;

        reactionStatus[tokenNotifId][_msgSender()] = true;

        _updateGaslessData(gasLeftInit);
    }

    function addValidReactions(string memory _reaction)
        external
        onlySuperAdmin
    {
        isValidReaction[_reaction] = true;
    }

    function updateDappToken(
        bytes32 _appId,
        address[] memory _tokens,
        uint256[] memory _types // bool _isOauthUser
    ) external superAdminOrDappAdmin(_appId) isValidApp(_appId) {
        // onlySuperAdmin
        uint256 gasLeftInit = gasleft();

        require(_tokens.length == _types.length, "INVALID_PARAM");

        for (uint256 i = 0; i < _tokens.length; i++) {
            Token memory _t = Token(_appId, _tokens[i], _types[i]);
            tokenOfVerifiedApp[_appId].push(_t);
            tokenByTokenAddress[_tokens[i]] = _t;
        }

        _updateGaslessData(gasLeftInit);
    }

    function deleteDappToken(bytes32 _appId)
        external
        superAdminOrDappAdmin(_appId)
        isValidApp(_appId)
    {
        require(tokenOfVerifiedApp[_appId].length != 0, "No Token");

        delete tokenOfVerifiedApp[_appId];
    }

    function updateWelcomeMessage(
        bytes32 _appId,
        string memory _message,
        string memory _cta,
        string memory _buttonName
    ) public superAdminOrDappAdmin(_appId) isValidApp(_appId) {
        welcomeMessage[_appId].message = _message;
        welcomeMessage[_appId].buttonName = _buttonName;
        welcomeMessage[_appId].cta = _cta;
    }

    function updateEbookMessage(
        bytes32 _appId,
        string memory _message,
        string memory _cta,
        string memory _buttonName
    ) public superAdminOrDappAdmin(_appId) isValidApp(_appId) {
        ebookMessage[_appId].message = _message;
        ebookMessage[_appId].buttonName = _buttonName;
        ebookMessage[_appId].cta = _cta;
    }

    function sendMessageToDapp(
        bytes32 appFrom,
        bytes32 appTo,
        string memory encMessageForReceiverDapp,
        string memory enMessageForSenderDapp,
        bool isOAuthUser
    )
        public
        superAdminOrDappAdmin(appFrom)
        isValidApp(appFrom)
        isValidApp(appTo)
        GasNotZero(_msgSender(), isOAuthUser)
    {
        bool isVerified = subscriptionModule.getDapp(appFrom).isVerifiedDapp;
        // check isVerified Dapp OR Not
        require(isVerified == true, "App Not Verified");

        Message memory message = Message({
            sender: _msgSender(),
            senderDappID: appFrom,
            receiverDappId: appTo,
            textMessageEncryptedForReceiver: encMessageForReceiverDapp,
            textMessageEncryptedForSender: enMessageForSenderDapp,
            timestamp: block.timestamp
        });

        uint256 messageId = messageIdOfDapps[appFrom][appTo];
        if (messageId == 0) {
            messageId = ++messageIdCount;
            messageIdOfDapps[appFrom][appTo] = messageId;
            messageIdOfDapps[appTo][appFrom] = messageId;
        }
        messages[messageId].push(message);

        emit NewDappMessage(appFrom, appTo, messageId);
    }


    function updateEbook(
        bytes32 _appId,
        EbookDetails memory _ebookDetails,
        bool _isAuthUser
    )
        external
        superAdminOrDappAdminOrAddedAdmin(_appId)
        GasNotZero(_msgSender(), _isAuthUser)
    {
        uint256 gasLeftInit = gasleft();

        require(
            subscriptionModule.getDappAdmin(_appId) != address(0),
            "INVALID DAPP ID"
        );
        require(bytes(_ebookDetails.title).length != 0, "EMPTY_TITLE");
        EbookDetails memory ebookDetails = EbookDetails({
            title: _ebookDetails.title,
            summary: _ebookDetails.summary,
            assetFile: _ebookDetails.assetFile,
            assetSampleFile: _ebookDetails.assetSampleFile,
            coverImage: _ebookDetails.coverImage,
            isSendNotif: _ebookDetails.isSendNotif,
            isShowApp: _ebookDetails.isShowApp,
            aboutCompany: _ebookDetails.aboutCompany,
            aboutImage: _ebookDetails.aboutImage
        });
        ebooks[_appId] = ebookDetails;

        _updateGaslessData(gasLeftInit);
    }

  

    function getWelcomeMessage(bytes32 _appId) external view returns(string memory, string memory, string memory){

        if (ebooks[_appId].isSendNotif)
            return (ebookMessage[_appId].message, ebookMessage[_appId].cta, ebookMessage[_appId].buttonName);
        else             
            return (welcomeMessage[_appId].message, welcomeMessage[_appId].cta, welcomeMessage[_appId].buttonName);


    }

      function _updateGaslessData(uint256 _gasLeftInit) internal {
        if (isTrustedForwarder[msg.sender]) {
            gasRestrictor._updateGaslessData(_msgSender(), _gasLeftInit);
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

// OpenZeppelin Contracts v4.3.2 (access/Ownable.sol)

pragma solidity ^0.8.4;

import {ERC2771ContextUpgradeable} from "./ERC2771ContextUpgradeable.sol";
// import {Initializable} from "../proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */

abstract contract OwnableUpgradeable is Initializable, ERC2771ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init(address trustedForwarder) internal initializer {
        __Ownable_init_unchained();
        __ERC2771ContextUpgradeable_init(trustedForwarder);
    }

    function __Ownable_init_unchained() internal initializer {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "ONA");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "INA");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

     function _msgSender() internal view virtual override returns (address sender) {
        if (isTrustedForwarder[msg.sender]) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return msg.sender;
        }
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "./GasRestrictor.sol";
import "./Gamification.sol";

contract WalletRegistry is Initializable, OwnableUpgradeable {
    GasRestrictor public gasRestrictor;
    Gamification public gamification;

    // dappID => telegram chatID
    mapping(address => string) public telegramChatID;

    struct SecondaryWallet {
        address account;
        string encPvtKey;
        string publicKey;
    }

    // userAddress  => Wallet
    mapping(address => SecondaryWallet) public userWallets;
    // string => userWallet for email users
    mapping(string => SecondaryWallet) public oAuthUserWallets;

    // secondary to primary wallet mapping to get primary wallet from secondary
    mapping(address => address) public getPrimaryFromSecondary;

    uint256 public noOfWallets;

    modifier isValidSender(address from) {
        _isValidSender(from);
        _;
    }

    modifier GasNotZero(address user, bool isOauthUser) {
        _gasNotZero(user, isOauthUser);
        _;
    }

    event WalletCreated(
        address indexed account,
        address secondaryAccount,
        bool isOAuthUser,
        string oAuthEncryptedUserId,
        uint256 walletCount
    );

    function __walletRegistry_init(address _trustedForwarder)
        public
        initializer
    {
        __Ownable_init(_trustedForwarder);
    }

    function _isValidSender(address _from) internal view {
        require(
            _msgSender() == _from ||
                _msgSender() == getSecondaryWalletAccount(_from),
            "INVALID_SENDER"
        );
    }

    function _gasNotZero(address user, bool isOauthUser) internal view {
        if (isTrustedForwarder[msg.sender]) {
            if (!isOauthUser) {
                if (getPrimaryFromSecondary[user] == address(0)) {} else {
                    (, , uint256 u) = gasRestrictor.gaslessData(
                        getPrimaryFromSecondary[user]
                    );
                    require(u != 0, "NOT_ENOUGH_GASBALANCE");
                }
            } else {
                (, , uint256 u) = gasRestrictor.gaslessData(user);
                require(u != 0, "NOT_ENOUGH_GASBALANCE");
            }
        }
    }

    function addGasRestrictorAndGamification(
        GasRestrictor _gasRestrictor,
        Gamification _gamification
    ) external onlyOwner {
        gasRestrictor = _gasRestrictor;
        gamification = _gamification;
    }

    function addTelegramChatID(
        address user, 
        string memory chatID,
        bool isOauthUser
    )
        external isValidSender(user) GasNotZero(_msgSender(), isOauthUser)
    {
        uint256 gasLeftInit = gasleft();
        require(bytes(telegramChatID[user]).length == 0, "INVALID_TG_ID"); // INVALID_TELEGRAM_ID
        telegramChatID[user] = chatID;

        _updateGaslessData(gasLeftInit);
    }

    function updateTelegramChatID(
        address user,
        string memory chatID,
        bool isOauthUser
    ) external isValidSender(user) GasNotZero(_msgSender(), isOauthUser)
    {
        uint256 gasLeftInit = gasleft();
        require(bytes(telegramChatID[user]).length != 0, "INVALID_TG_IG"); // INVALID_TELEGRAM_ID
        telegramChatID[user] = chatID;

        _updateGaslessData(gasLeftInit);
    }

    function createWallet(
        address _account,
        string calldata _encPvtKey,
        string calldata _publicKey,
        string calldata oAuthEncryptedUserId,
        bool isOauthUser,
        address referer
    ) external {
        if (!isOauthUser) {
            require(
                userWallets[_msgSender()].account == address(0),
                "ACCOUNT_ALREADY_EXISTS"
            );
            SecondaryWallet memory wallet = SecondaryWallet({
                account: _account,
                encPvtKey: _encPvtKey,
                publicKey: _publicKey
            });
            userWallets[_msgSender()] = wallet;
            getPrimaryFromSecondary[_account] = _msgSender();

            gasRestrictor.initUser(_msgSender(), _account, false);

            // add 2 karma point for _msgSender()
            gamification.addKarmaPoints(_msgSender(), 2);


            if (
                referer != address(0) &&
                getSecondaryWalletAccount(referer) != address(0)
            ) {
                // add 5 karma point for _msgSender()
                // add 5 karma point for referer
                gamification.addKarmaPoints(_msgSender(), 5);
                gamification.addKarmaPoints(referer, 5);

            }
        } else {
            require(
                oAuthUserWallets[oAuthEncryptedUserId].account == address(0),
                "ACCOUNT_ALREADY_EXISTS"
            );
            require(_msgSender() == _account, "Invalid_User");
            SecondaryWallet memory wallet = SecondaryWallet({
                account: _account,
                encPvtKey: _encPvtKey,
                publicKey: _publicKey
            });
            oAuthUserWallets[oAuthEncryptedUserId] = wallet;
            // getPrimaryFromSecondary[_account] = _msgSender();

              // add 2 karma point for _msgSender()
            gamification.addKarmaPoints(_msgSender(), 2);

            if (
                referer != address(0) &&
                getSecondaryWalletAccount(referer) != address(0)
            ) {
                // add 5 karma point for _msgSender()
                // add 5 karma point for referer
                gamification.addKarmaPoints(_msgSender(), 5);
                gamification.addKarmaPoints(referer, 5);

            }

            gasRestrictor.initUser(_msgSender(), _account, true);
        }

        emit WalletCreated(
            _msgSender(),
            _account,
            isOauthUser,
            oAuthEncryptedUserId,
            ++noOfWallets
        );
    }

    function getSecondaryWalletAccount(address _account)
        public
        view
        returns (address)
    {
        return userWallets[_account].account;
    }

    function _updateGaslessData(uint256 _gasLeftInit) internal {
        if (isTrustedForwarder[msg.sender]) {
            gasRestrictor._updateGaslessData(_msgSender(), _gasLeftInit);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int256)", p0));
	}

	function logUint(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint256 p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256)", p0, p1));
	}

	function log(uint256 p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string)", p0, p1));
	}

	function log(uint256 p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool)", p0, p1));
	}

	function log(uint256 p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address)", p0, p1));
	}

	function log(string memory p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint256 p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}

// SPDX-License-Identifier: GPL-3.0-or-later

// OpenZeppelin Contracts v4.3.2 (metatx/ERC2771Context.sol)

pragma solidity ^0.8.4;

// import {Initializable} from "../proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


/**
 * @dev Context variant with ERC2771 support.
 */
// solhint-disable
abstract contract ERC2771ContextUpgradeable is Initializable {
    // address public trustedForwarder;
    mapping(address=>bool) public isTrustedForwarder;

    function __ERC2771ContextUpgradeable_init(address tForwarder) internal initializer {
        __ERC2771ContextUpgradeable_init_unchained(tForwarder);
    }

    function __ERC2771ContextUpgradeable_init_unchained(address tForwarder) internal {
        isTrustedForwarder[tForwarder] = true;
    }

    function addOrRemovetrustedForwarder(address _forwarder, bool status) public  virtual  {
        require( isTrustedForwarder[_forwarder] != status, "same satus");
        isTrustedForwarder[_forwarder] = status;
    }



    function _msgSender() internal view virtual returns (address sender) {
        if (isTrustedForwarder[msg.sender]) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return msg.sender;
        }
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        if (isTrustedForwarder[msg.sender]) {
            return msg.data[:msg.data.length - 20];
        } else {
            return msg.data;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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