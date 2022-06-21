/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface ISwapPair {
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

    function token0() external view returns (address);
    function token1() external view returns (address);
}
interface IInvitation {
    function getInvitation(address user) external view returns(address inviter, address[] memory invitees);
}


contract StakeImpl01 {

    uint256 private _totalStake;
    uint128 private _blockSupply;
    uint128 public _rewardPerToken;
    address private _pair;
    uint64 public _lastUpdate;
    address public _marketing;
    address constant public _token = 0xBc2e52ea811246c5Bf71F0BbF69749eE0A313cA6;
    address constant public _invitation = 0x1ed732A198f0e446Fc26e941ACc3e6Af46C948dA;

    struct User {
        uint stake;
        uint rewardPerToken;
        uint reward;
    }
    mapping(address=>User) public _users;

    event Stake(uint indexed amount);
    event Claim(address indexed sender, uint indexed amount);
    event Quit(uint indexed amount);

    modifier update() {
        _rewardPerToken = calRewardsPerToken();
        _lastUpdate = uint64(block.number);
        _;
    }

    function initialize(address pair, address marketing) external {
        require(_pair == address(0), "StakeImpl: only called once");
        _pair = pair;
        _marketing = marketing;
    }

    function calRewardsPerToken() public view returns(uint128) {
        uint perTokenIncrement;
        if (_blockSupply > 0 && _totalStake > 0){
            perTokenIncrement = (block.number - _lastUpdate) * _blockSupply * 1e10 / _totalStake;
        }
        return  uint128(perTokenIncrement + _rewardPerToken);
    }

    function calRewards(uint perToken, address account) internal view returns(uint){
        User memory user = _users[account];
        uint rewards = (perToken - user.rewardPerToken) * user.stake;

        if (rewards > 0) {
            rewards = rewards / 1e10;
        }
        return rewards;
    }

    function _claimable(address account) internal view returns(uint){
        uint perToken = calRewardsPerToken();
        return calRewards(perToken, account);
    }

    function claim(address account) public {
        uint rewards = _claimable(account);
        _users[account].reward = 0;
        emit Claim(msg.sender, rewards);

        uint fee = rewards / 10;
        ISwapPair(_token).transfer(account, rewards - fee);

        (address inviter,) = IInvitation(_invitation).getInvitation(account);
        if (inviter == address(0)) {
            ISwapPair(_token).transfer(_marketing, fee);
        }else{
            ISwapPair(_token).transfer(inviter, fee);
        }
    }

    function stake(uint amount) external {
        _stake(amount);
    }

    function stakeWithPermit(
        uint stake,
        uint approve,
        uint deadline,
        uint8 v, bytes32 r, bytes32 s
    ) external {
        ISwapPair(_pair).permit(msg.sender, address(this), approve, deadline, v, r, s);
        _stake(stake);
    }

    function _stake(uint amount) internal update {

        ISwapPair(_pair).transferFrom(msg.sender, address(this), amount);

        User storage user = _users[msg.sender];
        if (user.stake > 0) {
            user.reward = calRewards(_rewardPerToken, msg.sender);
        }

        user.rewardPerToken = _rewardPerToken;
        user.stake += amount;
        _totalStake += amount;

        emit Stake(amount);
    }

    function emergencyQuit() external {
        User storage user = _users[msg.sender];
        ISwapPair(_pair).transfer(msg.sender, user.stake);
        _totalStake -= user.stake;
        user.stake = 0;
        user.reward = 0;
    }

    function quit(uint amount) external update{

        claim(msg.sender);
        User storage user = _users[msg.sender];
        ISwapPair(_pair).transfer(msg.sender, amount);
        _totalStake -= amount;
        user.stake -= amount;
    }


    function setBlockSupply(uint128 supply) external update {
        _blockSupply = supply;
    }

    function setMarketing(address newMarketing) external {
        _marketing = newMarketing;
    }

    function getPair() external view returns(address) {
        return _pair;
    }

    function getBaseInfo(address account) external view returns(uint256 totalStake, uint128 blockSupply, uint256 userStake, uint userClaimable) {
        return(_totalStake, _blockSupply, _users[account].stake, _claimable(account));
    }
}