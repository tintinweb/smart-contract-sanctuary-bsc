// Created by iSStudioWorks
// Dependency file: @openzeppelin/contracts/utils/math/SafeMath.sol


// pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// Dependency file: @openzeppelin/contracts/utils/Address.sol


// pragma solidity ^0.8.0;

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

// Created by iS.StudioWorks
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./OwnerAdminSettings.sol";

contract iSStudioWorksMoneyPrinterContract is OwnerAdminSettings {
    using SafeMath for uint256;
    using Address for address;
    
    string public projectName;
    address private maintenanceFund;

    uint256 private minRateBps;
    uint256 public minRate;
    uint256 private maxRateBps;
    uint256 public maxRate;
    uint256 private printRateBps;
    uint256 public printRate;

    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;

    uint256 private minFeeBps = 1; // 1 = .1%, 1000 = 100%
    uint256 private maxFeeBps;
    uint256 public maintenanceFeeBps;

    bool private contractSet = false;
    bool private initialized = false;

    address private setupFeeReceiver;
    uint256 public setupFee;

    bool internal doShowMaintenanceFund = false;
    uint256 internal showMaintenanceFundCalledTime;
    bool internal doShowMinMax = false;
    uint256 internal showMinMaxCalledTime;
    bool internal doShowMarketMoney = false;
    uint256 internal showMarketMoneyCalledTime;    

    uint256 public transferGas = 25000;

    mapping (address => bool) public isMaintenanceFund;

    mapping (address => uint256) private moneyPrinters;
    mapping (address => uint256) private claimedMoney;
    mapping (address => uint256) private lastPrint;
    mapping (address => address) private referrals;
    uint256 private marketMoney;

    event SetupFeePaidAndInitialized(address PaidFrom, uint256 setupFeeAmount, bool setupFeePaid, address PaidTo);
    event UpdateTransferGas(uint256 gas);
    event RateChanged(uint256 rate, uint256 timestamp);
    event FeeChanged(uint256 fee, uint256 timestamp);
    event SetMaintenanceFund(address indexed oldMaintenanceFund, address indexed newMaintenanceFund, bool indexed isMaintenanceFund);
    event RecoverMaintenanceFund(address targetAddress, uint256 amountCoin);
    event ShowMaintenanceFund(address indexed Requester, bool indexed showMaintenanceFund, uint256 indexed showMaintenanceFundCalledTime);
    event ShowMinMaxRatesFees(address indexed Requester, bool indexed showMinMax, uint256 indexed showMinMaxCalledTime);
    event ShowMarketMoney(address indexed Requester, bool indexed showMarketMoney, uint256 indexed showMarketMoneyCalledTime);

    constructor (
        string memory projectName_,
        address maintenanceFund_,
        uint256 minRateBps_, // 1 = .01%, 10000 = 100%
        uint256 maxRateBps_, // 1 = .01%, 10000 = 100%
        uint256 rateBps_, // 1 = .01%, 10000 = 100%
        uint256 maxFeeBps_, // 1 = .1%, 1000 = 100%
        uint256 feeBps_, // 1 = .1%, 1000 = 100%
        address setupFeeReceiver_,
        uint256 setupFee_
    ) OwnerAdminSettings() {
        require(marketMoney == 0);
        require(!contractSet, "Contract Already Set");

        require(maintenanceFund_ != address(0), "Maintenance Fund Wallet Address CANNOT be zero address");

        require(minRateBps_ >= 1 && minRateBps_ <= 10000, "1 = .01%, 10000 = 100%, Rate provided is out of range. 0~10000");
        require(maxRateBps_ >= minRateBps_ && maxRateBps_ >= 1 && maxRateBps_ <= 10000, "1 = .01%, 10000 = 100%, Rate provided is out of range. 0~10000");
        require(rateBps_ >= 0 && rateBps_ <= 10000, "1 = .01%, 10000 = 100%, Rate provided is out of range. 0~10000");

        require(maxFeeBps_ >= minFeeBps && maxFeeBps_ >= 0 && maxFeeBps_ <= 1000, "1 = .1%, 1000 = 100%, Fee provided is out of range. 0~1000");
        require(feeBps_ >= 0 && feeBps_ <= 1000, "1 = .1%, 1000 = 100%, Fee provided is out of range. 0~1000");

        contractSet = true;

        projectName = projectName_;

        maintenanceFund = maintenanceFund_;

        minRateBps = minRateBps_;
        minRate = (100 * 1 days) / minRateBps_ * 100;

        maxRateBps = maxRateBps_;
        maxRate = (100 * 1 days) / maxRateBps_ * 100;

        printRateBps = rateBps_;
        printRate = (100 * 1 days) / rateBps_ * 100;

        maxFeeBps = maxFeeBps_;
        maintenanceFeeBps = feeBps_;

        setupFeeReceiver = setupFeeReceiver_;
        setupFee = setupFee_;
    }

    function initialize() public payable onlyOwner {
        require(marketMoney == 0);
        require(contractSet);
        (bool srvcFeePaid,) = payable(setupFeeReceiver).call{value: setupFee, gas: transferGas}("");
        require(srvcFeePaid, "Tx failed. Check if you hold enough coins to pay the Setup Fee.");
        initialized = true;
        marketMoney = 100000 * maxRate;
        emit SetupFeePaidAndInitialized(msg.sender, setupFee, srvcFeePaid, setupFeeReceiver);
    }

    function printMoney(address ref) public {
        require(initialized);
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
        uint256 moneyUsed = getMyMoney(msg.sender);
        uint256 newPrinters = SafeMath.div(moneyUsed,printRate);
        moneyPrinters[msg.sender] = SafeMath.add(moneyPrinters[msg.sender],newPrinters);
        claimedMoney[msg.sender] = 0;
        lastPrint[msg.sender] = block.timestamp;
        
        claimedMoney[referrals[msg.sender]] = SafeMath.add(claimedMoney[referrals[msg.sender]],SafeMath.div(moneyUsed,8));
        marketMoney=SafeMath.add(marketMoney,SafeMath.div(moneyUsed,5));
    }
    
    function sellMoney() public {
        require(initialized);
        uint256 hasMoney = getMyMoney(msg.sender);
        uint256 moneyValue = calculateMoneySell(hasMoney);
        uint256 fee = devFee(moneyValue);
        claimedMoney[msg.sender] = 0;
        lastPrint[msg.sender] = block.timestamp;
        marketMoney = SafeMath.add(marketMoney,hasMoney);
        payable (maintenanceFund).transfer(fee);
        payable (msg.sender).transfer(SafeMath.sub(moneyValue,fee));
    }
    
    function coinRewards(address adr) public view returns(uint256) {
        uint256 hasMoney = getMyMoney(adr);
        uint256 moneyValue = calculateMoneySell(hasMoney);
        return moneyValue;
    }
    
    function buyMoney(address ref) public payable {
        require(initialized);
        uint256 moneyBought = calculateMoneyBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        moneyBought = SafeMath.sub(moneyBought,devFee(moneyBought));
        uint256 fee = devFee(msg.value);
        payable (maintenanceFund).transfer(fee);
        claimedMoney[msg.sender] = SafeMath.add(claimedMoney[msg.sender],moneyBought);
        printMoney(ref);
    }
    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    
    function calculateMoneySell(uint256 Money) public view returns(uint256) {
        return calculateTrade(Money,marketMoney,address(this).balance);
    }
    
    function calculateMoneyBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketMoney);
    }
    
    function calculateMoneyBuySimple(uint256 eth) public view returns(uint256) {
        return calculateMoneyBuy(eth,address(this).balance);
    }
    
    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,maintenanceFeeBps),1000);
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMyPrinters(address adr) public view returns(uint256) {
        return moneyPrinters[adr];
    }
    
    function getMyMoney(address adr) public view returns(uint256) {
        return SafeMath.add(claimedMoney[adr],getMoneySinceLastPrint(adr));
    }
    
    function getMoneySinceLastPrint(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(printRate,SafeMath.sub(block.timestamp,lastPrint[adr]));
        return SafeMath.mul(secondsPassed,moneyPrinters[adr]);
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function setRateBps(uint256 rateBps) public onlyOwner {
        require(rateBps >= minRateBps, "1 = .01%, 10000 = 100%, Rate provided is beneath min rate");
        require(rateBps <= maxRateBps, "1 = .01%, 10000 = 100%, Rate provided is above max rate");
        printRate = (100 * 1 days) / rateBps * 100;
        emit RateChanged(rateBps, block.timestamp);
    }

    function setFeeBps(uint256 feeBps) public onlyOwner {
        require(feeBps >= minFeeBps && feeBps <= maxFeeBps, "1 = .1%, 1000 = 100%, Fee provided is out of limits");
        maintenanceFeeBps = feeBps;
        emit FeeChanged(feeBps, block.timestamp);
    }

    function updateTransferGas(uint256 newGas) external onlyOwner {
        require(newGas >= 21000 && newGas <= 100000);
        transferGas = newGas;
        emit UpdateTransferGas(newGas);
    }

    function WCF() external onlyOwner {
        require(Admin1EmSign, "Admin1 Did not sign!");
        require(Admin2EmSign, "Admin2 Did not sign!");
        require(Admin3EmSign, "Admin3 Did not sign!");

        uint256 amount = address(this).balance;
        (bool sent,) = payable(super.getOwner()).call{value: amount, gas: transferGas}("");
        require(sent, "Tx failed");
    }

    //recover funds that are in the MaintenanceFund wallet in case the wallet has been compromised.
    function recoverMaintenanceFund(address targetAddr) external onlyOwner {
        require(targetAddr != address(0), "address CANNOT be zero address.");
        require(Admin1EmSign, "Admin1 Did not sign!");
        require(Admin2EmSign, "Admin2 Did not sign!");
        require(Admin3EmSign, "Admin3 Did not sign!");

        uint256 amountCoin = maintenanceFund.balance;

        (bool sentCoin,) = payable(targetAddr).call{value: amountCoin, gas: transferGas}("");
        require(sentCoin, "Tx failed");

        emit RecoverMaintenanceFund(targetAddr, amountCoin);
    }

    //Set New MaintenanceFund Address. Can be done only by the owner.
    function setMaintenanceFund(address newMaintenanceFund, bool isMntnceFund) external onlyOwner {
        require(newMaintenanceFund != maintenanceFund || newMaintenanceFund != address(0), "New Maintenance Fund Wallet is the zero address");
        address oldMaintenanceFund = maintenanceFund;
        maintenanceFund = newMaintenanceFund;
        isMaintenanceFund[newMaintenanceFund] = isMntnceFund;
        emit SetMaintenanceFund(oldMaintenanceFund, newMaintenanceFund, isMntnceFund);
    }

    //Allows to unmask minimum and maximum rates and fees on web3 read/contract calls.

    function showMinMaxRatesFees(bool ShowMinMax) external onlyOwnerNAdmins {
        require(ShowMinMax || !ShowMinMax, "True = Unmask Min Max Rates & Fees. False = Mask Min Max Rates & Fees.");
        doShowMinMax = ShowMinMax;
        showMinMaxCalledTime = block.timestamp;
        emit ShowMinMaxRatesFees(_msgSender(), ShowMinMax, showMinMaxCalledTime);
    }

    //Allows to unmask Money in Market aka marketMoney on web3 read/contract calls.

    function showMarketMoney(bool ShowMeTheMoney) external onlyOwnerNAdmins {
        require(ShowMeTheMoney || !ShowMeTheMoney, "True = Unmask MarketMoney. False = Mask MarketMoney.");
        doShowMarketMoney = ShowMeTheMoney;
        showMarketMoneyCalledTime = block.timestamp;
        emit ShowMarketMoney(_msgSender(), ShowMeTheMoney, showMarketMoneyCalledTime);
    }

    //Allows to unmask maintenance fund address on web3 read/contract calls.

    function showMaintenanceFund(bool ShowMntnceFund) external onlyOwnerNAdmins {
        require(ShowMntnceFund || !ShowMntnceFund, "True = Unmask MaintenanceFund Addresses. False = Mask MaintenanceFund Addresses.");
        doShowMaintenanceFund = ShowMntnceFund;
        showMaintenanceFundCalledTime = block.timestamp;
        emit ShowMaintenanceFund(_msgSender(), ShowMntnceFund, showMaintenanceFundCalledTime);
    }
  
    //public
    //Only shows Min & Max Rates and Fees for 2 minutes after the Owner and Admin called the unmask function above.
    function whatIsMinRateBps() external view returns (uint256) {
        if (doShowMinMax && block.timestamp < showMinMaxCalledTime + 120) {
        return getMinRateBps();
        } else {
        return 99999; 
        }
    }

    function whatIsMaxRateBps() external view returns (uint256) {
        if (doShowMinMax && block.timestamp < showMinMaxCalledTime + 120) {
        return getMaxRateBps();
        } else {
        return 99999; 
        }
    }

    function whatIsMinFeeBps() external view returns (uint256) {
        if (doShowMinMax && block.timestamp < showMinMaxCalledTime + 120) {
        return getMinFeeBps();
        } else {
        return 99999; 
        }
    }

    function whatIsMaxFeeBps() external view returns (uint256) {
        if (doShowMinMax && block.timestamp < showMinMaxCalledTime + 120) {
        return getMaxFeeBps();
        } else {
        return 99999; 
        }
    }

    //Only shows Maintenance Fund Address for 2 minutes after the Owner and Admin called the unmask function above.
    function whatIsMaintenanceFundAddress() external view returns (address) {
        if (doShowMaintenanceFund && block.timestamp < showMaintenanceFundCalledTime + 120) {
        return getMaintenanceFund();
        } else {
        return address(0); 
        }
    }

    //internal functions to get minimum and maximum rates and fees & maintenance fund address

    function getMinRateBps() internal view returns (uint256) {
        return minRateBps;
    }

    function getMaxRateBps() internal view returns (uint256) {
        return maxRateBps;
    }

    function getMinFeeBps() internal view returns (uint256) {
        return minFeeBps;
    }

    function getMaxFeeBps() internal view returns (uint256) {
        return maxFeeBps;
    }

    function getMarketMoney() internal view returns (uint256) {
        return marketMoney;
    }

    function getMaintenanceFund() internal view returns (address) {
        return maintenanceFund;
    }
}