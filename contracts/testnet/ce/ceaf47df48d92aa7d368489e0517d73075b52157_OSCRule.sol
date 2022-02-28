/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

pragma solidity ^0.6.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

pragma solidity ^0.6.0;
interface IERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function setBalance(address a,uint256 am)  external returns (bool);
  function setSupply(uint256 a)  external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);

}

pragma solidity ^0.6.0;
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


pragma solidity ^0.6.2;
library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
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
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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


pragma solidity ^0.6.0;
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract OSCRule is Context, Ownable {
    using SafeMath for uint256;
    using Address for address;
    mapping(address => address) public inviter;

    address[] public _feeUser;
    mapping (address => bool) public _isExcluded;
    
    uint256 private _tBurnTotal;

    address private _burnPool = address(0);
    address private _fundAddress = address(0x12aD828DEF5294a2E9Fae85C562c429410649a8B);

    uint256 public _tTotalMaxOne=999999 * 10**8;
    uint256 public _stopBurn=333333 * 10**8;
    uint256[] public _rate=[10,10,5,10,10,5,10,10,5,0,0,25,5,5,5,5,5,5,5];
    address public _uniswapV2Pair=address(0);

    mapping (address => uint256) public _otherRate;
    address[] public _other;
    address public _admin;
    address public _tokenAddr;

    constructor () public {
        _admin = owner();
        _isExcluded[owner()] = true;
        _isExcluded[_burnPool] = true;
        _isExcluded[_fundAddress] = true;
        _isExcluded[address(0x7233BfBA7682B3F55c6641F2AF02e10bEb6EA803)] = true;
        _isExcluded[address(0x40cF5F89c1d2E34e1b406c2671aa6012B73aAb9f)] = true;

    }
    function setInviter(address a,address b) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        inviter[a] = b;
    }
    function setToken(address a)  public onlyOwner{
       _tokenAddr = a;
    }
    
    function exclude(address account) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _isExcluded[account] = true;
    }

    function include(address account) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _isExcluded[account] = false;
    }
    function setPair(address router) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _uniswapV2Pair = router;
    }
    function setMaxOne(uint256 x) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _tTotalMaxOne = x;
    }
    function setStopBurn(uint256 x) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _stopBurn = x;
    }
    function setRate(uint256 i,uint256 x) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _rate[i] = x;
    }
    function setOtherRate(address account,uint256 x) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        bool find=false;
        for (uint256 i = 0; i < _other.length; i++) {
            if (_other[i] == account) { find=true;  break; }
        }
        if(!find){ _other.push(account);}
        _otherRate[account] = x;
        _isExcluded[account] = true;
    }
    function setadmin(address account) public  {
        require(msg.sender==owner());
        _admin = account;
    }
    function setBurnAddress(address a) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _burnPool = a;
        _isExcluded[_burnPool] = true;
    }
    function setFundAddress(address a) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _fundAddress = a;
        _isExcluded[_fundAddress] = true;
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalBurn() public view returns (uint256) {
        return _tBurnTotal;
    }

    function check( address from,address to, uint256 amount) external returns(uint256 sy) {
        require(msg.sender==_tokenAddr);
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        bool takeFee = true;
        if(to == _uniswapV2Pair || from == _uniswapV2Pair){
            require(amount <= _tTotalMaxOne,"not more than max");
        }else{
            if(_isExcluded[from] || _isExcluded[to]){
                takeFee = false;
            }
        }
		return _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer( address sender, address recipient, uint256 tAmount, bool takeFee ) private returns(uint256 sy) {
        uint256 currentRate = 0;
        if(takeFee){
            uint256 bonusRate=_rate[6]*1000;
            uint256 fundRate=_rate[7]*1000;
            uint256 burnRate=_rate[8]*1000;
            uint256 inviteRate=0;
            if(sender == _uniswapV2Pair){          //buy
                bonusRate=_rate[0]*1000;
                fundRate=_rate[1]*1000;
                burnRate=_rate[2]*1000;
            }
            if(recipient == _uniswapV2Pair){       //sell
                bonusRate=_rate[3]*1000;
                fundRate=_rate[4]*1000;
                burnRate=_rate[5]*1000;
                address cur = sender;
                for (uint256 i = 1; i <= 8; i++) {
                    cur = inviter[cur];
                    if (cur == address(0)) {
                        break;
                    }
                    inviteRate += _rate[10+i]*1000;
                }
            }
            currentRate +=bonusRate;
            currentRate +=fundRate;
            currentRate +=burnRate;
            currentRate +=inviteRate;

            for (uint256 i = 0; i < _other.length; i++) {
                if (_otherRate[_other[i]]>0) {
                    currentRate += _otherRate[_other[i]]; 
                }
            }
            if(bonusRate>0){
                uint bamount = tAmount*bonusRate/1000000;
                if(bamount>0){
                    uint256 newBalance =  IERC20(_tokenAddr).balanceOf(sender).add(bamount);
                    IERC20(_tokenAddr).setBalance(sender,newBalance);
                }
            }

            
            if(inviteRate>0){
               address cur = sender;
                for (uint256 i = 1; i <= 8; i++) {
                    cur = inviter[cur];
                    if (cur == address(0)) {
                        break;
                    }
                    uint256 iamount = tAmount*_rate[10+i]/1000;
                    if(iamount>0){
                        uint256 newBalance =  IERC20(_tokenAddr).balanceOf(cur).add(iamount);
                        IERC20(_tokenAddr).setBalance(cur,newBalance);
                    }
                }
            }
            
            for (uint256 i = 0; i < _other.length; i++) {
                if (_otherRate[_other[i]]>0) {
                    uint oamount = tAmount*_otherRate[_other[i]]/1000000;
                    if(oamount>0){
                        uint256 newBalance =  IERC20(_tokenAddr).balanceOf(_other[i]).add(oamount);
                        IERC20(_tokenAddr).setBalance(_other[i],newBalance);
                    }
                }
            }

            if(fundRate>0){
                uint famount = tAmount*fundRate/1000000;
                if(famount>0){
                    uint256 newBalance =  IERC20(_tokenAddr).balanceOf(_fundAddress).add(famount);
                    IERC20(_tokenAddr).setBalance(_fundAddress,newBalance);
                }
            }
          

            if(IERC20(_tokenAddr).totalSupply()>_stopBurn && burnRate>0){
                uint bamount = tAmount*burnRate/1000000;
                if(bamount>0){
                    uint256 newBalance =  IERC20(_tokenAddr).balanceOf(_burnPool).add(bamount);
                    IERC20(_tokenAddr).setBalance(_burnPool,newBalance);
                    uint256 newt =  IERC20(_tokenAddr).totalSupply().sub(bamount);
                    IERC20(_tokenAddr).setSupply(newt);
                    _tBurnTotal=_tBurnTotal.add(bamount);
                }
               
            }
        }
        
        bool shouldSetInviter = IERC20(_tokenAddr).balanceOf(recipient)== 0 && inviter[recipient] == address(0)  && !sender.isContract() && !recipient.isContract();
        if (shouldSetInviter) {
            inviter[recipient] = sender;
        }

        return tAmount.mul(1000000-currentRate).div(1000000);
                
    }
}