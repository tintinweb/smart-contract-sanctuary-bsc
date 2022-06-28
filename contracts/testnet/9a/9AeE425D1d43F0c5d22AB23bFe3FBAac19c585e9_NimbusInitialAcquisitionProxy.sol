/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

abstract contract Pausable is Ownable {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }


    function pause() external onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

interface IBEP165 {
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IBEP165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IBEP165).interfaceId;
    }
}

interface IBEP721 is IBEP165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface ISmartLP is IBEP721 {
    function buySmartLPforBNB() payable external;
    function buySmartLPforWBNB(uint256 amount) external;
    function buySmartLPforToken(uint256 amount) external;
    function withdrawUserRewards(uint tokenId) external;
    function tokenCount() external view returns(uint);
    function getUserTokens(address user) external view returns (uint[] memory);
    function WBNB() external view returns(address);
}

interface IStakingMain is IBEP721 {
    function buySmartStaker(uint256 _setNum, uint _amount) external payable;
    function withdrawReward(uint256 _id) external;
    function tokenCount() external view returns(uint);
    function getUserTokens(address user) external view returns (uint[] memory);
}

interface IVestingNFT is IBEP721 {
    function safeMint(address to, string memory uri, uint nominal, address token) external;
    function totalSupply() external view returns (uint256);
    function lastTokenId() external view returns (uint256);
    function burn(uint256 tokenId) external;
    struct Denomination {
        address token;
        uint256 value;
    }
    function denominations(uint256 tokenId) external returns (Denomination memory denomination);
}

interface INimbusReferralProgram {
    function lastUserId() external view returns (uint);
    function userSponsorByAddress(address user)  external view returns (uint);
    function userIdByAddress(address user) external view returns (uint);
    function userAddressById(uint id) external view returns (address);
    function userSponsorAddressByAddress(address user) external view returns (address);
}

interface INimbusStakingPool {
    function stakeFor(uint amount, address user) external;
    function balanceOf(address account) external view returns (uint256);
    function stakingToken() external view returns (IBEP20);
    function rewardsToken() external view returns (IBEP20);
    function getRewardForUser(address user) external;
}

interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function approve(address spender, uint value) external returns (bool);
}

interface INimbusRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface INimbusReferralProgramMarketing {
    function registerUser(address user, uint sponsorId) external returns(uint userId);
    function updateReferralProfitAmount(address user, uint amount) external;
    function registerUserBySponsorId(address user, uint sponsorId, uint category) external returns (uint);
    function userPersonalTurnover(address user) external returns(uint);
}

interface IPriceFeed {
    function queryRate(address sourceTokenAddress, address destTokenAddress) external view returns (uint256 rate, uint256 precision);
    function wbnbToken() external returns(address);
}


library Address {
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in construction, 
        // since the code is only stored at the end of the constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract NimbusInitialAcquisitionStorage is Ownable, Pausable {
    IBEP20 public SYSTEM_TOKEN;
    address public NBU_WBNB;
    INimbusReferralProgram public referralProgram;
    INimbusReferralProgramMarketing public referralProgramMarketing;
    IPriceFeed public priceFeed;

    IVestingNFT public nftVesting;
    ISmartLP public nftCashback;
    IStakingMain public nftSmartStaker;

    string public nftVestingUri;

    bool public allowAccuralMarketingReward;

    mapping(uint => INimbusStakingPool) public stakingPools;
    mapping(address => uint) public userPurchases;
    mapping(address => uint) public userPurchasesEquivalent;

    address public recipient;                      

    INimbusRouter public swapRouter;                
    mapping (address => bool) public allowedTokens;
    address public swapToken;                       
    
    uint public sponsorBonus;
    uint public swapTokenAmountForSponsorBonusThreshold;  
    mapping(address => uint) public unclaimedSponsorBonus;
    mapping(address => uint) public unclaimedSponsorBonusEquivalent;

    bool public usePriceFeeds;

    uint public cashbackBonus;
    uint public swapTokenAmountForCashbackBonusThreshold;  

    bool public vestingRedeemingAllowed;

    event BuySystemTokenForToken(address indexed token, uint indexed stakingPool, uint tokenAmount, uint systemTokenAmount, uint swapTokenAmount, address indexed systemTokenRecipient);
    event ProcessSponsorBonus(address indexed user, address indexed nftContract, uint nftTokenId, uint amount, uint indexed timestamp);
    event AddUnclaimedSponsorBonus(address indexed sponsor, address indexed user, uint systemTokenAmount, uint swapTokenAmount);

    event VestingNFTRedeemed(address indexed nftVesting, uint indexed tokenId, address user, address token, uint value);

    event UpdateTokenSystemTokenWeightedExchangeRate(address indexed token, uint indexed newRate);
    event ToggleUsePriceFeeds(bool indexed usePriceFeeds);
    event ToggleVestingRedeemingAllowed(bool indexed vestingRedeemingAllowed);
    event Rescue(address indexed to, uint amount);
    event RescueToken(address indexed token, address indexed to, uint amount);

    event AllowedTokenUpdated(address indexed token, bool allowance);
    event SwapTokenUpdated(address indexed swapToken);
    event SwapTokenAmountForSponsorBonusThresholdUpdated(uint indexed amount);
    event SwapTokenAmountForCashbackBonusThresholdUpdated(uint indexed amount);

    event ProcessCashbackBonus(address indexed to, address indexed nftContract, uint nftTokenId, address purchaseToken, uint amount, uint indexed timestamp);
    event UpdateCashbackBonus(uint indexed cashbackBonus);
    event UpdateNFTVestingContract(address indexed nftVestingAddress, string nftVestingUri);
    event UpdateNFTCashbackContract(address indexed nftCashbackAddress);
    event UpdateNFTSmartStakerContract(address indexed nftSmartStakerAddress);
    event UpdateVestingParams(uint vestingFirstPeriod, uint vestingSecondPeriod);
    event ImportUserPurchases(address indexed user, uint amount, bool indexed isEquivalent, bool indexed addToExistent);
    event ImportSponsorBonuses(address indexed user, uint amount, bool indexed isEquivalent, bool indexed addToExistent);

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

contract NimbusInitialAcquisitionProxy is NimbusInitialAcquisitionStorage {
        address public target;
        
        event SetTarget(address indexed newTarget);

        constructor(address _newTarget) NimbusInitialAcquisitionStorage() {
            _setTarget(_newTarget);
        }

        fallback() external payable {
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