/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface TokenLike {
    function transfer(address,uint) external;
    function balanceOf(address) external view returns (uint256);
}
contract Exchequer {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Exchequer/not-authorized");
        _;
    }
    TokenLike      public mother;
    uint256        public dorAmount;
    uint256        public supAmount;
    uint256        public nftAmount;
    uint256        public dorscale = 500;
    uint256        public supscale;
    uint256        public nftscale = 500;
    address        public dorPoolAddress;
    address        public supPoolAddress;
    address        public nftPoolAddress = 0x6C38DA460c9891c592bbF03a5F3358462Ee71b0a;
    constructor() {
        wards[msg.sender] = 1;
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }

    function setAddress(uint what,address ust) external auth{
         if(what ==1) mother = TokenLike(ust);
         if(what ==2) dorPoolAddress = ust;
         if(what ==3) supPoolAddress = ust;
         if(what ==4) nftPoolAddress = ust;
    }
    function setScale(uint what,uint data) external auth{
         if(what ==1) dorscale = data;
         if(what ==2) supscale = data;
         if(what ==3) nftscale = data;
    }

    function dorPool() public returns (uint256 wad){
        wad = getdorPool();
        if (wad >0) {
            dorAmount = add(dorAmount,wad);
            mother.transfer(dorPoolAddress,wad); 
        }
    }

    function supPool(address usr) public returns (uint256 wad){
        require(msg.sender == supPoolAddress, "Exchequer/not-authorized");
        wad = getsupPool();
        if (wad >0) {
            supAmount = add(supAmount,wad);
            mother.transfer(usr,wad);            
        }
    }

    function nftPool(address usr) public returns (uint256 wad){
        require(msg.sender == nftPoolAddress, "Exchequer/not-authorized");
        wad = getnftPool();
        if (wad >0) {
            nftAmount = add(nftAmount,wad);
            mother.transfer(usr,wad); 
        }
        dorPool();     
    }

   //Enquire the Treasury's accumulated total revenue
    function getTotal() public  view returns (uint256 total){
        total = mother.balanceOf(address(this)) + dorAmount + supAmount + nftAmount;  
    }

    //Query the residual revenue of the dor pool
    function getdorPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*dorscale/1000,dorAmount);
    }

    //Query the residual revenue of the integral pool
    function getsupPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*supscale/1000,supAmount);
    }

    //Query nft pool residual returns
    function getnftPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*nftscale/1000,nftAmount);    
    }
 }