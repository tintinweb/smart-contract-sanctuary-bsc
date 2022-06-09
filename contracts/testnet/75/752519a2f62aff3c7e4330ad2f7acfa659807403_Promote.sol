// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "../Manager/Member.sol";
import "../Utils/IERC20.sol";
import "../Utils/IUniswapV2Pair.sol";
import "../Utils/IPreacher.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface IMasterChef {
    struct _UserInfo {
        uint256 receivedReward;
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 pendingReward;
        uint256[]  _nftBalances;
        uint256 lvMore1Count;   // 擁有level > 1的nft數量
    }
    function getUser(address _user) external view returns(_UserInfo memory);
    function claimReward(uint256 _pid, address _user) external;
    function updateRewardDebt(address _user) external;
}
contract Promote is Initializable, Member {
    IERC20 public mp;

    struct UserInfo {
        uint256 rewardedAmount;
        bool isValid;
        // md 值(一代)
        uint256 numSS;
        // md 值(三代)
        uint256 numGS;
        // md 值(6代内有效地址數)
        uint256 numDown6Gen;
        uint256 weight;
        // 用戶上線
        address f;
        // 下線群組
        address[] ss;
    }

    struct User3GenWeight {
        // 1、2、3代的權重加總(不含加成)
        uint256 gen3Weight;
        uint256 gen2Weight;
        uint256 gen1Weight;
    }

    uint256 public total3GenBonusWeight;    // 全網（包含無效user權重）
    uint256 public invalid3GenBonusWeight;    // 無效user的權重加總
    uint256 public totalReward;
    uint256 public totalBurn;
    uint256[3] public genBonus;

    mapping(address => UserInfo) public userInfo;
    mapping(address => User3GenWeight) public user3GenWeight;
    mapping(address => bool) public isGamer;
    
    event NewJoin(address _user, address _f);
    event RecoverTokens(address token, uint256 amount, address to);
    event UserMint(address user, uint256 amount);

    modifier onlyPool{
        require(msg.sender == address(manager.members("nftMasterChef")), "this function can only called by pool address!");
        _;
    }
    
    modifier validSender{
        require(msg.sender == address(manager.members("updatecard")) || msg.sender == manager.members("nft"));
        _;
    }
    
    function initialize(IERC20 _mp, address genesis) public initializer {
        __initializeMember();
        mp = _mp;
        isGamer[genesis] = true;
        genBonus = [50,10,30];
    }

    function getSS(address _user) public view returns (address[] memory) {
        return userInfo[_user].ss;
    }
    
    function getUser3GenWeight(address _user) public view returns(User3GenWeight memory) {
        return user3GenWeight[_user];
    }

    function bind(address downline, address binding) external {
        address _downline = msg.sender;
        if (msg.sender == manager.members("owner")){
            _downline = downline;
        } else {
            // 只有在 user bind 時檢查
            require(msg.sender != binding, "can not bindself");
        }
        UserInfo storage user = userInfo[_downline];
        require((isGamer[binding] == true) && (isGamer[_downline] == false), "origin & upline must in game!");
        
        user.f = binding;
        isGamer[_downline] = true;

        // 更新下線群組
        userInfo[user.f].ss.push(_downline);
        emit NewJoin(_downline, user.f);
    }

    // NFT 解質押後會呼叫
    function redem(address sender, uint256, uint256 amount) external onlyPool {
        UserInfo storage user = userInfo[sender];
        require(isGamer[sender] == true, "origin must in game!");
        address f = user.f;
        address ff = userInfo[f].f;
        address fff = userInfo[ff].f;
        
        user.weight -= amount;
        IMasterChef(manager.members("nftMasterChef")).updateRewardDebt(sender);

        bool changeToInvalid = false;
        if(user.isValid && user.weight == 0) {
            userInfo[sender].isValid = false;

            if(f != address(0)) {
                evoDown(f,1);
            }
            if(ff != address(0)) {
                evoDown(ff,2);
            }
            if(fff != address(0)) {
                evoDown(fff,3);
            }
            changeToInvalid = true;
        }

        // 紀錄total3GenBonusWeight的更新值
        uint256 _total3GenBonusWeight;
        uint256 _invalid3GenBonusWeight;
        // 自己
        _total3GenBonusWeight += amount;

        uint256 tmpAmount = amount;
        address _user = sender;
        for(uint8 i=0; i < 6; i++) {
            _user = userInfo[_user].f;
            if(_user == address(0)){
                break;
            }
            // 更新上線6代的有效人數
            if (changeToInvalid) {
                userInfo[_user].numDown6Gen--;
                // 檢查是否為佈道者
                IPreacher(manager.members("PreacherAddress")).upgradePreacher(_user);
            }

            // 更新上線3代權重加總
            if(i < 3){
                IMasterChef._UserInfo memory _masterUserInfo = IMasterChef(manager.members("nftMasterChef")).getUser(_user);
                IMasterChef(manager.members("nftMasterChef")).claimReward(0, _user);
                
                // 更新全網總權重
                uint256 _bounsWeight = tmpAmount * (genBonus[i]) / (100);
                _total3GenBonusWeight += _bounsWeight;

                if(_masterUserInfo.lvMore1Count== 0){
                    // 該上線沒有權重加權
                    _invalid3GenBonusWeight += _bounsWeight;
                }

                // 用於「masterChef算力額外加成」
                if(i == 0){
                    user3GenWeight[_user].gen1Weight -= tmpAmount;
                }

                if(i == 1){
                    user3GenWeight[_user].gen2Weight -= tmpAmount;
                }

                if(i == 2){
                    user3GenWeight[_user].gen3Weight -= tmpAmount;
                }

                if(_masterUserInfo.lvMore1Count > 0) {
                    IMasterChef(manager.members("nftMasterChef")).updateRewardDebt(_user);
                }
            }
        }

        // 更新全網三代bouns權重
        total3GenBonusWeight -= _total3GenBonusWeight;
        invalid3GenBonusWeight -= _invalid3GenBonusWeight;
    }


    // 代數gen 1~3
    function evoDown(address _user, uint8 gen) internal {
        // 更新 MD 值
        if(gen == 1){
            // 直推
            userInfo[_user].numSS--;
        }
        userInfo[_user].numGS--;
    }
    
    // NFT 質押後會呼叫
    function newDeposit(address sender,uint256, uint256 amount) external onlyPool {
        require(isGamer[sender] == true, "origin must in game!");
        UserInfo storage user = userInfo[sender];

        address f = user.f;
        address ff = userInfo[f].f;
        address fff = userInfo[ff].f;

        // 累加(自己)到總權重
        user.weight += amount;

        bool changeToValid = false;
        // 質押後，該用戶變為有效用戶
        if(!user.isValid && user.weight > 0) {
            userInfo[sender].isValid = true;
            evo(f,1);
            if (ff != address(0)) {
                evo(ff, 2);
            }
            if (fff != address(0)) {
                evo(fff, 3);
            }
            changeToValid = true;
        }

        // 更新權重
        // 自己

        // 紀錄total3GenBonusWeight的更新值
        uint256 _total3GenBonusWeight;
        uint256 _invalid3GenBonusWeight;
        // 自己
        _total3GenBonusWeight += amount;

        uint256 tmpAmount = amount;
        address _user = sender;
        for(uint8 i=0; i < 6; i++) {
            _user = userInfo[_user].f;
            if(_user == address(0)){
                break;
            }
            // 更新上線6代的有效人數
            if (changeToValid) {
                userInfo[_user].numDown6Gen++;
                // 檢查是否為佈道者
                IPreacher(manager.members("PreacherAddress")).upgradePreacher(_user);
            }

            // 更新上線3代權重加總
            if(i < 3){
                // 幫上線領獎
                IMasterChef(manager.members("nftMasterChef")).claimReward(0, _user);
                IMasterChef._UserInfo memory _masterChefUser = IMasterChef(manager.members("nftMasterChef")).getUser(_user);

                // 更新全網總權重
                uint256 _bounsWeight = tmpAmount * (genBonus[i]) / (100);
                _total3GenBonusWeight += _bounsWeight;

                if(_masterChefUser.lvMore1Count == 0){
                    _invalid3GenBonusWeight += _bounsWeight;
                }

                // 用於「masterChef算力額外加成」
                if(i == 0){
                    user3GenWeight[_user].gen1Weight += tmpAmount;
                }

                if(i == 1){
                    user3GenWeight[_user].gen2Weight += tmpAmount;
                }

                if(i == 2){
                    user3GenWeight[_user].gen3Weight += tmpAmount;
                }
                if(_masterChefUser.lvMore1Count > 0){
                    // 幫上線計算負債值
                    IMasterChef(manager.members("nftMasterChef")).updateRewardDebt(_user);
                }
            }
        }
        // 更新全網三代bouns權重
        total3GenBonusWeight += _total3GenBonusWeight;
        invalid3GenBonusWeight += _invalid3GenBonusWeight;
    }

    // 更上線信息（如果提升了等级将沉淀奖励）
    function evo(address _user, uint8 gen) internal {
        // 更新 MD 值
        if(gen == 1){
            // 直推
            userInfo[_user].numSS++;
        }
        userInfo[_user].numGS++;
    }
    function userMint(address _user, uint256 amount) external validSender {
        // 查詢直推有效人數
        // 直推有效1人可獲得第1代鑄造分潤、直推有效2人可獲得第2代鑄造分潤、依此類推至18代。
        uint256 numSS = userInfo[_user].numSS;

        
        // 累計總派發+銷毀
        uint256 totalPay;

        address nGenUser = userInfo[_user].f;
        for(uint8 gen = 1; gen <= 18; gen++){
            if(nGenUser == address(0)) {
                break;
            }

            if(numSS < gen){
                break;
            }
            // 預計派發金額
            uint256 needPay;
            // 1代 20%
            // 2-3代 5%（10%）
            // 4-8代 10%（50%）
            // 9-18代 2%（20%）
            if(gen == 1) {
                needPay = amount * 20 / 100;
            }else if(gen >= 2 && gen <= 5){
                needPay = amount * 5 / 100;
            }else if(gen >= 4 && gen <= 8){
                needPay = amount * 10 / 100;
            }else if(gen >= 9 && gen <= 18){
                needPay = amount * 2 / 100;
            }

            totalPay += needPay;

            // 達標轉帳
            mp.transfer(nGenUser, needPay);
            userInfo[nGenUser].rewardedAmount += needPay;
            totalReward += needPay;
            emit UserMint(nGenUser, needPay);

            // 再找下一代上線
            nGenUser = userInfo[nGenUser].f;
        }

        // 累計總銷毀
        uint256 needBurn = amount - totalPay;
        
        mp.burn(needBurn);
        totalBurn += needBurn;
    }
    function getUser(address _user) external view returns (UserInfo memory) {
        return userInfo[_user];
    }
    
    // 質押罕見級以上變動時，需更新無效權重
    function updateInvalid3GenBonusWeight(address _user, bool isValid) external onlyPool {
        // isValid是新狀態
        // sender已經領獎(該func只有sender使用)
        // IMasterChef(manager.members("nftMasterChef")).claimReward(0, _user);

        User3GenWeight memory _user3Gen = user3GenWeight[_user];
        uint256 userUplineWeight;
        userUplineWeight = userUplineWeight + (_user3Gen.gen3Weight * (genBonus[2]) / (100));
        userUplineWeight = userUplineWeight + (_user3Gen.gen2Weight * (genBonus[1]) / (100));
        userUplineWeight = userUplineWeight + (_user3Gen.gen1Weight * (genBonus[0]) / (100));

        if(isValid){
            // 變有效用戶
            invalid3GenBonusWeight = invalid3GenBonusWeight - (userUplineWeight);
        }else{
            // 變無效用戶
            invalid3GenBonusWeight = invalid3GenBonusWeight + (userUplineWeight);
        }
    }
    function recoverTokens(address token, uint256 amount, address to) external {
        require(msg.sender == manager.members("owner"), "owner");
        require(IERC20(token).balanceOf(address(this)) >= amount, "balance");
        IERC20(token).transfer(to, amount);
        emit RecoverTokens(token, amount, to);
    }
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";
import "./Manager.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
abstract contract Member is Initializable, ContractOwner {
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

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
    function totalSupply() external view returns(uint256);
    function balanceOf(address owner) external view returns(uint256);
    function allowance(address owner, address spender) external view returns(uint256);
    
    function approve(address spender, uint256 value) external returns(bool);
    function transfer(address to, uint256 value) external returns(bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function burn(uint256 amount) external;
    function mint(address to, uint256 amount) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function balanceOf(address owner) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IPreacher {
    function update(uint256 amount) external;
    function upgradePreacher(address _user) external;
    function checkIsPreacher(address _user) external view returns (bool);
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
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Manager is Initializable, ContractOwner {
    mapping(string => address) public members;
    
    mapping(address => mapping(string => bool)) public userPermits;
    

    function initialize() public initializer {
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