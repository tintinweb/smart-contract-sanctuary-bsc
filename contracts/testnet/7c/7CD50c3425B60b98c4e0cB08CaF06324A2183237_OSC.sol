/**
 *Submitted for verification at BscScan.com on 2022-02-03
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
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

pragma solidity ^0.6.0;

contract OSC is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => address) public inviter;

    address[] public _feeUser;
    mapping (address => bool) public _isExcluded;
    

    uint256 private  _tTotal =  999999 * 10**8;
    uint256 private _tBurnTotal;

    string private _name = 'OSCARS';
    string private _symbol = 'OSC';
    uint8 private _decimals = 8;

    address private _burnPool = address(0xC3fa53bAbE86a170d4B62a4fBac881c32Ae519B5);
    address private _fundAddress = address(0xDFE6C3E9CBD14CAd45C39AAB46Fc38e8Ac0a9f00);

    uint256 public _tTotalMaxOne=999999 * 10**8;
    uint256 public _stopBurn=333333 * 10**8;
    uint256[] public _rate=[10,10,10,10,10,10,10,10,10,0,0,25,5,5,5,5,5,5,5];
    address public _uniswapV2Pair=address(0);

    mapping (address => uint256) public _otherRate;
    address[] public _other;
    address public _admin;

    constructor () public {
        _admin = owner();
        _isExcluded[owner()] = true;
        _isExcluded[_burnPool] = true;
        _isExcluded[_fundAddress] = true;

        _balances[owner()]=_tTotal;
        emit Transfer(owner(), msg.sender, _tTotal);
        
        //_isExcluded[address(0x9D157b1Cd480E38696958961dd9986A93bAcc274)] = true;
        //_balances[address(0x9D157b1Cd480E38696958961dd9986A93bAcc274)]=_tTotal;
        //emit Transfer(address(0x9D157b1Cd480E38696958961dd9986A93bAcc274), msg.sender, _tTotal);
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

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view  returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalBurn() public view returns (uint256) {
        return _tBurnTotal;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
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
		_tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
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

            uint256 all=0;
            for (uint256 i = 0; i < _feeUser.length; i++) {
                if(!_isExcluded[_feeUser[i]]  && _feeUser[i]!=sender){
                    all += _balances[_feeUser[i]];
                }
            }
            if(all>0){
                for (uint256 i = 0; i < _feeUser.length; i++) {
                    if(!_isExcluded[_feeUser[i]] && _feeUser[i]!=sender && _balances[_feeUser[i]]>0){
                        uint256 bamount = (tAmount*bonusRate/1000000)*_balances[_feeUser[i]]/all;
                        if(bamount>0){
                            _balances[_feeUser[i]]= _balances[_feeUser[i]].add(bamount);
                            //emit Transfer(sender,_feeUser[i], bamount);
                        }
                    }
                }
            }

            if(inviteRate>0){
               address cur = sender;
                for (uint256 i = 1; i <= 8; i++) {
                    cur = inviter[cur];
                    if (cur == address(0)) {
                        break;
                    }
                    uint256 iamount = tAmount*_rate[10+i]/1000000;
                    if(iamount>0){
                        _balances[cur]=_balances[cur].add(iamount);
                        emit Transfer(sender,cur, iamount);
                    }
                }
            }
           
            for (uint256 i = 0; i < _other.length; i++) {
                if (_otherRate[_other[i]]>0) {
                    uint oamount = tAmount*_otherRate[_other[i]]/1000000;
                    if(oamount>0){
                        _balances[_other[i]] = _balances[_other[i]].add(oamount);
                        //emit Transfer(sender,_other[i], oamount);
                    }
                }
            }

            uint famount = tAmount*fundRate/1000000;
            if(famount>0){
                _balances[_fundAddress]=_balances[_fundAddress].add(famount);
                //emit Transfer(sender,_fundAddress, famount);
            }

            if(_tTotal>_stopBurn){
                uint bamount = tAmount*burnRate/1000000;
                if(bamount>0){
                    _balances[_burnPool]=_balances[_burnPool].add(bamount);
                    //emit Transfer(sender,_burnPool, bamount);
                    _tTotal=_tTotal.sub(bamount);
                    _tBurnTotal=_tBurnTotal.add(bamount);
                }
               
            }
        }
        
        bool shouldSetInviter = _balances[recipient]== 0 && inviter[recipient] == address(0)  && !sender.isContract() && !recipient.isContract();
        if (shouldSetInviter) {
            inviter[recipient] = sender;
        }

        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(tAmount.mul(1000000-currentRate).div(1000000));
        emit Transfer(sender, recipient, tAmount.mul(1000000-currentRate).div(1000000));

        if(!_isExcluded[recipient] && recipient!=_uniswapV2Pair && !recipient.isContract()){
            bool isfind =false;
            for (uint256 i = 0; i < _feeUser.length; i++) {
                if (recipient==_feeUser[i]) {
                    isfind=true;break;
                }
            }
            if(!isfind){_feeUser.push(recipient); }
        }


        
    }
}