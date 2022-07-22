// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./JobContext.sol";
import "./FeeContext.sol";
import "./swap/IStableTokenConverter.sol";

contract Escrow is Ownable, Pausable, JobContext, FeeContext {
    uint256 constant BASIS_POINTS_10000 = 10000;

    uint256 constant MAX_INT = 2**256 - 1;

    /**
     * @dev Emitted only after `setERC20Token` has been called.
     */
    event TokenAddressChanged(address indexed _tokenAddress);

    /**
     * @dev Emitted when the default fee is set.
     */
    event DefaultFeeChanged(uint256 indexed _fee);

    /**
     * @dev Emitted when a preferential fee is set.
     */
    event PreferentialFeeChanged(
        uint256 indexed _fee,
        address indexed _beneficiary,
        bool indexed _exists
    );

    /**
     * @dev Emitted when the wallet address where all the fees are gathered is set.
     */
    event FeeBeneficiaryAddressChanged(address indexed _address);

    /**
     * @dev Emitted when a possible employer requests a job from a freelancer.
     */
    event JobRequest(
        uint256 indexed _id,
        address indexed _employer,
        JobStatus indexed _status
    );

    /**
     * @dev Emitted after the funds have been transferred to this account.
     */
    event JobFunded(
        uint256 indexed _id,
        address indexed _freelancer,
        address indexed _employer,
        uint256 _amount,
        JobStatus _status
    );

    /**
     * @dev Emitted after the freelancer/employer marked the job as done.
     */
    event JobApproved(
        uint256 indexed _id,
        bool _freelancerApproval,
        bool _employerApproval
    );

    /**
     * @dev @dev Emitted after any of the freelancer/employer raised a dispute.
     */
    event RaisedDispute(uint256 indexed _id, address indexed _disputeRaisedBy);

    /**
     * @dev Emitted after the funds were force released to a @param _beneficiary following a dispute raised by any of the involved parties.
     */
    event DisputeSettled(uint256 indexed _id, address indexed _beneficiary);

    /**
     * @dev Emitted each time a new StableTokenConverter is set via the `setStableTokenConverter` function.
     */
    event StableTokenConverterChanged(address indexed _stableTokenConverter);

    /**
     * @dev Preferential fees for an employer.
     */
    mapping(address => Fee) public preferentialFees;

    /**
     * @dev Fee to be used if not found in the `preferentialFees` mapping.
     */
    uint256 public fee;

    /**
     * @dev Token used for escrow and swap.
     */
    IERC20 public token;

    /**
     * @dev Maps the internal job id with Job metadata. The metadata is defined in the JobContext smart contract.
     */
    mapping(uint256 => Job) public jobs;

    /**
     * @dev Wallet address where all the fees are gathered.
     */
    address public feeBeneficiary;

    /**
     * @dev Used to convert to stable coin in order to prevent market volatility.Ò
     */
    IStableTokenConverter public stableTokenConverter;

    /**
     * @dev Sets the stable token converter to be used on each deposit fulfill and on each funds release.
     */
    function setStableTokenConverter(address _stableTokenConverterAddress)
        external
        onlyOwner
    {
        stableTokenConverter = IStableTokenConverter(
            _stableTokenConverterAddress
        );
        require(
            token.approve(address(stableTokenConverter), MAX_INT),
            "Escrow: ERC20's approve function for token failed"
        );
        require(
            IERC20(stableTokenConverter.stableTokenAddress()).approve(
                address(stableTokenConverter),
                MAX_INT
            ),
            "Escrow: ERC20's approve function failed"
        );

        emit StableTokenConverterChanged(_stableTokenConverterAddress);
    }

    /**
     * @dev Sets the default fee to be used for normal fee payment. This will be ignored if employer address is present in the `preferentialFees` mapping.
     */
    function setDefaultFee(uint256 _fee) external onlyOwner {
        fee = _fee;
        emit DefaultFeeChanged(_fee);
    }

    /**
     * @dev Sets the preferential fee to be used for preferred employers. This will ignore the `fee` field.
     */
    function setPreferentialFee(address _address, uint256 _fee)
        external
        onlyOwner
    {
        preferentialFees[_address] = Fee(_fee, _address, true);
        emit PreferentialFeeChanged(_fee, _address, true);
    }

    /**
     * @dev Sets wallet address where all the fees are gathered.
     */
    function setFeeBeneficiaryAddress(address _address) external onlyOwner {
        feeBeneficiary = _address;
        emit FeeBeneficiaryAddressChanged(_address);
    }

    /**
     * @dev After changing this all deposits will use this token. Callable only by the smart contract owner.
     */
    function setERC20Token(address _address) external onlyOwner {
        token = IERC20(_address);
        emit TokenAddressChanged(_address);
    }

    /**
     * @dev Callable by anyone. The caller will be marked as a possible employer for the Job. Address verification is done at a later step.
     */
    function deposit(uint256 _id) external whenNotPaused {
        require(!jobs[_id].exists, "Escrow: Job id already used");
        jobs[_id] = Job(
            _id,
            address(0),
            msg.sender,
            0,
            0,
            JobStatus.REQUESTED,
            true,
            false,
            false
        );
        emit JobRequest(_id, msg.sender, JobStatus.REQUESTED);
    }

    /**
     * @dev Callable by owner. Temporary function that will be called by ChainLink in future.
     * @param _amount Here is expressed in LANC.
     */
    function depositFulfill(
        uint256 _id,
        uint256 _amount,
        address _employer,
        address _freelancer
    ) external whenNotPaused onlyOwner {
        require(
            jobs[_id].employer == _employer,
            "Escrow: Wrong employer address"
        );
        require(
            token.allowance(_employer, address(this)) >= _amount,
            "Escrow: Allowance should be greater than the amount deposited"
        );
        require(
            token.transferFrom(_employer, address(this), _amount),
            "Escrow: ERC20's transferFrom function failed"
        );

        uint256 _stableTokenAmount = stableTokenConverter.convertToStable(
            _amount,
            address(this)
        );

        jobs[_id].freelancer = _freelancer;
        jobs[_id].convertedStableTokenAmount = _stableTokenAmount;
        jobs[_id].depositedLANCamount = _amount;
        jobs[_id].jobStatus = JobStatus.FUNDED;
        emit JobFunded(_id, _freelancer, _employer, _amount, JobStatus.FUNDED);
    }

    /**
     * @dev Callable only by the freelancer/employer that is specified in the job.
     * @dev On mutual approval will trigger automatic funds release.
     * @param _id Id of the job.
     */
    function approveJob(uint256 _id)
        external
        whenNotPaused
        onlyExistingAndFundedJobs(_id)
        onlyFreelancerOrEmployer(_id)
    {
        if (msg.sender == jobs[_id].freelancer) {
            jobs[_id].freelancerApproval = true;
        }

        if (msg.sender == jobs[_id].employer) {
            jobs[_id].employerApproval = true;
        }

        bool freelancerApproval = jobs[_id].freelancerApproval;
        bool employerApproval = jobs[_id].employerApproval;

        if (freelancerApproval && employerApproval) {
            jobs[_id].jobStatus = JobStatus.RELEASED;

            uint256 _lancAmount = stableTokenConverter.convertBackFromStable(
                jobs[_id].convertedStableTokenAmount,
                address(this)
            );
            (uint256 _feeAmount, uint256 _amount) = computeFeeAmountForJob(
                _id,
                _lancAmount
            );
            token.transfer(jobs[_id].freelancer, _amount);
            token.transfer(feeBeneficiary, _feeAmount);
        }
        emit JobApproved(_id, freelancerApproval, employerApproval);
    }

    /**
     * @dev Callable only by the freelancer/employer that is specified in the job.
     * @param _id Id of the job.
     */
    function raiseDispute(uint256 _id)
        external
        whenNotPaused
        onlyExistingAndFundedJobs(_id)
        onlyFreelancerOrEmployer(_id)
    {
        jobs[_id].jobStatus = JobStatus.IN_DISPUTE;
        emit RaisedDispute(_id, msg.sender);
    }

    /**
     * @dev Callable only by owner after a freelancer/employer raised a dispute.
     * @param _id Id of the job.
     */
    function settleDispute(uint256 _id, address _beneficiary)
        external
        onlyOwner
    {
        require(
            jobs[_id].jobStatus == JobStatus.IN_DISPUTE,
            "Escrow: Only a job in dispute can be settled"
        );
        uint256 _lancAmount = stableTokenConverter.convertBackFromStable(
            jobs[_id].convertedStableTokenAmount,
            address(this)
        );

        (uint256 _feeAmount, uint256 _amount) = computeFeeAmountForJob(
            _id,
            _lancAmount
        );
        token.transfer(_beneficiary, _amount);
        token.transfer(feeBeneficiary, _feeAmount);

        jobs[_id].jobStatus = JobStatus.DISPUTE_SETTLED;
        emit DisputeSettled(_id, _beneficiary);
    }

    /**
     * @dev This is called only for updates or emergency situations to salvage locked stable coin.
     * @dev Can also be used for returning back any stuck `ERC20` tokens to owners.
     */
    function extractERC20TokenAmount(
        address _erc20TokenAddress,
        address _to,
        uint256 _amount
    ) external whenPaused onlyOwner {
        IERC20(_erc20TokenAddress).transfer(_to, _amount);
    }

    /**
     * @dev Stops non-owner function interractions.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Resumes non-owner function interractions.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Returns the @return _feeAmount amount that should be taxed.
     * @dev Returns the @return _amount amount that should be released to freelancer or settled.
     */
    function computeFeeAmountForJob(uint256 _jobId, uint256 _lancAmount)
        internal
        view
        returns (uint256 _feeAmount, uint256 _amount)
    {
        uint256 _fee;
        if (preferentialFees[jobs[_jobId].employer].exists) {
            _fee = preferentialFees[jobs[_jobId].employer].fee;
        } else {
            _fee = fee;
        }
        _feeAmount = (_lancAmount * _fee) / BASIS_POINTS_10000;
        _amount = _lancAmount - _feeAmount;
    }

    /**
     * @dev Allows invocation only on a valid job (existing and funded).
     */
    modifier onlyExistingAndFundedJobs(uint256 _id) {
        require(
            jobs[_id].exists && jobs[_id].jobStatus == JobStatus.FUNDED,
            "Escrow: Can not perform action on a non existing job or a non-funded job"
        );
        _;
    }

    /**
     * @dev Allows only the freelancer can call the modified function.
     */
    modifier onlyFreelancerOrEmployer(uint256 _id) {
        require(
            jobs[_id].freelancer == msg.sender ||
                jobs[_id].employer == msg.sender,
            "Escrow: Only the freelancer or the employer can call this"
        );
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStableTokenConverter {
    /**
     * @dev ERC20 token address used for conversion.
     */
    function stableTokenAddress() external view returns (address);

    /**
     * @dev ERC20 token address used for conversion.
     */
    function swapTokenAddress() external view returns (address);

    /**
     * @dev Requires execution of `ERC20.approve` of @param _amountIn amount of swap token for this smart contract address.
     * @dev Converts the sender's @param _amountIn amount of swap tokens in @param _amountOut amount of stable tokens.
     * @dev The stable tokens are sent to the @param _to parameter.
     * @dev The stable token and the swap token are configured in the contract's contructor.
     */
    function convertToStable(uint256 _amountIn, address _to)
        external
        returns (uint256 _amountOut);

    /**
     * @dev Requires execution of `ERC20.approve` of @param _amountIn amount of stable token for this smart contract address.
     * @dev Converts the sender's @param _amountIn amount of stable tokens in @param _amountOut amount of swap tokens.
     * @dev The swap tokens are sent to the @param _to parameter.
     * @dev The stable token and the swap token are configured in the contract's contructor.
     */
    function convertBackFromStable(uint256 _amountIn, address _to)
        external
        returns (uint256 _amountOut);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract JobContext {

    /**
     * @dev Job metadata
     * @param id Job or milestone id. Unique identifier of the current deposit on the Lanceria platform.
     * Must be linked with an internal UUID from the database.
     * @param employer Address of the job requester that also deposits the token.
     * @param freelancer Address of the deposit receiver.
     * @param amount How much Stable token amount has been deposited for this specific Job. 
     * (LANC is being converted to stable token at deposit time).
     */
    struct Job {
        uint256 id;
        address freelancer;
        address employer;
        uint256 depositedLANCamount;
        uint256 convertedStableTokenAmount;
        JobStatus jobStatus;
        bool exists;
        bool freelancerApproval;
        bool employerApproval;
    }

    /**
     * @dev REQUESTED - When the employer called the `deposit()` function.
     * @dev FUNDED - When the Job was verified and the Token's `transferFrom()` function executed with success.
     * @dev IN_DISPUTE - If employer and freelancer raised a dispute.
     * @dev RELEASED - When the Job was approved both by freelancer and employer.
     * @dev DISPUTE_SETTLED - After a raised dispute, the owner will revert funds to a beneficiarry address.
     */
    enum JobStatus {
        REQUESTED,
        FUNDED,
        IN_DISPUTE,
        RELEASED,
        DISPUTE_SETTLED
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FeeContext {

    /**
     * @dev Preferential fee information for @param beneficiary.
     * @param fee Expressed in basis points.
     */
    struct Fee {
        uint256 fee;
        address beneficiary;
        bool exists;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

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
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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