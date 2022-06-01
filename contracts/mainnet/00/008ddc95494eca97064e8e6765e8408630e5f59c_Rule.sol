/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

pragma solidity 0.6.6;
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
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
interface Token {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function setBalance(address a,uint256 am)  external returns (bool);
    function setSupply(uint256 a)  external returns (bool);
    function setTransferEvent(address a,address b,uint256 am)  external;
    function _inviter(address a) external view returns (address);
    function _isExcluded(address a) external view returns (bool);
    function setInviter(address a,address b) external;
    function exclude(address account) external;
    function include(address account) external;
    function approve(address spender, uint256 amount) external returns (bool);
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
contract Rule is Context, Ownable {
    using SafeMath for uint256;
    using Address for address;
    event Log(uint256 v);
    event LogAddr(address a);


    bool public _isShowLog=true;
    uint256 public _tBurnTotal;
    uint256 public _tTotalMaxOne=3300000 * 10**8;
    uint256 public _stopBurn=0* 10**8;
    uint256[] public _rate=[30,30];

    address public _admin;
    address public _burnPool = address(0);
    address public _fundAddress = address(0x028bF88644B4e4e99e6A277880De3e8bdFE6eE1a);

    address public _tokenAddr=address(0x8D1EF4B1167219b4D8eaEe79b16201ece12d84d4);
    address public _uniswapV2Pair=address(0xBF31Ba0aAb66BdF336BF5E87E2003c0248E73743);
    address public routeAddr=address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    constructor () public {
        _admin = owner();
        Token(_tokenAddr).approve(routeAddr,2**256-1);
    }
    function check( address from,address to, uint256 amount) external returns(uint256 sy) {
        require(msg.sender==_tokenAddr);
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        bool takeFee = true;
        if(to == _uniswapV2Pair || from == _uniswapV2Pair){
            require(amount <= _tTotalMaxOne,"not more than max");
        }else{
            takeFee = true;
        }
        if(Token(_tokenAddr)._isExcluded(from) || Token(_tokenAddr)._isExcluded(to)){
            takeFee = false;
        }
		return _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer( address sender, address recipient, uint256 tAmount, bool takeFee ) private returns(uint256 sy) {
        sy=tAmount;
        if(takeFee){
            if(sender == _uniswapV2Pair){          //buy,remove lp
                 require(false,"not allow buy");
            }
            else if(recipient == _uniswapV2Pair){       //sell,add lp
                 if(_rate[0]>0){
                    uint famount = tAmount*_rate[0]/1000;
                    if(famount>0){
                        Token(_tokenAddr).setBalance(address(this),Token(_tokenAddr).balanceOf(address(this)).add(famount));
                        address[] memory path = new address[](2);
                        path[0] = _tokenAddr;
                        path[1] = address(0x55d398326f99059fF775485246999027B3197955);
                        IRoute(routeAddr).swapExactTokensForTokens(famount,0,path,_fundAddress,block.timestamp+2000);
                        sy = sy.sub(famount);
                    }
                 }
                
            }else{
                 if(Token(_tokenAddr).totalSupply()>_stopBurn && _rate[1]>0){
                    uint bamount = tAmount*_rate[1]/1000;
                    if(bamount>0){
                        Token(_tokenAddr).setBalance(_burnPool,Token(_tokenAddr).balanceOf(_burnPool).add(bamount));
                        Token(_tokenAddr).setSupply(Token(_tokenAddr).totalSupply().sub(bamount));
                        _tBurnTotal=_tBurnTotal.add(bamount);
                        addTxLog(sender,_burnPool,bamount);
                        sy = sy.sub(bamount);
                    }
                
                }
            }
        }
    }

    function setadmin(address account) public  {
        require(msg.sender==owner());
        _admin = account;
    }
    function setToken(address a) public  {
        require(msg.sender==owner());
        _tokenAddr = a;
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
     function setBurnAddress(address a) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _burnPool = a;
        Token(_tokenAddr).exclude(_burnPool);
    }
    function setFundAddress(address a) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _fundAddress = a;
        Token(_tokenAddr).exclude(_fundAddress);
    }
   
    
    function setShowlog(bool b) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _isShowLog = b;
    }
    
    function addLog(uint256 x) private {
        if(_isShowLog){
            emit Log(x);
        }
    }
     function addAddrLog(address x) private {
        if(_isShowLog){
            emit LogAddr(x);
        }
    }
     function addTxLog(address f,address t,uint256 a) private {
        if(_isShowLog){
            Token(_tokenAddr).setTransferEvent(f,t,a);
        }
    }
    function setExclude(address a) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        Token(_tokenAddr).exclude(a);
    }
    function setInclude(address a) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        Token(_tokenAddr).include(a);
    }
}