/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor(){
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() 
    {   _status = _NOT_ENTERED;     }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

abstract contract Pausable is Context {

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused()
        public 
        view 
        virtual 
        returns (bool) 
    {   return _paused;     }

    modifier whenNotPaused(){
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause()
        internal 
        virtual 
        whenNotPaused 
    {
      _paused = true;
      emit Paused(_msgSender());
    }

    function _unpause() 
        internal 
        virtual 
        whenPaused 
    {
      _paused = false;
      emit Unpaused(_msgSender());
    }
}

contract EstrellaTera is Ownable, Pausable, ReentrancyGuard{

    using SafeMath for uint256; 
    IERC20 public USDToken;
    IERC20 public USDACEToken;
    IERC20 public TeraToken;

    uint256 public round;
    uint256 public totalUser;
    uint256 public referDepth = 10;
    uint256 public minDeposit = 10e18;
    uint256 public maxDeposit = 100e18;
    uint256 public cycleSupply = 100e18;
    uint256 public roundSupply = 200e18;
    uint256 public fixedPrice = 1e18;
    uint256 public tokenPrice = 1e18;
    uint256 public tokenPriceIncreament = 10000000000000000;
    uint256 private basedivider = 100;
    uint256 public percentage70 = 70;
    uint256 public percentage30 = 30;

    address public defaultRefer;
    address public offchain;

    struct UserInfo {
        address referrer;
        uint256 directsReferralNum;
        uint256 referralTeamNum;
    }
    mapping(address => UserInfo) public userInfo;

    mapping(address => mapping(uint256 => address[])) public teamUsers;

    event Register(address user, address referral);

    constructor()
    {
        USDToken = IERC20(0xCc59Ea62F420daf1F692C960A5E4b65f0b80C9bE);
        USDACEToken = IERC20(0xEA4cF54175F38BE85FF1109c29A8d3A5e3922e73);
        TeraToken = IERC20(0xc0c01E11f85E4B022A7ADF46DD91D3eD512e2Dc3);
        defaultRefer = 0xC353bC8E1C4d3C6F4870D83262946E8C32e126b3;
        offchain = 0xf8F76f766B39420019E4301ca7949279302D1A90;
        round = 0;
        cycle[0] = 0;
        // count_User[0][0] = 0;
    }

    function register(address _referral) public {
        require(_referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        userInfo[user.referrer].directsReferralNum = userInfo[user.referrer].directsReferralNum.add(1);
        _updateTeamNum(msg.sender);
        totalUser = totalUser.add(1);
        emit Register(msg.sender, _referral);
    }
    function _updateTeamNum(address _user) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                userInfo[upline].referralTeamNum = userInfo[upline].referralTeamNum.add(1);
                teamUsers[upline][i].push(_user);
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    mapping(uint256 => mapping(uint256 => uint256)) public totalTokencycle;
    mapping(uint256 => mapping(uint256 => uint256)) public totalTokencyclePrice;
    mapping(uint256 => uint256) public totalTokenRound; 
    mapping(uint256 => uint256) public cycle;
    uint256 private totlalToken;
    uint256 private totalPrice;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    // mapping(address => mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256)))) public userToken;
    // mapping(address => mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256)))) public userTokenPrice;
    // mapping(uint256 => mapping(uint256 => uint256)) public countUser;


    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    mapping(address => mapping(uint256 => mapping(uint256 =>  uint256))) public user_Token;
    mapping(address => mapping(uint256 => mapping(uint256 =>  uint256))) public userToken_Price;
    mapping(uint256 => mapping(uint256 =>  address)) public user_address;
    mapping(uint256 => uint256) public count_User;
    mapping(uint256 => uint256) public countSaller_User;
    mapping(address => mapping(uint256 => mapping(uint256 =>  uint256))) public seller_Token;




    function buy(address tokenAddress, uint256 tokenAmount, uint256 token)  
    external
    nonReentrant
    whenNotPaused
    {
        require(msg.sender == tx.origin," External Error ");
        // UserInfo storage user = userInfo[msg.sender];
        // require(user.referrer != address(0), "register first");
        require(token >= minDeposit, "less than min");
        require(token <= maxDeposit, "less than max");
        require(token.mod(10) == 0, "Token should be multiples of 10");
            
        uint256 tokentransfer;
        (uint256[] memory rounndDetails,uint256[] memory currentDetails,uint256[] memory nextDetails) 
        = getPrice1(token, round, cycle[round]
        // , tokenPrice
        );
        if(rounndDetails[0] == 0 || rounndDetails[0] == 1)
        { 
            (uint256 price1, uint256 price2) = getPrice(token, round, cycle[round], tokenPrice);
            uint256 totalprice = price1.add(price2);

            require(tokenAmount == totalprice, "Error");

            if(rounndDetails[2] > 1)
            {
                tokentransfer = rounndDetails[1];
            }
            else
            {
                tokentransfer = rounndDetails[1].add(rounndDetails[3]);
            }


            round = rounndDetails[0];
            totalTokenRound[round] += rounndDetails[1];

            cycle[round] = currentDetails[0];
            totalTokencycle[round][cycle[round]] += currentDetails[1];

            // countUser[round][cycle[round]] = countUser[round][cycle[round]].add(1); 
            // userToken[msg.sender][round][cycle[round]][countUser[round][cycle[round]]] = currentDetails[1];
            // userTokenPrice[msg.sender][round][cycle[round]][countUser[round][cycle[round]]] = tokenPrice;
            
            user_Token[msg.sender][round][count_User[round]] = currentDetails[1];
            userToken_Price[msg.sender][round][count_User[round]] = tokenPrice;
            user_address[round][count_User[round]] = msg.sender;

            if(currentDetails[1] > 0)
            {
            count_User[round] = count_User[round].add(1);
            }


            if(currentDetails[2] > currentDetails[0])
            {
            cycle[round] = currentDetails[2];
            tokenPrice = tokenPrice.add(tokenPriceIncreament);

            totalTokencycle[round][cycle[round]] += currentDetails[3];

            // countUser[round][cycle[round]] = countUser[round][cycle[round]].add(1); 
            // userToken[msg.sender][round][cycle[round]][countUser[round][cycle[round]]] = currentDetails[3];
            // userTokenPrice[msg.sender][round][cycle[round]][countUser[round][cycle[round]]] = tokenPrice;

            user_Token[msg.sender][round][count_User[round]] = currentDetails[3];
            userToken_Price[msg.sender][round][count_User[round]] = tokenPrice;
            user_address[round][count_User[round]] = msg.sender;
            count_User[round] = count_User[round].add(1);

            }  

            if(rounndDetails[2] > rounndDetails[0])
            {
                round = rounndDetails[2];
                totalTokenRound[round] += rounndDetails[3];

                cycle[round] = nextDetails[0];
                tokenPrice = fixedPrice;

                totalTokencycle[round][cycle[round]] += nextDetails[1];

                // countUser[round][cycle[round]] = countUser[round][cycle[round]].add(1); 
                // userToken[msg.sender][round][cycle[round]][countUser[round][cycle[round]]] = nextDetails[1];
                // userTokenPrice[msg.sender][round][cycle[round]][countUser[round][cycle[round]]] = tokenPrice;

                user_Token[msg.sender][round][count_User[round]] = nextDetails[1];
                userToken_Price[msg.sender][round][count_User[round]] = tokenPrice;
                user_address[round][count_User[round]] = msg.sender;
                count_User[round] = count_User[round].add(1);
            }
           
                if(IERC20(tokenAddress) == USDToken)
                {
                    (uint256 Percentage1,uint256 Percentage2) = percentage(tokenAmount);
                    USDToken.transferFrom(msg.sender, owner(), Percentage1);
                    USDToken.transferFrom(msg.sender, offchain, Percentage2);
                    TeraToken.transferFrom(owner(),address(this),tokentransfer);
                }
                else if(IERC20(tokenAddress) == USDACEToken)
                {
                    TeraToken.transferFrom(owner(),address(this),tokentransfer);
                }
        }
        if(rounndDetails[2] > 1)
        {
                round = rounndDetails[2]; 
                uint256 totalSalePrice;
                uint256 remainingbuyerToken;
                uint256 currentRound = round.sub(2);
                uint256 totaluser = count_User[currentRound];
                address SellerAddress = user_address[currentRound][countSaller_User[currentRound]];
                uint256 sellerTokenPrice = userToken_Price[SellerAddress][currentRound][countSaller_User[currentRound]];
                uint256 TokenofUser = user_Token[SellerAddress][currentRound][countSaller_User[currentRound]];
                TokenofUser = TokenofUser.sub(seller_Token[SellerAddress][currentRound][countSaller_User[currentRound]]);
                

                getPriceAfterTwoRunds (nextDetails[1],currentRound,totaluser,SellerAddress,sellerTokenPrice,
                TokenofUser,countSaller_User[currentRound]);

                remainingbuyerToken = nextDetails[1];
                while(remainingbuyerToken > 0)
                {
                    if(remainingbuyerToken <= TokenofUser)
                    {
                    totalSalePrice = totalSalePrice.add(remainingbuyerToken.mul(sellerTokenPrice));
                    seller_Token[SellerAddress][currentRound][countSaller_User[currentRound]] = 
                    seller_Token[SellerAddress][currentRound][countSaller_User[currentRound]].add(remainingbuyerToken);
                    }
                    else
                    {
                        totalSalePrice = totalSalePrice.add(TokenofUser.mul(sellerTokenPrice));
                        remainingbuyerToken = remainingbuyerToken.sub(TokenofUser);

                        seller_Token[SellerAddress][currentRound][countSaller_User[currentRound]] = 
                        seller_Token[SellerAddress][currentRound][countSaller_User[currentRound]].add(TokenofUser);

                        countSaller_User[round] = countSaller_User[currentRound].add(1);

                        SellerAddress = user_address[round][countSaller_User[currentRound]];
                        sellerTokenPrice = userToken_Price[SellerAddress][currentRound][countSaller_User[currentRound]];
                        TokenofUser = user_Token[SellerAddress][currentRound][countSaller_User[currentRound]];
                        TokenofUser = TokenofUser.sub(seller_Token[SellerAddress][currentRound][countSaller_User[currentRound]]);
                    }
                }
                
        }
        else
        {

        }

    }

    function getPriceAfterTwoRunds(uint256 _Tokens,uint256 _round,uint256 _totaluser, address _SellerAddress, 
    uint256 _sellerTokenPrice, uint256 _TokenofUser,uint256 _countSaller_User) public 
    view returns(uint256,uint256,uint256,uint256,address)
    {
        uint256 _remainingbuyerToken = _Tokens;
        uint256 _totalSalePrice;
        while(_remainingbuyerToken > 0)
            {
                    if(_remainingbuyerToken <= _TokenofUser)
                    {
                    _totalSalePrice = _totalSalePrice.add(_remainingbuyerToken.mul(_sellerTokenPrice));
                    _remainingbuyerToken = 0;
                    }
                    else
                    {
                        _totalSalePrice = _totalSalePrice.add(_TokenofUser.mul(_sellerTokenPrice));
                        _remainingbuyerToken = _remainingbuyerToken.sub(_TokenofUser);
                        _countSaller_User = _countSaller_User.add(1);
                        if( _countSaller_User > _totaluser)
                        {
                        _round = _round.add(1);
                        _countSaller_User = 0;
                        }
                        _SellerAddress = user_address[_round][_countSaller_User];
                        _sellerTokenPrice = userToken_Price[_SellerAddress][_round][_countSaller_User];
                        _TokenofUser = user_Token[_SellerAddress][_round][_countSaller_User];
                        _TokenofUser = _TokenofUser.sub(seller_Token[_SellerAddress][_round][_countSaller_User]);
                    }
            }
        return (_totalSalePrice, _sellerTokenPrice, _TokenofUser, _countSaller_User,_SellerAddress);
    }
    function percentage(uint256 _tokenAmount) public view returns(uint256,uint256)
    {
        uint256 _70Percentage = (_tokenAmount.mul(percentage70)).div(basedivider);
        uint256 _30Percentage = (_tokenAmount.mul(percentage30)).div(basedivider);
        return (_70Percentage, _30Percentage);
    }
    
    function getPrice1(uint256 _token, uint256 _round, uint256 _cycle
    )
    public view returns 
    (uint256[] memory,uint256[] memory,uint256[] memory)
    {
        uint256[] memory rounndDetails = new uint256[](4);
        uint256[] memory currentDetails = new uint256[](4);
        uint256[] memory nextDetails = new uint256[](4);
        (rounndDetails[0],rounndDetails[1],rounndDetails[2],rounndDetails[3]) = checkRound(_token,_round);
        if(rounndDetails[1] > 0)
        {
            (currentDetails[0],currentDetails[1],currentDetails[2],currentDetails[3])
             = CheckCycle(rounndDetails[1], rounndDetails[0],_cycle);
        }
        if(rounndDetails[3] > 0)
        {
            (nextDetails[0],nextDetails[1],nextDetails[2],nextDetails[3])
            = CheckCycle(rounndDetails[3], rounndDetails[2],_cycle);
        }

        return (rounndDetails,currentDetails, nextDetails);
    }

   function CheckCycle(uint256 _token,uint256 _round,uint256 _cycle)
    public view returns 
    (uint256,uint256,uint256,uint256)
    {
        uint256 _remainingTokenCurrentCycle;
        uint256 _remainingTokenNextCycle;
        uint256 _cycle2;

        if(totalTokencycle[_round][_cycle] <= cycleSupply)
        {
            _remainingTokenCurrentCycle = cycleSupply.sub(totalTokencycle[_round][_cycle]);
            if(_token <= _remainingTokenCurrentCycle)
            {
                _remainingTokenCurrentCycle = _token;
                _remainingTokenNextCycle = 0;
                _cycle2 = 0;
                _cycle = cycle[_round];
            }
            else
            {

                _remainingTokenNextCycle = _token.sub(_remainingTokenCurrentCycle);
                _cycle2 = _cycle.add(1);
                if(_cycle2 >= 2)
                {
                    _remainingTokenNextCycle = 0;
                }
            }
        }
        return (_cycle,_remainingTokenCurrentCycle,_cycle2,_remainingTokenNextCycle);
    }

   function checkRound(uint256 _token,uint256 _round)
    public view returns(uint256,uint256,uint256,uint256)
   {
        uint256 _remroundTokenCurrent;
        uint256 _remroundTokenNext;
        uint256 _round1;
        uint256 _round2;
        if(totalTokenRound[round] <= roundSupply)
        {
            _remroundTokenCurrent = roundSupply.sub(totalTokenRound[_round]);
            if(_token <= _remroundTokenCurrent)
            {
                _remroundTokenCurrent = _token;
                _round1 = _round;
                _remroundTokenNext = 0;
                _round2 = 0;
            }
            else{
                    _remroundTokenNext = _token.sub(_remroundTokenCurrent);
                    _round1 = _round;
                    _round2 =_round.add(1);
            }
        }
       return (_round1,_remroundTokenCurrent,_round2,_remroundTokenNext);
   }
   function getPrice(uint256 _token, uint256 _round, uint256 _cycle, uint256 _price)
    public view returns 
    (uint256,uint256)
    {
        uint256 TotalCurrentPrice;
        uint256 TotalCurrentPrice1;
        uint256 TotalNextPrice;
        uint256 TotalNextPrice1;
        (uint256 currentRound,uint256 roundTokenCurrent,uint256 nextRound,uint256 roundTokenNext) = checkRound(_token,_round);
        if(roundTokenCurrent > 0)
        {
            uint256[] memory currentDetails = new uint256[](4);
            (currentDetails[0],currentDetails[1],currentDetails[2],currentDetails[3])
             = CheckCycle(roundTokenCurrent, currentRound,_cycle);
            TotalCurrentPrice = currentDetails[1].mul(_price);
            TotalCurrentPrice = TotalCurrentPrice.div(1e18);
            if(currentDetails[3] > 0 )
            {
            uint256 nextPrice = _price.add(tokenPriceIncreament);
            TotalCurrentPrice1 = currentDetails[3].mul(nextPrice);
            TotalCurrentPrice1 = TotalCurrentPrice1.div(1e18);
            }
        }
        if(roundTokenNext > 0)
        {
            uint256[] memory nextDetails = new uint256[](4);
            _price = fixedPrice;
            _cycle = 0; 
            (nextDetails[0],nextDetails[1],nextDetails[2],nextDetails[3])
            = CheckCycle(roundTokenNext, nextRound,_cycle);
            TotalNextPrice = nextDetails[1].mul(_price);
            TotalNextPrice = TotalNextPrice.div(1e18);
            if(nextDetails[3] > 0)
            {
            uint256 nextPrice = _price.add(tokenPriceIncreament);
            TotalNextPrice1 = nextDetails[3].mul(nextPrice);
            TotalNextPrice1 = TotalNextPrice1.div(1e18);
            }
        }
        return ((TotalCurrentPrice1.add(TotalCurrentPrice)),(TotalNextPrice.add(TotalNextPrice1)));
    }
///////////////////////USDT TOken/////////////////////////////////////////
    function withdrawUSDToken(uint256 _count)
    public
    onlyOwner
    {   USDToken.transfer(owner(),_count);   }

    function emergancyWithdrawUSDToken()
    public
    onlyOwner
    {   USDToken.transfer(owner(),USDToken.balanceOf(address(this)));  }
/////////////////////USDACE Token/////////////////////////////////////////
function withdrawUSDACEToken(uint256 _count)
    public
    onlyOwner
    {   USDACEToken.transfer(owner(),_count);   }

    function emergancyWithdrawUSDACEToken()
    public
    onlyOwner
    {   USDACEToken.transfer(owner(),USDACEToken.balanceOf(address(this)));  }
///////////////////TeraToken//////////////////////////////////////////////////
function withdrawTeraToken(uint256 _count)
    public
    onlyOwner
    {   TeraToken.transfer(owner(),_count);   }

    function emergancyWithdrawTeraToken()
    public
    onlyOwner
    {   TeraToken.transfer(owner(),TeraToken.balanceOf(address(this)));  }
///////////////////////////////////////////////////////////////////////////////

    function pauseContract()
    public
    onlyOwner
    {       _pause();   }

    function unPauseContract()
    public
    onlyOwner 
    {       _unpause();     }

    function test(uint256 div, uint Token) public view returns (uint256,uint256 )
    {
        uint256 tokenPriceIncreament1 = Token.mul(tokenPriceIncreament);
        uint256 tokenPriceIncreament2 = tokenPriceIncreament1.div(div);
    
    return (tokenPriceIncreament1,tokenPriceIncreament2);
    }
}