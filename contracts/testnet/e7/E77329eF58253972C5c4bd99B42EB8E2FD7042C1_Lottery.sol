/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.14;

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
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  function mintBox(address recipient, string memory tokenURI) external returns (uint256);

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
library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Lottery is Ownable {
    using SafeMath for uint256;

    uint256 public _totalUsers;
    uint256 public _buyAmount;
    uint256 public _totalToken;
    uint256 public _winNumber;
    uint256 public _winerNumber;
    bool public isStop;

    mapping(uint=> address[]) private _players;
    mapping(address=> bool) private _playerMaps;
    mapping(address=> bool) private _isClaimed;

    
    address public dealer;
    IERC20  public token;

    event Bet(address,uint256);
    event StopGame(uint256);
    event ClaimPrize(address,uint256);

    modifier onlyDealer() {
        require(msg.sender == dealer, 'Invalid Caller');
        _;
    }

    constructor() {
        dealer = owner();
    }

    function playGame(uint betNumber) external {

        require( !isStop, "game is closed.");
        require( betNumber >= 0 && betNumber <=99, "Betting number from 0-99");
        require(msg.sender != owner(), "Dealer cannot be player");
        require(!_playerMaps[msg.sender], "1 player can bet only 1 time.");
        require(_totalUsers <= 100, "max 100 players at the same time.");

        require (token.allowance(msg.sender,address(this)) >= _buyAmount, "You have to approve first!");
        require(token.transferFrom(msg.sender, address(this), _buyAmount), "No Enough Money");


        _playerMaps[msg.sender] = true;
        _players[betNumber].push(msg.sender);
        _totalUsers = _totalUsers.add(1);
        _totalToken = _totalToken.add(_buyAmount);

        emit Bet(msg.sender,betNumber);
    }

    function stopGame() external onlyDealer{
        require( !isStop, "Game is stopped.");
        uint256 totalBalance = token.balanceOf(address(this));
        uint256 dealerProfit = totalBalance.mul(10).div(100);//10% of total Deposit

        //Win random number
        _winNumber = block.timestamp % 100;
        _winerNumber = _players[_winNumber].length;

        if (_winerNumber == 0) {
            token.transfer(dealer,totalBalance);
        } else {
            token.transfer(dealer,dealerProfit);
        }

        isStop = true;
        emit StopGame(_winNumber);
    }

    function claimReward() external returns(bool){
        require( isStop, "Game is progressing");
        require(_players[_winNumber].length > 0, "There is no player who won the prize");
        require(!_isClaimed[msg.sender], "You have claimed the prize");

        uint256 prizePerPlayer = _players[_winNumber].length == 1 ? token.balanceOf(address(this)) : token.balanceOf(address(this)).div(_players[_winNumber].length);
        for(uint i = 0 ; i<_players[_winNumber].length; i++) {
                if (_players[_winNumber][i] == msg.sender) {
                   token.transfer(_players[_winNumber][i], prizePerPlayer);
                   _isClaimed[msg.sender] = true;
                   emit ClaimPrize(msg.sender, prizePerPlayer);
                   return true;
                }
        }
        revert("You are not a winer");
    }

    //Get Users who won the prize 
    function getWonUsers() public view returns(address[] memory) {
        return _players[_winNumber];
    }

    //Get Win Number 
    function getWinNumber() public view returns(uint256) {
        return _winNumber;
    }

    //Start again , only for emergency case
    function startAgain() external onlyDealer onlyOwner{
        require (isStop, "The Game is progressing. Don't need to Start again");
        isStop = false;
    }

    //Get total Token that players have deposited
    function getTotalToken() public view returns(uint256) {
        return _totalToken;
    }

    //Set token for depositing
    function setToken(address _token) external onlyDealer onlyOwner{
        require (isContract(_token), "Invalid Token");
        token = IERC20(_token);
    }

    //Set amount token per ticket
    function setTokenAmount(uint256 _amount) external onlyDealer onlyOwner{
        require (_amount > 0, "Invalid Token");
        _buyAmount = _amount;
    }

    //Change Dealer , only Owner can do this
    function changeDealer(address _dealer) external onlyOwner {
        require(isContract(_dealer), "Invalid Param");
        dealer = _dealer;
    }

    //Setup for the new game
    function loterrySetup(address _token, uint256 _amount) external onlyDealer onlyOwner {
        require (isContract(_token), "Invalid Token");
        require (_amount > 0, "Invalid Token");
        _totalUsers = 0;
        _buyAmount = 0;
        _totalToken = 0;
        _winNumber = 100;
        _winerNumber = 0;
        isStop = false;
        token = IERC20(_token);
        _buyAmount = _amount;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}