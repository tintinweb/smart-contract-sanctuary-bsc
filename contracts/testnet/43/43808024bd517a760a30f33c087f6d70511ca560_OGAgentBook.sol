/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
        // solhint-disable-next-line no-inline-assembly
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function getTime() public view returns (uint256) {
        return now;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(_previousOwner == msg.sender, "no permission");
        require(now > _lockTime , "not expired");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

/**
 * @dev list of operator identities to manage contract
 */
contract OGOperators is Ownable {

    // @dev Operator Address => Authorized or not
    mapping (address => bool) private operators_;

    // MODIFIERS
    // ========================================================================
    modifier onlyOperator() {
        require(operators_[msg.sender], "Not operator");
        _;
    }
    modifier onlyOwnerOrOperator() {
        require((msg.sender == owner()) || operators_[msg.sender], "Not owner or operator");
        _;
    }

    // EVENT
    // ========================================================================
    event EnrollOperatorAddress(address operator);
    event DisableOperatorAddress(address operator);

    // FUNCTIONS
    // ========================================================================
    /**
     * @notice Enroll new operator addresses
     * @dev Only callable by owner
     * @param _operatorAddress: address of the operator
     */
    function enrollOperatorAddress(address _operatorAddress) external onlyOwnerOrOperator {
        require(_operatorAddress != address(0), "Cannot be zero address");
        require(!operators_[_operatorAddress], "Already registered");
        operators_[_operatorAddress] = true;
        emit EnrollOperatorAddress(_operatorAddress);
    }

    /**
     * @notice Disable a operator addresses
     * @dev Only callable by owner
     * @param _operatorAddress: address of the operator
     */
    function disableOperatorAddress(address _operatorAddress) external onlyOwnerOrOperator {
        require(_operatorAddress != address(0), "Cannot be zero address");
        require(operators_[_operatorAddress], "Already disabled");
        operators_[_operatorAddress] = false;
        emit DisableOperatorAddress(_operatorAddress);
    }

    /**
     * @notice Get operator availability
     * @param _operatorAddress: address of the operator
     */
    function getOperatorEnable(address _operatorAddress) public view returns (bool) {
        return operators_[_operatorAddress];
    }

}

/**
 * @dev OGPlayerBank Interface
 */
interface IOGPlayerBank {
    function getTokenIDXAddr(address _tokenAddr) external view returns (uint256);
    function getTokenAddrXID(uint256 _tokenID) external view returns (address);
    function getGameIDXAddr(address _gameAddr) external view returns (uint256);
}

/**
 * @dev OGPlayerBook Interface
 */
interface IOGPlayerBook {
    function getPlayerIDXAddr(address _plyrAddr) external view returns (uint256);
    function getAgtInfoXPlayerID(uint256 _plyrID) external view returns (uint256, address);
    function getAgtInfoXPlayerAddr(address _plyrAddr) external view returns (uint256, address);
}

contract OGAgentBook is OGOperators {

    using SafeMath for uint256;
    using Address for address;

    struct Agent {
        uint256 abid;   
        address addr;   
        uint256 laff;   
    }

    event onActivatedUpdated(bool enabled);

    event onEnrollAgent(
        uint256 indexed agentID,
        address indexed agentAddress,
        uint256 indexed affiliateID,
        uint256 timeStamp
    );

    event onDisableAgent(
        uint256 indexed agentID,
        address indexed agentAddress,
        uint256 timeStamp
    );

    event onEnableAgent(
        uint256 indexed agentID,
        address indexed agentAddress,
        uint256 timeStamp
    );

    event onAlterAgent(
        uint256 indexed agentID,
        uint256 indexed beforeID,
        uint256 indexed afterID,
        uint256 timeStamp
    );

    event onAgentIncome(
        uint256 indexed agentID,
        uint256 indexed gameID,
        uint256 indexed tokenID,
        int256 amount,
        uint256 timeStamp
    );

    event onAgentLoss(
        uint256 indexed agentID,
        uint256 indexed gameID,
        uint256 indexed tokenID,
        int256 amount,
        uint256 timeStamp
    );

    modifier isActivated() {
        require(activated_ == true, "Not enabled");
        _;
    }

    modifier needConfigured() {
        require(plyrBankAddr_ != address(0x0) && plyrBookAddr_ != address(0x0), "Not yet configured");
        _;
    }

    modifier onlyAuthorized() {
        require(
            _msgSender() == plyrBookAddr_ || _msgSender() == plyrBankAddr_ || _msgSender() == owner() || getOperatorEnable(_msgSender()) || plyrBank_.getGameIDXAddr(msg.sender) > 0,
            "Permission denied"
        );
        _;
    }

    bool public activated_ = false;                     

    address public plyrBookAddr_ = address(0x0);
    IOGPlayerBook private plyrBook_;

    address public plyrBankAddr_ = address(0x0);
    IOGPlayerBank private plyrBank_;

    uint256 public aID_;                                 
    mapping (address => bool) private aAddrxEnable_;     
    mapping (address => uint256) private addrxaID_;      
    mapping (uint256 => Agent) private aIDxAgent_;      

    mapping (uint256 => mapping (uint256 => int256)) private aIDtIDxStats_;

    constructor()
    public
    {
        aAddrxEnable_[owner()] = true;
        addrxaID_[owner()] = 1;
        aIDxAgent_[1].abid = 1;
        aIDxAgent_[1].addr = owner();
        aIDxAgent_[1].laff = 0;
        aID_ = 1;
    }

    function enrollNewAgent(address _agentAddr, uint256 _affiliateID)
    external
    onlyOwnerOrOperator needConfigured isActivated returns (uint256) {
        require(_agentAddr != address(0x0), "Cannot be zero address");
        if (_affiliateID < 1) {
            _affiliateID = 1;
        } else {
            require(aIDxAgent_[_affiliateID].addr != address(0x0), "AffiliateID not exist");
        }
        aID_++;
        aAddrxEnable_[_agentAddr] = true;
        addrxaID_[_agentAddr] = aID_;
        aIDxAgent_[aID_].addr = _agentAddr;
        aIDxAgent_[aID_].laff = _affiliateID;
        emit onEnrollAgent(aID_, _agentAddr, _affiliateID, now);
        return aID_;
    }

    function disableAgentByAddr(address _agentAddr)
    external
    onlyOwnerOrOperator needConfigured isActivated {
        uint256 agentID = addrxaID_[_agentAddr];
        _disableAgent(_agentAddr, agentID);
    }

    function disableAgentByID(uint256 _agentID)
    external
    onlyOwnerOrOperator needConfigured isActivated {
        address agentAddr = aIDxAgent_[_agentID].addr;
        _disableAgent(agentAddr, _agentID);
    }

    function enableAgentByAddr(address _agentAddr)
    external
    onlyOwnerOrOperator needConfigured isActivated {
        uint256 agentID = addrxaID_[_agentAddr];
        _enableAgent(_agentAddr, agentID);
    }

    function enableAgentByID(uint256 _agentID)
    external
    onlyOwnerOrOperator needConfigured isActivated {
        address agentAddr = aIDxAgent_[_agentID].addr;
        _enableAgent(agentAddr, _agentID);
    }

    function alterAffiliateByID(uint256 _agentID, uint256 _affiliateID)
    external
    onlyOwnerOrOperator needConfigured isActivated {
        _alterAffiliateByID(_agentID, _affiliateID);
    }

    function alterAffiliateByAddr(address _agentAddr, address _affiliateAddr)
    external
    onlyOwnerOrOperator needConfigured isActivated {
        require(_agentAddr != address(0x0), "Illegal address");
        require(_agentAddr != aIDxAgent_[1].addr, "Cannot be official");
        require(_affiliateAddr != address(0x0), "Illegal address");
        uint256 agentID = addrxaID_[_agentAddr];
        uint256 affiliateID = addrxaID_[_affiliateAddr];
        _alterAffiliateByID(agentID, affiliateID);
    }

    function logAgentIncome(
        address _tokenAddr,
        uint256 _agentID,
        int256 _amount
    )
    external
    onlyAuthorized needConfigured isActivated
    {
        require(_amount > 0, "Amount denied");
        uint256 tokenID = plyrBank_.getTokenIDXAddr(_tokenAddr);
        require(tokenID > 0, "Token doesnt exist");
        uint256 gameID = plyrBank_.getGameIDXAddr(_msgSender());
        if (_agentID == 0) {
            _agentID = 1;
        }
        aIDtIDxStats_[_agentID][tokenID] += _amount;
        emit onAgentIncome(_agentID, gameID, tokenID, _amount, now);
    }

    function logAgentLoss(
        address _tokenAddr,
        uint256 _agentID,
        int256 _amount
    )
    external
    onlyAuthorized needConfigured isActivated
    {
        require(_amount < 0, "Amount denied");
        uint256 tokenID = plyrBank_.getTokenIDXAddr(_tokenAddr);
        require(tokenID > 0, "Token doesnt exist");
        uint256 gameID = plyrBank_.getGameIDXAddr(_msgSender());
        if (_agentID == 0) {
            _agentID = 1;
        }
        aIDtIDxStats_[_agentID][tokenID] += _amount;
        emit onAgentLoss(_agentID, gameID, tokenID, _amount, now);
    }

    function _disableAgent(address _agentAddr, uint256 _agentID) private {
        require(_agentID > 0 && _agentID <= aID_, "Agent doesnt exist");
        require(_agentID != 1, "Cannot be official");
        require(_agentAddr != address(0x0), "Illegal address");
        require(_agentAddr != aIDxAgent_[1].addr, "Cannot be official");
        aAddrxEnable_[_agentAddr] = false;
        emit onDisableAgent(_agentID, _agentAddr, now);
    }

    function _enableAgent(address _agentAddr, uint256 _agentID) private {
        require(_agentID > 0 && _agentID <= aID_, "Agent doesnt exist");
        require(_agentID != 1, "Cannot be official");
        require(_agentAddr != address(0x0), "Illegal address");
        require(_agentAddr != aIDxAgent_[1].addr, "Cannot be official");
        aAddrxEnable_[_agentAddr] = true;
        emit onEnableAgent(_agentID, _agentAddr, now);
    }

    function _alterAffiliateByID(uint256 _agentID, uint256 _affiliateID) private {
        require(_agentID > 0 && _agentID <= aID_, "Agent doesnt exist");
        require(_agentID != 1, "Cannot be official");
        require(_affiliateID != 0, "AffiliateID doesnt exist");
        require(aIDxAgent_[_agentID].laff != _affiliateID, "No need to alter");
        uint256 beforeAffiliateID = aIDxAgent_[_agentID].laff;
        aIDxAgent_[_agentID].laff = _affiliateID;
        emit onAlterAgent(_agentID, beforeAffiliateID, _affiliateID, now);
    }

    function verifyAgentEnable(uint256 _agentID) external view needConfigured onlyAuthorized returns (uint256, address) {
        if (_agentID > 0 && _agentID <= aID_ && aAddrxEnable_[aIDxAgent_[_agentID].addr]) {
            return (_agentID, aIDxAgent_[_agentID].addr);
        } else {
            return (1, aIDxAgent_[1].addr);
        }
    }

    function getAgentAddrByID(uint256 _agentID) external view needConfigured returns (address) {
        return aIDxAgent_[_agentID].addr;
    }

    function getAgentAffiliateIDByID(uint256 _agentID) external view needConfigured returns (uint256) {
        return aIDxAgent_[_agentID].laff;
    }

    function getAgentIDByAddr(address _agentAddr) external view needConfigured returns (uint256) {
        return addrxaID_[_agentAddr];
    }

    function getAgentEnableByID(uint256 _agentID) external view needConfigured returns (bool) {
        return aAddrxEnable_[aIDxAgent_[_agentID].addr];
    }

    function getAgentEnableByAddr(address _agentAddr) external view needConfigured returns (bool) {
        return aAddrxEnable_[_agentAddr];
    }

    function getStatsByAgentToken(uint256 _agentID, uint256 _tokenID)
    external view
    needConfigured
    returns (int256) {
        return aIDtIDxStats_[_agentID][_tokenID];
    }

    function setPlayerBookAddr(address _plyrBookAddress) external onlyOwner {
        require(_plyrBookAddress != address(0x0), "Illegal address");
        plyrBookAddr_ = _plyrBookAddress;
        plyrBook_ = IOGPlayerBook(plyrBookAddr_);
    }

    function setPlayerBankAddr(address _plyrBankAddress) external onlyOwner {
        require(_plyrBankAddress != address(0x0), "Illegal address");
        plyrBankAddr_ = _plyrBankAddress;
        plyrBank_ = IOGPlayerBank(plyrBankAddr_);
    }

    function setActivated(bool _enabled) external onlyOwnerOrOperator needConfigured {
        activated_ = _enabled;
        emit onActivatedUpdated(_enabled);
    }

}