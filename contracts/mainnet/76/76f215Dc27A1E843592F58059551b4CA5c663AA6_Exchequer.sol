/**
 *Submitted for verification at BscScan.com on 2022-03-12
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
    uint256        public lpAmount;
    uint256        public recommendAmount;
    uint256        public operationAmount;
    uint256        public fundAmount;
    address        public lpPoolAddress = 0xC1EF58027f3992247D72422dbCcf7cFDC69d97C3;
    address        public recommendPoolAddress = 0xAeAF211A9DF60Ba8D5BcFB27Cd826378CC3A61b0;
    address        public fundPoolAddress = 0xdFc3Ad5622c4B389B3A9B8CAb02A6f2037F761e3;
    constructor() {
        wards[msg.sender] = 1;
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }

     function setmother(address _mother) external {
         if ( mother == TokenLike(address(0)))
         mother = TokenLike(_mother);
    }

    function lpPool(address usr) public returns (uint256 wad){
        require(msg.sender == lpPoolAddress, "Exchequer/not-authorized");
        wad = getlpPool();
        if (wad >0) {
            lpAmount = add(lpAmount,wad);
            mother.transfer(usr,wad); 
        }
    }

    function recommendPool(address usr) public returns (uint256 wad){
        require(msg.sender == recommendPoolAddress, "Exchequer/not-authorized");
        wad = getrecommendPool();
        if (wad >0) {
            recommendAmount = add(recommendAmount,wad);
            mother.transfer(usr,wad);            
        }
    }

    function operationPool(address usr) public auth returns (uint256 wad){
        wad = getoperationPool();
        if (wad >0) {
            operationAmount = add(operationAmount,wad);
            mother.transfer(usr,wad);       
        }
    }

    function fundPool(address usr) public returns (uint256 wad){
        require(msg.sender == fundPoolAddress, "Exchequer/not-authorized");
        wad = getfundPool();
        if (wad >0) {
            fundAmount = add(fundAmount,wad);
            mother.transfer(usr,wad); 
        }     
    }

   //Enquire the Treasury's accumulated total revenue
    function getTotal() public  view returns (uint256 total){
        total = mother.balanceOf(address(this)) + lpAmount + recommendAmount + operationAmount + fundAmount;  
    }

    //Query the residual revenue of the LP pool
    function getlpPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*35/100,lpAmount);
    }

    //Query the residual revenue of the integral pool
    function getrecommendPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*35/100,recommendAmount);
    }

    //Query residual revenue of operating expenses
    function getoperationPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*10/100,operationAmount);
    }

    //Query fund pool residual returns
    function getfundPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*20/100,fundAmount);    
    }
 }