/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

/**
 *  DEX pancake Route interface
 */
interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

/**
 *  Original COntract PTD1 interface
 */
interface IPTD1 {
    function decimals() external view returns(uint8);
    function balanceOf(address account) external view returns(uint256);
    function transfer(address recipient, uint256 amount) external returns(bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

/*
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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract BuyPTD1 is Context, Ownable {
    address public usdtToken;
    address private addressContract;
    uint256 public dexTaxFee = 200; //take fee while sell token to dex
    uint256 public _initSupply = 0;
    //uint256 public _totalSupply = utilityContract.balanceOf(address(this));
    mapping(address => bool) public _isExcludedFromFee;

    /**
     * @notice
     * A stake struct is used to represent the way we store stakes, 
     * A Stake will contain the users address, the amount staked and a timestamp, 
     * Since which is when the stake was made
     */
    struct Stake{
        address user;
        uint256 amount;
        uint256 since;
        // This claimable field is new and used to tell how big of a reward is currently available
        uint256 claimable;
    }

    /**
     * @notice Stakeholder is a staker that has active stakes
     */
    struct Stakeholder{
        address user;
        Stake[] address_stakes;
    }

    /**
     * @notice
     * StakingSummary is a struct that is used to contain all stakes performed by a certain account
     */ 
    struct StakingSummary{
        uint256 total_amount;
        Stake[] stakes;
    }

    /**
     * @notice 
     *   This is a array where we store all Stakes that are performed on the Contract
     *   The stakes for each address are stored at a certain index, the index can be found using the stakes mapping
     */
    Stakeholder[] internal stakeholders;

    /**
     * @notice 
     * stakes is used to keep track of the INDEX for the stakers in the stakes array
     */
    mapping(address => uint256) internal stakes;

    /**
     * @notice
     * rewardPerHour is 11415525100000 because 1000 is used to represent 0.001, since we only use integer numbers
     * This will give users 0.00114155251% reward for each staked token / H
     * 1 Token = 1 USDT
     * hour = 60*60 = 3600 seconds
     * day = 3600*24 = 86400 seconds
     * year = 86400*365 = 31536000 seconds
     * for each 1 year 10% rewards
     * x = (31536000 * 100) / 10 = 315360000 seconds for 100%
     * x = (86400 * 100) / 315360000 = 0.0273972602739726% rewards for day
     * x = (1 * 100) / 315360000 = 0.00000031709791983765459% rewards for second
     * 0.00000031709791983765459 * 86400 = 0.0273972602739726% rewards for day
     * 0.0273972602739726% / 24h = 0.00114155251% rewards for hour
     * 0.0273972602739726 * 365 = 9.999999999999999% rewards for year.
     * 1 Token + 0.0273972602739726% rewards for day 0.000273972602739726 = 1.00027397260274 Tokens (USDT)
     * x = (100.02739726027397 * 1) / 100 = 1.000273972602739726 USDT for day, Total Token + rewards for day
     * 0.000273972602739726 USDT for day * 365 days = 0.1 USDT rewards for each 1 USDT for Year 
     * 0.000273972602739726 / 86400 = 0.0000000031709792
     * x = (1 second * 0.000273972602739726 USDT rewars for day) / 86400 seconds (1 day) = 0.0000000031709792 USDT rewars for second
     * 0.0000000031709792 * 10 ** 18 = 3170979200 Weis rewards for second for each Token (USDT)
     * x = (3600 seconds (1 hour) * 0.000273972602739726 USDT rewars for day) / 86400 seconds (1 day) = 0.0000114155251 USDT rewars for hour
     * 0.0000114155251 * 10 **18 = 11415525100000 Weis rewards for hour for each Token (USDT)
     */
    //uint256 internal rewardPerHour = 11415525100000; // 250000 - 0.025% | 8300000 - 0.0083% | 11415525100000 - 0.00114155251% | 3170979198 - 0.00000031709791983765459%
    uint256 internal rewardWeiPerSecond = 3170979200; // 250000 - 0.025% | 8300000 - 0.0083% | 11415525100000 - 0.00114155251% | 3170979198 - 0.00000031709791983765459%

    IPTD1 utilityContract;
    IPancakeRouter02 public immutable router;

    event Sold(address buyer, uint256 amount);

    /**
     * @notice Staked event is triggered whenever a user stakes tokens, address is indexed to make it filterable
     */
    event Staked(address indexed user, uint256 amount, uint256 index, uint256 timestamp);

    event WithdrawStaked(address indexed user, uint256 amount, uint256 amount_to_recive, uint256 stake_index, uint256 timestamp);

    constructor(address _addressContract) {
        // This push is needed so we avoid index 0 causing bug of index-1
        stakeholders.push();
        addressContract = _addressContract;
        utilityContract = IPTD1(_addressContract);
        router = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        usdtToken = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
        //stableCoin = IERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
        _isExcludedFromFee[owner()] = true;
    }

    function buy(uint256 _numTokens, address _addressContract) public payable {
        require(addressContract == _addressContract, "ERROR: The contract incorrect");
        uint256 scaledAmount = mul(_numTokens, uint256(10) ** utilityContract.decimals());
        // uint _numTokens = 1 PTD1 = 1 USDT || 1 PTD1/1 USDT
        //uint[] memory estimatedETH = router.getAmountsIn(scaledAmount, getPathForETHtoUSDT());
        uint256 _taxFee = 0;
        uint256 _weisPayFee = 0;
        uint256 scaledAmountFee = 0;
        //uint _price = estimatedETH[0];
        bool takeFee = true;
        if (_isExcludedFromFee[msg.sender]) {
            takeFee = false;
        }
        //if(takeFee) {
        //    _taxFee = mul(_price, dexTaxFee) / uint256(10000);
        //    _price = add(_price, _taxFee);
        //}
        if(takeFee) {
            _taxFee = mul(scaledAmount, dexTaxFee) / uint256(10000);
            scaledAmountFee = add(scaledAmount, _taxFee);
            _weisPayFee = router.getAmountsIn(scaledAmountFee, getPathForETHtoUSDT())[0];
            uint deadline = block.timestamp + 15; // using 'now' for convenience, for mainnet pass deadline from frontend!
            require(msg.value == _weisPayFee);
            router.swapETHForExactTokens{ value: msg.value }(scaledAmountFee, getPathForETHtoUSDT(), address(this), deadline);
        } else {
            uint _price = router.getAmountsIn(scaledAmount, getPathForETHtoUSDT())[0];
            require(msg.value == _price);
            uint deadline = block.timestamp + 15; // using 'now' for convenience, for mainnet pass deadline from frontend!
            router.swapETHForExactTokens{ value: msg.value }(scaledAmount, getPathForETHtoUSDT(), address(this), deadline);
        }
        //require(msg.value == _price);
        require(utilityContract.balanceOf(address(this)) >= scaledAmount);

        //uint deadline = block.timestamp + 15; // using 'now' for convenience, for mainnet pass deadline from frontend!
        //uint256[] memory amountsSwaped = router.swapETHForExactTokens{ value: msg.value }(scaledAmount, getPathForETHtoUSDT(), address(this), deadline);
        //require(amountsSwaped[0] == msg.value , "ERROR: Swap ETH for USDT");
        //router.swapETHForExactTokens{ value: msg.value }(scaledAmount, getPathForETHtoUSDT(), address(this), deadline);
        // refund leftover ETH to user
        //(bool success,) = msg.sender.call{ value: address(this).balance }("");
        //require(success, "refund failed");

        require(utilityContract.transfer(msg.sender, scaledAmount));
        //_totalSupply = utilityContract.balanceOf(address(this));
        emit Sold(msg.sender, _numTokens);

        stake(scaledAmount, msg.sender);
    }

    function endSold() public onlyOwner {
        require(utilityContract.transfer(owner(), utilityContract.balanceOf(address(this))));
        //_totalSupply = utilityContract.balanceOf(address(this));
        if(address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function getTotalSupply() public view returns (uint) {
        return utilityContract.balanceOf(address(this));
    }

    function getDividends(address _addressToken) public onlyOwner {
        uint256 tokensDividends = IERC20(_addressToken).balanceOf(address(this));
        if(tokensDividends > 0) {
            IERC20(_addressToken).transfer(msg.sender, tokensDividends);
        }
    }

    function getPathForETHtoUSDT() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = usdtToken;
        
        return path;
    }

    function getEstimatedETHforUSDT(uint usdtAmount) public view returns (uint[] memory) {
        return router.getAmountsIn(usdtAmount, getPathForETHtoUSDT());
    }

    function getEstimatedETHforBuyPTD1(uint _numTokens) public view returns (uint estimatedETH, uint256 _price, uint256 _taxFee, uint256 _taxFeeTokens, uint256 _totalTokensFee, uint256 _weisPayFee) {
        // uint _numTokens = 1 PTD1 = 1 USDT || 1 PTD1/1 USDT
        estimatedETH = router.getAmountsIn(_numTokens, getPathForETHtoUSDT())[0];
        _taxFee = 0;
        _taxFeeTokens = 0;
        _totalTokensFee = 0;
        _weisPayFee = 0;
        _price = estimatedETH;
        bool takeFee = true;
        if (_isExcludedFromFee[msg.sender]) {
            takeFee = false;
        }
        if(takeFee){
            _taxFee = mul(_price, dexTaxFee) / uint256(10000);
            _price = add(_price, _taxFee);
            _taxFeeTokens = mul(_numTokens, dexTaxFee) / uint256(10000);
            _totalTokensFee = add(_numTokens, _taxFeeTokens);
            _weisPayFee = router.getAmountsIn(_totalTokensFee, getPathForETHtoUSDT())[0];
        }
    }

    /**
     * Add functionality like burn to the _stake afunction
     *
     */
    function stake(uint256 _amount, address staker) private {
        // Make sure staker actually is good for it
        require(utilityContract.balanceOf(staker) >= _amount, "ERROR: Cannot stake more than you own");
        _stake(_amount);
    }

    /**
     * @notice _addStakeholder takes care of adding a stakeholder to the stakeholders array
     */
    function _addStakeholder(address staker) internal returns (uint256) {
        // Push a empty item to the Array to make space for our new stakeholder
        stakeholders.push();
        // Calculate the index of the last item in the array by Len-1
        uint256 userIndex = stakeholders.length - 1;
        // Assign the address to the new index
        stakeholders[userIndex].user = staker;
        // Add index to the stakeHolders
        stakes[staker] = userIndex;
        return userIndex; 
    }

    /**
     * @notice
     * _Stake is used to make a stake for an sender. It will remove the amount staked from the stakers account and place those tokens inside a stake container
     * StakeID 
     */
    function _stake(uint256 _amount) internal {
        // Simple check so that user does not stake 0 
        require(_amount > 0, "Cannot stake nothing");
        
        // Mappings in solidity creates all values, but empty, so we can just check the address
        uint256 index = stakes[msg.sender];
        // block.timestamp = timestamp of the current block in seconds since the epoch
        uint256 timestamp = block.timestamp;
        // See if the staker already has a staked index or if its the first time
        if(index == 0){
            // This stakeholder stakes for the first time
            // We need to add him to the stakeHolders and also map it into the Index of the stakes
            // The index returned will be the index of the stakeholder in the stakeholders array
            index = _addStakeholder(msg.sender);
        }

        // Use the index to push a new Stake
        // push a newly created Stake with the current block timestamp.
        stakeholders[index].address_stakes.push(Stake(msg.sender, _amount, timestamp,0));
        // Emit an event that the stake has occured
        emit Staked(msg.sender, _amount, index,timestamp);
    }

    /**
     * @notice
     * calculateStakeReward is used to calculate how much a user should be rewarded for their stakes
     * and the duration the stake has been active
     */
    function calculateStakeReward(Stake memory _current_stake) internal view returns(uint256) {
        // First calculate how long the stake has been active
        // Use current seconds since epoch - the seconds since epoch the stake was made
        // The output will be duration in SECONDS ,
        // We will reward the user 0.1% per Hour So thats 0.1% per 3600 seconds
        // the alghoritm is seconds = block.timestamp - stake seconds (block.timestap - _stake.since)
        // hours = Seconds / 3600 (seconds /3600) 3600 is an variable in Solidity names hours
        // we then multiply each token by the hours staked , then divide by the rewardPerHour rate 
        //return (((block.timestamp - _current_stake.since) / 1 hours) * _current_stake.amount) / rewardPerHour;
        //return ((block.timestamp - _current_stake.since) * rewardWeiPerSecond) * _current_stake.amount;
        uint256 scaled = mul(uint256(1), uint256(10) ** utilityContract.decimals());
        return mul(mul(sub(block.timestamp, _current_stake.since), rewardWeiPerSecond), div(_current_stake.amount, scaled));
    }

    /**
     * @notice withdrawStake is used to withdraw stakes from the account holder
     */
    function withdrawStake(uint256 amount, uint256 stake_index) public {
        uint256 amount_to_recive = _withdrawStake(amount, stake_index);
        // Return staked tokens to user
        //_mint(_msgSender(), amount_to_mint);
        if(amount_to_recive > 0) {
            // Emit an event that the stake has occured
            emit WithdrawStaked(msg.sender, amount, amount_to_recive, stake_index, block.timestamp);
        }
    }

    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the acount
     * Will also calculateStakeReward and reset timer
     */
    function _withdrawStake(uint256 amount, uint256 index) internal returns(uint256) {
        uint256 scaledAmount = mul(amount, uint256(10) ** utilityContract.decimals());
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[msg.sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[index];
        require(current_stake.amount >= scaledAmount, "Staking: Cannot withdraw more than you have staked");
        require((block.timestamp - current_stake.since) >= 1 hours, "ERROR: Only withdraw if passed 1 hour or plus of your tokens staked");

        // Calculate available Reward first before we start modifying data
        uint256 reward = calculateStakeReward(current_stake);
        // Remove by subtracting the money unstaked 
        current_stake.amount = sub(current_stake.amount, scaledAmount);
        // If stake is empty, 0, then remove it from the array of stakes
        if(current_stake.amount == 0){
            delete stakeholders[user_index].address_stakes[index];
        }else {
            // If not empty then replace the value of it
            stakeholders[user_index].address_stakes[index].amount = current_stake.amount;
            // Reset timer of stake
            stakeholders[user_index].address_stakes[index].since = block.timestamp;    
        }

        uint256 amount_to_recive = add(amount, reward);

        if(amount_to_recive > 0) {
            uint256 usdtDividends = IERC20(usdtToken).balanceOf(address(this));
            uint256 tokensDividends = utilityContract.balanceOf(address(this));
            require(usdtDividends >= amount_to_recive, "ERROR: The Contract not have sufficent funds");
            require(utilityContract.balanceOf(_msgSender()) >= scaledAmount, "ERROR: Your balance of Token is insufficent");
            require(utilityContract.approve(_msgSender(), scaledAmount), "ERROR: Approve for trasnferFrom your tokens to Contract");
            require(utilityContract.transferFrom(_msgSender(), address(this), scaledAmount), "ERROR: For trasnferFrom your tokens to Contract");
            require(utilityContract.balanceOf(address(this)) >= add(tokensDividends, scaledAmount), "ERROR: Not add tokens on to balance contract");
            require(IERC20(usdtToken).transfer(_msgSender(), amount_to_recive), "ERROR: For transfer USDT from contract to your address acount");
        }

        return amount_to_recive;
    }

    /**
     * @notice
     * hasStake is used to check if a account has stakes and the total amount along with all the seperate stakes
     */
    function hasStake(address _staker) public view returns(StakingSummary memory) {
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount; 
        // Keep a summary in memory since we need to calculate this
        StakingSummary memory summary = StakingSummary(0, stakeholders[stakes[_staker]].address_stakes);
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakes.length; s += 1){
           uint256 availableReward = calculateStakeReward(summary.stakes[s]);
           summary.stakes[s].claimable = availableReward;
           totalStakeAmount = totalStakeAmount+summary.stakes[s].amount;
       }
       // Assign calculate amount to summary
       summary.total_amount = totalStakeAmount;
        return summary;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setTax(uint256 _taxFee) public onlyOwner {
        dexTaxFee = _taxFee;
    }

    function setInitSupply(uint256 _newInitSupply) public onlyOwner {
        uint256 _OldInitSupply = _initSupply;
        if(_OldInitSupply == 0) {
            _initSupply = _newInitSupply;
            //_totalSupply = _newInitSupply;
        }
        /*if(_OldInitSupply > 0 && _OldInitSupply > _totalSupply) {
            uint256 _tokensStaked = sub(_OldInitSupply, _totalSupply);
            require(_newInitSupply > _tokensStaked, "ERROR: The new Supply is to less that tokens staked");
            _initSupply = _newInitSupply;
            //_totalSupply = sub(_newInitSupply, _tokensStaked);
        }*/
    }
    
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}