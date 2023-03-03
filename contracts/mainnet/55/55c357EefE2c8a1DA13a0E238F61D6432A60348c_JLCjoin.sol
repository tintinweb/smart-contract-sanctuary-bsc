/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface Token{
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function approve(address,uint) external;
    function balanceOf(address) external view returns(uint);
}
interface IUniswapV2Router{
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract JLCjoin  {

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "JLCrank/not-authorized");
        _;
    }
    uint256[5]                                        public  quotedPrice = [140*1E18,17*1E18,25*1E18,11,1E17];
    uint256                                           public  fundAmount;
    uint256                                           public  swapTokensAtAmount = 100*1E18;
    address                                           public  exchequer = 0x96Ab5580E8e345fAb2611Ee6315f296d13BBE1C0;
    address                                           public  funder = 0x73a2d0a5B43a13e83d69FBFCB6f36C548317B811;
    Token                                             public  JLC = Token(0xCbc24F8a3f8526871a26Dc27A5372368c7b21dE2);
    Token                                             public  usdt = Token(0xE85131c9530A2Fc55D3587F914Ba6c1415f7EF86);
    address                                           public  uniswapV2Router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    mapping (address => bool)                         public  white;
    mapping (address => UserInfo)                     public  userInfo;

    struct UserInfo { 
        address    recommend;
        address    topBoss;
        address    wealth;
        address[]  under;
        uint256    orders;
        uint256    buyAmount;
        uint256    extract;
        uint256    amount;
        uint256    site;
    }
    constructor() {
        wards[msg.sender] = 1;
    }
    function global(uint256 what, uint data,address usr) external auth {
        if (what == 1) quotedPrice[0] = data;                           
        else if (what == 2) quotedPrice[1] = data;           
        else if (what == 3) quotedPrice[2] = data;                      
        else if (what == 4) quotedPrice[3] = data;
        else if (what == 5) quotedPrice[4] = data;
        else if (what == 6) swapTokensAtAmount = data;           
        else if (what == 7) exchequer = usr;                      
        else if (what == 8) funder = usr;
        else if (what == 9) white[usr] = !white[usr];
        else revert("JLCrank/setdata-unrecognized-param");
    }
    function setBoss(address boss,address ust) external auth {
        userInfo[boss].topBoss = boss;
        userInfo[boss].recommend = ust;
        userInfo[boss].wealth = ust;
    }
    function deposit(address recommender) public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.topBoss != msg.sender ,"JLCrank/1");
        uint256 wad = user.amount;
        if(wad < quotedPrice[0]) {
            usdt.transferFrom(msg.sender, address(this), quotedPrice[0] - wad);
            user.amount = 0;
        }
        else user.amount -=quotedPrice[0];
        userInfo[funder].amount += quotedPrice[1];
        fundAmount += quotedPrice[2];
        if(user.recommend != address(0)) recommender = user.recommend;
        UserInfo storage up = userInfo[recommender];
        if(user.recommend == address(0)){
           require(up.topBoss !=address(0) ,"JLCrank/2");
           user.recommend = recommender;
           up.under.push(msg.sender);
           user.topBoss = up.topBoss;
           user.site = up.under.length;
        }
        user.buyAmount += quotedPrice[0];
        up.orders +=1;
        if(up.orders%3 == 0) {
            fundAmount -= quotedPrice[2];
            uint256 jlcAmount = swapTokensForUsdt(quotedPrice[2],address(this));
            JLC.transfer(recommender,jlcAmount);
        }
        if(fundAmount >= swapTokensAtAmount) {
            swapAndLiquify(fundAmount/2);
            fundAmount = 0;
        }
        uint256 cardinality;
        if(user.site >=3) {
            up.amount += quotedPrice[0]*31/100;
            user.wealth = recommender;
            cardinality = 39;
        }
        else {
            up.amount += quotedPrice[0]*11/100;
            address _wealth = up.wealth;
            userInfo[_wealth].amount += quotedPrice[0]*30/100;
            user.wealth = up.wealth;
            cardinality = 29;
        }
        address underaddress = recommender;
        uint i;
        for(i=0;i<quotedPrice[3];++i){
            address upaddress = userInfo[underaddress].recommend;
            if(upaddress == address(0))  break;
            userInfo[upaddress].amount += quotedPrice[0]/100;
            underaddress = upaddress;
        }
        address boss =  user.topBoss;
        uint256 bossAmount = quotedPrice[0]*(cardinality-i)/100;
        userInfo[boss].amount += bossAmount;
        if(JLC.balanceOf(address(this)) >= quotedPrice[4]) JLC.transfer(msg.sender,quotedPrice[4]);     
    }
    
    function getUserInfo(address usr) public view returns(UserInfo memory user){
        user = userInfo[usr];
    }
    function init() public {
        JLC.approve(uniswapV2Router, ~uint256(0));
        usdt.approve(uniswapV2Router, ~uint256(0));
    }
    function swapAndLiquify(uint256 sellAmount) internal {
        uint256 jlcAmount = swapTokensForUsdt(sellAmount,address(this));
        IUniswapV2Router(uniswapV2Router).addLiquidity(
            address(usdt),
            address(JLC),
            sellAmount,
            jlcAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            funder,
            block.timestamp
        );
    }

    function swapTokensForUsdt(uint256 tokenAmount,address usr) internal returns(uint256){
        address[] memory path = new address[](2);
        path[0] = address(usdt);
        path[1] = address(JLC);
        uint[] memory amounts = IUniswapV2Router(uniswapV2Router).swapExactTokensForTokens(
            tokenAmount,
            0, 
            path,
            usr,
            block.timestamp
        );
        return amounts[1];
    }
    function withdraw(uint256 wad) public{
        UserInfo storage user = userInfo[msg.sender];
        require(wad<=user.amount,"JLCrank/3");
        user.amount -= wad;
        if(!white[msg.sender]) {
            if(user.topBoss != msg.sender) require(wad<=user.buyAmount*3 - user.extract,"JLCrank/4");
            fundAmount += wad*5/100;
            usdt.transfer(exchequer,wad*3/100);
            usdt.transfer(funder,wad*2/100);
            user.extract += wad;
            wad = wad*9/10;
        }
        usdt.transfer(msg.sender,wad);
    }
    function getUnderInfo(address usr) public view returns(address[]  memory A,uint256[]  memory amountA){
        UserInfo storage user = userInfo[usr];
        uint length = user.under.length;
        A = new address[](length);
        amountA = new uint256[](length);
        for(uint i=0;i<length;++i) {
            A[i] = user.under[i];
            amountA[i] = userInfo[A[i]].buyAmount;
        }
    }
}