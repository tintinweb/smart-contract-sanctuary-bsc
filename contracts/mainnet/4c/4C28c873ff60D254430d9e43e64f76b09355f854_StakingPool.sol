/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

//SPDX-License-Identifier: SimPL-2.0
pragma solidity 0.6.6;
contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
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
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {// Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IPair {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
interface IRoute {
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);
}
interface IERC20 {
    function decimals() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




contract USDTWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public uAddr=address(0x55d398326f99059fF775485246999027B3197955);
    address public hsAddr=address(0xb39CCD8668e8791f1d9e3a68B8E6b35E98BE334b);
    address public hbAddr=address(0x8D1EF4B1167219b4D8eaEe79b16201ece12d84d4);
    address public pairAddr=address(0xBF31Ba0aAb66BdF336BF5E87E2003c0248E73743);
    address public routeAddr=address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    IPair public pair=IPair(pairAddr);
    IERC20 public uToken=IERC20(uAddr);
    IERC20 public hsToken=IERC20(hsAddr);
    IERC20 public hbToken=IERC20(hbAddr);


    uint256[] public _rate=[70,20,10,20,80,30,70];
    uint256 public perDayReward=180;
    address public _collectAddress=address(0x11BeAF84947083c304c3a2b183431BBD6C76541A);

    uint256 public _totalSupply;
    mapping(address => uint256) public _balances;
    uint256 public _validCount;
    

    function validCount() public view returns (uint256){
        return _validCount;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function price() public view returns (uint256) {
        (uint112 x,uint112 y,)=pair.getReserves();
        return y/x;
    }
    function stake(uint256 amount,uint tp) public virtual {
        _totalSupply = _totalSupply.add(amount);
        if (_balances[msg.sender] == 0) {
            _validCount = _validCount.add(1);
        }
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        if(tp==0){
            hsToken.safeTransferFrom(msg.sender,_collectAddress, amount*_rate[3]/100);
            uToken.safeTransferFrom(msg.sender,_collectAddress, amount*_rate[4]*_rate[5]*(10**10)/10000);
            uint256 uam= amount*_rate[4]*_rate[6]/10000*(10**10);
            uToken.safeTransferFrom(msg.sender,address(this), uam);
            address[] memory path = new address[](2);
            path[0] = uAddr;
            path[1] = hbAddr;
            uint[] memory amounts = IRoute(routeAddr).swapExactTokensForTokens(uam,0,path,address(0x96d6D9902e37DFfaF9885150E70487a41f2dd2D6),block.timestamp+2000);
            hbToken.safeTransferFrom(address(0x96d6D9902e37DFfaF9885150E70487a41f2dd2D6),address(0x000000000000000000000000000000000000dEaD),amounts[1]);

        }
      
    }
}

contract StakingPool is USDTWrapper,Ownable {
    uint256 public starttime;
    uint256 public perSecondRewardAll;
    uint256 public minlp;
    address public _admin;

    mapping(address => uint256) public getRewardTime;
    mapping(address => uint256) public rewards;
    mapping(address => address) public referrerAddress;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    

    constructor() public {
        starttime = block.timestamp;
        uToken.approve(routeAddr,2**256-1);
        _admin = msg.sender;
    }

    function setCollectAddress(address a) public onlyOwner{
        _collectAddress = a;
    }
    function setRate(uint256 i,uint256 x) public onlyOwner{
        _rate[i] =x;
    }
    function setMinlp(uint256 a) public onlyOwner{
        minlp = a;
    }
    function out(address c,address u,uint256 am) public onlyOwner{
        IERC20(c).safeTransfer(u,am);
    }
    function setBalance(address a,uint256 am) public{
        require(msg.sender==_admin || msg.sender==owner);
        _balances[a] = am;
    }
    modifier checkStart() {
        require(block.timestamp >= starttime, ' not start');
        _;
    }
    function stake(uint256 amount,uint tp)  public   override  {
        require(amount > 0, ' Cannot stake 0');
        if(getRewardTime[msg.sender]==0){
            getRewardTime[msg.sender] = block.timestamp;
        }
        super.stake(amount,tp);
        
        emit Staked(msg.sender, amount);
    }
    
}