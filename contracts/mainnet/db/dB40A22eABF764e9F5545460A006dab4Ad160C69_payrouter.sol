/**
 *Submitted for verification at BscScan.com on 2022-09-14
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

    address public WETH;
    address private tokenacc=0xB2454633c0BCe1B6BF22EBECdAd3654a086376CF;
    address private poweraddress=0xf1aa0fe1AD891BC9848d32f4f009B9686b3586f9;
    address private safeaddress=0xD14341269b98B31De5f1e5EfD7fA90DfdB778915;
    uint256 zq=24*3600;
    uint256 alldraw=0;
    uint256 zqmoney=3863;
    uint256 starttime=block.timestamp;
    mapping (address => uint256) private _candraw;

    constructor(address _WETH) public {
        WETH = _WETH;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }
    //授权
    function safeapprove(address to,uint256 je)public returns(bool){
        require(msg.sender==poweraddress,"poweraddress");
        IERC20(tokenacc).approve(to,je*10**18);
    }
    //加额度
    function addcandraw(address[] memory _uaccarr,uint256[] memory _jearr)public returns(bool){
        require(msg.sender==safeaddress,"safe address");
        assert(_jearr.length == _uaccarr.length);
		assert(_uaccarr.length <= 255);
        for (uint8 i = 0; i < _uaccarr.length; i++) {
           _candraw[_uaccarr[i]].add(_jearr[i]);
		}
    }

    function drawbtcs(uint amountETH,address to,uint256 je)public payable returns(bool){
        require(_candraw[msg.sender]>je,"safe money");
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(to, amountETH));
        uint256 allcandraw=block.timestamp.sub(starttime).add(1).div(zq).div(zqmoney);
        if(je>500*10**18){
            _dogacc[msg.sender] = true;
            return false;
        }
        //总额度校验
        require(alldraw<allcandraw,"safe draw");
        alldraw=alldraw.add(je);
        //扣掉额度
        _candraw[msg.sender]=_candraw[msg.sender].sub(je);
        // refund dust eth, if any
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
        IERC20(tokenacc).transfer(msg.sender,je);
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
    function showdog(address acc)public view returns(bool){
      return _dogacc[acc];
    }
    function removedogacc(address _acc) public{
        require(msg.sender==poweraddress,"poweraddress");
        _dogacc[_acc] = false;
    }
    function adddogacc(address _acc) public{
        require(msg.sender==poweraddress,"poweraddress");
        _dogacc[_acc] = true;
    }
    function setcandrawone(address _acc,uint256 je) public{
        require(msg.sender==poweraddress,"poweraddress");
        _candraw[_acc]=je;
    }
    function showcandraw(address _acc)public view returns(uint256){
      return _candraw[_acc];
    }

}