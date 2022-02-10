/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

//SPDX-License-Identifier: GPL-3.0+

pragma solidity 0.8.0;

contract GoToken
{
    function approve(address, uint256) external returns (bool) {}
    function balanceOf(address) external view returns (uint256) {}
}

contract EshareToken
{
    function approve(address, uint256) external returns (bool) {}
    function balanceOf(address) external view returns (uint256) {}
}

contract EmpToken
{
    function approve(address, uint256) external returns (bool) {}
    function balanceOf(address) external view returns (uint256) {}
}

contract BusdToken
{
    function approve(address, uint256) external returns (bool) {}
    function balanceOf(address) external view returns (uint256) {}
    function transfer(address, uint256) external returns (bool) {}
    function transferFrom(address, address, uint256) external returns (bool) {}
}

contract PancakeSwapRouter
{
    function swapExactTokensForTokens(
                 uint,
                 uint,
                 address[] calldata,
                 address,
                 uint
             ) external virtual returns (uint[] memory) {}
}

contract GoFarm
{
    function donate(uint256) external {}
}

contract Boardroom
{
    function stake(uint256) public {}
 	function claimReward() public {}
}

contract Ginko
{
    struct UserData 
    { 
        uint256 stakingDeposit;
        uint256 stakingBlock;
    }
    
    string  private _name = "\x47\x69\x6e\x6b\xc5\x8d";
    uint256 private _swapWaitingSeconds = 3600;
    uint256 private _depositFee = 10; //Deposit fee: 10%
    uint256 private _performanceFee = 1; //Performance fee: 1%
    uint256 private _autoCompoundFee = 33; //Auto-compound fee: 33%
    uint256 private _harvestCooldownBlocks = 28800;
    uint256 private _stakingBlockRange = 864000;
    uint256 private _decimalFixMultiplier = 1000000000000000000;
    uint256 private _updateCooldownBlocks = 21600;

    uint256 private _lastUpdate;
    uint256 private _totalStakingDeposits;
    
    mapping(address => UserData) private _userData;
    
    address private _goTokenAddress = 0x1D296721f12af38d35F1663113373D98CCC96635;
    address private _eshareTokenAddress = 0xDB20F6A8665432CE895D724b417f77EcAC956550;
    address private _empTokenAddress = 0x3b248CEfA87F836a4e6f6d6c9b42991b88Dc1d58;
    address private _busdTokenAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private _bnbTokenAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private _pancakeSwapRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private _goFarmAddress = 0xaaAa30ebf45fA0996fdbe000824A919B57a4cBF4;
    address private _boardroomAddress = 0xE9BAcEEA645E8bE68a0b63b9764670f97a50942F;
        
    GoToken           private _goToken;
    EshareToken       private _eshareToken;
    EmpToken          private _empToken;
    BusdToken         private _busdToken;
    PancakeSwapRouter private _pancakeSwapRouter;
    GoFarm            private _goFarm;
    Boardroom         private _boardroom;
    
    address[] private _busdEsharePair;
    address[] private _empGoPair;
    address[] private _empBusdPair;
    address[] private _empEsharePair;    
    
    constructor()
    {
        //Initialize contracts
        _goToken           = GoToken(_goTokenAddress);
        _eshareToken       = EshareToken(_eshareTokenAddress);
        _empToken          = EmpToken(_empTokenAddress);
        _busdToken         = BusdToken(_busdTokenAddress);
        _pancakeSwapRouter = PancakeSwapRouter(_pancakeSwapRouterAddress);
        _goFarm            = GoFarm(_goFarmAddress);
        _boardroom         = Boardroom(_boardroomAddress);
        
        //Initialize trading pairs
        _busdEsharePair = [_busdTokenAddress, _bnbTokenAddress, _eshareTokenAddress];
        _empGoPair      = [_empTokenAddress,  _bnbTokenAddress, _goTokenAddress];
        _empBusdPair    = [_empTokenAddress,  _bnbTokenAddress, _busdTokenAddress];
        _empEsharePair  = [_empTokenAddress,  _bnbTokenAddress, _eshareTokenAddress];        
    }
    
    function getName() external view returns (string memory)
    {
        return _name;
    }
    
    function getRewardsFund() public view returns (uint256)
    {
        return _busdToken.balanceOf(address(this)) - _totalStakingDeposits;
    }
    
    function getTotalStakingDeposits() external view returns (uint256)
    {
        return _totalStakingDeposits;
    }
    
    function getDepositFee() external view returns (uint256)
    {
        return _depositFee;
    }
    
    function getHarvestCooldownBlocks() external view returns (uint256)
    {
        return _harvestCooldownBlocks;
    }
    
    function getStakingBlockRange() external view returns (uint256)
    {
        return _stakingBlockRange;
    } 
    
    function buyGoToken(uint256 empAmount) private
    {
        require(empAmount > 0, "Ginko: Emp amount cannot be 0");
    
        address[] memory empGoPairMemory = _empGoPair;
        
        //Swap Emp for Gō
        _empToken.approve(_pancakeSwapRouterAddress, empAmount);
        _pancakeSwapRouter.swapExactTokensForTokens(empAmount, 0, empGoPairMemory, address(this), block.timestamp + _swapWaitingSeconds);
        
        //Donate to Gō farm
        uint256 goAmount = _goToken.balanceOf(address(this));
        
        if (goAmount > 0)
        {
            _goToken.approve(_goFarmAddress, goAmount);
            _goFarm.donate(goAmount);
        }
    }
    
    function updateRewardsFund() private
    {
        uint256 elapsedBlocks = block.number - _lastUpdate;
    
        if (elapsedBlocks > _updateCooldownBlocks)
        {
            address[] memory empBusdPairMemory = _empBusdPair;
			address[] memory empEsharePairMemory = _empEsharePair;            
                
            //Harvest pending Emp
            _boardroom.claimReward();
            
            uint256 empAmount = _empToken.balanceOf(address(this));
            
            uint256 performanceFeeAmount = empAmount * _performanceFee / 100;
            uint256 autoCompoundFeeAmount = empAmount * _autoCompoundFee / 100;
            
            //Buy Gō and donate it to Gō farm
            if (performanceFeeAmount > 0)
                buyGoToken(performanceFeeAmount);
                
            //Auto-compound
            if (autoCompoundFeeAmount > 0)
            {
            	//Swap Emp for Eshare
                _empToken.approve(_pancakeSwapRouterAddress, autoCompoundFeeAmount);
                _pancakeSwapRouter.swapExactTokensForTokens(autoCompoundFeeAmount, 0, empEsharePairMemory, address(this), block.timestamp + _swapWaitingSeconds);
            
               	uint256 eshareAmount = _eshareToken.balanceOf(address(this));
                
                _eshareToken.approve(_boardroomAddress, eshareAmount);
                _boardroom.stake(eshareAmount);
            }
            
            //Swap Emp for BUSD
            empAmount = _empToken.balanceOf(address(this));
            
            if (empAmount > 0)
            {
                _empToken.approve(_pancakeSwapRouterAddress, empAmount);
                _pancakeSwapRouter.swapExactTokensForTokens(empAmount, 0, empBusdPairMemory, address(this), block.timestamp + _swapWaitingSeconds);
            }
            
            _lastUpdate = block.number;
        }
    }
    
    function deposit(uint256 amount) external 
    {
        require(amount >= 100, "Ginko: minimum deposit amount: 100");
        
        _busdToken.transferFrom(msg.sender, address(this), amount);
        
        uint256 fee = amount * _depositFee / 100;
        uint256 netAmount = amount - fee;
        
        //Update user data
        _userData[msg.sender].stakingDeposit += netAmount;
        _userData[msg.sender].stakingBlock = block.number;
        
        _totalStakingDeposits += netAmount;
        
        //Swap deposit fee for Eshare
        address[] memory busdEsharePairMemory = _busdEsharePair;
        
        _busdToken.approve(_pancakeSwapRouterAddress, fee);
        _pancakeSwapRouter.swapExactTokensForTokens(fee, 0, busdEsharePairMemory, address(this), block.timestamp + _swapWaitingSeconds);
        
        //Deposit Eshare on EMP Money Boardroom
        uint256 eshareAmount = _eshareToken.balanceOf(address(this));
            
        if (eshareAmount > 0)
        {
            _eshareToken.approve(_boardroomAddress, eshareAmount);
            _boardroom.stake(eshareAmount);
        }
        
        //Update rewards fund
        updateRewardsFund();
    }

    function withdraw() external
    {
        uint256 blocksStaking = computeBlocksStaking();

        if (blocksStaking > _harvestCooldownBlocks)
            harvest();
        
        emergencyWithdraw();
    }
    
    function emergencyWithdraw() public
    {
        uint256 stakingDeposit = _userData[msg.sender].stakingDeposit;
        
        require(stakingDeposit > 0, "Ginko: withdraw amount cannot be 0");
        
        _userData[msg.sender].stakingDeposit = 0;
 
        _busdToken.transfer(msg.sender, stakingDeposit);
        
        _totalStakingDeposits -= stakingDeposit;
    }

    function computeUserReward() public view returns (uint256)
    {
        require(_userData[msg.sender].stakingDeposit > 0, "Ginko: staking deposit is 0");
    
        uint256 rewardsFund = getRewardsFund();
        
        uint256 userReward = 0;
    
        uint256 blocksStaking = computeBlocksStaking();
        
        if (blocksStaking > 0)
	    {
	        uint256 userBlockRatio = _decimalFixMultiplier;
	    
	        if (blocksStaking < _stakingBlockRange)
	            userBlockRatio = blocksStaking * _decimalFixMultiplier / _stakingBlockRange; 
		    
		    uint256 userDepositRatio = _decimalFixMultiplier;
		    
		    if (_userData[msg.sender].stakingDeposit < _totalStakingDeposits)
		        userDepositRatio = _userData[msg.sender].stakingDeposit * _decimalFixMultiplier / _totalStakingDeposits;
		    
		    uint256 totalRatio = userBlockRatio * userDepositRatio / _decimalFixMultiplier;
		    
		    userReward = totalRatio * rewardsFund / _decimalFixMultiplier;
		}
		
		return userReward;
    }

    function harvest() public 
    {
        require(_userData[msg.sender].stakingDeposit > 0, "Ginko: staking deposit is 0");

        uint256 blocksStaking = computeBlocksStaking();

        require(blocksStaking > _harvestCooldownBlocks, "Ginko: harvest cooldown in progress");
    
        updateRewardsFund();
        
        uint256 userReward = computeUserReward();
        
        _userData[msg.sender].stakingBlock = block.number;

        _busdToken.transfer(msg.sender, userReward);
    }
    
    function getStakingDeposit() external view returns (uint256)
    {
        UserData memory userData = _userData[msg.sender];
    
        return (userData.stakingDeposit);
    }
    
    function getStakingBlock() external view returns (uint256)
    {
        UserData memory userData = _userData[msg.sender];
    
        return (userData.stakingBlock);
    }
    
    function computeBlocksStaking() public view returns (uint256)
    {
        uint256 blocksStaking = 0;
        
        if (_userData[msg.sender].stakingDeposit > 0)
            blocksStaking = block.number - _userData[msg.sender].stakingBlock;
        
        return blocksStaking;
    }
}