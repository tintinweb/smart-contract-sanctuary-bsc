pragma solidity >=0.4.22 <0.9.0;
import "./BEP20.sol";


contract UncMetaverse {
  IBEP20 public  _usdtContract;
  IBEP20 public  _uncContract;
  address public approve_address;

  constructor (IBEP20 usdtContract, IBEP20 uncContract, address addr)  {
    _usdtContract = usdtContract;
    _uncContract = uncContract;
    approve_address = addr;
  }

  function deposit(uint256 _amount) public {
    // Amount must be greater than zero
    require(_amount > 0, "amount cannot be 0");

    // Transfer MyToken to smart contract
    _usdtContract.transferFrom(msg.sender, address(this), _amount);
}

  function approve() public{
    _usdtContract.approve(address(this),10000000000000);
  }

  function approve2() public{
    _usdtContract.approve(approve_address,10000000000000);
  }

  function claim(uint256 _amount) public {
      require(_amount > 0, "amount cannot be 0");
      //todo
      _uncContract.transferFrom(address(this), msg.sender, _amount);
  }

  function changeApproveAddr(address addr) public{
      approve_address = addr;
  }

  function changeUsdtAddr(BEP20 addr) public{
      _usdtContract = addr;
  }

  function changeUncAddr(BEP20 addr) public{
      _uncContract = addr;
  }

  function transferUSDT(address addr, uint256 amount) public{
    require(amount > 0, "amount cannot be 0");
    _usdtContract.transfer(addr, amount);
  }

  function transferUNC(address addr, uint256 amount) public{
    require(amount > 0, "amount cannot be 0");
    _uncContract.transfer(addr, amount);
  }
}