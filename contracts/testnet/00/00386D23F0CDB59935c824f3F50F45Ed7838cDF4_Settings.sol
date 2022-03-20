pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../Interfaces/ISettings.sol";

contract Settings is Initializable, OwnableUpgradeable, ISettings {
    address public override factory;

    uint256 public override boxPrice;

    uint256 public override totalNum;
    uint256 public override fomoRate;
    uint256 public override inviterRate;
    uint256 public override inviterNum;

    uint256 public override inviterRate1;

    uint256 public override  priceStep;

    uint256 public override  normalPrice;
    uint256 public override  giftBagPrice;

    uint private randomNonce;

    uint8 public  override godQuality;

    uint256 public override toInviter;

    uint256 public override toDividendsPool;

    uint256 public override toBonusesPool;

    uint256 public override beInviterAmt;

    uint256 public override toDev;

    address  public override defaultInviter;

    address public override dev;

    address public override operator;

    address public override fomo;

    uint256[5] urCount;

    bool public urActive;

    uint constant private  maxRandom = 450100;

    mapping(uint8 => uint256) public override stakePower;
    mapping(uint8 => uint16[]) public godSource;

    function setFactory(address _factory) public onlyOwner {
        factory = _factory;
    }

    function setOperator(address _operator) public onlyOwner {
        operator = _operator;
    }

    function setFomo(address _fomo) public onlyOwner {
        fomo = _fomo;
    }

    modifier onlyFactory() {
        require(factory == msg.sender, "Settings: only factory");
        _;
    }

    function initialize() public initializer {
        totalNum = 500100;
        inviterNum = 10;
        inviterRate = 10;
        inviterRate1 = 5;
        fomoRate = 10;
        __Ownable_init();
        defaultInviter = msg.sender;
        dev = msg.sender;
        boxPrice = 3 * (10 ** 18);
        priceStep = 5 * (10 ** 12);
        //test price todo 0.05
        normalPrice = 5 * (10 ** 14);
        giftBagPrice = 5 * (10 ** 16);
        godQuality = uint8(6);
        toInviter = 500;
        toDividendsPool = 3325;
        toBonusesPool = 3325;
        beInviterAmt = 100 * (10 ** 18);
        toDev = 2850;
        urCount = [0, 0, 0, 0, 0];
        urActive = true;

        //stakePower
        stakePower[1] = 1;
        stakePower[2] = 3;
        stakePower[3] = 10;
        stakePower[4] = 32;
        stakePower[5] = 586;

        godSource[0] = [uint16(1284), uint16(772), uint16(512), uint16(259), uint16(258)];
        godSource[1] = [uint16(1282), uint16(771), uint16(515), uint16(513), uint16(257), uint16(256)];
        godSource[2] = [uint16(1283), uint16(1024), uint16(774), uint16(516), uint16(260)];
        godSource[3] = [uint16(1280), uint16(770), uint16(769), uint16(514)];
        godSource[4] = [uint16(1281), uint16(773), uint16(768), uint16(516), uint16(260)];
        godSource[5] = [uint16(1285), uint16(1025), uint16(775), uint16(517), uint16(261)];
    }


    function getGiftBagInfo(uint256 random, bool spec) private pure returns (uint8 quality, uint8 index){
        if (spec) {
            quality = uint8(5);
            if (random < 60) {
                index = uint8(random % 6);
            } else {
                index = 6 + uint8(random % 9);
            }
        } else {
            if (random < 100) {
                quality = uint8(4);
                index = uint8(random % 2);
            } else if (random < 4260) {
                quality = uint8(4);
                index = 2 + uint8(random % 13);
            }
            else if (random < 5340) {
                quality = uint8(3);
                index = uint8(random % 4);
            } else if (random < 9340) {
                quality = uint8(3);
                index = 4 + uint8(random % 8);
            }
            else if (random < 11140) {
                quality = uint8(2);
                index = uint8(random % 4);
            } else if (random < 21700) {
                quality = uint8(2);
                index = 4 + uint8(random % 16);
            }

            else if (random < 23460) {
                quality = uint8(1);
                index = uint8(random % 2);
            } else if (random < 27000) {
                quality = uint8(1);
                index = 2 + uint8(random % 4);
            } else {
                quality = uint8(1);
                index = 6 + uint8(random % 25);
            }
        }

    }

    function getBagCards() public override onlyFactory returns (uint8[] memory qualityNums, uint8[] memory indexNums){
        qualityNums = new uint8[](100);
        indexNums = new uint8[](100);
        uint256 randomNonceMem = randomNonce;
        // spec card
        uint random = uint(keccak256(abi.encodePacked(randomNonceMem, msg.sender, block.difficulty, block.timestamp))) % 500;
        (uint8 quality,uint8  index) = getGiftBagInfo(random, true);
        qualityNums[0] = quality;
        indexNums[0] = index;
        for (uint i = 1; i < 100; i++) {
            randomNonceMem++;
            uint random = uint(keccak256(abi.encodePacked(randomNonceMem, msg.sender, block.difficulty, block.timestamp))) % 49500;
            (uint8 quality,uint8  index) = getGiftBagInfo(random, false);
            qualityNums[i] = quality;
            indexNums[i] = index;
        }
        randomNonce = randomNonceMem;
    }

    function getBatchInfo(uint256 random) private pure returns (uint8 quality, uint8 index){
        if (random < 720) {
            quality = uint8(5);
            index = uint8(random % 6);
        } else if (random < 4072) {
            quality = uint8(5);
            index = 6 + uint8(random % 8);
        } else if (random < 4495) {
            quality = uint8(5);
            index = uint8(14);
        }
        else if (random < 10811) {
            quality = uint8(4);
            index = uint8(random % 2);
        } else if (random < 48335) {
            quality = uint8(4);
            index = 2 + uint8(random % 13);
        }
        else if (random < 58335) {
            quality = uint8(3);
            index = uint8(random % 2);
        } else if (random < 77275) {
            quality = uint8(3);
            index = 2 + uint8(random % 4);
        } else if (random < 87275) {
            quality = uint8(3);
            index = 6 + uint8(random % 2);
        } else if (random < 123275) {
            quality = uint8(3);
            index = 8 + uint8(random % 8);
        }
        else if (random < 136275) {
            quality = uint8(2);
            index = uint8(random % 2);
        } else if (random < 160475) {
            quality = uint8(2);
            index = 2 + uint8(random % 4);
        } else if (random < 253915) {
            quality = uint8(2);
            index = 6 + uint8(random % 16);
        }
        else if (random < 266605) {
            quality = uint8(1);
            index = uint8(random % 2);
        } else if (random < 291965) {
            quality = uint8(1);
            index = 2 + uint8(random % 4);
        } else {
            quality = uint8(1);
            index = 6 + uint8(random % 25);
        }
    }

    function getBatchCard(uint256 num) public override onlyFactory returns (uint8[] memory qualityNums, uint8[] memory indexNums){
        qualityNums = new uint8[](num);
        indexNums = new uint8[](num);
        uint256 randomNonceMem = randomNonce;
        for (uint i = 0; i < num; i++) {
            randomNonceMem++;
            uint random = uint(keccak256(abi.encodePacked(randomNonceMem, msg.sender, block.difficulty, block.timestamp))) % maxRandom;
            (uint8 quality,uint8  index) = getBatchInfo(random);
            qualityNums[i] = quality;
            indexNums[i] = index;
        }
        randomNonce = randomNonceMem;
    }

    function getUrCard(uint256 index) public override onlyFactory {
        require(urCount[index] < 100, 'no left');
        urCount[index]++;
    }

    function getGodSource(uint8 targetGod) public view override returns (uint16[] memory result){
        return godSource[targetGod];
    }

    function discount(uint256 num) public pure override returns (uint256){
        if (num < 30) {
            return 0;
        } else if (num < 50) {
            return 3;
        } else if (num < 100) {
            return 6;
        } else {
            return 10;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

pragma solidity ^0.8.0;

interface ISettings {

    function getBagCards() external returns (uint8[] memory, uint8[] memory);

    function getBatchCard(uint256 num) external returns (uint8[] memory, uint8[] memory);

    function getUrCard(uint) external;

    function getGodSource(uint8) view external returns (uint16[] memory);

    function godQuality() view external returns (uint8);

    function toInviter() view external returns (uint256);

    function totalNum() view external returns (uint256);

    function inviterNum() view external returns (uint256);

    function inviterRate() view external returns (uint256);

    function inviterRate1() view external returns (uint256);

    function fomoRate() view external returns (uint256);

    function toDividendsPool() view external returns (uint256);

    function toBonusesPool() view external returns (uint256);

    function toDev() view external returns (uint256);

    function defaultInviter() view external returns (address);

    function dev() view external returns (address);

    function operator() view external returns (address);

    function fomo() view external returns (address);

    function factory() view external returns (address);

    function stakePower(uint8) view external returns (uint256);

    function beInviterAmt() view external returns (uint256);

    function boxPrice() view external returns (uint256);

    function priceStep() view external returns (uint256);

    function normalPrice() view external returns (uint256);

    function giftBagPrice() view external returns (uint256);

    function discount(uint256 num) view external returns (uint256);

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