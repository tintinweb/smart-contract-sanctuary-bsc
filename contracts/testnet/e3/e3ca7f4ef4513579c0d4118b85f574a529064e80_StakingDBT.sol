/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-10
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

interface IBEP20 {
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

    function decimals() external view returns (uint256);
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

/**
* @notice Contract is a inheritable smart contract that will add a 
* New modifier called onlyOwner available in the smart contract inherting it
* 
* onlyOwner makes a function only callable from the Token owner
*
*/
contract Ownable {
    // _owner is the owner of the Token
    address private _owner;

    /**
    * Event OwnershipTransferred is used to log that a ownership change of the token has occured
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * Modifier
    * We create our own function modifier called onlyOwner, it will Require the current owner to be 
    * the same as msg.sender
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: only owner can call this function");
        // This _; is not a TYPO, It is important for the compiler;
        _;
    }

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    /**
    * @notice owner() returns the currently assigned owner of the Token
    * 
     */
    function owner() public view returns(address) {
        return _owner;

    }
    /**
    * @notice renounceOwnership will set the owner to zero address
    * This will make the contract owner less, It will make ALL functions with
    * onlyOwner no longer callable.
    * There is no way of restoring the owner
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
    * @notice transferOwnership will assign the {newOwner} as owner
    *
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    /**
    * @notice _transferOwnership will assign the {newOwner} as owner
    *
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

/**
 * @notice Stakeable is a contract who is ment to be inherited by other contract that wants Staking capabilities
 */
contract StakingDBT is Ownable {
    IBEP20 private IBEP20Interface;
    AggregatorV3Interface internal priceFeed;
    address pairAddress;

    /**
     * @notice Constructor since this contract is not ment to be used without inheritance
     * push once to stakeholders for it to work proplerly
     */
    constructor(address _tokenAddress) {
        // This push is needed so we avoid index 0 causing bug of index-1
        IBEP20Interface = IBEP20(_tokenAddress);

        /**
         * Network: BSC
         * Aggregator: BNB/USD
         * Address (MainNet): 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
         * Address (TestNet): 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
         */
        priceFeed = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
        stakeholders.push();
    }

    struct Lottery {
        uint256 date;
    }

    /**
     * @notice Stakeholder is a staker that has active stakes
     */
    struct Stakeholder {
        address user;
        uint256 amount;
        uint256 token_tier_level;
        uint256 nft_level;
        uint256 tier_level;
        mapping(string => Lottery[]) lottery_history;
        uint256 cooldown_time;
    }

    /**
     * @notice
     * StakingSummary is a struct that is used to contain all stakes performed by a certain account
     */
    struct StakingSummary {
        uint256 total_amount;
        uint256 tier_level;
        uint256 cooldown_time;
        uint256 lottery_count;
    }

    struct TotalSummary {
        uint256 locked_amount;
        uint256 total_staker;
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
     * @notice Staked event is triggered whenever a user stakes tokens, address is indexed to make it filterable
     */

    event Staked(address indexed user, uint256 amount, uint256 timestamp);

    event Withdrawed(address indexed user, uint256 amount, uint256 timestamp);

    /**
     * @notice
      rewardPerHour is 1000 because it is used to represent 0.001, since we only use integer numbers
      This will give users 0.1% reward for each staked token / H
     */
    // uint256 internal rewardPerHour = 1000;

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
     * @notice _getTokenTierLevel calc token price and tier level
     */
    function _getTokenTierLevel(uint256 totalAmount) internal view returns (uint256){
        uint256 tierLevel;
        uint256 totalBNBPrice = getPrice(totalAmount);
        int totalPrice = getBNBPrice(totalBNBPrice);

        if (totalPrice > (750 * (10 ** 18))) {
            tierLevel = 3;
        } else if (totalPrice > (300 * (10 ** 18))) {
            tierLevel = 2;
        } else if (totalPrice > (150 * (10 ** 18))) {
            tierLevel = 1;
        } else {
            tierLevel = 0;
        }
        return tierLevel;
    }

    /**
     * @notice _getTierLevel calc tier system level
     */
    function _getTierLevel(uint256 token_tier_level, uint256 nft_level) internal pure returns (uint256){
        
        uint256 tierLevel;
        
        if (nft_level == 2 || token_tier_level > 2 || (token_tier_level > 0 && nft_level == 2)) {
            tierLevel = 3;
        } else if (token_tier_level > 1 || (token_tier_level > 0 && nft_level == 1)) {
            tierLevel = 2;
        } else if (token_tier_level > 0) {
            tierLevel = 1;
        } else {
            tierLevel = 0;
        }
        return tierLevel;
    }

    function setPairAddress(address _pairAddress) public {
        pairAddress = _pairAddress;
    }

    function getPrice(uint256 amount) public view returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (uint256 Res0, uint256 Res1, ) = pair.getReserves();
        return (amount * Res1 / Res0);
    }

    function getBNBPrice(uint256 amount) public view returns (int) {
        (
            ,
            int256 price,
            ,
            ,
            
        ) = priceFeed.latestRoundData();
        return price / (10 ** 8) * int(amount);
    }

    /**
     * @notice
     * _Stake is used to make a stake for an sender. It will remove the amount staked from the stakers account and place those tokens inside a stake container
     * StakeID
     */
    function _stake(uint256 _amount) public {
        // Simple check so that user does not stake 0
        require(_amount > 0, "Cannot stake nothing");

        uint256 amount = _amount * (10 ** IBEP20Interface.decimals());
        uint256 index = stakes[msg.sender];
        uint256 timestamp = block.timestamp;

        if (index == 0) {
            index = _addStakeholder(msg.sender);
        }

        stakeholders[index].amount = stakeholders[index].amount + amount;

        stakeholders[index].token_tier_level = _getTokenTierLevel(
            stakeholders[index].amount
        );
        
        uint tier_level  = _getTierLevel(
            stakeholders[index].token_tier_level,
            stakeholders[index].nft_level
        );

        if(tier_level == 3){
            stakeholders[index].cooldown_time = timestamp;
        } else if (stakeholders[index].tier_level == 1 && tier_level == 2) {
            if(stakeholders[index].cooldown_time > 0) {
                stakeholders[index].cooldown_time = stakeholders[index].cooldown_time - 15 days;
            }
        }

        stakeholders[index].tier_level = tier_level;

        // Emit an event that the stake has occured
        if (IBEP20Interface.transferFrom(msg.sender, address(this), amount)) {
            emit Staked(msg.sender, _amount, timestamp);
        } else {
            revert("Unable to transfer funds");
        }
    }

    function _updateNFTLevel(address staker, uint256 _NFTLevel) public onlyOwner {

        uint256 index = stakes[staker];

        if (index == 0) {
            index = _addStakeholder(staker);
        }

        stakeholders[index].nft_level = _NFTLevel;

        uint tier_level  = _getTierLevel(
            stakeholders[index].token_tier_level,
            stakeholders[index].nft_level
        );

        uint256 timestamp = block.timestamp;

        if(tier_level == 3){
            stakeholders[index].cooldown_time = timestamp;
        } else if (stakeholders[index].tier_level == 1 && tier_level == 2) {
            if(stakeholders[index].cooldown_time > 0) {
                stakeholders[index].cooldown_time = stakeholders[index].cooldown_time - 15 days;
            }
        }
        stakeholders[index].tier_level = tier_level;
    }

    function _attendLottery(string memory lottery_date) public {

        uint256 index = stakes[msg.sender];

        uint256 timestamp = block.timestamp;
        
        stakeholders[index].lottery_history[lottery_date].push(Lottery(timestamp));

        if(stakeholders[index].lottery_history[lottery_date].length == 1){
            if(stakeholders[index].tier_level == 1 ){
                stakeholders[index].cooldown_time = timestamp + 30 days;
            }else if(stakeholders[index].tier_level == 2){
                stakeholders[index].cooldown_time = timestamp + 15 days;
            }else {
                stakeholders[index].cooldown_time = timestamp;
            }
        }
    }

    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the acount
     * Will also calculateStakeReward and reset timer
     */
    function _withdrawStake(uint256 _amount) public {
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 index = stakes[msg.sender];
        uint256 amount = _amount * (10 ** IBEP20Interface.decimals());
        uint256 timestamp = block.timestamp;
        require(
            stakeholders[index].amount >= amount,
            "Staking: Cannot withdraw more than you have staked"
        );

        require(
            timestamp > stakeholders[index].cooldown_time,
            "Staking: Cannot withdraw in Lottery Cooldown time"
        );

        // Remove by subtracting the money unstaked

        stakeholders[index].amount = stakeholders[index].amount - amount;

        stakeholders[index].token_tier_level = _getTokenTierLevel(
            stakeholders[index].amount
        );
        
        uint tier_level  = _getTierLevel(
            stakeholders[index].token_tier_level,
            stakeholders[index].nft_level
        );

        if(tier_level == 3){
            stakeholders[index].cooldown_time = timestamp;
        } else if (stakeholders[index].tier_level == 1 && tier_level == 2) {
            if(stakeholders[index].cooldown_time > 0) {
                stakeholders[index].cooldown_time = stakeholders[index].cooldown_time - 15 days;
            }
        }

        stakeholders[index].tier_level = tier_level;

        if (IBEP20Interface.transfer(msg.sender, _amount)) {
            emit Withdrawed(msg.sender, _amount, timestamp);
        } else {
            revert("Unable to transfer funds");
        }
    }

    /**
     * @notice
     * hasStake is used to check if a account has stakes and the total amount along with all the seperate stakes
     */
    function hasStake(address _staker, string memory date) public view returns (StakingSummary memory)
    {
        uint256 index = stakes[_staker];
        StakingSummary memory summary = StakingSummary(0,0,0,0);
        if(index > 0){
            summary = StakingSummary(stakeholders[index].amount, stakeholders[index].tier_level, stakeholders[index].cooldown_time,stakeholders[index].lottery_history[date].length);
        }
        return summary;
    }

    
    function totalSummary() public view returns (TotalSummary memory)
    {
        uint256 totalStakeAmount; 

        TotalSummary memory summary = TotalSummary(0, stakeholders.length);
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            totalStakeAmount = totalStakeAmount+stakeholders[s].amount;
        }
        // Assign calculate amount to summary
        summary.locked_amount = totalStakeAmount;
        return summary;
    }
}