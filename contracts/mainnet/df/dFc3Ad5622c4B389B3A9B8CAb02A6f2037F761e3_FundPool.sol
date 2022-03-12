/**
 *Submitted for verification at BscScan.com on 2022-03-12
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
}
interface Lp2Farm {
    function depositAll() external;
    function harvest() external returns (uint);
    function withdrawAll() external;
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
    mapping (uint =>mapping (uint => bool))           public  voted;
    address                                           public  spd;
    address                                           public  fist = 0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A;
    address                                           public  uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address[]                                         public  path = [spd,fist];
    address                                           public  Pair ;
    address                                           public  exchequer;
    address                                           public  lp2farm = 0xbA1D4818475E3924715803872aE21ee0cdb7894b;
    address                                           public  spdnft = 0xefE9b24E1060540096760869859c87096c2c723b;
    mapping (uint256 => UserInfo)                     public  userInfo;
    uint256                                           public  order;

    event Swapandliquify( uint256  indexed  spdamount,
                          uint256           fistamount,
                          uint256           lpamount
                         );
    event Harvest( address  indexed  owner,
                   uint256           wad
                  );
    event Withdraw( address  indexed  owner,
                    uint256           wad
                 );

    struct UserInfo {
        address    owner;
        uint256    tokenid;   
        uint256    poll;
        uint256    received;
    }

    function init() public{
        TokenLike(spd).approve(uniswapV2Router,~uint(1));
        TokenLike(fist).approve(uniswapV2Router,~uint(1));
        TokenLike(Pair).approve(lp2farm,~uint(1));
    }
    function setAddress(address _token,address _lptoken ,address _exchequer) external {
        if (spd == address(0)) {
            spd = _token;
            Pair = _lptoken; 
            exchequer = _exchequer;
            path[0] = spd;
        }
    }

    //----Add liquidity and collateral LP-----
    //Convert half of your gains into FIST and add the remaining half to the bottom pool and pledge the LP earned to the bonus pool for mining  
    function swapAndLiquify() internal {
        uint256 tokens = TokenLike(spd).balanceOf(address(this));
        // split the contract balance into halves
        uint256 half = tokens/2;
        uint256 otherHalf = sub(tokens,half);
        Routerv2(uniswapV2Router).swapExactTokensForTokens(half,0,path, address(this),block.timestamp);
        uint256 fisttokens = TokenLike(fist).balanceOf(address(this));
        (, , uint liquidity)=Routerv2(uniswapV2Router).addLiquidity(fist,spd,fisttokens,otherHalf,0,0,address(this),block.timestamp);
        Lp2Farm(lp2farm).depositAll();
        emit Swapandliquify(fisttokens,half,liquidity);
    }
    //Add the full balance of the contract to the bottom pool and pledge the LP earned to the bonus pool for mining  
    function addLiquify() public {
        uint256 tokens = TokenLike(spd).balanceOf(address(this));
        uint256 fisttokens = TokenLike(fist).balanceOf(address(this));
        (, , uint liquidity)=Routerv2(uniswapV2Router).addLiquidity(fist,spd,fisttokens,tokens,0,0,address(this),block.timestamp);
        Lp2Farm(lp2farm).depositAll();
        emit Swapandliquify(fisttokens, tokens, liquidity);
    }
    
    //----Extraction Found yield-----
    //Access to Treasury funds
    function getExchequerFund() public {
        uint256 wad = ExchequerLike(exchequer).fundPool(address(this));
        if (wad>0) swapAndLiquify();
    }

    //Obtain liquidity mining income
    function getLpFarm() public {
        uint256 wad = Lp2Farm(lp2farm).harvest();
        if (wad>0) swapAndLiquify();
    }

    //----Hold NFT to divide fund pool earnings-----
    //Users who currently apply for a split, with the consent of half of the NFT holders, can take their share 
    function withdraw() public {    
        UserInfo storage user = userInfo[order];
        require(user.received == 0,"FundPool/The current user has finished collecting the file");   

        //When the last 21 NFT are left, you do not need to vote, you can directly receive them    
        if (order <= 189) require(user.poll >(210-order)/2,"FundPool/Less than half of current users voted"); 
        getExchequerFund();
        getLpFarm(); 
        Lp2Farm(lp2farm).withdrawAll();
        uint256 _liquidity = TokenLike(Pair).balanceOf(address(this));
        uint256 _share =  _liquidity/(211-order);
        TokenLike(Pair).transfer(user.owner,_share);
        user.received =_share;
        Lp2Farm(lp2farm).depositAll();
     }
     // NFT owner applies for allocation
    function allocation(uint256  _tokenid) public {  
        require(TokenLike(spdnft).totalSupply() == 210,"FundPool/NFT quantity does not meet legal standard");
        if (order>0) require(userInfo[order].received != 0,"FundPool/The current user vote has not yet closed");
        TokenLike(spdnft).transferFrom(msg.sender, address(this), _tokenid);
        order +=1; 
        UserInfo storage user = userInfo[order];
        user.tokenid = _tokenid;
        user.owner = msg.sender;
     }
    function allocationAuto() public {      
        require(TokenLike(spdnft).balanceOf(msg.sender) >=1,"FundPool/Voters don't have NFT"); 
        uint256  _tokenid = TokenLike(spdnft).tokenOfOwnerByIndex(msg.sender,0);
         allocation(_tokenid);
     }
     //NFT holders can vote for the current applicant
    function vote(uint256  _tokenid) public {      
        require(msg.sender == TokenLike(spdnft).ownerOf(_tokenid),"FundPool/The voters are not the owners of NFT"); 
        require(!voted[order][_tokenid],"FundPool/An NFT can only vote once");
        UserInfo storage user = userInfo[order];
        user.poll += 1;
        voted[order][_tokenid] =true;
     }
    function voteAuto() public {      
        require(TokenLike(spdnft).balanceOf(msg.sender) >=1,"FundPool/Voters don't have NFT"); 
        uint256  _tokenid = TokenLike(spdnft).tokenOfOwnerByIndex(msg.sender,0);
        vote(_tokenid);
     }

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external pure returns(bytes4){
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}