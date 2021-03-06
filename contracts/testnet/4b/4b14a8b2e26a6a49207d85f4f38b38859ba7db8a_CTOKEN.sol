/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

pragma solidity ^0.8.0;

library SafeMath{

    function add(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a+b;
        assert (c>=a);
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256)
    {
        assert(a>=b);
        return (a-b);
    }

    function mul(uint256 a,uint256 b)internal pure returns (uint256)
    {
        if (a==0)
        {
        return 0;
        }
        uint256 c = a*b;
        assert ((c/a)==b);
        return c;
    }

    function div(uint256 a,uint256 b)internal pure returns (uint256)
    {
        return a/b;
    }
}



abstract contract claimable {

    address public owner;

    constructor() internal
    {
        owner = msg.sender;
    }

    modifier onlyowner()
    {
        require(msg.sender==owner);
        _;
    }

    event Pause();
    event Unpause();
    bool public _pause = false;

    modifier whenNotPaused()
    {
        require(!_pause);
        _;
    }
    modifier whenPaused()
    {
        require(_pause);
        _;
    }

    function pause() onlyowner whenNotPaused public{
        _pause = true;
        emit Pause();
    }

    function unpause() onlyowner whenPaused public{
        _pause = false;
        emit Unpause();
    }

    address public pendingOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyPendingOwner(){
        require(msg.sender == pendingOwner);
        _;
    }

    function transferOwnership(address newOwner) onlyowner public{
        pendingOwner = newOwner;
    }

    function claimOwnership() onlyPendingOwner public{
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}

interface ERC20 {
  function transfer(address _to, uint256 _value) external returns (bool);
  function balanceOf(address _owner) external view returns (uint256 balance);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
  function totalSupply() external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
}

contract CTOKEN is claimable{
    ERC20 public ETKO_Token;

    using SafeMath for uint256;
    string public constant name = "FTOKEN";
    string public constant symbol = "FTOKEN";
    uint256 public decimals = 18;
    uint256 totalsupply =  16000000000*(10**decimals);
    address public contract_owner;//????????????
    address public swap_addr;//????????????(swap)
    uint256 public start_time = 1655827200;//2022-06-22 00:00(+0)
    uint256 public referrer = 5;//5% = (5/100) ??????????????????
    uint256 public buy_fee = 10;//10% = (10/100) ??????-??????10%
    uint256 public sell_fee = 50;//50% = (50/100) ??????-??????50%

    mapping (address => uint256) public swap_balances;
    mapping (address => bool) public is_send;//???????????????
    mapping (address => uint256) internal balances;
    mapping (address => mapping(address =>uint256)) internal allowed;
    mapping (address => address) public referer;//???????????????
    uint256 totaltoken;

    uint public max_balance = 10000;//????????????1000
    uint public oneday_send = 200; // ??????????????????200
    uint public fourhour_send = 50; // ???4??????????????????50

    mapping (address => mapping (uint8 => uint)) public user_ods;//1???-send
    mapping (address => mapping (uint8 => uint)) public user_fhs;//4???-sned

    event Approval(address owner, address spender, uint256 value);
    event Burn(address from, uint256 value); 
    event transfer_event(uint256 start_time, uint256 end_time, address _from, address _to, uint256 _num);
    event chk_log(string _type,uint256 _hour, uint256 end_time, address _addr, uint256 _0, uint256 _1, bool is_next);
    event require_log(string _type, uint256 _a, uint256 _b);

    constructor () public{
        balances[msg.sender] = totalsupply;
        totaltoken = totalsupply;

        swap_addr = msg.sender;
        contract_owner = msg.sender;

        //ETKO_Token = ERC20(0x4Cdb2987996Ccdb22027C0748A4C6Bb682081d93);//????????????
    }

    modifier onlyOwner() {
        require(msg.sender == contract_owner);
        _;
     }

    function totalSupply() public view returns (uint256){
        return totaltoken;
    }

    function balanceOf(address _owner) public view returns (uint256 balance){
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool){
        require(_to!=address(0));
        require(_value <= balances[msg.sender]);
        uint256 _end_time = block.timestamp;
        if(msg.sender != contract_owner && _to != contract_owner)//?????????????????????
        {
            //?????????????????????100?????????,????????????????????????
            require(is_send[msg.sender],"Unable to send.");

            //????????????????????????10000?????????
            require(balances[_to].add(_value) <= max_balance*1*10**decimals,"Max 10000");

            emit require_log("balances_1000", balances[_to].add(_value), max_balance*1*10**decimals);


            //??????????????????????????????
            bool A; 
            string memory B;
            (A, B) = chk_transaction(msg.sender,_value,"send"); 
            require(A,B);

        }

        // uint256 burn_num = 0;
        // // ??????
        // if(msg.sender == swap_addr)//??????
        // {
        //     burn_num = (_value*buy_fee)/100;
        //     require(balances[swap_addr] > burn_num);
        //     totaltoken = totaltoken.sub(burn_num);
        //     balances[swap_addr] = balances[swap_addr].sub(burn_num);
        // }
        // else if(_to == swap_addr)//??????
        // {
        //     burn_num = (_value*sell_fee)/100;
        //     require(balances[swap_addr] > burn_num);
        //     totaltoken = totaltoken.sub(burn_num);
        //     balances[swap_addr] = balances[swap_addr].sub(burn_num);
        // }
        

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        
        if(msg.sender == swap_addr)
        {
            //?????????????????????100?????????,????????????????????????
            swap_balances[_to] = swap_balances[_to].add(_value);
            if(swap_balances[_to] >= 100*1*10**decimals)
            {
                is_send[_to] = true;
            }
        }


        //emit Transfer(msg.sender, _to, _value);
        emit transfer_event(start_time, _end_time, msg.sender, _to, _value);//??????????????????

        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused  returns (bool){
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        uint256 _end_time = block.timestamp;
        if(msg.sender != contract_owner && _to != contract_owner && _from != contract_owner)//?????????????????????
        {
            //?????????????????????100?????????,????????????????????????
            require(is_send[_from],"Unable to send.");

            //????????????????????????1000?????????
            require(balances[_to].add(_value) <= max_balance*1*10**decimals,"Max 1000");

            //??????????????????????????????
            bool A; 
            string memory B;
            (A, B) = chk_transaction(msg.sender,_value,"send"); 
            require(A,B);

        }

        // uint256 burn_num = 0;
        // // ??????
        // if(_from==swap_addr)//??????
        // {
        //     burn_num = (_value*buy_fee)/100;
        //     require(balances[swap_addr] > burn_num);
        //     totaltoken = totaltoken.sub(burn_num);
        //     balances[swap_addr] = balances[swap_addr].sub(burn_num);
        // }
        // else if(_to==swap_addr)//??????
        // {
        //     burn_num = (_value*sell_fee)/100;
        //     require(balances[swap_addr] > burn_num);
        //     totaltoken = totaltoken.sub(burn_num);
        //     balances[swap_addr] = balances[swap_addr].sub(burn_num);
        // }

        

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        if(_from == swap_addr)
        {
            //?????????????????????100?????????,????????????????????????
            swap_balances[_to] = swap_balances[_to].add(_value);
            if(swap_balances[_to] >= 100*1*10**decimals)
            {
                is_send[_to] = true;
            }
        }


        //emit Transfer(_from, _to, _value);
        emit transfer_event(start_time, block.timestamp, _from, _to, _value);//??????????????????

        return true;
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool){
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256){
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool){
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool){
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue)
        {
            allowed[msg.sender][_spender] = 0;
        }
        else
        {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    
    function burn(uint256 tokens) public returns (bool){
        // ??????????????????
        require(tokens <= balances[msg.sender]);
        // ?????? total supply
        totaltoken = totaltoken.sub(tokens);
        // ?????? msg.sender balance
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        
        emit Burn(msg.sender, tokens);
        //emit Transfer(msg.sender, address(0), tokens);
        return true;
    }

    function get_time_key(address _addr, uint256 _e, uint256 _hour, string memory _type) public returns (uint256){
        uint256 x1 = 0;
        x1 = (_e.sub(start_time)) / (60*_hour);//???????????????(24?????? or 4??????)
        if(chk_string(_type,"send"))
        {
            if(_hour==24)
            {
                if(x1 > user_ods[_addr][0])
                {
                    user_ods[_addr][0] = x1;//??????????????????
                    user_ods[_addr][1] = 0;//???????????????

                    emit chk_log("send", _hour, _e, _addr, user_ods[_addr][0], user_ods[_addr][1], true);

                    return user_ods[_addr][1];
                }
                else
                {
                    emit chk_log("send", _hour, _e, _addr, user_ods[_addr][0], user_ods[_addr][1], false);
                    return user_ods[_addr][1];
                }
            }
            else if(_hour==4)
            {
                if(x1 > user_fhs[_addr][0])
                {
                    user_fhs[_addr][0] = x1;//??????????????????
                    user_fhs[_addr][1] = 0;//???????????????

                    emit chk_log("send", _hour, _e, _addr, user_fhs[_addr][0], user_fhs[_addr][1], true);
                    return user_fhs[_addr][1];
                }
                else
                {
                    emit chk_log("send", _hour, _e, _addr, user_fhs[_addr][0], user_fhs[_addr][1], false);
                    return user_fhs[_addr][1];
                }
            }
        }


    }

    function chk_transaction(address _addr, uint256 _num, string memory _type) public returns (bool, string memory){
        uint256 end_time = block.timestamp;
        string memory m;

        uint256 day_b = get_time_key(_addr, end_time, 24, _type);
        uint256 hour_b = get_time_key(_addr, end_time, 4, _type);

        bool r = true;
        if(_addr != contract_owner)
        {
            if(chk_string(_type,"send"))
            {
                if(hour_b.add(_num) > fourhour_send*1*10**decimals)
                {
                    r = false;
                    m = "Sending limit exceeded. (4 Hour)";
                }
                else if(day_b.add(_num) > oneday_send*1*10**decimals)
                {
                    r = false;
                    m = "Sending limit exceeded. (1 Day)";
                }
                else
                {
                    user_ods[_addr][1] = user_ods[_addr][1].add(_num);//1day_send
                    user_fhs[_addr][1] = user_fhs[_addr][1].add(_num);//4hour_send
                }
            }

        }

        return (r,m);
    }

    function get_referrer(address _addr) public returns (address){
        return referer[_addr];
    }

    function set_max_balance(uint256 num) public onlyOwner {
        max_balance = num;
    }

    function set_swap_addr(address _addr) public onlyOwner {
        require(_addr != address(0));
        swap_addr = _addr;
    }

    function set_oneday(uint num, string memory _type) public onlyOwner {
        require(num>0);
        if(chk_string(_type,"send"))
        {
            oneday_send = num;
        }
    }

    function set_fourhour(uint num, string memory _type) public onlyOwner {
        require(num>0);
        if(chk_string(_type,"send"))
        {
            fourhour_send = num;
        }
    }

    function set_referrer(uint8 _num) public onlyOwner {
        referrer = _num;
    }

    function set_EToken(address _addr) public onlyOwner {
        require(_addr != address(0));
        ETKO_Token = ERC20(_addr);//????????????
    }


    function chk_string(string memory a, string memory b) internal returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function set_referer(address _addr) public returns (bool) {
        require(_addr != address(0));
        referer[msg.sender] = _addr;
        return true;
    }

    
}