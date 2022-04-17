// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './ERC20.sol';
import './IUniswapV2Router.sol';
contract crown127Token is ERC20 {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    uint256 public startTime;
    uint256 public swapTime;

    uint256 public _rateBase=10**4;
    uint256 public _totalFeeRate;
    address public _totalFeeAddress;
      //Black hole address
    address public _burnAddress = address(0x000000000000000000000000000000000000dEaD);
    uint256 public _burnFeeRate;
    address public _marketAddress;
    uint256 public _marketFeeRate;
    uint256 public _saleToAMMFeeRate;
    address public _fundAddress;
    //uint256 public _liquidityAddFeeRate;
    uint256 public _liquidityRemoveFeeRate;

    uint256 public _maxHoldAmount;
    uint256 public _maxSaleRate;
    
    mapping(address => uint256) public _liquidityAmounts;
    address[] public _liquidityUsers;

    mapping(address => bool) public _isLiquiding;
    mapping(address => bool) public _isExcludedFromFees;
    uint256 public _liquiditySum;
    mapping (address => bool) public _automatedMarketMakerPairs;
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    mapping(address => bool) public _partners;
    uint256[] public _partnerRates;
   

    mapping(address => address) private _inviter;
    uint256[] public _inviterRates;
    uint256 public _inviterFeeMinHoldAmount;
    constructor()  payable ERC20("crown token", "CROWN") {

            _totalFeeRate=1600;
            _burnFeeRate=200;
            _marketFeeRate=500;
            
        _inviterRates=[1600,500,200];    
        _partnerRates=[500];

        _totalFeeAddress=0x3c3022E3fFC55F48b45193f12320616856992AB6;
        excludeFromFees(_totalFeeAddress, true);
        
        _marketAddress=0x5aD372A63AEeA9A3538e94e77f73c23a766B00a1;
        _burnAddress=0xC65A3CeAff85CcDfAD3eD0afF0bCfe4aE2dfcFdc;
        _fundAddress=0x6ECd0Dbf7094B3B5b3A013343Bf8c6AAD8b4F48E;
        excludeFromFees(_marketAddress, true);
        excludeFromFees(_burnAddress, true);
        excludeFromFees(_fundAddress, true);

        _saleToAMMFeeRate=500;

        _maxHoldAmount=1000000000*(10**decimals());
        _maxSaleRate=9000;

        _liquidityRemoveFeeRate=_burnFeeRate.add(_countInviteFeeRate());
        //_liquidityAddFeeRate=_totalFeeRate;

        //startTime = block.timestamp.div(1 days).mul( 1 days);
        swapTime=block.timestamp.add(3 days);

        /*IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), 0x55d398326f99059fF775485246999027B3197955);//_uniswapV2Router.WETH()

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);*/

        setPower(owner(),8);
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);

        uint256 totalSupply = 1000000000000 * (10**decimals());
        _Cast(owner(), totalSupply);
    }

    function _setPartner(address user,bool enable) public {
        require(checkPower(_msgSender(),8),'no power');
        if(_partners[user] != enable){
            _partners[user] = enable;
        }
    }

    function _getInviter(address user) public view onlyOwner returns (address) {
        return _inviter[user];
    }
    function _getMyInviter() public view returns (address) {
        return _inviter[_msgSender()];
    }
    function _checkInviterLine(address f,address u) public view returns (bool) {
        require(checkPower(_msgSender(),8),'no power');
        return checkInviterLine(f,u);
    }
    function checkInviterLine(address f,address u) private view returns (bool) {
        if(_inviter[u]==address(0)) {
            return false;
        }
        else if(_inviter[u]==f){
            return true;
        }
        else
            return checkInviterLine(f,_inviter[u]);
    }
    function _setInviter(address f,address u) public onlyOwner {
        require(f != u, "inviter yourself"); 
        require(!checkInviterLine(u,f), "inviter is grandson"); 
         _inviter[u] =f;
    }
    function _setMyInviter(address addr) public returns(bool){
        require(addr!=address(0),'no inviter');
        require(addr != _msgSender(), "inviter yourself");       
        require(_inviter[_msgSender()] == address(0), "already set");     
        
        return setInviter(addr,_msgSender());
    }
    function setInviter(address f,address u) private returns(bool){
        if(checkInviterLine(f,u) || checkInviterLine(u,f) ){
            return false;
        }
         else
        {
            _inviter[u] =f;
            return true;
        }
    }
       
    function setFee(
        uint256[] memory feeRates_,
        uint256[] memory inviterRates_,
        uint256[] memory partnerRates_,
        uint256 saleToAMMFeeRate_,
        //uint256 liquidityAddFeeRate_,
        uint256 liquidityRemoveFeeRate_
    ) public onlyOwner {
        _totalFeeRate=feeRates_[0];
            _burnFeeRate=feeRates_[2];
            _marketFeeRate=feeRates_[1];

        _inviterRates=inviterRates_;    
        _partnerRates=partnerRates_;
        _saleToAMMFeeRate=saleToAMMFeeRate_;

        //_liquidityAddFeeRate=liquidityAddFeeRate_;
        _liquidityRemoveFeeRate=liquidityRemoveFeeRate_;
    }

    function setTime(uint256 start,uint256 swap) public onlyOwner{
        startTime=start;
        swapTime=swap;
    }

    
    function setMaxHoldAmount(uint256 amount) public onlyOwner {
        _maxHoldAmount=amount;
    }

    
    function setMaxSaleRate(uint256 rate) public onlyOwner {
        _maxSaleRate=rate;
    }

    function setInviterFeeMinHoldAmount(uint256 amount) public onlyOwner {
        _inviterFeeMinHoldAmount=amount;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        if(_isExcludedFromFees[account] != excluded){
            _isExcludedFromFees[account] = excluded;
            emit ExcludeFromFees(account, excluded);
        }
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setBurnAddress(address payable wallet) external onlyOwner{
        _burnAddress = wallet;
        excludeFromFees(_burnAddress, true);
    }

    function setMarketAddress(address payable wallet) external onlyOwner{
        _marketAddress = wallet;
        excludeFromFees(_marketAddress, true);
    }

    function setFundAddress(address payable wallet) external onlyOwner{
        _fundAddress = wallet;
        excludeFromFees(_fundAddress, true);
    }

    function setTotalFeeAddress(address payable wallet) external onlyOwner{
        if(wallet==address(0))
            _totalFeeAddress=address(this);
        else
            _totalFeeAddress=wallet;
        excludeFromFees(_totalFeeAddress, true);
    }


    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }


    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed");
        _setAutomatedMarketMakerPair(pair, value);
    }

     function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(_automatedMarketMakerPairs[pair] != value, "pair is already set to that value");
        _automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }
    function _setMeLiquiding(bool active) public {
        _isLiquiding[_msgSender()]=active;
    }
    function _setIsLiquiding(address user,bool active) public {
        require(checkPower(_msgSender(),8),'no power');
        _isLiquiding[user]=active;
    }
    function _setLiquidity(address user,uint256 amount) public {
        require(checkPower(_msgSender(),8),'no power');
        if(_liquidityAmounts[user]==0){
            bool exsit;
            for(uint256 i=0;i<_liquidityUsers.length;i++){
                if(_liquidityUsers[i]==user) exsit=true;
            }
            if(!exsit) _liquidityUsers.push(user);
            
        }
        _liquiditySum=_liquiditySum.add(amount).sub(_liquidityAmounts[user]);
        _liquidityAmounts[user]=amount;
    }

    function addLiquidity(address user,uint256 amount) private{
       if(_liquidityAmounts[user]==0){
            bool exsit;
            for(uint256 i=0;i<_liquidityUsers.length;i++){
                if(_liquidityUsers[i]==user) exsit=true;
            }
            if(!exsit) _liquidityUsers.push(user);
            
        }
        _liquiditySum=_liquiditySum.add(amount);
        _liquidityAmounts[user]=_liquidityAmounts[user].add(amount);
    }

    function _addLiquidity(address user,uint256 amount) public returns(uint256){
        require(user != address(0), "zero address");
        require(checkPower(_msgSender(),8),'no power');
        addLiquidity( user,amount);
        return _liquidityAmounts[user];
    }

    function subLiquidity(address user,uint256 amount) private{
        if(_liquidityAmounts[user]>=amount){
            _liquiditySum=_liquiditySum.sub(amount);
           _liquidityAmounts[user]=_liquidityAmounts[user].sub(amount);
        }      
    }

    function _subLiquidity(address user,uint256 amount) public returns(uint256){
        require(user != address(0), "zero address");
        require(checkPower(_msgSender(),8),'no power');
        subLiquidity(user,amount);
        return _liquidityAmounts[user];
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");
        require(amount > 0, "amount must be greater than zero");
        require(!checkPower(from,1),'sender has no power'); 
        require(!checkPower(to,2),'recipient has no power');
        require(block.timestamp>startTime,"not start time");

        if(_maxHoldAmount>0 && !_isExcludedFromFees[to] && !_automatedMarketMakerPairs[to])
            require(balanceOf(to).add(amount)<=_maxHoldAmount,' exceeds max hold amount');
        if(swapTime>0 ){
            if(_automatedMarketMakerPairs[from]  && !_isExcludedFromFees[to])
                require(block.timestamp>swapTime,"not swap");
            else if(_automatedMarketMakerPairs[to]  && !_isExcludedFromFees[from])
                require(block.timestamp>swapTime,"not swap");
        }
        uint256 totalFee;
        //uint256 sumFee;
        if(_totalFeeRate>0){

            if(_automatedMarketMakerPairs[from]){//buy remove
                if(_liquidityRemoveFeeRate>0 && _isLiquiding[to] && _liquiditySum>=amount && _liquidityAmounts[to]>=amount){//
                    subLiquidity(to,amount);
                    if(!_isExcludedFromFees[to]){
                        totalFee=amount.mul(_liquidityRemoveFeeRate).div(_rateBase);
                        super._transfer(from, _totalFeeAddress, totalFee);
                        takeInviteFee(amount,to,0,10);
                        takeBurnFee(amount);
                    }
                    _isLiquiding[to]=false;
                }
                else if(!_isExcludedFromFees[to]){
                    totalFee=amount.mul(_totalFeeRate).div(_rateBase);
                    super._transfer(from, _totalFeeAddress, totalFee);
                    takeMarketFee(amount);
                    takeInviteFee(amount,to,0,10);
                    takePartnerFee(amount,to,0,10,0);
                    takeBurnFee(amount);
                }
            }
            else if(_automatedMarketMakerPairs[to]){//sale add
                if(!_isExcludedFromFees[from]){
                    require(amount<=balanceOf(from).mul(_maxSaleRate).div(_rateBase),'sale exceeds limit');             
                    uint256 ammFee=amount.mul(_saleToAMMFeeRate).div(_rateBase);
                    //totalFee=totalFee.add(ammFee); 
                    super._transfer(_fundAddress, address(0x000000000000000000000000000000000000dEaD), ammFee);

                    totalFee=amount.mul(_totalFeeRate).div(_rateBase);
                    super._transfer(from, _totalFeeAddress, totalFee);
                    takeMarketFee(amount);
                    takeInviteFee(amount,from,0,10);
                    takePartnerFee(amount,from,0,10,0);
                    takeBurnFee(amount);
                }         
               
                           
            }
            else if(_isExcludedFromFees[from] || _isExcludedFromFees[to]){
                totalFee=0;
            }
            else{
                require(amount<=balanceOf(from).mul(_maxSaleRate).div(_rateBase),'sale exceeds limit');
                totalFee=amount.mul(_totalFeeRate).div(_rateBase);
                super._transfer(from, _totalFeeAddress, totalFee);
                takeMarketFee(amount);
                takeInviteFee(amount,to,0,10);
                takePartnerFee(amount,to,0,10,0);
                takeBurnFee(amount);
            }
            
        }
        super._transfer(from, to, amount.sub(totalFee));
        
        if(from!=owner() && !_automatedMarketMakerPairs[to] && _inviter[to] == address(0) && !_automatedMarketMakerPairs[from]) {
            setInviter(from,to);
        }
    }

    function takeBurnFee(uint256 amount) private returns(uint256 fee){
        if(_burnFeeRate>0 && amount>0 && _burnAddress!=address(0)){
            fee=amount.mul(_burnFeeRate).div(_rateBase);
            super._transfer(_totalFeeAddress, _burnAddress, fee);
        }
    }
    function takeMarketFee(uint256 amount) private returns(uint256 fee){
        if(_marketFeeRate>0 && amount>0 && _marketAddress!=address(0)){
            fee=amount.mul(_marketFeeRate).div(_rateBase);
            super._transfer(_totalFeeAddress, _marketAddress, fee);
        }
        takeLiquidityReward();
    }
    function takeLiquidityReward() private returns(uint256 sum){
        uint256 _marketSum=balanceOf(_marketAddress);
        if(_marketSum>0){
            for(uint256 i=0;i<_liquidityUsers.length;i++){
                if(_liquidityAmounts[_liquidityUsers[i]]>0){
                    uint256 reward=_marketSum.mul(_liquidityAmounts[_liquidityUsers[i]]).div(_liquiditySum);
                    super._transfer(_marketAddress, _liquidityUsers[i], reward);
                    sum=sum.add(reward);
                }
                
            }
        }
        
    }
    function _takeLiquidityReward() public returns(uint256 sum){
        require(checkPower(_msgSender(),8),'no power');
        return takeLiquidityReward();
    }
    function _countInviteFeeRate() public view returns(uint256 rate){
        for(uint256 i=0;i<_inviterRates.length;i++){
            rate=rate.add(_inviterRates[i]);
        }
    }
    function takeInviteFee(uint256 amount,address user,uint256 gen,uint256 maxGen) private returns(uint256 fee) {
        if(_inviter[user]!=address(0) && gen<maxGen && gen<_inviterRates.length){
            if(_inviterFeeMinHoldAmount==0 || (_inviterFeeMinHoldAmount>0 && balanceOf(_inviter[user])>=_inviterFeeMinHoldAmount)){
                fee=amount.mul(_inviterRates[gen]).div(_rateBase);
                super._transfer(_totalFeeAddress, _inviter[user], fee);
            }
                
             fee=fee.add(takeInviteFee(amount,_inviter[user],gen.add(1),maxGen));
        }
    }
    
    function takePartnerFee (uint256 amount,address user,uint256 gen,uint256 maxGen,uint256 idx) private returns(uint256 fee){
        if(_inviter[user]!=address(0) && gen<maxGen && idx<_partnerRates.length){
            if(_partners[_inviter[user]]){
                fee=amount.mul(_partnerRates[idx]).div(_rateBase);
                super._transfer(_totalFeeAddress, _inviter[user], fee);
                idx=idx.add(1);
            }
             
            fee=fee.add(takePartnerFee(amount,_inviter[user],gen.add(1),maxGen,idx));
        }
    }

}