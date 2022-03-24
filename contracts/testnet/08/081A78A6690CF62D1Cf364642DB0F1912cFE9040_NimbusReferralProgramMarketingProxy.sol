/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

pragma solidity =0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
    function vest(address user, uint amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferBNB(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}

interface INimbusReferralProgramUsers {
    function userSponsor(uint user) external view returns (uint);
    function registerUser(address user, uint category) external returns (uint);
    function registerUserBySponsorAddress(address user, address sponsorAddress, uint category) external returns (uint);
    function registerUserBySponsorId(address user, uint sponsorId, uint category) external returns (uint);
    function userIdByAddress(address user) external view returns (uint);
    function userAddressById(uint id) external view returns (address);
    function userSponsorAddressByAddress(address user) external view returns (address);
    function getUserReferrals(address user) external view returns (uint[] memory);
}

contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed to);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Ownable: Caller is not the owner");
        _;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transferOwnership(address transferOwner) external onlyOwner {
        require(transferOwner != newOwner);
        newOwner = transferOwner;
    }

    function acceptOwnership() virtual external {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract NimbusReferralProgramMarketingStorage is Ownable {  
        struct Qualification {
            uint Number;
            uint TotalTurnover; 
            uint Percentage; 
            uint FixedReward;
            uint MaxUpdateLevel;
        }

        struct UpgradeInfo {
            uint date;
            uint prevLevel;
            uint nextLevel;
        }

        mapping (address => uint) public upgradeNonces;
        mapping (address => mapping (uint => UpgradeInfo)) public upgradeInfos;
        mapping (address => mapping (uint => mapping(address => uint))) public prevTurnovers;

        IBEP20 public NBU;
        INimbusReferralProgramUsers rpUsers;

        uint public totalFixedAirdropped;
        uint public totalVariableAirdropped;
        uint public airdropProgramCap;

        uint constant PERCENTAGE_PRECISION = 1e5;
        uint constant MARKETING_CATEGORY = 3;
        uint constant REFERRAL_LINES = 1;

        mapping(address => bool) public isRegionManager;
        mapping(address => bool) public isHeadOfLocation;
        mapping(address => address) public userHeadOfLocations;
        mapping(address => address) public headOfLocationRegionManagers;
        address[] public regionalManagers;
        address[] public headOfLocations;

        mapping(address => uint) public headOfLocationTurnover; //contains the whole structure turnover (more than 6 lines), including userStructureTurnover (only 6 lines turnover)
        mapping(address => uint) public regionalManagerTurnover;
        mapping(address => uint) public userPersonalTurnover;
        mapping(address => uint) public userQualificationLevel;
        mapping(address => uint) public userQualificationOrigin; //0 - organic, 1 - imported, 2 - set
        mapping(address => uint) public userMaxLevelPayment;
        mapping(address => uint) public userUpgradeAllowedToLevel;

        uint public qualificationsCount;
        mapping(uint => Qualification) public qualifications;

        mapping(address => bool) public isAllowedContract;
        mapping(address => bool) public registrators;
        mapping(address => bool) public allowedUpdaters;
        mapping(address => bool) public allowedVerifiers;

        uint public levelLockPeriod;

        event Rescue(address indexed to, uint amount);
        event RescueToken(address indexed token, address indexed to, uint amount);

        event AirdropFixedReward(address indexed user, uint fixedAirdropped, uint indexed qualification);
        event AirdropVariableReward(address indexed user, uint variableAirdropped, uint indexed qualification);
        event QualificationUpdated(address indexed user, uint indexed previousQualificationLevel, uint indexed qualificationLevel, uint systemFee);

        event UserRegistered(address user, uint indexed sponsorId);
        event UserRegisteredWithoutHeadOfLocation(address user, uint indexed sponsorId);

        event LevelLockPeriodSet(uint levelLockPeriod);
        event PendingQualificationUpdate(address indexed user, uint indexed previousQualificationLevel, uint indexed qualificationLevel);

        event UpdateReferralProfitAmount(address indexed user, uint amount, uint indexed line);
        event UpdateHeadOfLocationTurnover(address indexed headOfLocation, uint amount);
        event UpdateRegionalManagerTurnover(address indexed regionalManager, uint amount);
        event UpdateAirdropProgramCap(uint indexed newAirdropProgramCap);
        event UpdateQualification(uint indexed index, uint indexed totalTurnoverAmount, uint indexed percentage, uint fixedReward, uint maxUpdateLevel);
        event AddHeadOfLocation(address indexed headOfLocation, address indexed regionalManager);
        event RemoveHeadOfLocation(address indexed headOfLocation);
        event AddRegionalManager(address indexed regionalManager);
        event RemoveRegionalManager(address indexed regionalManager);
        event UpdateRegionalManager(address indexed user, bool indexed isManager);
        event ImportUserTurnoverSet(address indexed user, uint personalTurnover);
        event ImportUserMaxLevelPayment(address indexed user, uint maxLevelPayment, bool indexed addToCurrentPayment);
        event AllowLevelUpgradeForUser(address indexed user, uint currentLevel, uint allowedLevel);
        event ImportUserTurnoverUpdate(address indexed user, uint newPersonalTurnoverAmount, uint previousPersonalTurnoverAmount);
        event ImportHeadOfLocationTurnoverUpdate(address indexed headOfLocation, uint previousTurnover, uint newTurnover);
        event ImportHeadOfLocationTurnoverSet(address indexed headOfLocation, uint turnover);
        event ImportRegionalManagerTurnoverUpdate(address indexed headOfLocation, uint previousTurnover, uint newTurnover);
        event ImportRegionalManagerTurnoverSet(address indexed headOfLocation, uint turnover);
        event ImportUserHeadOfLocation(address indexed user, address indexed headOfLocation);
        event UpgradeUserQualification(address indexed user, uint indexed previousQualification, uint indexed newQualification, uint newStructureTurnover);
    }

    contract NimbusReferralProgramMarketingProxy is NimbusReferralProgramMarketingStorage {
        address public target;
        
        event SetTarget(address indexed newTarget);

        constructor(address _newTarget) NimbusReferralProgramMarketingStorage() {
            _setTarget(_newTarget);
        }

        fallback() external {
            if (gasleft() <= 2300) {
                return;
            }

            address target_ = target;
            bytes memory data = msg.data;
            assembly {
                let result := delegatecall(gas(), target_, add(data, 0x20), mload(data), 0, 0)
                let size := returndatasize()
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, size)
                switch result
                case 0 { revert(ptr, size) }
                default { return(ptr, size) }
            }
        }

        function setTarget(address _newTarget) external onlyOwner {
            _setTarget(_newTarget);
        }

        function _setTarget(address _newTarget) internal {
            require(Address.isContract(_newTarget), "Target not a contract");
            target = _newTarget;
            emit SetTarget(_newTarget);
        }
    }