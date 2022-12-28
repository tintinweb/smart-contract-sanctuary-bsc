// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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

pragma solidity 0.8.16;

interface Iswap{
    function lockTime(address addr) external view returns(uint256);
    function totalConvertedToken(address addr) external view returns(uint256);
}

interface BEP {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount)
    external 
    returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) 
        external 
        returns (bool);

    event Transfer(
        address indexed from, 
        address indexed to, 
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract BEP20{

    string public symbol; // symbol Of Token
    string public name;  // Name of Token
    uint8 public decimals; // Returns the number of decimals used to get its user representation.
    uint256 public totalSupply; // total supply of token
    mapping(address => uint256) balances;  // wallet Address own balance eg. (address => amount)
    mapping(address => mapping(address => uint256)) allowed; // Check the allowance Comment
    uint256 public stopTime;
    address swapAddress;
    mapping(address => uint256) public lockTime; // User or Owner lock for certain time
    
    
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     *  account (`to`).
     */

    event Transfer(
        address indexed _from, 
        address indexed _to, 
        uint256 _value
    );

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    /**
     *  It is restricted to owner to use some functionality until lockTime is over 
     */

    modifier onlyAfterTimeLimit(address _owner) {
        require(
            block.timestamp > lockTime[_owner],
            "PROMPT 2001: Time lock period is still going on. The token can not be transferred during locking period."
        );
        _;
    }
    
    //Returns the amount of tokens owned by `account`.
    function balanceOf(address _owner) 
        public 
        view 
        returns (uint256 balance) 
    {
        return balances[_owner];
    }

    /**
     *  @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */

    function transfer(address _to, uint256 _amount)
        public
        onlyAfterTimeLimit(msg.sender)
        returns (bool success)
    {
        require(
            balances[msg.sender] >= _amount && 
            _amount > 0 && balances[_to] + _amount > balances[_to], 
            "PROMPT 2002: Insufficient balance! Please add balance to your wallet and try again!"
        );
        
        // require(
        //     (Iswap(swapAddress).lockTime(msg.sender) < block.timestamp) || 
        //     ((balances[msg.sender] - _amount) >= (Iswap(swapAddress).totalConvertedToken(msg.sender))), 
        //     "PROMPT 2032:locktime is not over"
        // );

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

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
        address _from,
        address _to,
        uint256 _amount
    ) 
        public
        onlyAfterTimeLimit(_from)
        returns (bool success)
    {
        require(
            balances[_from] >= _amount, 
            "PROMPT 2003: Insufficient balance! Please add balance to your wallet and try again!"
        );

        require(
            allowed[_from][msg.sender] >= _amount, 
            "PROMPT 2004: Please enter lesser or same amount than the allowed value!"
        );

        require(_amount > 0,"PROMPT 2005: Please enter value greater than 0!");
        
        require(
            balances[_to] + _amount > balances[_to], 
            "PROMPT 2006: Insufficient balance! Please add balance to your wallet and try again!"
        );

        balances[_from] -= _amount;
        allowed[_from][msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    /**
     *  @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits an {Approval} event.
     */

    function approve(address _spender, uint256 _amount)
        public
        returns (bool success)
    {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
       zero by default.
     * This value changes when {approve} or {transferFrom} are called.
     */

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    /**
     * remove tokons from totalSupply 
     * It's basically transfer tokens to the dead wallet
     * in this Contract It's called through proposal(Only Owners). and for user They can call burn  
     */

    function _burn(address account, uint256 amount) 
        internal 
        virtual 
    {
        require(
            account != address(0), 
            "PROMPT 2007: It should not be the zero address. Please enter valid burn address!"
        );

        uint256 accountBalance = balances[account];
        require(
            accountBalance >= amount, 
            "PROMPT 2008: Number of tokens to burn should be lesser or same as available balance. Please check the value entered!"
        );

        balances[account] = accountBalance - amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "./Proposal.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract CitrusV2 is Initializable, Proposal {
    
    /**
     * Initialization of the Contract 
     */

    function init(
        address[] memory _owners, 
        uint[] memory _sharePercentage
    ) external initializer 
    {
        symbol = "CTS 2.0";
        name = "Citrus V2";
        decimals = 18;
        totalSupply = 500000000 * 1 ether;
        
        for(uint256 i=0; i < _owners.length; i++)
        {
            address owner = _owners[i];
            require(
                owner != address(0), 
                "PROMPT 2009: Invalid address. Please enter a valid address!"
            );
            require(
                !isOwner[owner], 
                "PROMPT 2010: Owner is not unique. Please enter a unique owner!"
            );
            isOwner[owner] = true;
            balances[owner] = (totalSupply * _sharePercentage[i])/100 ;
            lockTime[owner] = block.timestamp + 720 days;
            noOfOwners++;
        }
        lockTimeForOwners = block.timestamp + 720 days;
    }

    /**
     * Burning a tokens if user want to burn it. if Owner want to burn token , they have to pass through proposals
     */

    function burn(uint _amount)
        external 
        onlyUsers
    {
        _burn(msg.sender, _amount);
    }   

    function setSwapAddress(address swapContractAddress) 
        external 
        onlyOwners
    {
        require(
            swapContractAddress != address(0), 
            "PROMPT 2009: Invalid address. Please enter a valid address!"
        );

        swapAddress = swapContractAddress;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

contract Owned {
    // address public owner; // Address of owners
    uint256 public noOfOwners; // It'll return No of Owners
    mapping(address => bool) public isOwner; // It return true if address is any owner  


     /**
     *  Throws if called by any account other than the owners.
     */

    modifier onlyOwners() {
        require(
            isOwner[msg.sender], 
            "PROMPT 2015: Access denied! Only owners can perform this activity!"
        );
        _;
    }

     /**
     *  Throws if called by any account other than the users.
     */

    modifier onlyUsers(){
        require(
            !isOwner[msg.sender], 
            "PROMPT 2016: Access denied! Only users can perform this activity!"
        );
        _;
    }

    /**
     * This function add Owners through the Proposal
     * It can be called by Owners 
     */

    function addOwner(address _addNewOwner) 
        internal 
    {
        require(
            !isOwner[_addNewOwner], 
            "PROMPT 2017: Owner already added!"
        );
        
        isOwner[_addNewOwner] = true;
        noOfOwners++;
    }

    /**
     * This function remove Owners through the Proposal
     * It can be called by Owners 
     */

    function removeOwner(address _removeOwner) 
        internal 
    {
        require(
            isOwner[_removeOwner], 
            "PROMPT 2018: Owner already removed!"
        );

        isOwner[_removeOwner] = false;
        noOfOwners--;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;
import "./Owner.sol";
import "./Bep20.sol";

contract Proposal is Owned, BEP20 {

    /**
     * Basic Structure of Proposal
     * description :- What is the purpose of this proposal 
     * proposalByOwner :- address of the Owner Who is propose 
     * recipient :- this is used for add owner, remove owner, also which address you want to transfer funds  
     * amount :- Amount you want to transfer to the recipient
     * isCompleted :- Proposal is completed or not 
     * noOfVoters :- no of owners vote for proposal
     * lockTime :- After complete proposal for this time owner wallet lock for lockTime periods
     * typeOfProposal :- 0 for transfer, 1 for add Owner, 2 for remove Owner, 3 for burning, 4 for emergency
     * voters :- it is for checking if owner voted or not
     */
     
    struct Proposals {
        string description;
        address proposalByOwner;
        address payable recipient;
        uint256 amount;
        bool isCompleted;
        uint256 noOfVoters;
        uint256 lockTime;
        ProposalType typeOfProposal; 
        mapping(address => bool) voters;
    }

    enum ProposalType{
        Transfer,
        AddOwner,
        RemoveOwner,
        Burn,
        Emergency
    }

    uint256 public numProposals;  // till now number of Proposal is made
    mapping(uint256 => Proposals) public proposals; // for checking Poposal to all Users 
    mapping(uint256 => mapping(address => bool)) public proposalVotes; // for Checking Who is voted Agree or not Agree
    bool public isSuccess; 
    mapping (uint256 => mapping(address => bool)) history;
    uint256 public lockTimeForOwners;

    /**
      Emited when Proposal will be created
     */

    event CreateProposalEvent(
        string description,
        address recipient,
        uint256 value,
        ProposalType typeOfProposal
    );

    event Vote(
        address owner,
        uint256 indexed proposal,
        bool vote
    );

    event Approve(
        address owner,
        address recipient,
        uint256 value,
        uint256 lockTime,
        uint256 indexed proposal,
        ProposalType typeOfProposal
    );

    /**
      function for Creating Proposals 
      only owners can create Proposals
      check Basic Structure of Proposals for more info
     */

    function createProposal(
        string memory _description,
        uint256 _value,
        address payable _recipient,
        ProposalType _typeOfProposal
    ) 
        external
        onlyOwners 
    {
        Proposals storage newProposal = proposals[numProposals++];
        newProposal.description = _description;
        newProposal.amount = _value;
        newProposal.recipient = _recipient;
        newProposal.isCompleted = false;
        newProposal.noOfVoters = 0;
        newProposal.lockTime = lockTime[msg.sender];
        newProposal.typeOfProposal = _typeOfProposal;
        newProposal.proposalByOwner = msg.sender;
        // lockTime[msg.sender] = block.timestamp + LOCK_TIME;
        
        emit CreateProposalEvent(
            _description,
            _recipient,
            _value,
            _typeOfProposal
        );
    }
    
    /**
      function for Voting Proposals 
      only owners can vote for it Proposals
      _index :- it's index of proposals. eg. mapping(_index => Proposals) public proposals;
      _isVote :- true(1), false(0)
     */

    function voteForProposal(
        uint256 _index, 
        bool _isVote
    )
        external
        onlyOwners
    {
        Proposals storage thisProposal = proposals[_index];
        require(!thisProposal.voters[msg.sender], "PROMPT 2011: Already voted for this request!");
        thisProposal.voters[msg.sender] = _isVote;
        if (_isVote) 
            thisProposal.noOfVoters++;
            proposalVotes[_index][msg.sender] = _isVote;
        
        emit Vote(msg.sender, _index, _isVote);

    }

    /**
      function for Approve Proposals 
      only owners can Approve Proposals
     */

    function approveProposal(
        uint256 _index
    ) 
        external
        onlyOwners 
    {
        Proposals storage thisProposal = proposals[_index];
        require(!thisProposal.isCompleted, "PROMPT 2012: Request already completed!");
        require(thisProposal.noOfVoters == noOfOwners, "PROMPT 2013: All owner must be voted for approval. Please try after voting is completed by all owners!"); //need 100% vote for approval
        require(thisProposal.proposalByOwner == msg.sender, "PROMPT 2014: Access denied! You are not the Owner of the Request!");
        
        if (thisProposal.typeOfProposal == ProposalType.Transfer) {
            lockTime[msg.sender] = 0;
            transfer(thisProposal.recipient,thisProposal.amount);
            
        } else if (thisProposal.typeOfProposal == ProposalType.AddOwner) {
            addOwner(thisProposal.recipient);

        } else if (thisProposal.typeOfProposal == ProposalType.RemoveOwner) {
            removeOwner(thisProposal.recipient);
            removeVoteByOwner(thisProposal.recipient);


        } else if (thisProposal.typeOfProposal == ProposalType.Burn) {  
            _burn(msg.sender, thisProposal.amount);

        } else if (thisProposal.typeOfProposal == ProposalType.Emergency) {
            lockTime[msg.sender] = 0;
            transfer(thisProposal.recipient,thisProposal.amount);
        }

        isSuccess = true;
        if (isSuccess)
            lockTime[msg.sender] = lockTimeForOwners;
            thisProposal.isCompleted = true;
            isSuccess = false;
            emit Approve(msg.sender, thisProposal.recipient, thisProposal.amount, thisProposal.lockTime, _index, thisProposal.typeOfProposal);
    }   


    function removeVoteByOwner(address _recipient) internal{
        for (uint256 i=0; i<=numProposals; i++){
            Proposals storage thisProposal = proposals[i];
            if (thisProposal.voters[_recipient]){
                history[i][_recipient] = proposalVotes[i][_recipient];
                proposalVotes[i][_recipient] = false;
                thisProposal.noOfVoters--;
            }else{
                history[i][_recipient] = proposalVotes[i][_recipient];
            }
        }
    }

    function getHistory(uint256 _index, address _owner) external view returns(bool){
        return history[_index][_owner];
    }
}