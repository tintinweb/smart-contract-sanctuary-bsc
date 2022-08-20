// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

contract BotControl {
    using Address for address;

    mapping (address => uint256) public lastTransferedAt;
    mapping (address => uint) public lastSoldAt;
    mapping (address => uint) public lastBoughtAt;
    mapping (address => bool) public isWhitelistContract;
    mapping (address => bool) public isExceptFromTxLimit;
    mapping (address => uint) public tierOf;
    mapping (uint => uint256) public tierPeriods;
    mapping (address => bool) public isAdmin;
    mapping (address => bool) public isBlacklisted;

    bool public onlyTiers; //
    bool public onlyWhitelistContract; //

    bool public hasTxLimit; //
    uint256 public txLimit; // 

    bool public hasTxCooldown; //
    uint public txCooldown; // seconds

    bool public hasMaxBuySellLimit; //
    uint256 public buyLimit; //
    uint256 public sellLimit; //

    bool public hasBuySellCooldown; //
    uint public buyCooldown; //
    uint public sellCooldown; //

    bool public hasConstantIncreaseMaxBuySell; //
    uint256 public tokenAmountIncreasePerSecond; // 

    bool public hasConstantDecreaseBuySellCooldown; //
    uint public cooldownDecreasePerSecond; // 

    uint public BPActiveDuration; // seconds

    uint256 public tierStartTime;

    address public pairAddress;

    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "BP: caller is not admin");
        _;
    }

    constructor(address pairAddress_) {
        isAdmin[msg.sender] = true;
        setPairAddress(pairAddress_);

        

        setTierPeriods(1, 0);
        setTierPeriods(2, 0);
        setTierPeriods(3, 120);
        setTierPeriods(0, 180);
        setOnlyTiers(true);
        setOnlyWhitelistContract(true);


        // option 1
        setTxLimit(100*1e18);
        setHasTxLimit(true);

        // // option 2
        // setHasMaxBuySellLimit();
        // setMaxBuySellLimit(10*1e18, 1*1e18);


        // option 1
        setHasTxCooldown(true);
        setTxCooldown(30);

        // // option 2
        // setHasBuySellCooldown();
        // setBuySellCooldown(30,60);


        // hasConstantIncreaseMaxBuySell();
        // setTokenAmountIncreasePerSecond(0);

        // hasConstantDecreaseBuySellCooldown();
        // setCooldownDecreasePerSecond(0);

        
        setBPActiveDuration(5*60);
    }

    function setPairAddress(address pairAddress_) public onlyAdmin {
        pairAddress = pairAddress_;
    }

    function setTxLimit(uint txLimit_) public onlyAdmin {
        txLimit = txLimit_;
    }

    function setTxCooldown(uint _txCooldown) public onlyAdmin {
        txCooldown = _txCooldown;
    }

    function setTierPeriods(uint8 tierNumber, uint256 time) public onlyAdmin {
        tierPeriods[tierNumber] = time;
    }

    function setHasTxCooldown(bool hasTxCooldown_) public onlyAdmin {
        hasTxCooldown = hasTxCooldown_;
    }

    function setHasTxLimit(bool hasTxLimit_) public onlyAdmin {
        hasTxLimit = hasTxLimit_;
    }

    function setOnlyWhitelistContract(bool onlyWhitelistContract_) public onlyAdmin {
        onlyWhitelistContract = onlyWhitelistContract_;
    }

    function setOnlyTiers(bool onlyTiers_) public onlyAdmin {
        onlyTiers = onlyTiers_;
    }

    function setBPActiveDuration(uint _BPActiveDuration) public onlyAdmin {
        BPActiveDuration = _BPActiveDuration;
    }

    function setIsAdmin(address[] calldata addresses, bool isAdmin_) public onlyAdmin {
        for (uint i=0; i<addresses.length; i++) {
            isAdmin[addresses[i]] = isAdmin_;
        }
    }

    function setIsExceptFromTxLimit(address[] calldata addresses, bool isExcept) public onlyAdmin {
        for (uint i=0; i<addresses.length; i++) {
            isExceptFromTxLimit[addresses[i]] = isExcept;
        }
    }

    function setTierOf(address[] calldata addresses, uint8 tierNumber) public onlyAdmin {
        for (uint i=0; i<addresses.length; i++) {
            tierOf[addresses[i]] = tierNumber;
        }
    }

    function setWhitelistContracts(address[] calldata addresses, bool isWhitelist) public onlyAdmin {
        for (uint i=0; i<addresses.length; i++) {
            require(addresses[i].isContract(), "BP: address is not contract");
            isWhitelistContract[addresses[i]] = isWhitelist;
        }
    }

    function setHasMaxBuySellLimit() public onlyAdmin {
        hasMaxBuySellLimit = !hasMaxBuySellLimit;
    }

    function setMaxBuySellLimit(uint256 _maxBuy, uint256 _maxSell) public onlyAdmin {
        require(hasMaxBuySellLimit, "BP: max buy and sell limit is not turned on.");
        buyLimit = _maxBuy;
        sellLimit = _maxSell;
    }

    function setHasBuySellCooldown() public onlyAdmin {
        hasBuySellCooldown = !hasBuySellCooldown;
    }

    function setBuySellCooldown(uint _buyCooldown, uint _sellCooldown) public onlyAdmin {
        require(hasBuySellCooldown, "BP: buy and sell cooldown is not turned on.");
        buyCooldown = _buyCooldown;
        sellCooldown = _sellCooldown;
    }


    function setHasConstantIncreaseMaxBuySell() public onlyAdmin {
        hasConstantIncreaseMaxBuySell = !hasConstantIncreaseMaxBuySell;
    }

    function setTokenAmountIncreasePerSecond(uint256 _tokenAmountIncreasePerSecond) public onlyAdmin {
        require(hasConstantIncreaseMaxBuySell, "BP: constant buy and sell limit is not turned on.");
        tokenAmountIncreasePerSecond = _tokenAmountIncreasePerSecond;
    }


    function setHasConstantDecreaseBuySellCooldown() public onlyAdmin {
        hasConstantDecreaseBuySellCooldown = !hasConstantDecreaseBuySellCooldown;
    }

    function setCooldownDecreasePerSecond(uint _cooldownDecreasePerSecond) public onlyAdmin {
        require(hasConstantDecreaseBuySellCooldown, "BP: constant buy and sell cooldown is not turned on.");
        cooldownDecreasePerSecond = _cooldownDecreasePerSecond;
    }


    function protect (
        address sender,
        address recipient,
        uint256 amount
    ) external {
        // add liquidity
        if (
            amount > 0 && 
            isAdmin[tx.origin] &&
            recipient == pairAddress &&
            tierStartTime == 0
        ) {
            tierStartTime = block.timestamp;
        }


        if (isAdmin[tx.origin]) return;

        if(block.timestamp > tierStartTime + BPActiveDuration && tierStartTime != 0) return;


        uint256 calculatedSellLimit = sellLimit;
        uint256 calculatedBuyLimit = buyLimit;
        if (hasConstantIncreaseMaxBuySell && hasMaxBuySellLimit) {
            calculatedSellLimit = sellLimit + ( (block.timestamp - tierStartTime) * tokenAmountIncreasePerSecond );
            calculatedBuyLimit = buyLimit + ( (block.timestamp - tierStartTime) * tokenAmountIncreasePerSecond );
        }


        uint calculatedBuyCooldown = buyCooldown;
        uint calculatedSellCooldown = sellCooldown;
        if (hasConstantDecreaseBuySellCooldown && hasBuySellCooldown) {
            calculatedBuyCooldown = buyCooldown - ( (block.timestamp - tierStartTime) * cooldownDecreasePerSecond );
            calculatedSellCooldown = sellCooldown - ( (block.timestamp - tierStartTime) * cooldownDecreasePerSecond );
        }


        if (onlyTiers) {
            uint256 timePassed = block.timestamp - tierStartTime;
            require(timePassed > tierPeriods[tierOf[tx.origin]], "BP: sender is not in tier");
        }

        if (hasTxLimit)
            require(amount <= txLimit, "BP: transfer amount exceeds limit");

        if (hasTxCooldown)
            require(block.timestamp - lastTransferedAt[tx.origin] >= txCooldown, "BP: transfer within cooldown");

        if (hasMaxBuySellLimit) {
            if (recipient == pairAddress) { // sell
                require(amount <= calculatedSellLimit, "BP: sell amount exceeeds limit.");
            } else if(sender == pairAddress ) { // buy
                require(amount <= calculatedBuyLimit, "BP: buy amount exceeds limit.");
            }
        }

        if (hasBuySellCooldown) {
            if (recipient == pairAddress) { // sell
                require(block.timestamp - lastSoldAt[tx.origin] >= calculatedBuyCooldown, "BP: sell within cooldown.");
                lastSoldAt[tx.origin] = block.timestamp;
            } else if(sender == pairAddress ) { // buy
                require(block.timestamp - lastBoughtAt[tx.origin] >= calculatedBuyCooldown, "BP: buy within cooldown.");
                lastBoughtAt[tx.origin] = block.timestamp;
            }
        }



        if (onlyWhitelistContract && recipient.isContract())
            require(isWhitelistContract[recipient], "BP: not a whitelist contract");

        lastTransferedAt[tx.origin] = block.timestamp;


    }

    function destroy() public onlyAdmin {
        selfdestruct(payable(msg.sender));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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