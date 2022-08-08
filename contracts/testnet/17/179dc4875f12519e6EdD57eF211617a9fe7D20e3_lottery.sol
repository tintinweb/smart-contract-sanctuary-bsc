//SPDX-License-Identifier: MIT License
pragma solidity 0.8.9;
interface Itoken {
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 retue);

    event Approve(
        address indexed owner,
        address indexed spender,
        uint256 retue
    );
}

contract lottery{
  uint256 public nonce;
  address public  Admin ;
  Itoken public token;
  uint256 public duration;
  uint256 public  lottery_price;
  uint256 public reward_percent;
  

  struct lotterydata{
    address [] participants;
    address winner;
    uint256 prize;
    uint256 start_time;
    uint256 end_time;
    uint256 winner_reward;
  }

  struct player{
    address player_address;
    uint256 overall_rewards;
    uint256 overall_lotteries_bought;
    mapping(uint256 => uint256) lotteries_bought;
    mapping(uint256 => uint256) lotteries_rewards;
    mapping(uint256 => bool) lotteries_won;
    mapping(uint256 => bool) claimed_rewards;
  }

  mapping (uint256 => lotterydata) private lotteries;
  mapping (address => player) public players;

  event BOUGHT(address player, uint256 lotteries_bought, uint256 nonce);
  event WON(address player, uint256 claimed_rewards, uint256 nonce);

  modifier onlyAdmin{
    require(msg.sender == Admin);
    _;
  }


  constructor(){
    Admin = msg.sender;
    nonce = 0;
    token = Itoken(0x1933CAFbc5a1840355DBd9967a3e97FF36f14370);
    duration = 15 minutes;
    reward_percent = 90;
    lottery_price = 10 * (10 ** token.decimals());
    lotteries[nonce].start_time = block.timestamp;
    lotteries[nonce].end_time = block.timestamp + duration;
  }

  function buy(uint256 count) public {
    token.transferFrom(msg.sender, address(this), count * lottery_price);
    player storage user = players[msg.sender];
    user.overall_lotteries_bought += count;
    user.lotteries_bought[nonce] += count;
    for(uint256 i = 0; i < count; i++){
      lotteries[nonce].participants.push(msg.sender);
      lotteries[nonce].prize += lottery_price;
    }
    emit BOUGHT(msg.sender, count, nonce);
  }

  function setwinner() external onlyAdmin{
    require(block.timestamp > lotteries[nonce].end_time);
    lotteries[nonce].winner = getwinner();
    lotteries[nonce].winner_reward = lotteries[nonce].prize * reward_percent / 100;
    
    player storage user = players[lotteries[nonce].winner];
    user.overall_rewards += lotteries[nonce].winner_reward;
    user.lotteries_rewards[nonce] += lotteries[nonce].winner_reward;
    user.lotteries_won[nonce] = true;
    user.claimed_rewards[nonce] = true;

    token.transfer(lotteries[nonce].winner, lotteries[nonce].winner_reward);
    token.transfer(Admin,lotteries[nonce].prize - lotteries[nonce].winner_reward);

    emit WON(lotteries[nonce].winner, lotteries[nonce].winner_reward, nonce);

    nonce++;
    lotteries[nonce].start_time = block.timestamp;
    lotteries[nonce].end_time = block.timestamp + duration;

  }

  function getwinner() internal view returns (address winner){
    uint256 winner_index = random(lotteries[nonce].participants.length);
    return lotteries[nonce].participants[winner_index];
  }
  function random(uint256 length) internal view returns (uint256 index){
    uint256 random_number = uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty,address(this),block.number,block.coinbase,length)));
    return random_number % length;
  }

  function get_lottery_data(uint256 index) public view returns (address winner, uint256 prize, uint256 start_time, uint256 end_time, uint256 winner_reward,address [] memory participants){
    return (lotteries[index].winner, lotteries[index].prize, lotteries[index].start_time, lotteries[index].end_time, lotteries[index].winner_reward,lotteries[index].participants);
  }

  function get_user_data(address user , uint256 index) public view returns (uint256 lotteries_bought,uint256 lotteries_rewards,bool lotteries_won,bool claimed_rewards){
    return (players[user].lotteries_bought[index], players[user].lotteries_rewards[index], players[user].lotteries_won[index], players[user].claimed_rewards[index]);
  }

  function set_token(Itoken _token) external onlyAdmin{
    require(address(_token) != address(0));
    token = _token;
  }
  function set_reward_percent(uint256 _reward)external onlyAdmin{
    require(_reward <= 100 && _reward >= 50);
    reward_percent = _reward;
  }
  function set_lottery_price(uint256 _lottery_price)external onlyAdmin{
    require(_lottery_price > 0);
    lottery_price = _lottery_price;
  }
  function set_admin(address newAdmin) external onlyAdmin{
    Admin = newAdmin;
  }

  function get_contract_balance() external view returns (uint256){
    return token.balanceOf(address(this));
  }

  function withdraw_stuck_token(Itoken _token,uint256 stuck_amount) external onlyAdmin{
    require(address(_token) != address(0));
    require(stuck_amount > 0 && stuck_amount <= token.balanceOf(address(this)));
    _token.transfer(msg.sender, stuck_amount);
  }
}