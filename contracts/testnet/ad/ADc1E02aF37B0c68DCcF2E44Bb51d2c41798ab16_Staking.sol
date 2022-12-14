// SPDX-License-Identifier: None
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Address.sol";

contract Staking {
    struct ValidatorStakeInfo {
        address addr;
        uint256 amount;
    }

    struct ValidatorStateInfo {
        string state;
        uint256 counterEpoch;
    }

    using Address for address;

    // Parameters
    uint128 public constant VALIDATOR_THRESHOLD = 1 ether;
    uint256 public constant AMOUNT_TOKEN_SLASHING = 0.1 ether;
    uint128 public constant EPOCH_SUSPEND = 3;
    uint128 public constant TIME_DURATION_BAN = 30;

    uint256 private timeStartBan;

    // Properties
    address[] public _validators;
    mapping(address => ValidatorStateInfo) public _validatorsState;
    mapping(address => bool) public _addressToIsValidator;
    mapping(address => uint256) public _addressToStakedAmount;
    mapping(address => uint256) public _addressToValidatorIndex;
    mapping(address => bytes) public _addressToBLSPublicKey;
    uint256 public _stakedAmount;
    uint256 public _minimumNumValidators;
    uint256 public _maximumNumValidators;

    // Events
    event Staked(address indexed account, uint256 amount);
    event Unstaked(address indexed account, uint256 amount);
    event Suspended(address indexed account, uint256 amount);
    event BLSPublicKeyRegistered(address indexed accout, bytes key);

    // Modifiers
    modifier onlyEOA() {
        require(!msg.sender.isContract(), "Only EOA can call function");
        _;
    }

    modifier onlyStaker() {
        require(
            _addressToStakedAmount[msg.sender] > 0,
            "Only staker can call function"
        );
        _;
    }

    modifier onlyValidator() {
        require(_isValidator(msg.sender), "Only validator can call function");
        _;
    }

    constructor(uint256 minNumValidators, uint256 maxNumValidators) {
        require(
            minNumValidators <= maxNumValidators,
            "Min validators num can not be greater than max num of validators"
        );
        _minimumNumValidators = minNumValidators;
        _maximumNumValidators = maxNumValidators;
    }

    // View functions
    function stakedAmount() public view returns (uint256) {
        return _stakedAmount;
    }

    function validators() public view returns (address[] memory) {
        return _validators;
    }

    function validatorBLSPublicKeys() public view returns (bytes[] memory) {
        bytes[] memory keys = new bytes[](_validators.length);

        for (uint256 i = 0; i < _validators.length; i++) {
            keys[i] = _addressToBLSPublicKey[_validators[i]];
        }

        return keys;
    }

    function isValidator(address addr) public view returns (bool) {
        return _addressToIsValidator[addr];
    }

    function accountStake(address addr) public view returns (uint256) {
        return _addressToStakedAmount[addr];
    }

    function minimumNumValidators() public view returns (uint256) {
        return _minimumNumValidators;
    }

    function maximumNumValidators() public view returns (uint256) {
        return _maximumNumValidators;
    }

    // Get state of validator
    function getValidatorState() public view returns(string memory) {
        return _validatorsState[msg.sender].state;
    }

    // Get address has largest staked balance
    function getLargestStakerAddress() public view returns (ValidatorStakeInfo memory) {
        ValidatorStakeInfo memory rs = ValidatorStakeInfo(address(0), 0);
        uint256 amt = 0;
        uint256 half = _stakedAmount / 2;
        for (uint256 i = 0; i < _validators.length; i++) {
            if (_addressToStakedAmount[_validators[i]] > amt) {
                amt = _addressToStakedAmount[_validators[i]];
                rs = ValidatorStakeInfo(_validators[i], amt);

                // return validator immediately if its balance is greater than half of the total staked amount
                if (rs.amount > half) {
                    return rs;
                }
            }
        }
        return rs;
    }

    // Get staked amount with all validators' address
    function getValidatorsStakeInfo() public view returns (ValidatorStakeInfo[] memory) {
        ValidatorStakeInfo[] memory rs = new ValidatorStakeInfo[](_validators.length);
        for (uint256 i = 0; i < _validators.length; i++) {
            ValidatorStakeInfo memory valInfo = ValidatorStakeInfo(_validators[i], _addressToStakedAmount[_validators[i]]);
            rs[i] = valInfo;
        }
        return rs;
    }


    // Public functions
    receive() external payable onlyEOA {
        _stake();
    }

    function stake() public payable onlyEOA {
        _stake();
    }

    function daysHavePassed(uint StartAt) private view returns(uint256) {
        uint256 timeNow = block.timestamp;
        require(StartAt <= timeNow, "time invalid");
        //calculate to the number of days that have passed
        return (timeNow - StartAt) / 86400;
    }

    function checkStateValidators() public {
        for (uint256 i = 0; i < _validators.length; i++) {
            ValidatorStateInfo memory _vldState = _validatorsState[_validators[i]];
            
            //check if state == "suspend"
            if (keccak256(abi.encodePacked(_vldState.state)) == keccak256(abi.encodePacked("suspend"))) {
                _vldState.counterEpoch ++ ;
                if (_vldState.counterEpoch == EPOCH_SUSPEND) {
                    // add validator to validatorSet
                    _appendToValidatorSet(msg.sender);
                    _vldState.state = "stake";
                    _vldState.counterEpoch = 0;
                    
                }
            } 
            //check if state == "ban"
            if (keccak256(abi.encodePacked(_vldState.state)) == keccak256(abi.encodePacked("ban"))) {
                _vldState.counterEpoch ++ ;
                if (_vldState.counterEpoch == EPOCH_SUSPEND) {
                    // add validator to validatorSet
                    _appendToValidatorSet(msg.sender);
                }
                if (daysHavePassed(timeStartBan) >= TIME_DURATION_BAN) {
                    _vldState.state = "stake";
                    _vldState.counterEpoch = 0;
                }
            }
            //check if state == "unstake"
            if (keccak256(abi.encodePacked(_vldState.state)) == keccak256(abi.encodePacked("unstake"))) {
                _unstake();
                _vldState.state = "end";
            }
            //check if state == "end"
            if (keccak256(abi.encodePacked(_vldState.state)) == keccak256(abi.encodePacked("end"))) {
                _withdraw();
            }
        }
    }

    function unstake() public onlyEOA onlyStaker {
        string memory state = _validatorsState[msg.sender].state;
        require (keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("stake")), "staker is banned or suspended");
        _validatorsState[msg.sender].state = "unstake";
    }

    function suspend() public onlyEOA() onlyStaker {
        _suspend();
        _validatorsState[msg.sender].state = "suspend";
    }

    function ban() public onlyEOA() onlyStaker {
        _suspend();
        _validatorsState[msg.sender].state = "ban";
        //set the time start to ban validators
        timeStartBan = block.timestamp;
    }

    // Private functions
    function _unstake() private {
        uint256 amount = _addressToStakedAmount[msg.sender];

        _addressToStakedAmount[msg.sender] = 0;
        _stakedAmount -= amount;

        if (_isValidator(msg.sender)) {
            _deleteFromValidators(msg.sender);
        }
        emit Unstaked(msg.sender, amount);
    }

    function _suspend() private {
        uint256 amount = _addressToStakedAmount[msg.sender];
        //slashing a part of token
        _addressToStakedAmount[msg.sender] = amount - AMOUNT_TOKEN_SLASHING;
        _stakedAmount -= AMOUNT_TOKEN_SLASHING;
        if (_isValidator(msg.sender)) {
            _deleteFromValidators(msg.sender);
        }
        emit Suspended(msg.sender, amount);
    }

    function _stake() private {
        string memory state = _validatorsState[msg.sender].state;
        require (keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("stake")),"staker is banned or suspended");
        _stakedAmount += msg.value;
        _addressToStakedAmount[msg.sender] += msg.value;

        if (_canBecomeValidator(msg.sender)) {
            _appendToValidatorSet(msg.sender);
            state = "stake";
        }

        emit Staked(msg.sender, msg.value);
    }

    function _withdraw() private {
        uint256 amount = _addressToStakedAmount[msg.sender];
        _addressToStakedAmount[msg.sender] = 0;
        _stakedAmount -= amount;
        payable(msg.sender).transfer(amount);
    }

    function registerBLSPublicKey(bytes memory blsPubKey) public {
        _addressToBLSPublicKey[msg.sender] = blsPubKey;

        emit BLSPublicKeyRegistered(msg.sender, blsPubKey);
    }

    function _deleteFromValidators(address staker) private {
        require(
            _validators.length > _minimumNumValidators,
            "Validators can't be less than the minimum required validator num"
        );

        require(
            _addressToValidatorIndex[staker] < _validators.length,
            "index out of range"
        );

        // index of removed address
        uint256 index = _addressToValidatorIndex[staker];
        uint256 lastIndex = _validators.length - 1;

        if (index != lastIndex) {
            // exchange between the element and last to pop for delete
            address lastAddr = _validators[lastIndex];
            _validators[index] = lastAddr;
            _addressToValidatorIndex[lastAddr] = index;
        }

        _addressToIsValidator[staker] = false;
        _addressToValidatorIndex[staker] = 0;
        _validators.pop();
    }

    function _appendToValidatorSet(address newValidator) private {
        require(
            _validators.length < _maximumNumValidators,
            "Validator set has reached full capacity"
        );

        _addressToIsValidator[newValidator] = true;
        _addressToValidatorIndex[newValidator] = _validators.length;
        _validators.push(newValidator);
    }

    function _isValidator(address account) private view returns (bool) {
        return _addressToIsValidator[account];
    }

    function _canBecomeValidator(address account) private view returns (bool) {
        return
        !_isValidator(account) &&
        _addressToStakedAmount[account] >= VALIDATOR_THRESHOLD;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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