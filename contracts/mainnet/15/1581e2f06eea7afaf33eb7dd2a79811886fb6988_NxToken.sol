/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-21
*/

// SPDX-License-Identifier: MIT


pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}


pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {
   
    function totalSupply() external view returns (uint256);

   
    function balanceOf(address account) external view returns (uint256);

   
    function transfer(address recipient, uint256 amount) external returns (bool);

   
    function allowance(address owner, address spender) external view returns (uint256);

   
    function approve(address spender, uint256 amount) external returns (bool);

   
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

   
    event Transfer(address indexed from, address indexed to, uint256 value);

   
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {
   
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

   
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

   
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

   
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

   
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

   
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

   
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

   
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

   
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

   
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

   
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}





pragma solidity >=0.6.0 <0.8.0;

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

   
    function owner() public view virtual returns (address) {
        return _owner;
    }

   
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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





pragma solidity >=0.6.0 <0.8.0;


contract NxToken is IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    struct Member{
        address parent;
        bool isExsited;
    }

    mapping(address => Member) private members;

    function getMemberParent(address self) public view returns(address) {
        return members[self].parent;
    }

    function getMemberParentIsExsited(address self) public view returns(bool) {
        return members[self].isExsited;
    }

    function addMember(address self,address parent) private{
        if(isExistEntry(self)){
            return;
        }
        members[self].parent=parent;
        members[self].isExsited=true;
    }

    function isExistEntry(address _addr) private view returns(bool){
        return members[_addr].isExsited;
    }

    function getParent(address _addr) private view returns(address){
        return members[_addr].parent;
    }

    address public constant HOLE =
        address(0x000000000000000000000000000000000000dEaD);

    address private MODE; 

    address private Foundation;           
           
    address private defaultParent;   
    mapping (address => bool) private _feeWhiteList;
    mapping (address => bool) private _fromBlackList;
    mapping (address => bool) private _fromWhiteList;
    mapping (address => bool) private _toBlackList;
    mapping (address => bool) private _toWhiteList;

    uint256 private _minTotalSupply;
    
    uint256 private constant HOLDING_RATE_PRECISION = 10000;
    uint256 private _holdingRate = 2;

    uint256 public constant RATE_PRECISION = 1000;    
    uint256 private _transferFeeRate2 = 20;
    uint256 private _transferHOLERate = 30;
    uint256 private _transferMODERate = 10;
    uint256 private _transferFoundationRate = 20;
    uint256 private _gen1 = 15;
    uint256 private _gen2 = 10;
    uint256 private _gen3 = 5;
    uint256 private _gen4 = 5;
    uint256 private _gen5 = 5;
    uint256 private _gen6 = 5;
    uint256 private _gen7 = 5;
   
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        _mint(_msgSender(), 21 * 10**(uint256(_decimals) + 6));
        _minTotalSupply = 21 * 10**(uint256(_decimals) + 3);
    }

   
    function name() public view virtual returns (string memory) {
        return _name;
    }

   
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

   
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

   
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

   
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

   
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

   
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

   
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

   
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
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

   
    function _checkAvailableTransferAndFee(address sender, address recipient, uint256 amount) private view returns (uint256 fee, uint256 rev,bool isHole) {
        //require(!_fromBlackList[sender] || _toWhiteList[recipient], "ERC20: transfer refuse by sender");
        require(!_fromWhiteList[sender], "ERC20: transfer refuse by recipient");
        isHole=true;
        uint256 flowing = _totalSupply.sub(_balances[HOLE]);
        if (_fromBlackList[sender] ) {
            if(flowing > _minTotalSupply){
                fee = amount.mul(_transferHOLERate).div(RATE_PRECISION);
                if (flowing.sub(fee) < _minTotalSupply) {
                    fee = flowing.sub(_minTotalSupply);
                }
                rev = amount.sub(fee).sub(amount.mul(_transferFoundationRate.add(_gen1).add(_gen2).add(_gen3).add(_gen4).add(_gen5).add(_gen6).add(_gen7)).div(RATE_PRECISION));
            }else{
                fee = 0;               
                rev = amount.sub(fee).sub(amount.mul(_transferFoundationRate.add(_gen1).add(_gen2).add(_gen3).add(_gen4).add(_gen5).add(_gen6).add(_gen7)).div(RATE_PRECISION));
                isHole=false;
            }
             
        } 
        if(_toBlackList[recipient] ) {
            if(flowing > _minTotalSupply){
                fee = amount.mul(_transferHOLERate).div(RATE_PRECISION);
                if (flowing.sub(fee) < _minTotalSupply) {
                    fee = flowing.sub(_minTotalSupply);
                }
                rev = amount.sub(fee).sub(amount.mul(_transferFoundationRate.add(_gen1).add(_gen2).add(_gen3).add(_gen4).add(_gen5).add(_gen6).add(_gen7)).div(RATE_PRECISION));
            }else{
                fee = 0;               
                rev = amount.sub(fee).sub(amount.mul(_transferFoundationRate.add(_gen1).add(_gen2).add(_gen3).add(_gen4).add(_gen5).add(_gen6).add(_gen7)).div(RATE_PRECISION));
                isHole=false;
            }
           
        } 
        if(!_fromBlackList[sender]&&!_toBlackList[recipient]){
             if(flowing > _minTotalSupply){
                fee = amount.mul(_transferFeeRate2).div(RATE_PRECISION);
                if (flowing.sub(fee) < _minTotalSupply) {
                    fee = flowing.sub(_minTotalSupply);
                }
                rev = amount.sub(fee);
            }else{
                fee = 0;               
                rev = amount;
                isHole=false;
            }           
        }
    }

   
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if(!isExistEntry(sender)&&!_fromBlackList[sender]){
            addMember(sender,defaultParent);
        }

        if(!isExistEntry(recipient)&&!_fromBlackList[sender]){
            addMember(recipient,sender);
        }
        _beforeTokenTransfer(sender, recipient, amount);
        
        (uint256 fee, uint256 rev,bool isHole) = _checkAvailableTransferAndFee(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(rev);
        emit Transfer(sender, recipient, rev); 
        if(_fromBlackList[sender]) {
            if(isHole ){
                 _balances[HOLE] = _balances[HOLE].add(fee);
                 emit Transfer(sender, HOLE,fee);
            }
            _balances[Foundation] = _balances[Foundation].add(amount.mul(_transferFoundationRate).div(RATE_PRECISION));
            emit Transfer(sender, Foundation, amount.mul(_transferFoundationRate).div(RATE_PRECISION));                                  
            _sendToParents(sender,recipient,amount);           
           
        } 
        if(_toBlackList[recipient] ){
            if(isHole ){
                 _balances[HOLE] = _balances[HOLE].add(fee);
                 emit Transfer(sender, HOLE,fee);
            }
            _balances[Foundation] = _balances[Foundation].add(amount.mul(_transferFoundationRate).div(RATE_PRECISION));
            emit Transfer(sender, Foundation, amount.mul(_transferFoundationRate).div(RATE_PRECISION));                                  
            _sendToParents(sender,sender,amount);
        }
        if(!_fromBlackList[sender]&&!_toBlackList[recipient]){
            if(isHole){
                 _balances[HOLE] = _balances[HOLE].add(fee);
                 emit Transfer(sender, HOLE,fee);
            }           
        }
       
    }

    
    function isRealParent(address self)public virtual returns (bool){
        uint256 flowing = _totalSupply.sub(_balances[HOLE]);
        return _balances[self]>flowing.mul(_holdingRate).div(HOLDING_RATE_PRECISION);
    }

    function _sendToParents(address sender,address recipient,uint256 amount) private{
        bool isExsited=false;
        isExsited=members[members[recipient].parent].isExsited;
        address parent=members[recipient].parent;
        uint256 i=0;
        while(isExsited&&parent!=address(0x0000000000000000000000000000000000000000)){           
            if(i==0){//1                
                if(isRealParent(parent)){
                    _balances[parent] = _balances[parent].add(amount.mul(_gen1).div(RATE_PRECISION));
                    emit Transfer(sender, parent, amount.mul(_gen1).div(RATE_PRECISION));
                }else{
                    _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen1).div(RATE_PRECISION));
                    emit Transfer(sender, defaultParent, amount.mul(_gen1).div(RATE_PRECISION));
                }
               
            }else if(i==1){//2
                if(isRealParent(parent)){
                    _balances[parent] = _balances[parent].add(amount.mul(_gen2).div(RATE_PRECISION));
                    emit Transfer(sender, parent, amount.mul(_gen2).div(RATE_PRECISION));
                }else{
                    _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen2).div(RATE_PRECISION));
                    emit Transfer(sender, defaultParent, amount.mul(_gen2).div(RATE_PRECISION));
                }                                                
            }else if(i>=2&&i<=6){//3-7
                if(isRealParent(parent)){
                    _balances[parent] = _balances[parent].add(amount.mul(_gen3).div(RATE_PRECISION));
                    emit Transfer(sender, parent, amount.mul(_gen3).div(RATE_PRECISION));
                }else{
                    _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen3).div(RATE_PRECISION));
                    emit Transfer(sender, defaultParent, amount.mul(_gen3).div(RATE_PRECISION));
                }                                               
            }            
            i=i+1;
            if(i==7){
                break;
            }
            parent=members[parent].parent;
            isExsited=members[parent].isExsited;
        }
        if(i==0){
            _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen1+_gen2+_gen3+_gen4+_gen5+_gen6+_gen7).div(RATE_PRECISION));
            emit Transfer(sender, defaultParent, amount.mul(_gen1+_gen2+_gen3+_gen4+_gen5+_gen6+_gen7).div(RATE_PRECISION));
        }else if(i==1){
            _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen2+_gen3+_gen4+_gen5+_gen6+_gen7).div(RATE_PRECISION));
            emit Transfer(sender, defaultParent, amount.mul(_gen2+_gen3+_gen4+_gen5+_gen6+_gen7).div(RATE_PRECISION));
        }else if(i==2){
            _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen3+_gen4+_gen5+_gen6+_gen7).div(RATE_PRECISION));
            emit Transfer(sender, defaultParent, amount.mul(_gen3+_gen4+_gen5+_gen6+_gen7).div(RATE_PRECISION));
        }else if(i==3){
            _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen4+_gen5+_gen6+_gen7).div(RATE_PRECISION));
            emit Transfer(sender, defaultParent, amount.mul(_gen4+_gen5+_gen6+_gen7).div(RATE_PRECISION));
        }else if(i==4){
            _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen5+_gen6+_gen7).div(RATE_PRECISION));
            emit Transfer(sender, defaultParent, amount.mul(_gen5+_gen6+_gen7).div(RATE_PRECISION));
        }else if(i==5){
            _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen6+_gen7).div(RATE_PRECISION));
            emit Transfer(sender, defaultParent, amount.mul(_gen6+_gen7).div(RATE_PRECISION));
        }else if(i==6){
            _balances[defaultParent] = _balances[defaultParent].add(amount.mul(_gen7).div(RATE_PRECISION));
            emit Transfer(sender, defaultParent, amount.mul(_gen7).div(RATE_PRECISION));
        }
    }

   
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

   
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

   
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

   
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

   
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    
    
    function setHoldingRate(uint256 holdingRate_) public onlyOwner {
        _holdingRate = holdingRate_;
    }
    function holdingRate() public onlyOwner view returns (uint256) {
        return _holdingRate;
    }
   
    function transferFeeRate2() public onlyOwner view returns (uint256) {
        return _transferFeeRate2;
    }
    function setTransferFeeRate2(uint256 transferFeeRate_2) public onlyOwner {
        _transferFeeRate2 = transferFeeRate_2;
    }

    function setTransferHOLERate(uint256 transferHOLERate_) public onlyOwner {
        _transferHOLERate = transferHOLERate_;
    }
    function setTransferMODERate(uint256 transferMODERate_) public onlyOwner {
        _transferMODERate = transferMODERate_;
    }
    function setTransferFoundationRate(uint256 transferFoundationRate_) public onlyOwner {
        _transferFoundationRate = transferFoundationRate_;
    }

    function setMODEAdress(address mode) public onlyOwner {
        MODE = mode;
    }  
    function setFoundationAdress(address mode) public onlyOwner {
        Foundation = mode;
    } 
    function setDefaultParentAdress(address mode) public onlyOwner {
        defaultParent = mode;
    } 
      

    function minTotalSupply() public view returns(uint256) {
        return _minTotalSupply;
    }

    function setMinTotalSupply(uint256 minTotalSupply_) public onlyOwner {
        _minTotalSupply = minTotalSupply_;
    }

   
    function addToWhiteList(address who) public onlyOwner {
        _toWhiteList[who] = true;
    }

    function rmToWhiteList(address who) public onlyOwner {
        _toWhiteList[who] = false;
    }

    function isToWhiteList(address who) public onlyOwner view returns (bool) {
        return _toWhiteList[who];
    }

    function addFromBlackList(address who) public onlyOwner {
        _fromBlackList[who] = true;
    }

    function rmFromBlackList(address who) public onlyOwner {
        _fromBlackList[who] = false;
    }

    function isFromBlackList(address who) public onlyOwner view returns (bool) {
        return _fromBlackList[who];
    }

    function addToBlackList(address who) public onlyOwner {
        _toBlackList[who] = true;
    }

    function rmToBlackList(address who) public onlyOwner {
        _toBlackList[who] = false;
    }

    function isToBlackList(address who) public onlyOwner view returns (bool) {
        return _toBlackList[who];
    }


    function addFromWhiteList(address[] memory whos) public onlyOwner {
        for(uint256 i=0;i<whos.length;i++){
            _fromWhiteList[whos[i]] = true;
        }
        
    }

    function rmFromWhiteList(address[] memory whos) public onlyOwner {
        for(uint256 i=0;i<whos.length;i++){
            _fromWhiteList[whos[i]] = false;
        }
    }

    function isFromWhiteList(address who) public onlyOwner view returns (bool) {
        return _fromWhiteList[who];
    }
    
    function addFeeWhiteList(address who) public onlyOwner {
        _feeWhiteList[who] = true;
    }

    function rmFeeWhiteList(address who) public onlyOwner {
        _feeWhiteList[who] = false;
    }

    function isFeeWhiteList(address who) public onlyOwner view returns (bool) {
        return _feeWhiteList[who];
    }
}

contract Token is NxToken {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () NxToken("XB", "XB") {        
    }
}