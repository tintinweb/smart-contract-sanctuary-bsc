pragma solidity 0.8.17;


import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract CPTOKENPROGRAMME {

    /**
        @dev    the struct that holds the data related to a program
        @param  _programId is a unique identifier for every created programs
        @param  _expiryDate is the date expiration set by the program owner
        @param  _owner  is the address of the program owner
        @param  _effectiveDate is the effective date of the program set by the owner

        @dev    the struct data structure is used to keep the data together and organized  
     */

    struct Program {

        uint256 _programId;
        uint256 _maximumAuthorizedAmount;
        uint256 _maximumTenor;
        uint256 _minimumTenor;
        uint256 _minimumDiscount;
        string _effectiveDate;
        string _expiryDate;
        address _owner;
        
    }

    struct Document {

        string _link;
        string _hash;

    }

    


    
    mapping (uint256 => Program) private _program;          //  private map that maps the Program struct the program id
    mapping (uint256 => bool) private _usedProgramId;       //  private map that tracks used and existing program id to avoid duplicated ids for different owners


    mapping (uint256 => mapping (uint256 => bool)) private _programLinkToIssuance;  // one to many that maps a program is to various issuance ids
    mapping (uint256 => uint256) private _issuanceLinkToProgram;    //  one to one

    mapping (uint256 => Document[]) private _programDocuments;    //  map the program id to an array of the program's Document struct. All documents assigned to a program can be fetched
    mapping (uint256 => mapping(string => address[])) private _documentSignatures;            //  the array of signatures of a document hash mapped to a program id
    //mapping (uint256 => bytes32[]) private _programSignatures;

    /**
        @dev    function to set program
        @notice _programId is the id of the program
        @notice _effectiveDate is the effective date of the format mm/dd/yyyy
        @notice _expiryDate is the expiry date of the format mm/dd/yyyy
     */

    function createProgram( bytes memory _programData ) external {

        //  decode the parameters from the encoded program data

        (uint256 _programId, uint256 _maximumAuthorizedAmount, uint256 _maximumTenor, uint256 _minimumTenor, uint256 _minimumDiscount, string memory _effectiveDate, string memory _expiryDate) = abi.decode(_programData, (uint256, uint256, uint256, uint256, uint256, string, string));

        // must not be zero

        require(_programId != 0, "Program cannot be zero");
        require(_usedProgramId[_programId] == false, "Used Program Id");
        _program[_programId] = Program(_programId, _maximumAuthorizedAmount, _maximumTenor, _minimumTenor, _minimumDiscount, _effectiveDate, _expiryDate, msg.sender);
        _usedProgramId[_programId] = true;
        emit CreateProgram(_programId, msg.sender);

    }


    /**
        @dev    function to fetch the details of a program using the program id
        @param      _programID is the id of the program that will be used to fetch the program details
     */
    function getProgram(uint256 _programID) public view returns (Program memory)  {

        require(_usedProgramId[_programID] == true, "Program does not exist");
        return  _program[_programID];
        

    }


    /**
        @dev    function to link an issuance to a program
        @dev    an issuance can only be linked to a program but a program can be linked to difference issuances
        @param  _issuanceId is the id of the issuance to be linked to the program
        @param _programId is the id of the program to be linked to the issuance id    
     */
    
    function linkIssuanceToProgram(uint256 _issuanceId, uint256 _programId) external {

        //  link only valid programs

        require(_usedProgramId[_programId] == true, "Program does not exist");
        require(_programLinkToIssuance[_programId][_issuanceId] == false, "Issance has already been linked to program");
        _programLinkToIssuance[_programId][_issuanceId] = true;
        _issuanceLinkToProgram[_issuanceId] = _programId;
        emit LinkIssuance(_programId, _issuanceId);

    }

    /**
        @dev    function to get the program details of a linked issuance. Function accepts an issuance id and fetches the details of the program that is linked to the issuance
        @param _issuanceId  is the id of the issuance
     */

    function getIssuanceProgram(uint256 _issuanceId) external view returns (Program memory) {

        uint256 _programId = _issuanceLinkToProgram[_issuanceId];
        require(_programId != 0, "Issuance has not been linked to any program");
        return getProgram(_programId);

    }


    /**
        @dev    function to set the link to the document of a program
        @notice the appending to the array mapped to the program id
        @param _programId is the id to the program
        @param _link is the link to the program document
     */

    function setProgramDocument(uint256 _programId, string calldata _link, string calldata _hash) external returns (bool success) {

        //  Set links for valid programs only

        require(_usedProgramId[_programId] == true, "Program does not exist");
        _programDocuments[_programId].push(Document(_link, _hash));
        return true;

    }


    /**
        @dev    function to fetch the array of links to a program using the program id
     */
    function getProgramDocument(uint256 _programId) external view returns (Document[] memory) {

        require(_usedProgramId[_programId] == true, "Program does not exist");
        return _programDocuments[_programId];

    }

    /**
        @dev    function to set program signatures
     */

    function signDocument(uint256 _programId, string calldata _hash, address signature) external returns (bool success) {

        require(_usedProgramId[_programId] == true, "Program does not exist");
        _documentSignatures[_programId][_hash].push(signature);
        return true;


    } 

    /**
        function to fetch the program's signatures
        @param _programId is the program's id
     */

    function getDocumentSignature(uint256 _programId, string calldata _hash) external view returns (address[] memory) {

        require(_usedProgramId[_programId] == true, "Program does not exist");
        return _documentSignatures[_programId][_hash];

    }




    event CreateProgram (uint256 indexed _programId, address indexed _owner);          //  event emitted after a program has been set
    event LinkIssuance (uint256 indexed _programId, uint256 indexed _issuanceId);   //  event emitted after an issuance has been linked to a program
  
}


/**
    evaluate the data structure for the hash
    save the link and the hash
    map the hash to its signatures
    fetch the signatures of an hash
 */

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
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
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}