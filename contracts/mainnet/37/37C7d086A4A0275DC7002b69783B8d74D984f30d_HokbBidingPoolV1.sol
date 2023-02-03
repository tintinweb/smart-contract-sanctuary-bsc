/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IERC20 {
  function decimals() external pure returns (uint8);
  function approve(address spender, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IMinterRouter {
  function excretion(address adr,address to,uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender());
        _;
    }

    function transferOwnership(address account) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, account);
        _owner = account;
    }

}

contract HokbBidingPoolV1 is Context, Ownable {

  address public rewardToken = 0x3d02B82ACBC64dAD2c4d82768dfA42B12E26a74a;
  IERC20 token;
  
  address public minterRouter;
  uint256 public fee;
  uint256 denominator = 1000;

  uint256 public rewardPerRound;
  uint256 public currentRound;

  struct BidingPool {
    uint256 balance;
    uint256 endingin;
    bool paidstatus;
    address[] depositor;
  }

  mapping(uint256 => BidingPool) bidingpool;
  mapping(uint256 => uint256) public bid_amount;
  mapping(uint256 => uint256) public bid_deley;
  
  bool reentrantcy;
  modifier noReentrant() {
    require(!reentrantcy, "!REENTRANTCY");
    reentrantcy = true;
    _;
    reentrantcy = false;
  }

  constructor() {
    minterRouter = 0xe0F2dBfc2E1E09019942d07Dcc0f1B2C54553Cb9;
    fee = 300;
    token = IERC20(rewardToken);
    rewardPerRound = 3000 * (10**token.decimals());
    //normal bid
    bid_amount[1] = 500 * (10**token.decimals());
    bid_deley[1] = 60*60*24; //24 hours
    //rush bid
    bid_amount[1] = 1000 * (10**token.decimals());
    bid_deley[1] = 60*60*12; //12 hours
    //force bid
    bid_amount[1] = 2000 * (10**token.decimals());
    bid_deley[1] = 60*60*12; //6 hours
  }

  function getpooldata(uint256 roundid) public view returns (uint256,uint256,bool,address[] memory) {
    return (
        bidingpool[roundid].balance,
        bidingpool[roundid].endingin,
        bidingpool[roundid].paidstatus,
        bidingpool[roundid].depositor
    );
  }

  function setting(address _minterRouter,uint256 _fee,address _token,uint256 _reward) public onlyOwner returns (bool) {
    minterRouter = _minterRouter;
    fee = _fee;
    rewardToken = _token;
    token = IERC20(rewardToken);
    rewardPerRound = _reward;
    return true;
  }

  function changeBidAmount(uint256 id,uint256 amount,uint256 deley) public onlyOwner returns (bool) {
    bid_amount[id] = amount;
    bid_deley[id] = deley;
    return true;
  }

  function bidFor(address account,uint256 i) public returns (bool) {
    
    uint256 depositAmount = bid_amount[i];
    uint256 deleyBlock = bid_deley[i];

    require(depositAmount>0,"!ERROR: NOT FOUND PACKAGE");

    token.transferFrom(msg.sender,address(this),depositAmount);

    if(block.timestamp<bidingpool[currentRound].endingin){
        bidingpool[currentRound].balance += depositAmount;
        bidingpool[currentRound].depositor.push(account);
        bidingpool[currentRound].endingin = block.timestamp + deleyBlock;
    }else{
        processWinner(currentRound);
        IMinterRouter(minterRouter).excretion(rewardToken,address(this),rewardPerRound);
        currentRound += 1;
        bidingpool[currentRound].balance += rewardPerRound + depositAmount;
        bidingpool[currentRound].depositor.push(account);
        bidingpool[currentRound].endingin = block.timestamp + deleyBlock;
        }
    return true;
  }

  function forceClaim(uint256 round) public returns (bool) {
    require(!bidingpool[round].paidstatus,"!ERROR: ROUND WAS CLAIMED");
    require(block.timestamp>bidingpool[round].endingin,"!ERROR: ROUND WAS NOT ENDED");
    processWinner(round);
    return true;
  }

  function processWinner(uint256 round) internal {
    uint256 len = bidingpool[round].depositor.length;
    if(len>0 && !bidingpool[round].paidstatus){
        uint256 amount = bidingpool[round].balance;
        uint256 amountA = amount * fee / denominator;
        uint256 amountB = amount - amountA;
        IERC20(rewardToken).transfer(minterRouter,amountA);
        IERC20(rewardToken).transfer(bidingpool[round].depositor[len],amountB);
        bidingpool[round].paidstatus = true;
    }
  }

  function excretion(address adr,address to,uint256 amount) external onlyOwner returns (bool) {
    IERC20(adr).transfer(to,amount);
    return true;
  }

  function rescue(address adr) external onlyOwner {
    IERC20 a = IERC20(adr);
    a.transfer(msg.sender,a.balanceOf(address(this)));
  }

  function purge() external onlyOwner {
    (bool success,) = msg.sender.call{ value: address(this).balance }("");
    require(success, "Failed to send ETH");
  }
  
  receive() external payable { }
}