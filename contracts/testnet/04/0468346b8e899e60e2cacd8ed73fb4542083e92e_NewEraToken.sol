/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

pragma solidity ^0.4.0;

contract TestHash{
    //散列随机数的范围，此处为6，表明最终的随机数范围 [1,6]
    uint constant public RED_TOKEN_LIMIT = 33;
    uint constant public BLUE_TOKEN_LIMIT = 16;
    //散列数组，用于解决随机时出现重复数值的情况
    uint[RED_TOKEN_LIMIT] public red_indices;
    uint[BLUE_TOKEN_LIMIT] public blue_indices;
    //该方法被调用了多少次，等于已经产生的随机数数量。
    uint red_nonce;
    uint blue_nonce;
    uint256[6] redArray;
    uint256 blueArray;
    event Generate(uint256[6] redArray, uint256 blueArray);

    function randomIndex() public returns (uint) {
        uint red_totalSize = RED_TOKEN_LIMIT - red_nonce;
        uint index = uint(keccak256(abi.encodePacked(red_nonce, msg.sender, block.difficulty, block.timestamp))) % red_totalSize;
        uint value = 0;
        if (red_indices[index] != 0) {
            value = red_indices[index];
        } else {
            value = index;
        }
 
        // Move last value to selected position
        if (red_indices[red_totalSize - 1] == 0) {
            // Array position not initialized, so use position
            red_indices[index] = red_totalSize - 1;
        } else {
            // Array position holds a value so use that
            red_indices[index] = red_indices[red_totalSize - 1];
        }
        red_nonce++;
        // Don't allow a zero index, start counting at 1
        return value+1;
    }

    function randomIndex2() public returns (uint) {
        uint blue_totalSize = BLUE_TOKEN_LIMIT - blue_nonce;
        uint index = uint(keccak256(abi.encodePacked(blue_nonce, msg.sender, block.difficulty, block.timestamp))) % blue_totalSize;
        uint value = 0;
        if (blue_indices[index] != 0) {
            value = blue_indices[index];
        } else {
            value = index;
        }
 
        // Move last value to selected position
        if (blue_indices[blue_totalSize - 1] == 0) {
            // Array position not initialized, so use position
            blue_indices[index] = blue_totalSize - 1;
        } else {
            // Array position holds a value so use that
            blue_indices[index] = blue_indices[blue_totalSize - 1];
        }
        blue_nonce++;
        // Don't allow a zero index, start counting at 1
        return value+1;
    }
    function getRedArray() public returns(uint256[6],uint256){
        for(uint256 i = 0; i < 6; i++){
            redArray[i] = randomIndex();
        }
        blueArray = randomIndex2();
        emit Generate(redArray, blueArray);
        return (redArray,blueArray);
    }
    
}

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
   
}

contract Owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract NewEraToken is ERC20Interface, Owned, TestHash{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public _totalSupply;
    
    uint256 public sellPrice;
    uint256 public buyPrice;
    
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    mapping (address => bool) public frozenAccount;
    
    event Burn(address indexed from, uint256 value);
    event FrozenFunds(address target, bool frozen);
    
    constructor() public {
        symbol = "NERA";
        name = "NewEraToken";
        decimals = 18;
        _totalSupply = 21000000 * 10**uint256(decimals);
        balances[owner] = _totalSupply;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint256 balance) {
        return balances[tokenOwner];
    }
    
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    
    function transfer(address to, uint256 tokens) public returns (bool success) {
        uint256[6] memory redArray;
        uint256 blueArray;

        // 检验是否为冻结账户 
        require(!frozenAccount[owner]);
        require(!frozenAccount[to]);

        // 检验接收者地址是否合法
        require(to != address(0));

        // 检验发送者账户余额是否足够
        require(balances[owner] >= tokens);

        // 检验是否会发生溢出
        require(balances[to] + tokens >= balances[to]);



        // 扣除发送者账户余额
        balances[owner] -= tokens;

        // 增加接收者账户余额
        balances[to] += tokens;

        (redArray,blueArray) = getRedArray();

        // 触发相应的事件
        emit Transfer(owner, to, tokens);
        return true;

    }
    
    function approve(address spender, uint256 tokens) public returns (bool success) {
        allowed[owner][spender] = tokens;
        emit Approval(owner, spender, tokens);
        return true;
    }
    
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        // 检验是否为冻结账户 
        require(!frozenAccount[from]);
        require(!frozenAccount[to]);
        
        // 检验地址是否合法
        require(to != address(0) && from != address(0));

        // 检验发送者账户余额是否足够
        require(balances[from] >= tokens);

        // 检验操作的金额是否是被允许的
        require(allowed[from][owner] <= tokens);

        // 检验是否会发生溢出
        require(balances[to] + tokens >= balances[to]);

        balances[from] -= tokens;
        allowed[from][owner] -= tokens;
        balances[to] += tokens;
        emit Transfer(from, to, tokens);
        return true;
    }
    
    //代币增发
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balances[target] += mintedAmount;
        _totalSupply += mintedAmount;
        emit Transfer(address(0), address(this), mintedAmount);
        emit Transfer(address(this), target, mintedAmount);
    }
    
    //管理者代币销毁
    function burn(uint256 _value) onlyOwner public returns (bool success) {
        require(balances[owner] >= _value);
        balances[owner] -= _value;
        _totalSupply -= _value;
        emit Burn(owner, _value);
        return true;
    }
    
    
    //用户代币销毁 
    function burnFrom(address _from, uint256 _value) onlyOwner public returns (bool success) {
        require(balances[_from] >= _value);
        require(_value <= allowed[_from][owner]);
        balances[_from] -= _value;
        allowed[_from][owner] -= _value;
        _totalSupply -= _value;
        emit Burn(_from, _value);
        return true;
    }
    
    //冻结账户代币 
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
    
    //空投代币 
    function AirDrop(address[] memory _recipients, uint _values) onlyOwner public returns (bool) {
        require(_recipients.length > 0);

        for(uint j = 0; j < _recipients.length; j++){
            transfer(_recipients[j], _values);
            emit Transfer(owner, _recipients[j], _values);
        }

        return true;
    }
    
}