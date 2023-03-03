/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y) 
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) 
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }
    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }
}


/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }


    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract LuckyKeys is Auth {
    using SafeMath for *;
    using Calcs for uint256;
        
    LuckyInterface public LuckyToken;
    DiviesInterface public Divies;

    string constant public name = "Luckys Keys Game";
    string constant public symbol = "LKY";
    uint256 constant private rndInit_ = 4 hours;                
    uint256 constant private rndInc_ = 30 seconds;              
    uint256 constant private rndMax_ = 24 hours;    
    uint256 constant private rndEnd_ = 182 days;            
    
    bool internal locked;

    uint256 public rID_;    
    uint256 public potKeyHoldersPerc = 25; 
    uint256 public potTokenHoldersPerc = 15; 
    uint256 public potWinPerc = 40; 
    uint256 public potDevPerc = 3; 
    uint256 public potMarkPerc = 3; 
    uint256 public potTokenBBPerc = 4;
    uint256 public affPerc = 10; 
    uint256 endGameKeyReq = 25000000000000000000000000;
    uint256 minTokenBalance = 300000000000000000000;
    address devFeeReceiver; 
    address marketingFeeReceiver;
    address tokenBuybackFeeReciever;

    mapping (address => datasets.Player) public plyr_;  
    mapping (address => mapping (uint256 => datasets.PlayerRounds)) public plyrRnds_;    
    mapping (uint256 => datasets.Round) public round_;   


    event buyCoreEvent(address indexed from, uint256 ethSpent, uint256 keysBought);
    event withdrawEvent(address indexed from, uint256 ethWithdrawn);
    event roundEndEvent(address indexed from, uint256 roundID,address winnerAddy,uint256 potAmount,uint256 winnerAmount,
                        uint256 keyHolderAmount,uint256 tokenHolderAmount,uint256 marketingAmount, uint256 devAmount, 
                        uint256 tokenBuyBackAmount, uint256 nextPotAmount);


    constructor(address _luckyToken,address _diviesAddy)Auth(msg.sender) {
        devFeeReceiver = msg.sender; 
        marketingFeeReceiver = msg.sender; 
        tokenBuybackFeeReciever = msg.sender;
        LuckyToken = LuckyInterface(_luckyToken);
        Divies = DiviesInterface(_diviesAddy);
        }

    modifier isActivated() {
        require(activated_ == true, "its not ready yet.  check ?eta in discord"); 
        _;
    }
   
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    
    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 1000000000, "pocket lint: not a valid currency");
        require(_eth <= 100000000000000000000000, "no vitalik, no");
        _;    
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function emergencyBuy()
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {   
        buyCore(msg.sender, plyr_[msg.sender].laff,false);
    }
    
    function buyXaddr(address affAddy)
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        
        
        address _affAddy;
     
        if (affAddy == address(0) || affAddy == msg.sender)
        {
          
            _affAddy = plyr_[msg.sender].laff;
        
        } else {
       
            _affAddy = affAddy;
            
            if (_affAddy != plyr_[msg.sender].laff)
            {
    
                plyr_[msg.sender].laff = _affAddy;
            }
        }
        
        buyCore(msg.sender, _affAddy,false);
    }


    function devDeposit()
        isActivated()
        public
        payable
        authorized
    {
        
        buyCore(msg.sender, address(0),true);
    }
    
    
    function withdraw()
        isActivated()
        isHuman()
        noReentrant()
        public
    {
        uint256 _rID = rID_;
        
        uint256 _now = block.timestamp;
        
        uint256 _eth;

        if (_now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != address(0) || _now > round_[_rID].forceEnd && round_[_rID].ended == false && round_[_rID].plyr != address(0))
        {
            
            round_[_rID].ended = true;
            endRound();
            
            _eth = withdrawEarnings(msg.sender);
            
            if (_eth > 0){
                payable(msg.sender).transfer(_eth);
                emit withdrawEvent(msg.sender,_eth);   
            }
            
        } else {
            _eth = withdrawEarnings(msg.sender); 
            
            if (_eth > 0){
                payable(msg.sender).transfer(_eth);
                emit withdrawEvent(msg.sender,_eth);
            }
        }
    }
    
    
    function getTimeLeft()
        public
        view
        returns(uint256)
    {
        uint256 _rID = rID_;
        
        uint256 _now = block.timestamp;

        uint256 _end = round_[_rID].end < round_[_rID].forceEnd ? round_[_rID].end : round_[_rID].forceEnd;

        if (_now < _end)
                return( _end.sub(_now) );
        else
            return(0);
    }
    
 
    function getPlayerVaults(address playerAddy)
        public
        view
        returns(uint256 ,uint256, uint256)
    {
        uint256 _rID = rID_;
        
        if (block.timestamp > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != address(0) || block.timestamp > round_[_rID].forceEnd && round_[_rID].ended == false && round_[_rID].plyr != address(0))
        {
            if (round_[_rID].plyr == playerAddy)
            {
                return
                (
                    (plyr_[playerAddy].win).add( ((round_[_rID].pot).mul(potWinPerc)) / 100 ),
                    (plyr_[playerAddy].gen).add(  getPlayerVaultsHelper(playerAddy, _rID).sub(plyrRnds_[playerAddy][_rID].mask)   ),
                    plyr_[playerAddy].aff
                );
            } else {
                return
                (
                    plyr_[playerAddy].win,
                    (plyr_[playerAddy].gen).add(  getPlayerVaultsHelper(playerAddy, _rID).sub(plyrRnds_[playerAddy][_rID].mask)  ),
                    plyr_[playerAddy].aff
                );
            }
            
        } else {
            return
            (
                plyr_[playerAddy].win,
                (plyr_[playerAddy].gen).add(calcUnMaskedEarnings(playerAddy, plyr_[playerAddy].lrnd)),
                plyr_[playerAddy].aff
            );
        }
    }
    
    function getPlayerVaultsHelper(address playerAddy, uint256 _rID)
        private
        view
        returns(uint256)
    {
        return(  ((((round_[_rID].mask).add(((((round_[_rID].pot).mul(potKeyHoldersPerc)) / 100).mul(1000000000000000000)) / (round_[_rID].keys))).mul(plyrRnds_[playerAddy][_rID].keys)) / 1000000000000000000)  );
    }
    
    function getCurrentRoundInfo()
        public
        view
        returns(uint256, uint256, uint256, uint256, uint256, address, uint256)
    {
        uint256 _rID = rID_;
        
        return
        (
            _rID,                           
            round_[_rID].keys,              
            round_[_rID].end,              
            round_[_rID].strt,              
            round_[_rID].pot,               
            round_[_rID].plyr,
            round_[_rID].forceEnd
        );
    }


    function getPlayerInfoByAddress(address playerAddy)
        public 
        view 
        returns(uint256, uint256, uint256, uint256, uint256)
    {
        uint256 _rID = rID_;
        address _addr = playerAddy;

        if (_addr == address(0))
        {
            _addr == msg.sender;
        }
        
        return
        (
            plyrRnds_[_addr][_rID].keys,         
            plyr_[_addr].win,                   
            (plyr_[_addr].gen).add(calcUnMaskedEarnings(_addr, plyr_[_addr].lrnd)),     
            plyr_[_addr].aff,                   
            plyrRnds_[_addr][_rID].eth           
        );
    }

    function isTokenHolder(address playerAddy) public view returns (bool){
        bool tokenHolder = false;
        if(LuckyToken.getTotalShares(playerAddy) >= minTokenBalance){
            tokenHolder = true;
        }
        return tokenHolder;
    }

    function setFeeReceivers(address _marketingFeeReceiver, address _devFeeReceiver, address _tokenBuybackFeeReciever) external authorized {
        marketingFeeReceiver = _marketingFeeReceiver;
        devFeeReceiver = _devFeeReceiver;
        tokenBuybackFeeReciever = _tokenBuybackFeeReciever;
    }

    

    function buyCore(address playerAddy, address affAddy,bool deposit)
        private
    {
        uint256 _rID = rID_;

        bool isDeposit = deposit;
        
        uint256 _now = block.timestamp;
        bool refund = false;
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == address(0))) && (_now <= round_[_rID].forceEnd || (_now > round_[_rID].forceEnd && round_[_rID].plyr == address(0)))) 
        {
            if(canIBuyKeys(playerAddy) || isDeposit ){
                core(_rID, playerAddy, msg.value, affAddy,isDeposit);
            } else{
                refund = true;
            }
             
        } else {
            if (_now > round_[_rID].end && round_[_rID].ended == false || _now > round_[_rID].forceEnd && round_[_rID].ended == false ) 
            {
                round_[_rID].ended = true;
                endRound(); 
            }
            refund = true; 
        }

        if(refund){
            plyr_[playerAddy].gen = plyr_[playerAddy].gen.add(msg.value);
        }
    }
    

    function core(uint256 _rID, address playerAddy, uint256 _eth, address affAddy,bool _deposit)
        private
    {
        if (plyrRnds_[playerAddy][_rID].keys == 0){
            managePlayer(playerAddy);
        }
        
        if (_eth > 1000000000) 
        {
            uint256 _keys;

            if(round_[_rID].keys >= endGameKeyReq){
                _keys = endGameKeysRec(endEth(round_[_rID].keys),_eth);
            } else {
               _keys = (round_[_rID].eth).keysRec(_eth);
            }
            
            if (_keys >= 1000000000000000000)
            {
                updateTimer(_keys, _rID,_deposit);

                if (round_[_rID].plyr != playerAddy && _deposit == false){
                    round_[_rID].plyr = playerAddy;  
                }
            }
                
            plyrRnds_[playerAddy][_rID].keys = _keys.add(plyrRnds_[playerAddy][_rID].keys);
            plyrRnds_[playerAddy][_rID].eth = _eth.add(plyrRnds_[playerAddy][_rID].eth);
                
            round_[_rID].keys = _keys.add(round_[_rID].keys);
            round_[_rID].eth = _eth.add(round_[_rID].eth);
        
            distributeExternal(playerAddy, _eth, affAddy);
            distributeInternal(_rID, playerAddy, _eth, _keys);
                
            emit buyCoreEvent(msg.sender,_eth,_keys);
        }
            
        
    }

    function calcUnMaskedEarnings(address playerAddy, uint256 _rIDlast)
        private
        view
        returns(uint256)
    {
        return(  (((round_[_rIDlast].mask).mul(plyrRnds_[playerAddy][_rIDlast].keys)) / (1000000000000000000)).sub(plyrRnds_[playerAddy][_rIDlast].mask)  );
    }

    
    function iWantXKeys(uint256 _keys)
        public
        view
        returns(uint256)
    {
        uint256 _rID = rID_;
        
        uint256 _now = block.timestamp;
        
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == address(0))) && (_now <= round_[_rID].forceEnd || (_now > round_[_rID].forceEnd && round_[_rID].plyr == address(0)))){
            uint256 _eth = round_[_rID].keys >= endGameKeyReq ? endGameEthRec(round_[_rID].keys.add(_keys),_keys)  : (round_[_rID].keys.add(_keys)).ethRec(_keys);
            return ( _eth );
        }
        else{ 
            return ( (_keys).eth() );
        }
    }

    function managePlayer(address playerAddy)
        private
    {

        if (plyr_[playerAddy].lrnd != 0)
            updateGenVault(playerAddy, plyr_[playerAddy].lrnd);

        plyr_[playerAddy].lrnd = rID_;
        
        return();
    }
    
    function canIBuyKeys (address playerAddy)public view returns(bool){
        uint256 _now = block.timestamp;
        uint256 _rID = rID_;
        
        if( _now < round_[_rID].strt + 3600 && isTokenHolder(playerAddy) || _now > round_[_rID].strt + 3600){
            return true;
        } else {
            return false;
        }
       
    }

    function distributePotExternal(uint256 _pot) private {
        uint256 _mark = (_pot.mul(potMarkPerc)) / 100;
        uint256 _bb = (_pot.mul(potTokenBBPerc)) / 100;

         //pay devs
        (bool devsuccess, ) = devFeeReceiver.call{value:_mark}("");
        require(devsuccess, "Transfer failed.");
        //pay mark
        (bool marksuccess, ) = marketingFeeReceiver.call{value:_mark}("");
        require(marksuccess, "Transfer failed.");
        //pay tokenBB
        (bool bbsuccess, ) = tokenBuybackFeeReciever.call{value:_bb}("");
        require(bbsuccess, "Transfer failed.");
    }

    function endRound()
        private
    {
        uint256 _rID = rID_;
        
        address winnerAddy = round_[_rID].plyr;
        
        uint256 _pot = round_[_rID].pot;
        
        uint256 _win = (_pot.mul(potWinPerc)) / 100;
        uint256 _gen = (_pot.mul(potKeyHoldersPerc)) / 100;
        uint256 _tok = (_pot.mul(potTokenHoldersPerc)) / 100;
        uint256 _res = (_pot.mul(affPerc)) / 100;
        uint256 _mark = (_pot.mul(potMarkPerc)) / 100;
        uint256 _bb = (_pot.mul(potTokenBBPerc)) / 100;
        
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        uint256 _dust = _gen.sub((_ppt.mul(round_[_rID].keys)) / 1000000000000000000);
        if (_dust > 0)
        {
            _gen = _gen.sub(_dust);
            _res = _res.add(_dust);
        }
        
        plyr_[winnerAddy].win = _win.add(plyr_[winnerAddy].win);

        round_[_rID].mask = _ppt.add(round_[_rID].mask);

        distributePotExternal(_pot);
        
        if (_tok > 0)
            Divies.deposit{ value: _tok }();
        
        emit roundEndEvent(address(0),_rID,winnerAddy,_pot,_win,_gen,_tok,_mark,_mark,_bb,_res);

        rID_++;
        _rID++;
        round_[_rID].strt = block.timestamp;
        round_[_rID].end = block.timestamp.add(rndInit_);
        round_[_rID].forceEnd = block.timestamp.add(rndEnd_);
        round_[_rID].pot = _res;
        
        return();
    }
    

    function updateGenVault(address playerAddy, uint256 _rIDlast)
        private 
    {
        uint256 _earnings = calcUnMaskedEarnings(playerAddy, _rIDlast);
        if (_earnings > 0)
        {
            plyr_[playerAddy].gen = _earnings.add(plyr_[playerAddy].gen);
            plyrRnds_[playerAddy][_rIDlast].mask = _earnings.add(plyrRnds_[playerAddy][_rIDlast].mask);
        }
    }
    
    function updateTimer(uint256 _keys, uint256 _rID,bool deposit)
        private
    {
        if(deposit == false){
            uint256 _now = block.timestamp;
            
            uint256 _newTime;
            if (_now > round_[_rID].end && round_[_rID].plyr == address(0) || _now > round_[_rID].forceEnd && round_[_rID].plyr == address(0))
                _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
            else
                _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round_[_rID].end);
            
            if (_newTime < (rndMax_).add(_now))
                round_[_rID].end = _newTime;
            else
                round_[_rID].end = rndMax_.add(_now);
        }
    }
    

    function distributeExternal(address playerAddy, uint256 _eth, address affAddy)
        private
    {
        uint256 _dev = _eth.mul(potDevPerc).div(100); 
        uint256 _mark = _eth.mul(potMarkPerc).div(100); 
       
        uint256 _totalTokenBB;
        uint256 _tok;
        
        uint256 _aff = _eth.mul(affPerc).div(100);
        uint256 _tokenBB = _eth.mul(potTokenBBPerc).div(100); 

        payable(marketingFeeReceiver).transfer(_mark);
        payable(devFeeReceiver).transfer(_dev);

        if (affAddy != playerAddy && affAddy != address(0)) {
            plyr_[affAddy].aff = _aff.add(plyr_[affAddy].aff);
            _totalTokenBB = _tokenBB;
        } else {
            _totalTokenBB = _aff.add(_tokenBB);
        }
        
        payable(tokenBuybackFeeReciever).transfer(_totalTokenBB);

        _tok = _tok.add((_eth.mul(potTokenHoldersPerc)) / (100));
        if (_tok > 0)
        {
            Divies.deposit{ value: _tok }();
        }

        return();
    }
    

    function distributeInternal(uint256 _rID, address playerAddy, uint256 _eth, uint256 _keys)
        private
    {

        uint256 _gen = (_eth.mul(potKeyHoldersPerc)) / 100;
        
        _eth = _eth.sub(((_eth.mul(35)) / 100));

        uint256 _pot = _eth.sub(_gen);

        uint256 _dust = updateMasks(_rID, playerAddy, _gen, _keys);
        if (_dust > 0)
            _gen = _gen.sub(_dust);

        round_[_rID].pot = _pot.add(_dust).add(round_[_rID].pot);
        
        return();
    }


    function updateMasks(uint256 _rID, address playerAddy, uint256 _gen, uint256 _keys)
        private
        returns(uint256)
    {

        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        round_[_rID].mask = _ppt.add(round_[_rID].mask);
            

        uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
        plyrRnds_[playerAddy][_rID].mask = (((round_[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds_[playerAddy][_rID].mask);
        

        return(_gen.sub((_ppt.mul(round_[_rID].keys)) / (1000000000000000000)));
    }

    function withdrawEarnings(address playerAddy)
        private
        returns(uint256)
    {

        updateGenVault(playerAddy, plyr_[playerAddy].lrnd);
        

        uint256 _earnings = (plyr_[playerAddy].win).add(plyr_[playerAddy].gen).add(plyr_[playerAddy].aff);
        if (_earnings > 0)
        {
            plyr_[playerAddy].win = 0;
            plyr_[playerAddy].gen = 0;
            plyr_[playerAddy].aff = 0;
        }

        return(_earnings);
    }

    function setMinTokenHolder(uint256 amount) external authorized {
        minTokenBalance = amount * 10 **18;
    }
    

    bool public activated_ = false;
    function activate()
        public authorized
    {   
        require(activated_ == false, "game already activated");
        
        activated_ = true;
        
        rID_ = 1;
        round_[1].strt = block.timestamp;
        round_[1].end = block.timestamp.add(rndInit_);
        round_[1].forceEnd = block.timestamp.add(rndEnd_);
    }

    /// shoving end game calcs down here cause wont work in lib???
    function endGameKeysRec(uint256 _curEth, uint256 _newEth)
        internal
        pure
        returns (uint256)
    {
        return(endKeys((_curEth).add(_newEth)).sub(endKeys(_curEth)));
    }
    
    function endGameEthRec(uint256 _curKeys, uint256 _sellKeys)
        internal
        pure
        returns (uint256)
    {
        return((endEth(_curKeys)).sub(endEth(_curKeys.sub(_sellKeys))));
    }

    function endKeys(uint256 _eth) 
        internal
        pure
        returns(uint256)
    {
        return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000000);

    }
    
    function endEth(uint256 _keys) 
        internal
        pure
        returns(uint256)  
    {
        return ((78125000000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());

    }

}


library datasets {
    struct Player {
        address addr;   // player address
        uint256 win;    // winnings vault
        uint256 gen;    // general vault
        uint256 aff;    // affiliate vault
        uint256 lrnd;   // last round played
        address laff;   // last affiliate addy used
    }
    struct PlayerRounds {
        uint256 eth;    // eth player has added to round (used for eth limiter)
        uint256 keys;   // keys
        uint256 mask;   // player mask 
    }
    struct Round {
        address plyr;   // address of player in lead
        uint256 end;    // time ends/ended
        bool ended;     // has round end function been ran
        uint256 strt;   // time round started
        uint256 keys;   // keys
        uint256 eth;    // total eth in
        uint256 pot;    // eth to pot (during round) / final amount paid to winner (after round ends)
        uint256 mask;   // global mask
        uint256 forceEnd;
    }
}



//==============================================================================
//  |  _      _ _ | _  .
//  |<(/_\/  (_(_||(_  .
//=======/======================================================================
library Calcs {
    using SafeMath for *;
 
    function keysRec(uint256 _curEth, uint256 _newEth)
        internal
        pure
        returns (uint256)
    {
        return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));
    }
    
    function ethRec(uint256 _curKeys, uint256 _sellKeys)
        internal
        pure
        returns (uint256)
    {
        return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
    }

    function keys(uint256 _eth) 
        internal
        pure
        returns(uint256)
    {
         return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
    }
    
    function eth(uint256 _keys) 
        internal
        pure
        returns(uint256)  
    {
        return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
    }

}


interface DiviesInterface {
    function deposit() external payable;
}

interface LuckyInterface{
    function getTotalShares(address account) external view returns (uint256);
}