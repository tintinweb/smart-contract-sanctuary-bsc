/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Ownable {
  address private owner;

  event OwnershipTransferred(
    address indexed oldOwner,
    address indexed newOwner
  );

  constructor() {
    owner = msg.sender;
  }

  // 只有 owner 才能调用的方法
  modifier onlyOwner() {
    require(msg.sender == owner, "Ownable: caller is not the owner");
    _;
  }

  function currentOwner() public view returns (address) {
    return owner;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    owner = newOwner;
    emit OwnershipTransferred(owner, newOwner);
  }
}

interface ERC20Token {
  function transferFrom(
    address,
    address,
    uint256
  ) external returns (bool);
}

contract ExTool is Ownable {
  mapping(address => bool) private masterMap;

  event SetMaster(address indexed masterAddr, bool indexed valid);
  event BatchTokens(
    address indexed sender,
    uint256 indexed count,
    uint256 indexed successCount
  );

  modifier onlyMaster() {
    require(masterMap[msg.sender], "caller is not the master");
    _;
  }

  constructor() {
    addMaster(msg.sender);
  }

  receive() external payable {}

  fallback() external payable {}

  function addMaster(address addr) public onlyOwner {
    require(addr != address(0));

    masterMap[addr] = true;
    emit SetMaster(addr, true);
  }

  function delMaster(address addr) public onlyOwner {
    require(addr != address(0) && masterMap[addr]);

    masterMap[addr] = false;
    emit SetMaster(addr, false);
  }

  function isMaster(address addr) public view onlyOwner returns (bool) {
    require(addr != address(0));

    return masterMap[addr];
  }

  // 批量转账
  // 在调用方法的时候，往合约里面传 eth，平分发给所有账户
  function transferEthsAvg(address payable[] calldata tos)
    public
    payable
    onlyMaster
    returns (bool)
  {
    require(tos.length > 0, "length is zero");
    require(msg.value > 0, "value is zero");

    uint256 vv = msg.value / tos.length;
    for (uint256 i = 0; i < tos.length; i++) {
      tos[i].transfer(vv);
    }

    return true;
  }

  // 批量转账
  // 在调用方法的时候，往合约里面传 eth，给每个地址转账的数量根据参数 values 来决定
  function transferEths(
    address payable[] calldata tos,
    uint256[] calldata values
  ) public payable onlyMaster returns (bool) {
    require(tos.length > 0, "length is zero");
    require(msg.value > 0, "value is zero");
    require(tos.length == values.length);

    // 检查金额是否充足
    uint256 total = 0;
    for (uint256 i = 0; i < tos.length; i++) {
      total += values[i];
    }

    require(msg.value >= total, "value is not enough");

    for (uint256 i = 0; i < tos.length; i++) {
      tos[i].transfer(values[i]);
    }

    return true;
  }

  // 直接转账
  function transferEth(address payable to)
    public
    payable
    onlyMaster
    returns (bool)
  {
    require(to != address(0));

    to.transfer(msg.value);

    return true;
  }

  // 将合约中的余额提取到指定账户
  function withdraw(address payable to)
    public
    payable
    onlyMaster
    returns (bool)
  {
    require(to != address(0));

    to.transfer(address(this).balance);

    return true;
  }

  // 检查当前余额
  function checkBalance() public view onlyMaster returns (uint256) {
    return address(this).balance;
  }

  // 销毁合约
  function destroy() public onlyOwner {
    selfdestruct(payable(msg.sender));
  }

  // 批量发放
  // 给所有地址发放指定 token，每个地址收到的数量为参数 value
  function transferTokensAvg(
    address from,
    address tokenAddr,
    address[] calldata tos,
    uint256 value
  ) public onlyMaster returns (bool) {
    require(tos.length > 0);

    ERC20Token token = ERC20Token(tokenAddr);
    uint256 sCount = 0;
    for (uint256 i = 0; i < tos.length; i++) {
      bool tResult = token.transferFrom(from, tos[i], value);
      if (tResult) {
        sCount += 1;
      }
    }

    emit BatchTokens(msg.sender, tos.length, sCount);

    return true;
  }

  // 批量发放
  // 给所有地址发放指定 token，每个地址收到的数量根据参数 values
  function transferTokens(
    address from,
    address tokenAddr,
    address[] calldata tos,
    uint256[] calldata values
  ) public onlyMaster returns (bool) {
    require(tos.length > 0);
    require(values.length == tos.length);

    ERC20Token token = ERC20Token(tokenAddr);
    uint256 sCount = 0;
    for (uint256 i = 0; i < tos.length; i++) {
      bool tResult = token.transferFrom(from, tos[i], values[i]);
      if (tResult) {
        sCount += 1;
      }
    }

    emit BatchTokens(msg.sender, tos.length, sCount);

    return true;
  }

  // 归集一个 token
  // 将多个地址的 token 归集到一个指定地址，数量根据参数 values
  function collect(
    address[] calldata froms,
    address tokenAddr,
    address to,
    uint256[] calldata values
  ) public onlyMaster returns (bool) {
    require(froms.length > 0);
    require(froms.length == values.length);
    require(to != address(0));

    ERC20Token token = ERC20Token(tokenAddr);
    uint256 sCount = 0;
    for (uint256 i = 0; i < froms.length; i++) {
      bool tResult = token.transferFrom(froms[i], to, values[i]);
      if (tResult) {
        sCount += 1;
      }
    }

    emit BatchTokens(msg.sender, froms.length, sCount);

    return true;
  }

  // 归集多个 token
  // 将多个地址的指定 token 归集到一个指定地址，token 地址和数量根据参数 tokenAddrs, values
  function collectMultipleTokens(
    address[] calldata froms,
    address[] calldata tokenAddrs,
    address to,
    uint256[] calldata values
  ) public onlyMaster returns (bool) {
    require(froms.length > 0);
    require(froms.length == tokenAddrs.length);
    require(froms.length == values.length);
    require(to != address(0));

    uint256 sCount = 0;
    for (uint256 i = 0; i < froms.length; i++) {
      bool tResult = ERC20Token(tokenAddrs[i]).transferFrom(
        froms[i],
        to,
        values[i]
      );
      if (tResult) {
        sCount += 1;
      }
    }
    emit BatchTokens(msg.sender, froms.length, sCount);
    return true;
  }

  // 单归集
  function transferTokenFrom(
    address from,
    address tokenAddr,
    address to,
    uint256 value
  ) public onlyMaster returns (bool) {
    require(from != address(0));
    require(to != address(0));

    // return callTransferToken(from, tokenAddr, to, value);
    return ERC20Token(tokenAddr).transferFrom(from, to, value);
  }

  // function callTransferToken(
  //     address from,
  //     address tokenAddr,
  //     address to,
  //     uint256 value
  // ) internal onlyMaster returns (bool) {
  //     require(from != address(0));
  //     require(to != address(0));

  //     bytes memory payload = abi.encodeWithSignature(
  //         "transferFrom(address,address,uint256)",
  //         from,
  //         to,
  //         value
  //     );
  //     (bool success, ) = tokenAddr.call(payload);

  //     return success;
  // }
}