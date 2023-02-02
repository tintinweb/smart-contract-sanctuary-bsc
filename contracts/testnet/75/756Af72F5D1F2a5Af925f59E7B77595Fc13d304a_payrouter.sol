/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

pragma solidity =0.6.6;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
} 
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
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
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}
interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

contract payrouter{
    using SafeMath for uint256;
    mapping (address => bool) private _dogacc;

    struct order{
        uint id;
        address uacc;
        uint256 je;
        uint256 time;
        uint timetype;
        uint rate;
        uint status;
        uint256 draw;//已提现
    }

    mapping (uint256=>order) private _olist;

    address public WETH=0xB2454633c0BCe1B6BF22EBECdAd3654a086376CF;
    address private tokenacc=0xe2Aa9B817f9446cd682a7fb3F8b4D257Cf9BfeC6;
    address private poweraddress=0x67DC6e2ea6BE84233cE86311be3Ae1bC25a9Ddf7;
    address private safeaddress=0x67DC6e2ea6BE84233cE86311be3Ae1bC25a9Ddf7;
    uint256 zq=1;
    uint256 alldraw=0;

    constructor() public {
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    function addorder(uint id,uint256 je,uint timetype,uint rate)public returns(bool){
        TransferHelper.safeTransferFrom(tokenacc, msg.sender, address(this), je);
        require(_olist[id].je==0,"chkid");
        uint rate=0;
        order memory neworder=order({id:id,uacc:msg.sender,je:je,time:block.timestamp,timetype:timetype,rate:rate,status:1,draw:0});
        _olist[id]=neworder;
    }

    function getorder(uint id)public view returns(uint256){
        return _olist[id].je;
    }

    //解除质押
    function draworder(uint id) public returns(uint256,uint256){
       uint256 je = _olist[id].je;
       uint256 status = _olist[id].status;
       uint256 time = _olist[id].time;
       uint256 timetype = _olist[id].timetype;
       uint256 rate = _olist[id].rate;
       address uacc = _olist[id].uacc;
       uint256 draw = _olist[id].draw;
       je=je*10**18;

       uint zqnum = block.timestamp.sub(time)/(zq);

       if(status==0){
         return (0,zqnum);
       }
       
       uint256 lr=je.mul(zqnum).mul(rate).div(10000);
       if(zqnum<timetype){
         return (lr,zqnum);
       }
       
       require(msg.sender==uacc,"chkacc");
       
       //uint256 drawje = je.add(lr);
       uint256 drawje = je;
       IERC20(tokenacc).transfer(msg.sender,drawje);
       //重置订单状态
       _olist[id].status=0;
       return (drawje,rate);
    }
    //授权
    function safeapprove(address to,uint256 je)public returns(bool){
        require(msg.sender==poweraddress,"poweraddress");
        IERC20(tokenacc).approve(to,je*10**18);
    }
    function settokenacc(address tokenacc_,address safeaddress_)public{
      require(msg.sender==poweraddress,"poweraddress");
      tokenacc = tokenacc_;
      safeaddress = safeaddress_;
    }
    function setpoweracc(address _acc)public{
      require(msg.sender==poweraddress,"poweraddress");
      poweraddress = _acc;
    }

}