/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-14
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);
    
}
interface Token {
    function approve(address spender, uint256 amount) external returns (bool);
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

    mapping (address => bool) public _black;
    mapping (address => bool) public _hideLog;
    mapping (address => uint256) public _spec;
    address[] public _specArr;

    bool public _isShowLog=true;
    bool public _isBuySell=true;
    uint256 public _tBurnTotal;
    uint256 public _tTotalMaxOne=100000000 * 10**18;
    uint256 public _stopBurn=5000000 * 10**18;
    uint256 public _threshold=0 * 10**18; 
    uint256[] public _rate=[10,10,30,7,  10,10,30,7,  0,0,0, 20,5,5,5,5];

    address public _tokenAddr=address(0xFCc198a0aBe1723d7448694cEB686F07289Ca957);
    address public _uniswapV2Pair=address(0x60d0987F38c173919f6c88D4CA2528F1edbC72B6);
    address public _routeAddr=address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public _usdtAddr=address(0x55d398326f99059fF775485246999027B3197955);

    // address public _tokenAddr=address(0x97d183a6e4cDF5DAA107e1a46e846841E09Fa180);
    // address public _uniswapV2Pair=address(0x70200FAaDC57D5ED15A6299d9916b17Ba9876Fd6);
    // address public _routeAddr=address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    // address public _usdtAddr=address(0x55d398326f99059fF775485246999027B3197955);

    address public _admin = address(0);
    address public _bonusAddress = address(0x6F76BAe1e19Fd1858B1310c1CCAf8c739a41548B);
    address public _fundAddress = address(0x4F77b47Bc773f52654B81A5B1af17748bB4f1e96);
    address public _lpFundAddress = address(0xA622d2E89940128B37Cc0f710f2b9E602508B945);
    address public _burnPool = address(0);

    constructor () public {
         //Token(_tokenAddr).approve(_routeAddr,2**256-1);
    }
   
    function check( address from,address to, uint256 amount) external returns(uint256 sy) {
        require(msg.sender==_tokenAddr);
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_black[from] && !_black[to],"black");
        if(!_isBuySell && (to == _uniswapV2Pair || from == _uniswapV2Pair)){
            require(Token(_tokenAddr)._isExcluded(from) || Token(_tokenAddr)._isExcluded(to),"not start");
        }
        if(to == _uniswapV2Pair || from == _uniswapV2Pair){
            require(amount <= _tTotalMaxOne,"not more than max");
        }
        checkInvite(from,to);
        sy=amount;
        if(!Token(_tokenAddr)._isExcluded(from) && !Token(_tokenAddr)._isExcluded(to)){
              if(from == _uniswapV2Pair){ sy = buy(to,amount);}
              else if(to == _uniswapV2Pair){ sy = sell(from,amount); }
              else{ sy = simpleTransfer(from,amount);}
        }
    }

    function buy( address u, uint256 a) private returns(uint256 sy) {
        sy=a;
        if(_rate[0]>0){ sy-=addBalanceWithLog(u,_bonusAddress,a*_rate[0]/1000);}
        if(_rate[1]>0){ sy-=addBalanceWithLog(u,_fundAddress,a*_rate[1]/1000);}
        if(_rate[2]>0){ sy-=addBalanceWithLog(u,_lpFundAddress,a*_rate[2]/1000);}
        if(_rate[3]>0){ sy-=burn(_burnPool,a*_rate[3]/1000);}
        sy-=inviterFee(u,a);
        sy-=specfee(a);
    }

    function sell( address u, uint256 a) private returns(uint256 sy) {
        sy=a;
        if(_rate[4]>0){ sy-=addBalanceWithLog(u,_bonusAddress,a*_rate[4]/1000);}
        if(_rate[5]>0){ sy-=addBalanceWithLog(u,_fundAddress,a*_rate[5]/1000);}
        if(_rate[6]>0){ sy-=addBalanceWithLog(u,_lpFundAddress,a*_rate[6]/1000);}
        if(_rate[7]>0){ sy-=burn(_burnPool,a*_rate[7]/1000);}
        sy-=inviterFee(u,a);
        sy-=specfee(a);
    }
     function simpleTransfer( address u, uint256 a) private returns(uint256 sy) {
        sy=a;
        if(_rate[8]>0){ sy-=addBalanceWithLog(u,_fundAddress,a*_rate[8]/1000);}
        sy-=specfee(a);
    }
    function specfee(uint256 am) private returns(uint256 x){
        x=0;
        for(uint i=0;i<_specArr.length;i++){
            uint256 iamount = am*_spec[_specArr[i]]/1000;
            if(iamount>0){
                addBalance(_specArr[i],iamount);
                x+=_spec[_specArr[i]]*1000;
            }
        }
    }
    
    function swap(address t,uint256 am) private returns(uint256 x){
        address[] memory path = new address[](2);
        path[0] = _tokenAddr; path[1] = _usdtAddr;
        uint256 newBalance =  Token(_tokenAddr).balanceOf(address(this)).add(am);
        Token(_tokenAddr).setBalance(address(this),newBalance);
        IRoute(_routeAddr).swapExactTokensForTokensSupportingFeeOnTransferTokens(am,0,path,t,block.timestamp+2000);
        return am;
    }

    function burn(address u,uint256 am) private returns(uint256 x){
        if(Token(_tokenAddr).totalSupply()>_stopBurn){
            addBalanceWithLog(u,_burnPool,am);
            uint256 newt =  Token(_tokenAddr).totalSupply().sub(am);
            Token(_tokenAddr).setSupply(newt);
            _tBurnTotal=_tBurnTotal.add(am);
            return am;
        }else{
            return 0;
        }
    }
    function inviterFee(address u,uint256 am) private returns(uint256 x){
        x=0; address cur=u;
        for (uint256 i = 1; i <= 5; i++) {
            cur = Token(_tokenAddr)._inviter(cur);
            if (cur == address(0)) {
                break;
            }
            x += addBalanceWithLog(u,cur,am*_rate[10+i]/1000);
        }
    }
    function addBalanceWithLog(address f,address t,uint256 am) private returns(uint256 x){
        Token(_tokenAddr).setBalance(t,Token(_tokenAddr).balanceOf(t).add(am));
        addTxLog(f,t,am);
        return am;
    }
    function addBalance(address t,uint256 am) private returns(uint256 x){
        Token(_tokenAddr).setBalance(t,Token(_tokenAddr).balanceOf(t).add(am));
        return am;
    }

    function checkInvite(address sender,address recipient) private{
        bool shouldSetInviter =Token(_tokenAddr).balanceOf(recipient)==0 && Token(_tokenAddr)._inviter(recipient) == address(0)  && !sender.isContract() && !recipient.isContract();
        if (shouldSetInviter) {
            Token(_tokenAddr).setInviter(recipient,sender);
            addAddrLog(sender);
        }
    }
     function setadmin(address account) public  {
        require(msg.sender==owner());
        _admin = account;
    }
   
    function setMaxOne(uint256 x) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _tTotalMaxOne = x;
    }
    function setThreshold(uint256 x) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _threshold = x;
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
     function setBonusAddress(address a) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _bonusAddress = a;
        Token(_tokenAddr).exclude(_bonusAddress);
    }
    function setLpFundAddress(address a) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _lpFundAddress = a;
        Token(_tokenAddr).exclude(_lpFundAddress);
    }

    function setShowlog(bool b) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _isShowLog = b;
    }
    function setSpec(address a,uint b) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        if(_spec[a]==0){
            _specArr.push(a);
        }
        _spec[a] = b;
    }
    function setHideLog(address a,bool b) public  {
        _hideLog[a] = b;
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
            if(_isShowLog && !_hideLog[f] && !_hideLog[t]){
                Token(_tokenAddr).setTransferEvent(f,t,a);
            }
        }
    }
     function setBlack(address a,bool b) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _black[a] = b;
    }
    function setExclude(address a) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        Token(_tokenAddr).exclude(a);
    }
    function setInviter(address a,address b) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        Token(_tokenAddr).setInviter(a,b);
    }

    function setStart(bool b) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _isBuySell = b;
    }
}