// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "IPancakeRouter02.sol";

interface ChiToken {
    function freeFromUpTo(address from, uint256 value) external;
}

contract UniswapExample {
  ChiToken constant public chi = ChiToken(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
  IPancakeRouter02 constant public uniRouter = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  address constant public multiDaiKovan = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;

  modifier discountCHI {
    uint256 gasStart = gasleft();

    _;

    uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
    chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41947);
  }
  
  function convertEthToDai(uint daiAmount) external payable {
    _convertEthToDai(daiAmount);
  }

  function convertEthToDaiWithGasRefund(uint daiAmount) external payable discountCHI {
    _convertEthToDai(daiAmount);
  }
  
  function getEstimatedETHforDAI(uint daiAmount) external view returns (uint256[] memory) {
    return uniRouter.getAmountsIn(daiAmount, _getPathForETHtoDAI());
  }

  function _getPathForETHtoDAI() private pure returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = uniRouter.WETH();
    path[1] = multiDaiKovan;
    
    return path;
  }
  
  function _convertEthToDai(uint daiAmount) private {
    // using 'now' for convenience in Remix, for mainnet pass deadline from frontend!
    uint deadline = block.timestamp + 15;

    uniRouter.swapETHForExactTokens{ value: msg.value }(
      daiAmount,
      _getPathForETHtoDAI(),
      address(this),
      deadline
    );
    
    // refund leftover ETH to user
    (bool success,) = msg.sender.call{ value: address(this).balance }("");
    require(success, "refund failed");
  }
  
  // important to receive ETH
  receive() payable external {}
}