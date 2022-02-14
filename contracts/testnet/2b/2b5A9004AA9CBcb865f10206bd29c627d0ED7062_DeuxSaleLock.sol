// SPDX-License-Identifier: MIT
// DEUX Special Sale and Lock Contract

pragma solidity ^0.8.0;

import "./Context.sol";
import "./IERC20.sol";
import "./SafeERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";

contract DeuxSaleLock is Context, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

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

    mapping(address => uint256[]) public depositsByWithdrawalAddress;
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
        for (uint256 i = 0; i < _addrs.length; i++) {
            tokenSaleWhiteList[_token][_addrs[i]] = true;
        }
    }

    // Remove address from Whitelisting List
    function removeMultipleAccountFromWhitelist(
        address _token,
        address[] memory _addrs
    ) external onlyOwner {
        for (uint256 i = 0; i < _addrs.length; i++) {
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
        require(
            _addrs.length == _amounts.length,
            "DEUX : address for buy limit amounts length error"
        );
        for (uint256 i = 0; i < _addrs.length; i++) {
            buyLimitList[_token][_addrs[i]] = _amounts[i];
        }
    }

    // Remove multiple address buy limit on list
    function removeMultipleAccountFromBuyLimitList(
        address _token,
        address[] memory _addrs
    ) external onlyOwner {
        for (uint256 i = 0; i < _addrs.length; i++) {
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
    function getAddressBuyLimitLeft(address _addr, address _token)
        external
        view
        returns (uint256)
    {
        Pair memory _pair = _getTokenPair(_token);
        // Check buy limit
        if (buyLimitStatusList[_pair.token1]) {
            return
                buyLimitList[_pair.token1][_addr] -
                saleLimits[_getSalePairKey(_pair)][_addr];
        } else {
            return _pair.maxCap - saleLimits[_getSalePairKey(_pair)][_addr];
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

    // Set token claim status
    function setTokenClaimStatus(address _token, bool _status)
        external
        onlyOwner
    {
        tokenClaimStatusList[_token] = _status;
    }

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
        uint256[] memory _lockPercentList = new uint256[](_lockPercents.length);
        uint256[] memory _lockTimestampList = new uint256[](
            _lockTimestamps.length
        );

        // Pair check
        require(tokenPairList[_token1].active == false, "Pair already defined");

        // Set LockPercentList for pair
        require(
            _lockPercents.length == _lockTimestamps.length,
            "Deux : percent list length check error"
        );
        uint256 totalPercent = 0;
        for (uint256 i = 0; i < _lockPercents.length; i++) {
            require(_lockPercents[i] > 0, "DEUX : percentage can not be zero");
            totalPercent += _lockPercents[i];
        }
        require(
            totalPercent == 100,
            "DEUX : Total percentage must be equal 100"
        );

        for (uint256 i = 0; i < _lockPercents.length; i++) {
            _lockPercentList[i] = _lockPercents[i];
        }

        // Set LockTimeStamp List for pair
        for (uint256 i = 0; i < _lockTimestamps.length; i++) {
            require(
                _lockTimestamps[i] > block.timestamp,
                "DEUX : unlock timestamp should be higher than current time"
            );
        }

        for (uint256 i = 0; i < _lockTimestamps.length; i++) {
            _lockTimestampList[i] = _lockTimestamps[i];
        }

        tokenPairList[_token1].token0 = _token0;
        tokenPairList[_token1].t0decimal = _token0decimal;
        tokenPairList[_token1].token1 = _token1;
        tokenPairList[_token1].t1decimal = _token1decimal;
        tokenPairList[_token1].price = _price;
        tokenPairList[_token1].provision = _provision;
        tokenPairList[_token1].receiver = _receiver;
        tokenPairList[_token1].minCap = _minCap;
        tokenPairList[_token1].maxCap = _maxCap;
        tokenPairList[_token1].lockPercentList = _lockPercentList;
        tokenPairList[_token1].lockTimestampList = _lockTimestampList;
        tokenPairList[_token1].active = true;

        // Set default claim status to false
        tokenClaimStatusList[_token1] = false;
        // Set default buy limit status to true
        buyLimitStatusList[_token1] = true;
        // Set default whitelisting status to true
        tokenSaleWhitelistingStatusList[_token1] = true;
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
        return IERC20(_token).balanceOf(address(this));
    }

    // Internal total locked token show
    function _calculateTotalTokenLocked(address _token)
        internal
        view
        returns (uint256)
    {
        return totalLockedAmounts[_token];
    }

    // Multiple lock internal function
    function _createMultipleLocks(
        address _tokenAddress,
        address _withdrawalAddress,
        uint256[] memory _amounts,
        uint256[] memory _unlockTimes
    ) internal returns (uint256 _id) {
        require(
            _amounts.length > 0,
            "DEUX : amounts array length cannot be zero"
        );
        require(
            _amounts.length == _unlockTimes.length,
            "DEUX : amounts array length and unlock timestamp array length must same"
        );

        uint256 i;
        for (i = 0; i < _amounts.length; i++) {
            require(_amounts[i] > 0, "DEUX : amount cannot be zero");
            require(
                _unlockTimes[i] < 10000000000,
                "DEUX : timestamp must be smaller then 10000000000"
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
            depositsByWithdrawalAddress[_withdrawalAddress].push(_id);
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
            "DEUX : given amount should be higher than unit price"
        );

        uint256[] memory lockAmounts = new uint256[](
            _pair.lockPercentList.length
        );
        uint256 dustAmount = _amount % _pair.price; // Dust amount for refund
        uint256 allowAmount = _amount.sub(dustAmount); // Accept amount for sell
        uint256 ratio = allowAmount.div(_pair.price); // Sell ratio
        uint256 allTransferSize = _pair.provision.mul(ratio); // Transfer before lock applied

        uint256 signersAlreadyBuyedAmount = _getSignerBuyedAmount(_pair); // Get transfer limit for signer

        // Limit Check
        if (!buyLimitStatusList[_pair.token1]) {
            require(
                allowAmount >= _pair.minCap,
                "DEUX : acceptable amount is lower than min cap"
            );

            require(
                allowAmount <= _pair.maxCap,
                "DEUX : acceptable amount is higher than max cap"
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
                "DEUX : signer buy limit is not enough"
            );
        } else {
            require(
                totalBuyedAmountAfterSale <= _pair.maxCap,
                "DEUX : total buyed amount will higher than max cap after transfer"
            );
        }

        // Calculate tokens buy lockpercent
        for (uint256 i = 0; i < _pair.lockPercentList.length; i++) {
            uint256 lockPercent = _pair.lockPercentList[i];
            uint256 lockAmount = allTransferSize.div(100).mul(lockPercent);
            lockAmounts[i] = lockAmount;
        }

        require(
            lockAmounts.length > 0,
            "DEUX : lock amounts calculation failed"
        );

        return (allowAmount, allTransferSize, dustAmount, lockAmounts);
    }

    // Check for buy
    function _beforeBuy(uint256 _amount, Pair memory _pair)
        internal
        view
        returns (bool)
    {
        require(_pair.active == true, "DEUX : pair is not active");
        require(
            _pair.receiver != address(0),
            "DEUX : receiver is zero address"
        );
        require(
            _pair.token1 != address(0),
            "DEUX : sale contract is not defined"
        );

        // Check whitelisting status
        if (tokenSaleWhitelistingStatusList[_pair.token1]) {
            require(
                tokenSaleWhiteList[_pair.token1][_msgSender()],
                "DEUX : signer is not in whitelist"
            );
        }

        // Check buy limit
        if (buyLimitStatusList[_pair.token1]) {
            require(
                buyLimitList[_pair.token1][_msgSender()] >= _amount,
                "DEUX : signer buy limit is not enough"
            );
        }

        // Check signer allowance for sale
        uint256 signerAllowance = IERC20(_pair.token0).allowance(
            _msgSender(),
            address(this)
        );

        require(
            signerAllowance >= _amount,
            "DEUX : signer allowance required for pair.token0"
        );

        return true;
    }

    // Buy some tokens and lock them all
    function buy(uint256 _amount, address _token) external {
        Pair memory _pair = _getTokenPair(_token);
        require(
            _beforeBuy(_amount, _pair) == true,
            "DEUX : buy is not allowed currently"
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
            "DEUX : insufficient liquidity for token1"
        );

        // Send token0 to current contract
        SafeERC20.safeTransferFrom(
            IERC20(_pair.token0),
            _msgSender(),
            address(this),
            _amount
        );

        // Send allowAmount token0 to receiver
        SafeERC20.safeTransfer(
            IERC20(_pair.token0),
            _pair.receiver,
            _allowAmount
        );

        // Send dustAmount to signer if exist
        if (_dustAmount > 0) {
            SafeERC20.safeTransfer(
                IERC20(_pair.token0),
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

            require(lockSuccess > 0, "DEUX : lock call is failed");
        } else {
            _increaseSignerSaleLimit(_allowAmount, _pair);

            // Send token1 to caller
            SafeERC20.safeTransfer(
                IERC20(_pair.token1),
                _msgSender(),
                _allTransferSize
            );
        }
    }

    // Add some token to contract for sale and lock
    function addLiquidity(uint256 _amount, address _token) external onlyOwner {
        Pair memory _pair = _getTokenPair(_token);
        uint256 allowance = IERC20(_pair.token1).allowance(
            _msgSender(),
            address(this)
        );
        require(allowance >= _amount, "DEUX : allowance is not enough");
        SafeERC20.safeTransferFrom(
            IERC20(_pair.token1),
            _msgSender(),
            address(this),
            _amount
        );
    }

    // Owner Calls Remove Liquidity from contract
    function removeLiquidity(
        address _to,
        uint256 _amount,
        address _token
    ) external onlyOwner {
        Pair memory _pair = _getTokenPair(_token);
        require(_to != address(0), "DEUX : to address is zero address");
        require(
            _getLiquidity(_token) >= _amount,
            "DEUX : insufficient liquidity"
        );

        require(
            _calculateTotalTokenLocked(_pair.token1) <=
                _getLiquidity(_token) - _amount,
            "DEUX : there are locked tokens you can not remove locked tokens"
        );
        SafeERC20.safeTransfer(IERC20(_pair.token1), _to, _amount);
    }

    // Add liquidity with contract address
    function addLiquidityWithContract(address _contract, uint256 _amount)
        external
        onlyOwner
    {
        uint256 allowance = IERC20(_contract).allowance(
            _msgSender(),
            address(this)
        );
        require(allowance >= _amount, "DEUX : allowance is not enough");
        SafeERC20.safeTransferFrom(
            IERC20(_contract),
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
        require(_to != address(0), "DEUX : to address is zero address");
        require(
            IERC20(_contract).balanceOf(address(this)) >= _amount,
            "DEUX : insufficient liquidity"
        );

        require(
            _calculateTotalTokenLocked(_contract) <=
                IERC20(_contract).balanceOf(address(this)) - _amount,
            "DEUX : there are locked tokens, you can not remove locked tokens"
        );

        SafeERC20.safeTransfer(IERC20(_contract), _to, _amount);
    }

    // Transfer owner status for locked tokens
    function transferLocks(uint256 _id, address _receiverAddress) external {
        require(!lockedToken[_id].withdrawn, "DEUX : amount already withdrawn");
        require(
            _msgSender() == lockedToken[_id].withdrawalAddress,
            "DEUX : this is not your token dude"
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
        uint256 arrLength = depositsByWithdrawalAddress[
            lockedToken[_id].withdrawalAddress
        ].length;
        for (j = 0; j < arrLength; j++) {
            if (
                depositsByWithdrawalAddress[lockedToken[_id].withdrawalAddress][
                    j
                ] == _id
            ) {
                depositsByWithdrawalAddress[lockedToken[_id].withdrawalAddress][
                    j
                ] = depositsByWithdrawalAddress[
                    lockedToken[_id].withdrawalAddress
                ][arrLength - 1];

                break;
            }
        }

        // Assign id to receiver address
        lockedToken[_id].withdrawalAddress = _receiverAddress;
        depositsByWithdrawalAddress[_receiverAddress].push(_id);
    }

    // Ready for withdraw tokens from contract
    function withdrawTokens(uint256 _id) external {
        require(
            !bannedAddress[lockedToken[_id].tokenAddress][_msgSender()],
            "DEUX: sender address banned to claim for this token"
        );
        require(
            tokenClaimStatusList[lockedToken[_id].tokenAddress] == true,
            "DEUX : token claim status is not ready"
        );
        require(
            block.timestamp >= lockedToken[_id].unlockTime,
            "DEUX : unlocktime should smaller then block timestamp"
        );
        require(
            _msgSender() == lockedToken[_id].withdrawalAddress,
            "DEUX : this is not your token dude"
        );
        require(!lockedToken[_id].withdrawn, "DEUX : amount already withdrawn");

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
        uint256 arrLength = depositsByWithdrawalAddress[
            lockedToken[_id].withdrawalAddress
        ].length;
        for (j = 0; j < arrLength; j++) {
            if (
                depositsByWithdrawalAddress[lockedToken[_id].withdrawalAddress][
                    j
                ] == _id
            ) {
                depositsByWithdrawalAddress[lockedToken[_id].withdrawalAddress][
                    j
                ] = depositsByWithdrawalAddress[
                    lockedToken[_id].withdrawalAddress
                ][arrLength - 1];

                break;
            }
        }

        // Everything is ok now, transfer tokens to wallet address
        require(
            IERC20(lockedToken[_id].tokenAddress).transfer(
                _msgSender(),
                lockedToken[_id].tokenAmount
            ),
            "DEUX : error while transfer tokens"
        );

        emit LogWithdrawal(_msgSender(), lockedToken[_id].tokenAmount);
    }

    // Get total token balance in contract of given token address
    function getContractTotalTokenBalance(address _tokenAddress)
        external
        view
        returns (uint256)
    {
        return IERC20(_tokenAddress).balanceOf(address(this));
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

    // Get Deposits By Withdrawal Address
    function getDepositsByWithdrawalAddress(address _withdrawalAddress)
        external
        view
        returns (uint256[] memory)
    {
        return depositsByWithdrawalAddress[_withdrawalAddress];
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