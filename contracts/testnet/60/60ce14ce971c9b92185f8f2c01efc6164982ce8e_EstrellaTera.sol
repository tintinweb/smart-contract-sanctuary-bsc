/**
 *Submitted for verification at BscScan.com on 2023-02-09
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

    address public defaultRefer;
    address public offchain;

    struct UserInfo {
        address referrer;
        uint256 directsReferralNum;
        uint256 referralTeamNum;
    }

    bool roundbool;

    uint256 public round;
    uint256 public totalUser;
    uint256 private totalPrice;
    uint256 private totlalToken;
    uint256 public referDepth = 10;
    uint256 public fixedPrice = 1e18;
    uint256 public tokenPrice = 1e18;

    uint256 public percentage70 = 70;
    uint256 public percentage30 = 30;
    // uint256 private basedivider = 100;

    uint256 public minDeposit = 10e18;
    uint256 public maxDeposit = 100e18;
    uint256 public cycleSupply = 100e18;
    uint256 public roundSupply = 200e18;
    
    uint256 private constant baseDivider = 100;
    uint256 public tokenPriceIncreament = 10000000000000000;
    
    uint256[6] private Selling_Percents = [0,0,160,180,200,400];
    uint256[6] private Balance_Percents = [100,200,240,300,400,0];
    uint256[6] private Round_Percents = [100,200,400,480,600,800];

    mapping(uint256 => uint256) public cycle;
    mapping(uint256 => bool) public checking;
    mapping(address => UserInfo) public userInfo;
    mapping(uint256 => uint256) public seller_Count;
    mapping(uint256 => uint256) public buyer_Count;
    mapping(address => uint256) public SellTotalToken;
    mapping(uint256 => uint256) public totalTokenRound; 
    mapping(address => uint256 ) public buyertimeCount;
    mapping(address => mapping(uint256 => address[])) public teamUsers;
    mapping(address => mapping(uint256 =>  uint256)) public buyerRound;
    mapping(uint256 => mapping(uint256 =>  address)) public buyer_address;
    mapping(uint256 => mapping(uint256 => uint256)) public totalTokencycle;
    mapping(address => mapping(uint256 =>  uint256)) public buyerTotalToken;
    mapping(uint256 => mapping(uint256 => uint256)) public totalTokencyclePrice;
    mapping(address => mapping(uint256 => mapping(uint256 =>  uint256))) public buyer_Token;
    mapping(address => mapping(uint256 => mapping(uint256 =>  uint256))) public buyerToken_Price;
    mapping(address => mapping(uint256 => mapping(uint256 =>  uint256))) public buyerSellTotalToken;

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
    uint256 public Rem_Amount1;
    uint256 public Rem_Amount2;
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
        if(roundbool == false)
        {
            uint256 tokentransfer;
            (uint256[] memory rounndDetails,uint256[] memory currentDetails,uint256[] memory nextDetails) 
            = getPrice1(token, round, cycle[round]);
            if(rounndDetails[0] == 0 || rounndDetails[0] == 1)
            { 
                (uint256 price1, uint256 price2) = getPrice(token, round, cycle[round], tokenPrice);
                uint256 totalprice = price1.add(price2);
                if(rounndDetails[2] > 1)
                {    tokentransfer = rounndDetails[1]; 
                     totalprice =  price1; 
                     Rem_Amount1 = tokenAmount.sub(price2); 
                     Rem_Amount2 = price2;
                }else{
                    tokentransfer = rounndDetails[1].add(rounndDetails[3]);  
                    Rem_Amount1 = tokenAmount; 
                }
                
                require(Rem_Amount1 == totalprice, "Error");

                round = rounndDetails[0];
                totalTokenRound[round] += rounndDetails[1];
                cycle[round] = currentDetails[0];
                totalTokencycle[round][cycle[round]] += currentDetails[1];
                buyer_Token[msg.sender][round][buyer_Count[round]] = currentDetails[1];
                buyerToken_Price[msg.sender][round][buyer_Count[round]] = tokenPrice;
                buyer_address[round][buyer_Count[round]] = msg.sender;
                buyerTotalToken[msg.sender][buyertimeCount[msg.sender]] = currentDetails[1];
                buyer_Count[round] = buyer_Count[round].add(1);
                if(currentDetails[2] > currentDetails[0])
                {
                cycle[round] = currentDetails[2];
                tokenPrice = tokenPrice.add(tokenPriceIncreament);
                totalTokencycle[round][cycle[round]] += currentDetails[3];
                buyer_Token[msg.sender][round][buyer_Count[round]] = currentDetails[3];
                buyerToken_Price[msg.sender][round][buyer_Count[round]] = tokenPrice;
                buyer_address[round][buyer_Count[round]] = msg.sender;
                buyerTotalToken[msg.sender][buyertimeCount[msg.sender]] += currentDetails[3];
                buyer_Count[round] = buyer_Count[round].add(1);
                }  
                buyerRound[msg.sender][buyertimeCount[msg.sender]] = round;
                buyertimeCount[msg.sender] = buyertimeCount[msg.sender].add(1);
                if(rounndDetails[2] > rounndDetails[0])
                {
                    round = rounndDetails[2];
                    totalTokenRound[round] += rounndDetails[3];
                    cycle[round] = nextDetails[0];
                    tokenPrice = fixedPrice;
                    totalTokencycle[round][cycle[round]] += nextDetails[1];
                    buyer_Token[msg.sender][round][buyer_Count[round]] = nextDetails[1];
                    buyerToken_Price[msg.sender][round][buyer_Count[round]] = tokenPrice;
                    buyer_address[round][buyer_Count[round]] = msg.sender;
                    buyer_Count[round] = buyer_Count[round].add(1);
                    buyerTotalToken[msg.sender][buyertimeCount[msg.sender]] = nextDetails[1];
                    buyerRound[msg.sender][buyertimeCount[msg.sender]] = round;
                    buyertimeCount[msg.sender] = buyertimeCount[msg.sender].add(1);
                }
                if(IERC20(tokenAddress) == USDToken)
                {
                    (uint256 Percentage1,uint256 Percentage2) = percentage(Rem_Amount1);
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
                roundbool = true;
                round = rounndDetails[2]; 
                uint256 remainingbuyerToken;
                uint256 totalToken;
                uint256 totalTokenPrice;
                uint256 PreviousRound = round.sub(2);
                address SellerAddress = buyer_address[PreviousRound][seller_Count[PreviousRound]];
                uint256 sellerTokenPrice = buyerToken_Price[SellerAddress][PreviousRound][seller_Count[PreviousRound]];
                uint256 TokenBuy_ = buyer_Token[SellerAddress][PreviousRound][seller_Count[PreviousRound]];
                uint256[] memory TokenBuy_User = new uint256[](3);
                TokenBuy_User = checktoken(PreviousRound, TokenBuy_);
                TokenBuy_User[0] = TokenBuy_User[0].sub(buyerSellTotalToken[SellerAddress][PreviousRound][seller_Count[PreviousRound]]);
                remainingbuyerToken = nextDetails[1];
                while(remainingbuyerToken > 0)
                {
                    if(remainingbuyerToken <= TokenBuy_User[0])
                    {
                    buyerSellTotalToken[SellerAddress][PreviousRound][seller_Count[PreviousRound]] = 
                    buyerSellTotalToken[SellerAddress][PreviousRound][seller_Count[PreviousRound]].add(remainingbuyerToken);
                    SellTotalToken[SellerAddress] += remainingbuyerToken; 
                    buyer_Token[msg.sender][round][buyer_Count[round]] = remainingbuyerToken;
                    buyerToken_Price[msg.sender][round][buyer_Count[round]] = sellerTokenPrice;
                    buyer_address[round][buyer_Count[round]] = msg.sender;
                    buyerTotalToken[msg.sender][buyertimeCount[msg.sender]] = remainingbuyerToken;
                    totalToken = remainingbuyerToken;
                    totalTokenPrice = remainingbuyerToken.mul(sellerTokenPrice);
                    remainingbuyerToken = 0;
                    }
                    else
                    {
                        remainingbuyerToken = remainingbuyerToken.sub(TokenBuy_User[0]);
                        buyerSellTotalToken[SellerAddress][PreviousRound][seller_Count[PreviousRound]] = 
                        buyerSellTotalToken[SellerAddress][PreviousRound][seller_Count[PreviousRound]].add(TokenBuy_User[0]);
                        SellTotalToken[SellerAddress] += TokenBuy_User[0];
                        buyer_Token[msg.sender][round][buyer_Count[round]] = TokenBuy_User[0];
                        buyerToken_Price[msg.sender][round][buyer_Count[round]] = sellerTokenPrice;
                        buyer_address[round][buyer_Count[round]] = msg.sender;
                        buyerTotalToken[msg.sender][buyertimeCount[msg.sender]] += TokenBuy_User[0];
                        buyer_Count[round] = buyer_Count[round].add(1);
                        totalToken += TokenBuy_User[0];
                        totalTokenPrice += TokenBuy_User[0].mul(sellerTokenPrice);
                        seller_Count[PreviousRound] = seller_Count[PreviousRound].add(1);
                        SellerAddress = buyer_address[PreviousRound][seller_Count[PreviousRound]];
                        sellerTokenPrice = buyerToken_Price[SellerAddress][PreviousRound][seller_Count[PreviousRound]];
                        TokenBuy_ = buyer_Token[SellerAddress][PreviousRound][seller_Count[PreviousRound]];
                        TokenBuy_User = checktoken(PreviousRound, TokenBuy_);
                        TokenBuy_User[0] = TokenBuy_User[0].sub(buyerSellTotalToken[SellerAddress][PreviousRound][seller_Count[PreviousRound]]);
                    }
                    buyerRound[msg.sender][buyertimeCount[msg.sender]] = round;
                    buyertimeCount[msg.sender] = buyertimeCount[msg.sender].add(1);
                    
                }
                if(IERC20(tokenAddress) == USDToken)
                {
                    totalTokenPrice = totalTokenPrice.div(1e18);
                    require(Rem_Amount2 == totalTokenPrice, "Error 1");
                    (uint256 Percentage1,uint256 Percentage2) = percentage(totalTokenPrice);
                    USDToken.transferFrom(msg.sender, owner(), Percentage1);
                    USDToken.transferFrom(msg.sender, offchain, Percentage2);
                    TeraToken.transferFrom(owner(),address(this),totalToken);
                }
                else if(IERC20(tokenAddress) == USDACEToken)
                {
                    TeraToken.transferFrom(owner(),address(this),totalToken);
                }
            }   
        }
        else
        { 
            uint256 remainingbuyerToken;
            uint256 endRound;
            uint256 totalToken;
            uint256 totalTokenPrice;
            uint256 PreviousRound;
            if(!checking[round]){
                if(round < 5){
                    endRound = round.sub(2);
                    PreviousRound = 0;
                }else{
                    PreviousRound = round.sub(5);
                    }
                checking[round] = true;
            }
            uint256 totaluser = buyer_Count[PreviousRound];
            address SellerAddress = buyer_address[PreviousRound][seller_Count[PreviousRound]];
            uint256 sellerTokenPrice = buyerToken_Price[SellerAddress][PreviousRound][seller_Count[PreviousRound]];
            uint256 TokenBuy_ = buyer_Token[SellerAddress][PreviousRound][seller_Count[PreviousRound]];
            uint256[] memory TokenBuy_User = new uint256[](3);
            TokenBuy_User = checktoken(PreviousRound, TokenBuy_);
            TokenBuy_User[0] = TokenBuy_User[0].sub(buyerSellTotalToken[SellerAddress][PreviousRound][seller_Count[PreviousRound]]);
            uint256[] memory BuyerandSalesDetails = new uint256[](3);
            BuyerandSalesDetails =  getPriceAfterTwoRunds(token,PreviousRound,totaluser,SellerAddress,sellerTokenPrice,
            TokenBuy_User[0],seller_Count[PreviousRound]);
            require(tokenAmount == BuyerandSalesDetails[0], "Error");
            remainingbuyerToken = token;
            while(remainingbuyerToken > 0)
            {
                if(remainingbuyerToken <= TokenBuy_User[0])
                {
                buyerSellTotalToken[SellerAddress][PreviousRound][seller_Count[PreviousRound]] = 
                buyerSellTotalToken[SellerAddress][PreviousRound][seller_Count[PreviousRound]].add(remainingbuyerToken);
                SellTotalToken[SellerAddress] += remainingbuyerToken;
                buyer_Token[msg.sender][round][buyer_Count[round]] = remainingbuyerToken;
                buyerToken_Price[msg.sender][round][buyer_Count[round]] = sellerTokenPrice;
                buyer_address[round][buyer_Count[round]] = msg.sender;
                buyer_Count[round] = buyer_Count[round].add(1);
                buyerTotalToken[msg.sender][buyertimeCount[msg.sender]] = remainingbuyerToken;
                totalToken += remainingbuyerToken;
                totalTokenPrice += remainingbuyerToken.mul(sellerTokenPrice);
                remainingbuyerToken = 0;
                }
                else{
                    remainingbuyerToken = remainingbuyerToken.sub(TokenBuy_User[0]);
                    buyerSellTotalToken[SellerAddress][PreviousRound][seller_Count[PreviousRound]] = 
                    buyerSellTotalToken[SellerAddress][PreviousRound][seller_Count[PreviousRound]].add(TokenBuy_User[0]);
                    SellTotalToken[SellerAddress] += TokenBuy_User[0];
                    buyer_Token[msg.sender][round][buyer_Count[round]] = TokenBuy_User[0];
                    buyerToken_Price[msg.sender][round][buyer_Count[round]] = sellerTokenPrice;
                    buyer_address[round][buyer_Count[round]] = msg.sender;
                    buyerTotalToken[msg.sender][buyertimeCount[msg.sender]] += TokenBuy_User[0];
                    buyer_Count[round] = buyer_Count[round].add(1);
                    totalToken += TokenBuy_User[0];
                    totalTokenPrice += TokenBuy_User[0].mul(sellerTokenPrice);
                    seller_Count[PreviousRound] = seller_Count[PreviousRound].add(1);
                    if(seller_Count[PreviousRound] >= buyer_Count[PreviousRound]){
                        PreviousRound = PreviousRound.add(1);
                        if(PreviousRound > endRound){
                            PreviousRound = 0;
                            seller_Count[PreviousRound] = 0;
                            buyerRound[msg.sender][buyertimeCount[msg.sender]] = round;
                            buyertimeCount[msg.sender] = buyertimeCount[msg.sender].add(1);
                            round = round.add(1);
                        }
                    }
                    SellerAddress = buyer_address[PreviousRound][seller_Count[PreviousRound]];
                    sellerTokenPrice = buyerToken_Price[SellerAddress][PreviousRound][seller_Count[PreviousRound]];
                    TokenBuy_ = buyer_Token[SellerAddress][PreviousRound][seller_Count[PreviousRound]];
                    TokenBuy_User = checktoken(PreviousRound, TokenBuy_);
                    TokenBuy_User[0] = TokenBuy_User[0].sub(buyerSellTotalToken[SellerAddress][PreviousRound][seller_Count[PreviousRound]]);
                }
                buyerRound[msg.sender][buyertimeCount[msg.sender]] = round;
                buyertimeCount[msg.sender] = buyertimeCount[msg.sender].add(1);
            }
            if(IERC20(tokenAddress) == USDToken)
                {
                    totalTokenPrice = totalTokenPrice.div(1e18);
                    (uint256 Percentage1,uint256 Percentage2) = percentage(totalTokenPrice);
                    USDToken.transferFrom(msg.sender, owner(), Percentage1);
                    USDToken.transferFrom(msg.sender, offchain, Percentage2);
                    TeraToken.transferFrom(owner(),address(this),totalToken);
                }
                else if(IERC20(tokenAddress) == USDACEToken)
                {
                    TeraToken.transferFrom(owner(),address(this),totalToken);
                }
        }
    }
    function checktoken(uint256 _round, uint256 _token) public view returns (uint256[] memory)
    {
        uint256 currentRound = round;
        uint256 percentages = currentRound.sub(_round);
        uint256[] memory totalTokens = new uint256[](3);
        totalTokens[0] = (_token.mul(Selling_Percents[percentages])).div(baseDivider);
        totalTokens[1] = (_token.mul(Balance_Percents[percentages])).div(baseDivider);
        totalTokens[2] = (_token.mul(Round_Percents[percentages])).div(baseDivider);
        return totalTokens;
    }
    function checkbalance(address _user) public view returns(uint256)
    {
        uint256 totalTokens;
        for(uint256 i = 0; i < buyertimeCount[_user] ; i++)
        {
            uint256 currentRound = round;
            uint256 _tokens = buyerTotalToken[_user][i];
            uint256 _rounds = buyerRound[_user][i];
            uint256 percentages = currentRound.sub(_rounds);
            uint256 total = (_tokens.mul(Round_Percents[percentages])).div(baseDivider);
            totalTokens = totalTokens.add(total);
        }
        totalTokens = totalTokens.sub(SellTotalToken[_user]);
        return totalTokens;
    }

    function getPriceAfterTwoRunds(uint256 _Tokens,uint256 _startRound,uint256 _totaluser, address _SellerAddress, 
    uint256 _sellerTokenPrice, uint256 _TokenBuy,uint256 _seller_Count) public 
    view returns(uint256[] memory Details)
    {
        uint256 _remainingbuyerToken = _Tokens;
        uint256[] memory priceDetails = new uint256[](3);
        priceDetails[1] = _startRound;
        uint256[] memory TokenBuy_User = new uint256[](3);
        TokenBuy_User[0] = _TokenBuy;
        while(_remainingbuyerToken > 0)
            {
                if(_remainingbuyerToken <= TokenBuy_User[0]){
                priceDetails[0] = priceDetails[0].add(_remainingbuyerToken.mul(_sellerTokenPrice));
                _remainingbuyerToken = 0;
                }
                else{
                priceDetails[0] = priceDetails[0].add(TokenBuy_User[0].mul(_sellerTokenPrice));
                _remainingbuyerToken = _remainingbuyerToken.sub(TokenBuy_User[0]);
                _seller_Count = _seller_Count.add(1);
                    if( _seller_Count >= _totaluser){
                    priceDetails[1] = priceDetails[1].add(1);
                    _seller_Count = 0;
                    }
                _SellerAddress = buyer_address[priceDetails[1]][_seller_Count];
                _sellerTokenPrice = buyerToken_Price[_SellerAddress][priceDetails[1]][_seller_Count];
                _TokenBuy = buyer_Token[_SellerAddress][priceDetails[1]][_seller_Count];
                TokenBuy_User = checktoken(priceDetails[1], _TokenBuy);
                TokenBuy_User[0] = TokenBuy_User[0].sub(buyerSellTotalToken[_SellerAddress][priceDetails[1]][_seller_Count]);
                }
            }
        priceDetails[0] = priceDetails[0].div(1e18);
        return priceDetails;
    }
   
    function percentage(uint256 _tokenAmount) public view returns(uint256,uint256)
    {
        uint256 _70Percentage = (_tokenAmount.mul(percentage70)).div(baseDivider);
        uint256 _30Percentage = (_tokenAmount.mul(percentage30)).div(baseDivider);
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
        if(rounndDetails[1] > 0){
            (currentDetails[0],currentDetails[1],currentDetails[2],currentDetails[3])
             = CheckCycle(rounndDetails[1], rounndDetails[0],_cycle);
        }
        if(rounndDetails[3] > 0){
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
        if(totalTokencycle[_round][_cycle] <= cycleSupply){
            _remainingTokenCurrentCycle = cycleSupply.sub(totalTokencycle[_round][_cycle]);
            if(_token <= _remainingTokenCurrentCycle){
                _remainingTokenCurrentCycle = _token;
                _remainingTokenNextCycle = 0;
                _cycle2 = 0;
                _cycle = cycle[_round];
            }
            else{
                _remainingTokenNextCycle = _token.sub(_remainingTokenCurrentCycle);
                _cycle2 = _cycle.add(1);
                if(_cycle2 >= 2){
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
            if(_token <= _remroundTokenCurrent){
                _remroundTokenCurrent = _token;
                _round1 = _round;
                _remroundTokenNext = 0;
                _round2 = 0;
            }else{
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
        (uint256 PreviousRound,uint256 roundTokenCurrent,uint256 nextRound,uint256 roundTokenNext) = checkRound(_token,_round);
        if(roundTokenCurrent > 0){
            uint256[] memory currentDetails = new uint256[](4);
            (currentDetails[0],currentDetails[1],currentDetails[2],currentDetails[3])
            = CheckCycle(roundTokenCurrent, PreviousRound,_cycle);
            TotalCurrentPrice = currentDetails[1].mul(_price);
            TotalCurrentPrice = TotalCurrentPrice.div(1e18);
            if(currentDetails[3] > 0 ){
            uint256 nextPrice = _price.add(tokenPriceIncreament);
            TotalCurrentPrice1 = currentDetails[3].mul(nextPrice);
            TotalCurrentPrice1 = TotalCurrentPrice1.div(1e18);
            }
        }
        if(roundTokenNext > 0){
            uint256[] memory nextDetails = new uint256[](4);
            _price = fixedPrice;
            _cycle = 0; 
            (nextDetails[0],nextDetails[1],nextDetails[2],nextDetails[3])
            = CheckCycle(roundTokenNext, nextRound,_cycle);
            TotalNextPrice = nextDetails[1].mul(_price);
            TotalNextPrice = TotalNextPrice.div(1e18);
            if(nextDetails[3] > 0){
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