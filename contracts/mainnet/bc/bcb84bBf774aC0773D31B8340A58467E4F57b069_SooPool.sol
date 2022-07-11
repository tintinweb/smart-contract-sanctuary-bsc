// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;
import "./Ownable.sol";
import "./IInvite.sol";
import "./SafeERC20.sol";
import "./ERC20.sol";
import "./PriceLibrary.sol";


contract SooPool is Ownable, ERC20 {

    using SafeMath for  uint256;
    using SafeERC20 for IERC20;

    constructor(
        address _usdt, 
        address _factory, 
        IERC20 _sootoken,
        uint256 _tokensPerBlock,
        uint256 _startBlock
    ) 
    public ERC20 ("SOO HashRate","SHR")
    {
        usdt = _usdt;
        factory = _factory;
        sooToken = _sootoken;
        tokensPerBlock = _tokensPerBlock;
        startBlock = _startBlock;
        lastUpdateBlock = _startBlock;
        initRate();
    }

    struct DepositInfo {
        uint256 amountA;
        uint256 amountB;
        uint256 amountR;
    }

    struct User {
        uint256 rewardPerTokenPaid;
        mapping(uint=>DepositInfo) deposits;
    }

    struct Pool {
        IERC20 tokenA;
        IERC20 tokenB; 
        bool status;
        uint256 maxWeight;
        uint256 totalAmount;
        uint256[3] minWeight;
        uint256[3] proportions;
    }

    // The block number when token mining starts.
    uint256 public startBlock;
    
    uint256 public feeA = 100;
    uint256 public feeB = 100;
    address public feeOwner = 0x76eE97027b77e35e5f3C97f486E6234b8AC0c4e8;
    
    uint256 internal DIVISOR = 100;
    uint256 internal BASE_INIT = 1000000;
    uint256 internal BASE_RATE = 5;

    uint256 constant internal REDUCE_PERIOD = 864000;
    uint256 public  THRESHOLD = 10000 * 10000 * 1e18 ;
    uint256 public lastUpdateBlock;
    uint256 public rewardPerTokenStored;


    // tokens created per block.
    uint256 public tokensPerBlock;

    address public factory;
    address public dead = 0x000000000000000000000000000000000000dEaD;

    address public usdt;
    IERC20  public sooToken;
    IERC20  public lpToken;

    IInvite public inviter;


    Pool[] public pools;
    mapping( uint => uint) public yinit;


    mapping(address => uint256) public rewards;
    mapping(address => User) public users;

    event Deposit(address indexed,uint,uint,uint,uint);
    event Withdraw(address indexed,uint,uint,uint,uint);
    event WithdrawReward(address index, uint );
    event UpdateReward(address index,uint);

  
    function initRate() internal {
        uint curRate = BASE_INIT;
        uint base = 100 ** 11;
        for(uint i = 0; i<17; i++) {
            yinit[i] = curRate;
            uint _yrate = yrate(i);
            uint _yLast = curRate.mul(
                _yrate**11
            )/base;
            curRate = _yLast.mul(yrate(i+1))/100;
        }

    }

    function yrate(uint _year) public view returns(uint256) {
        uint rate;
        
        if(_year>=BASE_RATE) {
            rate = 1;
        }else{
            rate = BASE_RATE-_year;
        }

        return 100 - rate;
    }

    function mrate(uint _month) public view returns (uint) {
        uint _year = _month/12;
        uint _yinitRate = yinit[_year];
        uint _yrate = yrate(_year);
        uint _mi = _month%12;
        return _yinitRate.mul(_yrate**_mi)/(100**_mi);
    }

    function mint(address _to, uint256 _amount) public override onlyMinter returns(bool) {
        _mint(_to,_amount);
    }


    function burn(address _to,uint _amount) public override {
        require(msg.sender == address(inviter), "forbidden operate");
        _burn(_to,_amount);
    }


   function setLpToken(IERC20 _lpToken) public onlyOwner {
        lpToken = _lpToken;
    }

   function setStartBlock(uint256 _startBlock) public onlyOwner {
        startBlock = _startBlock;
    }


    function setInviter(IInvite _inviter) public onlyOwner {
        inviter = _inviter;
    }

    function setTokenPerBlock(uint _tokensPerBlock) public onlyOwner {
        updateReward(address(0));
        tokensPerBlock = _tokensPerBlock;
    }

     function add(
        IERC20 _tokenA,
        IERC20 _tokenB,
        uint256 _maxWeight,
        uint256[3] memory _minWeight,
        uint256[3] memory _proportions
    ) public onlyOwner {    
        pools.push(
            Pool({
                tokenA: _tokenA,
                tokenB: _tokenB,
                status: true,
                totalAmount: 0,
                maxWeight: _maxWeight,
                minWeight: _minWeight,
                proportions: _proportions
            })
        );
    }

     function set(
        uint256 _pid,
        bool _status,
        uint256 _maxWeight,
        uint256[3] memory _minWeight,
        uint256[3] memory _proportions
    ) public onlyOwner {
        pools[_pid].status = _status;
        pools[_pid].maxWeight = _maxWeight;
        pools[_pid].minWeight = _minWeight;
        pools[_pid].proportions = _proportions;
    }

    function updateAndMint() internal returns( uint tincr, uint tactul, uint burned ) {
        (uint256 multiplier,uint256 curHash) = getMultiplier(lastUpdateBlock,block.number);
        tincr = multiplier.mul(tokensPerBlock).div(BASE_INIT);
       
        tactul = tincr.mul(curHash).div(THRESHOLD);
        burned = tincr.sub(tactul);
        if(burned>0) {
            sooToken.safeTransfer(dead,burned);
        }
    }

    function updateReward(address account) public returns(uint256) {
        require(block.number>startBlock,"not start");
        ( , uint tactul, ) = updateAndMint();
        rewardPerTokenStored = rewardPerToken(tactul);
        lastUpdateBlock = block.number;
        if (account != address(0)) {
            rewards[account] = 
                balanceOf(account)
                .mul(
                    rewardPerTokenStored.sub(users[account].rewardPerTokenPaid)
                )
                .div(1e18)
                .add(rewards[account]);

            users[account].rewardPerTokenPaid = rewardPerTokenStored;
        }
        emit UpdateReward(account, rewards[account]);
    }

    function rewardPerToken(uint tactul) public view returns(uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored.add(
            tactul.mul(1e18).div(totalSupply())
        );
    }

    function earned(address account) public view returns (uint256) {
        (uint256 multiplier,uint256 curHash) = getMultiplier(lastUpdateBlock,block.number);
        uint tactul = multiplier.mul(tokensPerBlock).mul(curHash).div(THRESHOLD).div(BASE_INIT);
        return
            balanceOf(account)
                .mul(
                    rewardPerToken(tactul).sub(users[account].rewardPerTokenPaid)
                )
                .div(1e18)
                .add(rewards[account]);
    }

    function poolEarned(address account, uint _pid) public view returns (uint256) {
        (uint256 multiplier,uint256 curHash) = getMultiplier(lastUpdateBlock,block.number);
        uint tactul = multiplier.mul(tokensPerBlock).mul(curHash).div(THRESHOLD).div(BASE_INIT);
        uint _balance = users[account].deposits[_pid].amountR;
        return
            _balance
                .mul(
                    rewardPerToken(tactul).sub(users[account].rewardPerTokenPaid)
                )
                .div(1e18);
    }

    function APR(uint _pid) public view returns(uint yopt, uint cic) {
        (uint unitToken,uint256 priceToken) = PriceLibrary.price(factory,address(sooToken),usdt);
        Pool storage pool = pools[_pid];
        (uint256 multiplier,) = getMultiplier(block.number,block.number+1);
        yopt = (28800*365*multiplier.mul(tokensPerBlock))* priceToken * pool.maxWeight/100/unitToken/BASE_INIT;
        cic = pool.totalAmount;
        uint _totalSupply = totalSupply();
        yopt = _totalSupply==0?0:yopt*cic/_totalSupply;
    }
    
    function deposit(uint256 _pid, uint256 _amountT, uint256 _rid) public  {
        Pool storage pool = pools[_pid];
        require(pool.status,"closed");
        updateReward(msg.sender);

         uint _amountA;
         uint _amountB;
         uint _amountR;
         
        
        ( _amountA, _amountB,_amountR) = transferAmount(pool,_rid,_amountT);
        
        
        if(address(inviter)!=address(0)) inviter.referReward(msg.sender,_amountR);

        users[msg.sender].deposits[_pid].amountA = users[msg.sender].deposits[_pid].amountA.add(_amountA);
        users[msg.sender].deposits[_pid].amountB = users[msg.sender].deposits[_pid].amountB.add(_amountB);
        users[msg.sender].deposits[_pid].amountR = users[msg.sender].deposits[_pid].amountR.add(_amountR);

        pool.totalAmount = pool.totalAmount.add(_amountR);

        _mint(msg.sender,_amountR);

        emit Deposit(msg.sender,_pid,_amountA,_amountB, _amountR);

    }

        uint public  unitAT; uint256 public  priceAT; 
        uint public  unitBT; uint256 public priceBT;
    
    function testPrice(address _token ) public onlyOwner {
            ( unitAT, priceAT) = PriceLibrary.price(factory, _token, usdt);
            (unitBT, priceBT) = (unitAT, priceAT*2);
    }

    
    function transferAmount(Pool storage pool,uint256 _rid,uint256 _amountT ) internal returns(uint256 _amountA,uint256 _amountB,uint256 _amountR) {
        uint unitA; uint256 priceA; 
        uint unitB; uint256 priceB;
        if(pool.tokenA == lpToken){
            ( unitA, priceA) = PriceLibrary.price(factory,address(sooToken),usdt);
            priceA = priceA * 2;
            (unitB, priceB) = (unitA, priceA);
        }else {
            ( unitA, priceA) = PriceLibrary.price(factory,address(pool.tokenA),usdt);
            ( unitB, priceB) = PriceLibrary.price(factory,address(pool.tokenB),usdt);    
        }
           
        _amountA = _amountT.mul(unitA).mul(pool.proportions[_rid]).div(priceA)/DIVISOR;
        _amountB = _amountT.mul(unitB).mul(uint(100).sub(pool.proportions[_rid])).div(priceB)/DIVISOR;
        
        pool.tokenA.safeTransferFrom(msg.sender,address(this),_amountA);
        pool.tokenB.safeTransferFrom(msg.sender,address(this),_amountB); 

        require(priceA!=0&&priceB!=0,"Invalid price");
        _amountR = _amountT*pool.maxWeight*pool.minWeight[_rid]/10000;
    }

    function withdraw(uint256 _pid) public  {
        withdrawReward();
        User storage user = users[msg.sender];
        uint256 amountA = user.deposits[_pid].amountA;
        uint256 amountB = user.deposits[_pid].amountB;
        uint256 amountR = user.deposits[_pid].amountR;


        user.deposits[_pid].amountA = 0;
        user.deposits[_pid].amountB = 0;
        user.deposits[_pid].amountR = 0;
        Pool storage pool = pools[_pid];
        pool.totalAmount = pool.totalAmount>amountR?pool.totalAmount-amountR:0;
        if(address(inviter)!=address(0)) inviter.redeemPower(msg.sender,amountR);
        
        uint256 amountFeeA = amountA.mul(feeA)/10000;
        uint256 amountFeeB = amountB.mul(feeB)/10000;

        pool.tokenA.safeTransfer(msg.sender, amountA.sub(amountFeeA));
        pool.tokenB.safeTransfer(msg.sender, amountB.sub(amountFeeB));
        
        transferFee(pool.tokenA,amountFeeA);
        transferFee(pool.tokenB,amountFeeB);
        
        _burn(msg.sender, amountR);

        emit Withdraw(msg.sender,_pid,amountA,amountB,amountR);
    }
    
    
    function transferFee(IERC20 _token, uint256 fee) internal {
        if(address(_token)==address(sooToken)) {
            _token.safeTransfer(dead,fee);
        }else{
            _token.safeTransfer(feeOwner,fee);
        }
    }

    function withdrawReward() public  {
        updateReward(msg.sender);
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            safeTokenTransfer(msg.sender,reward);
        }

        emit WithdrawReward(msg.sender,reward);
    }

    function emergencyWithdraw(uint256 _pid) public  {
        User storage user = users[msg.sender];
        uint256 amountA = user.deposits[_pid].amountA;
        uint256 amountB = user.deposits[_pid].amountB;
        uint256 amountR = user.deposits[_pid].amountR;
        user.deposits[_pid].amountA = 0;
        user.deposits[_pid].amountB = 0;
        user.deposits[_pid].amountR = 0;
        Pool storage pool = pools[_pid];
        pool.totalAmount = pool.totalAmount>amountR?pool.totalAmount-amountR:0;
        if(address(inviter)!=address(0)) inviter.redeemPower(msg.sender,amountR);
        uint256 amountFeeA = amountA.mul(feeA)/10000;
        uint256 amountFeeB = amountB.mul(feeB)/10000;

        pool.tokenA.safeTransfer(msg.sender, amountA.sub(amountFeeA));
        pool.tokenB.safeTransfer(msg.sender, amountB.sub(amountFeeB));
        
        transferFee(pool.tokenA,amountFeeA);
        transferFee(pool.tokenB,amountFeeB);
        _burn(msg.sender, amountR);
         rewards[msg.sender] = 0;
    }


    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256 multiplier,uint256 curHash)
    {

        uint fromPeriod = period(_from);
        uint toPeriod   = period(_to);
        uint _startBlock = _from;
        
        for(;fromPeriod<=toPeriod;fromPeriod++){
            uint _endBlock = bonusEndBlock(fromPeriod);
            if(_to<_endBlock) _endBlock = _to;
            multiplier = multiplier.add(
                _endBlock.sub(_startBlock).mul(mrate(fromPeriod))
            );
            _startBlock = _endBlock;
        }

        curHash = totalSupply();
        if(curHash>THRESHOLD){
            curHash = THRESHOLD;
        }
    }

    function getDeposit(address account,uint pid) public view returns(DepositInfo memory depositInfo) {
        return users[account].deposits[pid];
    }

    function getMinWeight(uint _pid) public view returns(uint[3] memory) {
        return pools[_pid].minWeight;
    }

    function getProportions(uint _pid) public view returns(uint[3] memory) {
        return pools[_pid].proportions;
    }

    function getPrice(address tokenA,address tokenB) public view returns(uint,uint) {
        return PriceLibrary.price(factory, tokenA, tokenB);
    }

    function getBalanceOfHash(address account) public view returns(uint poolHash,uint teamHash) {
            for(uint i = 0;i<pools.length;i++) {
                poolHash = poolHash.add(users[account].deposits[i].amountR);
            }
            teamHash = balanceOf(account).sub(poolHash);
    }


    function bonusEndBlock(uint256 _period) public view returns (uint) {
        return startBlock.add((_period+1).mul(REDUCE_PERIOD));
    }

    function period(uint256 blockNumber) public view returns (uint _period) {
        if(blockNumber>startBlock) {
            _period = (blockNumber-startBlock)/REDUCE_PERIOD;
        }
    }

    function poolLength() public view returns (uint256) {
        return pools.length;
    }

    // Safe Token transfer function, just in case if rounding error causes pool to not have enough Tokens.
    function safeTokenTransfer(address _to, uint256 _amount) internal {
        uint256 tBal = sooToken.balanceOf(address(this));
        if (_amount > tBal) {
            sooToken.transfer(_to, tBal);
        } else {
            sooToken.transfer(_to, _amount);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 ) internal  override virtual {
        if(from!=address(this)&&from!=address(inviter)) {
            updateReward(from);
        }
        if(to!=address(this)&&to!=address(inviter)) {
            updateReward(to);
        }
     }



    modifier onlyMinter() {
        require(isMinter(msg.sender), "caller is not the minter");
        _;
    }


    mapping (address => bool) public minters;
    function isMinter(address account) public view returns (bool) {
        return minters[account];
    }

    function addMinter (address _user) public onlyOwner {
        minters[_user] = true;
        emit AddMinter(_user);
    }

    function removeMinter (address _clearedUser) public onlyOwner {
        minters[_clearedUser] = false;
        emit RemoveMinter(_clearedUser);
    }

    event AddMinter(address indexed _user);

    event RemoveMinter(address indexed _user);

    function setTHRESHOLD(uint256 _THRESHOLD) public onlyOwner {
        THRESHOLD = _THRESHOLD;
    }




}