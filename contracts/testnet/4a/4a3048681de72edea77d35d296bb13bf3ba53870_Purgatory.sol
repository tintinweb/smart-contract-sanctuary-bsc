/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// File: contracts/purgatory.sol


pragma solidity ^0.8.17;

pragma solidity ^0.8.0;

library Counters {
    struct Counter {
        uint256 _value;
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transferExactDest(address _to, uint _value) external returns (bool success);

    function transferExactDestFrom(address _from, address _to, uint _value) external returns (bool success);

    function getReceivedAmount(uint _sentAmount) external view returns (uint receivedAmount, uint feeAmount);

    function getSendAmount(uint _receivedAmount) external view returns (uint sendAmount, uint feeAmount);

    function burn(uint256 amount) external;
}

pragma solidity ^0.8.0;

contract ERC20 is Context {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual{
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        _afterTokenTransfer(account, address(0), amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
   
}

interface LotteryNFTs {

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

contract Purgatory is Ownable, ERC20 {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    address LRTaddress = 0xbA0d3Be6E931E3AD9228fBBe60ca0BB9C0223d74;
    address RHTaddress = 0x2314Da466918c4358913b96bFf56b3e875B11FbF;
    IERC20 public RHT = IERC20(address(RHTaddress));
    LotteryNFTs public LRT = LotteryNFTs(address(LRTaddress));

    address[] private allplayers;
    address[] commonRecievers;
    uint[] private SupplyNFTs;

    mapping (address => bool) CotractsForNewGames;
    mapping (uint => Gamblestats) public Gamble;
    mapping (uint => NFT) public NFTs;

    bool MintPermission;
    
    uint gamerounds;
    uint RHTonAccountforClaim;
    uint MintAmount;
    uint public Soulpool;
    uint public Soulsupply;
    uint public MintPrice;
    uint public MintCommonPrice;
    uint public MintPriceToken;

    constructor() {
        allplayers.push(_msgSender());
        gamerounds = 0;
        RHTonAccountforClaim = 1000*1000000000000000000;
        Soulpool = 0;
    }

    struct NFT {
        uint Rarity;
        uint RHT;
        uint Score;
        uint Soultoken;
        uint date;
        uint SoulthisDate;
        uint usedToken;
    }

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

    function SetRHTonAccountforClaim(uint x) public onlyOwner {
        RHTonAccountforClaim = x;
    }

    function createGamble(uint stake, uint game, uint targets) public {
        Gamblestats storage g = Gamble[nextgame()];
        require(game != 0);
           g.complete = false;
           g.stake = stake;
           g.tickets = 0;   
           g.game = game;
           g.creator = _msgSender();
           if(game == 2) {
               require(targets > 1);
               g.target.push(targets);
           } else g.target.push(targets);
    }

    function random(uint x) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp + x, allplayers)));
    }

    function buyticket(uint gamenr, uint amount, uint target) public {
        addPlayer();
        Gamblestats storage g = Gamble[gamenr];
        require(g.game != 0);
        require(g.complete == false);
        require(balanceOf(_msgSender()) >= g.stake*amount);
        g.tickets += amount; 
        for (uint i = 0; i < amount; i++) {
            g.ticket.push(_msgSender());
            g.target.push(target);
        }  
        _burn(_msgSender(), g.stake*amount);
    }

    function showTicket(uint gamenr) public view returns(address[] memory){
        Gamblestats storage g = Gamble[gamenr];
        return g.ticket;
    }

    function payloadaccount(uint amount) public {
        uint256 allowance = RHT.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        bool sent = RHT.transferExactDestFrom(msg.sender, address(this), amount);
        require(sent, "Token transfer failed");
        _mint(_msgSender(), amount);
    }

    function cashout(uint amount) public {
        require(balanceOf(msg.sender) >= amount, "Check the token allowance");
        _burn(msg.sender, amount);
        _cashOut(msg.sender, amount);
    }

    function _cashOut(
        address to,
        uint amount
    ) private {
        bool sent = RHT.transfer(to, amount);
        require(sent, "Token transfer failed");
    }

    function addPlayer() private {
        address player = _msgSender();
        bool inlist = false;
        for (uint i = 0; i < allplayers.length; i++) {
            if(player == allplayers[i]) inlist = true;
        }
        if(inlist == false) allplayers.push(_msgSender());
    }

    

    function balanceInPool() public view returns (uint) {
        return RHT.balanceOf(address(this));
    }

    function winpool() public view returns(uint) {
        uint i = balanceInPool() - totalSupply() - RHTinNFTunclaimed() - RHTinGames() - Soulpool; 
        return i;
    }

    function RHTinGames() private view returns(uint) {
        uint rht = 0;
        uint nr = 0;
        for (uint i = 0; i < gamelist.length; i++) {
            nr = gamelist[i];
            if(Gamble[nr].complete == false) rht += Gamble[i].tickets*Gamble[i].stake;
        }
        return rht;
    }

    function winnerNFTs() private view returns (uint[] memory wNFTs){
        uint[] memory allNFTs = SupplyNFTs;
        uint winners = allNFTs.length/10;
        wNFTs = new uint[](winners); 
        uint256 i = 0;
        while (i < winners) {
            uint x = random(i)%(allNFTs.length - i);
            wNFTs[i] = x;
            allNFTs[x] = allNFTs[allNFTs.length - 1];
            i++;
        }
        return wNFTs;
    }

    function splitPoolToNFTs() public {
        uint pool = winpool() / gamerounds;
        while (gamerounds > 0) {
            uint score = 0;
            uint[] memory winners = winnerNFTs();
            for (uint i = 0; i < winners.length; i++) {
                score += NFTs[winners[i]].Score;
            }
             for (uint i = 0; i < winners.length; i++) {
                NFTs[winners[i]].RHT += (pool/score)*NFTs[winners[i]].Score;
            }
        }
    }

    function RHTinNFTunclaimed() private view returns (uint) {
        uint x = 0;
        for (uint i = 0; i < SupplyNFTs.length; i++) {
            x += NFTs[i].RHT;
        }
        return x;
    }

    function claimNFTs() public {
        require(RHT.balanceOf(_msgSender()) >= RHTonAccountforClaim);
        uint x = LRT.balanceOf(_msgSender());
        for (uint i = 0; i < x; i++) {
            uint e = LRT.tokenOfOwnerByIndex(_msgSender(),i);
            if(NFTs[e].Rarity > 1) {
                _mint(_msgSender(), NFTs[e].RHT);
                NFTs[e].RHT = 0;
            } 
        }
    }

    function claimNFTsSoulToken() public { //----------------------------------------------------------------------------- vll noch funktion für einzeln anwählbar
        uint x = LRT.balanceOf(_msgSender());
        for (uint i = 0; i < x; i++) {
            uint e = LRT.tokenOfOwnerByIndex(_msgSender(),i);
            if(NFTs[e].Soultoken > 0) {
                uint value = NFTs[e].Soultoken*SoulValue();
                _mint(_msgSender(), value);
                if(NFTs[e].Rarity < 4) Soulsupply -= NFTs[e].Soultoken;
                NFTs[e].Soultoken = 0;
                Soulpool -= value;
            } 
        }
    }

    function claimCommonNFTs() public {
        uint x = LRT.balanceOf(_msgSender());
        for (uint i = 0; i < x; i++) {
            uint e = LRT.tokenOfOwnerByIndex(_msgSender(),i);
            if(NFTs[e].Rarity == 1) {
                _mint(_msgSender(), NFTs[e].RHT);
                NFTs[e].RHT = 0;
                SupplyNFTs[e] = SupplyNFTs[SupplyNFTs.length - 1];
                SupplyNFTs.pop();
            } 
        }
    }

    function mintNFT() public {
        require(MintPermission == true);
        require(MintAmount > 0);
        require(balanceOf(_msgSender()) >= MintPrice);
        (uint rarity, uint score) = LRT.mintNFT(_msgSender());    
        NFTs[SupplyNFTs.length].Rarity = rarity;
        NFTs[SupplyNFTs.length].Score = score;
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        SupplyNFTs.push(tokenId);
        MintAmount--;
        _burn(msg.sender, MintPrice);
        _mint(owner(), (MintPrice*15/100));
        Soulsupply += 1000;
        Soulpool += MintPrice-(MintPrice*15/100);
    }

    function mintNFTwithSoulstone(uint nft) public { // ------------------------------------ mint prozente an uns.
        require(MintPermission == true);
        require(balanceOf(_msgSender()) >= MintPrice);
        require(NFTs[nft].Soultoken >= MintPriceToken);
        require(LRT.ownerOf(nft) == _msgSender());
        (uint rarity, uint score) = LRT.mintNFT(_msgSender());    
        NFTs[SupplyNFTs.length].Rarity = rarity;
        NFTs[SupplyNFTs.length].Score = score;
        NFTs[nft].Soultoken -= MintPriceToken;
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        SupplyNFTs.push(tokenId);
        _burn(msg.sender, MintPrice);
        _mint(owner(), (MintPrice*15/100));
        if(NFTs[nft].Rarity < 4){
            Soulsupply += 1000 - MintPriceToken;
        } else Soulsupply += 1000;
        Soulpool += MintPrice-(MintPrice*15/100);
    }

    function mintNFTlegend() public onlyOwner {
        (uint rarity, uint score) = LRT.mintNFTlegend(owner());   
        NFTs[SupplyNFTs.length].Rarity = rarity;
        NFTs[SupplyNFTs.length].Score = score;
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        SupplyNFTs.push(tokenId);
        Soulsupply += 1000;
    }

    function mintNFTcreator(address sender, uint scoreX) public onlyOwner {
        (uint rarity, uint score) = LRT.mintNFTcreator(sender, scoreX);   
        NFTs[SupplyNFTs.length].Rarity = rarity;
        NFTs[SupplyNFTs.length].Score = score;
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        SupplyNFTs.push(tokenId);
    }

    function mintCommonNFT() public onlyOwner {
        uint[] memory scores = LRT.mintCommonNFT();
        for (uint i = 0; i < scores.length; i++) {
            NFTs[SupplyNFTs.length].Rarity = 1;
            NFTs[SupplyNFTs.length].Score = scores[i];
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            SupplyNFTs.push(tokenId);
        }
    }

    function mintCommonNFTsingle() public {
        require(MintPermission == true);
        require(balanceOf(_msgSender()) >= MintCommonPrice);
        uint score = LRT.mintCommonNFTsingle(_msgSender());    
        uint value = ((MintCommonPrice * 80) / 100) * SoulValue(); 
        NFTs[SupplyNFTs.length].Rarity = 1;
        NFTs[SupplyNFTs.length].Score = score;
        NFTs[SupplyNFTs.length].Soultoken = value;
        Soulsupply += value;
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        SupplyNFTs.push(tokenId);
        MintAmount--;
        _burn(msg.sender, MintCommonPrice);
        _mint(owner(), (MintCommonPrice*10/100));
        RHT.burn(MintCommonPrice*10/100);
        Soulsupply += 1000;
        Soulpool += MintCommonPrice-(MintCommonPrice*20/100);
    }

    function setMint(uint price, uint amount, uint token, bool permission) public onlyOwner {
        MintAmount = amount;
        MintPrice = price;
        MintCommonPrice = price/10;
        MintPriceToken = token;
        MintPermission = permission;
    }

    

    function buyticketfromNFT(uint gamenr, uint amount, uint target, uint ID) public {
        addPlayer();
        Gamblestats storage g = Gamble[gamenr];
        require(g.game != 0);
        require(g.complete == false);
        require(LRT.ownerOf(ID) == _msgSender());
        require(NFTs[ID].RHT >= g.stake*amount);
        g.tickets += amount; 
        for (uint i = 0; i < amount; i++) {
            g.ticket.push(_msgSender());
            if(g.game == 2) {
            require(target != 0 && target <= g.target[0]);
            g.target.push(target);
            } else {
                g.target.push(target);
            }
        }  
        NFTs[ID].RHT -= g.stake*amount;
    }

    function SoulValue() public view returns(uint) {
        uint x = Soulpool/Soulsupply;
        return x;
    }

    function SoultoNFTsOfOwner(uint stake, address owner) external haveRights {
        uint x = LRT.balanceOf(owner);
        for (uint i = 0; i < x; i++) {
            uint e = LRT.tokenOfOwnerByIndex(_msgSender(),i);
            if(NFTs[e].Rarity > 1) {
                giveSoultoNFT(e, stake);
            } 
        }
    }

    function giveSoultoNFT(uint nft, uint stake) private {
        require(NFTs[nft].date >= block.timestamp - 21*60*60);
        require(NFTs[nft].usedToken < 1000);
        uint x = 0;
        if(stake >= 35*1000000000000000000) x = 70;
        else if(stake >= 30*1000000000000000000) x = 60;
        else if(stake >= 25*1000000000000000000) x = 50;
        else if(stake >= 20*1000000000000000000) x = 40; 
        else if(stake >= 15*1000000000000000000) x = 30;
        else if(stake >= 10*1000000000000000000) x = 20;
        else if(stake >= 5*1000000000000000000) x = 10;
        else x = 0;
        x = 70 - NFTs[nft].SoulthisDate;
        if(NFTs[nft].Rarity < 4 && x > (1000 - NFTs[nft].usedToken)) x = 1000 - NFTs[nft].usedToken;
        NFTs[nft].SoulthisDate += x;
        NFTs[nft].Soultoken += x;
        NFTs[nft].usedToken += x;
        if(NFTs[nft].SoulthisDate == 70) {
            NFTs[nft].date = block.timestamp;
            NFTs[nft].SoulthisDate = 0;
        }
    }

    function setCommonList(address[] memory list) public onlyOwner {
        bool success = LRT.setCommonList(list);
        require(success);
    }

    function market() public { //-----------------------------------------------------------------------------------???-

    }
    
    function mint(address account, uint amount) public haveRights returns(bool) {
        _mint(account, amount);
        return true;
    }

    function burn(uint amount) public haveRights returns(bool) {
        RHT.burn(amount);
        return true;
    }

    function addSoulpool(uint x) public haveRights returns(bool) {
        Soulpool += x;
        return true;
    }

    function addSoultoken(uint value, uint e) public haveRights returns(bool) {
        NFTs[e].Soultoken += value;
        return true;
    }
    
    function useRandom(uint x) public view haveRights returns(uint) {
        uint y = random(x);
        return y;
    }

    function GameX(uint gamenr) public haveRights {
        require(Gamble[gamenr].complete == false);
        Gamble[gamenr].complete = true;
        removegame(gamenr);
    }

    function addGameRights(address newContract, bool x) public onlyOwner {
        CotractsForNewGames[newContract] = x;
    }

    function inRightList() private view {
        require(CotractsForNewGames[_msgSender()] == true);
    }

    modifier haveRights {
        inRightList();
        _;
    }

    function countRaritys() public view returns(uint r1, uint r2, uint r3, uint r4) {
        r1=0;
        r2=0;
        r3=0;
        r4=0;
        for (uint i = 0; i < SupplyNFTs.length; i++) {
            if(NFTs[i].Rarity == 1) r1++;
            else if(NFTs[i].Rarity == 2) r2++;
            else if(NFTs[i].Rarity == 3) r3++;
            else if(NFTs[i].Rarity == 4) r4++;
        }
        return (r1, r2, r3, r4);
    }

    function transferOwnershipNFTcontract(address newOwner) public onlyOwner {
        LRT.transferOwnership(newOwner);
    }

    function resetGame(uint gamenr) public {
        Gamblestats storage g = Gamble[gamenr];
        require(owner() == _msgSender());
        require(g.complete == false);
        for (uint i = 0; i < g.tickets; i++) {
            _mint(g.ticket[i],g.stake);
        }
        g.complete = true;
        removegame(gamenr);
    }

    uint[] nextgamelist;
    uint[] public gamelist;

    function nextgame() private returns(uint gamenr) {
        if(nextgamelist.length > 0) 
        {
            gamenr = nextgamelist[0];
            nextgamelist[0] = nextgamelist[nextgamelist.length - 1];
            nextgamelist.pop();
        } else gamenr = gamelist.length;
        gamelist.push(gamenr);
        return gamenr;
    }

    function removegame(uint gamenr) private {
        uint game;
        for (uint i = 0; i < gamelist.length; i++) {
            if(gamelist[i] == gamenr) game = i;
        }
        gamelist[game] = gamelist[gamelist.length - 1];
        gamelist.pop();
        nextgamelist.push(game);
        Gamble[gamenr].complete = false;
        Gamble[gamenr].tickets = 0;
        delete Gamble[gamenr].ticket;
        delete Gamble[gamenr].target;
        Gamble[gamenr].stake = 0;
        Gamble[gamenr].game = 0;
    }

    function gamelistlength() public view returns(uint) {
        return gamelist.length;
    }

    function gamestatsstake(uint x) public view returns(uint stake){
        return Gamble[x].stake;
    }

    function gamestatstickets(uint x) public view returns(uint tickets){
        return Gamble[x].tickets;
    }

    function gamestatsgame(uint x) public view returns(uint game){
        return Gamble[x].game;
    }

    function gameticket(uint x) public view returns(address[] memory ticket){
        return Gamble[x].ticket;
    }

    function gametarget(uint x) public view returns(uint[] memory ticket){
        return Gamble[x].target;
    }

    function gametarget0(uint x) public view returns(uint ticket){
        return Gamble[x].target[0];
    }

    function addgamerounds() public haveRights {
        gamerounds++;
    }

    function showgamerounds() public view haveRights returns(uint) {
        return gamerounds;
    }

    function addtickets(uint gamenr) public haveRights {
        Gamble[gamenr].tickets ++;
    }
}