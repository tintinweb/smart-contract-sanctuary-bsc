/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// File: Charging.sol


pragma solidity 0.8.17;

contract Charging {
  address private owner;
  mapping(string => address) stableCoins;

  event OwnerSet(address indexed oldOwner, address indexed newOwner);
  event Deposit(address from, string data);
  modifier isOwner() {
    require(msg.sender == owner, "Caller is not owner");
    _;
  }

  constructor() {
    owner = msg.sender;
    emit OwnerSet(address(0), owner);
    stableCoins["BUSD"] = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    stableCoins["USDT"] = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd;
    stableCoins["USDC"] = 0x64544969ed7EBf5f083679233325356EbE738930;
  }

  function changeOwner(address newOwner) public isOwner {
    emit OwnerSet(owner, newOwner);
    owner = newOwner;
  }

  function deposit(string memory tokenName, uint amount, string memory data) public {
    _validateTokenName(tokenName);
    require(amount > 0, "Amount is greater than 0");
    address _contract = stableCoins[tokenName];
    (bool allowanceSuccess, bytes memory allowanceResult) = _contract.call(
      abi.encodeWithSignature("allowance(address,address)", msg.sender, address(this))
    );

    require(allowanceSuccess, "Fail to check allowance coin");
    (uint256 allowance) = abi.decode(allowanceResult, (uint256));
    require(amount < allowance, "Amount BUSD is greater than allowance");

    (bool transferFromSuccess,) = _contract.call(
      abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(this), amount)
    );
    require(transferFromSuccess, "Fail to transfer coin");


    emit Deposit(msg.sender, data);
  }

  function withdraw(string memory tokenName, uint amount) public isOwner {
    _validateTokenName(tokenName);
    address _contract = stableCoins[tokenName];

    (bool balanceSuccess, bytes memory balanceResult) = _contract.call(
      abi.encodeWithSignature("balanceOf(address)", msg.sender)
    );
    require(balanceSuccess, "Get balance failed");

    (uint256 balance) = abi.decode(balanceResult, (uint256));
    require(amount <= balance, "Balance is not enought");

    (bool transferSuccess,) = _contract.call(
      abi.encodeWithSignature("transfer(address,uint256)", msg.sender, amount)
    );
    require(transferSuccess, "Withdraw failed");
  }

  function _compareStrings(string memory a, string memory b) private pure returns (bool) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
  }

  function _validateTokenName(string memory tokenName) private pure {
    require(
      _compareStrings(tokenName, "BUSD") ||
      _compareStrings(tokenName, "USDT") ||
      _compareStrings(tokenName, "USDC"),
      "Not support token");
  }

}