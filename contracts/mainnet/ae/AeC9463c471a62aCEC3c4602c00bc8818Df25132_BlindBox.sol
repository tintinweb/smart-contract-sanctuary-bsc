/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external; 
    function mint(address,uint256) external returns(uint256); 
    function balanceOf(address) external view returns(uint256);
}
interface InviterLike {
    function inviter(address) external view returns (address);
    function setLevel(address, address) external;
}
interface RandomLike {
    function getrandomNumber() external view returns(uint256);
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}
contract BlindBox {
    using Address for address;
    // --- Auth ---
    uint256 public live = 1;
    mapping (address => uint) public wards;
    function rely(address usr) external  auth {wards[usr] = 1; }
    function deny(address usr) external  auth {wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "BlindBox/not-authorized");
        _;
    }

    TokenLike        public usdt = TokenLike(0x55d398326f99059fF775485246999027B3197955);
    TokenLike        public elv = TokenLike(0x1AB914574F86A350EE66abD14708B39aBFF00D3E);
    TokenLike        public elvNft = TokenLike(0xE2bF2C7ae28B399aE272A69E893993B86206C144);
    InviterLike      public elvInviter = InviterLike(0x69BBaa77604711C3Cb169Bf998ad1407885007E0);
    RandomLike       public randomContract;
    address         public owner = 0x698f7C4bBb5198eC28B3a965B11b1A8499E6a19d;
    bool             public random;
    mapping (address => uint256) public vip;
    mapping (address => uint256) public total;
    mapping (address => uint256) public recommenderNumber;
    mapping (address => uint256) public recommenderMint;
    mapping (address => mapping (uint256 => uint256[2])) public record;
    mapping (address => mapping (address => bool)) public marking;

    

         
    event OpenBlind( address  indexed  owner,
                    uint256           category,
                    uint256           luckily
                 );

    constructor(){
        wards[msg.sender] = 1;
    }
        // --- Math ---
    function add(uint x, int y) internal pure returns (uint z) {
        z = x + uint(y);
        require(y >= 0 || z <= x);
        require(y <= 0 || z >= x);
    }
    function sub(uint x, int y) internal pure returns (uint z) {
        z = x - uint(y);
        require(y <= 0 || z <= x);
        require(y >= 0 || z >= x);
    }
    function mul(uint x, int y) internal pure returns (int z) {
        z = int(x) * y;
        require(int(x) >= 0);
        require(y == 0 || z / y == int(x));
    }
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    
        return c;
      }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }

	function setVariable(uint256 what, address ust) external auth{
        if (what == 1) elv = TokenLike(ust);
        if (what == 2) elvInviter = InviterLike(ust);
        if (what == 3) elvNft = TokenLike(ust);
        if (what == 4) randomContract = RandomLike(ust);
        if (what == 5) usdt = TokenLike(ust);
        if (what == 6) owner = ust;
	}

    function setVip(address usr, uint8 _vip) public auth{
        vip[usr] = _vip;
    }
    function setLive(uint8 _live) public auth{
        live = _live;
    }
    function setRandom() public auth{
        random = !random;
    }
    function getRandom(address sender) public view returns (uint){
        if (random) return randomContract.getrandomNumber();
        bytes32 hash = keccak256(abi.encodePacked(sender, blockhash(block.number-1), total[sender]));
        uint256 luckily = uint256(hash)%100;  
        return luckily;
    }
    function _openblind(uint256 wad,uint256 luckily) internal {
        total[msg.sender] +=1;
        record[msg.sender][total[msg.sender]] = [wad,luckily];
        address recommender = elvInviter.inviter(msg.sender);
        if (recommender != address(0) && vip[recommender] >=1 && !recommender.isContract()) {
            usdt.transfer(recommender,wad*9/100);
            if (!marking[recommender][msg.sender]) {
                marking[recommender][msg.sender] = true;
                recommenderNumber[recommender] +=1;
            }
            if (recommenderNumber[recommender] >=10 && recommenderMint[recommender] == 0) {
                recommenderMint[recommender] = elvNft.mint(recommender,0);
            }
        }
        address recommender1 = elvInviter.inviter(recommender);
        if (recommender1 != address(0) && vip[recommender1] >=2 && !recommender1.isContract()) usdt.transfer(recommender1,wad*7/100);
        address recommender2 = elvInviter.inviter(recommender1);
        if (recommender2 != address(0) && vip[recommender2] >=3 && !recommender2.isContract()) usdt.transfer(recommender2,wad*4/100);
        uint256 amount = usdt.balanceOf(address(this));
        usdt.transfer(owner, amount);
        emit OpenBlind(msg.sender,wad,luckily);
    }
    function openblindOne() public {
        require(live == 1 , "BlindBox/stop");
        usdt.transferFrom(msg.sender, address(this), 28*1E18);
        uint256 luckily = getRandom(msg.sender);
        elv.transfer(msg.sender,28*1E22);
        _openblind(28*1E18,luckily);
         
    }
    function openblindTwo() public {
        require(live == 1 , "BlindBox/stop");
        usdt.transferFrom(msg.sender, address(this), 98*1E18);
        uint256 luckily = getRandom(msg.sender);
        elv.transfer(msg.sender,98*1E22);
        if(vip[msg.sender] < 1) vip[msg.sender] = 1;
        _openblind(98*1E18,luckily);
    }
    function openblindThree() public {
        require(live == 1 , "BlindBox/stop");
        usdt.transferFrom(msg.sender, address(this), 298*1E18);
        uint256 luckily = getRandom(msg.sender);
        elv.transfer(msg.sender,298*1E22);
        if(vip[msg.sender] < 2) vip[msg.sender] = 2;
        _openblind(298*1E18,luckily);
    }
    function openblindFour() public {
        require(live == 1 , "BlindBox/stop");
        usdt.transferFrom(msg.sender, address(this), 598*1E18);
        uint256 luckily = getRandom(msg.sender);
        elv.transfer(msg.sender,598*1E22);
        if(vip[msg.sender] < 3) vip[msg.sender] = 3;
        _openblind(598*1E18,luckily);
    }

    function withdraw(address asses, uint256 amount, address ust) public auth {
        TokenLike(asses).transfer(ust, amount);
    }

    function getOwnerOpen(address usr) public view returns (uint[2][] memory){
        uint n = total[usr];
        uint[2][] memory openRecord = new uint[2][](n);
        for(uint i = 0; i< n; ++i) {
            openRecord[i] = record[usr][i+1];
        }
        return openRecord;
    }
    function getAmount(address usr) public view returns (uint256){
        uint n = total[usr];
        uint totalUsdt;
        for(uint i = 0; i< n; ++i) {
            uint256 wad = record[usr][i+1][0];
            totalUsdt += wad;
        }
        return totalUsdt;
    }
    function getOwnerOrder(address usr,uint256 order) public view returns (uint[2] memory){
        return record[usr][order];
    }
 }