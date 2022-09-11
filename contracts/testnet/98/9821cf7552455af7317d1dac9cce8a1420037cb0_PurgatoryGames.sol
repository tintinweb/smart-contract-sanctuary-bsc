/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

// File: contracts/gamble.sol


pragma solidity ^0.8.17;

interface Purgatory {
    function Gamble(uint) external view returns (address creator, bool complete, uint256 stake, uint256 tickets, uint256 game);
    function useRandom(uint x) external view returns(uint);
    function mint(address account, uint amount) external returns(bool);
    function SoultoNFTsOfOwner(uint stake, address owner) external;
    function addSoulpool(uint x) external returns(bool);
    function SoulValue() external view returns(uint);
    function addgamerounds() external;
    function showgamerounds() external view returns(uint);
    function addSoultoken(uint value, uint e) external returns(bool);
    function burn(uint amount) external returns(bool);
    function GameX(uint gamenr) external;
    function gameticket(uint x) external view returns(address[] calldata ticket);
    function gametarget(uint x) external view returns(uint[] memory ticket);
    function addtickets(uint gamenr) external;
}

interface PurgatoryNFTs {

    function balanceOf(address account) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function mintNFT(address sender) external returns(uint rarity, uint score);

    function mintCommonNFTsingle(address sender) external returns(uint score);

    function mintNFTlegend(address sender) external returns (uint rarity, uint score);

    function mintCommonNFT() external returns (uint[] memory scores);

    function mintNFTcreator(address sender, uint scoreX) external returns(uint rarity, uint score);

    function CurrentID() external view returns (uint);

    function setMint(uint price, uint amount) external;

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function setCommonList(address[] memory list) external returns (bool);

    function transferOwnership(address newOwner) external;
}

contract PurgatoryGames {

    address PurgatoryAddress = 0x2314Da466918c4358913b96bFf56b3e875B11FbF;
    address PurgatoryNFTsAddress = 0xbA0d3Be6E931E3AD9228fBBe60ca0BB9C0223d74;
    Purgatory public PGC = Purgatory(address(PurgatoryAddress));
    PurgatoryNFTs public PGNFT = PurgatoryNFTs(address(PurgatoryNFTsAddress));


    mapping (uint => GameOneStats) GambleOne;
    mapping (uint => Gamblestats) public Gamble;

    struct Gamblestats {
        address creator;
        address[] ticket;
        uint[] target;
        bool complete;
        uint stake;
        uint tickets;
        uint game;
        mapping (uint => address) winners;
    }

    struct GameOneStats {
        uint w1;
        uint w2;
        uint w3;
        uint w4;
        uint w5;
        uint g1;
        uint g2;
        uint g3;
        uint g4;
        uint g5;
    }

    function GameOne(uint gamenr) public {
        Gamblestats storage g = Gamble[gamenr];
        GameOneStats storage go = GambleOne[gamenr];
        (g.creator,g.complete,g.stake,g.tickets,g.game) = PGC.Gamble(gamenr);
        require(g.complete == false);
        require(g.game == 1);
        require(g.tickets >= 400);
        uint pool = g.stake * g.tickets;
        uint winners = (g.tickets/2)+1;
        go.w1 = winners*75/100;
        go.w2 = winners*17/100;
        go.w3 = winners*5/100;
        go.w4 = winners*25/1000;
        go.w5 = winners*5/1000;
        go.g1 = (pool*45/100)/go.w1;
        go.g2 = (pool*16/100)/go.w2;
        go.g3 = (pool*9/100)/go.w3;
        go.g4 = (pool*10/100)/go.w4;
        go.g5 = (pool*15/100)/go.w5;
        winners = go.w1+go.w2+go.w3+go.w4+go.w5;
        winnerTickets(gamenr, winners-1);
        transferwingameone(gamenr, winners);
        PGC.GameX(gamenr);
        PGC.addgamerounds();
        PGC.burn(pool/100);
        removegame(gamenr);
    }

    function winnerTickets(uint256 gamenr, uint256 winners) private {
        Gamblestats storage g = Gamble[gamenr];
        g.ticket = PGC.gameticket(gamenr);
        (g.creator,g.complete,g.stake,g.tickets,g.game) = PGC.Gamble(gamenr);
        uint256 i = 0;
        while (i < winners) {
            uint x = PGC.useRandom(i)%g.ticket.length;
            g.winners[i] = g.ticket[x];
            g.ticket[x] = g.ticket[g.ticket.length - 1];
            g.ticket.pop();
            i++;
        }
    }

    function transferwingameone(uint gamenr, uint winners) private {
        GameOneStats storage go = GambleOne[gamenr];
        Gamblestats storage g = Gamble[gamenr];
        (g.creator,g.complete,g.stake,g.tickets,g.game) = PGC.Gamble(gamenr);
        for (uint i = 0; i < winners; i++) {
            address winner = Gamble[gamenr].winners[i];
            if(i < go.w1) PGC.mint(winner, go.g1);
            else if(i < go.w1 + go.w2) PGC.mint(winner, go.g2);
            else if(i < go.w1 + go.w2 + go.w3) PGC.mint(winner, go.g3);
            else if(i < go.w1 + go.w2 + go.w3 + go.w4 -1) PGC.mint(winner, go.g4);
            else PGC.mint(winner, go.g5);
            PGC.SoultoNFTsOfOwner(g.stake, winner);
        }
        PGC.addSoulpool(go.g4);
    }

    function GameTwo(uint gamenr) public {
        Gamblestats storage g = Gamble[gamenr];
        g.target = PGC.gametarget(gamenr);
        (g.creator,g.complete,g.stake,g.tickets,g.game) = PGC.Gamble(gamenr);
        require(g.complete == false);
        require(g.game == 2);
        require(g.tickets >= g.target[0]);
        uint w = (PGC.useRandom(g.tickets)%g.target[0])+1;
        uint u = 0;
        for(uint i = 1; i <= g.tickets; i++) {
            if(g.target[i] == w) {
                g.winners[u] = g.ticket[i-1];
                u++;
            }
        }
        uint pool = ((g.stake * g.tickets)*95)/100;
        for (uint i = 0; i < u; i++) {
            PGC.mint(g.winners[i],pool/u+1);
            PGC.SoultoNFTsOfOwner(g.stake, g.winners[i]);
        }
        PGC.addSoulpool(pool/u+1);
        g.complete=true;
        PGC.addgamerounds();
        PGC.burn((g.stake * g.tickets)/100);
        PGC.GameX(gamenr);
        removegame(gamenr);
    }   

    function Soulette(uint gamenr) public returns(uint response) {
        Gamblestats storage g = Gamble[gamenr];
        (g.creator,g.complete,g.stake,g.tickets,g.game) = PGC.Gamble(gamenr);
        require(g.complete == false);
        require(g.game == 3);
        uint x = PGC.useRandom(PGC.showgamerounds())%6;
        uint y = PGC.useRandom(x)%6;
        bool win = false;
        response = 0;
        PGC.addtickets(gamenr);
        if(y==x) win = true;
        if(g.tickets == 1 && win == true) {
            uint u = PGNFT.balanceOf(msg.sender);
            if(u > 1) u = 1;
            for (uint i = 0; i < u; i++) {
                uint e = PGNFT.tokenOfOwnerByIndex(msg.sender,i);
                uint value = g.stake / PGC.SoulValue();
                PGC.addSoultoken(value, e);
            }
            uint pool = (g.stake*g.tickets)*95/100;
            PGC.mint(msg.sender, pool*90/100);
            PGC.addSoulpool(pool*10/100);
            PGC.burn((g.stake * g.tickets)/100);
            g.complete = true;
            PGC.GameX(gamenr);
            removegame(gamenr);
            response = 1;
        }
        else if(win == true) {
            uint pool = (g.stake*g.tickets)*95/100;
            PGC.mint(msg.sender, pool*90/100);
            PGC.addSoulpool(pool*10/100);
            PGC.burn((g.stake * g.tickets)/100);
            g.complete = true;
            PGC.GameX(gamenr);
            removegame(gamenr);
            response = pool*90/100;
        }
        PGC.SoultoNFTsOfOwner(g.stake, msg.sender);
        return (response);
    }

    function removegame(uint gamenr) private {
        Gamble[gamenr].complete = false;
        Gamble[gamenr].tickets = 0;
        delete Gamble[gamenr].ticket;
        delete Gamble[gamenr].target;
        Gamble[gamenr].stake = 0;
        Gamble[gamenr].game = 0;
    }

}