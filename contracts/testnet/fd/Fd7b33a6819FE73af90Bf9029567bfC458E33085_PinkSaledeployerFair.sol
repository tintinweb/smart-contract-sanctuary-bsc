pragma solidity ^0.8.9;

// SPDX-License-Identifier: MIT
import './preSaleBnbFairTeam.sol';

contract PinkSaledeployerFair is ReentrancyGuard {

    using SafeMath for uint256;
    address payable public admin;
    IERC20 public token;
    uint256 public adminFee;

    mapping(address => bool) public isPreSaleExist;
    mapping(address => address) public getPreSale;
    address[] public allPreSales;

    modifier onlyAdmin(){
        require(msg.sender == admin,"PinkSale: Not an admin");
        _;
    }

    event PreSaleCreated(address indexed _token, address indexed _preSale, uint256 indexed _length);

    constructor() {
        admin = payable(msg.sender);
        adminFee = 0.1 ether;
    }

    receive() payable external{}

    // function createPreSaleContributionTeam(
    //     IERC20 _token,
    //     IERC20 _antibotToken,
    //     address _routerAddress,
    //     bool [4] memory pinkenables,
    //     uint256 [10] memory pinkvalues,
    //     uint256 [9] memory values
    // ) external payable isHuman returns(address preSaleContract) {
    //     require(msg.value == adminFee,"PinkSale: Admin fee not paid");
    //     token = _token;
    //     require(address(token) != address(0), 'PinkSale: ZERO_ADDRESS');
    //     require(isPreSaleExist[address(token)] == false, 'PinkSale: PRESALE_EXISTS'); // single check is sufficient

    //     bytes memory bytecode = type(PreSaleBNBContributionTeam).creationCode;
    //     bytes32 salt = keccak256(abi.encodePacked(token, msg.sender));

    //     assembly {
    //         preSaleContract := create2(0, add(bytecode, 32), mload(bytecode), salt)
    //     }

    //     IPreSaleContributionTeam(preSaleContract).initialize(
    //         msg.sender,
    //         token,
    //         _routerAddress,
    //         _antibotToken,
    //         pinkenables,
    //         pinkvalues,
    //         values
    //     );
        
    //     uint256 tokenAmount = getTotalNumberOfTokens(
    //         values[0],
    //         values[7],
    //         values[5],
    //         values[8]
    //     );

    //     tokenAmount = tokenAmount.mul(10 ** (token.decimals()));
    //     if(pinkenables[3]){
    //     tokenAmount = tokenAmount.add(pinkvalues[5].mul(10 ** (token.decimals())));
    //     }
    //     token.transferFrom(msg.sender, preSaleContract, tokenAmount);
    //     getPreSale[address(token)] = preSaleContract;
    //     isPreSaleExist[address(token)] = true; // setting preSale for this token to aviod duplication
    //     allPreSales.push(preSaleContract);

    //     emit PreSaleCreated(address(token), preSaleContract, allPreSales.length);
    // }
    function createFairPreSaleTeam(
        IERC20 _token,
        address _routerAddress,
        address _pairLocker,
        bool team,
        uint256 [7] memory pinkvalues,
        uint256 [4] memory values
    ) external payable isHuman returns(address preSaleContract) {
        require(msg.value == adminFee,"PinkSale: Admin fee not paid");
        token = _token;
        require(address(token) != address(0), 'PinkSale: ZERO_ADDRESS');
        require(isPreSaleExist[address(token)] == false, 'PinkSale: PRESALE_EXISTS'); // single check is sufficient

        bytes memory bytecode = type(PreSaleBnbFairTeam).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token, msg.sender));

        assembly {
            preSaleContract := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        IPreSaleFairTeam(preSaleContract).initialize(
             msg.sender,
             token,
             _routerAddress,
             _pairLocker,
             team,
             pinkvalues,
             values
        );
        
        uint256 tokenAmount = getTotalNumberOfTokensFair(pinkvalues[0], values[3]);
        tokenAmount = tokenAmount.mul(10 ** (token.decimals()));
        if(team){
        tokenAmount = tokenAmount.add(pinkvalues[2].mul(10 ** (token.decimals())));
        }
        token.transferFrom(msg.sender, preSaleContract,tokenAmount);
        
        getPreSale[address(token)] = preSaleContract;
        
        isPreSaleExist[address(token)] = true; // setting preSale for this token to aviod duplication
        
        allPreSales.push(preSaleContract);

        emit PreSaleCreated(address(token), preSaleContract, allPreSales.length);
    }

    

    // function getTotalNumberOfTokens(
    //     uint256 _tokenPrice,
    //     uint256 _listingPrice,
    //     uint256 _hardCap,
    //     uint256 _liquidityPercent
    // ) public pure returns(uint256){

    //     uint256 tokensForSell = _hardCap.mul(_tokenPrice).mul(1000).div(1e18);
    //     tokensForSell = tokensForSell.add(tokensForSell.mul(2).div(100));
    //     uint256 tokensForListing = (_hardCap.mul(_liquidityPercent).div(100)).mul(_listingPrice).mul(1000).div(1e18);
    //     return tokensForSell.add(tokensForListing).div(1000);

    // }
    function getTotalNumberOfTokensFair(
        uint256 _preSaleAmount,
        uint256 liquidityPercent
    ) public pure returns(uint256){
        return _preSaleAmount.add(_preSaleAmount.mul(liquidityPercent).div(100));
    }
    function setAdmin(address payable _admin) external onlyAdmin{
        admin = _admin;
    }
    
    function setAdminFee(uint256 _adminFee) external onlyAdmin{
        adminFee = _adminFee;
    }
    
    function getAllPreSalesLength() external view returns (uint) {
        if(allPreSales.length == 0){
            return allPreSales.length; 
        }
        else{
            return allPreSales.length-1;
        }
        
    }

    function getCurrentTime() public view returns(uint256){
        return block.timestamp;
    }

}

    // function createPreSaleSimple(
    //     IERC20 _token,
    //     IERC20 _antibotToken,
    //     address _routerAddress,
    //     bool [3] memory pinkenables,
    //     uint256 [2] memory pinkvalues,
    //     uint256 [9] memory values
    // ) external payable isHuman returns(address preSaleContract) {
    //     require(msg.value == adminFee,"PinkSale: Admin fee not paid");
    //     token = _token;
    //     require(address(token) != address(0), 'PinkSale: ZERO_ADDRESS');
    //     require(isPreSaleExist[address(token)] == false, 'PinkSale: PRESALE_EXISTS'); // single check is sufficient

    //     bytes memory bytecode = type(preSaleBnbSimple).creationCode;
    //     bytes32 salt = keccak256(abi.encodePacked(token, msg.sender));

    //     assembly {
    //         preSaleContract := create2(0, add(bytecode, 32), mload(bytecode), salt)
    //     }

    //     IPreSaleSimple(preSaleContract).initialize(
    //         msg.sender,
    //         token,
    //         _routerAddress,
    //         _antibotToken,
    //         pinkenables,
    //         pinkvalues,
    //         values
    //     );
        
    //     uint256 tokenAmount = getTotalNumberOfTokens(
    //         values[0],
    //         values[7],
    //         values[5],
    //         values[8]
    //     );

    //     tokenAmount = tokenAmount.mul(10 ** (token.decimals()));
    //     token.transferFrom(msg.sender, preSaleContract, tokenAmount);
    //     getPreSale[address(token)] = preSaleContract;
    //     isPreSaleExist[address(token)] = true; // setting preSale for this token to aviod duplication
    //     allPreSales.push(preSaleContract);

    //     emit PreSaleCreated(address(token), preSaleContract, allPreSales.length);
    // }
    // function createPreSaleContribution(
    //     IERC20 _token,
    //     IERC20 _antibotToken,
    //     address _routerAddress,
    //     bool [3] memory pinkenables,
    //     uint256 [5] memory pinkvalues,
    //     uint256 [9] memory values
    // ) external payable isHuman returns(address preSaleContract) {
    //     require(msg.value == adminFee,"PinkSale: Admin fee not paid");
    //     token = _token;
    //     require(address(token) != address(0), 'PinkSale: ZERO_ADDRESS');
    //     require(isPreSaleExist[address(token)] == false, 'PinkSale: PRESALE_EXISTS'); // single check is sufficient

    //     bytes memory bytecode = type(PreSaleBNBContribution).creationCode;
    //     bytes32 salt = keccak256(abi.encodePacked(token, msg.sender));

    //     assembly {
    //         preSaleContract := create2(0, add(bytecode, 32), mload(bytecode), salt)
    //     }

    //     IPreSaleContribution(preSaleContract).initialize(
    //         msg.sender,
    //         token,
    //         _routerAddress,
    //         _antibotToken,
    //         pinkenables,
    //         pinkvalues,
    //         values
    //     );
        
    //     uint256 tokenAmount = getTotalNumberOfTokens(
    //         values[0],
    //         values[7],
    //         values[5],
    //         values[8]
    //     );

    //     tokenAmount = tokenAmount.mul(10 ** (token.decimals()));
    //     token.transferFrom(msg.sender, preSaleContract, tokenAmount);
    //     getPreSale[address(token)] = preSaleContract;
    //     isPreSaleExist[address(token)] = true; // setting preSale for this token to aviod duplication
    //     allPreSales.push(preSaleContract);

    //     emit PreSaleCreated(address(token), preSaleContract, allPreSales.length);
    // }
    
    // function createPreSaleTeam(
    //     IERC20 _token,
    //     IERC20 _antibotToken,
    //     address _routerAddress,
    //     bool [3] memory pinkenables,
    //     uint256 [7] memory pinkvalues,
    //     uint256 [9] memory values
    // ) external payable isHuman returns(address preSaleContract) {
    //     require(msg.value == adminFee,"PinkSale: Admin fee not paid");
    //     token = _token;
    //     require(address(token) != address(0), 'PinkSale: ZERO_ADDRESS');
    //     require(isPreSaleExist[address(token)] == false, 'PinkSale: PRESALE_EXISTS'); // single check is sufficient

    //     bytes memory bytecode = type(preSaleBnbSimpleTeam).creationCode;
    //     bytes32 salt = keccak256(abi.encodePacked(token, msg.sender));

    //     assembly {
    //         preSaleContract := create2(0, add(bytecode, 32), mload(bytecode), salt)
    //     }

    //     IPreSaleTeam(preSaleContract).initialize(
    //         msg.sender,
    //         token,
    //         _routerAddress,
    //         _antibotToken,
    //         pinkenables,
    //         pinkvalues,
    //         values
    //     );
        
    //     uint256 tokenAmount = getTotalNumberOfTokens(
    //         values[0],
    //         values[7],
    //         values[5],
    //         values[8]
    //     );

    //     tokenAmount = tokenAmount.mul(10 ** (token.decimals()));
    //     tokenAmount = tokenAmount.add(pinkvalues[2].mul(10 ** (token.decimals())));
    //     token.transferFrom(msg.sender, preSaleContract, tokenAmount);
    //     getPreSale[address(token)] = preSaleContract;
    //     isPreSaleExist[address(token)] = true; // setting preSale for this token to aviod duplication
    //     allPreSales.push(preSaleContract);

    //     emit PreSaleCreated(address(token), preSaleContract, allPreSales.length);
    // }
    // function createFairPreSaleSimple(
    //     IERC20 _token,
    //     address _routerAddress,
    //     uint256 [2] memory pinkvalues,
    //     uint256 [4] memory values
    // ) external payable isHuman returns(address preSaleContract) {
    //     require(msg.value == adminFee,"PinkSale: Admin fee not paid");
    //     token = _token;
    //     require(address(token) != address(0), 'PinkSale: ZERO_ADDRESS');
    //     require(isPreSaleExist[address(token)] == false, 'PinkSale: PRESALE_EXISTS'); // single check is sufficient

    //     bytes memory bytecode = type(preSaleBnbFairSimple).creationCode;
    //     bytes32 salt = keccak256(abi.encodePacked(token, msg.sender));

    //     assembly {
    //         preSaleContract := create2(0, add(bytecode, 32), mload(bytecode), salt)
    //     }

    //     IPreSaleFairSimple(preSaleContract).initialize(
    //        msg.sender,
    //          token,
    //          _routerAddress,
    //          pinkvalues,
    //          values
    //     );
        
    //     uint256 tokenAmount = getTotalNumberOfTokensFair(pinkvalues[0], values[3]);

    //     token.transferFrom(msg.sender, preSaleContract, tokenAmount.mul(10 ** (token.decimals())));
        
    //     getPreSale[address(token)] = preSaleContract;
        
    //     isPreSaleExist[address(token)] = true; // setting preSale for this token to aviod duplication
        
    //     allPreSales.push(preSaleContract);

    //     emit PreSaleCreated(address(token), preSaleContract, allPreSales.length);
    // }

pragma solidity ^0.8.9;

// SPDX-License-Identifier: MIT

import './Interfaces/IERC20.sol';
import './Interfaces/IPreSale.sol';
import './interfaces/ILocker.sol';
import './interfaces/IPancakeswapV2Factory.sol';

contract PreSaleBnbFairTeam is ReentrancyGuard {

    using SafeMath for uint256;
    
    address payable public adminIDO;
    address payable public preSaleOwner;
    address public pairLocker;
    address public IDO;
    address [] public users;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    IERC20 public pair;
    IERC20 public token;
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

    bool public allow;
    bool public canClaim;
    bool public teamenabled;

    struct Team{
        uint256 Claimed;
        uint256 Claimable;
        uint256 LastClaimTime;
    }

    mapping(address => Team) public TeamContribution;
    mapping(address => uint256) public bnbBalance;
    mapping(address => bool) public whitelisted;
    address [] public team;
     

    modifier onlyadminIDO(){
        require(msg.sender == adminIDO,"PinkSale: Not an adminIDO");
        _;
    }

    modifier onlypreSaleOwner(){
        require(msg.sender == preSaleOwner,"PinkSale: Not a token owner");
        _;
    }

    modifier allowed(){
        require(allow == true,"PinkSale: Not allowed");
        _;
    }
    
    
    event tokenBought(address indexed user, uint256 indexed amountBNB);

    event tokenClaimed(address indexed user, uint256 indexed numberOfTokens);

    event bnbClaimed(address indexed user, uint256 indexed balance);

    event tokenUnSold(address indexed user, uint256 indexed numberOfTokens);

    constructor() {
        IDO = msg.sender;
        allow = true;
        adminIDO = payable(0x1bF99f349eFdEa693e622792A3D70833979E2854);
    }

    // called once by the IDO contract at time of deployment
    function initialize(
        address _preSaleOwner,
        IERC20 _token,
        address _routerAddress,
        address _pairLocker,
        bool _team,
        uint256 [7] memory pinkvalues,
        uint256 [4] memory values
        
        
    ) external {
        require(msg.sender == IDO, "PinkSale: FORBIDDEN"); // sufficient check
        preSaleOwner = payable(_preSaleOwner);
        token = _token;
        
        preSaleStartTime = values[0];
        preSaleEndTime = values[1];
        softCap = values[2];
        liquidityPercent = values[3];
        routerAddress = IPancakeRouter02(_routerAddress);
        preSaleAmount = pinkvalues[0];
        pairLockDuration = pinkvalues[1];
        teamAmount = pinkvalues[2];
        teamStartDuration = pinkvalues[3];
        initialPercentageTeam = pinkvalues[4];
        cyclePercentageTeam = pinkvalues[5];
        cyclePeriodTeam = pinkvalues[6];
        teamenabled = _team;
        pairLocker = _pairLocker;
    }

    receive() payable external{}
    
    // to buy token during preSale time => for web3 use
    function buyToken() public payable allowed isHuman{
        require(block.timestamp <= preSaleEndTime,"PinkSale: Time over"); // time check
        require(block.timestamp >= preSaleStartTime,"PinkSale: Time not Started"); // time check
        if(bnbBalance[msg.sender] == 0){
            totalUser++;
            users.push(msg.sender);
        }
        bnbBalance[msg.sender] = bnbBalance[msg.sender].add(msg.value);
        amountRaised = amountRaised.add(msg.value);

        emit tokenBought(msg.sender, msg.value);
    }

    function internalclaim(address _user) internal {
        require(block.timestamp > preSaleEndTime,"PinkSale: Presale not over");
        require(canClaim == true,"PinkSale: pool not initialized yet");

        if(amountRaised < softCap){
            uint256 Balance = bnbBalance[_user];
            require(Balance > 0,"PinkSale: Zero balance");
        
            payable(_user).transfer(Balance);
            bnbBalance[_user] = 0;

            emit bnbClaimed(_user, Balance);
        }
        if(bnbBalance[_user] > 0 && amountRaised >= softCap) {
            require(bnbBalance[_user] > 0,"PinkSale: Zero balance");
            uint256 numberOfTokens = preSaleAmount.mul(bnbBalance[_user]).div(amountRaised);
            require(numberOfTokens > 0,"PinkSale: Zero balance");
        
            token.transfer(_user, numberOfTokens);
            bnbBalance[_user] = 0;

            emit tokenClaimed(_user, numberOfTokens);
        }
        if(_checkteam(_user) && amountRaised >= softCap && teamenabled){
            require(teamenabled,"PinkSale: Team not enabled");
            require(block.timestamp > preSaleEndTime.add(teamStartDuration),"PinkSale: Team not started");
            require(TeamContribution[_user].Claimed < amountPerMember,"PinkSale: Already claimed");
            require(teamContributionClaimable(_user) > 0,"PinkSale: No more claimable");
            token.transfer(_user, teamContributionClaimable(_user));
            TeamContribution[_user].Claimed += teamContributionClaimable(_user);
            TeamContribution[_user].LastClaimTime = block.timestamp;
            
        }
    }
    function claim() public allowed isHuman{
        internalclaim(msg.sender);
    }
    
    function withdrawAndInitializePool() public onlypreSaleOwner allowed isHuman{
        require(block.timestamp > preSaleEndTime,"PinkSale: PreSale not over yet");
        canClaim = true;
        if(amountRaised >= softCap){
            uint256 bnbAmountForLiquidity = amountRaised.mul(liquidityPercent).div(100);
            uint256 tokenAmountForLiquidity = listingTokens();
            token.approve(address(routerAddress), tokenAmountForLiquidity);
            addLiquidity(tokenAmountForLiquidity, bnbAmountForLiquidity);
            pair = IERC20(IPancakeswapV2Factory(address(routerAddress.factory())).getPair(address(token),routerAddress.WETH()));
            unLockTime = block.timestamp.add(pairLockDuration);
            pair.approve(pairLocker,pair.balanceOf(address(this)));
            Locker(pairLocker).lock(address(pair),preSaleOwner,pair.balanceOf(address(this)),unLockTime);
            preSaleOwner.transfer(getContractBnbBalance());
            if(teamenabled){
                amountPerMember = teamAmount.div(team.length);
                initialClaimableTeam = amountPerMember.mul(initialPercentageTeam).div(100);
                tokenPerCycleTeam = (amountPerMember).mul(cyclePercentageTeam).div(100);
                }
                
        }else{
            token.transfer(preSaleOwner, getContractTokenBalance());

            emit tokenUnSold(preSaleOwner, getContractBnbBalance());
        }
    }    
    
    function addLiquidity(
        uint256 tokenAmount,
        uint256 bnbAmount
    ) internal {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // add the liquidity
        pancakeRouter.addLiquidityETH{value : bnbAmount}(
            address(token),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
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
        return bnbBalance[_user];
    }

    // to Stop preSale in case of scam
    function setAllow(bool _enable) external onlyadminIDO{
        allow = _enable;
    }
    
    function getContractBnbBalance() public view returns(uint256){
        return address(this).balance;
    }
    
    function getContractTokenBalance() public view returns(uint256){
        return token.balanceOf(address(this));
    }
    
    function distriburte(uint256 startindex,uint256 endindex) external onlypreSaleOwner  allowed{
        require(canClaim == true,"PinkSale: pool not initialized yet");
        require(startindex < endindex,"PinkSale: startindex should be less than endindex");
        require(endindex <= users.length,"PinkSale: endindex should be less than users.length");
        require(startindex >= 0,"PinkSale: startindex should be greater than 0");
        require(endindex >= 0,"PinkSale: endindex should be greater than 0");
        for(uint256 i = startindex; i < endindex; i++){
            if(users[i] != address(0)){
                internalclaim(users[i]);
            }
        }
    }
    function teamContributionClaimable(address _user) public view returns(uint256 claimable){
        require(teamenabled,"PinkSale: Team not enabled");
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
        require(teamenabled,"PinkSale: Team not enabled");
        require(block.timestamp < preSaleEndTime,"PinkSale: preSale ended");
        for(uint256 i = 0; i < _team.length; i++){
            team.push(_team[i]);
            TeamContribution[_team[i]].LastClaimTime = preSaleEndTime.add(teamStartDuration);
        }
    }
    function removeteam(address [] memory _team) external onlypreSaleOwner allowed{
        require(teamenabled,"PinkSale: Team not enabled");
        require(block.timestamp < preSaleEndTime,"PinkSale: preSale ended");
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

pragma solidity 0.8.9;

//SPDX-License-Identifier: MIT Licensed

interface Locker {

    function lock(address _Pair,address _owner,uint256 _amount,uint256 _unlocktime) external returns(bool);

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
        IERC20 _token,
        address _routerAddress,
        address _pairLocker,
        bool team,
        uint256 [7] memory pinkvalues,
        uint256 [4] memory values
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
        address _pairLocker,
        bool [4] memory pinkenables,
        uint256 [10] memory pinkvalues,
        uint256 [9] memory values
    ) external ;
    

    
}

// interface IPreSaleSimple{

//     function owner() external view returns(address);
//     function tokenOwner() external view returns(address);
//     function deployer() external view returns(address);
//     function token() external view returns(address);
//     function busd() external view returns(address);

//     function tokenPrice() external view returns(uint256);
//     function preSaleTime() external view returns(uint256);
//     function claimTime() external view returns(uint256);
//     function minAmount() external view returns(uint256);
//     function maxAmount() external view returns(uint256);
//     function softCap() external view returns(uint256);
//     function hardCap() external view returns(uint256);
//     function listingPrice() external view returns(uint256);
//     function liquidityPercent() external view returns(uint256);

//     function allow() external view returns(bool);

//     function initialize(
//          address _preSaleOwner,
//         IERC20 _token,
//         address _routerAddress,
//         IERC20 _antibotToken,
//         bool [3] memory pinkenables,
//         uint256 [2] memory pinkvalues,
//         uint256 [9] memory values
//     ) external ;
    

    
// }
// interface IPreSaleContribution{

//     function owner() external view returns(address);
//     function tokenOwner() external view returns(address);
//     function deployer() external view returns(address);
//     function token() external view returns(address);
//     function busd() external view returns(address);

//     function tokenPrice() external view returns(uint256);
//     function preSaleTime() external view returns(uint256);
//     function claimTime() external view returns(uint256);
//     function minAmount() external view returns(uint256);
//     function maxAmount() external view returns(uint256);
//     function softCap() external view returns(uint256);
//     function hardCap() external view returns(uint256);
//     function listingPrice() external view returns(uint256);
//     function liquidityPercent() external view returns(uint256);

//     function allow() external view returns(bool);

//     function initialize(
//         address _preSaleOwner,
//         IERC20 _token,
//         address _routerAddress,
//         IERC20 _antibotToken,
//         bool [3] memory pinkenables,
//         uint256 [5] memory pinkvalues,
//         uint256 [9] memory values 

//     ) external ;
    

    
// }
// interface IPreSaleTeam{

//     function owner() external view returns(address);
//     function tokenOwner() external view returns(address);
//     function deployer() external view returns(address);
//     function token() external view returns(address);
//     function busd() external view returns(address);

//     function tokenPrice() external view returns(uint256);
//     function preSaleTime() external view returns(uint256);
//     function claimTime() external view returns(uint256);
//     function minAmount() external view returns(uint256);
//     function maxAmount() external view returns(uint256);
//     function softCap() external view returns(uint256);
//     function hardCap() external view returns(uint256);
//     function listingPrice() external view returns(uint256);
//     function liquidityPercent() external view returns(uint256);

//     function allow() external view returns(bool);

//     function initialize(
//        address _preSaleOwner,
//         IERC20 _token,
//         address _routerAddress,
//         IERC20 _antibotToken,
//         bool [3] memory pinkenables,
//         uint256 [7] memory pinkvalues,
//         uint256 [9] memory values

//     ) external ;
    

    
// }
// interface IPreSaleFairSimple{

//     function owner() external view returns(address);
//     function tokenOwner() external view returns(address);
//     function deployer() external view returns(address);
//     function token() external view returns(address);
//     function busd() external view returns(address);

//     function tokenPrice() external view returns(uint256);
//     function preSaleTime() external view returns(uint256);
//     function claimTime() external view returns(uint256);
//     function minAmount() external view returns(uint256);
//     function maxAmount() external view returns(uint256);
//     function softCap() external view returns(uint256);
//     function hardCap() external view returns(uint256);
//     function listingPrice() external view returns(uint256);
//     function liquidityPercent() external view returns(uint256);

//     function allow() external view returns(bool);

//     function initialize(
//         address _preSaleOwner,
//         IERC20 _token,
//         address _routerAddress,
//         uint256 [2] memory pinkvalues,
//         uint256 [4] memory values
//     ) external ;
    

    
// }

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