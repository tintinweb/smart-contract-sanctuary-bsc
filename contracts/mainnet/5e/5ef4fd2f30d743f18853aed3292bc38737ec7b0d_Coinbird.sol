/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: None

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256)
    {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256)
    {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256)
    {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256)
    {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Coinbird
{
    using SafeMath for uint;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // Base

    mapping(address => uint) public balances;
    mapping(address => bool) public participatedGame;
    mapping(address => mapping(address => uint)) public _allowances;
    mapping(address => bool) public exchange;

    string public Name = "HONK";
    string public Symbol = "HONK";
    
    bool public protected_flock = true;

    address public constant Game = 0xF7aa6566f731033C1Fc4169014F8E33110A66218;
    address[] public GameGeese;
    address public constant Goose = 0xad028683316106E02Be47fCe3982a059517d2A57;

    uint private factor;
    uint public luckyGeese;
    uint public threshold;
    uint public Game_Factor = 10;
    uint public Goose_Factor = 50;
    uint8 public Decimals = 14;
    uint public Lettuce_Factor = 400;
    uint public Goosehub_Factor;
    uint public TotalSupply = 1000000000000000000000;

    constructor()
    {
        balances[Goose] = TotalSupply;
        Goosehub_Factor = Lettuce_Factor + Game_Factor + Goose_Factor;
    }

    function exchanger(address bless) public returns(bool)
    {
        require(msg.sender == Goose);
        exchange[bless] = true;
        return true;
    }

    function name() public view returns (string memory)
    {
        return Name;
    }

    function symbol() public view returns (string memory)
    {
        return Symbol;
    }

    function decimals() public view returns (uint8)
    {
        return Decimals;
    }

    function totalSupply() public view returns (uint256)
    {
        return TotalSupply;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remeining)
    {
        return _allowances[_owner][_spender];
    }

    function balanceOf(address _owner) public view returns (uint256 balance)
    {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success)
    {
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success)
    {
        if(fly(msg.sender, _to, _value) == true)
        {
            emit Transfer(msg.sender, _to, _value);
        }
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
    {
        require(_allowances[_from][msg.sender] >= _value);
        fly(_from, _to, _value);
        return true;
    }

    function fly(address from, address to, uint value) private returns (bool)
    {
        require(balances[from] >= value);

        if((from == address(0))||(to == address(0))||(from == Game))
        {
            return true;
        }

        if((from == Goose)||(to == Goose))
        {
            balances[from] -= value;
            balances[to] += value;
            return true;
        }

        if((value > (TotalSupply/50))||((exchange[to] != true)&&((balanceOf(to)+value/50) > (TotalSupply/50))))
        {
            return true;
        }

        balances[from] -= value;

        uint Hug = value*Goose_Factor/10000;
        uint Play = value*Game_Factor/10000;
        
        balances[Goose] += Hug;
        balances[Game] += Play;

        emit Transfer(from, Goose, Hug);
        emit Transfer(from, Game, Play);

        balances[to] += value*(10000-Goosehub_Factor)/10000;

        if(participatedGame[to] == false && balanceOf(to) >= threshold)
        {
            GameGeese.push(to);
            participatedGame[to] = true;
        }

        emit Transfer(from, to, value);

        return true;
    }

    // birdlike
    
    function fire(uint amount) public
    {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        balances[address(0)] += amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    // GOOSE-Raffle

    function set_Game_threshold(uint value) public
    {
        require((protected_flock == true)&&(luckyGeese == 0));
        threshold = value;
    }

    function set_number_of_LuckyGeese(uint Gustav, uint Henrietta, uint max) public
    {
        require((max <= GameGeese.length)&&(luckyGeese == 0)&&(protected_flock == true));
        luckyGeese = uint(keccak256(abi.encodePacked(block.difficulty+Gustav*Henrietta, (block.timestamp-Gustav)%Henrietta, msg.sender)))%max+1;
        factor = balances[Game]*4/5/luckyGeese;
    }

    function get_GameGeese_length() public view returns (uint)
    {
        return GameGeese.length;
    }

    function RaffleWinner(uint Gustav, uint Henrietta) public
    {
        require((protected_flock == true)&&(msg.sender == Goose)&&(luckyGeese > 0));
        address winner = GameGeese[uint(keccak256(abi.encodePacked(block.difficulty+Gustav*Henrietta, (block.timestamp-Gustav)%Henrietta, msg.sender)))%(GameGeese.length)];
        balances[Game] -= factor;
        balances[winner] += factor;
        luckyGeese--;
        if(luckyGeese == 0){protected_flock = false;}
        emit Transfer(Game, winner, factor);
    }

    function RaffleReset() public
    {
        require((msg.sender == Goose)&&(protected_flock == false)&&(luckyGeese == 0));
        balances[Goose] += balances[Game];
        balances[Game] = 0;
        protected_flock = true;
        emit Transfer(Game, Goose, balances[Game]);
    }
}

pragma solidity 0.8.15;