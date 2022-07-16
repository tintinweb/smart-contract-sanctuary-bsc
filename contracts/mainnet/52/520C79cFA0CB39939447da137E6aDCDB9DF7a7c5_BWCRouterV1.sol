/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IBEP20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function setIsFeeExempt(address holder, bool exempt) external;
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
    return msg.sender;
    }
}

contract Ownable is Context {
  address private _owner;
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
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract BWCRouterV1 is Context, Ownable {
  using SafeMath for uint256;

  mapping (address => bool) private tokensupport;

  bool private _reentrant;
  IPancakeRouter02 private router;

  address public recaiver;

  modifier noReentrant() {
    require(!_reentrant, "No re-entrancy");
    _reentrant = true;
    _;
    _reentrant = false;
  }

  address private BWC = 0xFEFe065667319Ab71c54e00C12F46229f10446fF;
  uint256 public swapfee;
  uint256 public feeDenominator;
  uint256 public bwcfee;
  uint256 public bwcDenominator;

  constructor() {
    recaiver = msg.sender;
    router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    swapfee = 5;
    feeDenominator = 1000;
    bwcfee = 200;
    bwcDenominator = 1000;
  }

  function BlueWolfSwapMulticall(address _token_input,address _token_output,uint256 _amountIn,uint256 _amountOut,uint256 _deley) external payable noReentrant returns (bool) {
    if(_token_input==router.WETH()){
      uint256 amountSwap = msg.value;
      payable(recaiver).transfer(takenfee(amountSwap,swapfee,feeDenominator));
      amountSwap = minusfee(amountSwap,swapfee,feeDenominator);
      address[] memory path = new address[](2);
      path[0] = router.WETH();
      path[1] = _token_output;
      router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountSwap}(
      _amountOut,
      path,
      msg.sender,
      block.timestamp.add(_deley)
      );
    }else if(_token_output==router.WETH()){
      IBEP20 tokeninput = IBEP20(_token_input);
      if(_token_input==BWC){
        IBEP20 tokenbwc = IBEP20(BWC);
        tokenbwc.setIsFeeExempt(msg.sender,true);
      }
      tokeninput.transferFrom(msg.sender,address(this),_amountIn);
      tokeninput.approve(address(router),type(uint256).max);
      uint256 balancebefore = address(this).balance;
      address[] memory path = new address[](2);
      path[0] = _token_input;
      path[1] = router.WETH();
      router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      _amountIn,
      _amountOut,
      path,
      address(this),
      block.timestamp.add(_deley)
      );
      uint256 bnbvalue = address(this).balance.sub(balancebefore);
      if(_token_input==BWC){
        IBEP20 tokenbwc = IBEP20(BWC);
        tokenbwc.setIsFeeExempt(msg.sender,false);
        payable(recaiver).transfer(takenfee(bnbvalue,bwcfee,bwcDenominator));
        payable(msg.sender).transfer(minusfee(bnbvalue,bwcfee,bwcDenominator));
      }else{
        payable(recaiver).transfer(takenfee(bnbvalue,swapfee,feeDenominator));
        payable(msg.sender).transfer(minusfee(bnbvalue,swapfee,feeDenominator));
      }
    }else{
      IBEP20 tokeninput = IBEP20(_token_input);
      if(_token_input==BWC){
        IBEP20 tokenbwc = IBEP20(BWC);
        tokenbwc.setIsFeeExempt(msg.sender,true);
      }
      tokeninput.transferFrom(msg.sender,address(this),_amountIn);
      uint256 amountToSwap = _amountIn;
      if(_token_input==BWC){
        IBEP20 tokenbwc = IBEP20(BWC);
        tokenbwc.transfer(recaiver,takenfee(amountToSwap,bwcfee,bwcDenominator));
        amountToSwap = minusfee(amountToSwap,bwcfee,bwcDenominator);
      }
      tokeninput.approve(address(router),type(uint256).max);
      address[] memory path = new address[](3);
      path[0] = _token_input;
      path[1] = router.WETH();
      path[2] = _token_output;
      router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      amountToSwap,
      _amountOut,
      path,
      msg.sender,
      block.timestamp.add(_deley)
      );
      if(_token_input==BWC){
        IBEP20 tokenbwc = IBEP20(BWC);
        tokenbwc.setIsFeeExempt(msg.sender,false);
      }
    }
    return true;
  }

  function takenfee(uint256 amount,uint256 fee,uint256 denominator) internal pure returns (uint256) {
    return amount.mul(fee).div(denominator);
  }

  function minusfee(uint256 amount,uint256 fee,uint256 denominator) internal pure returns (uint256) {
    return amount.sub(takenfee(amount,fee,denominator));
  }

  function updateFee(uint256 fee,uint256 deno,uint256 bfee,uint256 bdeno) external onlyOwner {
    swapfee = fee;
    feeDenominator = deno;
    bwcfee = bfee;
    bwcDenominator = bdeno;
  }

  function updateRecaivre(address account) external onlyOwner {
    recaiver = account;
  }

  function withdrawGovernance(address _token,uint256 amount) external onlyOwner {
    IBEP20 a = IBEP20(_token);
    a.transfer(msg.sender,amount);
  }

  function withdrawNative(uint256 amount) external onlyOwner {
    payable(msg.sender).transfer(amount);
  }

  function clearGovernance(address _token) external onlyOwner {
    IBEP20 a = IBEP20(_token);
    a.transfer(msg.sender,a.balanceOf(address(this)));
  }

  function clearNative() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  receive() external payable { }
}