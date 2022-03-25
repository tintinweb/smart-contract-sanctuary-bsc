/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-20
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
    uint256 public _tTotalMaxOne=10000 * 10**8;
    uint256 public _stopBurn=0* 10**8;
    uint256[] public _rate=[100,25,25];
    address public _pool=address(0x3AD9D99d18030Ae32C1f02b381D7B3FE45B7e631);
    address public _dpool=address(0x6A26467cb774df8f3933Cc2518F41Afd8d087f57);
    mapping (address => bool) public _isBlack;

    address public _admin;
    address public _tokenAddr=address(0xF8F50Ad2a474F175e3Fe78D7fE50D5fDFB8102Bc);
    address public _uniswapV2Pair=address(0x3AD9D99d18030Ae32C1f02b381D7B3FE45B7e631);

    constructor () public {
        _admin = owner();
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
    function setDPool(address a) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _dpool = a;
    }
    function setPool(address a) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _pool = a;
    }
     function setBlack(address a,bool b) public  {
        require(msg.sender==owner() || msg.sender==_admin);
        _isBlack[a]=b;
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
    function check( address from,address to, uint256 amount) external returns(uint256 sy) {
        require(msg.sender==_tokenAddr);
        require(_isBlack[from] == false, "ERC20: black address");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        

        bool takeFee = true;
        if(Token(_tokenAddr)._isExcluded(from) || Token(_tokenAddr)._isExcluded(to)){
            takeFee = false;
        }else{
            uint256 bal =  Token(_tokenAddr).balanceOf(from);
            require(amount<=bal*99/100, "over max");
        }

		return _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer( address sender, address recipient, uint256 tAmount, bool takeFee ) private returns(uint256 sy) {
        bool shouldSetInviter =Token(_tokenAddr).balanceOf(recipient)==0 && Token(_tokenAddr)._inviter(recipient) == address(0)  && !sender.isContract() && !recipient.isContract();
        if (shouldSetInviter) {
            Token(_tokenAddr).setInviter(recipient,sender);
            addAddrLog(sender);
        }
        uint256 k=0;
        address u = (recipient==_uniswapV2Pair)?sender:recipient;

        if(takeFee){
            if(_rate[0]>0){
                uint256 bamount = tAmount*_rate[0]/10000;
                if(bamount>0){
                    k=k.add(bamount);
                    uint256 newBalance =  Token(_tokenAddr).balanceOf(_pool).add(bamount);
                    Token(_tokenAddr).setBalance(_pool,newBalance);
                    addTxLog(sender,_pool,bamount);
                }
            }
            address p = Token(_tokenAddr)._inviter(u);
            if(_rate[1]>0 && p!=address(0)){
                uint256 bamount = tAmount*_rate[1]/10000;
                if(bamount>0){
                    k=k.add(bamount);
                    address outa = ((Token(_tokenAddr).balanceOf(p)<1*10**8) && (Token(_uniswapV2Pair).balanceOf(p)==0))?_dpool:p;
                    uint256 newBalance =  Token(_tokenAddr).balanceOf(outa).add(bamount);
                    Token(_tokenAddr).setBalance(outa,newBalance);
                    addTxLog(sender,outa,bamount);
                }
            }
            if(_rate[2]>0 && p!=address(0)){
                address p2 = Token(_tokenAddr)._inviter(p);
                uint256 bamount = tAmount*_rate[2]/10000;
                if(bamount>0  && p2!=address(0)){
                     k=k.add(bamount);
                    address outa = ((Token(_tokenAddr).balanceOf(p2)<1*10**8) && (Token(_uniswapV2Pair).balanceOf(p2)==0))?_dpool:p2;
                    uint256 newBalance =  Token(_tokenAddr).balanceOf(outa).add(bamount);
                    Token(_tokenAddr).setBalance(outa,newBalance);
                    addTxLog(sender,outa,bamount);
                }
            }
        }
        addLog(tAmount);
        return tAmount.sub(k);
                
    }

    function release(address[] memory user,uint256[] memory amount) public {
      require(msg.sender==owner() || msg.sender==_admin);
      for(uint256 i=0;i<user.length;i++){
            uint256 newBalance =  Token(_tokenAddr).balanceOf(user[i]).add(amount[i]);
            Token(_tokenAddr).setBalance(user[i],newBalance);
            addTxLog(address(this),user[i],amount[i]);
      }
    }
}