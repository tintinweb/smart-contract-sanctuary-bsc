// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
        assembly { size := extcodesize(account) }
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
        (bool success, ) = recipient.call{ value: amount }("");
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./SafeERC20.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";

interface IAthStaking {
    function athLevel(address user_) external view returns(uint256 level);
}

/// @title IDOPool
/// @notice IDO contract useful for launching NewIDO
//solhint-disable-next-line max-states-count
contract IDOPool is Ownable, ReentrancyGuard {
    enum InvestorType {
        LEVEL_0,
        LEVEL_1,
        LEVEL_2,
        LEVEL_3
    }

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /**
     * @dev Struct to store information of each Sale
     * @param investor Address of user/investor
     * @param amount Amount of tokens to be purchased
     * @param tokensWithdrawn Amount of Tokens Withdrawal
     * @param tokenWithdrawnStatus Tokens Withdrawal status
     */
    struct Sale {
        address investor;
        uint256 amount;
        uint256 feePaid;
        uint256 allocatedAmount;
        uint256 tokensWithdrawn;
        bool tokenWithdrawnStatus;
    }

    // Token for sale
    IERC20 public token;
    // Token Decimal
    uint256 public tokenDecimal;
    // Token used to buy
    IERC20 public currency;
    // Ath Staking contract
    IAthStaking public athStaking;

    // DEV TEAM Address
    address public devAddress;
    // List investors
    address[] private investorList;
    // Info of each investor that buy tokens.
    mapping(address => Sale) public sales;
    // pre-sale start time
    uint256 public startTime;
    // pre-sale end time
    uint256 public endTime;
    // funding Period
    uint256 public fundingPeriod;
    // Price of each token
    uint256 public price;
    // Amount of tokens remaining
    uint256 public availableTokens;
    // Total amount of tokens to be sold
    uint256 public totalAmount;
    // Total amount sold
    uint256 public totalAmountSold;
    // Release time
    uint256 public releaseTime;
    // total collected Fee
    uint256 public collectedFee;
    // total fund rasied
    uint256 public totalFundRaised;
    // total pre-sale token suppiled
    uint256 public totalIDOTokenSupplied;
    // total pre-sale token claimed by user
    uint256 public totalIDOTokenClaimed;
    // Number of investors
    uint256 public numberParticipants;
    // Amount of tokens remaining w.r.t Tier
    mapping(uint8 => uint256) public tierMaxAmountThatCanBeInvested;
    // Participation fee based on Ath Staking Level
    mapping(uint8 => uint256) public participationFee;

    /************************* Event's *************************/

    event Buy(address indexed _user, uint256 _amount, uint256 fee, uint256 _tokenAmount);
    event Claim(address indexed _user, uint256 _amount);
    event Withdraw(address indexed _user, uint256 _amount);
    event EmergencyWithdraw(address indexed _user, uint256 _amount);
    event TokenRecovered(address indexed _user, address indexed _token, uint256 _amount);
    event TokenAddressUpdated(address indexed _user, address indexed _token);
    event AthStakingUpdated(address indexed _user, address _oldStaking, address _newStaking);
    event DevAddressUpdated(address indexed _user, address _oldDev, address _newDev);
    event IDOTokenSupplied(address indexed _user, uint256 _amount);

    /**************************************************************/

    /************************* Modifier's *************************/

    modifier publicSaleActive() {
        require(
            block.timestamp >= startTime,
            "Public sale is not yet activated"
        );
        _;
    }

    modifier publicSaleEnded() {
        require((block.timestamp > endTime || availableTokens == 0), "Public sale not yet ended");
        _;
    }

    modifier canClaim() {
        require(block.timestamp >= releaseTime, "Please wait until release time for claiming tokens");
        _;
    }

    /**********************************************************/

    /**
     * @dev Initialzes the TierIDO Pool contract
     * @param _token The ERC20 token contract address
     * @param _tokenDecimal The ERC20 token decimal
     * @param _currency The curreny used for the IDO
     * @param _startTime Timestamp of when pre-Sale starts
     * @param _fundingPeriod funding Period in seconds
     * @param _releaseTime Timestamp of when the token will be released
     * @param _price Price of the token for the IDO
     * @param _totalAmount The total amount for the IDO
     */
    //solhint-disable-next-line function-max-lines
    constructor(
        address _token,
        uint256 _tokenDecimal,
        address _currency,
        uint256 _startTime,
        uint256 _fundingPeriod,
        uint256 _releaseTime,
        uint256 _price,
        uint256 _totalAmount
    ) public {
        require(_tokenDecimal > 0, "_tokenDecimal must be greater Zero");
        require(_currency != address(0), "Currency address cannot be address zero");
        require(_startTime >= block.timestamp, "start time > current time");
        require(_fundingPeriod >= 1 hours, "_fundingPeriod time > 1 hour");
        require(_releaseTime > _startTime + _fundingPeriod, "release time > end time");
        require(_totalAmount > 0, "Total amount must be > 0");

        token = IERC20(_token);
        tokenDecimal = _tokenDecimal;
        currency = IERC20(_currency);
        startTime = _startTime;
        endTime = _startTime + _fundingPeriod;
        fundingPeriod = _fundingPeriod;
        releaseTime = _releaseTime;
        price = _price;
        totalAmount = _totalAmount;
        availableTokens = _totalAmount;

        athStaking = IAthStaking(0x48E5Fc0cD874fB2eC9C5dd67d3e141C0DA152DA3);
    }

    /************************* Internal function's *************************/

    /**
     * @dev To determine whether investor can buy depending on the investor type
     */
    function isParticipationTimeCrossed(InvestorType _investoryType) public view returns (bool) {
        uint256 lockPeriod = fundingPeriod.div(4);
        if (_investoryType == InvestorType.LEVEL_0) {
            return (now >= startTime.add(lockPeriod.mul(3)));
        } else if (_investoryType == InvestorType.LEVEL_1) {
            return (now >= startTime.add(lockPeriod.mul(2)));
        } else if (_investoryType == InvestorType.LEVEL_2) {
            return (now >= (startTime + lockPeriod));
        } else if (_investoryType == InvestorType.LEVEL_3) {
            return (now >= startTime);
        } else {
            return false;
        }
    }

    /**
     * @dev To transfer Currency token
     */
    function transferCurrencyToken() internal {
        uint256 currencyBalance = currency.balanceOf(address(this));

        currency.safeTransfer(owner(), collectedFee);
        emit Withdraw(owner(), collectedFee);

        currency.safeTransfer(devAddress, currencyBalance.sub(collectedFee));
        emit Withdraw(devAddress, currencyBalance.sub(collectedFee));
    }

    /***********************************************************************/

    /*************************** view function's ***************************/

    /**
     * @dev claimable amount of IDO token
     * Returns amount IDO token available to claim
     */
    function claimableAmount(address _user) public view returns (uint256 _tokenAmount){
        Sale memory sale = sales[_user];

        if (block.timestamp < releaseTime || sale.tokenWithdrawnStatus || sale.allocatedAmount == 0) {
            return 0;
        }

        uint256 tAmount = sale.allocatedAmount.mul(totalIDOTokenSupplied).div(totalAmountSold);
        _tokenAmount = tAmount.sub(sale.tokensWithdrawn);
    }


    /**
     * @dev To get investor of the IDO
     * Returns array of investor addresses and their invested funds
     */
    function getInvestorsDetails() external view returns (address[] memory, uint256[] memory, uint256[] memory) {
        address[] memory addrs = new address[](numberParticipants);
        uint256[] memory funds = new uint256[](numberParticipants);
        uint256[] memory allocatedfunds = new uint256[](numberParticipants);

        for (uint256 i = 0; i < numberParticipants; i++) {
            addrs[i] = sales[investorList[i]].investor;
            funds[i] = sales[investorList[i]].amount;
            allocatedfunds[i] = sales[investorList[i]].allocatedAmount;
        }

        return (addrs, funds, allocatedfunds);
    }

    /**
     * @dev To get investor address of the IDO
     * Returns only array of investor addresses
     */
    function getInvestorList() external view returns(address[] memory) {
        return investorList;
    }

    /**
     * @dev To get type of investor depending on amount Ath staked
     */
    function getInvestorType(address _user) public view returns (InvestorType level) {
        level = InvestorType(athStaking.athLevel(_user));
        require(level <= InvestorType.LEVEL_3, "Derived Level is out of Range");
    }

    /***********************************************************************/

    /************************ Restricted function's ************************/

    /**
     * @dev To withdraw tokens after the sale ends and burns the remaining tokens
     *
     * Requirements:
     * - invocation can be done, only by the contract owner.
     * - the public sale must have ended
     * - this call is non reentrant
     */
    function withdraw() external onlyOwner publicSaleEnded nonReentrant {
        if (availableTokens > 0) {
            availableTokens = 0;
        }

        transferCurrencyToken();
    }

    /**
     * @dev To withdraw in case of any possible hack/vulnerability
     *
     * Requirements:
     * - invocation can be done, only by the contract owner.
     * - this call is non reentrant
     */
    function emergencyWithdraw() external onlyOwner nonReentrant {
        if (availableTokens > 0) {
            availableTokens = 0;
        }

        if (totalIDOTokenSupplied > 0 &&
            totalIDOTokenSupplied > totalIDOTokenClaimed) {
                token.transfer(owner(), totalIDOTokenSupplied.sub(totalIDOTokenClaimed));
        }
        transferCurrencyToken();
    }

    /**
     * @dev To add users and tiers to the contract storage
     * @param _participationFees An array of participation fee as per tiers
     * @param _maxAmountThatCanBeInvestedInTiers An array of max investments amount in tiers
     */
    function setTierInfo(
            uint256[] memory _participationFees,
            uint256[] memory _maxAmountThatCanBeInvestedInTiers
    )
        public onlyOwner
    {
        for (uint8 i = 0; i < _maxAmountThatCanBeInvestedInTiers.length; i++) {
            require(_maxAmountThatCanBeInvestedInTiers[i] > 0, "Tier allocation amount must be > 0");
            // Since we have named Tier1, Tier2, Tier3 & Tier4
            tierMaxAmountThatCanBeInvested[i + 1] = _maxAmountThatCanBeInvestedInTiers[i];
            participationFee[i + 1] = _participationFees[i];
        }
    }

    /**
     * @dev To set the Ath Staking address
     * @param _athStaking ath staking contract address
     */
    function setAthStaking(address _athStaking) external onlyOwner {
        require(_athStaking != address(0x0), "_athStaking should be valid address");

        emit AthStakingUpdated(msg.sender, address(athStaking), _athStaking);
        athStaking = IAthStaking(_athStaking);
    }

    /**
     * @dev To set the DEV address
     * @param _devAddr dev wallet address.
     */
    function setDevAddress(address _devAddr) external onlyOwner {
        require(_devAddr != address(0x0), "_devAddr should be valid Address");

        emit DevAddressUpdated(msg.sender, devAddress, _devAddr);
        devAddress = _devAddr;
    }

    /**
     * @dev To set the Token address
     * @param _token token address.
     */
    function setTokenAddress(address _token) external onlyOwner {
        require(_token != address(0x0), "_token should be valid Address");

        token = IERC20(_token);
        tokenDecimal = token.decimals();

        emit TokenAddressUpdated(msg.sender, _token);
    }

    /**
     * @dev To recover ERC20 token sent to contract by mistake
     * @param _tokenAddress ERC20 token address which need to recover
     * @param _amount amount of token to be recover
     */
    function recoverToken(address _tokenAddress, uint256 _amount) external onlyOwner {
        IERC20 _token = IERC20(_tokenAddress);
        _token.safeTransfer(msg.sender, _amount);

        emit TokenRecovered(msg.sender, _tokenAddress, _amount);
    }

    /**
     * @dev To supply IDO token to contract
     * @param _amount amount of token to be supplied to contract
     */
    function supplyIDOToken(uint256 _amount) external onlyOwner {
        require(totalIDOTokenSupplied.add(_amount) <= totalAmountSold,
                    "IDO token amount is overflooded!!");

        token.safeTransferFrom(msg.sender, address(this), _amount);
        totalIDOTokenSupplied += _amount;

        emit IDOTokenSupplied(msg.sender, _amount);
    }

    /***********************************************************************/

    /************************* External function's *************************/
    /**
     * @dev To buy tokens
     *
     * @param amount The amount of tokens to buy
     *
     * Requirements:
     * - can be invoked only when the public sale is active
     * - this call is non reentrant
     */
    function buy(uint256 amount) external publicSaleActive nonReentrant {
        require(availableTokens > 0,
                "All tokens were purchased");

        require(amount > 0,
                "Amount must be > 0");


        require(currency.balanceOf(msg.sender) >= amount,
                "Insufficient currency balance of caller");

        InvestorType investorType = getInvestorType(msg.sender);
        require(isParticipationTimeCrossed(investorType),
                "Participation time is not yet crossed. Please wait.");

        uint8 tier = uint8(investorType) + 1;
        uint256 fee = amount.mul(participationFee[tier]).div(10000);
        if (fee > 0) {
            collectedFee = collectedFee.add(fee);
        }

        uint256 amountAfterFee = amount.sub(fee);
        uint256 allocatedToken = (amountAfterFee).mul(10 ** tokenDecimal).div(price);

        require(allocatedToken <= availableTokens,
                "Not enough tokens to buy");

        Sale storage sale = sales[msg.sender];
        require(sale.allocatedAmount.add(allocatedToken) <= tierMaxAmountThatCanBeInvested[tier],
                "amount exceeds buy limit");

        availableTokens = availableTokens.sub(allocatedToken);
        totalAmountSold = totalAmountSold.add(allocatedToken);
        totalFundRaised = totalFundRaised.add(amountAfterFee);

        currency.safeTransferFrom(msg.sender, address(this), amount);

        if (sale.allocatedAmount == 0) {
            sales[msg.sender] = Sale(msg.sender,
                                        amount,
                                        fee,
                                        allocatedToken,
                                        0,
                                        false);
            numberParticipants += 1;
            investorList.push(msg.sender);
        } else {
            sales[msg.sender] = Sale(msg.sender,
                                        sale.amount.add(amount),
                                        sale.feePaid.add(fee),
                                        sale.allocatedAmount.add(allocatedToken),
                                        0,
                                        false);
        }

        emit Buy(msg.sender, amount, fee, allocatedToken);
    }

    /**
     * @dev To withdraw purchased tokens after release time
     *
     * Requirements:
     * - this call is non reentrant
     * - cannot claim within release time
     */
    function claimTokens() external canClaim nonReentrant {
        Sale storage sale = sales[msg.sender];
        require(!sale.tokenWithdrawnStatus, "Already withdrawn");
        require(sale.allocatedAmount > 0, "Only investors");

        uint256 tokenAmount = claimableAmount(msg.sender);
        token.transfer(sale.investor, tokenAmount);

        sale.tokensWithdrawn += tokenAmount;
        totalIDOTokenClaimed += tokenAmount;
        if (sale.tokensWithdrawn == sale.allocatedAmount) {
            sale.tokenWithdrawnStatus = true;
        }

        emit Claim(msg.sender, tokenAmount);
    }

    /***********************************************************************/
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    /**
      * @dev Return token Decimal
      */
    function decimals() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Context.sol";
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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}