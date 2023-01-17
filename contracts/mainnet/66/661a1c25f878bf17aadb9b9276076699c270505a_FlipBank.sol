/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

pragma solidity >=0.7.0 <0.9.0;

interface USDC {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract FlipBank {
    USDC private bUSD;
    address private _owner;
    address private _b4u;
    uint256 private rooms;
    uint256 private _rate;
    uint256 private min_amount;

    struct Player {
        uint256 index;
        uint256 side;
        uint256 winner;
        uint256 amount;
        address player1;
        address player2;
        string status; // true: wait false: init
        uint256 update;
    }

    Player[] private players;

    constructor() {
        bUSD = USDC(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        _owner = msg.sender;
        _b4u = _owner;
        _rate = 5;
        min_amount = 5000000000000000000;
    }

    event msgGame(Player[], uint256, string);
    event msgService(string, uint256, address);

    function changeOwner(address owner) public {
        require(msg.sender == _owner, "No permission");
        _owner = owner;
    }

    function changeVariable(uint r, uint256 m, address b) public {
        require(msg.sender == _owner, "No permission");
        _rate = r; 
        min_amount = m;
        _b4u = b;
    }

    function initGame(uint256 number_rooms) public {
        require(msg.sender == _owner, "No permission");
        delete players;
        rooms = number_rooms;
        for (uint256 i = 0; i < rooms; i++) {
            Player memory player = Player({
                index: i,
                side: 0,
                winner: 2,
                amount: 0,
                player1: address(0),
                player2: address(0),
                status: "init",
                update: block.timestamp
            });
            players.push(player);
        }
        emit msgGame(players, 0, "flip_inited");
        emit msgService("init_game", block.timestamp, msg.sender);
    }

    function openFlip(uint256 side, uint256 amount) public {
        require(amount >= min_amount, "Amount should be greater than minimum amount");
        require((0 <= side && side < 2), "Out of range");
        bool hasRoom = false;
        for (uint256 i = 0; i < rooms; i++) {
            if (
                keccak256(abi.encodePacked(players[i].status)) ==
                keccak256(abi.encodePacked("init"))
            ) {
                Player memory player = Player({
                    index: i,
                    side: side,
                    winner: 2,
                    amount: amount,
                    player1: msg.sender,
                    player2: address(0),
                    status: "wait",
                    update: block.timestamp
                });
                players[i] = player;
                bUSD.transferFrom(msg.sender, address(this), amount);
                hasRoom = true;
                emit msgGame(players, i, "flip_created");
                break;
            }
        }
        if (!hasRoom) {
            emit msgService("no rest room", block.timestamp, msg.sender);
            require(hasRoom, "no rest room");
        }
    }

    function closeFlip(uint256 index, uint256 amount) public {
        require((index >= 0 && index < rooms), "Out of Rooms");
        require(players[index].amount == amount, "Logic Error");
        bUSD.transferFrom(msg.sender, address(this), amount);
        uint256 _side = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.difficulty, msg.sender)
            )
        ) % 2;
        Player memory player = Player({
            index: index,
            side: players[index].side,
            winner: _side,
            amount: players[index].amount,
            player1: players[index].player1,
            player2: msg.sender,
            status: "init",
            update: block.timestamp
        });
        players[index] = player;
        if (_side == player.side) {
            bUSD.transfer(player.player1, (amount * 2 * (100 - _rate)) / 100);
        } else {
            bUSD.transfer(player.player2, (amount * 2 * (100 - _rate)) / 100);
        }
        emit msgGame(players, index, "flip_closed");
        emit msgService("flip_closed", index, msg.sender);
        bUSD.transfer(_b4u, (amount * 2 * _rate) / 100);
    }
}