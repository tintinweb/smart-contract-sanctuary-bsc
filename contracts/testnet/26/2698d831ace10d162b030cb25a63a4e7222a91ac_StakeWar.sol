// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

pragma experimental ABIEncoderV2;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../Manager/Member.sol";
import "../Utils/SafeMath.sol";


interface INFT{

    struct starAttributesStruct{
      address origin; // 发布者
      uint256 power; // 算力
      bool offical;
      uint256 createTime; // 鑄造時間
      uint256 openTime; // 開盒時間
      string IpfsHash; // hash
      uint256 level; // 無限等級
      uint8 ethnicity; // 種族類型
      uint256 price; // 當下等值 mca
    }
    function getStarAttributes(uint256 _tokenID) external view returns(starAttributesStruct memory nftAttr);
    
}

interface IMasterChef {
    function StakeWarDistribute(address winerUser, address loserUser, uint256 bonus) external;
    function userStakeTokenId(address owner) external view returns(uint256 tokenId);
}


interface IRandom {
    function random(uint256 randomLen) external returns(uint256[] memory);
}

contract StakeWar is Initializable, OwnableUpgradeable, Member {
    using SafeMath for uint256;

    INFT nft;

    mapping(uint8 => uint256) public ethnicityCount; // 種族數量
    mapping(uint8 => uint256[]) public ethnicityTokenList; // 種族NFT列表
    mapping(uint256 => uint256) public ethnicityTokenListIdx; // 種族NFT列表array idx
    mapping(uint256 => uint256) public lastFightBlock;
    mapping(uint256 => address) public tokenIdToStaker;

    uint256 public fightLockBlock;

    event Fight(address attcker, uint256 attckerTokenId,address defender,uint256 defenderTokenId, bool result, uint256 rate, uint256 bonus);


    modifier onlyNftPool{
        require(msg.sender == address(manager.members("NFTStakePool")), "this function can only called by pool address!");
        _;
    }

    function initialize(INFT _nft) public initializer {
        __initializeMember();
        __Ownable_init();
        nft = _nft;
        fightLockBlock = 14400;
    }

    function _random() internal returns(uint256) {
        require(manager.members("random") != address(0), "empty members random");
        uint256[] memory r = IRandom(manager.members("random")).random(1);
        return r[0];
    }

    // 質押後呼叫
    function pushEthnicityNFT(uint256 tokenId) external onlyNftPool {
        INFT.starAttributesStruct memory nftAttr = INFT(nft).getStarAttributes(tokenId);
        // 盲盒不能參與質押戰爭
        if(nftAttr.level != 0){

            uint8 ethnicity = nftAttr.ethnicity;
            ethnicityCount[ethnicity] += 1;
            ethnicityTokenList[ethnicity].push(tokenId);
            ethnicityTokenListIdx[tokenId] = ethnicityTokenList[ethnicity].length - 1;
            
            tokenIdToStaker[tokenId] = tx.origin;
            lastFightBlock[tokenId] = 0;
        }
    }

    // 解質押後呼叫
    function removeEthnicityNFT(uint256 tokenId) external onlyNftPool {
        INFT.starAttributesStruct memory nftAttr = INFT(nft).getStarAttributes(tokenId);
        // 盲盒不能參與質押戰爭
        if(nftAttr.level != 0){
            uint8 ethnicity = nftAttr.ethnicity;

            uint256 idx = ethnicityTokenListIdx[tokenId]; // 獲取種族NFT array idx
            uint256 totalEthnicity = ethnicityCount[ethnicity]; // 種族總數量

            // 種族總數量 - 1
            ethnicityCount[ethnicity] = totalEthnicity - 1;

            if (totalEthnicity != (idx + 1)) {
                // 刪除array中間
                // 把最後item移到刪除的idx位置
                ethnicityTokenList[ethnicity][idx] = ethnicityTokenList[ethnicity][totalEthnicity - 1];
                ethnicityTokenListIdx[ethnicityTokenList[ethnicity][totalEthnicity - 1]] = idx;
            }
            
            // 刪除array最後一個
            ethnicityTokenList[ethnicity].pop();

            delete lastFightBlock[tokenId];
            delete tokenIdToStaker[tokenId];
        }
    }

    function typeMatchupChart(uint8 ethnicityA,uint8 ethnicityB) public pure returns(uint256 percentage) {
        require(ethnicityA >= 1 && ethnicityA <= 3, "ethnicityA over range");
        require(ethnicityB >= 1 && ethnicityB <= 3, "ethnicityB over range");
        require(ethnicityA != ethnicityB, "ethnicityA and ethnicityB need diff");

        bool effective = false;

        // 人类 《克制》服务型机器人《克制》邪恶机械体《克制》人类
        if (ethnicityA == 1) {
            effective = ethnicityB == 2 ? true : false;
        } else if (ethnicityA == 2) {
            effective = ethnicityB == 3 ? true : false;
        } else if (ethnicityA == 3) {
            effective = ethnicityB == 1 ? true : false;
        }

        return effective ? 115 : 85;
    }

    function bonusCalculator(uint256 winerPercentage) internal pure returns(uint256) {
        if (winerPercentage <= 5500) {
            // 最高勝率 0.00~0.55 收益 20%
            return 20;
        } else if ((winerPercentage > 5500) && (winerPercentage <= 6500)) {
            // 最高勝率 0.55~0.65 收益 14%
            return 14;
        } else if ((winerPercentage > 6500) && (winerPercentage <= 7500)) {
            // 最高勝率 0.65~0.75 收益 10%
            return 10;
        } else if ((winerPercentage > 7500) && (winerPercentage <= 8500)) {
            // 最高勝率 0.75~0.85 收益 7%
            return 7;
        } else {
        // } else if ((winerPercentage > 8500) && (winerPercentage <= 9500)) {
            // 最高勝率 0.85~0.95 收益 5%
            return 5;
        }
    }

    // 攻擊
    function fight() public {
        uint256 tokenId = IMasterChef(manager.members("NFTStakePool")).userStakeTokenId(msg.sender);

        // 檢查 發起攻擊的 NFT Owner
        require(tokenId != 0, "not stake nft");

        // 質押需超過 14400 個 block 才能發起攻擊
        require(block.number >= (lastFightBlock[tokenId] + fightLockBlock) , "can't fight");

        lastFightBlock[tokenId] = block.number;

        INFT.starAttributesStruct memory nftAttr_1 = INFT(nft).getStarAttributes(tokenId);

        // 檢查是否為盲盒
        require(nftAttr_1.level > 0, "this nft can't fight");
        uint8 ethnicity = nftAttr_1.ethnicity;
        uint256 powerA = nftAttr_1.power;
        
        // 尋找其他種族
        uint256 randomNum = _random();
        uint8 findEthnicityRandom = uint8(randomNum % 2) ;

        uint8 findEthnicity;
        uint8[2] memory findEthnicitys;
        if(ethnicity == 1){
            findEthnicitys =[2,3];
            findEthnicity = findEthnicitys[findEthnicityRandom];
        }else if(ethnicity == 2){
            findEthnicitys =[1,3];
            findEthnicity = findEthnicitys[findEthnicityRandom];
        }else{
            findEthnicitys =[1,2];
            findEthnicity = findEthnicitys[findEthnicityRandom];
        }

        // 對手池子內至少要有 NFT
        if(ethnicityCount[findEthnicity] == 0){
            findEthnicity = findEthnicityRandom == 0 ? findEthnicitys[1] : findEthnicitys[0];

            require(ethnicityCount[findEthnicity] > 0, "can't found user");
        }
    

        // 對手克制表
        uint256 powerA_after_power_bonus = powerA.mul(typeMatchupChart(ethnicity, findEthnicity)).div(100);

        uint256 randomNum2 = _random();
        uint256 findIdx = randomNum2 % ethnicityCount[findEthnicity];

        uint256 tokenIdB = ethnicityTokenList[findEthnicity][findIdx];
        INFT.starAttributesStruct memory nftAttr_2 = INFT(nft).getStarAttributes(tokenIdB);
        
        uint256 powerB = nftAttr_2.power;

        // PK
        uint256 allPower = powerA_after_power_bonus.add(powerB);
        // 計算到小數點後兩位
        uint256 percentageA = powerA_after_power_bonus.mul(10000).div(allPower);

        // 戰力最高上限是 95% (9500)，最低 5%
        if (percentageA > 9500) {
            percentageA = 9500;
        } else if (percentageA < 500) {
            percentageA = 500;
        }

        bool isWinner = false;
        uint256 randomNum3 = _random();
        // p 隨機數 1-100.00%(一樣到小數點後兩位)
        uint256 p = randomNum3 % 10000 + 1;

        uint256 _all = 10000;
        uint256 percentageB = _all.sub(percentageA);

        if (p <= percentageA) {
            isWinner = true;
        }
        address originB = tokenIdToStaker[tokenIdB];
        // 贏的話，使用贏家的勝率下去看損益區間
        uint256 bonus = 0;
        if (isWinner) {
            // 贏的話使用贏家勝率
            bonus = bonusCalculator(percentageA);

            // 呼叫 NFT質押池合約，獎賞分配
            IMasterChef(manager.members("NFTStakePool")).StakeWarDistribute(msg.sender, originB, bonus);
        } else {
            // 輸的話使用輸家勝率
            bonus = bonusCalculator(percentageB);

            // 呼叫 NFT質押池合約，獎賞分配
            IMasterChef(manager.members("NFTStakePool")).StakeWarDistribute(originB,msg.sender, bonus);
        }
        
        emit Fight(msg.sender, IMasterChef(manager.members("NFTStakePool")).userStakeTokenId(msg.sender), originB, tokenIdB, isWinner, p, bonus);
    }

    function setFightLockBlock(uint256 _fightLockBlock) external {
        require(msg.sender == manager.members("owner"), "owner");
        fightLockBlock = _fightLockBlock;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

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
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";
import "./Manager.sol";

abstract contract Member is ContractOwner {
    modifier CheckPermit(string memory permit) {
        require(manager.userPermits(msg.sender, permit),
            "no permit");
        _;
    }
    
    Manager public manager;

    function __initializeMember() internal initializer {
        contractOwner = msg.sender;
    }

    function setManager(address addr) external ContractOwnerOnly {
        manager = Manager(addr);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

pragma solidity ^0.8.0;
// SPDX-License-Identifier: SimPL-2.0

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
abstract contract ContractOwner is Initializable {
    address public contractOwner;
    
    modifier ContractOwnerOnly {
        require(msg.sender == contractOwner, "contract owner only");
        _;
    }
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";

contract Manager is ContractOwner {
    mapping(string => address) public members;
    
    mapping(address => mapping(string => bool)) public userPermits;
    
    constructor () {
        contractOwner = msg.sender;
    }

    function setMember(string memory name, address member)
        external ContractOwnerOnly {
        
        members[name] = member;
    }
    
    function setUserPermit(address user, string memory permit,
        bool enable) external ContractOwnerOnly {
        
        userPermits[user][permit] = enable;
    }
    
    function getTimestamp() external view returns(uint256) {
        return block.timestamp;
    }
}