/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

// SPDX-License-Identifier: MIT
// Mens et Manus
//
// ██████╗ ██████╗  ██████╗ ███╗   ███╗ ██████╗ ██████╗ ███████╗██╗  ██╗
// ██╔══██╗██╔══██╗██╔═══██╗████╗ ████║██╔═══██╗██╔══██╗██╔════╝╚██╗██╔╝
// ██████╔╝██████╔╝██║   ██║██╔████╔██║██║   ██║██║  ██║█████╗   ╚███╔╝
// ██╔═══╝ ██╔══██╗██║   ██║██║╚██╔╝██║██║   ██║██║  ██║██╔══╝   ██╔██╗
// ██║     ██║  ██║╚██████╔╝██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗██╔╝ ██╗
// ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
//
// Sale and Lock Contract
// Programmatic Promotion Marketplace Create, target, budget your campaign,
// Get your message promoted all over the world by thousands of influencers and publishers.



pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

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

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

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

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

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

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

interface IBEP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

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

library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeBEP20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: ERC20 operation did not succeed"
            );
        }
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;

        _;
        _status = _NOT_ENTERED;
    }
}

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

contract PromodexSaleLock is Context, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    //Lock needs
    struct Items {
        address tokenAddress;
        address withdrawalAddress;
        uint256 tokenAmount;
        uint256 unlockTime;
        bool withdrawn;
    }

    uint256 public lockId;
    uint256[] public allLockIds;
    mapping(address => uint256) public totalLockedAmounts;

    mapping(address => uint256[]) public locksByWithdrawalAddress;
    mapping(uint256 => Items) public lockedToken;
    mapping(address => mapping(address => uint256)) public walletTokenBalance;
    mapping(bytes32 => mapping(address => uint256)) private saleLimits;
    mapping(address => mapping(address => bool)) public bannedAddress;
    mapping(address => bool) public tokenClaimStatusList;

    event LogWithdrawal(address SentToAddress, uint256 AmountTransferred);

    // Sale needs
    struct Pair {
        address token0;
        uint256 t0decimal;
        address token1;
        uint256 t1decimal;
        uint256 price;
        uint256 provision;
        address receiver;
        uint256 minCap;
        uint256 maxCap;
        uint256[] lockPercentList;
        uint256[] lockTimestampList;
        bool active;
    }

    mapping(address => bool) public buyLimitStatusList;
    mapping(address => bool) public tokenLockStatusList;
    mapping(address => bool) public tokenSaleWhitelistingStatusList;

    mapping(address => mapping(address => bool)) public tokenSaleWhiteList;
    mapping(address => mapping(address => uint256)) public buyLimitList;
    mapping(address => Pair) public tokenPairList;

    // Contract sale limit for whitelisting is active or passive
    function setSaleWhitelistingStatus(
        address _token,
        bool _saleWhiteListingStatus
    ) external onlyOwner {
        tokenSaleWhitelistingStatusList[_token] = _saleWhiteListingStatus;
    }

    // Contract buy limit status for token via crowedsale active or passive
    function setBuyLimitStatus(address _token, bool _buyLimitStatus)
        external
        onlyOwner
    {
        buyLimitStatusList[_token] = _buyLimitStatus;
    }

    // Contract Lock status for token via crowedsale active or passive
    function setTokensLockStatus(address _token, bool _lockActive)
        external
        onlyOwner
    {
        tokenLockStatusList[_token] = _lockActive;
    }

    // Set token claim status
    function setTokenClaimStatus(address _token, bool _status)
        external
        onlyOwner
    {
        tokenClaimStatusList[_token] = _status;
    }

    // Add one address to Whitelisting List
    function addSingleAccountToWhitelist(address _token, address _addr)
        external
        onlyOwner
    {
        tokenSaleWhiteList[_token][_addr] = true;
    }

    // Remove one address from Whitelisting List
    function removeSingleAccountFromWhitelist(address _token, address _addr)
        external
        onlyOwner
    {
        tokenSaleWhiteList[_token][_addr] = false;
    }

    // Add address to Whitelisting List
    function addMultipleAccountToWhitelist(
        address _token,
        address[] memory _addrs
    ) external onlyOwner {
        uint256 addrsLength = _addrs.length;
        require(
            addrsLength <= 500,
            "PROMO : max 500 account can added at once"
        );
        for (uint256 i = 0; i < addrsLength; i++) {
            tokenSaleWhiteList[_token][_addrs[i]] = true;
        }
    }

    // Remove address from Whitelisting List
    function removeMultipleAccountFromWhitelist(
        address _token,
        address[] memory _addrs
    ) external onlyOwner {
        uint256 addrsLength = _addrs.length;
        require(
            addrsLength <= 500,
            "PROMO : max 500 account can remove at once"
        );
        for (uint256 i = 0; i < addrsLength; i++) {
            tokenSaleWhiteList[_token][_addrs[i]] = false;
        }
    }

    // Add single address buy limit to list
    function addSingleAccountToBuyLimitList(
        address _token,
        address _addr,
        uint256 _amount
    ) external onlyOwner {
        buyLimitList[_token][_addr] = _amount;
    }

    // Remove single address buy limit on list
    function removeSingleAccountFromBuyLimitList(address _token, address _addr)
        external
        onlyOwner
    {
        buyLimitList[_token][_addr] = 0;
    }

    // Set multiple address buy limit
    function addMultipleAccountToBuyLimitList(
        address _token,
        address[] memory _addrs,
        uint256[] memory _amounts
    ) external onlyOwner {
        uint256 addrsLength = _addrs.length;
        uint256 amountsLength = _amounts.length;
        require(
            amountsLength == addrsLength,
            "PROMODEX : address for buy limit amounts length error"
        );
        require(addrsLength <= 500, "PROMO : max 500 account can add at once");
        for (uint256 i = 0; i < addrsLength; i++) {
            buyLimitList[_token][_addrs[i]] = _amounts[i];
        }
    }

    // Remove multiple address buy limit on list
    function removeMultipleAccountFromBuyLimitList(
        address _token,
        address[] memory _addrs
    ) external onlyOwner {
        uint256 addrsLength = _addrs.length;
        require(
            addrsLength <= 500,
            "PROMO : max 500 account can remove at once"
        );
        for (uint256 i = 0; i < addrsLength; i++) {
            buyLimitList[_token][_addrs[i]] = 0;
        }
    }

    // Get address buy limit amount
    function getAddressBuyLimit(address _token, address _addr)
        external
        view
        returns (uint256)
    {
        return (buyLimitList[_token][_addr]);
    }

    // Get available buy limit on active pair for an address
    function getAddressBuyLimitLeft(address _token, address _addr)
        external
        view
        returns (uint256)
    {
        Pair memory _pair = _getTokenPair(_token);
        // Check buy limit
        if (buyLimitStatusList[_pair.token1]) {
            return
                buyLimitList[_pair.token1][_addr].sub(
                    saleLimits[_getSalePairKey(_pair)][_addr]
                );
        } else {
            return _pair.maxCap.sub(saleLimits[_getSalePairKey(_pair)][_addr]);
        }
    }

    // Get address whitelisting status for a token
    function getAddressWhiteListStatus(address _token, address _addr)
        external
        view
        returns (bool)
    {
        return (tokenSaleWhiteList[_token][_addr]);
    }

    // Get address ban status
    function getAddressBanStatus(address _token, address _addr)
        external
        view
        returns (bool)
    {
        return (bannedAddress[_token][_addr]);
    }

    // Add single address buy limit to list
    function addSingleAccountToBannedList(address _token, address _addr)
        external
        onlyOwner
    {
        bannedAddress[_token][_addr] = true;
    }

    // Remove single address banned
    function removeSingleAccountFromBannedList(address _token, address _addr)
        external
        onlyOwner
    {
        bannedAddress[_token][_addr] = false;
    }

    function _checkLockArrays(
        uint256[] memory _lockPercents,
        uint256[] memory _lockTimestamps
    ) internal view returns (uint256[] memory, uint256[] memory) {
        uint256 lockPercentsLength = _lockPercents.length;
        uint256 lockTimestampsLength = _lockTimestamps.length;

        uint256[] memory _lockPercentList = new uint256[](lockPercentsLength);
        uint256[] memory _lockTimestampList = new uint256[](
            lockTimestampsLength
        );

        // Set LockPercentList for pair
        require(
            lockPercentsLength == lockTimestampsLength,
            "PROMODEX : percent list length check error"
        );
        uint256 totalPercent = 0;
        for (uint256 i = 0; i < lockPercentsLength; i++) {
            require(
                _lockPercents[i] > 0,
                "PROMODEX : percentage can not be zero"
            );
            totalPercent = totalPercent.add(_lockPercents[i]);
        }
        require(
            totalPercent == 100,
            "PROMODEX : Total percentage must be equal 100"
        );

        for (uint256 i = 0; i < lockPercentsLength; i++) {
            _lockPercentList[i] = _lockPercents[i];
        }

        // Set LockTimeStamp List for pair
        for (uint256 i = 0; i < lockTimestampsLength; i++) {
            require(
                _lockTimestamps[i] > block.timestamp,
                "PROMODEX : unlock timestamp should be higher than current time"
            );
        }

        for (uint256 i = 0; i < lockTimestampsLength; i++) {
            _lockTimestampList[i] = _lockTimestamps[i];
        }

        return (_lockPercentList, _lockTimestampList);
    }

    // Setting Pairs for sale and Lock
    function setTokenSalePair(
        address _token0,
        uint8 _token0decimal,
        address _token1,
        uint8 _token1decimal,
        uint256 _price,
        uint256 _provision,
        address _receiver,
        uint256 _minCap,
        uint256 _maxCap,
        uint256[] memory _lockPercents,
        uint256[] memory _lockTimestamps
    ) external onlyOwner {
        // Pair check
        require(tokenPairList[_token1].active == false, "Pair already defined");

        (
            uint256[] memory lockPercentList,
            uint256[] memory lockTimestampList
        ) = _checkLockArrays(_lockPercents, _lockTimestamps);

        tokenPairList[_token1].token0 = _token0;
        tokenPairList[_token1].t0decimal = _token0decimal;
        tokenPairList[_token1].token1 = _token1;
        tokenPairList[_token1].t1decimal = _token1decimal;
        tokenPairList[_token1].price = _price;
        tokenPairList[_token1].provision = _provision;
        tokenPairList[_token1].receiver = _receiver;
        tokenPairList[_token1].minCap = _minCap;
        tokenPairList[_token1].maxCap = _maxCap;
        tokenPairList[_token1].lockPercentList = lockPercentList;
        tokenPairList[_token1].lockTimestampList = lockTimestampList;
        tokenPairList[_token1].active = true;

        // Set default claim status to false
        tokenClaimStatusList[_token1] = false;
        // Set default buy limit status to false
        buyLimitStatusList[_token1] = false;
        // Set default whitelisting status to false
        tokenSaleWhitelistingStatusList[_token1] = false;
        // Set default lock status to true
        tokenLockStatusList[_token1] = true;
    }

    function deleteTokenPair(address _token) external onlyOwner {
        delete tokenPairList[_token];
    }

    function getTokenPairDetails(address _token)
        external
        view
        returns (Pair memory)
    {
        return _getTokenPair(_token);
    }

    function _getTokenPair(address _token) internal view returns (Pair memory) {
        return tokenPairList[_token];
    }

    // Get sale pair key
    function _getSalePairKey(Pair memory _pair)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_pair.token0, _pair.token1));
    }

    // Get available sale limit for signer address
    function _getSignerBuyedAmount(Pair memory _pair)
        internal
        view
        returns (uint256)
    {
        return saleLimits[_getSalePairKey(_pair)][_msgSender()];
    }

    // Here Update sale limit function for call inside
    function _increaseSignerSaleLimit(uint256 _limit, Pair memory _pair)
        internal
    {
        saleLimits[_getSalePairKey(_pair)][_msgSender()] = saleLimits[
            _getSalePairKey(_pair)
        ][_msgSender()].add(_limit);
    }

    // Here Get Liquidity function for call inside
    function _getLiquidity(address _token) internal view returns (uint256) {
        return IBEP20(_token).balanceOf(address(this));
    }

    // Internal total locked token show
    function _calculateTotalTokenLocked(address _token)
        internal
        view
        returns (uint256)
    {
        return totalLockedAmounts[_token];
    }

    // Extarnal total locked token show
    function totalTokenLocked(address _token) external view returns (uint256) {
        return totalLockedAmounts[_token];
    }

    // Multiple lock internal function
    function _createMultipleLocks(
        address _tokenAddress,
        address _withdrawalAddress,
        uint256[] memory _amounts,
        uint256[] memory _unlockTimes
    ) internal returns (uint256 _id) {
        uint256 unlockTimesLength = _unlockTimes.length;
        uint256 amountsLength = _amounts.length;
        require(
            amountsLength > 0,
            "PROMODEX : amounts array length cannot be zero"
        );
        require(
            amountsLength == unlockTimesLength,
            "PROMODEX : amounts array length and unlock timestamp array length must same"
        );

        uint256 i;
        for (i = 0; i < amountsLength; i++) {
            require(_amounts[i] > 0, "PROMODEX : amount cannot be zero");
            require(
                _unlockTimes[i] < 10000000000,
                "PROMODEX : timestamp must be smaller then 10000000000"
            );

            //update balance in address
            walletTokenBalance[_tokenAddress][
                _withdrawalAddress
            ] = walletTokenBalance[_tokenAddress][_withdrawalAddress].add(
                _amounts[i]
            );

            totalLockedAmounts[_tokenAddress] = totalLockedAmounts[
                _tokenAddress
            ].add(_amounts[i]);

            _id = ++lockId;
            lockedToken[_id].tokenAddress = _tokenAddress;
            lockedToken[_id].withdrawalAddress = _withdrawalAddress;
            lockedToken[_id].tokenAmount = _amounts[i];
            lockedToken[_id].unlockTime = _unlockTimes[i];
            lockedToken[_id].withdrawn = false;

            allLockIds.push(_id);
            locksByWithdrawalAddress[_withdrawalAddress].push(_id);
        }
    }

    // Calculate time for tokens
    function _calculateSendAmount(uint256 _amount, Pair memory _pair)
        internal
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256[] memory
        )
    {
        require(
            _amount > _pair.price,
            "PROMODEX : given amount should be higher than unit price"
        );
        uint256 pairLockPercentListLength = _pair.lockPercentList.length;

        uint256[] memory lockAmounts = new uint256[](pairLockPercentListLength);
        uint256 dustAmount = _amount % _pair.price; // Dust amount for refund
        uint256 allowAmount = _amount.sub(dustAmount); // Accept amount for sell
        uint256 ratio = allowAmount.div(_pair.price); // Sell ratio
        uint256 allTransferSize = _pair.provision.mul(ratio); // Transfer before lock applied

        uint256 signersAlreadyBuyedAmount = _getSignerBuyedAmount(_pair); // Get transfer limit for signer

        // Limit Check
        if (!buyLimitStatusList[_pair.token1]) {
            require(
                _amount >= _pair.minCap,
                "PROMODEX : acceptable amount is lower than min cap"
            );

            require(
                _amount <= _pair.maxCap,
                "PROMODEX : acceptable amount is higher than max cap"
            );
        }

        uint256 totalBuyedAmountAfterSale = signersAlreadyBuyedAmount.add(
            allowAmount
        );

        // Check for limits
        if (buyLimitStatusList[_pair.token1]) {
            require(
                totalBuyedAmountAfterSale <=
                    buyLimitList[_pair.token1][_msgSender()],
                "PROMODEX : signer buy limit is not enough"
            );
        } else {
            require(
                totalBuyedAmountAfterSale <= _pair.maxCap,
                "PROMODEX : total buyed amount will higher than max cap after transfer"
            );
        }

        // Calculate tokens buy lockpercent
        for (uint256 i = 0; i < pairLockPercentListLength; i++) {
            uint256 lockPercent = _pair.lockPercentList[i];
            uint256 lockAmount = allTransferSize.div(100).mul(lockPercent);
            lockAmounts[i] = lockAmount;
        }

        require(
            lockAmounts.length > 0,
            "PROMODEX : lock amounts calculation failed"
        );

        return (allowAmount, allTransferSize, dustAmount, lockAmounts);
    }

    // Check for buy
    function _beforeBuy(uint256 _amount, Pair memory _pair)
        internal
        view
        returns (bool)
    {
        require(_pair.active == true, "PROMODEX : pair is not active");
        require(
            _pair.receiver != address(0),
            "PROMODEX : receiver is zero address"
        );
        require(
            _pair.token1 != address(0),
            "PROMODEX : sale contract is not defined"
        );

        // Check whitelisting status
        if (tokenSaleWhitelistingStatusList[_pair.token1]) {
            require(
                tokenSaleWhiteList[_pair.token1][_msgSender()],
                "PROMODEX : signer is not in whitelist"
            );
        }

        // Check buy limit
        if (buyLimitStatusList[_pair.token1]) {
            require(
                buyLimitList[_pair.token1][_msgSender()] >= _amount,
                "PROMODEX : signer buy limit is not enough"
            );
        }

        // Check signer allowance for sale
        uint256 signerAllowance = IBEP20(_pair.token0).allowance(
            _msgSender(),
            address(this)
        );

        require(
            signerAllowance >= _amount,
            "PROMODEX : signer allowance required for pair.token0"
        );

        return true;
    }

    // Buy some tokens and lock them all
    function buy(uint256 _amount, address _token) external {
        Pair memory _pair = _getTokenPair(_token);
        require(
            _beforeBuy(_amount, _pair) == true,
            "PROMODEX : buy is not allowed currently"
        );

        // Calculate allowed amount, transfer size & dust amount for refund
        (
            uint256 _allowAmount,
            uint256 _allTransferSize,
            uint256 _dustAmount,
            uint256[] memory _lockAmounts
        ) = _calculateSendAmount(_amount, _pair);

        // Check liquidity
        require(
            _allTransferSize <= _getLiquidity(_token),
            "PROMODEX : insufficient liquidity for token1"
        );

        // Send token0 to current contract
        SafeBEP20.safeTransferFrom(
            IBEP20(_pair.token0),
            _msgSender(),
            address(this),
            _amount
        );

        // Send allowAmount token0 to receiver
        SafeBEP20.safeTransfer(
            IBEP20(_pair.token0),
            _pair.receiver,
            _allowAmount
        );

        // Send dustAmount to signer if exist
        if (_dustAmount > 0) {
            SafeBEP20.safeTransfer(
                IBEP20(_pair.token0),
                _msgSender(),
                _dustAmount
            );
        }

        if (tokenLockStatusList[_pair.token1]) {
            _increaseSignerSaleLimit(_allowAmount, _pair);

            // Create locks in contract for future
            uint256 lockSuccess = _createMultipleLocks(
                _pair.token1,
                _msgSender(),
                _lockAmounts,
                _pair.lockTimestampList
            );

            require(lockSuccess > 0, "PROMODEX : lock call is failed");
        } else {
            _increaseSignerSaleLimit(_allowAmount, _pair);

            // Send token1 to caller
            SafeBEP20.safeTransfer(
                IBEP20(_pair.token1),
                _msgSender(),
                _allTransferSize
            );
        }
    }

    // Add some token to contract for sale and lock
    function addPairLiquidity(address _token, uint256 _amount)
        external
        onlyOwner
    {
        Pair memory _pair = _getTokenPair(_token);
        uint256 allowance = IBEP20(_pair.token1).allowance(
            _msgSender(),
            address(this)
        );
        require(allowance >= _amount, "PROMODEX : allowance is not enough");
        SafeBEP20.safeTransferFrom(
            IBEP20(_pair.token1),
            _msgSender(),
            address(this),
            _amount
        );
    }

    // Owner Calls Remove Liquidity from contract
    function removePairLiquidity(
        address _to,
        uint256 _amount,
        address _token
    ) external onlyOwner {
        Pair memory _pair = _getTokenPair(_token);
        require(_to != address(0), "PROMODEX : to address is zero address");
        require(
            _getLiquidity(_token) >= _amount,
            "PROMODEX : insufficient liquidity"
        );

        require(
            _calculateTotalTokenLocked(_pair.token1) <=
                _getLiquidity(_token).sub(_amount),
            "PROMODEX : there are locked tokens you can not remove locked tokens"
        );
        SafeBEP20.safeTransfer(IBEP20(_pair.token1), _to, _amount);
    }

    // Add liquidity with contract address
    function addLiquidityWithContract(address _contract, uint256 _amount)
        external
        onlyOwner
    {
        uint256 allowance = IBEP20(_contract).allowance(
            _msgSender(),
            address(this)
        );
        require(allowance >= _amount, "PROMODEX : allowance is not enough");
        SafeBEP20.safeTransferFrom(
            IBEP20(_contract),
            _msgSender(),
            address(this),
            _amount
        );
    }

    // Remove liquidity with contract address
    function removeLiquidityWithContract(
        address _contract,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        require(_to != address(0), "PROMODEX : to address is zero address");
        require(
            IBEP20(_contract).balanceOf(address(this)) >= _amount,
            "PROMODEX : insufficient liquidity"
        );
        require(
            _calculateTotalTokenLocked(_contract) <=
                IBEP20(_contract).balanceOf(address(this)).sub(_amount),
            "PROMODEX : there are locked tokens, you can not remove locked tokens"
        );

        SafeBEP20.safeTransfer(IBEP20(_contract), _to, _amount);
    }

    // Transfer owner status for locked tokens
    function transferLocks(uint256 _id, address _receiverAddress) external {
        require(
            !lockedToken[_id].withdrawn,
            "PROMODEX : amount already withdrawn"
        );
        require(
            _msgSender() == lockedToken[_id].withdrawalAddress,
            "PROMODEX : this is not your token dude"
        );

        // Senders token balance now decrease
        walletTokenBalance[lockedToken[_id].tokenAddress][
            _msgSender()
        ] = walletTokenBalance[lockedToken[_id].tokenAddress][_msgSender()].sub(
            lockedToken[_id].tokenAmount
        );

        // Receivers token balance now increase
        walletTokenBalance[lockedToken[_id].tokenAddress][
            _receiverAddress
        ] = walletTokenBalance[lockedToken[_id].tokenAddress][_receiverAddress]
            .add(lockedToken[_id].tokenAmount);

        // Remove id from sender address
        uint256 j;
        uint256 arrLength = locksByWithdrawalAddress[
            lockedToken[_id].withdrawalAddress
        ].length;
        for (j = 0; j < arrLength; j++) {
            if (
                locksByWithdrawalAddress[lockedToken[_id].withdrawalAddress][
                    j
                ] == _id
            ) {
                locksByWithdrawalAddress[lockedToken[_id].withdrawalAddress][
                    j
                ] = locksByWithdrawalAddress[
                    lockedToken[_id].withdrawalAddress
                ][arrLength - 1];

                break;
            }
        }

        // Assign id to receiver address
        lockedToken[_id].withdrawalAddress = _receiverAddress;
        locksByWithdrawalAddress[_receiverAddress].push(_id);
    }

    // Ready for withdraw tokens from contract
    function withdrawTokens(uint256 _id) external {
        require(
            !bannedAddress[lockedToken[_id].tokenAddress][_msgSender()],
            "PROMODEX: sender address banned to claim for this token"
        );
        require(
            tokenClaimStatusList[lockedToken[_id].tokenAddress] == true,
            "PROMODEX : token claim status is not ready"
        );
        require(
            block.timestamp >= lockedToken[_id].unlockTime,
            "PROMODEX : unlocktime should smaller then block timestamp"
        );
        require(
            _msgSender() == lockedToken[_id].withdrawalAddress,
            "PROMODEX : this is not your token dude"
        );
        require(
            !lockedToken[_id].withdrawn,
            "PROMODEX : amount already withdrawn"
        );

        lockedToken[_id].withdrawn = true;

        // Update balance in address
        walletTokenBalance[lockedToken[_id].tokenAddress][
            _msgSender()
        ] = walletTokenBalance[lockedToken[_id].tokenAddress][_msgSender()].sub(
            lockedToken[_id].tokenAmount
        );

        // Amount remove from totalLockList
        totalLockedAmounts[lockedToken[_id].tokenAddress] = totalLockedAmounts[
            lockedToken[_id].tokenAddress
        ].sub(lockedToken[_id].tokenAmount);

        // Remove id from this address
        uint256 j;
        uint256 arrLength = locksByWithdrawalAddress[
            lockedToken[_id].withdrawalAddress
        ].length;
        for (j = 0; j < arrLength; j++) {
            if (
                locksByWithdrawalAddress[lockedToken[_id].withdrawalAddress][
                    j
                ] == _id
            ) {
                locksByWithdrawalAddress[lockedToken[_id].withdrawalAddress][
                    j
                ] = locksByWithdrawalAddress[
                    lockedToken[_id].withdrawalAddress
                ][arrLength - 1];

                break;
            }
        }

        // Everything is ok now, transfer tokens to wallet address
        require(
            IBEP20(lockedToken[_id].tokenAddress).transfer(
                _msgSender(),
                lockedToken[_id].tokenAmount
            ),
            "PROMODEX : error while transfer tokens"
        );

        emit LogWithdrawal(_msgSender(), lockedToken[_id].tokenAmount);
    }

    // Get total token balance in contract of given token address
    function getContractTotalTokenBalance(address _tokenAddress)
        external
        view
        returns (uint256)
    {
        return IBEP20(_tokenAddress).balanceOf(address(this));
    }

    // Get total token balance of wallets given token address
    function getTokenBalanceByAddress(
        address _tokenAddress,
        address _walletAddress
    ) external view returns (uint256) {
        return walletTokenBalance[_tokenAddress][_walletAddress];
    }

    // Get All Lock Ids
    function getAllLockIds() external view returns (uint256[] memory) {
        return allLockIds;
    }

    // Get Lock Details
    function getLockDetails(uint256 _id)
        external
        view
        returns (
            address _tokenAddress,
            address _withdrawalAddress,
            uint256 _tokenAmount,
            uint256 _unlockTime,
            bool _withdrawn
        )
    {
        return (
            lockedToken[_id].tokenAddress,
            lockedToken[_id].withdrawalAddress,
            lockedToken[_id].tokenAmount,
            lockedToken[_id].unlockTime,
            lockedToken[_id].withdrawn
        );
    }

    // Get locks By Withdrawal Address
    function getLocksByWithdrawalAddress(address _withdrawalAddress)
        external
        view
        returns (uint256[] memory)
    {
        return locksByWithdrawalAddress[_withdrawalAddress];
    }

    // Creating Multiple Locks for token in contract
    function createMultipleLocks(
        address _tokenAddress,
        address _withdrawalAddress,
        uint256[] memory _amounts,
        uint256[] memory _unlockTimes
    ) external returns (uint256 _id) {
        return
            _createMultipleLocks(
                _tokenAddress,
                _withdrawalAddress,
                _amounts,
                _unlockTimes
            );
    }
}

// Made with love.