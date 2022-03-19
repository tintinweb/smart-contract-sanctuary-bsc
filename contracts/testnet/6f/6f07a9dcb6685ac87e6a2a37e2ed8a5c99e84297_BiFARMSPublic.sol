// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Context.sol";
import "./IERC20.sol";
import "./SafeERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";

contract BiFARMSPublic is Context, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    
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

    
    function addSingleAccountToWhitelist(address _token, address _addr)
        external
        onlyOwner
    {
        tokenSaleWhiteList[_token][_addr] = true;
    }

    
    function removeSingleAccountFromWhitelist(address _token, address _addr)
        external
        onlyOwner
    {
        tokenSaleWhiteList[_token][_addr] = false;
    }

    
    function addMultipleAccountToWhitelist(
        address _token,
        address[] memory _addrs
    ) external onlyOwner {
        for (uint256 i = 0; i < _addrs.length; i++) {
            tokenSaleWhiteList[_token][_addrs[i]] = true;
        }
    }

    
    function removeMultipleAccountFromWhitelist(
        address _token,
        address[] memory _addrs
    ) external onlyOwner {
        for (uint256 i = 0; i < _addrs.length; i++) {
            tokenSaleWhiteList[_token][_addrs[i]] = false;
        }
    }

    
    function addSingleAccountToBuyLimitList(
        address _token,
        address _addr,
        uint256 _amount
    ) external onlyOwner {
        buyLimitList[_token][_addr] = _amount;
    }

    
    function removeSingleAccountFromBuyLimitList(address _token, address _addr)
        external
        onlyOwner
    {
        buyLimitList[_token][_addr] = 0;
    }

    
    function addMultipleAccountToBuyLimitList(
        address _token,
        address[] memory _addrs,
        uint256[] memory _amounts
    ) external onlyOwner {
        require(
            _addrs.length == _amounts.length,
            "BiFARMS : address for buy limit amounts length error"
        );
        for (uint256 i = 0; i < _addrs.length; i++) {
            buyLimitList[_token][_addrs[i]] = _amounts[i];
        }
    }

    
    function removeMultipleAccountFromBuyLimitList(
        address _token,
        address[] memory _addrs
    ) external onlyOwner {
        for (uint256 i = 0; i < _addrs.length; i++) {
            buyLimitList[_token][_addrs[i]] = 0;
        }
    }

    
    function getAddressBuyLimit(address _token, address _addr)
        external
        view
        returns (uint256)
    {
        return (buyLimitList[_token][_addr]);
    }

    
    function getAddressBuyLimitLeft(address _addr, address _token)
        external
        view
        returns (uint256)
    {
        Pair memory _pair = _getTokenPair(_token);
        
        if (buyLimitStatusList[_pair.token1]) {
            return
                buyLimitList[_pair.token1][_addr] -
                saleLimits[_getSalePairKey(_pair)][_addr];
        } else {
            return _pair.maxCap - saleLimits[_getSalePairKey(_pair)][_addr];
        }
    }

    
    function getAddressWhiteListStatus(address _token, address _addr)
        external
        view
        returns (bool)
    {
        return (tokenSaleWhiteList[_token][_addr]);
    }

    
    function getAddressBanStatus(address _token, address _addr)
        external
        view
        returns (bool)
    {
        return (bannedAddress[_token][_addr]);
    }

    
    function addSingleAccountToBannedList(address _token, address _addr)
        external
        onlyOwner
    {
        bannedAddress[_token][_addr] = true;
    }

    
    function removeSingleAccountFromBannedList(address _token, address _addr)
        external
        onlyOwner
    {
        bannedAddress[_token][_addr] = false;
    }

    
    function setTokenClaimStatus(address _token, bool _status)
        external
        onlyOwner
    {
        tokenClaimStatusList[_token] = _status;
    }

    
    function setSaleWhitelistingStatus(
        address _token,
        bool _saleWhiteListingStatus
    ) external onlyOwner {
        tokenSaleWhitelistingStatusList[_token] = _saleWhiteListingStatus;
    }

    
    function setBuyLimitStatus(address _token, bool _buyLimitStatus)
        external
        onlyOwner
    {
        buyLimitStatusList[_token] = _buyLimitStatus;
    }

    
    function setTokensLockStatus(address _token, bool _lockActive)
        external
        onlyOwner
    {
        tokenLockStatusList[_token] = _lockActive;
    }

    
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

        
        require(tokenPairList[_token1].active == false, "Pair already defined");

        
        require(
            _lockPercents.length == _lockTimestamps.length,
            "BiFARMS : percent list length check error"
        );
        uint256 totalPercent = 0;
        for (uint256 i = 0; i < _lockPercents.length; i++) {
            require(_lockPercents[i] > 0, "BiFARMS : percentage can not be zero");
            totalPercent += _lockPercents[i];
        }
        require(
            totalPercent == 100,
            "BiFARMS : Total percentage must be equal 100"
        );

        for (uint256 i = 0; i < _lockPercents.length; i++) {
            _lockPercentList[i] = _lockPercents[i];
        }

        
        for (uint256 i = 0; i < _lockTimestamps.length; i++) {
            require(
                _lockTimestamps[i] > block.timestamp,
                "BiFARMS : unlock timestamp should be higher than current time"
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

        
        tokenClaimStatusList[_token1] = false;
        
        buyLimitStatusList[_token1] = true;
        
        tokenSaleWhitelistingStatusList[_token1] = true;
       
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

    
    function _getSalePairKey(Pair memory _pair)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_pair.token0, _pair.token1));
    }

    
    function _getSignerBuyedAmount(Pair memory _pair)
        internal
        view
        returns (uint256)
    {
        return saleLimits[_getSalePairKey(_pair)][_msgSender()];
    }

    
    function _increaseSignerSaleLimit(uint256 _limit, Pair memory _pair)
        internal
    {
        saleLimits[_getSalePairKey(_pair)][_msgSender()] = saleLimits[
            _getSalePairKey(_pair)
        ][_msgSender()].add(_limit);
    }

    
    function _getLiquidity(address _token) internal view returns (uint256) {
        return IERC20(_token).balanceOf(address(this));
    }

    
    function _calculateTotalTokenLocked(address _token)
        internal
        view
        returns (uint256)
    {
        return totalLockedAmounts[_token];
    }

    
    function _createMultipleLocks(
        address _tokenAddress,
        address _withdrawalAddress,
        uint256[] memory _amounts,
        uint256[] memory _unlockTimes
    ) internal returns (uint256 _id) {
        require(
            _amounts.length > 0,
            "BiFARMS : amounts array length cannot be zero"
        );
        require(
            _amounts.length == _unlockTimes.length,
            "BiFARMS : amounts array length and unlock timestamp array length must same"
        );

        uint256 i;
        for (i = 0; i < _amounts.length; i++) {
            require(_amounts[i] > 0, "BiFARMS : amount cannot be zero");
            require(
                _unlockTimes[i] < 10000000000,
                "BiFARMS : timestamp must be smaller then 10000000000"
            );

            
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
            "BiFARMS : given amount should be higher than unit price"
        );

        uint256[] memory lockAmounts = new uint256[](
            _pair.lockPercentList.length
        );
        uint256 dustAmount = _amount % _pair.price; 
        uint256 allowAmount = _amount.sub(dustAmount); 
        uint256 ratio = allowAmount.div(_pair.price); 
        uint256 allTransferSize = _pair.provision.mul(ratio); 

        uint256 signersAlreadyBuyedAmount = _getSignerBuyedAmount(_pair); 

        
        if (!buyLimitStatusList[_pair.token1]) {
            require(
                allowAmount >= _pair.minCap,
                "BiFARMS : acceptable amount is lower than min cap"
            );

            require(
                allowAmount <= _pair.maxCap,
                "BiFARMS : acceptable amount is higher than max cap"
            );
        }

        uint256 totalBuyedAmountAfterSale = signersAlreadyBuyedAmount.add(
            allowAmount
        );

        
        if (buyLimitStatusList[_pair.token1]) {
            require(
                totalBuyedAmountAfterSale <=
                    buyLimitList[_pair.token1][_msgSender()],
                "BiFARMS : signer buy limit is not enough"
            );
        } else {
            require(
                totalBuyedAmountAfterSale <= _pair.maxCap,
                "BiFARMS : total buyed amount will higher than max cap after transfer"
            );
        }

        
        for (uint256 i = 0; i < _pair.lockPercentList.length; i++) {
            uint256 lockPercent = _pair.lockPercentList[i];
            uint256 lockAmount = allTransferSize.div(100).mul(lockPercent);
            lockAmounts[i] = lockAmount;
        }

        require(
            lockAmounts.length > 0,
            "BiFARMS : lock amounts calculation failed"
        );

        return (allowAmount, allTransferSize, dustAmount, lockAmounts);
    }

    
    function _beforeBuy(uint256 _amount, Pair memory _pair)
        internal
        view
        returns (bool)
    {
        require(_pair.active == true, "BiFARMS : pair is not active");
        require(
            _pair.receiver != address(0),
            "BiFARMS : receiver is zero address"
        );
        require(
            _pair.token1 != address(0),
            "BiFARMS : sale contract is not defined"
        );

        
        //if (tokenSaleWhitelistingStatusList[_pair.token1]) {
        //    require(
        //        tokenSaleWhiteList[_pair.token1][_msgSender()],
        //        "BiFARMS : signer is not in whitelist"
        //    );
        //}

        
        //if (buyLimitStatusList[_pair.token1]) {
        //    require(
        //        buyLimitList[_pair.token1][_msgSender()] >= _amount,
        //        "BiFARMS : signer buy limit is not enough"
        //    );
        //}

        
        uint256 signerAllowance = IERC20(_pair.token0).allowance(
            _msgSender(),
            address(this)
        );

        require(
            signerAllowance >= _amount,
            "BiFARMS : signer allowance required for pair.token0"
        );

        return true;
    }

    
    function buy(uint256 _amount, address _token) external {
        Pair memory _pair = _getTokenPair(_token);
        require(
            _beforeBuy(_amount, _pair) == true,
            "BiFARMS : buy is not allowed currently"
        );

        
        (
            uint256 _allowAmount,
            uint256 _allTransferSize,
            uint256 _dustAmount,
            uint256[] memory _lockAmounts
        ) = _calculateSendAmount(_amount, _pair);

        
        require(
            _allTransferSize <= _getLiquidity(_token),
            "BiFARMS : insufficient liquidity for token1"
        );

        
        SafeERC20.safeTransferFrom(
            IERC20(_pair.token0),
            _msgSender(),
            address(this),
            _amount
        );

        
        SafeERC20.safeTransfer(
            IERC20(_pair.token0),
            _pair.receiver,
            _allowAmount
        );

        
        if (_dustAmount > 0) {
            SafeERC20.safeTransfer(
                IERC20(_pair.token0),
                _msgSender(),
                _dustAmount
            );
        }

        if (tokenLockStatusList[_pair.token1]) {
            _increaseSignerSaleLimit(_allowAmount, _pair);

            
            uint256 lockSuccess = _createMultipleLocks(
                _pair.token1,
                _msgSender(),
                _lockAmounts,
                _pair.lockTimestampList
            );

            require(lockSuccess > 0, "BiFARMS : lock call is failed");
        } else {
            _increaseSignerSaleLimit(_allowAmount, _pair);

            
            SafeERC20.safeTransfer(
                IERC20(_pair.token1),
                _msgSender(),
                _allTransferSize
            );
        }
    }

    
    function addLiquidity(uint256 _amount, address _token) external onlyOwner {
        Pair memory _pair = _getTokenPair(_token);
        uint256 allowance = IERC20(_pair.token1).allowance(
            _msgSender(),
            address(this)
        );
        require(allowance >= _amount, "BiFARMS : allowance is not enough");
        SafeERC20.safeTransferFrom(
            IERC20(_pair.token1),
            _msgSender(),
            address(this),
            _amount
        );
    }

    
    function removeLiquidity(
        address _to,
        uint256 _amount,
        address _token
    ) external onlyOwner {
        Pair memory _pair = _getTokenPair(_token);
        require(_to != address(0), "BiFARMS : to address is zero address");
        require(
            _getLiquidity(_token) >= _amount,
            "BiFARMS : insufficient liquidity"
        );

        require(
            _calculateTotalTokenLocked(_pair.token1) <=
                _getLiquidity(_token) - _amount,
            "BiFARMS : there are locked tokens you can not remove locked tokens"
        );
        SafeERC20.safeTransfer(IERC20(_pair.token1), _to, _amount);
    }

    
    function addLiquidityWithContract(address _contract, uint256 _amount)
        external
        onlyOwner
    {
        uint256 allowance = IERC20(_contract).allowance(
            _msgSender(),
            address(this)
        );
        require(allowance >= _amount, "BiFARMS : allowance is not enough");
        SafeERC20.safeTransferFrom(
            IERC20(_contract),
            _msgSender(),
            address(this),
            _amount
        );
    }

    
    function removeLiquidityWithContract(
        address _contract,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        require(_to != address(0), "BiFARMS : to address is zero address");
        require(
            IERC20(_contract).balanceOf(address(this)) >= _amount,
            "BiFARMS : insufficient liquidity"
        );

        require(
            _calculateTotalTokenLocked(_contract) <=
                IERC20(_contract).balanceOf(address(this)) - _amount,
            "BiFARMS : there are locked tokens, you can not remove locked tokens"
        );

        SafeERC20.safeTransfer(IERC20(_contract), _to, _amount);
    }

    
    function transferLocks(uint256 _id, address _receiverAddress) external {
        require(!lockedToken[_id].withdrawn, "BiFARMS : amount already withdrawn");
        require(
            _msgSender() == lockedToken[_id].withdrawalAddress,
            "BiFARMS : this is not your token dude"
        );

        
        walletTokenBalance[lockedToken[_id].tokenAddress][
            _msgSender()
        ] = walletTokenBalance[lockedToken[_id].tokenAddress][_msgSender()].sub(
            lockedToken[_id].tokenAmount
        );

        
        walletTokenBalance[lockedToken[_id].tokenAddress][
            _receiverAddress
        ] = walletTokenBalance[lockedToken[_id].tokenAddress][_receiverAddress]
            .add(lockedToken[_id].tokenAmount);

        
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

    
    function withdrawTokens(uint256 _id) external {
        require(
            !bannedAddress[lockedToken[_id].tokenAddress][_msgSender()],
            "BiFARMS: sender address banned to claim for this token"
        );
        require(
            tokenClaimStatusList[lockedToken[_id].tokenAddress] == true,
            "BiFARMS : token claim status is not ready"
        );
        require(
            block.timestamp >= lockedToken[_id].unlockTime,
            "BiFARMS : unlocktime should smaller then block timestamp"
        );
        require(
            _msgSender() == lockedToken[_id].withdrawalAddress,
            "BiFARMS : this is not your token dude"
        );
        require(!lockedToken[_id].withdrawn, "BiFARMS : amount already withdrawn");

        lockedToken[_id].withdrawn = true;

        
        walletTokenBalance[lockedToken[_id].tokenAddress][
            _msgSender()
        ] = walletTokenBalance[lockedToken[_id].tokenAddress][_msgSender()].sub(
            lockedToken[_id].tokenAmount
        );

        
        totalLockedAmounts[lockedToken[_id].tokenAddress] = totalLockedAmounts[
            lockedToken[_id].tokenAddress
        ].sub(lockedToken[_id].tokenAmount);

        
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

        
        require(
            IERC20(lockedToken[_id].tokenAddress).transfer(
                _msgSender(),
                lockedToken[_id].tokenAmount
            ),
            "BiFARMS : error while transfer tokens"
        );

        emit LogWithdrawal(_msgSender(), lockedToken[_id].tokenAmount);
    }

    
    function getContractTotalTokenBalance(address _tokenAddress)
        external
        view
        returns (uint256)
    {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

   
    function getTokenBalanceByAddress(
        address _tokenAddress,
        address _walletAddress
    ) external view returns (uint256) {
        return walletTokenBalance[_tokenAddress][_walletAddress];
    }

    
    function getAllLockIds() external view returns (uint256[] memory) {
        return allLockIds;
    }

    
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

    
    function getDepositsByWithdrawalAddress(address _withdrawalAddress)
        external
        view
        returns (uint256[] memory)
    {
        return depositsByWithdrawalAddress[_withdrawalAddress];
    }

    
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