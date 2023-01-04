/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/

pragma solidity >=0.7.0 <0.9.0;

interface USDC {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract SpinBank {
    USDC public USDc;
    address private _owner;
    address private _b4u;
    uint private startTime;
    uint private winner;
    uint private rate;
    uint private game_time; 
    uint256 private min_amount;
    

    struct Player {
        address player;
        uint256 amount;
    }

    Player[] private players;

    constructor() {
        USDc = USDC(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);         
        _owner = msg.sender;
        _b4u = _owner;
        startTime = 0;
        winner = 0;
        rate = 5;
        game_time = 180;
        min_amount = 1000000000000000000;
    } 
  
    event msgGame(Player[], Player, string, uint);
    event msgService(string, uint);

    function changeOwner(address owner) public {
        require(msg.sender == _owner, "No permission");
        _owner = owner;
    }

    function changeVariable(uint r, uint g, uint256 m, address b) public {
        require(msg.sender == _owner, "No permission");
        rate = r;
        game_time = g;
        min_amount = m;
        _b4u = b;
    }

    function initGame() public {
        require(msg.sender == _owner, "No permission");  
        if( startTime == 0 ) {
            delete players;
            emit msgService("Game inited", block.timestamp); 
        } else {
            emit msgService("Game didn't end", block.timestamp); 
        }  
    } 

    function endGame() public {        
        require(msg.sender == _owner, "No permission");

        if( startTime != 0 && (block.timestamp - startTime) < game_time ) {
            emit msgService("Game can't end", block.timestamp); 
        }
        if( startTime == 0){            
            emit msgService("Game not started", block.timestamp); 
        } 

        if( startTime != 0 && (block.timestamp - startTime) >= game_time ) {
            uint _score = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 100;
            uint256 sum = 0;
            
            for(uint i = 0; i < players.length; i++){
                sum += players[i].amount;
            }
            uint256 sum_sub = 0;
            for(uint i = 0; i < players.length; i++){            
                uint bottom_val = sum_sub;
                sum_sub += players[i].amount;
                uint top_val = sum_sub;
                if( _score > ( bottom_val * 100 ) / sum && _score <= ( top_val * 100 ) / sum) {
                    winner = i;
                }            
            } 
            
            USDc.transfer(players[winner].player, sum * (100 - rate) / 100);
            USDc.transfer(_b4u, sum * rate / 100); 
            emit msgGame(players, players[winner], "winner", winner);
            startTime = 0;
        }      
    } 

    function depositMoney(uint256 amount) public {
        require(amount > min_amount, "Deposit amount should be greater than 0");

        if( startTime != 0 && (block.timestamp - startTime) > game_time ) {
            emit msgService("Game endded", block.timestamp);
            require(false, "Game endded");
        }

        USDc.transferFrom(msg.sender, address(this), amount);
        Player memory player = Player({player: msg.sender, amount: amount});   
        players.push(player);  

        emit msgGame(players, player, "deposit", 0);
        
        if(players.length == 1){ 
            emit msgGame(players, player, "Game created", block.timestamp);
        }  
        if(players.length == 2){
            startTime = block.timestamp;
            emit msgGame(players, player, "Game started", startTime);
        } 
    }

    function getPlayers() public view returns (Player[] memory) { 
        return players; 
    }  

    function getGameTime() public view returns (uint) {
        return block.timestamp - startTime;
    }    
}