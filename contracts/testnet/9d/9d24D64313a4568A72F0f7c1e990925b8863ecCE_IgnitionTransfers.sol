// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "./IgnitionIDO.sol";

/**
* @title IGNITION Events Contract
* @author Luis Sanchez / Alfredo Lopez: PAID Network 2021.4
*/
contract IgnitionTransfers is IgnitionIDO {
	using SafeERC20Upgradeable for IERC20Upgradeable;
	using LibPool for LibPool.PoolTokenModel;

	struct PoolParam {
		uint8 id;
		address addr;
	}

	/**
	* @notice Buy BaseAsset Token in the CrownSale of this Pool only with ETH
	* @dev Error IGN01 - Pool don't use ETH for IDO
	* @dev Error IGN02 - Private Pool Sale Reached Maximum
	* @dev Error IGN03 - Sale isn't active
	* @dev Error IGN04 - You can't send more than max payable amount
	* @dev Error IGN05 - Insufficient token
	* @dev Receive ETH of the sender address and setting in the Whitelist the rewardedAmount, for redeemed the BaseAsset Token when finalized the CrownSale
	* @param _pool} Id of the pool (is important to clarify this number must be order by priority for handle the Auto Transfer function)
	* @param _poolAddr} Address of the BaseAsset, and Index of the Mapping in the Smart Contract
	*/
	function buyTokensETH(
		uint8 _pool,
		address _poolAddr,
		bytes32[] calldata _merkleProof,
		uint8 _tier
	)
	external payable whenNotPaused isWhitelist(_pool, _poolAddr, _merkleProof, _tier) {

		PoolParam memory pp = PoolParam(_pool, _poolAddr);
		LibPool.PoolTokenModel storage pt = poolTokens[pp.addr][pp.id];

		require(address(pt.quoteAsset) == address(0),"IGN01");
		uint256 rewardedAmount = calculateAmount(
			pp.id,
			pp.addr,
			msg.value
		);

		if (pt.isPrivPool()) {
			require(pt.totalRaise + msg.value <= pt.maxRaiseAmount, "IGN02");
		}

		require(pt.isActive(), "IGN03");

		User storage _user = users[pp.addr][pp.id][msg.sender];
		require(_user.amount + msg.value <= pt.baseTier * _tier, "IGN04");

		require(pt.soldAmount + rewardedAmount <= pt.tokenTotalAmount, "IGN05");

		_user.amount = _user.amount + msg.value;
		_user.rewardedAmount = _user.rewardedAmount + rewardedAmount;
		pt.soldAmount = pt.soldAmount + rewardedAmount;
		pt.totalRaise = pt.totalRaise + msg.value;

		emit LogBuyTokenETH(
			pp.addr,
			pp.id,
			msg.sender,
			msg.value,
			rewardedAmount
		);
	}

	/**
	* @notice Buy BaseAsset Token in the CrownSale of this Pool only with QuoteAsset
	* @dev Error IGN06 - Pool don't use ERC20 Stablecoin for IDO
	* @dev Error IGN07 - Private Pool Sale Reached Maximum
	* @dev Error IGN08 - You can't send more than max payable amount
	* @dev Error IGN10 - Don't have allowance to Buy
	* @dev Error IGN03 - Sale isn't active
	* @dev Receive the value of the QuoteAsset of the sender address, execute the IncreaseAllowance and the TransferFrom and setting in the
	* @dev Whitelist the rewardedAmount, for redeemed the BaseAsset Token when finalized the CrownSale
	* @param _pool Id of the pool (is important to clarify this number must be order by priority for handle the Auto Transfer function)
	* @param _poolAddr Address of the BaseAsset, and Index of the Mapping in the Smart Contract
	* @param value Buy amount
	*/
	function buyTokensQuoteAsset(
		uint8 _pool,
		address _poolAddr,
		uint256 value,
		bytes32[] calldata _merkleProof,
		uint8 _tier
	)
	external whenNotPaused isWhitelist(_pool, _poolAddr, _merkleProof, _tier) {

		PoolParam memory pp = PoolParam(_pool, _poolAddr);
		LibPool.PoolTokenModel storage pt = poolTokens[pp.addr][pp.id];
		User storage _user = users[pp.addr][pp.id][msg.sender];

		require(address(pt.quoteAsset) != address(0), "IGN06");
		require(pt.isActive(), "IGN03");

		if (pt.isPrivPool()) {
			require(pt.totalRaise + value <= pt.maxRaiseAmount, "IGN07");
		}

		uint256 _value;{
			_value = value / LibPool.getDecimals(ERC20Decimals[pt.quoteAsset].decimals);
			require(_user.amount + _value <= pt.baseTier * _tier, "IGN08");
		}

		uint256 rewardedAmount;
		{
			rewardedAmount = calculateAmount(pp.id, pp.addr, _value);
			require(pt.soldAmount + rewardedAmount <= pt.tokenTotalAmount, "IGN05");
		}

		IERC20Upgradeable _token = IERC20Upgradeable(pt.quoteAsset);
		require(_token.allowance(msg.sender,address(this)) >= _value,"IGN10");

		_user.amount = _user.amount + _value;
		_user.rewardedAmount = _user.rewardedAmount + rewardedAmount;

		pt.soldAmount = pt.soldAmount + rewardedAmount;
		pt.totalRaise = pt.totalRaise + _value;

		_token.safeTransferFrom(msg.sender,	address(this), _value);
		emit LogBuyTokensQuoteAsset(
			pp.addr,
			pp.id,
			pt.quoteAsset,
			msg.sender,
			_value,
			rewardedAmount
		);
	}

	/**
	* @notice Withdraw ETH or QuoteAsset Total Amount Raised in the CrownSale of this Pool
	* @dev Error IGN16 - Pool isn't finalized
	* @dev Error IGN13 - Total Raised was withdrawn
	* @dev Receive your ETH or QuoteAsset Token in the admin address setting in the Pool, and change the withdrawed status to true in the Pool
	* @param _pool Id of the pool (is important to clarify this number must be order by priority for handle the Auto Transfer function)
	* @param _poolAddr Address of the BaseAsset, and Index of the Mapping in the Smart Contract
	*/
	function withdrawRaisedFounds(uint8 _pool, address _poolAddr)
	external whenNotPaused isOwnerOrAdmin(_pool, _poolAddr) {
		uint8 nextPoolId = uint8(_pool + uint8(1));
		LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];
		LibPool.PoolTokenModel storage _nextPool = poolTokens[_poolAddr][nextPoolId];

		require(pt.isFinalized(),"IGN16");
		require(
			!pt.isWithdrawed() && (pt.totalRaise != uint(0)),
			"IGN13"
		);
		require(!_nextPool.valid, "IGN60");

		// Total Raise in Zero, because send out, all profic of this pool in ETH
		uint256 amount = pt.totalRaise;
		pt.totalRaise = uint(0);
		// isWithdrawed = true;
		pt.packageData = Data.setPkgDtBoolean(pt.packageData, true, 232);

		if (pt.quoteAsset == address(0)) {
			// solhint-disable-next-line avoid-low-level-calls, avoid-call-value
			(bool success, ) = msg.sender.call{value: amount}("");
			if (!success) {
				revert("Address: unable to send value, recipient may have reverted");
			}
		} else {

			IERC20Upgradeable(pt.quoteAsset).safeTransfer(
				msg.sender,
				amount
			);
		}
		emit LogWithdrawRaisedFounds(_poolAddr, _pool, IDOManagers[_poolAddr], pt.quoteAsset, true, amount );
	}

	/**
	* @notice Withdraw the unsold tokens for this pool
	* @dev Receive your ETH or QuoteAsset Token in the admin address setting in the Pool, and change the withdrawed status to true in the Pool
	* @dev Error IGN43 - Pool is not paused and End Date not reached
	* @dev Error IGN53 - Pool is finalized
	* @dev Error IGN15 - Contract's token balance insufficient
	* @dev Error IGN60 - Can't withdraw, not the last pool
	* @param _pool Id of the pool (is important to clarify this number must be order by priority for handle the Auto Transfer function)
	* @param _poolAddr Address of the BaseAsset, and Index of the Mapping in the Smart Contract
	* @param _toAccount Address where to Send the Rest Amount unSold of the BaseAsset Token
	*/
	function withdrawUnsoldTokens(uint8 _pool, address _poolAddr, address _toAccount)
	external whenNotPaused isOwnerOrAdmin(_pool, _poolAddr) {
		uint8 nextPoolId = uint8(_pool + uint8(1));
		LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];
		LibPool.PoolTokenModel storage _nextPool = poolTokens[_poolAddr][nextPoolId];

		require(pt.isPaused() || block.timestamp > pt.getEndDate(), "IGN43");
		require(!pt.isFinalized(), "IGN53");
		require(!_nextPool.valid, "IGN60");

		uint256 soldAmount = pt.soldAmount;
		LibPool.FallBackModel storage fb = fallBacks[_poolAddr][_pool];
		fb.fbck_finalize = pt.tokenTotalAmount - soldAmount;
		fb.fbck_account = _toAccount;

		require(
			IERC20Upgradeable(_poolAddr).balanceOf(address(this)) >= fb.fbck_finalize,
			"IGN15"
		);
		IERC20Upgradeable(_poolAddr).transfer(fb.fbck_account,fb.fbck_finalize);

		pt.setFinalized();
		pt.tokenTotalAmount = soldAmount;

		emit LogwithdrawUnsoldTokens(
			_poolAddr,
			_pool,
			IDOManagers[_poolAddr],
			pt.quoteAsset,
			fb.fbck_account,
			pt.tokenTotalAmount,
			fb.fbck_finalize);
	}

	/**
	* @notice StakeHolders Redeem Tokens for the IDO
	* @dev Error IGN16 - Pool isn't finalized
	* @dev Error IGN17 - Already Redeemed
	* @dev Error IGN18 - There is no Reward tokens
	* @param _pool Id of the pool (is important to clarify this number must be order by priority for handle the Auto Transfer function)
	* @param _poolAddr Address of the BaseAsset, and Index of the Mapping in the Smart Contract
	* @dev Receive your BaseAsset Token in the sender address, and change the redeemed status to true in the whitelist struct
	*/
	function redeemTokens(
		uint8 _pool,
		address _poolAddr,
		bytes32[] calldata _merkleProof,
		uint8 _tier
	)
	external whenNotPaused isWhitelist(_pool, _poolAddr, _merkleProof, _tier) {
		LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];
		require(pt.isFinalized(), "IGN16");

		User storage _user = users[_poolAddr][_pool][msg.sender];
		IERC20Upgradeable _token = IERC20Upgradeable(address(uint160(pt.packageData)));

		require(!_user.redeemed, "IGN17");
		require(_user.rewardedAmount > 0, "IGN18");

		pt.tokenTotalAmount = pt.tokenTotalAmount - _user.rewardedAmount;

		_token.safeTransfer(address(msg.sender), _user.rewardedAmount);
		_user.redeemed = true;

		emit LogRedeemed(
			_poolAddr,
			_pool,
			msg.sender,
			true,
			true,
			_user.amount,
			_user.rewardedAmount
		);
	}
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.5;

import "./IgnitionPools.sol";

/**
* @title IGNITION IDO Contract
* @author Luis Sanchez / Alfredo Lopez: PAID Network 2021.4
* @dev First 2 are moon and galaxy which are the standard pools on every IDO
* @dev the other ones are any other pools that needs to be added to the IDO
*/
contract IgnitionIDO is IgnitionPools {
	using SafeERC20Upgradeable for IERC20Upgradeable;
	using LibPool for LibPool.PoolTokenModel;

	/**
	* @notice Finalized CrownSale Pool Token, and Remove the Rest Amount of Token
	* @notice Removed Token From the Pool and Finalized
	* @dev Only Owner and Project Owner of the IDO
	* @dev Error IGN20 - Pool Token Sale has already started
	* @dev Error IGN52 - Pool is not auto-transfer
	* @param _pool Id of the pool (is important to clarify this number must be order by priority for handle the Auto Transfer function)
	* @param _poolAddr _poolAddr Address of the BaseAsset, and Index of the Mapping in the Smart Contract
	*/
	function finalize(uint8 _pool, address _poolAddr)
	external isOwnerOrAdmin(_pool, _poolAddr) {

		uint8 nextPoolId = uint8(_pool + uint8(1));
		LibPool.PoolTokenModel storage _currentPool = poolTokens[_poolAddr][_pool];
		LibPool.PoolTokenModel storage _nextPool = poolTokens[_poolAddr][nextPoolId];
		
		if(uint8(_pool) > uint8(0)){
			uint8 prevPoolId = uint8(_pool - uint8(1));
			LibPool.PoolTokenModel storage _prevPool = poolTokens[_poolAddr][prevPoolId];

			if (_prevPool.valid) {
				require(_prevPool.isFinalized(), "IGN61");
			}
		}

        _nextPool.poolIsValid();
		require(block.timestamp > _currentPool.getStartDate(), "IGN20");
		require(_currentPool.isAutoTransfer(), "IGN52");

		LibPool.FallBackModel storage _fallback = fallBacks[_poolAddr][_pool];

		_fallback.fbck_endDate = _currentPool.getEndDate();

		if (_fallback.fbck_endDate > block.timestamp) {
			_currentPool.setEndDate(block.timestamp, status_boolean);
		}

		_fallback.fbck_finalize = _currentPool.tokenTotalAmount -
			_currentPool.soldAmount;

		_nextPool.tokenTotalAmount = _nextPool.tokenTotalAmount +
			_fallback.fbck_finalize;

		_currentPool.setFinalized();
		_currentPool.tokenTotalAmount = _currentPool.soldAmount;

		emit LogFinalize(
			_poolAddr,
			_pool,
			IDOManagers[_poolAddr],
			_currentPool.quoteAsset,
			true,
			nextPoolId,
			_fallback.fbck_finalize
		);
	}

	/**
	* @notice Revert Finalized CrownSale Pool Token status
	* @dev Error IGN20 - Pool Token Sale has already started
	* @dev Error IGN52 - Pool is not auto-transfer
	* @dev Error IGN16 - Pool is not finalized
	* @param _pool Id of the pool (is important to clarify this number must be order by priority for handle the Auto Transfer function)
	* @param _poolAddr _poolAddr Address of the BaseAsset, and Index of the Mapping in the Smart Contract
	*/
	function revert_finalize(uint8 _pool, address _poolAddr)
	external isOwnerOrAdmin(_pool, _poolAddr) {
		uint8 nextPoolId = uint8(_pool + (uint8(1)));
		LibPool.PoolTokenModel storage _finalizedPool = poolTokens[_poolAddr][_pool];
		LibPool.PoolTokenModel storage _nextPool = poolTokens[_poolAddr][nextPoolId];
		LibPool.FallBackModel memory _fallback = fallBacks[_poolAddr][_pool];

		require(_finalizedPool.isAutoTransfer(), "IGN52");
		require(_finalizedPool.isFinalized(), "IGN16");
		_nextPool.poolIsValid();

		if (_fallback.fbck_endDate > block.timestamp) {
			_finalizedPool.setEndDate(block.timestamp, status_boolean);
		}

		_nextPool.tokenTotalAmount = _nextPool.tokenTotalAmount -
			_fallback.fbck_finalize;

		_finalizedPool.tokenTotalAmount = _finalizedPool.tokenTotalAmount +
			_fallback.fbck_finalize;

		_finalizedPool.packageData = _finalizedPool.packageData & ~(uint256(1)<<233);

		emit LogRevertFinalize(
			_poolAddr,
			_pool,
			IDOManagers[_poolAddr],
			_finalizedPool.quoteAsset,
			true,
			nextPoolId,
			_fallback.fbck_finalize
		);
	}

	/**
	* @notice Add Whitelist
	* @dev Only Owner
	* @dev Error IGN21 - Pool Token Crowd Sale is active or finalized
	* @dev Error IGN58 - Pools and roots array lenghts are not equal
	* @param _pools Id of the pool (is important to clarify this number must be order by priority for handle the Auto Transfer function)
	* @param _poolAddr Address of the BaseAsset, and Index of the Mapping in the Smart Contract
	* @param _merkleRoots root of the merkle three
	*/
	function setWhiteList(
		uint8[] memory _pools,
		address _poolAddr,
		bytes32[]memory _merkleRoots
	) external whenNotPaused {
		_isOwnerOrAdmin(_poolAddr);
		require(_pools.length == _merkleRoots.length, "IGN58");

		for (uint i = 0; i < _pools.length; i++) {
			LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pools[i]];
			pt.poolIsValid();
			require(block.timestamp <= pt.getStartDate(), "IGN21");
			merkleRoots[_poolAddr][_pools[i]] = _merkleRoots[i];

			emit LogWhiteList(_poolAddr, _pools[i], _merkleRoots[i]);
		}
	}
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.5;

import "./IgnitionAccess.sol";

// First 2 are moon and galaxy which are the standard pools on every IDO
// the other ones are any other pools that needs to be added to the IDO

/**
* @title IGNITION Pools Contract
* @author Luis Sanchez / Alfredo Lopez: PAID Network 2021.4
*/
contract IgnitionPools is IgnitionAccess {
	using SafeERC20Upgradeable for IERC20Upgradeable;
    using LibPool for LibPool.PoolTokenModel;

    mapping(address => mapping(uint8 => uint256)) private _timepaused;

    /**
	 * Add CrownSale Pool Token
	 *
	 * @dev Only Owner
     * @dev Error IGN22 - Token Pool Exist
     * @dev Error IGN26 - Must be set Secondary Project Token Amount more than Zero
     * @dev Error IGN27 - Don't support the Value
     * @dev Error IGN47 - Unsuported address
     * @dev Error IGN49 - Start Date must be after current time and before end date
	 * @param _address[0] {address _baseAsset},
	 * @param _address[1] {address _quoteAsset} Address of the QuoteAsset of Pool
	 * @param _address[2] {address _pplSuppAsset} Main token adddress to hold (eg PAID)
     * @param _address[3] {address _sndSuppAsset} Optional token address to hold
	 * @param _args[0] {uint256 _startDate} Start Date of Pool
	 * @param _args[1] {uint256 _endDate}End Date of Pool
	 * @param _args[2] {uint256 _pool} Pool into the IDO (CrownSale)
	 * @param _args[3] {uint256 _rate} rate based on QuoteAsset used in the Pool
	 * @param _args[4] {uint256 _baseTier} floor or base of the Tier Structure in the Pool
	 * @param _args[5] {uint256 _pplAmount} Principal Support Project Amount Limit for Participate in the Pool
     * @param _args[6] {uint256 _sndAmount} Secondary Support Project Amount Limit for Participate in the Pool
	 * @param _args[7] {uint256 _tokenTotalAmount},
	 * @param _args[8] {uint256 _maxRaiseAmount},
	 * @param _args[9] {uint256(boolean)}: Private Pool active/inactive
	 * @param _args[10] {uint256(boolean)}: Auto Transfer Active / Inactive in the Pool
     * @param _args[11] {uint256 _baseAssetDecimals} Decimals Presicion for Base Asset
     * @param _args[12] {uint256 _QuoteAssetDecimals} Decimals Presicion for Quote Asset
     * @param _args[13] {uint256 _pplSuppAssetDecimals} Decimals Presicion for Pricipal Support Asset
     * @param _args[14] {uint256 _sndSuppAsset Decimals} Decimals Presicion for Secondary Support Asset
	 */
	function addTokenToPool(address[4] memory _address, uint256[15] memory _args)
    external whenNotPaused {
        _isOwnerOrAdmin(_address[0]);
        require(
            _address[0] != address(0) &&
            _address[2] != address(0), "IGN47"
        );
        require(!poolTokens[_address[0]][uint8(_args[2])].valid, "IGN22");
        require(
            block.timestamp < _args[0] &&
            _args[0] < _args[1],
            "IGN49"
        );
        require(_args[7] > uint(0), "IGN51");

        uint256 _packageData = LibPool.generatePackage(_address[0], _args);

        // Verify Secondary Project Token Amount not Zero, when the Secondary Project token address is different address(0)
        if (_address[3] != address(0)) {
            require(_args[6] > uint(0), "IGN26");
        }

        // Add mapping for ERC20 Decimals
        for (uint256 i = 0; i < 4; i++) {
            require(_args[11+i] <= uint(18), "IGN27");
            if (!ERC20Decimals[_address[i]].active) {
                ERC20Decimals[_address[i]].active = true;
                ERC20Decimals[_address[i]].decimals = _args[11+i];
            }
        }

        uint256 _pplAmount = _args[5] /
            LibPool.getDecimals(ERC20Decimals[_address[2]].decimals);

        uint256 _sndAmount = _args[6] /
            LibPool.getDecimals(ERC20Decimals[_address[3]].decimals);

        uint256 _tokenTotalAmount = _args[7] /
            LibPool.getDecimals(ERC20Decimals[_address[0]].decimals);

        uint256 _maxRaiseAmount = _args[8] /
            LibPool.getDecimals(ERC20Decimals[_address[1]].decimals);

        fallBacks[_address[0]][uint8(_args[2])] = LibPool.FallBackModel({
            fbck_finalize: 0,
            fbck_endDate: 0,
            fbck_account: address(0)
        });

		poolTokens[_address[0]][uint8(_args[2])] = LibPool.PoolTokenModel({
            valid: true,
            quoteAsset: _address[1],
            pplSuppAsset: _address[2],
            sndSuppAsset: _address[3],
            packageData: _packageData,
            rate: _args[3],
            baseTier: _args[4],
            pplAmount: _pplAmount,
            sndAmount: _sndAmount,
            soldAmount: 0,
            tokenTotalAmount: _tokenTotalAmount,
            totalRaise: 0,
            maxRaiseAmount: _maxRaiseAmount
        });

        emit LogPoolToken(
            _address[0],
            uint8(_args[2]),
            IDOManagers[_address[0]],
            _address[1],
            _address[2],
            _args[0],
            _args[1],
            _args[3],
            _args[4],
            _pplAmount,
            _sndAmount,
            _tokenTotalAmount,
            _maxRaiseAmount
        );
	}

    /**
    * @notice Set Rate for the collateral in the pool    *
    * 1 QuoteAsset (e.g. ETH/WETH/USDC/USDT) = ?  BaseAsset Token
    * Example: 1 Ether = 30 Token
    * @param _pool  number Id of Pool in Priority Order
    * @param _poolAddr The Token Address of the IDO
    * @param _rate Rate of the Token According with the Coin Used in the CrowdSale
    */
    function setRate(uint8 _pool, address _poolAddr, uint256 _rate)
    external whenNotPaused isOwnerOrAdmin(_pool, _poolAddr) {
        LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];

        uint256 oldRate = pt.rate;
        pt.rate = _rate;
        emit LogRatePool(_poolAddr, _pool, oldRate, _rate);
    }

    /**
    * change Base Tier
    * @notice Method to change to the Base Tier and Paid Amount of the Pool
    * @dev Only Owner or Project Owner
    * @dev Error IGN27 - Don't support the Value
    * @dev Error IGN28 - Pool Token Sale has already started
    * @dev Error IGN29 - Must be set Secondary Project Token Amount more than Zero
    * @dev Error IGN47 - Unsuported address
    * @dev Error IGN48 - _pplAmount must be greater than zero
    * @param _pool  number Id of Pool in Priority Order
    * @param _poolAddr The Token Address of the IDO
    * @param _baseTier Tier 1
    * @param _ppalAddress Main support address asset
    * @param _sndAddresss Secondary support address asset
    * @param _pplAmount Main amount need to be holding
    * @param _sndAmount Secondary amount need to be holding
    * @param _decimalsPpl Main decimals on holding asset
    * @param _decimalsSnd Secondary decimals on holding asset
    */
    function setBaseTier(
        uint8 _pool,
        address _poolAddr,
        uint256 _baseTier,
        address _ppalAddress,
        address _sndAddresss,
        uint256 _pplAmount,
        uint256 _sndAmount,
        uint256 _decimalsPpl,
        uint256 _decimalsSnd
    ) external whenNotPaused isOwnerOrAdmin(_pool, _poolAddr) {
        LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];

        require(block.timestamp < pt.getStartDate(), "IGN28");
        require(_ppalAddress != address(0), "IGN47");
        require(_decimalsPpl <= uint(18), "IGN27");

        if (!ERC20Decimals[_ppalAddress].active) {
            ERC20Decimals[_ppalAddress].active = true;
            ERC20Decimals[_ppalAddress].decimals = _decimalsPpl;
        }

        if (_sndAddresss != address(0)) {
            require(_decimalsSnd <= uint(18), "IGN27");

            if (!ERC20Decimals[_sndAddresss].active) {
                ERC20Decimals[_sndAddresss].active = true;
                ERC20Decimals[_sndAddresss].decimals = _decimalsSnd;
            }
        }

        pt.baseTier = _baseTier;
        pt.pplSuppAsset = _ppalAddress;
        pt.sndSuppAsset = _sndAddresss;
        pt.pplAmount = _pplAmount / LibPool.getDecimals(_decimalsPpl);
        pt.sndAmount = _sndAmount / LibPool.getDecimals(_decimalsSnd);

        emit LogBaseTier(_poolAddr, _pool, _baseTier);
    }

    /**
    * change Start Date of Pool
    *
    * @dev Only Owner or Project Owner
    * @dev Error IGN30 - Pool Token Sale has already started
    * @dev Error IGN49 - Start Date must be after current time and before end date
    * @notice Method to change to the Start of the Pool
    * @param _pool  number Id of Pool in Priority Order
    * @param _poolAddr The Token Address of the IDO
    * @param _newStartDate New start date
    */
    function setStartDate(uint8 _pool, address _poolAddr, uint256 _newStartDate)
    external isOwnerOrAdmin(_pool, _poolAddr) {
        LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];

        require(block.timestamp < pt.getStartDate(), "IGN30");
        require(
            block.timestamp < _newStartDate && _newStartDate < pt.getEndDate(),
            "IGN49"
        );

        uint256 oldDate = uint256(uint32(pt.packageData>>160));

        pt.setStartDate(_newStartDate, status_boolean);

        emit LogStartDatePool(_poolAddr, _pool, oldDate, _newStartDate);
    }

    /**
    * @notice change End Date of Pool
    * @dev Only Owner or Project Owner
    * @dev Error IGN31 - Pool Token Sale End
    * @dev Error IGN50 - End Date must be after current time and Start Date
    * @notice Method to change to the EndDate of the Pool
    * @param _pool  number Id of Pool in Priority Order
    * @param _poolAddr The Token Address of the IDO
    * @param _newEndDate New end date
    */
    function setEndDate(uint8 _pool, address _poolAddr, uint256 _newEndDate)
    public isOwnerOrAdmin(_pool, _poolAddr) {
        LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];

        require(block.timestamp < pt.getEndDate(), "IGN31");
        require(
            block.timestamp <= _newEndDate && pt.getStartDate() < _newEndDate,
            "IGN50"
        );

        uint256 _packageData = pt.packageData;
        uint256 oldDate = uint256(uint32(_packageData>>192));

        pt.setEndDate(_newEndDate, status_boolean);

        emit LogEndDatePool(_poolAddr, _pool, oldDate, _newEndDate);
    }

    /**
    * Paused of Pool
    * @dev Error IGN32 - Sale isn't active
    * @dev Only Owner
    * @notice Method to paused the Pool in any moment and the time paused is addition to the EndDate of the Pool
    * @param _pool Id of Pool in Priority Order
    * @param _poolAddr The Token Address of the IDO
    */
    function pausePool(uint8 _pool, address _poolAddr)
    external isOwnerOrAdmin(_pool, _poolAddr) {
        LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];

        require(pt.isActive(), "IGN32");
        if (!pt.isPaused()) {
            _timepaused[_poolAddr][_pool] = block.timestamp;
            // paused = true
            poolTokens[_poolAddr][_pool].packageData = poolTokens[_poolAddr][_pool].packageData | (uint256(1)<<234);
            emit LogPausePool(_poolAddr, _pool, true);
        }
    }

    /**
    * Unpaused of Pool
    *
    * @dev Only Owner
    * @notice Method to unpaused the Pool in any moment and the time paused is addition to the EndDate of the Pool
    * @param _pool number Id of Pool in Priority Order
    * @param _poolAddr The Token Address of the IDO
    */
    function unPausePool(uint8 _pool, address _poolAddr)
    external isOwnerOrAdmin(_pool, _poolAddr) {
        LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];

        uint256 endDate = pt.getEndDate();
        if (pt.isPaused()) {
            endDate = endDate + block.timestamp - _timepaused[_poolAddr][_pool];
            pt.setEndDate(endDate, status_boolean);
            // paused = false
            pt.packageData = pt.packageData & ~(uint256(1)<<234);
            emit LogPausePool(_poolAddr, _pool, false);
        }
    }

    /**
    * Change Total Amount of the BaseAsset Token in this Pool
    *
    * @dev Only Owner
    * @dev Error IGN33 - Pool Token Sale has already started or Finalized
    * @dev Error IGN51 - totalAmount can't be zero
    * @param _pool  number Id of Pool in Priority Order
    * @param _poolAddr The Token Address of the IDO
    * @param _newTotalAmount the new Total Amount of the BaseAsset Token in this Pool
    */
    function setTokenTotalAmount(
        uint8 _pool,
        address _poolAddr,
        uint256 _newTotalAmount
    ) external whenNotPaused isOwnerOrAdmin(_pool, _poolAddr) {
        LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];

		require(block.timestamp < pt.getStartDate(), "IGN33");
        require(_newTotalAmount > uint(0), "IGN51");

        uint256 oldTotalAmount = pt.tokenTotalAmount;

        pt.tokenTotalAmount = _newTotalAmount /
            LibPool.getDecimals(ERC20Decimals[_poolAddr].decimals);

        emit LogTokenTotalAmount(_poolAddr, _pool, oldTotalAmount, _newTotalAmount);
    }

    /**
    * Arbitrary Manual Transfer Poll
    *
    * @dev Only Owner
    * @dev Error IGN35 - Pool Token Sale Origin has auto transfer pool actived
    * @dev Error IGN36 - Out of window for the Transfer
    * @dev Error IGN37 - Tokens of the Pool Origin was Withdrawn or moved to another Pool
    * @param _poolAddr The Token Address of the IDO
    * @param _frompool Pool Origin for Transfer the BaseAsset Token
    * @param _topool  Pool Destination for Transfer the BaseAsset Token
    */
    function transferPool(address _poolAddr, uint8 _frompool, uint8 _topool)
    external isOwnerOrAdmin(_frompool, _poolAddr) {
        LibPool.PoolTokenModel storage toPool = poolTokens[_poolAddr][_topool];
        LibPool.PoolTokenModel storage fromPool = poolTokens[_poolAddr][_frompool];

        toPool.poolIsValid();
        require(!fromPool.isAutoTransfer(), "IGN35");
		require(
            block.timestamp < toPool.getStartDate() &&
            !fromPool.isActive() && !toPool.isActive(),
			"IGN36"
		);
		require(fromPool.tokenTotalAmount != uint(0), "IGN37");

        uint256 substrate = fromPool.tokenTotalAmount - fromPool.soldAmount;
        uint256 oldAmount = toPool.tokenTotalAmount;
        // isFinalized = true;
		fromPool.packageData = fromPool.packageData | (uint256(1)<<233);
        toPool.tokenTotalAmount = toPool.tokenTotalAmount + substrate;
        fromPool.tokenTotalAmount = fromPool.tokenTotalAmount - substrate;

        emit LogTokenTotalAmount(
            _poolAddr,
            _topool,
            oldAmount,
            toPool.tokenTotalAmount);
    }

    /**
	* @notice Setter for Enable te Private Pool
	* @notice Enable the Private Pool status after tho Add the Pool in the Smart Contract
	* @dev Only Owner can activate and only when the All Smart Contract is NOT Paused()
	* @dev Error IGN44 - Pool Token Sale has already started
	* @dev Error IGN45 - Max Raise Amount must not be Zero
    * @dev Error IGN23 - Must be set Max Raised Amount more than Zero to enable Private Pool
	* @param _pool Id of the pool (is important to clarify this number must be order by priority for handle the Auto Transfer function)
	* @param _poolAddr Address of the BaseAsset, and Index of the Mapping in the Smart Contract
	* @param _enablePrivatePool Value True or False for enable or disable the Private Pool feature in this Pool of the IDO
	* @param _enableAutoTx Value True or False for enable or disable the AutoTx Pool feature in this Pool of the IDO
	* @param _maxRaiseAmount Max Total Amount permitted (this value apply for Private Pool)
	*/
	function setPrivAndAutoTxPool(
		uint8 _pool,
		address _poolAddr,
		bool _enablePrivatePool,
		bool _enableAutoTx,
		uint256 _maxRaiseAmount
	) external isOwnerOrAdmin(_pool, _poolAddr) {
        LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];

		require(block.timestamp < pt.getStartDate(), "IGN44");
		require(!(_enablePrivatePool && _maxRaiseAmount == uint(0)), "IGN45");

		pt.setPrivatePool(_enablePrivatePool);
		pt.setAutoFix(_enableAutoTx);
		pt.maxRaiseAmount = _maxRaiseAmount;

		emit LogPrivAndAutoTxPool(
			_poolAddr,
			_pool,
			pt.quoteAsset,
			_enablePrivatePool,
			_enableAutoTx,
			_maxRaiseAmount
        );
	}

    /**
	* @notice Set the Address for the Quote Asset
	* @notice in owner case have different option like e.g. USDT, USDC, DAI, BUSD, etc) and inclusive Wrapper ETH WETH
	* Set the Address of the ERC20 stable Coin or address(0) or "0x0000000000000000000000000000000000000000", for ETH
	* @dev Only Owner
	* @dev Error IGN46 - Don't support the Value
    * @dev Error IGN47 - Unsuported address
	* @param _pool Id of the pool (is important to clarify this number must be order by priority for handle the Auto Transfer function)
	* @param _poolAddr Address of the BaseAsset, and Index of the Mapping in the Smart Contract
	* @param _quoteAsset token ERC20 stable coin or wrapper ERC20, for but tokens in the CrownSale of the Pool in the IDO
	* @param _decimals Decimals precision for token
	*/
	function setQuoteAsset(
        uint8 _pool,
		address _poolAddr,
		address _quoteAsset,
		uint8 _decimals
	) external isOwnerOrAdmin(_pool, _poolAddr) {
		require(_decimals <= uint(18), "IGN46");
        require(_quoteAsset != address(0), "IGN47");

		if (ERC20Decimals[_quoteAsset].active) {
			ERC20Decimals[_quoteAsset].decimals = _decimals;
		} else {
			ERC20Decimals[_quoteAsset].active = true;
			ERC20Decimals[_quoteAsset].decimals = _decimals;
		}

        LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];

		pt.quoteAsset = _quoteAsset;

		emit LogQuoteAsset(
			_poolAddr,
			_pool,
			_quoteAsset,
			_decimals,
			IDOManagers[_poolAddr],
			pt.rate,
			pt.tokenTotalAmount,
			pt.maxRaiseAmount
		);
	}

    /**
    * Disable of Pool Token
    *
    * @dev Only Owner
    * @param _pool  number Id of Pool in Priority Order
    * @param _poolAddr The Token Address of the IDO
    */
    function disablePool(uint8 _pool, address _poolAddr)
    external isOwnerOrAdmin(_pool, _poolAddr) {
        LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];

        pt.valid = false;
        emit LogDisablePool(
            _poolAddr,
            _pool,
            pt.quoteAsset,
            IDOManagers[_poolAddr],
            pt.soldAmount,
            pt.tokenTotalAmount,
            pt.totalRaise
        );
    }

    /**
	* @notice External function to get the Start Date of the Pool
	* @param _pool Id of the pool (is important to clarify this number must be order by priority for handle the Auto Transfer function)
	* @param _poolAddr Address of the BaseAsset, and Index of the Mapping in the Smart Contract
	* @return Start Date of the Pool in Epoch Format
	*/
	function getStartDate (uint8 _pool, address _poolAddr)
	external view returns (uint256) {
        LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];
        pt.poolIsValid();
		return pt.getStartDate();
	}

	/**
	* @notice External function to get the End Date of the Pool
	* @param _pool Id of the pool (is important to clarify this number must be order by priority for handle the Auto Transfer function)
	* @param _poolAddr Address of the BaseAsset, and Index of the Mapping in the Smart Contract
	* @return End Date of the Pool in Epoch Format
	*/
	function getEndDate (uint8 _pool, address _poolAddr)
	external view returns (uint256) {
		LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];
        pt.poolIsValid();
		return pt.getEndDate();
	}

    /**
	* @notice External function to check if the Crowd Sale has already been started or not
	* @param _pool  number Id of Pool in Priority Order
	* @param _poolAddr The Token Address of the IDO
	* @return a boolean value according to the state of the Crowd Sale
	*/
	function isActive(uint8 _pool, address _poolAddr) external view returns (bool) {
		LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];
        pt.poolIsValid();
		return pt.isActive();
	}

    /**
	* @notice External function to check if the pool is paused
	* @param _pool  number Id of Pool in Priority Order
	* @param _poolAddr The Token Address of the IDO
	* @return a boolean value according to the state of the Crowd Sale
	*/
    function isPoolPaused(uint8 _pool, address _poolAddr) external view returns (bool) {
		LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];
        pt.poolIsValid();
		return pt.isPaused();
    }

    /**
	* @notice External function to check if the pool is Withdrawed
	* @param _pool  number Id of Pool in Priority Order
	* @param _poolAddr The Token Address of the IDO
	* @return a boolean value according to the state of the Crowd Sale
	*/
    function isPoolWithdrawed(uint8 _pool, address _poolAddr) external view returns (bool) {
		LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];
        pt.poolIsValid();
		return pt.isWithdrawed();
    }

    /**
	* @notice External function to check if the pool is finalized
	* @param _pool  number Id of Pool in Priority Order
	* @param _poolAddr The Token Address of the IDO
	* @return a boolean value according to the state of the Crowd Sale
	*/
    function isPoolFinalized(uint8 _pool, address _poolAddr) external view returns (bool) {
		LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];
        pt.poolIsValid();
		return pt.isFinalized();
    }

     /**
	* @notice External function to check if the pool is private
	* @param _pool  number Id of Pool in Priority Order
	* @param _poolAddr The Token Address of the IDO
	* @return a boolean value according to the state of the Crowd Sale
	*/
    function isPoolPrivate(uint8 _pool, address _poolAddr) external view returns (bool) {
		LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];
        pt.poolIsValid();
		return pt.isPrivPool();
    }

    /**
	* @notice External function to check if the pool is set to auto transfer
	* @param _pool  number Id of Pool in Priority Order
	* @param _poolAddr The Token Address of the IDO
	* @return a boolean value according to the state of the Crowd Sale
	*/
    function isPoolAutoTransfer(uint8 _pool, address _poolAddr) external view returns (bool) {
		LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];
        pt.poolIsValid();
		return pt.isAutoTransfer();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./IgnitionCore.sol";

contract IgnitionAccess is IgnitionCore {
	using LibPool for LibPool.PoolTokenModel;

    struct User {
        uint256 amount;             // Amount of ETH/USDT/USDC/DAI/BUSD.etc used for buy Token of the Pool of the IDO
        uint256 rewardedAmount;     // Amount rewarded based on the tier assign in th e Lottery of Ignition for this Pool of the IDO
        bool redeemed;
    }

    // rbac managers collection
	address[] private rbacManagers;

	// project(pool) admin collection
	mapping(address => address) internal IDOManagers;

	//users keep track of users amounts and if tokens were redeemed
	mapping(address => mapping(uint8 => mapping(address => User))) public users;

    //merkle roots
    mapping(address => mapping(uint8 => bytes32)) merkleRoots;

    /**
	* @notice isOwnerOrAdmin Modifier
	* @notice For validate if the Pool is valid, and if the msg.sender is Contract Owner or Project Owner
	* @dev method for reduce bytecode size of the contract
	* @param  _pool Id of the pool (is important to clarify this number must be order by priority for handle the Auto Transfer function)
	* @param _poolAddr Address of the BaseAsset, and Index of the Mapping in the Smart Contract
	*/
	modifier isOwnerOrAdmin(uint8 _pool, address _poolAddr) {
		LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];
        pt.poolIsValid();
		_isOwnerOrAdmin(_poolAddr);
        _;
    }

	/**
	* @notice isWhilisted Modifier
	* @notice For validate if the Pool is active o inactive, and if the msg.sender is Whitelisted, and Have Enough Token for the CrownSale
	* @dev method for reduce bytecode size of the contract
	* @dev Error IGN11 - Pool is paused
	* @param  _pool Id of the pool (is important to clarify this number must be order by priority for handle the Auto Transfer function)
	* @param _poolAddr Address of the BaseAsset, and Index of the Mapping in the Smart Contract
	*/
	modifier isWhitelist(
        uint8 _pool,
        address _poolAddr,
        bytes32[] calldata _merkleProof,
        uint8 _tier
    ) {
        LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];
        pt.poolIsValid();
		require(!pt.isPaused(), "IGN11");
        require(isUserWhitelisted(_pool, _poolAddr, _merkleProof, _tier), "IGN40");
		_enoughToken(_pool, _poolAddr);
        _;
    }

	/**
	* @notice isOwnerOrAdmin Function for Modifier
	* @notice method for verifiy if the msg.sender is Admin or Project Owner
	* @dev method for reduce bytecode size of the contract
	* @dev Error IGN39 - Should be admin
	* @param _poolAddr Address of the BaseAsset, and Index of the Mapping in the Smart Contract
	*/
    function _isOwnerOrAdmin(address _poolAddr) internal view {
        require(
			(IDOManagers[_poolAddr] == msg.sender) ||
			(owner() == msg.sender),
			"IGN39"
		);
    }

	/**
	* @notice _enoughToken Function for Modifier
	* @dev method for reduce bytecode size of the contract
	* @dev Error IGN41.1 - You dont have enough Principal Project Token
	* @dev Error IGN42.1 - You dont have enough Secondary Project Token
	* @param _pool Id of the pool (is important to clarify this number must be order by priority for handle the Auto Transfer function)
	* @param _poolAddr Address of the BaseAsset, and Index of the Mapping in the Smart Contract
	*/
    function _enoughToken(uint8 _pool, address _poolAddr) internal view {
		LibPool.PoolTokenModel storage pt = poolTokens[_poolAddr][_pool];

		uint256 decimal_adjust = LibPool.getDecimals(
			ERC20Decimals[pt.pplSuppAsset].decimals
		);

		uint256 pplOnWallet = IERC20Upgradeable(pt.pplSuppAsset).balanceOf(msg.sender);
		require(
			(pplOnWallet) * decimal_adjust >= pt.pplAmount,
			"IGN41.1"
		);

		if (pt.sndSuppAsset != address(0)) {
			decimal_adjust = LibPool.getDecimals(
				ERC20Decimals[pt.sndSuppAsset].decimals
			);

			uint256 sndOnWallet = IERC20Upgradeable(pt.sndSuppAsset)
				.balanceOf(msg.sender);

			require(
				(sndOnWallet) * decimal_adjust >= pt.sndAmount,
				"IGN42.1"
			);
		}
    }

	/**
	* @notice checks if user wallet is whitelisted on pool
	* @param _pool  number Id of Pool in Priority Order
	* @param _poolAddr The Token Address of the IDO
	* @param _merkleProof Proof the user is whitelisted
    * @param _tier user tier
	* @return true if user is whitelisted
	*/
	function isUserWhitelisted(
        uint8 _pool,
        address _poolAddr,
        bytes32[] calldata _merkleProof,
        uint8 _tier
    ) public view returns (bool) {
        bytes32 root = merkleRoots[_poolAddr][_pool];
		bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _tier));

        return MerkleProof.verify(_merkleProof, root, leaf);
	}

	/**
	* @notice checks if user alredy redeemed it's tokens
	* @param _pool  number Id of Pool in Priority Order
	* @param _poolAddr The Token Address of the IDO
	* @param _wallet The wallet of the Stakeholders
	* @return true if user is redeemed its tokens
	*/
	function areUserTokensRedeemed(uint8 _pool, address _poolAddr, address _wallet)
	external view returns (bool) {
        return users[_poolAddr][_pool][_wallet].redeemed;
	}

    /**
	* @notice isOwnerOrRbac modifier to check if the user is the owner or the rbac manager
	* @dev IGN56 - the wallet is not Rbac Manager or Owner
	*/
	modifier isOwnerOrRbac() {
		require(isRbacManager(msg.sender) || owner() == msg.sender, "IGN56");
		_;
	}

	function getRbackManagerIndex(address _user) private view returns (int) {
		for(uint i = 0; i < rbacManagers.length; i++) {
			if (_user == rbacManagers[i]) {
				return int(i);
			}
		}
		return -1;
	}

	function isRbacManager(address _user) private view returns (bool) {
		return getRbackManagerIndex(_user) >= 0;
	}

	/**
	* @return an array of rback manager address
	*/
	function getRbacManagers() external view onlyOwner returns (address[] memory) {
		return rbacManagers;
	}

	/**
	* @notice addRbacManager adds a wallet address to the RBAC Managers
	* @dev IGN55 - the rbac manager address can't be zero
	* @dev IGN54 - user aready is rbac manager
	* @param _newRbacManager wallet address to add
	*/
	function addRbacManager(address _newRbacManager) external onlyOwner {
		require(_newRbacManager != address(0), "IGN55");
		require(!isRbacManager(_newRbacManager), "IGN54");

		rbacManagers.push(_newRbacManager);

		emit LogRbacChange("added", _newRbacManager);
	}

	/**
	* @notice removeRbacManager removes a wallet address from the RBAC Managers
	* @dev IGN59 - address is not rbac manager
	* @param _existingRbacManager wallet address to remove
	*/
	function removeRbacManager(address _existingRbacManager) external onlyOwner {
		require(isRbacManager(_existingRbacManager), "IGN59");

		int index = getRbackManagerIndex(_existingRbacManager);
		rbacManagers[uint(index)] = rbacManagers[rbacManagers.length - 1];
		rbacManagers.pop();

		emit LogRbacChange("removed", _existingRbacManager);
	}

	/**
	* @param _tokenAddress token address for the project
	* @return IDO Manager's wallet address
	*/
	function getAdminWallet(address _tokenAddress)
	external view isOwnerOrRbac returns (address) {
		return IDOManagers[_tokenAddress];
	}

	/**
	* @notice setAdminWallet sets the admin wallet for the project
	* @dev IGN57 - _tokenAddress and _userWallet must be valid addresses
	* @param _tokenAddress the project's token address
	* @param _user wallet address to be set as admin
	*/
	function setAdminWallet(address _tokenAddress, address _user) 
	external isOwnerOrRbac {
		require(
			_tokenAddress != address(0) && _user != address(0),
			"IGN57"
		);
		IDOManagers[_tokenAddress] = _user;
		emit LogSetProjectAdmin(_tokenAddress, _user);
	}

	/**
	* @notice getUserRoles gets the user roles
	* @param _tokenAddress the project's token address
	* @return an array of strings with the roles
	*/
	function getUserRoles(address _tokenAddress) external view returns (string[3] memory) {
		string[3] memory userRoles = ["", "", ""];
		if (msg.sender == owner()) {
			userRoles[0] = "owner";
		}

		if (isRbacManager(msg.sender)) {
			userRoles[1] = "rbac";
		}

		if (IDOManagers[_tokenAddress] == msg.sender) {
			userRoles[2] = "admin";
		}

		return userRoles;
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.5;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./IgnitionEvents.sol";
import "../lib/LibPool.sol";
import "../lib/Math.sol";

contract IgnitionCore is OwnableUpgradeable, PausableUpgradeable, IgnitionEvents {

    /// Pool Token Model
	/// IDO (Token Address) -> Pool (unit) -> PoolTokenModel
    mapping(address => mapping(uint8 => LibPool.PoolTokenModel)) public poolTokens;
	mapping(address => mapping(uint8 => LibPool.FallBackModel)) public fallBacks;
	mapping(address => LibPool.ERC20Decimals) public ERC20Decimals;

	uint constant status_boolean = 5;

	function initialize() external initializer{
        __Ownable_init();
        __Pausable_init();
    }

	/**
	* @notice pause/Unpause Smart Contract
	* @dev Only Owner
	*/
	function pause(bool status) external onlyOwner {
        if (status) {
            _pause();
        } else {
            _unpause();
        }
    }

	/**
	* @notice Calculate Amount of Token
	* @dev This method hava a adjust that permit eliminate the 10 less significant digits
	* @dev This is achieved by dividing not by 1e18 to convert from wei to eth, but by
	* @dev additionally changing the exponent to the value of 1e28, to discard the last
	* @dev 10 least significant digits of the multiplication result, avoiding the
	* @dev well-known solidity precision errors when multiply bignumbers
	* @dev Error IGN34 - Buy value below threshold
	* @param _pool number Id of Pool in Priority Order
	* @param _poolAddr The Token Address of the IDO
	* @param _amount Amount in Coin (ETH/USDT/USDC/DAI, etc) for Buy Tokens of the IDO
	* @return Amount of token rewarded based in th Tiers assign in the Lottery
	*/
	function calculateAmount(uint8 _pool, address _poolAddr, uint256 _amount)
	public view returns (uint256) {

		uint256 decimal_adjust = LibPool.getDecimals(ERC20Decimals[_poolAddr].decimals);
		uint256 rewardedAmount = Math.mulDivRoundingUp(
			_amount,
			poolTokens[_poolAddr][_pool].rate,
			1e28
		) * 1e11;

		require(rewardedAmount > 0, "IGN34");
		return rewardedAmount / decimal_adjust;
	}

	/**
    * Get the Address from PackageDate variable.
    * @param _packageData Address package the data via Bytes Shift
    * @return result is a address from convert uint256 to bytes20 with address() method
    */
	function getAddress(uint256 _packageData) external pure returns (address)
	{
		return address(uint160(_packageData));
	}

	/// @notice Revert receive ether without buyTokens
	fallback() external {
		revert();
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

/**
* @title IGNITION Events Contract
* @author Luis Sanchez / Alfredo Lopez: PAID Network 2021.4
* @notice This contract include all events
*/
contract IgnitionEvents {

    event LogWhiteList(
        address indexed BaseAsset,
        uint8 indexed pool,
        bytes32 merkleRoot
    );

    event LogPoolToken(
        address indexed BaseAsset,
        uint8 indexed pool,
        address admin,
        address QuoteAsset,
        address indexed pplSuppAsset,
        uint256 startDate,
        uint256 endDate,
        uint256 rate,
        uint256 baseTier,
        uint256 pplAmount,
        uint256 sndAmount,
	    uint256 tokenTotalAmount, // Total of Token in the pool
	    uint256 maxRaiseAmount // Max Amount of (ETH/USDT/USDC) to Raise
    );

    event LogFinalize(
        address indexed BaseAsset,
        uint8 indexed pool,
        address indexed admin,
        address QuoteAsset,
        bool autoTranfer,
        uint8 nextpool,
        uint256 TransferAmount
    );

    event LogWithdrawRaisedFounds(
        address indexed BaseAsset,
        uint8 indexed pool,
        address indexed admin,
        address QuoteAsset,
        bool withdrawed,
        uint256 totalRaise
    );

    event LogwithdrawUnsoldTokens(
        address indexed BaseAsset,
        uint8 indexed pool,
        address indexed admin,
        address QuoteAsset,
        address toAccount,
        uint256 tokenTotalAmount,
        uint256 tokenRestAmount
    );

    event LogStartDatePool(
        address indexed BaseAsset,
        uint8 indexed pool,
        uint256 oldStartDate,
        uint256 newStartDate
    );

    event LogEndDatePool(
        address indexed BaseAsset,
        uint8 indexed pool,
        uint256 oldEndDate,
        uint256 newEndDate
    );

    event LogRatePool(
        address indexed BaseAsset,
        uint8 indexed pool,
        uint256 oldRate,
        uint256 newRate
    );

    event LogBaseTier(
        address indexed BaseAsset,
        uint8 pool,
        uint256 newbaseTier
    );

    event LogTokenTotalAmount(
        address indexed BaseAsset,
        uint8 indexed pool,
        uint256 oldTotalAmount,
        uint256 newTotalAmount
    );

    event LogAdminOnPoolToken(
        address indexed BaseAsset,
        uint8 indexed pool,
        address indexed oldAdmin,
        address newAdmin
    );

    event LogRedeemed(
        address indexed BaseAsset,
        uint8 indexed pool,
        address indexed wallet,
        bool whitelisted,
        bool redeemed,
        uint256 amount,
        uint256 rewardedAmount
    );

    event LogPrivAndAutoTxPool(
        address indexed BaseAsset,
        uint8 indexed pool,
        address indexed QuoteAsset,
        bool privatePool,
        bool autoTranfer,
        uint256 maxRaiseAmount // Max Amount of (ETH/USDT/USDC) to Raise
    );

    event LogQuoteAsset(
        address indexed BaseAsset,
        uint8 indexed pool,
        address indexed QuoteAsset,
        uint8 QuoteAssetDecimals,
        address admin,
        uint256 rate,
        uint256 tokenTotalAmount, // Total of Token in the pool
        uint256 maxRaiseAmount // Max Amount of (ETH/USDT/USDC) to Raise
    );

    event LogDisablePool(
        address indexed BaseAsset,
        uint8 indexed pool,
        address QuoteAsset,
        address indexed admin,
        uint256 soldAmount, // Tokens Sold
	    uint256 tokenTotalAmount, // Total of Token in the pool
	    uint256 totalRaise // Total of (ETH/USDT/USDC, etc) Raised
    );

    event LogBuyTokenETH(
        address indexed BaseAsset,
        uint8 indexed pool,
        address indexed buyer,
        uint256 value,
        uint256 rewardedAmount
    );

    event LogBuyTokensQuoteAsset(
        address indexed BaseAsset,
        uint8 indexed pool,
        address QuoteAsset,
        address indexed buyer,
        uint256 value,
        uint256 rewardedAmount
    );

    event LogPausePool(
        address indexed BaseAsset,
        uint8 indexed pool,
        bool indexed isPaused
    );

    event LogRevertFinalize(
        address indexed BaseAsset,
        uint8 indexed pool,
        address indexed admin,
        address QuoteAsset,
        bool autoTranfer,
        uint8 nextpool,
        uint256 TransferAmount
    );

    event LogRbacChange(
        string change, //added or removed
        address user
    );

    event LogSetProjectAdmin(
        address token,
        address admin
    );
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "./Data.sol";
import "./Math.sol";

/**
* @title Pool Library
* @author Luis Sanchez / Alfredo Lopez: PAID Network 2021.4
* @notice This contract include Struc and Matematics Method
*/
library LibPool {
	/**
	* Interface Struct for ERC20 Decimals
	*
	* @param {boolean active} Exist or not
	* @param {uint256 decimals} number of decimals that ERC20 have
	* @param {uint256} Amount rewarded based on the tier assign in th e Lottery of Ignition for this Pool of the IDO
	*/
	struct ERC20Decimals {
		bool active;
		uint256 decimals;
	}

	/**
	pools mapping
	IDO (Token Address)
		----> Pool Galaxy (uint256)
		----> Pool Moon (uint256)
		----> Pool .... (uint256)
		----> Pool n+1 (uint256)
	*/

	/**
	* Storage Strucs Data in a too efficiente way based on:
	* @notice https://medium.com/@novablitz/storing-structs-is-costing-you-gas-774da988895e
	* @dev Package Data Field (Details):
	* @param {address}: Base Asset of the project owner of the IDO
	* @param {uint32}: Start Date of the pool IDO
	* @param {uint32}: End Date of the IDO
	* @param {uint8}: Id the pool
	* @param {boolean}: withdrawed or not the Crown Sale (is when the Project Owner can withdraw the total coin raised in the Pool of the IDO)
	* @param {boolean}: finalized and Removed or not Rest of the Token (is when the Project Owner can withdraw or transfer Rest Amount of the Token to another address or pool)
	* @param {boolean}: paused/unpaused pool
	* @param {boolean}: Private Pool active/inactive
	* @param {boolean}: Auto Transfer Active / Inactive in the Pool
	* ================================================================================
	* @dev   Struct Pool Token Model
	* @param {bool active} Status Value, indicate if the Pool is Enable or Disable
	* @param {address quoteAsset} Address of address(0) for ETH, or Address of ERC20 for Stablecoin (eg. USDT, USDC, DAI, BUSD, etc) or Inclusive Wrapper ETH (WETH)
	* @param {uint256 packageData} Package Data Field, details above!
	* @param {uint256 rate} Rate of the BaseAsset according with the QuoteAsset selected for the Pool of the IDO
	* @param {uint256 baseTier} Base Value of the Tiers, and based on generete the all allocation in the Pool of the IDO, as multiples of this value
	* @param {uint256 paidAmount} Base Value for participate in the Pool of the IDO (Standard Value for Galaxy: 75K and Moon: 2K)
	* @param {uint256 soldAmount} Total Amount Sold in the Pool of the IDO
	* @param {uint256 tokenTotalAmount} Total Amount of Token enable in the Pool of the IDO
	* @param {uint256 totalRaise} Total Amount raised in the CrownSale in the Pool of the IDO, according the QuoteAsset
	* @param {uint256 maxRaiseAmount} Max Total Amount permitted (this value apply for Private Pool)
	*/
	struct PoolTokenModel {
		bool valid;
		address quoteAsset; // if the value is address(0) is ETH for}
		address pplSuppAsset; // Adddres of Main support asset of Pool
		address sndSuppAsset; // Adddres of secondary support asset of Pool\
		// packageData:
		// 0-159: Pool token address
		// 160-191: Start date timestamp (no miliseconds)
		// 192-223: End date timestamp (no miliseconds)
		// 224-231: uint8 of pool
		// 232: withdraw bit
		// 233: removed remaining amount of token bit
		// 234: paused pool bit
		// 235: private pool bit
		// 236: auto transfer pool bit
		uint256 packageData;
		uint256 rate; // rate pair comparison on ERC20 and pool token
		uint256 baseTier; // tier 1
		uint256 pplAmount; // Main Support Project Amount Limit for Participate in the Pool
		uint256 sndAmount; // Secondary Support Project Amount Limit for Participate in the Pool
		uint256 soldAmount; // Tokens Sold
		uint256 tokenTotalAmount; // Total of Token in the pool
		uint256 totalRaise; // Total of (ETH/USDT/USDC, etc) Raised
		uint256 maxRaiseAmount; // Max Amount of (ETH/USDT/USDC) to Raise
	}

	struct FallBackModel {
		uint256 fbck_finalize; // fallback finalize amount
		uint256 fbck_endDate; // fallback endDate timestamp
		address fbck_account; // fallback address account
	}

	/**
	* @notice generate package for libpool model
	* @dev Error IGN23 - Must be set Max Raised Amount more than Zero to enable Private Pool
    * @dev Error IGN24 - Private Pool Parameter only accept 1 or 0
    * @dev Error IGN25 - Auto Transfer Parameter only accept 1 or 0
	* @param _baseAddress baseToken address
	* @param _args pool args array
	*/
	function generatePackage(address _baseAddress, uint256[15] memory _args)
	internal pure returns (uint256) {
		uint256 _packageData = uint256(uint160(_baseAddress));
		// startDate
		_packageData |= _args[0]<<160;
		// endDate
		_packageData |= _args[1]<<192;
		// Pool
		_packageData |= _args[2]<<224;
		// withdrawed = false
		_packageData = Data.setPkgDtBoolean(_packageData, false, 232);
		// removed Rest Amount of Token (AKA finalized) = false
		_packageData = Data.setPkgDtBoolean(_packageData, false, 233);
		// paused = false
		_packageData = Data.setPkgDtBoolean(_packageData, false, 234);
		// Private Pool, true or false
		if (_args[9] == 1) {
			require(_args[8] > 0, "IGN23");
			_packageData = Data.setPkgDtBoolean(_packageData, true, 235);
		} else if (_args[9] == 0) {
			_packageData = Data.setPkgDtBoolean(_packageData, false, 235);
		} else {
			revert("IGN24");
		}
		// Auto Transfer, true or false
		if (_args[10] == 1) {
			_packageData = Data.setPkgDtBoolean(_packageData, true, 236);
		} else if (_args[10] == 0){
			_packageData = Data.setPkgDtBoolean(_packageData, false, 236);
		} else {
			revert("IGN25");
		}

		return _packageData;
	}

    /**
	* @dev Checks tokens decimal setting
	* @dev IGN47: Decimals is out ERC20 Standard
	* @return decimal correction
	*/
	function getDecimals(uint256 _decimals) internal pure returns (uint256) {
		if (_decimals == uint256(18)) {
			return uint256(1);
		} else if (_decimals < uint256(18)) {
			return 10**(uint256(18) - (_decimals - (uint(1))));
		} else {
			revert("IGN47");
		}
	}

	/**
	* @dev sets private pool flag in package data
	* @param self pool package data
	* @param value bool value to set
	*/
	function setPrivatePool(PoolTokenModel storage self, bool value) internal{
		self.packageData = Data.setPkgDtBoolean(
			self.packageData,
			value,
			235
		);
	}

	/**
	* @dev sets auto fix flag in package data
	* @param self pool package data
	* @param value bool value to set
	*/
	function setAutoFix(PoolTokenModel storage self, bool value) internal{
		self.packageData = Data.setPkgDtBoolean(
			self.packageData,
			value,
			236
		);
	}

	/**
	* @dev sets end date value in package data
	* @param self pool package data
	* @param _newEndDate date to set
	* @param _status_boolean counter to all status to set
	*/
	function setEndDate(
		PoolTokenModel storage self,
		uint256 _newEndDate,
		uint _status_boolean
	) internal {
		//address
		uint256 _packageData = uint256(uint160(self.packageData));
		//start date
		_packageData |= uint256(uint32(self.packageData>>160))<<160;
		//end date
		_packageData |= _newEndDate<<192;
		//pool
		_packageData |= uint256(uint8(self.packageData>>224))<<224;

		for (uint256 i = 0; i < _status_boolean; i++) {
			bool flag = Data.getPkgDtBoolean(self.packageData, 232+i);
            _packageData = Data.setPkgDtBoolean(_packageData, flag, 232+i);
        }

		self.packageData = _packageData;
	}

	/**
	* @dev sets end date value in package data
	* @param self pool package data
	* @param _newStartDate date to set
	* @param _status_boolean counter to all status to set
	*/
	function setStartDate(
		PoolTokenModel storage self,
		uint256 _newStartDate,
		uint _status_boolean
	) internal {

		//address
		uint256 _packageData = uint256(uint160(self.packageData));
		// startDate
		_packageData |= _newStartDate<<160;
		// endDate
		_packageData |= uint256(uint32(self.packageData>>192))<<192;
		// Pool
		_packageData |= uint256(uint8(self.packageData>>224))<<224;
        // for include all Status pool
        for (uint256 i = 0; i <= _status_boolean; i++) {
            bool flag = Data.getPkgDtBoolean(self.packageData, 232+i);
            _packageData = Data.setPkgDtBoolean(_packageData, flag, 232+i);
        }

		self.packageData = _packageData;
	}

	function setFinalized(PoolTokenModel storage self) internal {
		self.packageData = Data.setPkgDtBoolean(self.packageData,true,233);
	}

	/**
	* @notice check if pool is valid
	* @dev Error IGN38 - Invalid Pool
	* @param self pool package data
	*/
    function poolIsValid(PoolTokenModel storage self) internal view {
		require(self.valid, "IGN38");
    }

	/**
	* @notice isStatusPool for Pool Token Model Struct
	* @dev Boolen method to verify Several Status in this pool
	* @param self pool package data
	* @param _statusNumber Position of Boolean in the PackageData, isWithdrawed(232), isFinalized(233), isPaused(234), isPrivPool(235), isAutoTransfer(236)
	* @return a boolean value according to the value in the storage
	*/
	function _isStatusPool (PoolTokenModel storage self, uint _statusNumber)
	private view returns (bool) {
		poolIsValid(self);
		return Data.getPkgDtBoolean(self.packageData,_statusNumber);
	}

	/**
	* @param self pool package data
	* @return a boolean indicating if raised was withdrawed
	*/
	function isWithdrawed(PoolTokenModel storage self) internal view returns (bool) {
		return _isStatusPool(self, 232);
	}

	/**
	* @param self pool package data
	* @return a boolean indicating if pool is finalized
	*/
	function isFinalized(PoolTokenModel storage self) internal view returns (bool) {
		return _isStatusPool(self, 233);
	}

	/**
	* @param self pool package data
	* @return a boolean indicating if pool is paused
	*/
	function isPaused(PoolTokenModel storage self) internal view returns (bool) {
		return _isStatusPool(self, 234);
	}

	/**
	* @param self pool package data
	* @return a boolean indicating if pool is private
	*/
	function isPrivPool(PoolTokenModel storage self) internal view returns (bool) {
		return _isStatusPool(self, 235);
	}

	/**
	* @param self pool package data
	* @return a boolean indicating if pool has autotransfer
	*/
	function isAutoTransfer(PoolTokenModel storage self) internal view returns (bool) {
		return _isStatusPool(self, 236);
	}

	/**
	* @notice Get the Start Date of the Pool, in Unix Format (Epoch based on Block Timestamp of the blockchain)
	* @param self pool package data
	* @return Start Date of the Pool in Epoch Format
	*/
	function getStartDate(PoolTokenModel storage self) internal view returns (uint256) {
		poolIsValid(self);
		return uint256(uint32(self.packageData>>160));
	}

	/**
	* @notice Get the End Date of the Pool, in Unix Format (Epoch based on Block Timestamp of the blockchain)
	* @param self pool package data
	* @return End Date of the Pool in Epoch Format
	*/
	function getEndDate(PoolTokenModel storage self) internal view returns (uint256) {
		poolIsValid(self);
		return uint256(uint32(self.packageData>>192));
	}

	/**
	* @notice Is Crowd Sale Started
	* @notice This method allows to determine if the Crowd Sale has already been started or not
	* @param self pool package data
	* @return a boolean value according to the state of the Crowd Sale
	*/
	function isActive(PoolTokenModel storage self) internal view returns (bool) {
		return block.timestamp > getStartDate(self) &&
		block.timestamp < getEndDate(self);
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

/**
* @title IGNITION Events Contract
* @author Edgar Sucre
* @notice This Library holdls math helper functions
*/
library Math {
    /**
	* @dev MulDiv standard function to handle the recommended order in solidity to perform arithmetic operations of multiplication and division
	* @param x The multiplicand
	* @param y The multiplier
	* @param z The denominator
	* @return the 256 result
	*/
	function muldiv(uint256 x, uint256 y, uint256 z)
	internal pure returns (uint256)
	{
		return x * y / z;
	}

	/**
	* @dev Calculates ceil(a×b÷denominator)
	* @param a The multiplicand
	* @param b The multiplier
	* @param denominator The divisor
	* @return result The 256-bit result
	*/
	function mulDivRoundingUp(uint256 a, uint256 b, uint256 denominator)
	internal pure returns (uint256) {
		uint256 result = muldiv(a, b, denominator);
		if (mulmod(a, b, denominator) > 0) {
			require(result < type(uint256).max);
			result++;
		}
		return result / 1e1;
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
pragma solidity 0.8.5;

/**
* @title IGNITION Events Contract
* @author Edgar Sucre
* @notice This Library abstraction methods for package data
*/
library Data {
     /**
    * @dev Insert bitwise boolean into package
    * @param _packageData bit holder
    * @param _value boolean to insert
    * @param _boolNumber bit position in package
    */
    function setPkgDtBoolean(uint256 _packageData, bool _value, uint _boolNumber)
    internal pure returns (uint256)
    {
        uint256 packageData;
        if (_value) {
			packageData = _packageData | uint256(1)<<_boolNumber;
		} else {
			packageData = _packageData & ~(uint256(1)<<_boolNumber);
		}
        return packageData;
    }

    /**
    * @dev Retrieve bitwise boolean from package
    * @param _packageData bit holder
    * @param _boolNumber bit position in package
    */
    function getPkgDtBoolean(uint256 _packageData, uint _boolNumber)
    internal pure returns (bool)
    {
        return (((_packageData>>_boolNumber) & uint256(1)) == 1 ? true : false);
    }
}