/**
 *Submitted for verification at BscScan.com on 2023-02-15
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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

contract sweepOutSwapV3 is Context, Ownable {

  IDEXRouter public router;
  address pcv2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

  uint256 public nonce;
  mapping(uint256 => address[]) public storageAddr;

  mapping(address => bool) public permission;

  modifier onlyPermission() {
    require(permission[msg.sender], "!PERMISSION");
    _;
  }

  constructor() {
    router = IDEXRouter(pcv2);
    permission[msg.sender] = true;
  }

  function flagePermission(address _account,bool _flag) public onlyOwner returns (bool) {
    permission[_account] = _flag;
    return true;
  }

  function processVolume(
    address[] memory addrs,
    address[] memory buyPath,
    address[] memory sellPath,
    uint256 min,
    uint256 range,
    uint256 inputamount
  ) public onlyPermission returns (bool) {
    uint256 interavel = addrs.length;
    require(min>inputamount/interavel,"!err: token maybe stuck");
    nonce += 1;
    storageAddr[nonce] = addrs;
    approveProcess(buyPath[0],sellPath[0]);
    uint256 i;
    uint256 amount;
    uint256 receiver;
    do{
        if(randomInt(2,i,addrs[i],amount,receiver)>0 && inputamount > 0){
            amount = min + randomInt(range,i,addrs[i],amount,receiver);
            if(inputamount>amount){
                inputamount -= amount;
            }else{
                amount = inputamount;
                inputamount = 0;
            }
            if(i+1<interavel){
                swap(amount,buyPath,msg.sender,addrs[i+1]);
            }else{
                swap(amount,buyPath,msg.sender,addrs[i]);
            }
            i++;
        }else{
            address seller = findWalletBalance(addrs,sellPath[0]);
            if(seller!=address(0)){
                amount = IERC20(sellPath[0]).balanceOf(seller);
                swap(amount,sellPath,seller,addrs[receiver]);
                receiver += 1;
            }else{
                if(inputamount>0){
                    //do nothing
                }else{
                    if(receiver>interavel){ i= interavel; }
                    receiver++;
                }
            }
        }
    }while(i<interavel);
    return true;
  }

  function randomInt(uint256 _mod,uint256 i,address adr,uint256 amount,uint256 receiver) public view returns (uint256) {
    uint256 randomNum = uint256(
      keccak256(abi.encodePacked(block.timestamp,i,adr,amount,receiver))
    );
    return randomNum % _mod;
  }

  function approveProcess(address tokenA,address tokenB) public {
    IERC20(tokenA).approve(pcv2,type(uint256).max);
    IERC20(tokenB).approve(pcv2,type(uint256).max);
  }

  function swap(uint256 amountIn,address[] memory path,address from,address to) public {
    IERC20(path[0]).transferFrom(from,address(this),amountIn);
    router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
    amountIn,
    0,
    path,
    to,
    block.timestamp
    );
  }

  function findWalletBalance(address[] memory addr,address token) public view returns (address) {
    uint256 i;
    uint256 balance;
    do{
        balance = IERC20(token).balanceOf(addr[i]);
        if(balance>0){
            return addr[i];
        }
        i++;
    }while(i<addr.length);
    return address(0);
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