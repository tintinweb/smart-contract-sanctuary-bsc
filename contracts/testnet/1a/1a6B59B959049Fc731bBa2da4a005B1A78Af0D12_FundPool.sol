/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.7;
interface TokenLike {
    function transfer(address,uint) external;
    function transferFrom(address,address,uint) external;
    function approve(address guy, uint wad) external;
    function balanceOf(address) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function ownerOf(uint _tokenid) external view returns (address);
    function tokenOfOwnerByIndex(address,uint) external view returns (uint);
}
interface Routerv2 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata _path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
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
    function getAmountsOut(uint amountIn, address[] memory path)
        external
        view
        returns (uint[] memory amounts);
}
interface LpFarm {
    function depositAll() external;
    function harvest() external returns (uint);
    function withdrawAll() external;
    function withdraw(uint256) external;
    function userInfo(address) external view returns(uint256,int256,uint256);
    }
interface ExchequerLike {
    function fundPool(address) external returns (uint);
}
contract FundPool {

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
    mapping (uint =>mapping (address => uint))        public  voted;
    mapping (uint =>mapping (address => uint))        public  unvoted;
    address                                           public  cdao;
    address                                           public  usdt = 0x5A79a689288d880Ed6bB78DAf3AC9EB537190A2F;
    address                                           public  uniswapV2Router = 0x296924fBA0c76821b00022f80658531e40b89cbc;
    
    address                                           public  Pair ;
    address                                           public  exchequer;
    address                                           public  lpfarm = 0x39C0270f3f3a594ae726D8290da4C9B902560246;
    address                                           public  child = 0xBEE8Ce01e7EB2F4d081aBa993025fc89B0eC5258;
    mapping (uint256 => SchemeInfo)                   public  schemeInfo;
    uint256                                           public  order;

    event Swapandliquify( uint256  indexed  usdtamount,
                          uint256           cdaoamount,
                          uint256           lpamount
                         );

    struct SchemeInfo {
        address    targetaddress;
        uint256    liquidity;   
        uint256    poll;
        uint256    unpoll;
        uint256    endtime;
        uint256    received;
    }

    function init() public{
        TokenLike(cdao).approve(uniswapV2Router,~uint(1));
        TokenLike(usdt).approve(uniswapV2Router,~uint(1));
        TokenLike(Pair).approve(lpfarm,~uint(1));
    }
    function setAddress(address _token,address _lptoken ,address _exchequer) external {
        //if (cdao == address(0)) {
            cdao = _token;
            Pair = _lptoken; 
            exchequer = _exchequer;
        //}
    }

    //----Add liquidity and collateral LP-----
    //Convert half of your cdao into usdt and add the remaining half to the bottom pool and pledge the LP earned to the bonus pool for mining  
    function swapAndLiquify() public {
        uint256 tokens = TokenLike(cdao).balanceOf(address(this));
        require(tokens >0,"FundPool/The CDAO balance must be greater than 0");
        // split the contract balance into halves
        uint256 half = tokens/2;
        uint256 otherHalf = sub(tokens,half);
        address[] memory path = new address[](2);
        path[0] = cdao;
        path[1] = usdt;
        Routerv2(uniswapV2Router).swapExactTokensForTokens(half,0,path, address(this),block.timestamp);
        uint256 usdtamount = TokenLike(usdt).balanceOf(address(this));
        (, , uint liquidity)=Routerv2(uniswapV2Router).addLiquidity(usdt,cdao,usdtamount,otherHalf,0,0,address(this),block.timestamp);
        LpFarm(lpfarm).depositAll();
        emit Swapandliquify(usdtamount,half,liquidity);
    }
    //Convert half of your usdt into cdao and add the remaining half to the bottom pool and pledge the LP earned to the bonus pool for mining  
    function swapAndLiquifyusdt() public {
        uint256 usdtamount = TokenLike(usdt).balanceOf(address(this));
        require(usdtamount >0,"FundPool/The usdt balance must be greater than 0");    
        uint256 half = usdtamount/2;
        uint256 otherHalf = sub(usdtamount,half);
        address[] memory path = new address[](2);
        path[0] = usdt;
        path[1] = cdao;
        Routerv2(uniswapV2Router).swapExactTokensForTokens(half,0,path, address(this),block.timestamp);
        uint256 cdaoamount = TokenLike(cdao).balanceOf(address(this));
        (, , uint liquidity)=Routerv2(uniswapV2Router).addLiquidity(usdt,cdao,otherHalf,cdaoamount,0,0,address(this),block.timestamp);
        LpFarm(lpfarm).depositAll();
        emit Swapandliquify(otherHalf, cdaoamount, liquidity);
    }
    
    //----Extraction Found yield-----
    //Access to Treasury funds
    function getExchequerFund() public {
        uint256 wad = ExchequerLike(exchequer).fundPool(address(this));
        if (wad>0) swapAndLiquify();
    }

    //Obtain liquidity mining income
    function getLpFarm() public {
        uint256 wad = LpFarm(lpfarm).harvest();
        if (wad>0) swapAndLiquify();
    }

    //----Only the address that holds the points can vote on the use of the fund-----
    //Implement adopted proposals 
    function execute(uint256 _order) public returns (bool){  
        SchemeInfo storage scheme = schemeInfo[_order];
        require(scheme.received == 0,"FundPool/The proposal has been implemented");         
        if (scheme.poll>TokenLike(child).totalSupply()/2 || block.timestamp > scheme.endtime && scheme.poll > scheme.unpoll*15/10 
           && scheme.poll >= TokenLike(child).totalSupply()*2/10){
                uint256 _liquidity = scheme.liquidity;
                (uint256  totaliquidity,,) = LpFarm(lpfarm).userInfo(address(this));
                if (_liquidity >totaliquidity/10) _liquidity = totaliquidity/10;
                scheme.received = _liquidity;
                LpFarm(lpfarm).withdraw(_liquidity);
                TokenLike(Pair).transfer(scheme.targetaddress,_liquidity);   
           }
        return true;
     }
     // Only proposals that meet the requirements can be voted on by the community
    function allocation(uint256 wad, address urt, uint256  _liquidity,uint256  _day) public returns (uint256){ 
        require(TokenLike(child).totalSupply() >= 210*10**18,"FundPool/A total of 2.1 million points is required to start a proposal");//210*10**22
        require(_day <=30,"FundPool/Proposals cannot be voted on for more than 30 days");
        (uint256  totaliquidity,,) = LpFarm(lpfarm).userInfo(address(this));
        require(_liquidity < totaliquidity/10,"FundPool/No more than 10% of the fund can be donated");
        address[] memory path = new address[](2);
        path[0] = cdao;
        path[1] = usdt;
        uint[] memory amounts = Routerv2(uniswapV2Router).getAmountsOut(wad,path);
        require(amounts[1] >=10**20,"FundPool/The sponsor's donated CDAO must be greater than 100USDT");
        TokenLike(cdao).transferFrom(msg.sender, address(this), wad);      
        order +=1; 
        SchemeInfo storage scheme = schemeInfo[order];
        scheme.targetaddress  = urt;
        scheme.liquidity  = _liquidity;
        scheme.endtime  = block.timestamp + _day*86400;
        return order;
    }
     //Vote yes and cancel no
    function vote(uint256 _order) public returns (bool){     
        uint256 _wad = TokenLike(child).balanceOf(msg.sender);      
        require(_wad >voted[_order][msg.sender],"FundPool/You can only vote again if the score is greater than the number of votes already cast");
        SchemeInfo storage scheme = schemeInfo[_order];
        require(block.timestamp < scheme.endtime,"FundPool/Voting hours have closed");
        scheme.poll = add(scheme.poll,sub(_wad,voted[_order][msg.sender]));
        voted[_order][msg.sender] =_wad; 
        if (unvoted[_order][msg.sender] >0) {
            scheme.unpoll = sub(scheme.poll,unvoted[_order][msg.sender]);
            unvoted[_order][msg.sender] =0; 
        }
        return true;
     }
     //Vote no and cancel yes
    function unvote(uint256 _order) public returns (bool){     
        uint256 _wad = TokenLike(child).balanceOf(msg.sender);      
        require(unvoted[_order][msg.sender]<  _wad,"FundPool/You can only vote again if the score is greater than the number of votes already cast");
        SchemeInfo storage scheme = schemeInfo[_order];
        require(block.timestamp < scheme.endtime,"FundPool/Voting hours have closed");
        scheme.unpoll = add(scheme.unpoll,sub(_wad,unvoted[_order][msg.sender]));
        unvoted[_order][msg.sender] =_wad; 
        if (voted[_order][msg.sender] >0) {
            scheme.poll = sub(scheme.poll,voted[_order][msg.sender]);
            voted[_order][msg.sender] =0; 
        }
        return true;
     }
}