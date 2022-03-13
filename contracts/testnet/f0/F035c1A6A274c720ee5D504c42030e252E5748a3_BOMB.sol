/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IFinalRewardPool {  
  function transferEth(uint256 amount) external returns(bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        _previousOwner = _owner;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 0 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}


contract BOMB is Ownable {

    modifier onlyBagholders() {
        require(myTokens() > 0);
        _;
    }
    
    // only people with profits
    modifier onlyStronghands() {
        require(myDividends(true) > 0);
        _;
    }
    
    // administrators can:
    // -> change the name of the contract
    // -> change the name of the token
    // -> change the PoS difficulty (How many tokens it costs to hold a masternode, in case it gets crazy high later)
    // they CANNOT:
    // -> take funds
    // -> disable withdrawals
    // -> kill the contract
    // -> change the price of tokens
    /*modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrators[keccak256(abi.encode(_customerAddress))]);
        _;
    }*/
    
    
    // ensures that the first tokens in the contract will be equally distributed
    // meaning, no divine dump will be ever possible
    // result: healthy longevity.
    /*modifier antiEarlyWhale(uint256 _amountOfEthereum){
        address _customerAddress = msg.sender;
        
        // are we still in the vulnerable phase?
        // if so, enact anti early whale protocol 
        if( onlyAmbassadors && ((totalEthereumBalance() - _amountOfEthereum) <= ambassadorQuota_ )){
            require(
                (tokenBalanceLedger_[_customerAddress] + _amountOfEthereum) <= ambassadorMaxPurchase_
            );
            
            // updated the accumulated quota    
            ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfEthereum);
        
            // execute
            _;
        } else {
            // in case the ether count drops low, the ambassador phase won't reinitiate
            onlyAmbassadors = false;
            _;
        }
        
    }*/
    
    
    /*==============================
    =            EVENTS            =
    ==============================*/
    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted
    );
    
    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethereumEarned
    );
    
    event onReinvestment(
        address indexed customerAddress,
        uint256 ethereumReinvested,
        uint256 tokensMinted
    );
    
    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );
    
    // ERC20
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );
    
    
    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    string public name = "Peace No War";
    string public symbol = "BOMB";
    uint8 constant public decimals = 18;
    uint8  public dividendFee_ = 13;
    uint8  public dividendFeeToPool_ = 2;
    uint8  public dividendFeeToInvite_ = 3;
    uint8  public dividendFeeToInvite2_ = 2;
    uint8  public dividendFeeToInvite3_ = 1;
    uint8  public dividendFeeToOwner_ = 1;
    address public FinalRewardPool;
    uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;
    uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;
    uint256 constant internal magnitude = 2**64;
    
    // proof of stake (defaults at 100 tokens)
    //uint256 public stakingRequirement = 100e18;
    
    // ambassador program
   // mapping(address => bool) internal ambassadors_;
    //uint256 constant internal ambassadorMaxPurchase_ = 1 ether;
    //uint256 constant internal ambassadorQuota_ = 20 ether;
    
    //空投奖励 每次奖励多少给到用户 奖池的百分比
    uint8 public rewardInvitePool = 50;//奖励50
    function setrewardinvitepool(uint8 _rewardInvitePool) public onlyOwner{
            rewardInvitePool = _rewardInvitePool;
    }
    //邀请的记录
    struct inviteLog{
        address invite;
        uint16 inum;
    }

    mapping(address => inviteLog) public inviteLogs;//记录所有邀请用户
    address[] public maxInviteUser;//记录最大邀请用户
    mapping(address => bool) inviteExit;//记录最大邀请用户是否存在

    //设置一个增加邀请的动作
    function setMyInvite(address inviteaddress) public{
        require(inviteLogs[inviteaddress].invite != address(0),"the invite man no exit");
        require(inviteLogs[_msgSender()].invite == address(0),"Have been set invite man already");
        require(_msgSender() != inviteaddress,"Can not set myself");
        inviteLogs[_msgSender()].invite = inviteaddress;
        if(inviteaddress!=owner()){
            inviteLogs[inviteaddress].inum += 1;
            checkMaxInviteUser(inviteaddress);
        }
    }
    function checkMaxInviteUser(address inviteaddress) internal{
        if(inviteExit[inviteaddress] != true){
            if(maxInviteUser.length<20 && inviteLogs[inviteaddress].inum>0){
                maxInviteUser.push(inviteaddress);
                inviteExit[inviteaddress] = true;
            }else{
                for(uint8 i=1;i<maxInviteUser.length;i++){
                    address tempAddress = maxInviteUser[i];
                    if(inviteLogs[tempAddress].inum<inviteLogs[inviteaddress].inum){//需要替换
                        maxInviteUser[i] = inviteaddress;
                        delete inviteExit[tempAddress];
                        inviteExit[inviteaddress] = true;
                    }
                }
            }
        } 
    }

    
   /*================================
    =            DATASETS            =
    ================================*/
    // amount of shares for each address (scaled number)
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => int256) internal payoutsTo_;
   // mapping(address => uint256) internal ambassadorAccumulatedQuota_;
    uint256 internal tokenSupply_ = 0;
    uint256 internal profitPerShare_;
    
    //administrator list (see above on what they can do)
    //mapping(bytes32 => bool) public administrators;
    
    // when this is set to true, only ambassadors can purchase tokens (this prevents a whale premine, it ensures a fairly distributed upper pyramid)
    //bool public onlyAmbassadors = true;

    /*owner set*/
    function setdividendfee(uint8 _dividendFee) public onlyOwner{
            dividendFee_ = _dividendFee;
    }
    function setdividendfeetopool(uint8 _dividendFeeToPool) public onlyOwner{
            dividendFeeToPool_ = _dividendFeeToPool;
    }
    function setdividendfeetoinvite(uint8 _dividendFeeToInvite) public onlyOwner{
            dividendFeeToInvite_ = _dividendFeeToInvite;
    }
    function setdividendfeetoinvite2(uint8 _dividendFeeToInvite2) public onlyOwner{
            dividendFeeToInvite2_ = _dividendFeeToInvite2;
    }
    function setdividendfeetoinvite3(uint8 _dividendFeeToInvite3) public onlyOwner{
            dividendFeeToInvite3_ = _dividendFeeToInvite3;
    }
    function setdividendfeetoowner_(uint8 _dividendFeeToOwner) public onlyOwner{
            dividendFeeToOwner_ = _dividendFeeToOwner;
    }


    /*针对用户进行空投，空投的目的是以对应的池子里面的内容多余多少的时候开启空投 讲池子里面的
    bnb兑换成token，然后进行空投，空投的数量为多少 则即为多少
    */
    uint256 public freeTokenThisWeek=0;//每次空投的数量 Tokenairdrop  币空投

    function sendFreeToken(address toMan,uint256 _freeToken) public onlyOwner {
        require(inviteExit[toMan]==true,"Can not get reward");
        require(freeTokenThisWeek>=_freeToken,"Tocken reward not enough");
        tokenBalanceLedger_[toMan] = SafeMath.add(tokenBalanceLedger_[toMan], _freeToken);
        payoutsTo_[toMan] += (int256) (profitPerShare_ * _freeToken);
    }
    //从最终的奖池里面每周抽出3分之一的奖励 回购token，并且把token分发给邀请的前10名用户
/*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    function purchaseTokensFromPool()
        onlyOwner
        external
    {
        uint256 _incomingEthereum =SafeMath.div(SafeMath.mul(address(FinalRewardPool).balance,rewardInvitePool),100);

        require(_incomingEthereum>=1e18,"Need min 1e18 demand");

        bool transferResult = IFinalRewardPool(FinalRewardPool).transferEth(_incomingEthereum);
        //转入eth
        require(transferResult==true,"Transfer eth fail");
        
        uint256 _dividends = SafeMath.div(SafeMath.mul(_incomingEthereum, dividendFee_),100);
        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        //uint256 _fee = _dividends * magnitude;
 
        // no point in continuing execution if OP is a poorfag russian hacker
        // prevents overflow in the case that the pyramid somehow magically starts being used by everyone in the world
        // (or hackers)
        // and yes we know that the safemath function automatically rules out the "greater then" equasion.
        require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));
        
        // we can't give people infinite ethereum
        if(tokenSupply_ > 0){
            
            // add tokens to the pool
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
 
            // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder
            profitPerShare_ += (_dividends * magnitude / (tokenSupply_));
            
            // calculate the amount of tokens the customer receives over his purchase 
            //_fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));
        
        } else {
            // add tokens to the pool
            tokenSupply_ = _amountOfTokens;
        }
        
        // update circulating supply & the ledger address for the customer
       // tokenBalanceLedger_[FinalRewardPool] = SafeMath.add(tokenBalanceLedger_[FinalRewardPool], _amountOfTokens);
        
        // Tells the contract that the buyer doesn't deserve dividends for the tokens before they owned them;
        //really i know you think you do but you don't
        //int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
        //payoutsTo_[FinalRewardPool] += _updatedPayouts;
        
        // fire event
        //emit onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy);
        //if( _amountOfTokens>0){
            setfreetokenthisweek(_amountOfTokens);
        //}
    }

    function setfreetokenthisweek(uint256 _amountOfTokens) public onlyOwner{
        freeTokenThisWeek=0;
        require(_amountOfTokens>0,"No free token set");
        freeTokenThisWeek = _amountOfTokens;
    }

    bool public isLockToSale=true;

    function unlockSale() public onlyOwner {
        require(isLockToSale==true);
        isLockToSale = false;
    }

    /*=======================================
    =            PUBLIC FUNCTIONS            =
    =======================================*/
    /*
    * -- APPLICATION ENTRY POINTS --  
    */
    constructor(){
        address _FinalRewardPool =0x19282506424bbE0a723F1977969D4991d24eB826;
        FinalRewardPool = _FinalRewardPool;
        //将自己创始人写入邀请码之中
        inviteLogs[owner()].invite = owner();
        inviteLogs[owner()].inum = 2**16-1;
        maxInviteUser.push(owner());
        inviteExit[owner()] = true;
    }
    
     
    /**
     * Converts all incoming ethereum to tokens for the caller, and passes down the referral addy (if any)
     */
    function buy()
        public
        payable
        returns(uint256)
    {
        require(inviteLogs[msg.sender].invite!=address(0),"Need set invite man first");
        uint256 buyTockens = purchaseTokens(msg.value,true);
        return buyTockens;
    }
    
    /**
     * Fallback function to handle ethereum that was send straight to the contract
     * Unfortunately we cannot use a referral address this way.
     */
    receive() external payable {
        //purchaseTokens(msg.value, address(0));
    }
    
    /**
     * Converts all of caller's dividends to tokens.
     */
    function reinvest()
        onlyStronghands()
        public
    {
        // fetch dividends
        uint256 _dividends = myDividends(false); // retrieve ref. bonus later in the code
        
        // pay out the dividends virtually
        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
        
        // retrieve ref. bonus
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;
        
        // dispatch a buy order with the virtualized "withdrawn dividends"
        uint256 _tokens = purchaseTokens(_dividends, false);
        
        // fire event
        emit onReinvestment(_customerAddress, _dividends, _tokens);
    }
    
    /**
     * Alias of sell() and withdraw().
     */
    function exit()
        public
    {
        require(isLockToSale==false,"The time is not up yet, please hold on");
        // get token count for caller & sell them all
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if(_tokens > 0) sell(_tokens);
        
        // lambo delivery service
        withdraw();
    }

    /**
     * Withdraws all of the callers earnings.
     */
    function withdraw()
        onlyStronghands()
        public
    {
        require(isLockToSale==false,"The time is not up yet, please hold on");
        // setup data
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(false); // get ref. bonus later in the code  不包含邀请的时候产生的分红
        
        // update dividend tracker
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
        
        // add ref. bonus
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;
        
        // lambo delivery service
        payable(_customerAddress).transfer(_dividends);
        
        // fire event
        emit onWithdraw(_customerAddress, _dividends);
    }
    
    /**
     * Liquifies tokens to ethereum.
     */
    function sell(uint256 _amountOfTokens)
        onlyBagholders()
        public
    {
        require(isLockToSale==false,"The time is not up yet, please hold on");
        // setup data
        address _customerAddress = msg.sender;
        // russian hackers BTFO
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens);
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_),100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

        //去掉团队奖励 以及池子奖励
        {
            uint256 _oneBonus = SafeMath.div(_dividends, dividendFee_);
            uint256 _ownerBonus = SafeMath.mul(_oneBonus, dividendFeeToOwner_);
            if(_ownerBonus>0){
                payable(owner()).transfer(_ownerBonus);
            }
            uint256 _poolBonus = SafeMath.mul(_oneBonus, dividendFeeToPool_);
            if(_poolBonus>0){
                payable(FinalRewardPool).transfer(_poolBonus);
            }
            _dividends = SafeMath.sub(_dividends,_ownerBonus);
            _dividends = SafeMath.sub(_dividends,_poolBonus);
        }
        
        // burn the sold tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
        
        // update dividends tracker
        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
        payoutsTo_[_customerAddress] -= _updatedPayouts;       
        
        // dividing by zero is a bad idea
        if (tokenSupply_ > 0) {
            // update the amount of dividends per token
            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
        }
        
        // fire event
        emit onTokenSell(_customerAddress, _tokens, _taxedEthereum);
    }
    
    
    /**
     * Transfer tokens from the caller to a new holder.
     * Remember, there's a 10% fee here as well.
     */
    function transfer(address _toAddress, uint256 _amountOfTokens)
        onlyBagholders()
        public
        returns(bool)
    {
        require(isLockToSale==false,"The time is not up yet, please hold on");
        // setup
        address _customerAddress = msg.sender;
        
        // make sure we have the requested tokens
        // also disables transfers until ambassador phase is over
        // ( we dont want whale premines )
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        
        // withdraw all outstanding dividends first
        if(myDividends(true) > 0) withdraw();
        
        // liquify 10% of the tokens that are transfered
        // these are dispersed to shareholders
        uint256 _tokenFee = SafeMath.div(SafeMath.mul(_amountOfTokens, dividendFee_),100);
        uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);
        uint256 _dividends = tokensToEthereum_(_tokenFee);

        //去掉团队奖励 以及池子奖励
        {
            uint256 _oneBonus = SafeMath.div(_dividends, dividendFee_);
            uint256 _ownerBonus = SafeMath.mul(_oneBonus, dividendFeeToOwner_);
            if(_ownerBonus>0){
                payable(owner()).transfer(_ownerBonus);
            }
            uint256 _poolBonus = SafeMath.mul(_oneBonus, dividendFeeToPool_);
            if(_poolBonus>0){
                payable(FinalRewardPool).transfer(_poolBonus);
            }
            _dividends = SafeMath.sub(_dividends,_ownerBonus);
            _dividends = SafeMath.sub(_dividends,_poolBonus);
        }
        
        // burn the fee tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);

        // exchange tokens
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);
        
        // update dividend trackers
        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _taxedTokens);
        
        // disperse dividends among holders
        profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
        
        // fire event
        emit Transfer(_customerAddress, _toAddress, _taxedTokens);
        
        // ERC20
        return true;
       
    }
    
    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/
    /**
     * In case the amassador quota is not met, the administrator can manually disable the ambassador phase.
     */
    /*function disableInitialStage()
        onlyOwner
        public
    {
        onlyAmbassadors = false;
    }*/
    
    /**
     * In case one of us dies, we need to replace ourselves.
     */
    /*function setAdministrator(bytes32 _identifier, bool _status)
        onlyOwner
        public
    {
        administrators[_identifier] = _status;
    }*/
    
    /**
     * Precautionary measures in case we need to adjust the masternode rate.
     */
    /*function setStakingRequirement(uint256 _amountOfTokens)
        onlyOwner
        public
    {
        stakingRequirement = _amountOfTokens;
    }*/
    
    /**
     * If we want to rebrand, we can.
     */
    /*function setName(string memory _name)
        onlyOwner
        public
    {
        name = _name;
    }
    */
    /**
     * If we want to rebrand, we can.
     */
    function setSymbol(string memory _symbol)
        onlyOwner
        public
    {
        symbol = _symbol;
    }

    
    /*----------  HELPERS AND CALCULATORS  ----------*/
    /**
     * Method to view the current Ethereum stored in the contract
     * Example: totalEthereumBalance()
     */
    function totalEthereumBalance()
        public
        view
        returns(uint)
    {
        return address(this).balance;
    }
    
    /**
     * Retrieve the total token supply.
     */
    function totalSupply()
        public
        view
        returns(uint256)
    {
        return tokenSupply_;
    }
    
    /**
     * Retrieve the tokens owned by the caller.
     */
    function myTokens()
        public
        view
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }
    
    /**
     * Retrieve the dividends owned by the caller.
     * If `_includeReferralBonus` is to to 1/true, the referral bonus will be included in the calculations.
     * The reason for this, is that in the frontend, we will want to get the total divs (global + ref)
     * But in the internal calculations, we want them separate. 
     */ 
    function myDividends(bool _includeReferralBonus) 
        public 
        view 
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
    }
    
    /**
     * Retrieve the token balance of any single address.
     */
    function balanceOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
        return tokenBalanceLedger_[_customerAddress];
    }
    
    /**
     * Retrieve the dividend balance of any single address.
     */
    function dividendsOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
        return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }
    
    /**
     * Return the buy price of 1 individual token.
     */
    function sellPrice() 
        public 
        view 
        returns(uint256)
    {
        // our calculation relies on the token supply, so we need supply. Doh.
        if(tokenSupply_ == 0){
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_),100);
            uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
            return _taxedEthereum;
        }
    }
    
    /**
     * Return the sell price of 1 individual token.
     */
    function buyPrice() 
        public 
        view 
        returns(uint256)
    {
        // our calculation relies on the token supply, so we need supply. Doh.
        if(tokenSupply_ == 0){
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_),100 );
            uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);
            return _taxedEthereum;
        }
    }
    
    /**
     * Function for the frontend to dynamically retrieve the price scaling of buy orders.
     */
    function calculateTokensReceived(uint256 _ethereumToSpend) 
        public 
        view 
        returns(uint256)
    {
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereumToSpend, dividendFee_),100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        
        return _amountOfTokens;
    }
    
    /**
     * Function for the frontend to dynamically retrieve the price scaling of sell orders.
     */
    function calculateEthereumReceived(uint256 _tokensToSell) 
        public 
        view 
        returns(uint256)
    {
        require(_tokensToSell <= tokenSupply_,'No enough token supply');
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_),100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
        return _taxedEthereum;
    }

    function getMyInviteAddress() public view returns(address[3] memory inviteAddress) {
        address customAddress = msg.sender;
        if(inviteLogs[customAddress].invite != address(0)){
            inviteAddress[0] = inviteLogs[customAddress].invite;

            address customAddress1 = inviteLogs[customAddress].invite;
            if(inviteLogs[customAddress1].invite != address(0) && customAddress1 != owner()){
                inviteAddress[1] = inviteLogs[customAddress1].invite;

                address customAddress2 = inviteLogs[customAddress1].invite;
                if(inviteLogs[customAddress2].invite != address(0) && customAddress2!=owner()){
                    inviteAddress[2] = inviteLogs[customAddress2].invite;
                }
            }
        }
        return inviteAddress;
    }

    uint256 public bondteam=0;
    uint256 public bondmy=0;
    uint256 public bondall=0;
    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    function purchaseTokens(uint256 _incomingEthereum, bool _referredBy)
        internal
        returns(uint256)
    {
        // data setup
        address _customerAddress = msg.sender;
        uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingEthereum,dividendFee_),100);
        uint256 _dividends =_undividedDividends;

        {
            
            if(_referredBy){
                uint256 _referralBonus=0;
                address[3] memory inviteUsers = getMyInviteAddress();
                if(inviteUsers[0]!=address(0)){
                    _referralBonus = SafeMath.div(SafeMath.mul(_incomingEthereum, dividendFeeToInvite_),100);
                    referralBalance_[inviteUsers[0]] = SafeMath.add(referralBalance_[inviteUsers[0]], _referralBonus);
                    _dividends = SafeMath.sub(_dividends, _referralBonus);
                }
                if(inviteUsers[1]!=address(0)){
                    _referralBonus=0;
                    _referralBonus =SafeMath.div(SafeMath.mul(_incomingEthereum,dividendFeeToInvite2_),100);
                    referralBalance_[inviteUsers[1]] = SafeMath.add(referralBalance_[inviteUsers[1]], _referralBonus);
                    _dividends = SafeMath.sub(_dividends, _referralBonus);
                }
                if(inviteUsers[2]!=address(0)){
                    _referralBonus=0;
                    _referralBonus = SafeMath.div(SafeMath.mul(_incomingEthereum, dividendFeeToInvite3_),100);
                    referralBalance_[inviteUsers[2]] =SafeMath.add(referralBalance_[inviteUsers[2]], _referralBonus);
                    _dividends = SafeMath.sub(_dividends, _referralBonus);
                }
                bondall = _incomingEthereum;
                uint256 _ownerBonus = SafeMath.div(SafeMath.mul(_incomingEthereum,dividendFeeToOwner_),100);
                if(_ownerBonus>0){
                    bondmy = _ownerBonus;
                    payable(owner()).transfer(_ownerBonus);
                    _dividends = SafeMath.sub(_dividends, _ownerBonus);
                }
                uint256 _poolBonus = SafeMath.div(SafeMath.mul(_incomingEthereum,dividendFeeToPool_),100);
                if(_poolBonus>0){
                    bondteam = _poolBonus;
                    payable(FinalRewardPool).transfer(_poolBonus);
                     _dividends = SafeMath.sub(_dividends, _poolBonus);
                }
            }
        }

        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        uint256 _fee = _dividends * magnitude;

        require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));
        
        int256 _updatedPayouts = 0;
        // we can't give people infinite ethereum
        if(tokenSupply_ > 0){
            
            // add tokens to the pool
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
 
            // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder
            profitPerShare_ += (_dividends * magnitude / (tokenSupply_));
            
            // calculate the amount of tokens the customer receives over his purchase 
            _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));
        
            _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
        } else {
            // add tokens to the pool
            tokenSupply_ = _amountOfTokens;
        }
        
        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        
        // Tells the contract that the buyer doesn't deserve dividends for the tokens before they owned them;
        //really i know you think you do but you don't
        
        
        payoutsTo_[_customerAddress] += _updatedPayouts;
        
        // fire event
        emit onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens);
        

        return _amountOfTokens;
    }

    /**
     * Calculate Token price based on an amount of incoming ethereum
     * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
     */
    function ethereumToTokens_(uint256 _ethereum)
        internal
        view
        returns(uint256)
    {
        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived = 
         (
            (
                // underflow attempts BTFO
                SafeMath.sub(
                    (sqrt
                        (
                            (_tokenPriceInitial**2)
                            +
                            (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))
                            +
                            (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
                            +
                            (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
                        )
                    ), _tokenPriceInitial
                )
            )/(tokenPriceIncremental_)
        )-(tokenSupply_)
        ;
  
        return _tokensReceived;
    }
    
    /**
     * Calculate token sell value.
     * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
     */
     function tokensToEthereum_(uint256 _tokens)
        internal
        view
        returns(uint256)
    {
        uint256 tokens_ = (_tokens + 1e18);
        uint256 _tokenSupply = (tokenSupply_ + 1e18);

        uint256 _etherReceived =0;
        uint256 subFa = (
                        (
                            tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
                        )-tokenPriceIncremental_
                    )*(tokens_ - 1e18);
        uint256 subSun = (tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2;
        if(subFa<subSun){
            return _etherReceived;
        }else{
            _etherReceived =SafeMath.sub(subFa,subSun);
            if(_etherReceived<1e18){
                _etherReceived = 0;
                return _etherReceived;
            }else{
                _etherReceived = _etherReceived/1e18;
            }
        }
        /*
        uint256 _etherReceived =
        (
            // underflow attempts BTFO
            SafeMath.sub(
                (
                    (
                        (
                            tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
                        )-tokenPriceIncremental_
                    )*(tokens_ - 1e18)
                ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
            )
        /1e18);*/
        return _etherReceived;
    }
/*
     function tokensMyToEthereum_(uint256 _tokens)
        public
    
        returns(uint256)
    {
        bondmy = _tokens;
        uint256 tokens_ = (_tokens + 1e18);
        
        uint256 _tokenSupply = (tokenSupply_ + 1e18);


        uint256 hong =  (
                        (
                            tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
                        )-tokenPriceIncremental_
                    )*(tokens_ - 1e18);
        uint256 jjj = (tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2;
        
        bondteam = hong;
        bondall = jjj;

        uint256 _etherReceived=0;
        if(hong>jjj){
            _etherReceived=1;
        }else{
            _etherReceived=2;
        }
        return _etherReceived;
    }
    */
    
    //This is where all your gas goes, sorry
    //Not sorry, you probably only paid 1 gwei
    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}