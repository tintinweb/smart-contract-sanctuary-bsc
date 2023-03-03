// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "./Dependencies.sol";

contract Compensate is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    bool public compensationDataWritten; // whether users compensation data is already written into the contract, can only be written once
    address public compensationToken; // which token is used to pay users the compensation amount
    address public treasury; // planet's treasury
    uint public currentRound; // currentRound is 1, when funds are sent first time to the contract, currentRound is 2, when funds are sent second time to the contract and so on
    uint[] public fundsInRound; // how much funds are part of each round
    uint[] public pendingInRound; // how much funds are remaining to be distributed for each round
    uint[] public unclaimedInRound; // how much funds have not been claimed before the deadline in each round
    uint public deadlineToWithdraw; // time by which tokens must be withdraw or will be sent to treasury
    uint public newDeadlineRound; // round uptil which tokens must be withdrawn by the deadline.
    uint public currentDeadlineRound; // round uptil which deadline has been hit. Users can no longer withdraw their funds up til this round.
    uint public totalCompensatedSoFar;


    struct UserCompensationDetail {
        uint whatPercentage; // what percentage of the total compensation amount is owed to the user
        uint userTotalCompensationAmount; // compensation amount owed to the user
        uint remainingAmount; // unpaid compensation amount to the user
        uint compensatedTillRound; // till which round has the user been compensated
        uint unclaimedAmount; // amount that the user won't receive because of missing the deadline
    }

    mapping (address => UserCompensationDetail) public usersCompensationDetails; // map stores each users compensation details

    event UserCompensated(address _user, uint _amountCompensated, uint _compensatedTillRound);
    event SetDeadline(uint _blockNumber, uint _uptilRound);

    constructor(address _compensationToken) {
        compensationToken = _compensationToken; // token address of compensation token
    } 

    /**
        Function to be called by users to recieve their part of the compensation.
    */
    function compensateMe() external nonReentrant {

        UserCompensationDetail storage userCompensationDetail = usersCompensationDetails[msg.sender];
        uint amountTobeCompensated; // calculating how much the user needs to recieve now
        uint userAmountInRound; // how much the user has to recieve in a particular round
        uint userUnclaimedAmount; // calculating how much the user has newly missed claiming
        
        // find what is the compensation amount that is to be sent to the user, based on the users proportions
        // this also loops through different rounds, so lets say if user didn't claim their compensation in round 1, round 2 and current round is 3
        // so the compensation amount will be calculated considering the missed claims of previous rounds as well 
        for(uint i = userCompensationDetail.compensatedTillRound; i < currentRound; ++i){
            userAmountInRound = (userCompensationDetail.whatPercentage * fundsInRound[i])/1e10;
            if (i<currentDeadlineRound){
                userUnclaimedAmount += userAmountInRound;
                continue;
            }
            amountTobeCompensated += userAmountInRound;
            pendingInRound[i] -= userAmountInRound;

        }

        require(amountTobeCompensated > 0, "already claimed");
        require(amountTobeCompensated <= userCompensationDetail.remainingAmount, "amount exceeds");
        require(amountTobeCompensated <= IERC20(compensationToken).balanceOf(address(this)), "amount > balance");

        userCompensationDetail.compensatedTillRound = currentRound; // update currentRound as users compensatedTillRound
        userCompensationDetail.remainingAmount -= (amountTobeCompensated + userUnclaimedAmount);
        userCompensationDetail.unclaimedAmount += userUnclaimedAmount;
    
        IERC20(compensationToken).safeTransfer(msg.sender, amountTobeCompensated); // transfer amount

        emit UserCompensated(msg.sender, amountTobeCompensated, userCompensationDetail.compensatedTillRound);

    }
    /**
        Owner will initiate next round of withdrawals with this function,
        takes input _funds, which is compensation amount used for the round that is being initiated
     */
    function initiateNextRoundWithdrawals(uint _funds) external onlyOwner {
        IERC20(compensationToken).safeTransferFrom(msg.sender, address(this), _funds); // transfer amount

        currentRound++;
        //shouldn't we also have the user transfer funds in this same function?
        fundsInRound.push(_funds);
        pendingInRound.push(_funds);
        unclaimedInRound.push(0);
        totalCompensatedSoFar += _funds;
    }

    /**
        Owner will use this function to write the users compensation data into the contract
     */
    function writeUsersCompensationData(address[] memory _usersAddressList, uint[] memory _percentageList, uint[] memory _usersCompensationList) external onlyOwner {
        require(_usersAddressList.length == _percentageList.length && _percentageList.length == _usersCompensationList.length, "something wrong");
        require(compensationDataWritten == false, "already written");
        
        compensationDataWritten = true;
        uint length = _usersAddressList.length;

        for(uint i = 0; i < length; ++i) {
            UserCompensationDetail memory userCompensationDetail;
            userCompensationDetail.whatPercentage = _percentageList[i];
            userCompensationDetail.userTotalCompensationAmount = _usersCompensationList[i];
            userCompensationDetail.remainingAmount = _usersCompensationList[i];

            usersCompensationDetails[_usersAddressList[i]] = userCompensationDetail;
        }
    }


    /**
        Function to set deadline by which users must withdraw compensation funds. After the deadline, funds for the corresponding rounds will be returned to treasury.
     */
    function setDeadline(uint _blockNumber, uint _uptilRound) external onlyOwner {
        require(_uptilRound > currentDeadlineRound, "Round deadline hit");
        deadlineToWithdraw = _blockNumber;
        newDeadlineRound = _uptilRound;
        emit SetDeadline(_blockNumber, _uptilRound);
    }

    /**
        Function to transfer pending funds to the treasury once the deadline is hit.
    */
    function transferFundsToTreasury() external{
        require(block.number >= deadlineToWithdraw, "too soon");
        uint amountToReturnToTreasury;
        for(uint i=currentDeadlineRound; i<newDeadlineRound; ++i){
            amountToReturnToTreasury += pendingInRound[i];
            unclaimedInRound[i] = pendingInRound[i];
            pendingInRound[i] = 0;
        }

        if (amountToReturnToTreasury>0){
            IERC20(compensationToken).safeTransfer(treasury, amountToReturnToTreasury); // transfer amount
        }

        currentDeadlineRound = newDeadlineRound;
    }

    /**
        Function to set treasury address
    */
    function setTreasury (address _treasury) external onlyOwner {   
        treasury = _treasury;
    }

    /**
        Function to set compensation token.
        Alert! Only change this after deadline has been hit for all past rounds, to avoid funds getting stuck in the contract
    */
    function setCompensationToken (address _compensationToken) external onlyOwner {   
        compensationToken = _compensationToken;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.17;

abstract contract ReentrancyGuard {
 
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
}

interface IERC20 {

        function totalSupply() external view returns (uint256);
        function balanceOf(address account) external view returns (uint256);
        function transfer(address recipient, uint256 amount) external returns (bool);
        function allowance(address owner, address spender) external view returns (uint256);
        function approve(address spender, uint256 amount) external returns (bool);
        function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender,uint256 value);
    }

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

library SafeERC20 {

        using AddressUpgradeable for address;

        function safeTransfer(IERC20 token, address to, uint256 value) internal {
            _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
        }

        function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
            _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
        }

        function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
            uint256 newAllowance = token.allowance(address(this), spender) + value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector,spender,newAllowance));
        }

        function _callOptionalReturn(IERC20 token, bytes memory data) private {

            bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
            if (returndata.length > 0) {
                require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
            }
        }
    }