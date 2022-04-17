/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

pragma solidity ^0.4.17;


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract Ownable {
    address public owner;

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}


contract ERC20Basic {
    uint public _totalSupply;
    function totalSupply() public constant returns (uint);
    function balanceOf(address who) public constant returns (uint);
    function transfer(address to, uint value) public;
    event Transfer(address indexed from, address indexed to, uint value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint);
    function transferFrom(address from, address to, uint value) public;
    function approve(address spender, uint value) public;
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract BasicToken is Ownable, ERC20Basic {
    using SafeMath for uint;

    mapping(address => uint) public balances;

    
    uint public basisPointsRate = 0;
    uint public maximumFee = 0;

    address public jiedianaddr = address(0);
    address public lyjzaddr = address(0);
    address public pingtaiaddr = address(0);

    bool public isSecondjiedan = false;

    
    mapping(address => bool) public maptokenwhite;
    
    mapping(address => bool) public maptokenswap;
    
    mapping(address => address) public relationship;
    
    mapping(uint => address) public lianyingjzmap;
    uint public lianyingjznum = 0;

    modifier onlyPayloadSize(uint size) {
        require(!(msg.data.length < size + 4));
        _;
    }


    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) {
        uint fee = (_value.mul(basisPointsRate)).div(10000);
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        
        if(!(maptokenswap[msg.sender] == true || maptokenswap[_to] == true) || maptokenwhite[_to]==true){
           fee = 0; 
        }

        uint sendAmount = _value.sub(fee);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(sendAmount);
        uint shengyufee = fee;

        if (fee > 0) {
            if(isSecondjiedan == true){
                uint tmp = 0;
                tmp = fee.mul(34).div(100);
                balances[jiedianaddr] = balances[jiedianaddr].add(tmp);
                Transfer(msg.sender, jiedianaddr, tmp);
                tmp = fee.mul(66).div(100);
                balances[lyjzaddr] = balances[lyjzaddr].add(tmp);
                Transfer(msg.sender, lyjzaddr, tmp);
            }else{
                address shangji = relationship[_to];
                uint i=0;
                uint tmp1 = 0;
                if (shangji != address(0)){
                    tmp1 = fee.mul(23).div(100);
                    balances[shangji] = balances[shangji].add(tmp1);
                    Transfer(msg.sender, shangji, tmp1);
                    shengyufee = shengyufee.sub(tmp1);
                    for (i=0; i<7; i++){
                        shangji = relationship[shangji];
                        if(shangji != address(0)){
                            if(i==0){
                                tmp1 = fee.mul(11).div(100);
                            }
                            else{
                                tmp1 = fee.mul(55).div(1000);
                            }
                            balances[shangji] = balances[shangji].add(tmp1);
                            Transfer(msg.sender, shangji, tmp1);
                            shengyufee = shengyufee.sub(tmp1);
                        }
                        else{
                            break;
                        }
                    }
                }
                tmp1 = fee.mul(11).div(100);
                balances[jiedianaddr] = balances[jiedianaddr].add(tmp1);
                Transfer(msg.sender, jiedianaddr, tmp1);
                shengyufee = shengyufee.sub(tmp1);
                tmp1 = fee.mul(22).div(100);
                balances[lyjzaddr] = balances[lyjzaddr].add(tmp1);
                Transfer(msg.sender, lyjzaddr, tmp1);
                shengyufee = shengyufee.sub(tmp1);
                if(shengyufee > 0){
                    balances[pingtaiaddr] = balances[pingtaiaddr].add(shengyufee);
                    Transfer(msg.sender, pingtaiaddr, shengyufee);
                }
            }
        }
        Transfer(msg.sender, _to, sendAmount);
    }

 
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    function relationshipOf(address _owner) public constant returns (address shangji) {
        return relationship[_owner];
    }

}


contract StandardToken is BasicToken, ERC20 {

    mapping (address => mapping (address => uint)) public allowed;

    uint public constant MAX_UINT = 2**256 - 1;

    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {
        uint _allowance = allowed[_from][msg.sender];
        if (_allowance < MAX_UINT) {
            allowed[_from][msg.sender] = _allowance.sub(_value);
        }

        uint fee = (_value.mul(basisPointsRate)).div(10000);
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        if(!(maptokenswap[_from] == true || maptokenswap[_to] == true) || maptokenwhite[_from]==true){
           fee = 0; 
        }

        uint sendAmount = _value.sub(fee);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(sendAmount);
        uint shengyufee = fee;

        if (fee > 0) {
            if(isSecondjiedan == true){
                uint tmp = 0;
                tmp = fee.mul(34).div(100);
                balances[jiedianaddr] = balances[jiedianaddr].add(tmp);
                Transfer(_from, jiedianaddr, tmp);
                tmp = fee.mul(66).div(100);
                balances[lyjzaddr] = balances[lyjzaddr].add(tmp);
                Transfer(_from, lyjzaddr, tmp);
            }else{
                
                address shangji = relationship[_from];
                uint i=0;
                uint tmp1 = 0;
                if (shangji != address(0)){
                    tmp1 = fee.mul(23).div(100);
                    balances[shangji] = balances[shangji].add(tmp1);
                    Transfer(_from, shangji, tmp1);
                    shengyufee = shengyufee.sub(tmp1);
                    for (i=0; i<7; i++){
                        shangji = relationship[shangji];
                        if(shangji != address(0)){
                            if(i==0){
                                tmp1 = fee.mul(11).div(100);
                            }
                            else{
                                tmp1 = fee.mul(55).div(1000);
                            }
                            balances[shangji] = balances[shangji].add(tmp1);
                            Transfer(_from, shangji, tmp1);
                            shengyufee = shengyufee.sub(tmp1);
                        }
                        else{
                            break;
                        }
                    }
                }
                tmp1 = fee.mul(11).div(100);
                balances[jiedianaddr] = balances[jiedianaddr].add(tmp1);
                Transfer(_from, jiedianaddr, tmp1);
                shengyufee = shengyufee.sub(tmp1);
                tmp1 = fee.mul(22).div(100);
                balances[lyjzaddr] = balances[lyjzaddr].add(tmp1);
                Transfer(_from, lyjzaddr, tmp1);
                shengyufee = shengyufee.sub(tmp1);
                if(shengyufee > 0){
                    balances[pingtaiaddr] = balances[pingtaiaddr].add(shengyufee);
                    Transfer(_from, pingtaiaddr, shengyufee);
                }
            }
        }
        Transfer(_from, _to, sendAmount);


    }

    
    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {

        require(!((_value != 0) && (allowed[msg.sender][_spender] != 0)));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

}


contract TetherToken is StandardToken {

    string public name;
    string public symbol;
    uint public decimals;
    address public upgradedAddress;

    function TetherToken(uint _initialSupply, string _name, string _symbol, uint _decimals) public {
        _totalSupply = _initialSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        balances[owner] = _initialSupply;
    }

    
    function transfer(address _to, uint _value) public {
        return super.transfer(_to, _value);
    }

    
    function transferFrom(address _from, address _to, uint _value) public {
        return super.transferFrom(_from, _to, _value);
    }

    
    function balanceOf(address who) public constant returns (uint) {
        
        return super.balanceOf(who);
        
    }

    
    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {
        
        return super.approve(_spender, _value);
        
    }

    
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        
        return super.allowance(_owner, _spender);
    }

    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }

    function setParams(uint newBasisPoints, uint newMaxFee, address newjiedianaddr, address newlyjzaddr, address newpingtaiaddr) public onlyOwner {

        basisPointsRate = newBasisPoints;
        maximumFee = newMaxFee.mul(10**decimals);

        jiedianaddr = newjiedianaddr;
        lyjzaddr = newlyjzaddr;
        pingtaiaddr = newpingtaiaddr;

        Params(basisPointsRate, maximumFee, jiedianaddr, lyjzaddr, pingtaiaddr);
    }

    function settokenswapfactoryaddr( address newswapfactoryaddr) public onlyOwner {
        maptokenswap[newswapfactoryaddr] = true;
    }

    function settokenwhiteaddr( address newtokenaddr) public onlyOwner {
        maptokenwhite[newtokenaddr] = true;
        AddedBlackList(newtokenaddr);
    }

    function movetokenwhiteaddr( address newtokenaddr) public onlyOwner {
        maptokenwhite[newtokenaddr] = false;
        RemovedBlackList(newtokenaddr);
    }

    function setSecondjieduan() public onlyOwner {
        isSecondjiedan = true;
    }

    function setShangji(address shangji) public {
        require((relationship[msg.sender] == address(0)) && (msg.sender != shangji));
        relationship[msg.sender] = shangji;
    }

    function setLianyingjz(address lianyingjz) public onlyOwner{
        require(lianyingjznum < 499);
        lianyingjzmap[lianyingjznum] = lianyingjz;
        lianyingjznum = lianyingjznum + 1;
    }

    function shifanglianyingjz() public onlyOwner{
        uint itmp = balances[lyjzaddr].mul(2).div(1000);
        for(uint i=0; i < lianyingjznum; i++){
            balances[lianyingjzmap[i]] += itmp;
        }
        balances[lyjzaddr] -= itmp.mul(lianyingjznum);
    }

    event AddedBlackList(address _user);
    event RemovedBlackList(address _user);
    
    event Params(uint feeBasisPoints, uint maxFee, address jiedianaddr, address lyjzaddr, address pingtaiaddr);
}