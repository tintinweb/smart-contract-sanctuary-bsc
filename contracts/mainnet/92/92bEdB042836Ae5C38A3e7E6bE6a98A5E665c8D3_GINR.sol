/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;

abstract contract ERC20Interface {
    function totalSupply() public virtual view returns (uint);
    function balanceOf(address tokenOwner) public virtual view returns (uint balance);
    function allowance(address tokenOwner, address spender) public virtual view returns (uint remaining);
    function transfer(address to, uint tokens) public virtual returns (bool success);
    function approve(address spender, uint tokens) public virtual returns (bool success);
    function transferFrom(address from, address to, uint tokens) public virtual returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event OwnershipTransfer(address indexed previousOwner, address indexed newOwner);
    event Bought(uint256 amount);
    event Sold(uint256 amount);

}

contract DEX {

    ERC20Interface public token;

    event Bought(uint256 amount);
    event Sold(uint256 amount);

    constructor() {
        token = new GINR();
    }

    function buy() payable public {
        // TODO
    }

    function sell(uint256 amount) public {
        // TODO
    }

}


contract GINR is ERC20Interface{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 private _totalSupply;
    address public owner;
    address public Charity = 0x2B15e14aB45cA29edc334653DD08f08Fbdc07295;
    address public Marketing = 0xA4c7B5b946b757Ab23b18fAF4Eb03DF295Cd7737;
    address [] public holders;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() {
        name = "GandhijiGold";
        symbol = "GINR";
        decimals = 18;
        _totalSupply = 1000000000000000000000000000;
        owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        balances[owner] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public override view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public override view returns (uint balance) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public override view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public override returns (bool success) {
        require(tokens<=balances[msg.sender]);
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transfer(address to, uint tokens) public override returns (bool success) {
        require(balances[msg.sender] >= tokens);
        unchecked{balances[msg.sender] -= tokens;}
        unchecked{balances[to] += tokens;}
        emit Transfer(msg.sender, to, tokens);
        holders.push(to);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
        require(tokens <= allowed[from][msg.sender]);
        unchecked{balances[from] -= tokens;}
        unchecked{allowed[from][msg.sender] -= tokens;}
        unchecked{balances[to] += tokens;}
        emit Transfer(from, to, tokens);
        return true;
    }

    function buy() payable public {
    uint256 amountTobuy = msg.value;
    uint256 dexBalance = GINR.balanceOf(address(this));
    require(amountTobuy > 0, "You need to send some ether");
    require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
    //9% -> 3% Charity -> 2% Distribution -> 2% Marketing
        uint256 charityTax = ((amountTobuy * 3)/100);
        unchecked{balances[msg.sender] -= charityTax; }
        balances[Charity] += charityTax;
        uint256 holdersReward = ((amountTobuy * 2)/100);
        unchecked{balances[msg.sender] -= holdersReward; }
        for(uint256 i = 0 ; i<holders.length ; i++){
            address j = holders[i];
            unchecked{balances[j] += holdersReward;}
        }
        uint256 MarTax = ((amountTobuy * 2)/100);
        unchecked{balances[Marketing] += MarTax;}
    GINR.transfer(msg.sender, amountTobuy);
    emit Bought(amountTobuy);
}

function sell(uint256 amount) public {
    require(amount > 0, "You need to sell at least some tokens");
    uint256 allowanc = GINR.allowance(msg.sender, address(this));
    require(allowanc >= amount, "Check the token allowance");
    //2% distribution on selling
        uint256 holdersReward = ((amount * 2)/100);
        unchecked{balances[msg.sender] -= holdersReward; }
        unchecked{allowanc -= holdersReward; }
        for(uint256 i = 0 ; i<holders.length ; i++){
            address j = holders[i];
            unchecked{balances[j] += holdersReward;}
        }
    GINR.transferFrom(msg.sender, address(this), amount);
    payable(msg.sender).transfer(amount);
    emit Sold(amount);
}



    function newOwner(address _newOwner) public virtual {
        require(msg.sender == owner, "You are not the owner");
        require(_newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransfer(owner, _newOwner);
        owner = _newOwner;
    }
}