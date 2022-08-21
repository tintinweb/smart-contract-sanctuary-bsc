/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface TokenLike {
    function transfer(address,uint) external;
    function approve(address,uint) external;
    function balanceOf(address) external view returns (uint256);
}
interface RouterV2 {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
}
contract ExchequerCcoin {
        // --- Auth ---
    mapping (address => uint256) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "ExchequerCcoin/not-authorized");
        _;
    }

    TokenLike      public usdt = TokenLike(0x55d398326f99059fF775485246999027B3197955);
    TokenLike      public ccoin;
    uint256        public backAmount;
    uint256        public lpAmount;
    uint256        public lotteryAmount;
    uint256        public NftAmount;
    uint256        public operationAmount;
    address        public lpPoolAddress;
    address        public lotteryPoolAddress;
    address        public NftPoolAddress;
    address        public operationAddress = 0x7Eb943eBb6ac0d65439B1630774Facd7e6ff567A;
    address        public v2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

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
        if (what == 1) lpPoolAddress = _ust;
        if (what == 2) lotteryPoolAddress = _ust;
        if (what == 3) NftPoolAddress = _ust;
        if (what == 4) operationAddress = _ust;
        if (what == 5) ccoin = TokenLike(_ust);
    }

    function lpPool(address usr) public returns (uint256 wad){
        require(msg.sender == lpPoolAddress, "ExchequerCcoin/invalid-sender");
        wad = getlpPool();
        if (wad >0) {
            lpAmount = add(lpAmount,wad);
            ccoin.transfer(usr,wad); 
        }
    }

    function lotteryPool(address usr) public returns (uint256 wad){
        require(msg.sender == lotteryPoolAddress, "ExchequerCcoin/invalid-sender");
        wad = getlotteryPool();
        if (wad >0) {
            lotteryAmount = add(lotteryAmount,wad);
            ccoin.transfer(usr,wad);            
        }
    }

    function NftPool(address usr) public returns (uint256 wad){
        require(msg.sender == NftPoolAddress, "ExchequerCcoin/invalid-sender");
        wad = getNftPool();
        if (wad >0) {
            NftAmount = add(NftAmount,wad);
            ccoin.transfer(usr,wad); 
        }     
    }
    function operaPool(address usr) public returns (uint256 wad){
        require(msg.sender == operationAddress, "ExchequerCcoin/invalid-sender");
        wad = getOperaPool();
        if (wad >0) {
            operationAmount = add(operationAmount,wad);
            ccoin.transfer(usr,wad); 
        }     
    }

   //Enquire the Treasury's accumulated total revenue
    function getTotal() public  view returns (uint256 total){
        total = ccoin.balanceOf(address(this)) + backAmount + lpAmount + lotteryAmount + NftAmount + operationAmount;  
    }
 
    //Query the residual revenue of the LP pool
    function getlpPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*15/50,lpAmount);
    }

    //Query the residual revenue of the integral pool
    function getlotteryPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*10/50,lotteryAmount);
    }


    //Query Nft pool residual returns
    function getNftPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*10/50,NftAmount);    
    }
    function getOperaPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*10/50,operationAmount);    
    }
    function getbacklp() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*5/50,operationAmount);    
    }
    function init() public {
        ccoin.approve(v2Router, ~uint256(0));
        usdt.approve(v2Router, ~uint256(0));
    }

    function addlp() public {
        (uint256 amountA, , ) = RouterV2(v2Router).addLiquidity(
            address(ccoin),
            address(usdt),
            getbacklp(),
            usdt.balanceOf(address(this)),
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
        backAmount += amountA;
    }
    function withdraw(address asses, uint256 amount, address ust) public auth {
        TokenLike(asses).transfer(ust, amount);
    }
 }