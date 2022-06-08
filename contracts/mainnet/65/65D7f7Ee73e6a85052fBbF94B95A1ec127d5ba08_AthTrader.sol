/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Link to bep20 token smart contract
interface IBEP20Token {
    // Transfer tokens on behalf
    function transferFrom(
      address from,
      address to,
      uint256 value
    ) external returns (bool success);
    
    // Transfer tokens
    function transfer(
      address to,
      uint256 value
    ) external returns (bool success);
    
    // Approve tokens for spending
    function approve(address spender, uint256 amount) external returns (bool);

    // Returns user balance
    function balanceOf(address user) external view returns(uint256 value);
}

// Link to AthSatking contract
interface IATHLEVEL {
    // Returns ath level of given address 
    function athLevel(address user) external view returns(uint256 level);
}

// Link to router contract 
interface IROUTER {
    // Swap tokens
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

// Link to pair contract
interface IPAIR {
    // Return token0 address of pair
    function token0() external view returns (address);

    // Return token1 address of pair    
    function token1() external view returns (address);
}

/**
 * @title AthenaBank trader contract Version 1.0
 *
 * @author AthenaBank
 */
contract AthTrader {
    // Address of AthTrader owner
    address public owner;

    // Address of AthStaking contract
    address public immutable athLevel;

    // Address of trader account
    address public trader;

    // Address of BinanaceAPI account
    address public binanceAPI;

    // Trader fee defined in percentage
    uint8 public traderFee;

    // Status of emergency withdraw
    bool public isEmergencyWithdrawlEnabled;

    // Address of participation token contract
    address public participationToken;

    // Funding start time defined in timestamp
    uint32 public fundingStartTime;

    // Funding period defined in seconds
    uint32 public fundingPeriod;

    // Trading period defined in seconds
    uint32 public tradingPeriod;

    // Benchmark for total funding amount 
    uint256 public fundingCap;

    // Minimum contribution required to participate in funding round
    uint256 public minContribution;

    // Total invested amount of participated token
    uint256 public totalInvestment;

    // Reward rate for calculating harvested amount
    uint256 public rewardRate;
    
    /**
     * @dev Returns fee in percentage for given level
     */
    mapping(uint8 => uint8) public athLevelFee;

    /**
     * @dev Returns true if given address is allowed for trading 
     */
    mapping(address => bool) public allowedV2PairsAndRouters;

    /**
     * @dev Returns invested amount for given address
     */
    mapping(address => uint256) public investedAmount;

    /**
	 * @dev Fired in transferOwnership() when ownership is transferred
	 *
	 * @param previousOwner an address of previous owner
	 * @param newOwner an address of new owner
	 */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
	 * @dev Fired in setBinanaceAPI() when API address is updated by an owner
	 *
	 * @param previousAPI an address of previous API
	 * @param newAPI an address of new API
	 */
    event UpdateAPI(address previousAPI, address newAPI);

    /**
	 * @dev Fired in addToAllowed() and removeFromAllowed() when address is added into/removed from
     *      allowedV2PairsAndRouters
	 *
	 * @param pairOrRouter an address of pair or router contract
	 * @param isAllowed defines if address is added or removed
	 */
    event Allowed(address pairOrRouter, bool isAllowed);

    /**
	 * @dev Fired in setAthLevelFee() when fee is set by an owner
	 *
	 * @param level index of level for which fee is set
	 * @param fee fee in percentage for given level
	 */
    event SetFee(uint8 level, uint8 fee);

    /**
	 * @dev Fired in recoverToken() when tokens are recovered by an owner
	 *
	 * @param token address of token to recover
	 * @param amount number of tokens to recover
	 */
    event Recover(address token, uint256 amount);

    /**
	 * @dev Fired in recoverContract() when contract value is recovered by an owner
	 *
	 * @param amount value of the contract recovered
	 */
    event RecoverValue(uint256 amount);

    /**
	 * @dev Fired in invest() when tokens are invested by user
	 *
	 * @param investor address of investor
	 * @param amount number of tokens invested
	 */
    event Investment(address indexed investor, uint256 amount);

    /**
	 * @dev Fired in withdraw() and emergencyWithdraw() when tokens are withdrawn by user
	 *
	 * @param investor address of an investor
	 * @param amount number of tokens withdrawn
     * @param isEmergencyWithdrawl true if fired in emergencyWithdraw()
	 */
    event WithdrawInvestment(address indexed investor, uint256 amount, bool isEmergencyWithdrawl);
    
    /**
	 * @dev Fired in swap() when tokens are swapped by a trader or binanceAPI 
	 *
	 * @param executor address of an executor
	 * @param router address of router
     * @param pair address of pair linked to given router
     * @param amountIn amount of input tokens to send
     * @param amountOutMin minimum amount of output tokens that must be received
     * @param deadline unix timestamp after which the transaction will revert  
     * @param flow direction of swap (from token0 to token1 -> "true", from token1 to token0 -> "false")
	 */
    event Swap(address indexed executor, address router, address pair, uint amountIn, uint amountOutMin, uint deadline, bool flow);
    
    /**
	 * @dev Fired in harvestReward() tokens are harvested by user
	 *
	 * @param investor address of an investor
	 * @param amount number of tokens harvested
     * @param fee number of tokens paid as fee 
	 */
    event Harvest(address indexed investor, uint256 amount, uint256 fee);

    /**
	 * @dev Creates/deploys AthenaBank trading contract Version 1.0
	 *
	 * @param athStaking_ address of AthStaking smart contract
	 */
    constructor(address athStaking_) {
        // Setup smart contract internal state
        owner = msg.sender;
        athLevel = athStaking_;
    }
    
    // To check if accessed by an owner
    modifier onlyOwner() {
        require(owner == msg.sender, "Not an owner");
        _;
    }

    // To check if accessed by a trader
    modifier onlyTrader() {
        require(trader == msg.sender, "Not a trader");
        _;
    }

    // To check if accessed by an owner or a tarder
    modifier traderOrOwner() {
        require(trader == msg.sender || owner == msg.sender, "Invalid access");
        _;
    }

    // To check if accessed by a trader or a binanceAPI
    modifier traderOrAPI() {
        require(trader == msg.sender || binanceAPI == msg.sender, "Invalid access");
        _;
    }

    /**
	 * @dev Transfer ownership to given address
	 *
	 * @notice restricted function, should be called by owner only
	 * @param newOwner_ address of new owner
	 */
    function transferOwnership(address newOwner_) external onlyOwner {
        // Update owner address
        owner = newOwner_;
    
        // Emit an event
        emit OwnershipTransferred(msg.sender, newOwner_);
    }

    /**
	 * @dev Initializes trading contract parameters
	 *
	 * @notice restricted function, should be called by owner only
	 * @param trader_ address of a trader
     * @param startTime_ unix timestamp after which funding period will start
     * @param fundingPeriodInSeconds_ funding period defined in seconds
     * @param tradingPeriodInSeconds_ trading period defined in seconds
     * @param participationToken_ address of participation token contract
     * @param traderFee_ trader fee defined in terms of percentage
     * @param fundingCap_ benchmark for token amount to be raised 
     * @param minContribution_ minimum contribution required to participate in funding round
	 */
    function initializeRound(
        address trader_,
        uint32 startTime_,
        uint32 fundingPeriodInSeconds_,
        uint32 tradingPeriodInSeconds_,
        address participationToken_,
        uint8 traderFee_,
        uint256 fundingCap_,
        uint256 minContribution_
    ) external onlyOwner {
        
        require(fundingStartTime == 0, "Active round");

        // Setup smart contract internal state
        trader = trader_;
        fundingStartTime = startTime_;
        fundingPeriod = fundingPeriodInSeconds_;
        tradingPeriod = tradingPeriodInSeconds_;
        traderFee = traderFee_;
        participationToken = participationToken_;
        fundingCap = fundingCap_;
        minContribution = minContribution_;
    }

    /**
	 * @dev Sets binanceAPI address
	 *
	 * @notice restricted function, should be called by owner only
	 * @param api_ address of binanace API account
	 */
    function setBinanceAPI(address api_) external onlyOwner {
        // Emit an event
        emit UpdateAPI(binanceAPI, api_);
        
        // Update API
        binanceAPI = api_;
    }

    /**
	 * @dev Adds router/pair address to allowed list 
	 *
	 * @notice restricted function, should be called by owner only
	 * @param allowed_ address list of router/pair
	 */
    function addToAllowed(address[] memory allowed_) external onlyOwner {
        for(uint8 i; i < allowed_.length; i++) {
            // Add address to the list
            allowedV2PairsAndRouters[allowed_[i]] = true;

            // Emit an event
            emit Allowed(allowed_[i], true);
        }
    }

    /**
	 * @dev Removes router/pair address from allowed list 
	 *
	 * @notice restricted function, should be called by owner only
	 * @param notAllowed_ address of router/pair
	 */
    function removeFromAllowed(address[] memory notAllowed_) external onlyOwner {
        for(uint8 i; i < notAllowed_.length; i++) {
            // Remove address from the list
            allowedV2PairsAndRouters[notAllowed_[i]] = false;

            // Emit an event
            emit Allowed(notAllowed_[i], false);
        }
    }

    /**
	 * @dev Enables/disables emergency withdraw  
	 *
	 * @notice restricted function, should be called by owner only
	 */
    function emergencyWithdrawSwitch() external onlyOwner {
        // Trigger emergency withdraw switch
        isEmergencyWithdrawlEnabled = !isEmergencyWithdrawlEnabled;
    }

    /**
	 * @dev Sets fee for given level 
	 *
	 * @notice restricted function, should be called by owner only
	 * @param level_ index of level
     * @param fee_ fee defined in percentage for given level
	 */
    function setAthLevelFee(
        uint8[] memory level_,
        uint8[] memory fee_
    ) external onlyOwner {
        require(level_.length == fee_.length, "Invalid input");

        for(uint8 i; i < level_.length; i++) {
            // Record fee for given level
            athLevelFee[level_[i]] = fee_[i];
            
            // Emit an event
            emit SetFee(level_[i], fee_[i]);
        }
    }

    /**
	 * @dev Recovers tokens from the contract  
	 *
	 * @notice restricted function, should be called by owner only
	 * @param token_ address of token to recover
     * @param amount_ number of tokens to recover
	 */
    function recoverToken(address token_, uint256 amount_) external onlyOwner {
        // Transfer tokens to the owner
        IBEP20Token(token_).transfer(msg.sender, amount_);

        // Emit an event
        emit Recover(token_, amount_);
    }

    /**
	 * @dev Recovers value from the contract  
	 *
	 * @notice restricted function, should be called by owner only
	 */
    function recoverContract() external onlyOwner {
        // Contract value to send
		uint256 _value = address(this).balance;

		// Verify balance is positive (non-zero)
		require(_value > 0, "zero balance");

        // Transfer value to the owner
        payable(msg.sender).transfer(_value);

        // Emit an event
        emit RecoverValue(_value);
    }

    /**
	 * @dev Returns true if funding is active  
	 */
    function isFundingActive() public view returns(bool) {
        return (block.timestamp >= fundingStartTime) &&
            (block.timestamp < fundingStartTime + fundingPeriod); 
    }

    /**
	 * @dev Returns true if trading is active  
	 */
    function isTradingActive() public view returns(bool) {
        return (block.timestamp >= fundingStartTime + fundingPeriod) &&
            (block.timestamp < fundingStartTime + fundingPeriod + tradingPeriod) &&
            totalInvestment >= fundingCap; 
    }

    /**
	 * @dev Returns true if claiming reward is active  
	 */
    function isRewardActive() public view returns(bool) {
        return (block.timestamp > fundingStartTime + fundingPeriod + tradingPeriod) &&
            totalInvestment >= fundingCap; 
    }

    /**
	 * @dev Returns true if funding is active for given level
     *
     * @param level_ index of level
	 */
    function isFundingActiveForAthLevel(uint8 level_) public view returns(bool) {
        uint256 lockPeriod = fundingPeriod / 4;

        if (level_ == 0) {
            return (block.timestamp >= fundingStartTime + (lockPeriod * 3));
        } else if (level_ == 1) {
            return (block.timestamp >= fundingStartTime + (lockPeriod * 2));
        } else if (level_ == 2) {
            return (block.timestamp >= fundingStartTime + lockPeriod);
        } else if (level_ == 3) {
            return (block.timestamp >= fundingStartTime);
        } else {
            return false;
        }
    } 

    /**
	 * @dev Invests participation tokens to the contract
     *
     * @param amount_ number of tokens to invest
	 */
    function invest(uint256 amount_) external {
        require(investedAmount[msg.sender] + amount_ >= minContribution, "Invalid amount");
        
        require(isFundingActive(), "Inactive funding");

        // Get level index
        uint8 _level = uint8(IATHLEVEL(athLevel).athLevel(msg.sender));
        
        require(isFundingActiveForAthLevel(_level), "Inactive for level");        

        // Transfer tokens to AthTrader contract
        IBEP20Token(participationToken).transferFrom(msg.sender, address(this), amount_);

        // Record invested amount of given address 
        investedAmount[msg.sender] += amount_;

        // Record total investment amount
        totalInvestment += amount_;

        // Emit an event
        emit Investment(msg.sender, amount_);
    }

    /**
	 * @dev Allows to withdraw invested tokens if emergency withdraw is enabled by an owner
     */
    function emergencyWithdraw() external {
        require(isEmergencyWithdrawlEnabled, "Withdrawl disabled");

        // Get invested amount of given address
        uint256 _amount = investedAmount[msg.sender];

        // Transfer invested amount to given address
        IBEP20Token(participationToken).transfer(msg.sender, _amount);

        // Remove invested amount data for given address
        delete investedAmount[msg.sender];

        // Emit an event
        emit WithdrawInvestment(msg.sender, _amount, true);
    }

    /**
	 * @dev Allows to withdraw invested tokens if funding cap is not reached at the end of funding period
     */
    function withdraw() external {
        require(
            (block.timestamp >= fundingStartTime + fundingPeriod) && (totalInvestment < fundingCap),
            "Withdrawl disabled"
        );
	
	require(investedAmount[msg.sender] > 0, "No investment");

        // Get invested amount of given address
        uint256 _amount = investedAmount[msg.sender];

        // Transfer invested amount to given address
        IBEP20Token(participationToken).transfer(msg.sender, _amount);

        // Remove invested amount data for given address
        delete investedAmount[msg.sender];

        // Emit an event
        emit WithdrawInvestment(msg.sender, _amount, false);
    }

    /**
	 * @dev Ends funding period earlier if funding cap is reached
     * 
     * @notice restricted function, should be called by owner only
     */
    function concludeFundingPeriod() external onlyOwner {
        require(isFundingActive(), "Inactive funding");

        require(totalInvestment >= fundingCap, "Cap not reached");

        // Decrease funding period time
        fundingPeriod = uint32(block.timestamp - fundingStartTime);
    }

    /**
	 * @dev Swaps tokens invested in contract
     * 
     * @notice restricted function, should be called by trader or API only
     * @param router_ address of router
     * @param pair_ address of pair linked to given router
     * @param amountIn_ amount of input tokens to send
     * @param amountOutMin_ minimum amount of output tokens that must be received
     * @param deadline_ unix timestamp after which the transaction will revert  
     * @param flow_ direction of swap (from token0 to token1 -> "true", from token1 to token0 -> "false")
     */
    function swap(
        address router_,
        address pair_,
        uint amountIn_,
        uint amountOutMin_,
        uint deadline_,
        bool flow_           
    ) public traderOrAPI {
        require(isTradingActive(), "Inactive trading");

        require(allowedV2PairsAndRouters[router_] && allowedV2PairsAndRouters[pair_], "Invalid address");

        // Get token0 address from given pair
        address _token0 = IPAIR(pair_).token0();
        
        // Get token1 address from given pair
        address _token1 = IPAIR(pair_).token1();
        
        // Define path
        address[] memory _path = new address[](2);
        
        // Record addresses to the path
        if(flow_) {
            _path[0] = _token0;
            _path[1] = _token1;
        } else {
            _path[0] = _token1;
            _path[1] = _token0;
        }

        // Approve input tokens to router
        IBEP20Token(_path[0]).approve(router_, amountIn_);

        // Execute swap function of given router
        IROUTER(router_).swapExactTokensForTokens(amountIn_, amountOutMin_, _path, address(this), deadline_);

        // Emit an event
        emit Swap(msg.sender, router_, pair_, amountIn_, amountOutMin_, deadline_, flow_);
    }

    /**
	 * @dev Swaps tokens in batch invested in contract
     * 
     * @notice restricted function, should be called by trader or API only
     * @param router_ address of router
     * @param pair_ address of pair linked to given router
     * @param amountIn_ amount of input tokens to send
     * @param amountOutMin_ minimum amount of output tokens that must be received
     * @param deadline_ unix timestamp after which the transaction will revert  
     * @param flow_ direction of swap (from token0 to token1 -> "true", from token1 to token0 -> "false")
     */
    function swapBatch(
        address[] memory router_,
        address[] memory pair_,
        uint[] memory amountIn_,
        uint[] memory amountOutMin_,
        uint deadline_,
        bool[] memory flow_           
    ) external {
        for(uint i; i < router_.length; i++) {
            swap(router_[i], pair_[i], amountIn_[i], amountOutMin_[i], deadline_, flow_[i]);
        }
    }

    /**
	 * @dev Ends trading period earlier
     * 
     * @notice restricted function, should be called by owner or trader only
     */
    function concludeTradingPeriod() external traderOrOwner {
        require(isTradingActive(), "Inactive trading");

        // Decrease trading period time
        tradingPeriod = uint32(block.timestamp - (fundingStartTime + fundingPeriod));
    }

    /**
	 * @dev Harvests rewards after trading period gets over
     */
    function harvestReward() external {
        require(isRewardActive(), "Inactive reward");
	
	require(investedAmount[msg.sender] > 0, "No investment");
	
        // Check if reward rate is set
        if(rewardRate == 0) {
            // Set reward rate based on participation token balance
            rewardRate = (IBEP20Token(participationToken).balanceOf(address(this)) * 1e9) / totalInvestment;
        }

        // Calculate reward amount
        uint256 _rewardAmount = investedAmount[msg.sender] * rewardRate / 1e9;

        // Calculate fee on profitable amount
        uint256 _fee = (_rewardAmount <= investedAmount[msg.sender]) ? 0 
                        : calculateFee(_rewardAmount - investedAmount[msg.sender]);

        // Transfer harvested amount to given address
        IBEP20Token(participationToken).transfer(msg.sender, _rewardAmount - _fee);

        // Check if fee is non zero
        if(_fee > 0) {
            // Calculate trader fee
            uint256 _traderFee = (_fee * traderFee) / 100;

            // Transfer owner share to owner account
            IBEP20Token(participationToken).transfer(owner, _fee - _traderFee);

            // Transfer trader fee to trader account
            IBEP20Token(participationToken).transfer(trader, _traderFee);
        }

        // Remove invested amount data for given address
        delete investedAmount[msg.sender];

        // Emit an event
        emit Harvest(msg.sender, _rewardAmount, _fee);
    }

    /**
	 * @dev Returns fee on surplus amount
     *
     * @param surPlus_ surplus amount of participation tokens
     */
    function calculateFee(uint256 surPlus_) internal view returns(uint256) {
        return (athLevelFee[uint8(IATHLEVEL(athLevel).athLevel(msg.sender))] * surPlus_) / 100;
    }
}