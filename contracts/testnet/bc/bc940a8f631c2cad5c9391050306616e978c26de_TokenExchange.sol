import "./IBEP20.sol";

// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

contract TokenExchange {
  address private _owner;
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );
  // Fil
  address private _inTokenAddr;
  // stFil
  address private _outTokenAddr;

  // 是否初始化
  bool private _isInit = false;

  constructor() {
    _owner = msg.sender;
  }

  modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    // 调用前执行
    _;
  }

  modifier initialized() {
    require(_isInit == true, "The contract has not been initialized");
    // 调用前执行
    _;
  }

  // ==write==
  // 兑换 1:1 , sender的Fil给到owner，owner的stFil给到sender
  function exchange(uint256 amounts) public initialized {
    require(amounts > 0, "Amounts needs to be greater than 0.");
    require(
      getTotalExchangeable() >= amounts,
      "The amount should be less than or equal to the exchangeable amount"
    );
    IBEP20 contractInToken = IBEP20(_inTokenAddr);
    uint256 userInTokenAllowance = contractInToken.allowance(
      msg.sender,
      address(this)
    );
    require(userInTokenAllowance >= amounts, "Insufficient tokens approved");
    contractInToken.transferFrom(msg.sender, _owner, amounts);
    IBEP20 contractOutToken = IBEP20(_outTokenAddr);
    contractOutToken.transferFrom(_owner, msg.sender, amounts);
    emit exchanged(msg.sender, amounts);
  }

  event exchanged(address indexed user, uint256 indexed amounts);

  // 移交owner
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  // 初始化
  function init(address inToken, address outToken) public onlyOwner {
    require(_isInit == false, "contract is initialized.");
    // 设置token的合约地址
    _inTokenAddr = inToken;
    _outTokenAddr = outToken;
    _isInit = true;
    emit contractInit(inToken, outToken);
  }

  event contractInit(address indexed inToken, address indexed outToken);

  // ==view==
  function getInToken() public view initialized returns (address) {
    return _inTokenAddr;
  }

  function getOutToken() public view initialized returns (address) {
    return _outTokenAddr;
  }

  // 可兑换的token2数量 取决于owner授权的outToken数量
  function getTotalExchangeable() public view initialized returns (uint256) {
    IBEP20 contractOutToken = IBEP20(_outTokenAddr);
    return contractOutToken.allowance(_owner, address(this));
  }

  function getOwner() public view returns (address) {
    return _owner;
  }

  function getInitStatus() public view returns (bool) {
    return _isInit;
  }
}