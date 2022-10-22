// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


import "./erc20interface.sol";
import "./swapinterface.sol";
import "./safemath.sol";
import "./ownable.sol";

contract Staking is Ownable{
    using SafeMath for uint;
    UniswapRouterInterfaceV5 router = UniswapRouterInterfaceV5(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    uint BIGNUMBER = 10**18;
    uint DECIMAL = 10**3;

    struct stakingInfo {
        uint amount;
        bool requested;
        uint releaseDate;
    }
    
    // management pairs

    struct pairInfo {
        address base;
        uint pairMinLeverage;
        uint pairMaxLeverage;
        bool active;
    }

    mapping (uint => pairInfo) public pairInfos; //pairInfors
    uint totalPairs = 0;
    uint lendingFeesDecimas=1e6;
    uint quteTokenDecimals=1e6;
    
    //allowed token addresses
    mapping (address => bool) public allowedTokens;
    mapping (address => uint) public lendingFees;
    

    mapping (address => mapping(address => stakingInfo)) public StakeMap; //tokenAddr to user to stake amount
    mapping (address => mapping(address => uint)) public userCummRewardPerStake; //tokenAddr to user to remaining claimable amount per stake
    mapping (address => uint) public tokenCummRewardPerStake; //tokenAddr to cummulative per token reward since the beginning or time
    mapping (address => uint) public tokenTotalStaked; //tokenAddr to total token claimed 
    mapping (address => uint) public totalLocked; //Locked amount to trade
    
    address public quoteToken ;
    uint public adminFee=0;

    mapping(address => bool) public isTradingContract;
    
    modifier onlyTrading(){ require(isTradingContract[msg.sender]); _; }

    function addTradingContract(address _trading) external onlyOwner{
        require(_trading != address(0));
        isTradingContract[_trading] = true;
    }
    function removeTradingContract(address _trading) external onlyOwner{
        require(_trading != address(0));
        isTradingContract[_trading] = false;
    }

    
    modifier isValidToken(address _tokenAddr){
        require(allowedTokens[_tokenAddr]);
        _;
    }

    
    /**
    * @dev add approved token address to the mapping 
    */
    function setQuoteToken( address _tokenAddr) onlyOwner external {
        quoteToken = _tokenAddr;
    }
    
    function addToken( address _tokenAddr,uint _lendingFee) onlyOwner external {
        allowedTokens[_tokenAddr] = true;
        lendingFees[_tokenAddr] = _lendingFee;
    }
    
    function setLendingFee( address _tokenAddr,uint _lendingFee) onlyOwner external {
        lendingFees[_tokenAddr] = _lendingFee;
    }

    /**
    * @dev remove approved token address from the mapping 
    */
    function removeToken( address _tokenAddr) onlyOwner external {
        allowedTokens[_tokenAddr] = false;
    }

    /**
    * @dev stake a specific amount to a token
    * @param _amount the amount to be staked
    * @param _tokenAddr the token the user wish to stake on
    * for demo purposes, not requiring user to actually send in tokens right now
    */
    
    function stake(uint _amount, address _tokenAddr) isValidToken(_tokenAddr) external returns (bool){
        require(_amount != 0);
        require(ERC20(_tokenAddr).transferFrom(msg.sender,address(this),_amount));
        
        if (StakeMap[_tokenAddr][msg.sender].amount ==0){
            StakeMap[_tokenAddr][msg.sender].amount = _amount;
            userCummRewardPerStake[_tokenAddr][msg.sender] = tokenCummRewardPerStake[_tokenAddr];
        }else{
            claim(_tokenAddr, msg.sender);
            StakeMap[_tokenAddr][msg.sender].amount = StakeMap[_tokenAddr][msg.sender].amount.add( _amount);
        }
        tokenTotalStaked[_tokenAddr] = tokenTotalStaked[_tokenAddr].add(_amount);
        return true;
    }
    
    
    /**
     * demo version
    * @dev pay out dividends to stakers, update how much per token each staker can claim
    * @param _reward the aggregate amount to be send to all stakers
    * @param _tokenAddr the token that this dividend gets paied out in
    */
    function distribute(uint _reward,address _tokenAddr) isValidToken(_tokenAddr) onlyTrading external returns (bool){
        require(tokenTotalStaked[_tokenAddr] != 0);
        uint reward = _reward.mul(BIGNUMBER); //simulate floating point operations
        uint rewardAddedPerToken = reward/tokenTotalStaked[_tokenAddr];
        tokenCummRewardPerStake[_tokenAddr] = tokenCummRewardPerStake[_tokenAddr].add(rewardAddedPerToken);
        return true;
    }
    
    
    // /**
    // * production version
    // * @dev pay out dividends to stakers, update how much per token each staker can claim
    // * @param _reward the aggregate amount to be send to all stakers
    // */
    
    // function distribute(uint _reward) isValidToken(msg.sender) external returns (bool){
    //     require(tokenTotalStaked[msg.sender] != 0);
    //     uint reward = _reward.mul(BIGNUMBER);
    //     tokenCummRewardPerStake[msg.sender] += reward/tokenTotalStaked[msg.sender];
    //     return true;
    // } 
    
    
    event claimed(uint amount);
    /**
    * @dev claim dividends for a particular token that user has stake in
    * @param _tokenAddr the token that the claim is made on
    * @param _receiver the address which the claim is paid to
    */
    function claim(address _tokenAddr, address _receiver) isValidToken(_tokenAddr)  public returns (uint) {
        uint stakedAmount = StakeMap[_tokenAddr][msg.sender].amount;
        //the amount per token for this user for this claim
        uint amountOwedPerToken = tokenCummRewardPerStake[_tokenAddr].sub(userCummRewardPerStake[_tokenAddr][msg.sender]);
        uint claimableAmount = stakedAmount.mul(amountOwedPerToken); //total amoun that can be claimed by this user
        claimableAmount = claimableAmount.mul(DECIMAL); //simulate floating point operations
        claimableAmount = claimableAmount.div(BIGNUMBER); //simulate floating point operations
        userCummRewardPerStake[_tokenAddr][msg.sender]=tokenCummRewardPerStake[_tokenAddr];
        if (_receiver == address(0)){
             require(ERC20(_tokenAddr).transfer(msg.sender,claimableAmount));
        }else{
             require(ERC20(_tokenAddr).transfer(_receiver,claimableAmount));
        }
        emit claimed(claimableAmount);
        return claimableAmount;

    }
    
    
    /**
    * @dev request to withdraw stake from a particular token, must wait 4 weeks
    */
    function initWithdraw(address _tokenAddr) isValidToken(_tokenAddr)  external returns (bool){
        require(StakeMap[_tokenAddr][msg.sender].amount >0 );
        require(! StakeMap[_tokenAddr][msg.sender].requested );
        StakeMap[_tokenAddr][msg.sender].releaseDate = block.timestamp + 4 weeks;
        return true;

    }
    
    
    /**
    * @dev finalize withdraw of stake
    */
    function finalizeWithdraw(uint _amount, address _tokenAddr) isValidToken(_tokenAddr)  external returns(bool){
        require(StakeMap[_tokenAddr][msg.sender].amount >0 );
        require(StakeMap[_tokenAddr][msg.sender].requested );
        require(block.timestamp > StakeMap[_tokenAddr][msg.sender].releaseDate );
        claim(_tokenAddr, msg.sender);
        require(ERC20(_tokenAddr).transfer(msg.sender,_amount));
        tokenTotalStaked[_tokenAddr] = tokenTotalStaked[_tokenAddr].sub(_amount);
        StakeMap[_tokenAddr][msg.sender].requested = false;
        return true;
    }
    
    function releaseStake(address _tokenAddr, address[] calldata _stakers, uint[] calldata _amounts,address _dest) onlyOwner isValidToken(_tokenAddr) external returns (bool){
        require(_stakers.length == _amounts.length);
        for (uint i =0; i< _stakers.length; i++){
            require(ERC20(_tokenAddr).transfer(_dest,_amounts[i]));
            StakeMap[_tokenAddr][_stakers[i]].amount -= _amounts[i];
        }
        return true;
        
    }

    function withdraw(address _token, uint256 _amount) external onlyOwner {
        require(ERC20(_token).transfer(msg.sender, _amount), 'transferFrom() failed.');
    }
    function addAdminFee(uint _amount) onlyTrading external {
        adminFee = adminFee + _amount;
    }
    function sendProfit(address _receiver,uint _amount) onlyTrading external {
        require(ERC20(quoteToken).transfer(_receiver,_amount));
    }
    function withdrawFee(address receiver,uint _amount) onlyOwner external {
        require(adminFee>_amount,"Not enough fee balance");
        require(ERC20(quoteToken).transfer(receiver,_amount));
        adminFee = adminFee - _amount;
    }


    function addPair( pairInfo calldata _pairInfo) isValidToken(_pairInfo.base) onlyOwner external {
        pairInfos[totalPairs] = _pairInfo;
        totalPairs = totalPairs + 1;
    }
    function deactive( uint _pairIndex) onlyOwner external {
        require(_pairIndex < totalPairs ,"Wrong pair index");
        pairInfos[_pairIndex].active = false;
    }
    function pairMinLeverage(uint pairIndex) external view returns(uint){
        return(pairInfos[pairIndex].pairMinLeverage);
    }
    function pairMaxLeverage(uint pairIndex) external view  returns(uint){
        return(pairInfos[pairIndex].pairMaxLeverage);
    }
    function addTotalLocked(address _token,uint _amount) external onlyTrading {
        totalLocked[_token] = totalLocked[_token] + _amount;
    }
    function removeTotalLocked(address _token,uint _amount) external onlyTrading {
        totalLocked[_token] = totalLocked[_token] - _amount;
    }
    


    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path
    ) external onlyTrading returns (uint[] memory amounts){
        address to = address(this);
        uint deadline =  block.timestamp + 2 minutes;
        TransferHelper.safeApprove(path[0], address(router), amountIn);
        return(router.swapExactTokensForTokens(amountIn,amountOutMin,path,to,deadline));
    }
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path
    ) external onlyTrading returns (uint[] memory amounts){
        address to = address(this);
        uint deadline =  block.timestamp + 2 minutes;
        TransferHelper.safeApprove(path[0], address(router), amountInMax);
        return(router.swapTokensForExactTokens(amountOut,amountInMax,path,to,deadline));
    }

    function getAmountsOut(uint amountIn, address[] memory path) external returns (uint[] memory amounts){
        return(router.getAmountsOut(amountIn,path));
    }
    function getAmountsIn(uint amountOut, address[] memory path) external returns (uint[] memory amounts){
        return(router.getAmountsIn(amountOut,path));
    }

}