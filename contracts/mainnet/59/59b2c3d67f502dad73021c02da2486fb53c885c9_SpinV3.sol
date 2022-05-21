/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

/******************************************************************************************************************************

	 $$$$$$\                                 $$\                $$$$$$\                                
	$$  __$$\                                $$ |              $$  __$$\                               
	$$ /  \__| $$$$$$\  $$\   $$\  $$$$$$\ $$$$$$\    $$$$$$\  $$ /  \__|$$\   $$\ $$$$$$$\   $$$$$$\  
	$$ |      $$  __$$\ $$ |  $$ |$$  __$$\\_$$  _|  $$  __$$\ \$$$$$$\  $$ |  $$ |$$  __$$\ $$  __$$\ 
	$$ |      $$ |  \__|$$ |  $$ |$$ /  $$ | $$ |    $$ /  $$ | \____$$\ $$ |  $$ |$$ |  $$ |$$ /  $$ |
	$$ |  $$\ $$ |      $$ |  $$ |$$ |  $$ | $$ |$$\ $$ |  $$ |$$\   $$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |
	\$$$$$$  |$$ |      \$$$$$$$ |$$$$$$$  | \$$$$  |\$$$$$$  |\$$$$$$  |\$$$$$$$ |$$ |  $$ |\$$$$$$  |
	 \______/ \__|       \____$$ |$$  ____/   \____/  \______/  \______/  \____$$ |\__|  \__| \______/ 
						$$\   $$ |$$ |                                   $$\   $$ |                    
						\$$$$$$  |$$ |                                   \$$$$$$  |                    
						 \______/ \__|                                    \______/                     

Whether it's meme-coins or utility-based projects you're after, 
CryptoSyno aims to develop the primary go-to source for alternative cryptocurrency gambling.

Website: 
- https://cryptosyno.io/

Social Media Links:
- https://discord.gg/CryptoSyno
- https://twitter.com/CryptoSyno

For questions/concerns/inquiries, feel free to pop into the discord or email us at: [email protected]

Buy
- 1% Sent to burn address

Sell
- 1% Reflections
- 2% Sent to burn address
- 2% Sent to slot machine reward pool

Slot Machine Odds
- House odds 0.1% - 10% of the prize pool is sent to the dead address.
- Big win odds 0.1% - Win 10% of the prize pool.
- Standard win odds 8% - Win 1% of the prize pool.
- After 3 losses in a row, user is granted a 2x  odds increase. 
- Users will keep getting extra odds increase for every lose if their lose streak is 3+. 
- After winning any reward, probabilities will reset to normal.

Add your Own Token
- User submits token.
- Must be 18 decimals.
- Must select spin cost.
- Listing fee 777 CryptoSyno (Sent to dead address)

VIP STATUS
- x1000 $CSYN tokens sent to the dead address.
- Grants personalized remote concierge service.

******************************************************************************************************************************/

pragma solidity 0.8.9;
//SPDX-License-Identifier: MIT
interface IBEP20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract SpinV3{
    address payable public  owner;
    IBEP20 public listingtoken;

    uint256 public totalUsers;
    uint256 public totalSpins;
    uint256 public totalWins;
    uint256 public totalLosses;
    uint256 public VIPCost = 1000 ether;

    uint256 public StandardRewardPercentage = 1_000;
    uint256 public BigRewardPercentage = 10_000;
    uint256 public houseEdgeRewardPercentage = 10_000;

    uint256 public StandardwinChance = 1_200;
    uint256 public BigwinChance = 200;
    uint256 public houseEdgewinChance = 100;

    uint256 public maxlose = 3;
    uint256 public multiplier = 2;
    
    uint256 public percentDivider = 100_000;



    bool public isSpinning = true;

    struct SpinInfo{
        uint256 SpinCount;
        uint256 Reward;
        uint256 WinCount;
        uint256 LoseCount;
        uint256 rewardFactor;
        string LastSpin;
        bool VIP;
    }

    mapping (address => SpinInfo) public Player;
    mapping (address => uint256) public spinCost;

    address [] public users;
    address [] public winers;
    address [] public losers;
    address [] public  tokens;


    modifier onlyOwner{
        require(msg.sender == owner, "Only owner can do this");
        _;
    }
    modifier isSpin{
        require(isSpinning, "Spin is not started");
        _;
    }

    constructor(address _token){
        owner = payable(msg.sender);
        listingtoken = IBEP20(_token);
        tokens.push(_token);
        spinCost[_token] = 777 ether;
    }
    function recieve() external payable{
    }
    function Spin(IBEP20 _token,uint256 spincount) external {
        require(spincount > 0, "Spin count must be greater than 0");
        for(uint256 i = 0; i < spincount; i++){
            _spin(_token,msg.sender);
        }
    }
    function _spin(IBEP20 _token,address spiner) internal isSpin returns(bool success){
        SpinInfo storage user = Player[spiner];
        _token.transferFrom(spiner,address(this), spinCost[address(_token)]);
        bool win;
        uint256 _rewardPercentage;
        uint256 incFactor = 1;
        bool burn;
        if(user.rewardFactor > maxlose){
            for(uint256 i = maxlose; i < user.rewardFactor; i++){
                incFactor = incFactor * multiplier;
            }
        }
        uint256 _spinvalue =uint256(keccak256(abi.encodePacked(spiner,block.timestamp,block.difficulty,block.number))) % percentDivider;
            if(_spinvalue <= houseEdgewinChance){
            _rewardPercentage = houseEdgeRewardPercentage;
            burn = true;
            win = true;
            user.LastSpin = "HouseEdge";
            user.rewardFactor = 0;
        }else if(_spinvalue <= BigwinChance*incFactor){
            _rewardPercentage = BigRewardPercentage;
            win = true;
            user.LastSpin = "BigWin";
            user.rewardFactor = 0;
        }else if(_spinvalue <= StandardwinChance*incFactor){
            _rewardPercentage = StandardRewardPercentage;
            win = true;
            user.LastSpin = "StandardWin";
            user.rewardFactor = 0;
        }else{
            win = false;
            user.LastSpin = "Lose";
            user.rewardFactor += 1;
        }

        totalSpins++;
        if(user.SpinCount == 0) { 
            users.push(spiner); 
            totalUsers++; }
        if(win) { 
            winers.push(spiner); 
            totalWins++;
            user.Reward = user.Reward + _token.balanceOf(address(this))*_rewardPercentage/percentDivider; 
            if(burn){
                _token.transfer(address(0xdead),_token.balanceOf(address(this))*_rewardPercentage/percentDivider);
            }else{
                _token.transfer(spiner,_token.balanceOf(address(this))*_rewardPercentage/percentDivider);
            }
            user.SpinCount++;
            user.WinCount++; 
        }
        else{ 
            losers.push(spiner); 
            totalLosses++;
            user.SpinCount++;
            user.LoseCount++;
        }
           
        
        return win;
    }
    function setWinChances(uint256 _StandardwinChance, uint256 _BigwinChance, uint256 _houseEdgewinChance)external  onlyOwner{
        require(_StandardwinChance + _BigwinChance + _houseEdgewinChance <= percentDivider, "Sum of win chances must be less than 100%");
        StandardwinChance = _StandardwinChance;
        BigwinChance = _BigwinChance;
        houseEdgewinChance = _houseEdgewinChance;
    }
    function setlosingbonus(uint256 _maxlose,uint256 _multiplier)external  onlyOwner{
        maxlose = _maxlose;
        multiplier = _multiplier;
    }
    function setrewardPercentages(uint256 _StandardRewardPercentage, uint256 _BigRewardPercentage, uint256 _houseEdgeRewardPercentage)external  onlyOwner{
        require(_StandardRewardPercentage + _BigRewardPercentage + _houseEdgeRewardPercentage <= percentDivider, "Percentages must add up to 100%");
        StandardRewardPercentage = _StandardRewardPercentage;
        BigRewardPercentage = _BigRewardPercentage;
        houseEdgeRewardPercentage = _houseEdgeRewardPercentage;
    }
    function SetSpinCost(address _token ,uint256 _spinCost) onlyOwner public{
        require(_spinCost > 0, "spinCost must be greater than 0");
        spinCost[_token] = _spinCost;
    }
    function SetNewOwner(address payable _newOwner) onlyOwner public{
        require(_newOwner != address(0), "newOwner must be a valid address");
        owner = _newOwner;
    }
    function SetSpin(bool _isSpinning) onlyOwner public{
        isSpinning = _isSpinning;
    }
    function withdrawStuckTokens(IBEP20 token,uint256 amount) public onlyOwner{
        require(address(token) != address(0), "token must be a valid address");
        require(amount > 0, "amount must be greater than 0");
        require(token.balanceOf(address(this)) >= amount, "not enough tokens in contract");
        token.transfer(owner,amount);
    }
    function withdrawStuckBNB(uint256 amount) public onlyOwner{
        require(amount > 0, "amount must be greater than 0");
        require(address(this).balance >= amount, "not enough BNB in contract");
        owner.transfer(amount);
    }
    function GetCurrentTime() public view returns(uint256){
        return block.timestamp;
    }
    function GetContractTokenBalance(IBEP20 _token) public view returns(uint256){
        return _token.balanceOf(address(this));
    }
    function houseEdgeReward(IBEP20 _token) public view returns(uint256){
        return (GetContractTokenBalance(_token)*houseEdgeRewardPercentage)/percentDivider;
    }
    function BigWinReward(IBEP20 _token) public view returns(uint256){
        return (GetContractTokenBalance(_token)*(BigRewardPercentage))/percentDivider;
    }
    function StandardWinReward(IBEP20 _token) public view returns(uint256){
        return (GetContractTokenBalance(_token)*(StandardRewardPercentage))/percentDivider;
    }
    function GetContractBNBBalance() public view returns(uint256){
        return address(this).balance;
    }
    function GetUserLastSpin(address user) public view returns(string memory){
        
        return Player[user].LastSpin;
    }
    function VIPSERVICE()external{
        require(!Player[msg.sender].VIP, "You are already a VIP");
        listingtoken.transferFrom(msg.sender,address(0xdead),VIPCost);
        Player[msg.sender].VIP = true;
    }
    function GetUserVIP(address user) public view returns(bool){
        return Player[user].VIP;
    }
    function SetVIPCost(uint256 _VIPCost) onlyOwner public{
        VIPCost = _VIPCost;
    }
    function addtoken(address _token,uint256 _spinCost) public {
        require(address(_token) != address(0), "token must be a valid address");
        require(IBEP20(_token).decimals() == 18, "token must be a valid IBEP20 token");
        require(!contains(_token), "token already added");
        listingtoken.transferFrom(msg.sender,address(0xdead),spinCost[address(listingtoken)]);
        tokens.push(_token);
        spinCost[_token] = _spinCost;
    }
    function contains(address _token) public view returns(bool){
        for(uint i = 0; i < tokens.length; i++){
            if(tokens[i] == _token){
                return true;
            }
        }
        return false;
    }
    function length()public view returns(uint256 len){
        len = tokens.length;
    }
    function setlistingToken(IBEP20 _listingtoken) public onlyOwner{
        require(address(_listingtoken) != address(0), "token must be a valid address");
        listingtoken = _listingtoken;
        tokens[0] = address(listingtoken);
    }
}