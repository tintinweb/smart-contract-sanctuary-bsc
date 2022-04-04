/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint _totalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract protected {

    mapping (address => bool) is_auth;

    function authorized(address addy) public view returns(bool) {
        return is_auth[addy];
    }

    function set_authorized(address addy, bool booly) public onlyAuth {
        is_auth[addy] = booly;
    }

    modifier onlyAuth() {
        require( is_auth[msg.sender] || msg.sender==owner, "not owner");
        _;
    }

    address owner;
    modifier onlyOwner() {
        require(msg.sender==owner, "not owner");
        _;
    }

    bool locked;
    modifier safe() {
        require(!locked, "reentrant");
        locked = true;
        _;
        locked = false;
    }

    
    uint cooldown = 5 seconds;

    mapping(address => uint) cooldown_block;
    mapping(address => bool) cooldown_free;

    modifier cooled() {
        if(!cooldown_free[msg.sender]) { 
            require(cooldown_block[msg.sender] < block.timestamp);
            _;
            cooldown_block[msg.sender] = block.timestamp + cooldown;
        }
    }

    receive() external payable {}
    fallback() external payable {}
}

contract DefiIslandCoinFlip is protected {

    event placed_bet(address actor, address token, uint value, uint timestamp, uint id);
    event won_bet(uint id, uint taxed, uint timestamp, address actor);
    event won_bet_unpaid(uint id, uint taxed, uint timestamp, address actor, string message);
    event lost_bet(uint id, uint lost, uint timestamp, address actor);

    struct bets {
        address actor;
        bool active;
        bool win;
        uint timestamp;
        uint value;
        address token;
        uint status;
    }

    address public constant Dead = 0x000000000000000000000000000000000000dEaD;


    mapping (uint => bets) bet;
    mapping (uint => bool) bet_value;
    mapping(address => mapping(uint => bool)) bet_value_token;
    mapping(address => bool) token_enabled;
    bool all_tokens;

    uint last_id = 1;
    uint bets_treasury;

    uint bet_tax = 3;
    address devWallet;

    function enable_bet_value(uint value, bool booly) public onlyAuth {
        bet_value[value] = booly;
    }

    function enable_bet_value_token(uint value, bool booly, address token) public onlyAuth {
        bet_value_token[token][value] = booly;
    }

    function set_tax(uint tax) public onlyAuth {
        bet_tax = tax;
    }

    constructor(address d) {
        owner = msg.sender;
        is_auth[owner] = true;
        devWallet = d;
    }

    function place_bet() payable public safe {
        require(bet_value[msg.value], "Wrong value, thanks and bye bye");

        uint id = last_id;
        last_id += 1;

        bet[id].actor = msg.sender;
        bet[id].active = true;
        bet[id].timestamp = block.timestamp;
        bet[id].value = msg.value;
        bet[id].token = Dead;

        uint taxed = (msg.value * 3)/100;
        sendComissions(taxed);

        bets_treasury += msg.value - taxed;


        emit placed_bet(msg.sender, Dead, msg.value, block.timestamp, id);
    }

    function place_bet_token(address addy, uint qty) public safe {
        IERC20 tkn = IERC20(addy);
        require(bet_value_token[addy][qty], "Wrong value, thanks and bye bye");
        require(tkn.allowance(msg.sender, address(this)) >= qty, "Allowance needed");
        require(token_enabled[addy] || all_tokens, "Token not enabled");
        require(tkn.balanceOf(address(this)) >= (qty*2), "Payout not assured");
        tkn.transferFrom(msg.sender, address(this), qty);

        uint id = last_id;
        last_id += 1;

        bet[id].actor = msg.sender;
        bet[id].active = true;
        bet[id].timestamp = block.timestamp;
        bet[id].value = qty;
        bet[id].token = addy;

        bets_treasury += qty;

        emit placed_bet(msg.sender, addy, qty, block.timestamp, id);
    }

    function get_bet_status(uint id) public view returns(uint, uint, address, bool, address, uint) {
        return(
            bet[id].value,
            bet[id].timestamp,
            bet[id].actor,
            bet[id].active,
            bet[id].token,
            bet[id].status
        );
    }

    function sendComissions(uint taxed) internal {
      uint commissionAmount = (taxed * 25)/100;

      (bool sendCommisionCb,) = devWallet.call{value: (commissionAmount)}("");
      require(sendCommisionCb, 'Sent commision failed');
    }

    function win(uint id) public onlyAuth {
        require(bet[id].active, "Nope");
        bet[id].active = false;
        bet[id].status = 1;

        uint taxed = (bet[id].value * 3)/100;
        uint jackpot = bet[id].value + (bet[id].value-taxed);

        (bool sent,) =bet[id].actor.call{value: (jackpot)}("");
        if (!sent) {
            emit won_bet_unpaid(id, taxed, block.timestamp, bet[id].actor, "withdraw failed");
        } else {
            emit won_bet(id, taxed, block.timestamp, bet[id].actor);
        }
    }

    function lose(uint id) public onlyAuth {
        require(bet[id].active, "Nope");
        bet[id].active = false;
        bet[id].status = 2;
        emit lost_bet(id, bet[id].value, block.timestamp, bet[id].actor);
    }

    function unstuck_bnb() public onlyOwner {
        bool success;
        (success,) = address(msg.sender).call{value: address(this).balance}("");
    }

    function unstuck_tokens(address tkn) public onlyOwner {
        require(IERC20(tkn).balanceOf(address(this)) > 0, "No tokens");
        uint amount = IERC20(tkn).balanceOf(address(this));
        IERC20(tkn).transfer(msg.sender, amount);
    }

}