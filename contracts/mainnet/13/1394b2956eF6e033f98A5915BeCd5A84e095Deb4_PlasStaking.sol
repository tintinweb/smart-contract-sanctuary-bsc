/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.4;
interface IBEP20 {
    function totalSupply() external view returns(uint256);
    function balanceOf(address who) external view returns(uint256);
    function allowance(address owner, address spender)
    external view returns(uint256);
    function transfer(address to, uint256 value) external returns(bool);
    function decimals() external returns(uint8);
    function approve(address spender, uint256 value)
    external returns(bool);
    function transferFrom(address from, address to, uint256 value)
    external returns(bool);
    function burn(uint256 amount) external;
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
contract PlasStaking {
    IBEP20 internal TokenInterfaces;
    struct PlayerExist {
        address addr;
    }
    struct Player {
        uint256 total_invested;
        uint256 total_withdrawn;
        bool exist;
        uint256 firstDeposit;
        uint256 amount;
        uint256 reward;
        uint256 witdrawn;
        uint256 last_payout;
    }
    address public owner;
    address private address_fee;
    uint256 public invested;
    uint256 public rewardToken;
    uint256 public valueLock;
    uint256 public withdrawn;
    uint256 private _fee = 175;
    uint256 public last_rate;
    //package 
    string public stake_name = "gallon";
    uint256 pkg = 2;
    uint256 min_keep = 182 days;
    //
    uint256 total_fee = 0;
    PlayerExist[] public exists;
    uint256 public alluser;
    uint256 public reward;
    mapping(address => Player) public players;
    event NewDeposit(address indexed addr, uint256 amount, uint256 package);
    event Restake(address indexed addr, uint256 amount, uint256 package);
    event Withdraw(address indexed addr, uint256 amount);
    event Unstake(address indexed addr, uint256 amount);
    event Take_fee(address indexed addr, uint256 amount);
    constructor(IBEP20 _addr, address _feeAddr) {
        TokenInterfaces = _addr;
        address_fee = _feeAddr;
        owner = msg.sender;
    }
    function balance() public view returns(uint256) {
        return (TokenInterfaces.balanceOf(address(this)));
    }
    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);
        Player storage player = players[_addr];
        if (payout > 0) {
                player.reward = player.amount * (uint256(block.timestamp) - player.last_payout) * (((last_rate - pkg)) - (((last_rate - pkg)) * pkg / 100)) / 365 / 864000000;
                player.last_payout = uint256(block.timestamp);
        }
    }
    function payoutOf(address _addr) view external returns(uint256 value) {
        return (_payoutOf(_addr));
    }
    function _getrate() private view returns(uint256) {
        uint256 c = (rewardToken * 100) / valueLock;
        if (c <= 10) {
            c = 10;
        }
        return c;
    }
    function updateRate() public returns(uint256, uint256) {
        require(msg.sender == owner, "fail");
        uint256 last = last_rate;
        last_rate = _getrate();
        return (last, _getrate());
    }
    function getRate() public view returns(uint256, uint256) {
        return (_getrate(), last_rate);
    }
   function deposit(uint256 _amount) external {
        require(_amount < TokenInterfaces.allowance(msg.sender, address(this)), "Please enable token");
        TokenInterfaces.transferFrom(msg.sender, address(this), _amount);
        _amount = _amount - (_amount * 7 / 100);
        _deposit(msg.sender, _amount);
    }
    function _deposit(address _addr, uint256 _amount) internal {
        Player storage player = players[_addr];
        uint256 fee = (_fee * _amount) / 100000;
        _amount -= fee;
        total_fee += fee;
        require(players[_addr].total_invested + _amount <= 1000e18, "Max 1000 token per user");

        if (players[_addr].exist) {
            player.amount += _amount;
            player.total_invested += _amount;
        } else {            
            player.total_invested += _amount;
            player.exist = true;
            exists.push(PlayerExist(_addr));
            alluser = exists.length;
            player.firstDeposit = uint256(block.timestamp);
            player.amount = _amount;
            player.last_payout = uint256(block.timestamp);
        }
        invested += _amount;
        _updatereward(msg.sender);
        valueLock += _amount;
        last_rate = _getrate();
    }
   function _restake(address _addr) external {
        require(msg.sender == _addr, "Wrong Address, its not your address");
        _payout(msg.sender);
        _updatereward(msg.sender);
        uint256 amount = 0;
        amount += _payoutOf(_addr);
        valueLock += amount;
        rewardToken -= amount;
        players[msg.sender].last_payout = uint256(block.timestamp);
        players[msg.sender].total_invested = amount;
        players[msg.sender].amount += amount;
    }
   function AddReward(uint256 _amt) external {
        require(msg.sender == owner, "Wrong Address, its not your address");
        TokenInterfaces.transferFrom(msg.sender, address(this), _amt);
        rewardToken += _amt;
   }
    function takeFee() external {
        require(total_fee > 0,"zero fee");
        TokenInterfaces.transfer(address_fee, total_fee);
        emit Take_fee(address_fee, total_fee);
        total_fee = 0;
   }
    function withdraw() external {
        Player storage player = players[msg.sender];
        _payout(msg.sender);
        uint256 amount = this.payoutOf(msg.sender);
        require(amount > 0, "Zero amount");
        uint256 fee = (_fee * amount) / 100000;
        amount -= fee;
        TokenInterfaces.transfer(msg.sender, amount);
        player.total_withdrawn += amount;
        player.last_payout = uint256(block.timestamp);
        withdrawn += amount;
        reward += amount;
        rewardToken -= amount;
        total_fee += fee;
        emit Withdraw(msg.sender, amount);
        for (uint256 i = 1; i <= 5; i++) {
            _updatereward(msg.sender);
        }
        last_rate = _getrate();
        player.reward = 0;
    }
   function unstake() external {
        Player storage player = players[msg.sender];
        require(_wdcheck(msg.sender), "u must keep till unlock period");
        _payout(msg.sender);
        uint256 amount = 0;
        amount = player.amount;
        amount += player.reward;
        require(amount > 0, "Zero amount");
        uint256 fee = (_fee * amount) / 100000;
        amount -= fee;
        total_fee += fee;
        TokenInterfaces.transfer(msg.sender, amount);
        reward += player.reward;
        player.amount = 0;
        player.reward = 0;
        player.total_invested = 0;
        player.total_withdrawn += amount;
        withdrawn += amount;
        valueLock -= amount;
        emit Unstake(msg.sender, amount);
        _update();
        last_rate = _getrate();
    }
    function _wdcheck(address _addr) view internal returns(bool) {
        Player storage player = players[_addr];
        bool wdavailable = false;
        if (block.timestamp > player.firstDeposit + min_keep) {
            wdavailable = true;
        }
        return wdavailable;
    }
    function timetowd(address _addr) external view returns(bool) {
        return (_wdcheck(_addr));
    }
    function _payoutOf(address _addr) view internal returns(uint256 value) {
        Player storage player = players[_addr];
        value += player.reward;
        uint256 from = player.last_payout;
        uint256 to = uint256(block.timestamp);
        if (from < to) {
            value += player.amount * (to - from) * (((last_rate - pkg)) - (((last_rate - pkg)) * pkg / 100)) / 365 / 864000000;
        }
        return value;
    }
    function _updatereward(address _addr) internal returns(uint256 value) {
        uint256 payout = this.payoutOf(_addr);
        Player storage player = players[_addr];
        if (payout > 0) {
            uint256 from = player.last_payout;
            uint256 to = uint256(block.timestamp);
            if (to - from >= 14400) {
                player.last_payout = uint256(block.timestamp);
                player.reward += _payoutOf(_addr);
                value++;
            }
        }
        return value;
    }
    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 first_Deposit) {
        Player storage player = players[_addr];
        uint256 payout = _payoutOf(_addr);
        total_invested += player.amount;
        return (
            payout,
            total_invested,
            player.total_withdrawn,
            player.firstDeposit
        );
    }
    function update() external returns(uint256) {
        return (_update());
    }
    function _update() internal returns(uint256 _total) {
        for (uint256 i = 0; i < exists.length; i++) {
            _total += _updatereward(exists[i].addr);
        }
    }
}