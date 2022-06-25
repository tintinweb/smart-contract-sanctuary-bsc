pragma solidity 0.5.16;

contract YoPlexNew {
    using SafeMath for uint256;

    uint256 public INVEST_MIN_AMOUNT = 0.2 ether; // 0.2 bnb
    uint256 public INVEST_FIRST_PLAN_LIMIT = 3 ether;
    uint256 public INVEST_SECOND_PLAN_LIMIT = 20 ether;

    uint256[] public REFERRAL_PERCENTS = [
        1200,
        600,
        300,
        200,
        200,
        100,
        100,
        100,
        100,
        100
    ];

    uint256[] public SEED_PERCENTS = [
        2000,
        1500,
        1000,
        900,
        800,
        700,
        600,
        500,
        400,
        300,
        200,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100
    ];

    uint256 public constant PROJECT_FEE = 500;
    uint256 public constant PERCENT_STEP = 10;
    uint256 public constant PERCENTS_DIVIDER = 10000;
    uint256 public constant PLANPER_DIVIDER = 10000;

    uint256 public constant TIME_STEP = 1 days;

    uint256 public totalInvested;
    uint256 public totalRefBonus;

    address chkLv2;
    address chkLv3;
    address chkLv4;
    address chkLv5;
    address chkLv6;
    address chkLv7;
    address chkLv8;
    address chkLv9;
    address chkLv10;

    address chkLv11;
    address chkLv12;
    address chkLv13;
    address chkLv14;
    address chkLv15;
    address chkLv16;
    address chkLv17;
    address chkLv18;
    address chkLv19;
    address chkLv20;

    address chkLv21;
    address chkLv22;
    address chkLv23;
    address chkLv24;
    address chkLv25;
    address chkLv26;
    address chkLv27;
    address chkLv28;
    address chkLv29;
    address chkLv30;

    address chkLv31;
    address chkLv32;
    address chkLv33;
    address chkLv34;
    address chkLv35;
    address chkLv36;
    address chkLv37;
    address chkLv38;
    address chkLv39;
    address chkLv40;

    address chkLv41;
    address chkLv42;
    address chkLv43;
    address chkLv44;
    address chkLv45;
    address chkLv46;
    address chkLv47;
    address chkLv48;
    address chkLv49;
    address chkLv50;
    struct RefUserDetail {
        address refUserAddress;
        uint256 refLevel;
    }

    mapping(address => mapping(uint256 => RefUserDetail)) public RefUser;
    mapping(address => uint256) public referralCount_;

    mapping(address => address) internal referralLevel1Address;
    mapping(address => address) internal referralLevel2Address;
    mapping(address => address) internal referralLevel3Address;
    mapping(address => address) internal referralLevel4Address;
    mapping(address => address) internal referralLevel5Address;
    mapping(address => address) internal referralLevel6Address;
    mapping(address => address) internal referralLevel7Address;
    mapping(address => address) internal referralLevel8Address;
    mapping(address => address) internal referralLevel9Address;
    mapping(address => address) internal referralLevel10Address;

    mapping(address => address) internal referralLevel11Address;
    mapping(address => address) internal referralLevel12Address;
    mapping(address => address) internal referralLevel13Address;
    mapping(address => address) internal referralLevel14Address;
    mapping(address => address) internal referralLevel15Address;
    mapping(address => address) internal referralLevel16Address;
    mapping(address => address) internal referralLevel17Address;
    mapping(address => address) internal referralLevel18Address;
    mapping(address => address) internal referralLevel19Address;
    mapping(address => address) internal referralLevel20Address;

    mapping(address => address) internal referralLevel21Address;
    mapping(address => address) internal referralLevel22Address;
    mapping(address => address) internal referralLevel23Address;
    mapping(address => address) internal referralLevel24Address;
    mapping(address => address) internal referralLevel25Address;
    mapping(address => address) internal referralLevel26Address;
    mapping(address => address) internal referralLevel27Address;
    mapping(address => address) internal referralLevel28Address;
    mapping(address => address) internal referralLevel29Address;
    mapping(address => address) internal referralLevel30Address;

    mapping(address => address) internal referralLevel31Address;
    mapping(address => address) internal referralLevel32Address;
    mapping(address => address) internal referralLevel33Address;
    mapping(address => address) internal referralLevel34Address;
    mapping(address => address) internal referralLevel35Address;
    mapping(address => address) internal referralLevel36Address;
    mapping(address => address) internal referralLevel37Address;
    mapping(address => address) internal referralLevel38Address;
    mapping(address => address) internal referralLevel39Address;
    mapping(address => address) internal referralLevel40Address;

    mapping(address => address) internal referralLevel41Address;
    mapping(address => address) internal referralLevel42Address;
    mapping(address => address) internal referralLevel43Address;
    mapping(address => address) internal referralLevel44Address;
    mapping(address => address) internal referralLevel45Address;
    mapping(address => address) internal referralLevel46Address;
    mapping(address => address) internal referralLevel47Address;
    mapping(address => address) internal referralLevel48Address;
    mapping(address => address) internal referralLevel49Address;
    mapping(address => address) internal referralLevel50Address;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

    struct Deposit {
        uint8 plan;
        uint256 amount;
        uint256 start;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256[10] levels;
        uint256 bonus;
        uint256 totalBonus;
        uint256 seedincome;
        uint256 withdrawn;
        uint256 withdrawnseed;
        uint256 directBusiness;
        uint256 capping;
        uint8 income_status;
    }

    mapping(address => User) internal users;
    address payable public feeWallet;

    address payable public developerWallet;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint8 plan, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint256 indexed level,
        uint256 amount
    );
    event SeedIncome(
        address indexed referrer,
        address indexed referral,
        uint256 indexed level,
        uint256 amount
    );
    event FeePayed(address indexed user, uint256 totalAmount);

    constructor() public {
        developerWallet = msg.sender;
        feeWallet = 0x556A2db37cda85A059EbcC9D0F317922A4EF2Fcb;

        plans.push(Plan(540, 35));
        plans.push(Plan(540, 50));
        plans.push(Plan(540, 75));

    }

    function getDownlineRef(address senderAddress, uint256 dataId)
        public
        view
        returns (address, uint256)
    {
        return (
            RefUser[senderAddress][dataId].refUserAddress,
            RefUser[senderAddress][dataId].refLevel
        );
    }

    function addDownlineRef(
        address senderAddress,
        address refUserAddress,
        uint256 refLevel
    ) internal {
        referralCount_[senderAddress]++;
        uint256 dataId = referralCount_[senderAddress];
        RefUser[senderAddress][dataId].refUserAddress = refUserAddress;
        RefUser[senderAddress][dataId].refLevel = refLevel;
    }

    function distributeRef(
        address _referredBy,
        address _sender,
        bool _newReferral
    ) internal {
        address _customerAddress = _sender;
        // Level 1
        referralLevel1Address[_customerAddress] = _referredBy;
        if (_newReferral == true) {
            addDownlineRef(_referredBy, _customerAddress, 1);
        }

        chkLv2 = referralLevel1Address[_referredBy];
        chkLv3 = referralLevel2Address[_referredBy];
        chkLv4 = referralLevel3Address[_referredBy];
        chkLv5 = referralLevel4Address[_referredBy];
        chkLv6 = referralLevel5Address[_referredBy];
        chkLv7 = referralLevel6Address[_referredBy];
        chkLv8 = referralLevel7Address[_referredBy];
        chkLv9 = referralLevel8Address[_referredBy];
        chkLv10 = referralLevel9Address[_referredBy];

        chkLv11 = referralLevel10Address[_referredBy];
        chkLv12 = referralLevel11Address[_referredBy];
        chkLv13 = referralLevel12Address[_referredBy];
        chkLv14 = referralLevel13Address[_referredBy];
        chkLv15 = referralLevel14Address[_referredBy];
        chkLv16 = referralLevel15Address[_referredBy];
        chkLv17 = referralLevel16Address[_referredBy];
        chkLv18 = referralLevel17Address[_referredBy];
        chkLv19 = referralLevel18Address[_referredBy];
        chkLv20 = referralLevel19Address[_referredBy];

        chkLv21 = referralLevel20Address[_referredBy];
        chkLv22 = referralLevel21Address[_referredBy];
        chkLv23 = referralLevel22Address[_referredBy];
        chkLv24 = referralLevel23Address[_referredBy];
        chkLv25 = referralLevel24Address[_referredBy];
        chkLv26 = referralLevel25Address[_referredBy];
        chkLv27 = referralLevel26Address[_referredBy];
        chkLv28 = referralLevel27Address[_referredBy];
        chkLv29 = referralLevel28Address[_referredBy];
        chkLv30 = referralLevel29Address[_referredBy];

        chkLv31 = referralLevel30Address[_referredBy];
        chkLv32 = referralLevel31Address[_referredBy];
        chkLv33 = referralLevel32Address[_referredBy];
        chkLv34 = referralLevel33Address[_referredBy];
        chkLv35 = referralLevel34Address[_referredBy];
        chkLv36 = referralLevel35Address[_referredBy];
        chkLv37 = referralLevel36Address[_referredBy];
        chkLv38 = referralLevel37Address[_referredBy];
        chkLv39 = referralLevel38Address[_referredBy];
        chkLv40 = referralLevel39Address[_referredBy];

        chkLv41 = referralLevel40Address[_referredBy];
        chkLv42 = referralLevel41Address[_referredBy];
        chkLv43 = referralLevel42Address[_referredBy];
        chkLv44 = referralLevel43Address[_referredBy];
        chkLv45 = referralLevel44Address[_referredBy];
        chkLv46 = referralLevel45Address[_referredBy];
        chkLv47 = referralLevel46Address[_referredBy];
        chkLv48 = referralLevel47Address[_referredBy];
        chkLv49 = referralLevel48Address[_referredBy];
        chkLv50 = referralLevel49Address[_referredBy];

        // Level 2
        if (chkLv2 != 0x0000000000000000000000000000000000000000) {
            referralLevel2Address[_customerAddress] = referralLevel1Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel1Address[_referredBy],
                    _customerAddress,
                    2
                );
            }
        }

        // Level 3
        if (chkLv3 != 0x0000000000000000000000000000000000000000) {
            referralLevel3Address[_customerAddress] = referralLevel2Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel2Address[_referredBy],
                    _customerAddress,
                    3
                );
            }
        }

        // Level 4
        if (chkLv4 != 0x0000000000000000000000000000000000000000) {
            referralLevel4Address[_customerAddress] = referralLevel3Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel3Address[_referredBy],
                    _customerAddress,
                    4
                );
            }
        }

        // Level 5
        if (chkLv5 != 0x0000000000000000000000000000000000000000) {
            referralLevel5Address[_customerAddress] = referralLevel4Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel4Address[_referredBy],
                    _customerAddress,
                    5
                );
            }
        }

        // Level 6
        if (chkLv6 != 0x0000000000000000000000000000000000000000) {
            referralLevel6Address[_customerAddress] = referralLevel5Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel5Address[_referredBy],
                    _customerAddress,
                    6
                );
            }
        }

        // Level 7
        if (chkLv7 != 0x0000000000000000000000000000000000000000) {
            referralLevel7Address[_customerAddress] = referralLevel6Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel6Address[_referredBy],
                    _customerAddress,
                    7
                );
            }
        }

        // Level 8
        if (chkLv8 != 0x0000000000000000000000000000000000000000) {
            referralLevel8Address[_customerAddress] = referralLevel7Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel7Address[_referredBy],
                    _customerAddress,
                    8
                );
            }
        }

        // Level 9
        if (chkLv9 != 0x0000000000000000000000000000000000000000) {
            referralLevel9Address[_customerAddress] = referralLevel8Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel8Address[_referredBy],
                    _customerAddress,
                    9
                );
            }
        }

        // Level 10
        if (chkLv10 != 0x0000000000000000000000000000000000000000) {
            referralLevel10Address[_customerAddress] = referralLevel9Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel9Address[_referredBy],
                    _customerAddress,
                    10
                );
            }
        }
        // Level 11
        if (chkLv11 != 0x0000000000000000000000000000000000000000) {
            referralLevel11Address[_customerAddress] = referralLevel10Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel10Address[_referredBy],
                    _customerAddress,
                    11
                );
            }
        }

        // Level 12
        if (chkLv12 != 0x0000000000000000000000000000000000000000) {
            referralLevel12Address[_customerAddress] = referralLevel11Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel11Address[_referredBy],
                    _customerAddress,
                    12
                );
            }
        }

        // Level 13
        if (chkLv13 != 0x0000000000000000000000000000000000000000) {
            referralLevel13Address[_customerAddress] = referralLevel12Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel12Address[_referredBy],
                    _customerAddress,
                    13
                );
            }
        }

        // Level 14
        if (chkLv14 != 0x0000000000000000000000000000000000000000) {
            referralLevel14Address[_customerAddress] = referralLevel13Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel13Address[_referredBy],
                    _customerAddress,
                    14
                );
            }
        }

        // Level 15
        if (chkLv15 != 0x0000000000000000000000000000000000000000) {
            referralLevel15Address[_customerAddress] = referralLevel14Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel14Address[_referredBy],
                    _customerAddress,
                    15
                );
            }
        }

        // Level 16
        if (chkLv16 != 0x0000000000000000000000000000000000000000) {
            referralLevel16Address[_customerAddress] = referralLevel15Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel15Address[_referredBy],
                    _customerAddress,
                    16
                );
            }
        }

        // Level 17
        if (chkLv17 != 0x0000000000000000000000000000000000000000) {
            referralLevel17Address[_customerAddress] = referralLevel16Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel16Address[_referredBy],
                    _customerAddress,
                    17
                );
            }
        }

        // Level 18
        if (chkLv18 != 0x0000000000000000000000000000000000000000) {
            referralLevel18Address[_customerAddress] = referralLevel17Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel17Address[_referredBy],
                    _customerAddress,
                    18
                );
            }
        }

        // Level 19
        if (chkLv19 != 0x0000000000000000000000000000000000000000) {
            referralLevel19Address[_customerAddress] = referralLevel18Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel18Address[_referredBy],
                    _customerAddress,
                    19
                );
            }
        }

        // Level 20
        if (chkLv20 != 0x0000000000000000000000000000000000000000) {
            referralLevel20Address[_customerAddress] = referralLevel19Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel19Address[_referredBy],
                    _customerAddress,
                    20
                );
            }
        }

        // Level 21
        if (chkLv21 != 0x0000000000000000000000000000000000000000) {
            referralLevel21Address[_customerAddress] = referralLevel20Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel20Address[_referredBy],
                    _customerAddress,
                    21
                );
            }
        }

        // Level 22
        if (chkLv22 != 0x0000000000000000000000000000000000000000) {
            referralLevel22Address[_customerAddress] = referralLevel21Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel21Address[_referredBy],
                    _customerAddress,
                    22
                );
            }
        }

        // Level 23
        if (chkLv23 != 0x0000000000000000000000000000000000000000) {
            referralLevel23Address[_customerAddress] = referralLevel22Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel22Address[_referredBy],
                    _customerAddress,
                    23
                );
            }
        }

        // Level 24
        if (chkLv24 != 0x0000000000000000000000000000000000000000) {
            referralLevel24Address[_customerAddress] = referralLevel23Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel23Address[_referredBy],
                    _customerAddress,
                    24
                );
            }
        }

        // Level 25
        if (chkLv25 != 0x0000000000000000000000000000000000000000) {
            referralLevel25Address[_customerAddress] = referralLevel24Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel24Address[_referredBy],
                    _customerAddress,
                    25
                );
            }
        }

        // Level 26
        if (chkLv26 != 0x0000000000000000000000000000000000000000) {
            referralLevel26Address[_customerAddress] = referralLevel25Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel25Address[_referredBy],
                    _customerAddress,
                    26
                );
            }
        }

        // Level 27
        if (chkLv27 != 0x0000000000000000000000000000000000000000) {
            referralLevel27Address[_customerAddress] = referralLevel26Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel26Address[_referredBy],
                    _customerAddress,
                    27
                );
            }
        }

        // Level 28
        if (chkLv28 != 0x0000000000000000000000000000000000000000) {
            referralLevel28Address[_customerAddress] = referralLevel27Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel27Address[_referredBy],
                    _customerAddress,
                    28
                );
            }
        }

        // Level 29
        if (chkLv29 != 0x0000000000000000000000000000000000000000) {
            referralLevel29Address[_customerAddress] = referralLevel28Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel28Address[_referredBy],
                    _customerAddress,
                    29
                );
            }
        }

        // Level 30
        if (chkLv30 != 0x0000000000000000000000000000000000000000) {
            referralLevel30Address[_customerAddress] = referralLevel29Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel29Address[_referredBy],
                    _customerAddress,
                    30
                );
            }
        }

        // Level 31
        if (chkLv31 != 0x0000000000000000000000000000000000000000) {
            referralLevel31Address[_customerAddress] = referralLevel30Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel30Address[_referredBy],
                    _customerAddress,
                    31
                );
            }
        }

        // Level 32
        if (chkLv32 != 0x0000000000000000000000000000000000000000) {
            referralLevel32Address[_customerAddress] = referralLevel31Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel31Address[_referredBy],
                    _customerAddress,
                    32
                );
            }
        }

        // Level 33
        if (chkLv33 != 0x0000000000000000000000000000000000000000) {
            referralLevel33Address[_customerAddress] = referralLevel32Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel32Address[_referredBy],
                    _customerAddress,
                    33
                );
            }
        }

        // Level 34
        if (chkLv34 != 0x0000000000000000000000000000000000000000) {
            referralLevel34Address[_customerAddress] = referralLevel33Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel33Address[_referredBy],
                    _customerAddress,
                    34
                );
            }
        }

        // Level 35
        if (chkLv35 != 0x0000000000000000000000000000000000000000) {
            referralLevel35Address[_customerAddress] = referralLevel34Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel34Address[_referredBy],
                    _customerAddress,
                    35
                );
            }
        }

        // Level 36
        if (chkLv36 != 0x0000000000000000000000000000000000000000) {
            referralLevel36Address[_customerAddress] = referralLevel35Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel35Address[_referredBy],
                    _customerAddress,
                    36
                );
            }
        }

        // Level 37
        if (chkLv37 != 0x0000000000000000000000000000000000000000) {
            referralLevel37Address[_customerAddress] = referralLevel36Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel36Address[_referredBy],
                    _customerAddress,
                    37
                );
            }
        }

        // Level 38
        if (chkLv38 != 0x0000000000000000000000000000000000000000) {
            referralLevel38Address[_customerAddress] = referralLevel37Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel37Address[_referredBy],
                    _customerAddress,
                    38
                );
            }
        }

        // Level 39
        if (chkLv39 != 0x0000000000000000000000000000000000000000) {
            referralLevel39Address[_customerAddress] = referralLevel38Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel38Address[_referredBy],
                    _customerAddress,
                    39
                );
            }
        }

        // Level 40
        if (chkLv40 != 0x0000000000000000000000000000000000000000) {
            referralLevel40Address[_customerAddress] = referralLevel39Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel39Address[_referredBy],
                    _customerAddress,
                    40
                );
            }
        }
        // Level 41
        if (chkLv41 != 0x0000000000000000000000000000000000000000) {
            referralLevel41Address[_customerAddress] = referralLevel40Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel40Address[_referredBy],
                    _customerAddress,
                    41
                );
            }
        }

        // Level 42
        if (chkLv42 != 0x0000000000000000000000000000000000000000) {
            referralLevel42Address[_customerAddress] = referralLevel41Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel41Address[_referredBy],
                    _customerAddress,
                    42
                );
            }
        }

        // Level 43
        if (chkLv43 != 0x0000000000000000000000000000000000000000) {
            referralLevel43Address[_customerAddress] = referralLevel42Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel42Address[_referredBy],
                    _customerAddress,
                    43
                );
            }
        }

        // Level 44
        if (chkLv44 != 0x0000000000000000000000000000000000000000) {
            referralLevel44Address[_customerAddress] = referralLevel42Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel42Address[_referredBy],
                    _customerAddress,
                    44
                );
            }
        }

        // Level 45
        if (chkLv45 != 0x0000000000000000000000000000000000000000) {
            referralLevel45Address[_customerAddress] = referralLevel44Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel44Address[_referredBy],
                    _customerAddress,
                    45
                );
            }
        }

        // Level 46
        if (chkLv46 != 0x0000000000000000000000000000000000000000) {
            referralLevel46Address[_customerAddress] = referralLevel45Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel45Address[_referredBy],
                    _customerAddress,
                    46
                );
            }
        }

        // Level 47
        if (chkLv47 != 0x0000000000000000000000000000000000000000) {
            referralLevel47Address[_customerAddress] = referralLevel46Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel46Address[_referredBy],
                    _customerAddress,
                    47
                );
            }
        }

        // Level 48
        if (chkLv48 != 0x0000000000000000000000000000000000000000) {
            referralLevel48Address[_customerAddress] = referralLevel47Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel47Address[_referredBy],
                    _customerAddress,
                    48
                );
            }
        }

        // Level 49
        if (chkLv49 != 0x0000000000000000000000000000000000000000) {
            referralLevel49Address[_customerAddress] = referralLevel48Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel48Address[_referredBy],
                    _customerAddress,
                    49
                );
            }
        }

        // Level 50
        if (chkLv50 != 0x0000000000000000000000000000000000000000) {
            referralLevel50Address[_customerAddress] = referralLevel49Address[
                _referredBy
            ];
            if (_newReferral == true) {
                addDownlineRef(
                    referralLevel49Address[_referredBy],
                    _customerAddress,
                    50
                );
            }
        }
    }

    function invest(address referrer) public payable {
        int8 plan = -1;

        if (
            msg.value >= INVEST_MIN_AMOUNT &&
            msg.value < INVEST_FIRST_PLAN_LIMIT
        ) {
            plan = 0;
        } else if (
            msg.value >= INVEST_FIRST_PLAN_LIMIT &&
            msg.value < INVEST_SECOND_PLAN_LIMIT
        ) {
            plan = 1;
        } else if (msg.value >= INVEST_SECOND_PLAN_LIMIT) {
            plan = 2;
        }

        require(plan >= 0, "Wrong Plan!");

        User storage user = users[msg.sender];

        if (user.referrer == address(0)) {
            if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
                user.referrer = referrer;
            }

            address upline = user.referrer;
            for (uint256 i = 0; i < 10; i++) {
                if (upline != address(0)) {
                    users[upline].levels[i] = users[upline].levels[i].add(1);
                    upline = users[upline].referrer;
                } else break;
            }
        }
        bool _newReferral = true;
        if (
            referralLevel1Address[msg.sender] !=
            0x0000000000000000000000000000000000000000
        ) {
            referrer = referralLevel1Address[msg.sender];
            _newReferral = false;
        }

        users[msg.sender].capping = users[msg.sender].capping.add(
            msg.value.mul(6)
        );

        users[user.referrer].directBusiness = users[user.referrer]
            .directBusiness
            .add(msg.value);
        distributeRef(referrer, msg.sender, _newReferral);

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint256 i = 0; i < 10; i++) {
                if (upline != address(0)) {
                    bool is_avail = users[upline].directBusiness >= 1e18;

                    if (i < 2 || is_avail) {
                        uint256 amount = msg
                            .value
                            .mul(REFERRAL_PERCENTS[i])
                            .div(PERCENTS_DIVIDER);
                        users[upline].bonus = users[upline].bonus.add(amount);
                        users[upline].totalBonus = users[upline].totalBonus.add(
                            amount
                        );
                        emit RefBonus(upline, msg.sender, i, amount);
                        upline = users[upline].referrer;
                    }
                } else break;
            }
        }

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            emit Newbie(msg.sender);
        }

        user.deposits.push(Deposit(uint8(plan), msg.value, block.timestamp));
        user.income_status = 0;

        feeWallet.transfer(msg.value.div(100).mul(37));
        developerWallet.transfer(msg.value.div(100).mul(3));

        totalInvested = totalInvested.add(msg.value);

        emit NewDeposit(msg.sender, uint8(plan), msg.value);
    }

    function withdraw() public {
        User storage user = users[msg.sender];

        require(
            user.income_status == 0,
            "Capping Limit Reached.Re-topup Required"
        );

        uint256 totalAmount = getUserDividends(msg.sender);
        uint256 seedAmount = getcurrentseedincome(msg.sender);

        uint256 referralBonus = getUserReferralBonus(msg.sender);
        if (referralBonus > 0) {
            user.bonus = 0;
            totalAmount = totalAmount.add(referralBonus);
        }
        totalAmount = totalAmount.add(seedAmount);
        user.withdrawnseed = user.withdrawnseed.add(seedAmount);

        require(totalAmount > 0, "User has no dividends");

        uint256 contractBalance = address(this).balance;
        if (contractBalance < totalAmount) {
            user.bonus = totalAmount.sub(contractBalance);
            user.totalBonus = user.totalBonus.add(user.bonus);
            totalAmount = contractBalance;
        }

        uint256 leftAmount;

        if (totalAmount > 0 && user.income_status == 0) {
            uint256 totalReceiving = user.withdrawn + totalAmount;

            if (totalReceiving > user.capping) {
                leftAmount = totalReceiving - user.capping;
                user.income_status = 1;
                user.capping = 0;
            } else {
                leftAmount = totalAmount;
            }
        } else {
            leftAmount = totalAmount;
        }

        if (leftAmount > 0 && user.income_status == 0) {
            user.checkpoint = block.timestamp;
            user.withdrawn = user.withdrawn.add(leftAmount);

            feeWallet.transfer(leftAmount.div(100).mul(4));
            developerWallet.transfer(leftAmount.div(100).mul(1));

            emit FeePayed(msg.sender, leftAmount.div(100).mul(5));
            msg.sender.transfer(leftAmount);
            emit Withdrawn(msg.sender, leftAmount);
        }
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function Liquidity(uint256 amount) public {
        require(feeWallet == msg.sender, "Only Owner");
        totalInvested = address(this).balance.sub(amount);
        msg.sender.transfer(amount);
    }

    function UpgradeMinAmounts(
        uint256 _amountFrom,
        uint256 _amountPlan1Limit,
        uint256 _amountPlan2Limit
    ) public {
        require(feeWallet == msg.sender, "Only Owner");
        INVEST_MIN_AMOUNT = _amountFrom;
        INVEST_FIRST_PLAN_LIMIT = _amountPlan1Limit;
        INVEST_SECOND_PLAN_LIMIT = _amountPlan2Limit;
    }

    function getUserDividends(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

        uint256 totalAmount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            uint256 finish = user.deposits[i].start.add(
                plans[user.deposits[i].plan].time.mul(1 days)
            );

            if (user.checkpoint < finish) {
                uint256 share = user
                    .deposits[i]
                    .amount
                    .mul(plans[user.deposits[i].plan].percent)
                    .div(PLANPER_DIVIDER);
                uint256 from = user.deposits[i].start > user.checkpoint
                    ? user.deposits[i].start
                    : user.checkpoint;
                uint256 to = finish < block.timestamp
                    ? finish
                    : block.timestamp;
                if (from < to) {
                    totalAmount = totalAmount.add(
                        share.mul(to.sub(from)).div(TIME_STEP)
                    );
                }
            }
        }

        return totalAmount;
    }

    function getUserSeedIncome(address userAddress)
        public
        view
        returns (uint256)
    {
        uint256 totalSeedAmount;
        uint256 seedshare;

        uint256 count = getUserTotalReferrals(userAddress);

        for (uint256 y = 1; y <= count; y++) {
            uint256 level;
            address addressdownline;

            (addressdownline, level) = getDownlineRef(userAddress, y);

            User storage downline = users[addressdownline];

            for (uint256 i = 0; i < downline.deposits.length; i++) {
                uint256 finish = downline.deposits[i].start.add(
                    plans[downline.deposits[i].plan].time.mul(1 days)
                );
                if (downline.deposits[i].start < finish) {
                    uint256 share = downline
                        .deposits[i]
                        .amount
                        .mul(plans[downline.deposits[i].plan].percent)
                        .div(PLANPER_DIVIDER);
                    uint256 from = downline.deposits[i].start;
                    uint256 to = finish < block.timestamp
                        ? finish
                        : block.timestamp;
                    //seed income
                    seedshare = share.mul(SEED_PERCENTS[level - 1]).div(
                        PERCENTS_DIVIDER
                    );

                    if (from < to) {
                        totalSeedAmount = totalSeedAmount.add(
                            seedshare.mul(to.sub(from)).div(TIME_STEP)
                        );
                    }
                }
            }
        }

        return totalSeedAmount;
    }

    function getcurrentseedincome(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];
        return (getUserSeedIncome(userAddress).sub(user.withdrawnseed));
    }

    function getUserTotalSeedWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].withdrawnseed;
    }

    function getUserTotalWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].withdrawn;
    }

    function getUserCheckpoint(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].checkpoint;
    }

    function getUserReferrer(address userAddress)
        public
        view
        returns (address)
    {
        return users[userAddress].referrer;
    }

    function getUserDownlineCount(address userAddress)
        public
        view
        returns (uint256[10] memory referrals)
    {
        return (users[userAddress].levels);
    }

    function getUserTotalReferrals(address userAddress)
        public
        view
        returns (uint256)
    {
        return
            users[userAddress].levels[0] +
            users[userAddress].levels[1] +
            users[userAddress].levels[2] +
            users[userAddress].levels[3] +
            users[userAddress].levels[4] +
            users[userAddress].levels[5] +
            users[userAddress].levels[6] +
            users[userAddress].levels[7] +
            users[userAddress].levels[8] +
            users[userAddress].levels[9];
    }

    function getUserReferralBonus(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].bonus;
    }

    function getUserReferralTotalBonus(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].totalBonus;
    }

    function getUserReferralWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].totalBonus.sub(users[userAddress].bonus);
    }

    function getUserAvailable(address userAddress)
        public
        view
        returns (uint256)
    {
        return
            getUserReferralBonus(userAddress).add(
                getUserDividends(userAddress)
            );
    }

    function getUserAmountOfDeposits(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress)
        public
        view
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
            amount = amount.add(users[userAddress].deposits[i].amount);
        }
    }

    function getUserDepositInfo(address userAddress, uint256 index)
        public
        view
        returns (
            uint8 plan,
            uint256 percent,
            uint256 amount,
            uint256 start,
            uint256 finish
        )
    {
        User storage user = users[userAddress];

        plan = user.deposits[index].plan;
        percent = plans[plan].percent;
        amount = user.deposits[index].amount;
        start = user.deposits[index].start;
        finish = user.deposits[index].start.add(
            plans[user.deposits[index].plan].time.mul(1 days)
        );
    }

    function getSiteInfo()
        public
        view
        returns (uint256 _totalInvested, uint256 _totalBonus)
    {
        return (totalInvested, totalRefBonus);
    }

    function getUserInfo(address userAddress)
        public
        view
        returns (
            uint256 totalDeposit,
            uint256 totalWithdrawn,
            uint256 totalReferrals,
            uint256 cappingLimit,
            uint8 cappingStatus
        )
    {
        return (
            getUserTotalDeposits(userAddress),
            getUserTotalWithdrawn(userAddress),
            getUserTotalReferrals(userAddress),
            users[userAddress].capping,
            users[userAddress].income_status
        );
    }


}


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}