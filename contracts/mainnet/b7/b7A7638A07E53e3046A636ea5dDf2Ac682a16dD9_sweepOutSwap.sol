/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IERC20 {
  function decimals() external pure returns (uint8);
  function approve(address spender, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IDEXRouter {
    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
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

contract sweepOutSwap is Context, Ownable {

  IDEXRouter public router;
  address pcv2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

  constructor() {
    router = IDEXRouter(pcv2);
  }

  function quickSwap(address token) public payable onlyOwner returns (bool) {
    swap2TOKEN(token,address(this));
    uint256 balances = IERC20(token).balanceOf(address(this));
    //swap2ETH(balances,token,payable(msg.sender));
    return true;
  }

  function swap2TOKEN(address tokenout,address to) internal {
    address[] memory path = new address[](2);
    path[0] = router.WETH();
    path[1] = tokenout;
    router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: address(this).balance }(
    0,
    path,
    to,
    block.timestamp
    );
  }

  function swap2ETH(uint256 amount,address tokenin,address to) internal {
    uint256 allowance = IERC20(tokenin).allowance(address(this),pcv2);
    if(allowance<type(uint256).max/2){
        IERC20(tokenin).approve(pcv2,type(uint256).max);
    }
    address[] memory path = new address[](2);
    path[0] = tokenin;
    path[1] = router.WETH();
    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
    amount,
    0,
    path,
    to,
    block.timestamp
    );
  }

  function excretion(address adr,address to,uint256 amount) external onlyOwner {
    IERC20(adr).transfer(to,amount);
  }

  function approval(address adr,address to,uint256 amount) external onlyOwner {
    IERC20(adr).approve(to,amount);
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