/**
 *Submitted for verification at BscScan.com on 2022-08-21
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
        require(wards[msg.sender] == 1, "Exchequer/not-authorized");
        _;
    }

    TokenLike      public USDT = TokenLike(0x55d398326f99059fF775485246999027B3197955);
    TokenLike      public csa;
    uint256        public dividendsAmount;
    uint256        public lpAmount;
    uint256        public lotteryAmount;
    uint256        public ccoinAmount;
    uint256        public NftAmount;
    uint256        public operationAmount;
    address        public lpPoolAddress = 0x8E66A55f6437916E09349293c6d281565C787538;
    address        public lotteryPoolAddress = 0x7E077472D68051BceB8E757f15c6cF94Ec6Bed33;
    address        public NftPoolAddress = 0x7Eb943eBb6ac0d65439B1630774Facd7e6ff567A;
    address        public ccoinPoolAddress = 0xcc0F5a4035DB6ADfb7d5F15D5d85CfC8411D1091;
    address        public operationAddress = 0x263df962a83b5bbECBfA549Fe444F284a86f3bC5;

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
        if (what == 1) csa = TokenLike(_ust);
        if (what == 2) lpPoolAddress = _ust;
        if (what == 3) lotteryPoolAddress = _ust;
        if (what == 4) NftPoolAddress = _ust;
        if (what == 5) ccoinPoolAddress = _ust;
        if (what == 6) operationAddress = _ust;
    }
    function dividendsPool(address usr) public returns (uint256 wad){
        require(msg.sender == address(csa), "Exchequer/invalid-sender");
        wad = getDividendsPool();
        if (wad >0) {
            dividendsAmount = add(dividendsAmount,wad);
            USDT.transfer(usr,wad); 
        }
    }
    function lpPool(address usr) public returns (uint256 wad){
        require(msg.sender == lpPoolAddress, "Exchequer/invalid-sender");
        wad = getlpPool();
        if (wad >0) {
            lpAmount = add(lpAmount,wad);
            csa.transfer(usr,wad); 
        }
    }

    function lotteryPool(address usr) public returns (uint256 wad){
        require(msg.sender == lotteryPoolAddress, "Exchequer/invalid-sender");
        wad = getlotteryPool();
        if (wad >0) {
            lotteryAmount = add(lotteryAmount,wad);
            csa.transfer(usr,wad);            
        }
    }

     function ccoinPool(address usr) public returns (uint256 wad){
        require(msg.sender == ccoinPoolAddress, "Exchequer/invalid-sender");
        wad = getccoinPool();
        if (wad >0) {
            ccoinAmount = add(ccoinAmount,wad);
            USDT.transfer(usr,wad); 
        }     
    }
    function NftPool(address usr) public returns (uint256 wad){
        require(msg.sender == NftPoolAddress, "Exchequer/invalid-sender");
        wad = getNftPool();
        if (wad >0) {
            NftAmount = add(NftAmount,wad);
            csa.transfer(usr,wad); 
        }     
    }
    function operaPool(address usr) public returns (uint256 wad){
        require(msg.sender == operationAddress, "Exchequer/invalid-sender");
        wad = getOperaPool();
        if (wad >0) {
            operationAmount = add(operationAmount,wad);
            csa.transfer(usr,wad); 
        }     
    }

   //Enquire the Treasury's accumulated total revenue
    function getTotal() public  view returns (uint256 total){
        total = csa.balanceOf(address(this)) + lpAmount + lotteryAmount + NftAmount + operationAmount;  
    }
    function getTotalForU() public  view returns (uint256 total){
        total = USDT.balanceOf(address(this)) + dividendsAmount + ccoinAmount;  
    }
    //Query the residual revenue of the LP pool
    function getDividendsPool() public view returns (uint256 wad){
        uint256 total = getTotalForU();
        wad = sub(total*5/20,dividendsAmount);
    }

    //Query the residual revenue of the LP pool
    function getlpPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*5/40,lpAmount);
    }

    //Query the residual revenue of the integral pool
    function getlotteryPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*20/40,lotteryAmount);
    }

    //Query residual revenue of operating expenses
    function getccoinPool() public view returns (uint256 wad){
        uint256 total = getTotalForU();
        wad = sub(total*15/20,ccoinAmount);
    }

    //Query Nft pool residual returns
    function getNftPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*10/40,NftAmount);    
    }

    function getOperaPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*5/40,operationAmount);    
    }
    function withdraw(address asses, uint256 amount, address ust) public auth {
        TokenLike(asses).transfer(ust, amount);
    }
 }