pragma solidity ^0.8.5;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./IDocumentStoreInterface.sol";

contract DocumentStore is OwnableUpgradeable {
    string public name;
    string public email;
    string public legalReference;
    string public intentDeclaration;
    string public host;
    uint256 public contractExpiredTime;

    address ownerManager;
    address[] public publishers;
    /// uint256 constant YEAR_IN_SECONDS = 31536000;

    /// A mapping of the document hash to the block number that was issued
    mapping(bytes32 => uint256) public documentIssued;
    /// A mapping of the hash of the claim being revoked to the revocation block number
    mapping(bytes32 => uint256) public documentRevoked;
    /// A mapping of the hash of the document to the expiration date
    mapping(bytes32 => uint256) public documentExpiration;
    /// A mapping of the hash of the document to the publisher
    mapping(bytes32 => address) public documentPublisher;

    event DocumentIssued(bytes32 indexed document);
    event DocumentRevoked(bytes32 indexed document);
    event PublisherChanged(address indexed documentStore, address[] currentPublishers);
    event ContractExpired(address indexed thisContract,uint256 time);
    event ContractInfoChanged(
        string _name,
        string _email,
        string _legalReference,
        string _intentDeclaration,
        string _host,
        uint256 _time
    );

    function initialize(
        string memory _name,
        string memory _email,
        string memory _legalReference,
        string memory _intentDeclaration,
        string memory _host,
        uint256 _time,
        address _owner,
        address _ownerManager
    ) public initializer {
        require(_time > block.timestamp, "Error: expired date has passed");
        super.__Ownable_init();
        super.transferOwnership(_owner);
        publishers.push(_owner);
        name = _name;
        email = _email;
        legalReference = _legalReference;
        intentDeclaration = _intentDeclaration;
        host = _host;
        ownerManager = _ownerManager;
        contractExpiredTime = _time;
    }

    function getExpiredTime() external view returns (uint256) {
        return contractExpiredTime;
    }

    function getName() external view returns (string memory) {
        return name;
    }

    function getEmail() external view returns (string memory) {
        return email;
    }

    function getLegalReference() external view returns (string memory) {
        return legalReference;
    }

    function getIntentDeclaration() external view returns (string memory) {
        return intentDeclaration;
    }

    function getHost() external view returns (string memory) {
        return host;
    }

    function getPublishers() external view returns (address[] memory) {
        return publishers;
    }

    function setName(string memory _name) external onlyOwner contractNotExpired{
        name = _name;
        IDocumentStoreInterface(ownerManager).setName(
            address(this), 
            _name
        );
        emit ContractInfoChanged(
            name,
            email,
            legalReference,
            intentDeclaration,
            host,
            contractExpiredTime
        );
    }

    function setEmail(string memory _email) external onlyOwner contractNotExpired{
        email = _email;
        IDocumentStoreInterface(ownerManager).setEmail(
            address(this), 
            _email
        );
        emit ContractInfoChanged(
            name,
            email,
            legalReference,
            intentDeclaration,
            host,
            contractExpiredTime
        );
    }

    function setLegalReference(string memory _legalReference) external onlyOwner contractNotExpired{
        legalReference = _legalReference;
        IDocumentStoreInterface(ownerManager).setLegalReference(
            address(this),
            _legalReference
        );
        emit ContractInfoChanged(
            name,
            email,
            legalReference,
            intentDeclaration,
            host,
            contractExpiredTime
        );
    }

    function setIntentDeclaration(string memory _intentDeclaration) external onlyOwner contractNotExpired{
        intentDeclaration = _intentDeclaration;
        IDocumentStoreInterface(ownerManager).setIntentDeclaration(
            address(this),
            _intentDeclaration
        );
        emit ContractInfoChanged(
            name,
            email,
            legalReference,
            intentDeclaration,
            host,
            contractExpiredTime
        );
    }

    function setHost(string memory _host) external onlyOwner contractNotExpired{
        host = _host;
        IDocumentStoreInterface(ownerManager).setHost(
            address(this), 
            _host
        );
        emit ContractInfoChanged(
            name,
            email,
            legalReference,
            intentDeclaration,
            host,
            contractExpiredTime
        );
    }

    function setExpiredTime(uint256 _time) external onlyOwner{
        IDocumentStoreInterface(ownerManager).setExpiredTime(
            address(this), 
            _time
        );
        contractExpiredTime = _time;
        emit ContractInfoChanged(
            name,
            email,
            legalReference,
            intentDeclaration,
            host,
            contractExpiredTime
        );
    }

    function removeAllPublishers() external onlyOwner contractNotExpired{
        while(publishers.length > 0) {
            publishers.pop();
        }
        emit PublisherChanged(address(this), publishers);
    }

    function addPublishers(address[] memory _newPublishers) external onlyOwner contractNotExpired{
        while(publishers.length > 0) {
            publishers.pop();
        }
        for (uint256 i; i < _newPublishers.length; i++) {
            if (publisherCheck(_newPublishers[i])) continue;
            publishers.push(_newPublishers[i]);
        }
        emit PublisherChanged(address(this), publishers);
    }

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) 
        public 
        view 
        onlyIssued(root) 
        onlyNotRevoked(root)
        onlyNotExpired(root)
        onlyNotRevoked(leaf)
        contractNotExpired 
        returns (bool) 
    {
        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf)
        internal
        pure
        returns (bytes32)
    {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b)
        internal
        pure
        returns (bytes32 value)
    {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }

    function issue(bytes32 document, uint256 expiredTime)
        public
        onlyPublisher
        onlyNotIssued(document)
        contractNotExpired
    {
        documentIssued[document] = block.number;
        documentExpiration[document] = expiredTime;
        documentPublisher[document] = msg.sender;
        emit DocumentIssued(document);
    }

    function bulkIssue(bytes32[] memory documents, uint256[] memory expiredTime)
        external
    {
        for (uint256 i = 0; i < documents.length; i++) {
            issue(documents[i], expiredTime[i]);
        }
    }

    function getIssuedBlock(bytes32 document)
        external
        view
        onlyIssued(document)
        returns (uint256)
    {
        return documentIssued[document];
    }

    function isIssued(bytes32 document) 
        public 
        view 
        returns (bool) 
    {
        return (documentIssued[document] != 0);
    }

    function isIssuedBefore(bytes32 document, uint256 blockNumber)
        public
        view
        returns (bool)
    {
        return (documentIssued[document] != 0 && documentIssued[document] <= blockNumber);
    }

    function revoke(bytes32 document)
        public
        onlyPublisher
        onlyNotRevoked(document)
        contractNotExpired
    {
        documentRevoked[document] = block.number;
        emit DocumentRevoked(document);
    }

    function bulkRevoke(bytes32[] memory documents) 
        external
    {
        for (uint256 i = 0; i < documents.length; i++) {
            revoke(documents[i]);
        }
    }

    function isRevoked(bytes32 document) 
        public
        view 
        returns (bool) 
    {
        return documentRevoked[document] != 0;
    }

    function isRevokedBefore(bytes32 document, uint256 blockNumber)
        public
        view
        returns (bool)
    {
        return (documentRevoked[document] <= blockNumber && documentRevoked[document] != 0);
    }

    function getDocExpiredTime(bytes32 document)
        external
        view
        onlyIssued(document)
        returns (uint256)
    {
        return documentExpiration[document];
    }

    function isNotExpired(bytes32 document)
        public
        view
        onlyIssued(document)
        returns (bool)
    {
        return documentExpiration[document] > block.timestamp || documentExpiration[document] == 0;
    }

    function publisherCheck(address _address) 
        public 
        view
        returns (bool check) 
    {
        check = false;
        for (uint256 i; i < publishers.length; i++) {
            if (publishers[i] == _address) {
                check = true;
                break;
            }
        }
    }

    modifier onlyNotExpired(bytes32 document) {
        require(isNotExpired(document), "Error: Document is not expired");
        _;
    }

    modifier onlyIssued(bytes32 document) {
        require(isIssued(document), "Error: Document's hash is not issued ");
        _;
    }

    modifier onlyNotIssued(bytes32 document) {
        require(!isIssued(document), "Error: Only hashes that have not been issued can be issued");
        _;
    }

    modifier onlyNotRevoked(bytes32 claim) {
        require(!isRevoked(claim), "Error: Hash has been revoked previously");
        _;
    }

    modifier onlyPublisher() {
        require(publisherCheck(msg.sender), "Error: Only Publisher can revoke or issue documents");
        _;
    }

    modifier onlyVerified(bytes32[] memory proof, bytes32 root, bytes32 leaf) {
        require(verify(proof, root, leaf), "Error: Leaf is not verified");
        _;
    }

    modifier contractNotExpired() {
        require(contractExpiredTime > block.timestamp);
        _;
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

pragma solidity ^0.8.5;

interface IDocumentStoreInterface {
    function getName() external view returns(string memory);
        
    function getEmail() external view returns(string memory);

    function getLegalReference() external view returns(string memory);

    function getIntentDeclaration() external view returns(string memory);

    function getHost() external returns(string memory);
    
    function getExpiredTime() external returns(uint256);

    function setName(address _contract, string memory _name) external;
        
    function setEmail(address _contract, string memory _email) external;

    function setLegalReference(address _contract, string memory _legalReference) external;

    function setIntentDeclaration(address _contract, string memory _intentDeclaration) external;

    function setHost(address _contract, string memory _host) external;

    function setExpiredTime(address _contract, uint256 _time) external;

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