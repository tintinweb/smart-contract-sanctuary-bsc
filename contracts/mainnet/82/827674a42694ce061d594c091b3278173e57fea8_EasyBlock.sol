/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: MIT

//    //   / /                                 //   ) )
//   //____     ___      ___                  //___/ /  //  ___      ___     / ___
//  / ____    //   ) ) ((   ) ) //   / /     / __  (   // //   ) ) //   ) ) //\ \
// //        //   / /   \ \    ((___/ /     //    ) ) // //   / / //       //  \ \
////____/ / ((___( ( //   ) )      / /     //____/ / // ((___/ / ((____   //    \ \
// Developed by Dogu Deniz UGUR (https://github.com/DoguD)

pragma solidity ^0.8.0;

// LIBRARIES START
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol) Source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol
library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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
        // This method relies in extcodesize, which returns 0 for contracts in
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
     * {ReentrancyGuard}
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
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

// ERC20 Interface
interface IERC20 {
    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

// LIBRARIES END

// PREVIOUS EASYBLOCK CONTRACT INTERFACE
interface Easyblock {
    function holders(uint256 _index) external view returns (address);

    function shareCount(address _address) external view returns (uint256);
}

// Verification Contract Interface
interface Verifier {
    function verifyString(string memory message, uint8 v, bytes32 r,
              bytes32 s) external pure returns (address signer);
}

// Price and Premium Oracles
interface PriceOracle {
    function getPrice() external view returns (uint256);
}

interface PremiumOracle {
    function getPremium() external view returns (uint256);
}

contract EasyBlock {
    using SafeERC20 for IERC20;

    // Shareholder Info
    address[] public holders;
    mapping(address => uint256) public shareCount;
    mapping(address => uint256) public referFeeEarned;
    mapping(address => uint32) public referSaleCount;
    mapping(address => bool) public isShareHolder;
    mapping(address => bool) public isAutoCompounding;
    // General Info
    uint256 public totalShareCount;
    uint256 public totalShareCountAutoCompounding;
    uint256 public sharesInNFTs;
    uint32 public holderCount;
    uint256 public totalInvestment;
    uint256 public totalRewardsDistributed;
    uint256 public totalReferralRewardDistributed;
    uint256 public totalInitialFeeCollected;
    // Manager Info
    address public manager;
    address[] public accessWallets;
    uint256 public rewardFee; // per 1000
    uint256 public initialFee; // per 1000
    uint256 public referFee; // per 1000 of the initial fee
    mapping(address => uint256) public addressDiscount; // per 1000 of the initial fee
    uint256 public discount; // per 1000 of the initial fee
    address public feeCollector;
    // Deposit Token
    address public rewardToken;
    // Purchase Tokens
    address public purchaseToken;
    uint256 public newInvestments;
    uint256 public premiumCollected;
    uint256 public premiumCollectedSellShare;
    // StrongBlock Node Holders
    address[] public nodeHolders;
    uint8 public nodeHoldersCount;
    uint16 public nodeCount;
    // Protocol controllers
    bool public sharePurchaseEnabled;
    // Experimental sell function
    uint256 public sellFeeDeveloper; // per 1000
    uint256 public sellFeeCommunity; // per 1000
    address public sellToken;
    uint256 public totalSharesSold;
    bool public isSellAllowed;
    uint256 public totalAmountOfSellBack;
    // Transfer share feature
    bool public isTransferEnabled;
    // Migration
    bool public isMigrating = true;
    address public previousContract;
    Easyblock easyContract;
    // Discount verification
    address public signerAddress;
    address public verifyAddress;
    // Oracles
    PriceOracle priceOracle;
    PremiumOracle premiumOracle;

    /* ======== EVENTS ======== */
    event Investment(
        uint256 shareAmount,
        uint256 investmentInUSD,
        address shareHolder
    );
    event ShareSold(
        uint256 shareCount,
        uint256 amountInTotal,
        address shareHolder
    );
    event ShareTransfer(address from, address to, uint256 shareCount);
    event ToggleAutocompound(address shareHolder, bool isAutoCompounding);

    constructor(
        uint256 _rewardFee,
        uint256 _initialFee,
        uint256 _referFee,
        uint256 _totalInvestment,
        uint256 _totalRewards,
        address _tokenAddress,
        address _previousContract
    ) {
        manager = msg.sender;
        feeCollector = msg.sender;

        rewardFee = _rewardFee;
        initialFee = _initialFee;
        referFee = _referFee;

        totalInvestment = _totalInvestment;
        totalRewardsDistributed = _totalRewards;

        purchaseToken = _tokenAddress;
        sellToken = _tokenAddress;
        rewardToken = _tokenAddress;

        // Migration
        previousContract = _previousContract;
        easyContract = Easyblock(previousContract);
    }

    // Discount verification
    function setSignerAddress(address _signerAddress) public onlyOwner{
        signerAddress = _signerAddress;
    }
    function setVerifyContract(address _verifyContract) public onlyOwner{
        verifyAddress = _verifyContract;
    }

    // Oracles
    function setPriceOracle(address _priceOracle) public onlyOwner{
        priceOracle = PriceOracle(_priceOracle);
    }
    function setPremiumOracle(address _premiumOracle) public onlyOwner{
        premiumOracle = PremiumOracle(_premiumOracle);
    }

    // Experimental sell functions
    function setSellToken(address _sellToken) external onlyOwner {
        sellToken = _sellToken;
    }

    function setSellFeeDeveloper(uint256 _fee) external onlyOwner {
        sellFeeDeveloper = _fee;
    }

    function setSellFeeCommunity(uint256 _fee) external onlyOwner {
        sellFeeCommunity = _fee;
    }

    function toggleIsSellAllowed(bool _isSellAllowed) external onlyOwner {
        isSellAllowed = _isSellAllowed;
    }

    function getSellPrice() public view returns (uint256) {
        return
            (priceOracle.getPrice() *
                (1000 - (sellFeeDeveloper + sellFeeCommunity))) / 1000;
    }

    function getMaxAmountOfSharesToBeSold() public view returns (uint256) {
        uint256 _maxAmount = newInvestments / priceOracle.getPrice();
        return _maxAmount;
    }

    function sellBackShares(uint256 _shareAmount) external {
        require(isSellAllowed, "Sell is not allowed");
        require(
            _shareAmount <= shareCount[msg.sender],
            "Not enough shares to sell"
        );
        require(
            _shareAmount <= getMaxAmountOfSharesToBeSold(),
            "Not enough shares to sell in treasury."
        );
        uint256 _sellAmount = _shareAmount * getSellPrice();
        uint256 _purchaseTokenPrice = priceOracle.getPrice();

        // STATE MANIPULATIONS PRE
        shareCount[msg.sender] = shareCount[msg.sender] - _shareAmount;
        totalSharesSold += _shareAmount;

        // Send developer their money
        IERC20(sellToken).safeTransfer(
            feeCollector,
            (_shareAmount * _purchaseTokenPrice * sellFeeDeveloper) / 1000
        );
        // Send seller their money
        IERC20(sellToken).safeTransfer(msg.sender, _sellAmount);

        // STATE MANIPULATIONS POST
        totalAmountOfSellBack += _sellAmount;
        totalShareCount -= _shareAmount;
        // Increase reward pool
        uint256 _communityFee = (_shareAmount *
            _purchaseTokenPrice *
            sellFeeCommunity) / 1000;
        premiumCollectedSellShare += _communityFee;
        // Decrease new investments
        newInvestments -= _shareAmount * _purchaseTokenPrice;

        emit ShareSold(_shareAmount, _sellAmount, msg.sender);
    }

    // Controller toggles
    function toggleSharePurchaseEnabled(bool _enabled) external onlyOwner {
        sharePurchaseEnabled = _enabled;
    }

    // Deposit to Purchase Methods
    function editPurchaseToken(address _tokenAddress) external onlyOwner {
        purchaseToken = _tokenAddress;
    }

    // Deposit to Share Rewards Methods
    function setDepositToken(address _tokenAddress) external onlyOwner {
        rewardToken = _tokenAddress;
    }

    // NodeHolders
    function setNodeHolder(address _address) external onlyOwner {
        nodeHolders.push(_address);
        nodeHoldersCount += 1;
    }

    function setNodeCount(uint16 _count) external onlyOwner {
        nodeCount = _count;
    }

    // Manager Related Methods
    function setManager(address _address) external onlyOwner {
        manager = _address;
    }

    function setFeeCollector(address _address) external onlyOwner {
        feeCollector = _address;
    }

    function setRewardFee(uint256 _fee) external onlyOwner {
        rewardFee = _fee;
    }

    function setInitalFee(uint256 _fee) external onlyOwner {
        initialFee = _fee;
    }

    function setReferFee(uint256 _fee) external onlyOwner {
        referFee = _fee;
    }

    // Withdrawals
    function withdrawToManager(uint256 _amount) external onlyOwner {
        require(
            _amount <= newInvestments,
            "Not enough new investments to withdraw."
        );
        IERC20(purchaseToken).safeTransfer(manager, _amount);
        newInvestments -= _amount;
    }

    function withdrawPremiumToManager() external onlyOwner {
        IERC20(purchaseToken).safeTransfer(manager, premiumCollected);
        premiumCollected = 0;
    }

    function withdrawPremiumSellToManager() external onlyOwner {
        IERC20(purchaseToken).safeTransfer(manager, premiumCollectedSellShare);
        premiumCollectedSellShare = 0;
    }

    function emergencyWithdrawal(address _token, uint256 _amount)
        external
        onlyOwner
    {
        IERC20(_token).safeTransfer(manager, _amount);
    }

    // Reward related functions
    function startDistribution() external onlyOwner {
        sharePurchaseEnabled = false;
        totalShareCountAutoCompounding = totalShareCount;
    }

    function endDistribution() external onlyOwner {
        sharePurchaseEnabled = true;
        totalShareCount = totalShareCountAutoCompounding;
    }

    function distributeRewardsDirectly(
        uint32 _start,
        uint32 _end,
        uint256 _rewardAmount
    ) external onlyOwner {
        require(!sharePurchaseEnabled, "Distribution is not allowed");
        uint256 _sharePrice = getSharePrice();
        uint256 _rewardPerShare = _rewardAmount / totalShareCount;

        for (uint32 _i = _start; _i < _end; _i++) {
            // Calculate the reward
            address _currentHolder = holders[_i];
            uint256 _shareCount = shareCount[_currentHolder];
            uint256 _rewardToBeDistributed = _rewardPerShare * _shareCount;

            // Check for auto-compounding
            if (isAutoCompounding[_currentHolder]) {
                uint256 _shareAmount = _rewardToBeDistributed / _sharePrice;
                shareCount[_currentHolder] =
                    shareCount[_currentHolder] +
                    _shareAmount;
                totalShareCountAutoCompounding += _shareAmount; // Updating a tmp variable so that the newly bought shares won't decrease the rewards of others
            } else {
                // Distribute
                IERC20(rewardToken).safeTransferFrom(
                    msg.sender,
                    _currentHolder,
                    _rewardToBeDistributed
                );
            }
        }
    }

    function increaseTotalRewardDistributed(uint256 _amount)
        external
        onlyOwner
    {
        totalRewardsDistributed += _amount;
    }

    function increaseTotalInvestment(uint256 _amount) external onlyOwner {
        totalInvestment += _amount;
    }

    // Transfer feature
    function toggleTransferEnabled(bool _isTransferEnabled) external onlyOwner {
        isTransferEnabled = _isTransferEnabled;
    }

    function transferShares(address _targetAddress, uint256 _shareAmount)
        external
    {
        require(
            msg.sender == manager || isTransferEnabled,
            "Can't transfer shares"
        );
        require(shareCount[msg.sender] >= _shareAmount, "Not Enough Shares.");

        if (!isShareHolder[_targetAddress]) {
            holders.push(_targetAddress);
            isShareHolder[_targetAddress] = true;
            holderCount += 1;
        }
        shareCount[msg.sender] = shareCount[msg.sender] - _shareAmount;
        shareCount[_targetAddress] = shareCount[_targetAddress] + _shareAmount;

        emit ShareTransfer(msg.sender, _targetAddress, _shareAmount);
    }

    function getSharePrice() public view returns (uint256) {
        return priceOracle.getPrice() + premiumOracle.getPremium();
    }

    function checkDiscount(uint256 balance, uint256 timestamp, uint8 v, bytes32 r, bytes32 s) public view returns (uint256){
        if(balance == 0) {
            return 0;
        }
        // Timestamp verification
        require(timestamp <= block.timestamp + 86400, "Transaction expired"); // Check if transaction sent in one day
        // Signature verification
        string memory message = string.concat(Strings.toHexString(uint256(uint160(msg.sender)), 20),'-');
        message = string.concat(message,Strings.toString(balance));
        message = string.concat(message,'-');
        message = string.concat(message,Strings.toString(timestamp));
        require(Verifier(verifyAddress).verifyString(message, v, r,s) == signerAddress, "Invalid signature");

        if (balance >= 9) {
            return 900;
        }
        else {
            return balance * 100;
        }
    }

    function buyShares(uint256 nftBalance, uint256 timestamp, uint8 v, bytes32 r,
              bytes32 s, uint256 _shareCount, address _referer) external {
        require(
            sharePurchaseEnabled,
            "Shares are not purchasable at the moment."
        );

        uint256 currentDiscount = checkDiscount(nftBalance, timestamp, v, r, s);
        uint256 _totalPrice = getSharePrice();
        uint256 _totalAmount = _totalPrice * _shareCount;
        uint256 _purchaseTokenPrice = priceOracle.getPrice();
        uint256 _purchaseTokenPremium = premiumOracle.getPremium();

        // Initial fee
        uint256 _initialFeeAmount = (_purchaseTokenPrice *
            _shareCount *
            initialFee) / 1000;
        uint256 _transferToProtocolAmount = _totalAmount - _initialFeeAmount;

        // Calculate address discount
        uint256 _addressDiscountAmount = (_initialFeeAmount * currentDiscount) /1000;
        uint256 _discountAmount = (_initialFeeAmount * discount) / 1000;

        // Check for referral
        if (
            _referer != address(0) && // Check if referer exsists
            _referer != msg.sender && // Check if referer is not the same as the sender
            isShareHolder[_referer] // Check if referer is an existing share holder
        ) {
            // Referer should be a shareholder
            uint256 _referFeeAmount = (_initialFeeAmount * referFee) / 1000;
            _initialFeeAmount -= _referFeeAmount;
            // Transfer the referer fee
            IERC20(purchaseToken).safeTransferFrom(
                msg.sender,
                _referer,
                _referFeeAmount
            );
            // Increase the amount for stat reasons
            totalReferralRewardDistributed += _referFeeAmount;
            referFeeEarned[_referer] =
                referFeeEarned[_referer] +
                _referFeeAmount;
            referSaleCount[_referer] = referSaleCount[_referer] + 1;
        }

        // Deduce address discount
        if((_addressDiscountAmount + _discountAmount) > _initialFeeAmount) {
            _initialFeeAmount = 0;
        } else {
             _initialFeeAmount -= (_addressDiscountAmount + _discountAmount);
        }

        // Transfer to protocol
        IERC20(purchaseToken).safeTransferFrom(
            msg.sender,
            address(this),
            _transferToProtocolAmount
        );
        // Transfer of fee
        IERC20(purchaseToken).safeTransferFrom(
            msg.sender,
            feeCollector,
            _initialFeeAmount
        );
        // Update general stats
        totalInitialFeeCollected += _initialFeeAmount;
        totalInvestment += _transferToProtocolAmount;
        totalShareCount += _shareCount;
        newInvestments +=
            _transferToProtocolAmount -
            (_purchaseTokenPremium * _shareCount);
        premiumCollected += _purchaseTokenPremium * _shareCount;

        // Add buyer to shareholders if not included
        if (!isShareHolder[msg.sender]) {
            holders.push(msg.sender);
            isShareHolder[msg.sender] = true;
            holderCount += 1;
        }

        // Update user stats
        shareCount[msg.sender] = shareCount[msg.sender] + _shareCount;

        emit Investment(
            _shareCount,
            _purchaseTokenPrice * _shareCount,
            msg.sender
        );
    }

    // Auto-compouding
    function setAutoCompounding(bool _isAutoCompounding) external {
        isAutoCompounding[msg.sender] = _isAutoCompounding;
        emit ToggleAutocompound(msg.sender, _isAutoCompounding);
    }

    function getAutocompounderCount() public view returns (uint256) {
        uint256 _count = 0;
        for (uint256 _i = 0; _i < holders.length; _i++) {
            if (isAutoCompounding[holders[_i]]) {
                _count += 1;
            }
        }
        return _count;
    }

    // Address Discount
    function setAddressDiscount(address _targetAddress, uint256 _amount)
        external
        onlyOwner
    {
        addressDiscount[_targetAddress] = _amount;
    }

    // Set Discount
    function setDiscount(uint256 _amount) external onlyOwner {
        discount = _amount;
    }

    // MIGRATION START
    function endMigartion() external onlyOwner {
        isMigrating = false;
    }

    function addHolder(address _holder, uint256 _shareCount) internal {
        holders.push(_holder);
        isShareHolder[_holder] = true;
        shareCount[_holder] = _shareCount;
        holderCount += 1;
    }

    function copyFromPrevious(
        uint16 _start,
        uint16 _end,
        uint256 _decimals
    ) external onlyOwner {
        require(isMigrating, "Migration is not in progress.");
        uint256 _additionToTotalShareCount = 0;

        for (uint16 _i = _start; _i < _end; _i++) {
            // Calculate share count
            address _currentHolder = easyContract.holders(_i);
            uint256 _shareCount = easyContract.shareCount(_currentHolder) *
                _decimals;

            addHolder(_currentHolder, _shareCount);

            _additionToTotalShareCount += _shareCount;
        }

        totalShareCount += _additionToTotalShareCount;
    }

    function addShareCount(address _target, uint256 _amount)
        external
        onlyOwner
    {
        require(isMigrating, "Migration is not in progress.");
        shareCount[_target] = shareCount[_target] + _amount;
    }

    // MIGRATION END

    // NFT RELATED START
    function decreaseShareCount(address _target, uint256 _amount)
        external
        hasAccess
    {
        require(isShareHolder[_target], "Target is not a shareholder.");
        require(shareCount[_target] >= _amount, "Not enough shares.");
        shareCount[_target] = shareCount[_target] - _amount;
        sharesInNFTs += _amount;
    }

    // NFT RELATED END

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == manager);
        _;
    }

    // Access to share count modifier
    function addAccess(address _address) external onlyOwner {
        accessWallets.push(_address);
    }

    function removeAccess(address _address) external onlyOwner {
        for (uint256 i; i < accessWallets.length; i++) {
            if (_address == accessWallets[i]) {
                delete accessWallets[i];
                break;
            }
        }
    }

    modifier hasAccess() {
        bool _hasAccess = false;
        for (uint256 i; i < accessWallets.length; i++) {
            if (msg.sender == accessWallets[i]) {
                _hasAccess = true;
                break;
            }
        }
        require(_hasAccess);
        _;
    }
}

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)
/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}