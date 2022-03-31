/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function aFreeAddr() external view returns (address);
    function bFreeAddr() external view returns (address);
    function rewardAddr() external view returns (address);
    function teamAddr() external view returns (address);
    function usdtTokenAddr() external view returns (address);
     function blackHoleAddr() external view returns (address);
    function fireBaseFuncAddr() external view returns (address);
    function swapTokenAddr() external view returns (address);
    function buyInviteRate() external view returns (uint256);
    function teamRate() external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

contract Manager is Context {
    address public governance;
    mapping (address => bool) public managers;

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    modifier isGover {
        require(governance == governance, "!governance");
        _;
    }

    modifier isManager {
         require(managers[msg.sender] == true, "!manager");
        _;
    }  

  function addManager(address _addr) public  isGover{
      managers[_addr] = true;
  }

  function removeManager(address _addr) public isGover{
       managers[_addr] =  false;
  }
}

contract ERC20Detailed is Manager {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface ILockWareHouseBaseFunc {
     function getDay(uint _endTime) external view  returns (uint32);
     function getUsdtPrice(uint _amount) external view  returns (uint256);
     function getInviteAddr(address _address) external view returns(address);
     function getLockRewardRate(uint256 _amount) external view returns(uint256);
     function getAllReleaseNum (uint _createTokenPrice, uint _nowTokenPrice) external view  returns (uint32);
}

contract swap is  ERC20Detailed {
   
    constructor () public ERC20Detailed("swap", "swap", 18) {
        governance = msg.sender;
    }

    uint256  usdtAmount = 1*10**18;    
    uint256  fireAmount = 1*10**18;

      function getAmountsOut(uint amountIn, address[]  memory path)
        public
        view
        returns (uint[] memory amounts){
            uint[] memory path = new uint[](2);
            path[0] = usdtAmount;
            path[1] = fireAmount;
             return path;
        }
  

    function setFireTokenAddr(uint256 _fireAmount) public {     
      fireAmount = _fireAmount*10**18;
    }

    function setUsdtAmount(uint256 _usdtAmount) public {     
      usdtAmount = _usdtAmount*10**18;
    }
}