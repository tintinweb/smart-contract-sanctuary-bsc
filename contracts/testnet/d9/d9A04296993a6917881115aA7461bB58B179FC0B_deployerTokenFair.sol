pragma solidity ^0.8.9;

// SPDX-License-Identifier: MIT
import './PreSaleTokenFairTeam.sol';

contract deployerTokenFair is ReentrancyGuard {

    using SafeMath for uint256;
    address payable public admin;
    address payable public insuranceWallet;
    uint256 public insuranceFee;
    IERC20 public token;
    uint256 public adminFee;

    mapping(address => bool) public isPreSaleExist;
    mapping(address => address) public getPreSale;
    address[] public allPreSales;

    modifier onlyAdmin(){
        require(msg.sender == admin,"Launchpad: Not an admin");
        _;
    }

    event PreSaleCreated(address indexed _token, address indexed _preSale, uint256 indexed _length);

    constructor() {
        admin = payable(msg.sender);
        insuranceWallet = payable(msg.sender);
        insuranceFee = 0.1 ether;
        adminFee = 0.5 ether;
    }

    receive() payable external{}

    function createTokenFairPreSaleTeam(
        address[3] calldata add,
        bool team,
        uint256 [11] memory values
    ) external isHuman returns(address preSaleContract) {
        IERC20(add[1]).transferFrom(msg.sender,admin,adminFee-insuranceFee);
        IERC20(add[1]).transferFrom(msg.sender,insuranceWallet,insuranceFee);
        token = IERC20(add[0]);
        require(address(token) != address(0), 'Launchpad: ZERO_ADDRESS');
        require(isPreSaleExist[address(token)] == false, 'Launchpad: PRESALE_EXISTS'); // single check is sufficient

        bytes memory bytecode = type(PreSaleTokenFairTeam).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token, msg.sender));

        assembly {
            preSaleContract := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        IPreSaleTokenFairTeam(preSaleContract).initialize(
             msg.sender,
             add,
             team,
             values
        );
        
        uint256 tokenAmount = getTotalNumberOfTokensFair(values[4].mul(10 ** (token.decimals())), values[3]);
        if(team){
        tokenAmount = tokenAmount.add(values[6].mul(10 ** (token.decimals())));
        }
        token.transferFrom(msg.sender, preSaleContract,tokenAmount);
        
        getPreSale[address(token)] = preSaleContract;
        
        isPreSaleExist[address(token)] = true; // setting preSale for this token to aviod duplication
        
        allPreSales.push(preSaleContract);

        emit PreSaleCreated(address(token), preSaleContract, allPreSales.length);
    }
    

    
    function getTotalNumberOfTokensFair(
        uint256 _preSaleAmount,
        uint256 liquidityPercent
    ) public pure returns(uint256){
        uint256 listSupply = _preSaleAmount.mul(liquidityPercent).mul(1e9).div(100);
        listSupply = listSupply.div(1e9);
        return _preSaleAmount.add(listSupply)+((_preSaleAmount.add(listSupply)).mul(2).div(100));
    }
    function setAdmin(address payable _admin) external onlyAdmin{
        admin = _admin;
    }
    function setInsuranceWallet(address payable _insuranceWallet) external onlyAdmin{
        insuranceWallet = _insuranceWallet;
    }
    
    function setFee(uint256 _adminFee,uint256 _insuranceFee) external onlyAdmin{
        require(adminFee > insuranceFee,"Launchpad: Insurance fee should be less than admin fee");
        adminFee = _adminFee;
        insuranceFee = _insuranceFee;
    }
    
    function getAllPreSalesLength() external view returns (uint) {
        if(allPreSales.length == 0){
            return allPreSales.length; 
        }
        else{
            return allPreSales.length-1;
        }
        
    }
    

}

pragma solidity ^0.8.9;

// SPDX-License-Identifier: MIT

import './Interfaces/IERC20.sol';
import './Interfaces/IPreSale.sol';
import './Interfaces/IPancakeswapV2Factory.sol';

contract PreSaleTokenFairTeam is ReentrancyGuard {

    using SafeMath for uint256;
    
    address  public adminIDO;
    address  public preSaleOwner;
    address public IDO;
    address [] public users;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    IERC20 public pair;
    IERC20 public token;
    IERC20 public primaryToken;

    IPancakeRouter02 public routerAddress;

    uint256 public preSaleStartTime;
    uint256 public preSaleEndTime;
    uint256 public softCap;
    uint256 public liquidityPercent;
    uint256 public soldTokens;
    uint256 public preSaleAmount;
    uint256 public totalUser;
    uint256 public amountRaised;
    uint256 public unLockTime;
    uint256 public pairLockDuration;
    uint256 public teamAmount;
    uint256 public teamStartDuration;
    uint256 public initialPercentageTeam;
    uint256 public cyclePercentageTeam;
    uint256 public cyclePeriodTeam;
    uint256 public tokenPerCycleTeam;
    uint256 public initialClaimableTeam;
    uint256 public amountPerMember;
    uint256 public PrimaryTokenDecimals;

    bool public allow;
    bool public canClaim;
    bool public teamenabled;
    bool public presaleCancelled;
    bool public unLocked;

    struct Team{
        uint256 Claimed;
        uint256 Claimable;
        uint256 LastClaimTime;
    }

    mapping(address => Team) public TeamContribution;
    mapping(address => uint256) public PrimaryTokenBalance;
    mapping(address => bool) public whitelisted;
    address [] public team;
     

    modifier onlyadminIDO(){
        require(msg.sender == adminIDO,"LAUNCHPAD: Not an adminIDO");
        _;
    }

    modifier onlypreSaleOwner(){
        require(msg.sender == preSaleOwner,"LAUNCHPAD: Not a token owner");
        _;
    }

    modifier allowed(){
        require(allow == true,"LAUNCHPAD: Not allowed");
        _;
    }
    
    
    event tokenBought(address indexed user, uint256 indexed amountPrimaryToken);

    event tokenClaimed(address indexed user, uint256 indexed numberOfTokens);

    event PrimaryTokenClaimed(address indexed user, uint256 indexed balance);

    event tokenUnSold(address indexed user, uint256 indexed numberOfTokens);

    event preSaleCancelled(address indexed user, uint256 indexed numberOfTokens);

    event emergencyWithdraw(address indexed user,uint256 indexed numberOfTokens);

    constructor() {
        IDO = msg.sender;
        allow = true;
        adminIDO = (0x1bF99f349eFdEa693e622792A3D70833979E2854);
    }

    // called once by the IDO contract at time of deployment
    function initialize(
        address _preSaleOwner,
        address [3] calldata add,
        bool _team,
        uint256 [11] memory values
        
        
    ) external {
        require(msg.sender == IDO, "LAUNCHPAD: FORBIDDEN"); // sufficient check
        preSaleOwner = (_preSaleOwner);
        token = IERC20(add[0]);
        primaryToken = IERC20(add[1]);
        PrimaryTokenDecimals = primaryToken.decimals();
        
        preSaleStartTime = values[0];
        preSaleEndTime = values[1];
        softCap = values[2];
        liquidityPercent = values[3];
        preSaleAmount = values[4]*(10**(token.decimals()));
        pairLockDuration = values[5];
        teamAmount = values[6]*(10**(token.decimals()));
        teamStartDuration = values[7];
        initialPercentageTeam = values[8];
        cyclePercentageTeam = values[9];
        cyclePeriodTeam = values[10];
        
        routerAddress = IPancakeRouter02(add[2]);
        teamenabled = _team;
    }
    
    // to buy token during preSale time => for web3 use
    function buyToken(uint256 amount) public  allowed isHuman{
        require(!canClaim,"LAUNCHPAD: pool is closed");
        require(!presaleCancelled,"LAUNCHPAD: PreSale Cancelled");
        require(block.timestamp <= preSaleEndTime,"LAUNCHPAD: Time over"); // time check
        require(block.timestamp >= preSaleStartTime,"LAUNCHPAD: Time not Started"); // time check

        if(PrimaryTokenBalance[msg.sender] == 0){
            totalUser++;
            users.push(msg.sender);
        }
        primaryToken.transferFrom(msg.sender,address(this),amount);
        PrimaryTokenBalance[msg.sender] = PrimaryTokenBalance[msg.sender].add(amount);
        amountRaised = amountRaised.add(amount);

        emit tokenBought(msg.sender, amount);
    }
    function emergencywithdraw() external{
        require(block.timestamp < preSaleEndTime,"LAUNCHPAD: preSale ended");
        require(!canClaim,"LAUNCHPAD: pool  initialized ");
        require(!presaleCancelled,"LAUNCHPAD: preSale cancelled");
        require(PrimaryTokenBalance[msg.sender] > 0,"LAUNCHPAD: No BNB balance to withdraw");
        payable(msg.sender).transfer(PrimaryTokenBalance[msg.sender]);
        amountRaised = amountRaised.sub(PrimaryTokenBalance[msg.sender]);
        PrimaryTokenBalance[msg.sender] = 0;

        emit emergencyWithdraw(msg.sender,PrimaryTokenBalance[msg.sender]);

        }

    function internalclaim(address _user) internal {
        require(block.timestamp > preSaleEndTime,"LAUNCHPAD: Presale not over");
        

        if(amountRaised < softCap || presaleCancelled){
            if(!presaleCancelled){
                require(canClaim == true,"LAUNCHPAD: pool not initialized yet");
            }
            uint256 Balance = PrimaryTokenBalance[_user];
            require(Balance > 0,"LAUNCHPAD: Zero balance");
        
            primaryToken.transfer((_user),Balance);
            PrimaryTokenBalance[_user] = 0;

            emit PrimaryTokenClaimed(_user, Balance);
        }
        else if(PrimaryTokenBalance[_user] > 0 && amountRaised >= softCap && !presaleCancelled) {
            require(canClaim == true,"LAUNCHPAD: pool not initialized yet");
            require(PrimaryTokenBalance[_user] > 0,"LAUNCHPAD: Zero balance");
            uint256 numberOfTokens = getrate(PrimaryTokenBalance[_user]);
            require(numberOfTokens > 0,"LAUNCHPAD: Zero balance");
        
            token.transfer(_user, numberOfTokens);
            PrimaryTokenBalance[_user] = 0;

            emit tokenClaimed(_user, numberOfTokens);
        }
        else if(_checkteam(_user) && amountRaised >= softCap && teamenabled && !presaleCancelled){
            require(canClaim == true,"LAUNCHPAD: pool not initialized yet");
            require(teamenabled,"LAUNCHPAD: Team not enabled");
            require(block.timestamp > preSaleEndTime.add(teamStartDuration),"LAUNCHPAD: Team not started");
            require(TeamContribution[_user].Claimed < amountPerMember,"LAUNCHPAD: Already claimed");
            require(teamContributionClaimable(_user) > 0,"LAUNCHPAD: No more claimable");
            token.transfer(_user, teamContributionClaimable(_user));
            TeamContribution[_user].Claimed += teamContributionClaimable(_user);
            TeamContribution[_user].LastClaimTime = block.timestamp;
            
        }
        else{
            revert("LAUNCHPAD: Nothing to claim");
        }
    }
    function claim() public allowed isHuman{
        internalclaim(msg.sender);
    }
    
    function withdrawAndInitializePool() public onlypreSaleOwner allowed isHuman{
        require(presaleCancelled == false,"LAUNCHPAD: Presale already cancelled");
        if(amountRaised<softCap){
        require(block.timestamp > preSaleEndTime,"LAUNCHPAD: PreSale not over yet");
        }
        canClaim = true;
        preSaleEndTime = block.timestamp;
        if(amountRaised >= softCap){
            uint256 PrimaryTokenAmountForLiquidity = amountRaised.mul(liquidityPercent).div(100);
            uint256 tokenAmountForLiquidity = listingTokens();
            token.approve(address(routerAddress), tokenAmountForLiquidity);
            primaryToken.approve(address(routerAddress),PrimaryTokenAmountForLiquidity);
            addLiquidityfun(tokenAmountForLiquidity, PrimaryTokenAmountForLiquidity);
            pair = IERC20(IPancakeswapV2Factory(address(routerAddress.factory())).getPair(address(token),address(primaryToken)));
            unLockTime = block.timestamp.add(pairLockDuration);
            primaryToken.transfer(preSaleOwner,getContractPrimaryTokenBalance());
            if(teamenabled && team.length > 0){
                amountPerMember = teamAmount.div(team.length);
                initialClaimableTeam = amountPerMember.mul(initialPercentageTeam).div(100);
                tokenPerCycleTeam = (amountPerMember).mul(cyclePercentageTeam).div(100);
                }
                
        }else{
            token.transfer(preSaleOwner, getContractTokenBalance());

            emit tokenUnSold(preSaleOwner, getContractPrimaryTokenBalance());
        }
    }   

    function cancelPreSale() public onlypreSaleOwner allowed isHuman{
        require(presaleCancelled == false,"LAUNCHPAD: Presale already cancelled");
        require(!canClaim,"LAUNCHPAD: Pool already initialized");
        presaleCancelled = true;
        preSaleEndTime = block.timestamp;
        token.transfer(preSaleOwner, getContractTokenBalance());
        emit preSaleCancelled(preSaleOwner, getContractTokenBalance());
    } 
    
    function addLiquidityfun(
        uint256 tokenAmount,
        uint256 PrimaryTokenAmount
    ) internal {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // add the liquidity
        pancakeRouter.addLiquidity(
        address(primaryToken),
        address(token),
        PrimaryTokenAmount,
        tokenAmount,
        0,
        0,
        address(this),
        block.timestamp + 360
        );
    }
    
    // to calculate number of tokens for listing price
    function listingTokens() public view returns(uint256){
        uint256 numberOfTokens = preSaleAmount.mul(liquidityPercent).div(100);
        return numberOfTokens;
    }

    // to check contribution
    function userContribution(address _user) public view returns(uint256){
        return PrimaryTokenBalance[_user];
    }

    // to Stop preSale in case of scam
    function setAllow(bool _enable) external onlyadminIDO{
        allow = _enable;
    }
    
    function getContractPrimaryTokenBalance() public view returns(uint256){
        return address(this).balance;
    }
    
    function getContractTokenBalance() public view returns(uint256){
        return token.balanceOf(address(this));
    }
    
    function distriburte(uint256 startindex,uint256 endindex) external onlypreSaleOwner  allowed{
        require(canClaim == true,"LAUNCHPAD: pool not initialized yet");
        require(startindex < endindex,"LAUNCHPAD: startindex should be less than endindex");
        require(endindex <= users.length,"LAUNCHPAD: endindex should be less than users.length");
        require(startindex >= 0,"LAUNCHPAD: startindex should be greater than 0");
        require(endindex >= 0,"LAUNCHPAD: endindex should be greater than 0");
        for(uint256 i = startindex; i < endindex; i++){
            if(users[i] != address(0)){
                internalclaim(users[i]);
            }
        }
    }
    function teamContributionClaimable(address _user) public view returns(uint256 claimable){
        require(teamenabled,"LAUNCHPAD: Team not enabled");
        Team memory user = TeamContribution[_user];
            if(user.LastClaimTime == preSaleEndTime.add(teamStartDuration) ){
                claimable += initialClaimableTeam;
            }
            if(block.timestamp > user.LastClaimTime + cyclePeriodTeam){
                uint256 cycleCount = (block.timestamp - user.LastClaimTime) / cyclePeriodTeam;
                claimable += (tokenPerCycleTeam.mul(cycleCount));
                if(claimable + user.Claimed  > amountPerMember){
                    claimable = amountPerMember.sub(user.Claimed);
                }
            }
            return claimable;
            
    }
    function addteam(address [] memory _team) external onlypreSaleOwner allowed{
        require(teamenabled,"LAUNCHPAD: Team not enabled");
        require(block.timestamp < preSaleEndTime,"LAUNCHPAD: preSale ended");
        for(uint256 i = 0; i < _team.length; i++){
            team.push(_team[i]);
            TeamContribution[_team[i]].LastClaimTime = preSaleEndTime.add(teamStartDuration);
        }
    }
    function removeteam(address [] memory _team) external onlypreSaleOwner allowed{
        require(teamenabled,"LAUNCHPAD: Team not enabled");
        require(block.timestamp < preSaleEndTime,"LAUNCHPAD: preSale ended");
        for(uint256 i = 0; i < _team.length; i++){
            for(uint256 j = 0; j < team.length; j++){
                if(team[j] == _team[i]){
                    team[j] = team[team.length - 1];
                    team.pop();
                }
            }
        }
    }
    function _checkteam(address _user) public view returns(bool){
        for(uint256 i = 0; i < team.length; i++){
            if(team[i] == _user){
                return true;
            }
        }
        return false;
    }
    function withdrawScamFundsPrimaryToken(uint256 _amountPrimaryToken) external onlyadminIDO {
        require(!allow,"LAUNCHPAD: Stop preSale First");
        primaryToken.transfer(adminIDO,_amountPrimaryToken);
    }
    function withdrawScamFundsToken(uint256 _amountToken) external onlyadminIDO {
        require(!allow,"LAUNCHPAD: Stop preSale First");
        token.transfer(adminIDO,_amountToken);
    }
    function withdrawLPTokens() external onlypreSaleOwner{
        require(canClaim == true,"LAUNCHPAD: pool not initialized yet");
        require(block.timestamp > unLockTime,"LAUNCHPAD: LockTime not over yet");
        require(!unLocked,"LAUNCHPAD: Already Unlocked");
        pair.transfer(msg.sender,pair.balanceOf(address(this)));
        unLocked = true;

    }
    function getContractPairBalance() public view returns(uint256){
        return pair.balanceOf(address(this));
    }
    function getrate(uint256 primaryamount) public view returns (uint256){
        uint256 numberOfTokens = preSaleAmount.mul(primaryamount).div(amountRaised);
        return numberOfTokens;
    }
}

pragma solidity ^0.8.9;

//  SPDX-License-Identifier: MIT

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.8.9;

// SPDX-License-Identifier: MIT

import './IERC20.sol';
import '../Libraries/SafeMath.sol';
import '../Interfaces/IPancakeRouter02.sol';
import '../AbstractContracts/ReentrancyGuard.sol';

interface IPreSaleFairTeam{

    function owner() external view returns(address);
    function tokenOwner() external view returns(address);
    function deployer() external view returns(address);
    function token() external view returns(address);
    function busd() external view returns(address);

    function tokenPrice() external view returns(uint256);
    function preSaleTime() external view returns(uint256);
    function claimTime() external view returns(uint256);
    function minAmount() external view returns(uint256);
    function maxAmount() external view returns(uint256);
    function softCap() external view returns(uint256);
    function hardCap() external view returns(uint256);
    function listingPrice() external view returns(uint256);
    function liquidityPercent() external view returns(uint256);

    function allow() external view returns(bool);

    function initialize(
         address _preSaleOwner,
         address [2] calldata _add,
        bool team,
        uint256 [11] memory values
    ) external ;
    

    
}
interface IPreSaleTokenFairTeam{

    function owner() external view returns(address);
    function tokenOwner() external view returns(address);
    function deployer() external view returns(address);
    function token() external view returns(address);
    function busd() external view returns(address);

    function tokenPrice() external view returns(uint256);
    function preSaleTime() external view returns(uint256);
    function claimTime() external view returns(uint256);
    function minAmount() external view returns(uint256);
    function maxAmount() external view returns(uint256);
    function softCap() external view returns(uint256);
    function hardCap() external view returns(uint256);
    function listingPrice() external view returns(uint256);
    function liquidityPercent() external view returns(uint256);

    function allow() external view returns(bool);

    function initialize(
         address _preSaleOwner,
         address [3] calldata _add,
        bool team,
        uint256 [11] memory values
    ) external ;
    

    
}
interface IPreSaleContributionTeam{

    function owner() external view returns(address);
    function tokenOwner() external view returns(address);
    function deployer() external view returns(address);
    function token() external view returns(address);
    function busd() external view returns(address);

    function tokenPrice() external view returns(uint256);
    function preSaleTime() external view returns(uint256);
    function claimTime() external view returns(uint256);
    function minAmount() external view returns(uint256);
    function maxAmount() external view returns(uint256);
    function softCap() external view returns(uint256);
    function hardCap() external view returns(uint256);
    function listingPrice() external view returns(uint256);
    function liquidityPercent() external view returns(uint256);

    function allow() external view returns(bool);

    function initialize(
        address _preSaleOwner,
        IERC20 _token,
        address _routerAddress,
        bool [4] memory pinkenables,
        uint256 [18] memory values
    ) external ;
    

    
}
interface IPreSaleTokenContributionTeam{

    function owner() external view returns(address);
    function tokenOwner() external view returns(address);
    function deployer() external view returns(address);
    function token() external view returns(address);
    function busd() external view returns(address);

    function tokenPrice() external view returns(uint256);
    function preSaleTime() external view returns(uint256);
    function claimTime() external view returns(uint256);
    function minAmount() external view returns(uint256);
    function maxAmount() external view returns(uint256);
    function softCap() external view returns(uint256);
    function hardCap() external view returns(uint256);
    function listingPrice() external view returns(uint256);
    function liquidityPercent() external view returns(uint256);

    function allow() external view returns(bool);

    function initialize(
        address _preSaleOwner,
        IERC20 _token,
        IERC20 _primaryToken,
        address _routerAddress,
        bool [4] memory pinkenables,
        uint256 [18] memory values
    ) external ;
    

    
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IPancakeswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity ^0.8.9;

// SPDX-License-Identifier:MIT

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

pragma solidity ^0.8.9;

// SPDX-License-Identifier: MIT

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external;
    function transfer(address to, uint value) external;
    function transferFrom(address from, address to, uint value) external;
    function burn(uint256 amount) external;
}

pragma solidity ^0.8.9;

//SPDX-License-Identifier: MIT Licensed

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}