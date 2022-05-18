// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import './EvexLiquidityPair.sol';
import './EvxToken.sol';
import './misc/WBNB/IWBNB.sol';

/**
 * @title Evex DEX contract
 */
contract EvexExchange is Ownable {
    // mapping of liquidity pairs, token addresses are sorted
    mapping (address => mapping(address => address)) public pairs;

    // address of the EVX token
    address public EVX;

    // address of the wrapped BNB contract
    address public WBNB;

    // swap fee rate for liquidity providers, 10000 = 100%
    uint256 public feeRateLP;

    // swap fee rate for burning by owner, 10000 = 100%
    uint256 public feeRateBurn;

    // swap fee rate for cashback in EVX tokens, 10000 = 100%
    uint256 public feeRateCashback;

    /**
     * Checks that value is greater than threshold
     * @param _value value to check
     * @param _threshold minimum threshold
     */
    modifier gt(uint256 _value, uint256 _threshold) {
        require(_value > _threshold, 'LESS_THAN_THRESHOLD');
        _;
    }

    /**
     * Checks that value is not a zero address
     * @param _value target address
     */
    modifier notZeroAddress(address _value) {
        require(_value != address(0), 'ZERO_ADDRESS');
        _;
    }

    /**
     * @notice Contract constructor
     * @param _WBNB address of the wrapped BNB contract
     * @param _EVX address of the EVX token contract
     * @param _feeRateLP fee rate for liquidity providers, 10000 = 100%
     * @param _feeRateBurn fee rate for burning by owner, 10000 = 100%
     * @param _feeRateCashback fee rate for cashback in EVX tokens, 10000 = 100%
     */
    constructor(
        address _WBNB,
        address _EVX,
        uint256 _feeRateLP,
        uint256 _feeRateBurn,
        uint256 _feeRateCashback
    ) 
    notZeroAddress(_WBNB) 
    notZeroAddress(_EVX) 
    gt(_feeRateLP, 0)
    {
        // assign variables
        WBNB = _WBNB;
        EVX = _EVX;
        feeRateLP = _feeRateLP;
        feeRateBurn = _feeRateBurn;
        feeRateCashback = _feeRateCashback;
    }

    //==================
    // Public methods
    //==================

    /**
     * @notice Adds liqudity (ERC20 <=> ERC20) to the pool
     * @param _tokenAddress0 1st token address
     * @param _tokenAddress1 2nd token address
     * @param _amountToken0 1st token amount to transfer
     * @param _amountToken1 2nd token amount to transfer
     */
    function addLiquidity(
        address _tokenAddress0,
        address _tokenAddress1,
        uint256 _amountToken0,
        uint256 _amountToken1
    ) 
    public 
    notZeroAddress(_tokenAddress0)
    notZeroAddress(_tokenAddress1)
    gt(_amountToken0, 0)
    gt(_amountToken1, 0)
    {
        // get pair
        EvexLiquidityPair pair = EvexLiquidityPair(_getPairAddress(_tokenAddress0, _tokenAddress1));
        // mint LP tokens to the user
        pair.mint(msg.sender, _amountToken0 * _amountToken1);
        // transfer tokens to the pool
        ERC20(_tokenAddress0).transferFrom(msg.sender, address(pair), _amountToken0);
        ERC20(_tokenAddress1).transferFrom(msg.sender, address(pair), _amountToken1);
    }

    /**
     * @notice Adds liquidity (BNB <=> ERC20) to the pool
     * @param _tokenAddress token address
     * @param _tokenAmount token amount
     */
    function addLiquidityBNB(
        address _tokenAddress,
        uint256 _tokenAmount
    ) 
    public 
    payable 
    notZeroAddress(_tokenAddress)
    gt(_tokenAmount, 0)
    gt(msg.value, 0)
    {
        // get pair
        EvexLiquidityPair pair = EvexLiquidityPair(_getPairAddress(_tokenAddress, WBNB));
        // mint LP tokens to the user
        pair.mint(msg.sender, _tokenAmount * msg.value);
        // transfer tokens to the pool
        ERC20(_tokenAddress).transferFrom(msg.sender, address(pair), _tokenAmount);
        // convert BNB to WBNB and transfer to the pool
        IWBNB(WBNB).deposit{value: msg.value}();
        IWBNB(WBNB).transfer(address(pair), msg.value);
    }

    /**
     * @notice Returns amount of tokens which user will get for selling input tokens
     * @param _tokenAddressIn sell token address
     * @param _tokenAmountIn sell token amount
     * @param _tokenAddressOut buy token address
     */
    function getTokenAmountOut(
        address _tokenAddressIn,
        uint256 _tokenAmountIn,
        address _tokenAddressOut
    ) 
    public 
    view 
    notZeroAddress(_tokenAddressIn)
    gt(_tokenAmountIn, 0)
    notZeroAddress(_tokenAddressOut)
    returns (uint256) {
        // get pair
        EvexLiquidityPair pair = EvexLiquidityPair(_getPairAddress(_tokenAddressIn, _tokenAddressOut));
        // apply fees to in token amount
        (uint256 feeAmountLP, uint256 feeAmountBurn, uint256 feeAmountCashback) = _getFees(_tokenAmountIn);
        uint256 _tokenAmountInWithAppliedFees = _tokenAmountIn - feeAmountLP - feeAmountBurn - feeAmountCashback;
        // get token out amount to send
        uint256 k = ERC20(_tokenAddressIn).balanceOf(address(pair)) * ERC20(_tokenAddressOut).balanceOf(address(pair));
        uint256 tokenAmountOut = k / (_tokenAmountInWithAppliedFees + ERC20(_tokenAddressIn).balanceOf(address(pair)));
        // ensure that pool is not completely depleted
        if (tokenAmountOut == ERC20(_tokenAddressOut).balanceOf(address(pair))) tokenAmountOut--;

        return tokenAmountOut;
    }

    /**
     * @notice Burns LP tokens and transfers pool tokens (ERC20 <=> ERC20) back to the user
     * @param _tokenAddress0 1st token address
     * @param _tokenAddress1 2nd token address
     * @param _lpTokensAmount amount of LP tokens to burn
     */
    function removeLiquidity(
        address _tokenAddress0,
        address _tokenAddress1,
        uint256 _lpTokensAmount
    ) 
    public 
    notZeroAddress(_tokenAddress0)
    notZeroAddress(_tokenAddress1)
    gt(_lpTokensAmount, 0)
    {
        // get pair
        EvexLiquidityPair pair = EvexLiquidityPair(_getPairAddress(_tokenAddress0, _tokenAddress1));
        // validation
        require(ERC20(address(pair)).balanceOf(msg.sender) >= _lpTokensAmount, 'NOT_ENOUGH_LP_TOKENS');
        // burn LP tokens
        pair.burn(msg.sender, _lpTokensAmount);
        // get token amounts to transfer
        uint256 tokenAmount0 = _lpTokensAmount * ERC20(pair.tokenAddress0()).balanceOf(address(pair)) / (ERC20(pair.tokenAddress0()).balanceOf(address(pair)) * ERC20(pair.tokenAddress1()).balanceOf(address(pair)));
        uint256 tokenAmount1 = _lpTokensAmount * ERC20(pair.tokenAddress1()).balanceOf(address(pair)) / (ERC20(pair.tokenAddress0()).balanceOf(address(pair)) * ERC20(pair.tokenAddress1()).balanceOf(address(pair)));
        // approve exchange to spend tokens from the pair address
        pair.approvePairTokenAmount(pair.tokenAddress0(), tokenAmount0);
        pair.approvePairTokenAmount(pair.tokenAddress1(), tokenAmount1);
        // transfer tokens to the user
        ERC20(pair.tokenAddress0()).transferFrom(address(pair), msg.sender, tokenAmount0);
        ERC20(pair.tokenAddress1()).transferFrom(address(pair), msg.sender, tokenAmount1);
    }

    /**
     * @notice Burns LP tokens and transfers pool tokens (ERC20 <=> BNB) back to the user
     * @param _tokenAddress token address
     * @param _lpTokensAmount amount of LP tokens to burn
     */
    function removeLiquidityBNB(
        address _tokenAddress,
        uint256 _lpTokensAmount
    ) 
    public 
    notZeroAddress(_tokenAddress)
    gt(_lpTokensAmount, 0)
    {
        // get pair
        EvexLiquidityPair pair = EvexLiquidityPair(_getPairAddress(_tokenAddress, WBNB));
        // validation
        require(ERC20(address(pair)).balanceOf(msg.sender) >= _lpTokensAmount, 'NOT_ENOUGH_LP_TOKENS');
        // burn LP tokens
        pair.burn(msg.sender, _lpTokensAmount);
        // get token amounts to transfer
        uint256 tokenAmount = (_lpTokensAmount * ERC20(_tokenAddress).balanceOf(address(pair))) / (ERC20(_tokenAddress).balanceOf(address(pair)) * ERC20(WBNB).balanceOf(address(pair)));
        uint256 bnbAmount = (_lpTokensAmount * ERC20(WBNB).balanceOf(address(pair))) / (ERC20(_tokenAddress).balanceOf(address(pair)) * ERC20(WBNB).balanceOf(address(pair)));
        // approve exchange to spend tokens from the pair address
        pair.approvePairTokenAmount(_tokenAddress, tokenAmount);
        pair.approvePairTokenAmount(WBNB, bnbAmount);
        // transfer ERC20 tokens to the user
        ERC20(_tokenAddress).transferFrom(address(pair), msg.sender, tokenAmount);
        // transfer WBNB to the user
        ERC20(WBNB).transferFrom(address(pair), msg.sender, bnbAmount);
    }

    /**
     * @notice Makes a swap (ERC20 => ERC20)
     * @param _tokenAddressIn token address to sell
     * @param _tokenAmountIn token amount to sell
     * @param _tokenAddressOut token address to buy
     */
    function swapERC20toERC20(
        address _tokenAddressIn,
        uint256 _tokenAmountIn,
        address _tokenAddressOut
    ) 
    public 
    notZeroAddress(_tokenAddressIn)
    gt(_tokenAmountIn, 0)
    notZeroAddress(_tokenAddressOut)
    {
        // get pair
        EvexLiquidityPair pair = EvexLiquidityPair(_getPairAddress(_tokenAddressIn, _tokenAddressOut));
        // get token out amount to send
        uint256 tokenAmountOut = getTokenAmountOut(_tokenAddressIn, _tokenAmountIn, _tokenAddressOut);
        // approve exchange to transfer pair tokens
        pair.approvePairTokenAmount(_tokenAddressOut, tokenAmountOut);
        // make a swap
        ERC20(_tokenAddressIn).transferFrom(msg.sender, address(pair), _tokenAmountIn);
        ERC20(_tokenAddressOut).transferFrom(address(pair), msg.sender, tokenAmountOut);
        // send fees
        _sendFees(_tokenAmountIn, address(pair));
    }

    /**
     * @notice Makes a swap (BNB => ERC20)
     * @param _tokenAddressOut token address to buy
     */
    function swapBNBtoERC20(
        address _tokenAddressOut
    ) 
    public 
    payable 
    notZeroAddress(_tokenAddressOut)
    gt(msg.value, 0)
    {
        // get pair
        EvexLiquidityPair pair = EvexLiquidityPair(_getPairAddress(WBNB, _tokenAddressOut));
        // get token out amount to send
        uint256 tokenAmountOut = getTokenAmountOut(WBNB, msg.value, _tokenAddressOut);
        // make a swap
        IWBNB(WBNB).deposit{value: msg.value}();
        ERC20(WBNB).transferFrom(msg.sender, address(pair), msg.value);
        ERC20(_tokenAddressOut).transferFrom(address(pair), msg.sender, tokenAmountOut);
        // send fees
        _sendFees(msg.value, address(pair));
    }

    /**
     * @notice Makes a swap (ERC20 => BNB)
     * @param _tokenAddressIn token address to sell
     * @param _tokenAmountIn token amount to sell
     */
    function swapERC20toBNB(
        address _tokenAddressIn,
        uint256 _tokenAmountIn
    ) 
    public 
    payable 
    notZeroAddress(_tokenAddressIn)
    gt(_tokenAmountIn, 0)
    {
        // get pair
        EvexLiquidityPair pair = EvexLiquidityPair(_getPairAddress(_tokenAddressIn, WBNB));
        // get token out amount to send
        uint256 tokenAmountOut = getTokenAmountOut(_tokenAddressIn, _tokenAmountIn, WBNB);
        // make a swap
        ERC20(_tokenAddressIn).transferFrom(msg.sender, address(pair), msg.value);
        ERC20(WBNB).transferFrom(address(pair), msg.sender, tokenAmountOut);
        IWBNB(WBNB).withdraw(tokenAmountOut);
        // send fees
        _sendFees(_tokenAmountIn, address(pair));
    }

    //=================
    // Owner methods
    //=================

    /**
     * @notice Creates a new liquidity pair
     * @param _tokenAddress0 1st token address
     * @param _tokenAddress1 2nd token address
     */
    function createPair(
        address _tokenAddress0, 
        address _tokenAddress1
    ) 
    public 
    onlyOwner 
    notZeroAddress(_tokenAddress0)
    notZeroAddress(_tokenAddress1)
    {
        // sort addresses
        (_tokenAddress0, _tokenAddress1) = _sortAddresses(_tokenAddress0, _tokenAddress1);
        // validation
        require(pairs[_tokenAddress0][_tokenAddress1] == address(0), 'LIQUIDITY_PAIR_EXIST');
        // create pair
        EvexLiquidityPair pair = new EvexLiquidityPair(_tokenAddress0, _tokenAddress1);
        pairs[_tokenAddress0][_tokenAddress1] = address(pair);
    }

    /**
     * @notice Updates swap fee rates
     * @param _newFeeRateLP updated LP fee rate, 10000 = 100%
     * @param _newFeeRateBurn updated burn by owner rate, 10000 = 100%
     * @param _newFeeRateCashback updated cashback in EVX tokens fee rate, 10000 = 100%
     */
    function updateFeeRates(
        uint256 _newFeeRateLP,
        uint256 _newFeeRateBurn,
        uint256 _newFeeRateCashback
    ) 
    public 
    onlyOwner 
    gt(_newFeeRateLP, 0)
    {
        // assign fee rates
        feeRateLP = _newFeeRateLP;
        feeRateBurn = _newFeeRateBurn;
        feeRateCashback = _newFeeRateCashback;
    }

    //====================
    // Internal methods
    //====================

    /**
     * @notice Returns all fees from input token amount
     * @param _tokenAmount token amount
     * @return fees 
     * Returns:
     * - swap fee for liquidity providers
     * - swap fee for burning by owner
     * - swap fee for cashback in EVX tokens
     */
    function _getFees(uint256 _tokenAmount) internal view returns(uint256, uint256, uint256) {
        return(
            // LP fee
            (_tokenAmount / 10000) * feeRateLP, 
            // burn by owner fee
            (_tokenAmount / 10000) * feeRateBurn,
            //  cashback fee
            (_tokenAmount / 10000) * feeRateCashback
        );
    }

    /**
     * @notice Returns pair address. Input token addresses can be in any order.
     * @param _tokenAddress0 1st token address
     * @param _tokenAddress1 2nd token address
     * @return pair address
     */
    function _getPairAddress(address _tokenAddress0, address _tokenAddress1) internal view returns(address) {
        // sort addresses
        (address _tokenAddressSorted0, address _tokenAddressSorted1) = _sortAddresses(_tokenAddress0, _tokenAddress1);
        // check that pair exists
        require(pairs[_tokenAddressSorted0][_tokenAddressSorted1] != address(0), 'LIQUIDITY_PAIR_NOT_EXIST');
        // return pair address
        return pairs[_tokenAddressSorted0][_tokenAddressSorted1];
    }

    /**
     * @notice Sends fees collected from swaps
     * @param _tokenAmountIn sell token amount
     * @param _pairAddress pair address
     */
    function _sendFees(
        uint256 _tokenAmountIn,
        address _pairAddress
    ) 
    internal 
    gt(_tokenAmountIn, 0)
    notZeroAddress(_pairAddress)
    {
        // get pair
        EvexLiquidityPair pair = EvexLiquidityPair(_pairAddress);
        // get fees
        (, uint256 feeAmountBurn, ) = _getFees(_tokenAmountIn);
        // approve exchange to spend fees
        pair.approvePairTokenAmount(pair.tokenAddress0(), feeAmountBurn);
        // send fees to burn
        ERC20(pair.tokenAddress0()).transferFrom(address(pair), EvxToken(EVX).burnAddress(), feeAmountBurn);
    }

    /**
     * @notice Sorts addresses in the ASC order
     * @param _tokenAddress0 1st token address
     * @param _tokenAddress1 2nd token address
     * @return sorted token addresses
     */
    function _sortAddresses(address _tokenAddress0, address _tokenAddress1) internal pure returns (address, address) {
        return _tokenAddress0 < _tokenAddress1 ? (_tokenAddress0, _tokenAddress1) : (_tokenAddress1, _tokenAddress0);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

/**
 * @title Basic token for Evex DEX
 */
contract EvxToken is ERC20, Ownable {
    // address which stores tokens that should be burned
    address public burnAddress;

    // initial token supply
    uint256 public initialSupply;

    // how many tokens were distributed for each token distribution target
    mapping (TokenDistributionTarget => uint256) public tokenDistributionTargetAmount;

    // capacity in % for each distribution target, ex: 100 = 1%
    mapping (TokenDistributionTarget => uint256) public tokenDistributionTargetCap;

    // whether token distribution target is set, can be set only once
    mapping (TokenDistributionTarget => bool) public tokenDistributionTargetIsSet;

    // Where tokens can be distributed (transfered)
    enum TokenDistributionTarget {
        IDO, // initial decentralized offering
        P2E, // play to earn
        TEAM, // team
        REFERRAL, // referral program
        LOCKED, // locked in the smart contract
        YIELD_FARMING, // yield farming
        STAKING, // staking
        MARKETING, // marketing and community
        SAFE_FUND // safe fund
    }

    /**
     * Contract constructor
     * @param _initialSupply initial token supply in wei
     * @param _tokenFullName token full name
     * @param _tokenTicker token ticker name
     * @param _burnAddress address where tokens to be burned should be stored
     */
    constructor(
        uint256 _initialSupply,
        string memory _tokenFullName,
        string memory _tokenTicker,
        address _burnAddress
    ) ERC20(_tokenFullName, _tokenTicker) {
        // validation
        require(_initialSupply > 0, 'EvxToken.constructor: initial supply can not be 0');
        // assign constructor variables
        initialSupply = _initialSupply * 10**decimals();
        burnAddress = _burnAddress;
        // mint initial supply to current contract address
        _mint(address(this), initialSupply);
    }

    //=================
    // Public methods
    //=================

    /**
     * @notice Checks whether owner can distribute tokens for the specified distribution target
     * Owner can distribute tokens for the following distribution targets:
     * - team
     * - locked amount of tokens
     * - marketing and community
     * - safe fund
     * @param _tokenDistributionTarget token distribution target
     * @return whether owner can distribute tokens for the specified target
     */
    function canBeDistributedByOwner(TokenDistributionTarget _tokenDistributionTarget) public pure returns (bool) {
        bool result = false;
        if (_tokenDistributionTarget == TokenDistributionTarget.TEAM ||
            _tokenDistributionTarget == TokenDistributionTarget.LOCKED ||
            _tokenDistributionTarget == TokenDistributionTarget.MARKETING ||
            _tokenDistributionTarget == TokenDistributionTarget.SAFE_FUND
        ) {
            result = true;
        }
        return result;
    }

    /**
     * @notice Returns max token amount for a specified distribution target which owner can spend
     * @param _tokenDistributionTarget for what purpose tokens are distributed
     * @return max token amount for distribution target which owner can spend
     */
    function getTokenDistributionTargetCapacityLimit(TokenDistributionTarget _tokenDistributionTarget) public view returns(uint256) {
        return (initialSupply / 10_000) * tokenDistributionTargetCap[_tokenDistributionTarget];
    }

    /**
     * @notice Returns current total supply of EVX token
     * @return Current total supply
     */
    function totalSupply () public view override returns (uint256) {
        return balanceOf(address(this));
    }

    //=================
    // Owner methods
    //=================

    /**
     * Send tokens from the burn address
     * @param _to address where tokens should be sent
     * @param _amount amount of tokens to send
     */
    function burnByOwner(address _to, uint256 _amount) public onlyOwner {
        // validation
        require(_amount <= balanceOf(burnAddress), 'EvxToken.burnByOwner: not enough tokens to burn');
        // allow owner to burn tokens
        _approve(burnAddress, owner(), balanceOf(burnAddress));
        // burn tokens
        transferFrom(burnAddress, _to, _amount);
    }

    /**
     * @notice Distributes tokens by owner
     * @param _to address where tokens should be distributed
     * @param _amount amount of tokens to be distributed
     * @param _tokenDistributionTarget for what purpose tokens are distributed
     */
    function distributeByOwner(address _to, uint256 _amount, TokenDistributionTarget _tokenDistributionTarget) public onlyOwner {
        // validation
        require(canBeDistributedByOwner(_tokenDistributionTarget), 'EvxToken.distributeByOwner(): owner can not distribute tokens for this target');
        // distribute tokens
        _distribute(_to, _amount, _tokenDistributionTarget);
    }

    /**
     * @notice Updates burn address
     * @param _newBurnAddress updated burn address
     */
    function updateBurnAddressByOwner(address _newBurnAddress) public onlyOwner {
        burnAddress = _newBurnAddress;
    }

    /**
     * @notice Sets token distribution target capacity. Can be set only once.
     * Ex: 100 = 1%
     * @param _tokenDistributionTarget token distribution target
     * @param _cap token capacity rate, 100 = 1%
     */
    function setTokenDistributionTargetCapacityByOwner(TokenDistributionTarget _tokenDistributionTarget, uint256 _cap) public onlyOwner {
        // validation
        require(!tokenDistributionTargetIsSet[_tokenDistributionTarget], 'EvxToken.setTokenDistributionTargetCapacityByOwner(): capacity already set for this target');
        require(
            tokenDistributionTargetCap[TokenDistributionTarget.IDO] + 
            tokenDistributionTargetCap[TokenDistributionTarget.P2E] + 
            tokenDistributionTargetCap[TokenDistributionTarget.TEAM] + 
            tokenDistributionTargetCap[TokenDistributionTarget.REFERRAL] + 
            tokenDistributionTargetCap[TokenDistributionTarget.LOCKED] +
            tokenDistributionTargetCap[TokenDistributionTarget.YIELD_FARMING] + 
            tokenDistributionTargetCap[TokenDistributionTarget.STAKING] +
            tokenDistributionTargetCap[TokenDistributionTarget.MARKETING] +
            tokenDistributionTargetCap[TokenDistributionTarget.SAFE_FUND] +
            _cap <= 10_000,
            'EvxToken.setTokenDistributionTargetCapacityByOwner(): total capacity should be <= 10000 (100%)'   
        );

        // set capacity
        tokenDistributionTargetCap[_tokenDistributionTarget] = _cap;
        tokenDistributionTargetIsSet[_tokenDistributionTarget] = true;

        // if owner is allowed to distribute tokens for the specified target
        if (canBeDistributedByOwner(_tokenDistributionTarget)) {
            // Add allowance from contract to owner.
            // Each new distribution target (where owner can spend tokends) adds a new allowance sum.
            uint256 newAllowance = allowance(address(this), owner()) + getTokenDistributionTargetCapacityLimit(_tokenDistributionTarget);
            _approve(address(this), owner(), newAllowance);
        }
    }

    //===================
    // Internal methods
    //===================

    /**
     * @notice Distributes tokens to address for a specified distribution target
     * @param _to address where tokens should be transfered
     * @param _amount amount of tokens to be tranfered
     * @param _tokenDistributionTarget token distribution target
     */
    function _distribute(address _to, uint256 _amount, TokenDistributionTarget _tokenDistributionTarget) internal {
        // validation
        require(_to != address(0), 'EvxToken._distribute(): _to can not be the zero address');
        require(_amount > 0, 'EvxToken._distribute(): _amount can not be 0');
        require(_amount <= balanceOf(address(this)), 'EvxToken._distribute(): contract does not have enough EVX tokens');
        uint tokenDistributionTargetCapacityLimit = getTokenDistributionTargetCapacityLimit(_tokenDistributionTarget);
        require(tokenDistributionTargetAmount[_tokenDistributionTarget] + _amount <= tokenDistributionTargetCapacityLimit, 'EvxToken._distribute(): capacity limit reached');
        // update distributed amount
        tokenDistributionTargetAmount[_tokenDistributionTarget] += _amount;
        // transfer tokens
        transferFrom(address(this), _to, _amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

/**
 * @title Contract for liquidity tokens 
 */
contract EvexLiquidityPair is ERC20, Ownable {
    // liquidity token addresses
    address public tokenAddress0;
    address public tokenAddress1;

    /**
     * @notice Contract constructor
     * @param _tokenAddress0 address of the 1st token in the liquidity pair pool
     * @param _tokenAddress1 address of the 2nd token in the liquidity pair pool
     */
    constructor(
        address _tokenAddress0,
        address _tokenAddress1
    ) ERC20('EVEX-LP', 'EVX-LP') {
        tokenAddress0 = _tokenAddress0;
        tokenAddress1 = _tokenAddress1;
    }

    //=================
    // Owner methods
    //=================

    /**
     * @notice Approves owner (exchange) to spend provided amount of tokens
     * @param _tokenAddress token address to approve
     * @param _tokenAmount 1st token amount to approve
     */
    function approvePairTokenAmount(
        address _tokenAddress,
        uint256 _tokenAmount
    ) public onlyOwner {
        require(tokenAddress0 == _tokenAddress || tokenAddress1 == _tokenAddress, 'NOT_POOL_TOKEN');
        ERC20(_tokenAddress).approve(owner(), _tokenAmount);
    }

    /**
     * @notice Burns LP tokens
     * @param account account to burn tokens from
     * @param amount amount of LP tokens to burn
     */
    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }

    /**
     * @notice Mints LP tokens
     * @param account account to mint tokens to
     * @param amount amount of LP tokens to mint
     */
    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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