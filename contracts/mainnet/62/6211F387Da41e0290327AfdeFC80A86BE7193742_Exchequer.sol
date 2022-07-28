/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface TokenLike {
    function transfer(address,uint) external;
    function balanceOf(address) external view returns (uint256);
}
contract Exchequer {
        // --- Auth ---
    mapping (address => uint256) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Donate/not-authorized");
        _;
    }

    TokenLike      public USDT = TokenLike(0x55d398326f99059fF775485246999027B3197955);
    uint256        public dividendsAmount;
    uint256        public lpAmount;
    uint256        public lotteryAmount;
    uint256        public ccoinAmount;
    uint256        public NftAmount;
    uint256        public operationAmount;
    address        public dividendsAddress;
    address        public lpPoolAddress = 0xEd3b0b298f3dE533d9BE9DC8D214e31Ed2A90704;
    address        public lotteryPoolAddress = 0x76c7133e59547FD398019e6442CEBeE1321546Ae;
    address        public NftPoolAddress = 0xCe6823cF3FBe9D25d59B6B84Fa80578Aa8df7625;
    address        public ccoinPoolAddress = 0x28A47379F29267Fbc2Bbd853FD59152dB9c6EFaA;
    address        public operationAddress = 0x28A47379F29267Fbc2Bbd853FD59152dB9c6EFaA;

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    constructor() {
        wards[msg.sender] = 1;
    }

    function setAddress(uint256 what, address _ust) public auth {
        if (what == 1) dividendsAddress = _ust;
        if (what == 2) lpPoolAddress = _ust;
        if (what == 3) lotteryPoolAddress = _ust;
        if (what == 4) NftPoolAddress = _ust;
        if (what == 5) ccoinPoolAddress = _ust;
        if (what == 6) operationAddress = _ust;
    }
    function dividendsPool(address usr) public returns (uint256 wad){
        require(msg.sender == dividendsAddress, "Exchequer/not-authorized");
        wad = getDividendsPool();
        if (wad >0) {
            dividendsAmount = add(dividendsAmount,wad);
            USDT.transfer(usr,wad); 
        }
    }
    function lpPool(address usr) public returns (uint256 wad){
        require(msg.sender == lpPoolAddress, "Exchequer/not-authorized");
        wad = getlpPool();
        if (wad >0) {
            lpAmount = add(lpAmount,wad);
            USDT.transfer(usr,wad); 
        }
    }

    function lotteryPool(address usr) public returns (uint256 wad){
        require(msg.sender == lotteryPoolAddress, "Exchequer/not-authorized");
        wad = getlotteryPool();
        if (wad >0) {
            lotteryAmount = add(lotteryAmount,wad);
            USDT.transfer(usr,wad);            
        }
    }

     function ccoinPool(address usr) public returns (uint256 wad){
        require(msg.sender == ccoinPoolAddress, "Exchequer/not-authorized");
        wad = getccoinPool();
        if (wad >0) {
            ccoinAmount = add(ccoinAmount,wad);
            USDT.transfer(usr,wad); 
        }     
    }
    function NftPool(address usr) public returns (uint256 wad){
        require(msg.sender == NftPoolAddress, "Exchequer/not-authorized");
        wad = getNftPool();
        if (wad >0) {
            NftAmount = add(NftAmount,wad);
            USDT.transfer(usr,wad); 
        }     
    }
    function operaPool(address usr) public returns (uint256 wad){
        require(msg.sender == operationAddress, "Exchequer/not-authorized");
        wad = getOperaPool();
        if (wad >0) {
            operationAmount = add(operationAmount,wad);
            USDT.transfer(usr,wad); 
        }     
    }

   //Enquire the Treasury's accumulated total revenue
    function getTotal() public  view returns (uint256 total){
        total = USDT.balanceOf(address(this)) + dividendsAmount + lpAmount + lotteryAmount + ccoinAmount + NftAmount + operationAmount;  
    }
    //Query the residual revenue of the LP pool
    function getDividendsPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*1/8,dividendsAmount);
    }

    //Query the residual revenue of the LP pool
    function getlpPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*1/8,lpAmount);
    }

    //Query the residual revenue of the integral pool
    function getlotteryPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*2/8,lotteryAmount);
    }

    //Query residual revenue of operating expenses
    function getccoinPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*2/8,ccoinAmount);
    }

    //Query Nft pool residual returns
    function getNftPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*1/8,NftAmount);    
    }
    function getOperaPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*1/8,operationAmount);    
    }
 }