/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Stakeing {

    IERC20 public S_Token;
    IERC20 public R_Token;

    address public owner;

    modifier onlyOwner{
        require(msg.sender == owner,"Caller Must be Ownable!!");
        _;
    }

    uint256 public _bnb = 10000000000000000; //0.01
    uint256 public factor = 270;
    uint256 deno = 1000;

    struct Data {
        address _user;
        uint256 _stakedAmount;
        uint256 _time;
        uint256 _APYs;  
        uint256 _previousReward;
    }

    mapping (address => Data) public stakers;
    mapping (address => bool) Invested;

    constructor(address _StakeToken, address _RewardToken){
        S_Token = IERC20(_StakeToken);
        R_Token = IERC20(_RewardToken);
        owner = msg.sender;
    }

    function stake(uint256 _amount) public {

        S_Token.transferFrom(msg.sender,address(this),_amount);

        Data storage newupdate = stakers[msg.sender];

        if(Invested[msg.sender]){
            uint apy_s = newupdate._APYs;
            uint ml = calreward(newupdate._time);
            uint final_reward = ml * apy_s;
            newupdate._previousReward += final_reward;
        }

        newupdate._user = msg.sender;
        newupdate._stakedAmount += _amount;
        newupdate._time = block.timestamp;
        newupdate._APYs = calapy(newupdate._stakedAmount);

        Invested[msg.sender] = true;

    }

    function unstake(uint _pid) public payable {  //25% 50% 75%

        require(msg.value >= _bnb,"Needs to Pay 0.01 BNB fee for unstake!!");

        if(_pid == 1) {
            percent(250,msg.sender);
        }
        if(_pid == 2) {
            percent(500,msg.sender);
        }
        if(_pid == 3) {
            percent(750,msg.sender);
        }
        if(_pid == 3) {
            percent(1000,msg.sender);
            clear(msg.sender);
        }

        (bool os,) = payable(owner).call{value: msg.value}("");
        require(os,"Failed!!");
        
    }

    function totalReward(address _user) public view returns (uint){

        uint apy_s = stakers[_user]._APYs;
        uint ml = calreward(stakers[_user]._time);
        uint final_reward = ml * (apy_s);

        uint Total_Reward = final_reward + (stakers[_user]._previousReward);

        return Total_Reward;
    }

    function total_Balance(address _user,uint _pid) public view returns (uint256 _balance){
        uint totalStaked = stakers[_user]._stakedAmount;
        if(_pid == 1){
            return (totalStaked*250)/deno;
        }
        if(_pid == 2){
            return (totalStaked*500)/deno;
        }
        if(_pid == 3){
            return (totalStaked*750)/deno;
        }
    }

    function claim() public returns (bool) {
        address _person = msg.sender;
        uint claimable = totalReward(msg.sender);
        require(claimable > 0,"Invalid Reward Call!!");
        stakers[_person]._previousReward = 0;
        stakers[_person]._time = block.timestamp;
        R_Token.transfer(_person,claimable);
        return true;
    }

    function percent(uint _per,address _person) internal {

        Data storage newupdate = stakers[_person];

        uint apy_s = newupdate._APYs;
        uint ml = calreward(newupdate._time);
        uint final_reward = ml * (apy_s);

        uint Total_Reward = final_reward + (newupdate._previousReward);
        uint Total_Staked = newupdate._stakedAmount;

        uint hashper = (Total_Staked*_per)/deno;
        uint hashperre = (Total_Reward*_per)/deno;

        S_Token.transfer(_person,hashper);
        R_Token.transfer(_person,hashperre);

        newupdate._stakedAmount = newupdate._stakedAmount - hashper;
        newupdate._time = block.timestamp;
        newupdate._APYs = calapy(newupdate._stakedAmount);

        newupdate._previousReward = Total_Reward - hashperre;

    }

    function checkAllowance(address _user) public view returns (uint) {
        return S_Token.allowance(_user,address(this));
    }

    function Cont_balance(uint _pid) public view returns (uint _bal)  {
        if(_pid == 1){
            return S_Token.balanceOf(address(this));
        }
        if(_pid == 2){
            return R_Token.balanceOf(address(this));
        }
        else{
            require(false,"Invalid Selection!!");
        }
    }

    function calreward(uint _time) internal view returns (uint) {
        uint sec = block.timestamp - _time;
        return sec;
    }

    function transferOwnership(address _newOwner) external onlyOwner{
        owner = _newOwner;
    }

    function calapy(uint _amount) internal view returns (uint){
        uint num = _amount * (factor) / (1000);
        return num / (31536000);
    }

    function clear(address _person) internal {
        Data storage newupdate = stakers[_person];
        newupdate._stakedAmount = 0;
        newupdate._time = 0;
        newupdate._APYs = 0;
        newupdate._previousReward = 0;
        Invested[_person] = false;
    }

    function Emg_withdraw() public onlyOwner {
        S_Token.transfer(msg.sender,S_Token.balanceOf(address(this)));
        R_Token.transfer(msg.sender,R_Token.balanceOf(address(this)));
        (bool os,) = payable(msg.sender).call{value: address(this).balance}("");
        require(os,"Operation Failed!!");
    }   

    receive() external payable {}
}