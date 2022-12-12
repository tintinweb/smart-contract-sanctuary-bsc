/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.17;

/**----------------------------------------*
    ███████ ██    ██    ███████ ██ ███████
    ██░░░██ ██   ███    ██░░░██ ██     ██
    ██░░░██ ██ ██ ██    █████   ██   ███  
    ██░░░██ ███   ██    ██░░░██ ██  ██     
    ███████ ██    ██    ███████ ██ ███████                                      
-------------------------------------------* OnBIZ.APP *--**/

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface BEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);

    function allowance(address tokenOwner, address spender)
        external
        view
        returns (uint256 remaining);

    function transfer(address to, uint256 tokens)
        external
        returns (bool success);

    function approve(address spender, uint256 tokens)
        external
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}


interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function getRoundData(uint80 _roundId) external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
        );

    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
        );
}

/*----------------------------------------*/
contract MonacoSYS is Context, Ownable {
    using SafeMath for uint256;
    AggregatorV3Interface internal priceFeed;

    struct User {
        address spon;
        uint256 f1;
        uint256 f1Act;
        uint256 totalGen;
        uint256 star;
        address[] f1StarAddr;
        
        uint256 totalInvest;
        uint256 totalInvestF1;
        uint256 totalInvestTree;

        uint256 wCom;
        uint256 totalIncome;
        uint256 totalWithdraw;
        uint256 checkPoint;
    }
   
    struct Invest {
        uint256 amount;
        uint256 depTime;
        bool isRun;
    }

    struct Profit {
        uint256 percent;
        uint256 time;
        address addr;
    }

    mapping(address => User) public users;
    mapping(address => uint256) public starNum;
    mapping(address => address[]) public refList;
    mapping(address => Invest[]) _investsOfUser;
    Profit[] internal _profitSetList;
    uint256 private _totalUsers;
    uint256 private _totalInvested;
    uint256 private _totalWithdrawn;

    event Register(address user, address referral);
    event UserInvest(address user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    BEP20 public token;
    address public topRefer;
    address private _admin;

    uint256 private constant baseDivider = 1000;
    uint256 private constant timeStep = 1 days;
    uint256 private minInvest = 1e18;
    uint256 private minWithdraw = 50e18;
    uint256[] investPacks = [100e18, 500e18, 5000e18, 30000e18];
    uint256[] comPerProfit = [50, 20, 10, 5, 2];
    

    constructor() {
        token = BEP20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee); //busd
        priceFeed = AggregatorV3Interface(0x9331b55D9830EF609A2aBCfAc0FBCE050A52fdEa);
        _admin = owner();
        topRefer = msg.sender;
        _profitSetList.push(Profit(500, block.timestamp, msg.sender));
        /** Network: BSC
        0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee BUSD Test
        0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 BUSD Main
        0x17308A18d4a50377A4E1C37baaD424360025C74D Test Aggregator: FIL/USD
        0xE5dbFD9003bFf9dF5feB2f4F445Ca00fb121fb83 Main Aggregator: FIL/USD
        0x9331b55D9830EF609A2aBCfAc0FBCE050A52fdEa Test Aggregator: BUSD/USD
        0xcBb98864Ef56E9042e7d2efef76141f15731B82f Main Aggregator: BUSD/USD
        */
    }
    function setPriceFeed(address _addContract) public onlyOwner {
        priceFeed = AggregatorV3Interface(_addContract);
    }
    function setToken(address _tokenContract) public onlyOwner {
        token = BEP20(_tokenContract);
    }
    modifier onlyAdmin() {
        require(_admin == _msgSender(), "Ownable: caller is not the Admin");
        _;
    }
    function setAdmin(address _addr) public onlyOwner {
        _admin = address(_addr);
    }
    function setInvestMin( uint256 _min) public onlyAdmin returns (uint256){
       return  minInvest = _min;
    }
    function setWithdrawMin( uint256 _min) public onlyAdmin returns (uint256){
       return  minWithdraw = _min;
    }

    //----------------------------------------
    function managerBNB() public onlyAdmin {
        require(address(this).balance > 0, "Balance need > 0!");
        payable(msg.sender).transfer(address(this).balance);
    }
    function managerToken() public onlyAdmin {
        uint256 _balance = token.balanceOf(address(this));
        require(_balance > 0, "Balance need > 0!");
        token.transferFrom(address(this), msg.sender, token.balanceOf(address(this)));
    }
    function getSiteInfo() public view returns (
            uint256 Users,
            uint256 TotalInvested,
            uint256 TotalWithdrawn,
            uint256 balanceOfCon
        ) {
        balanceOfCon = token.balanceOf(address(this));
        return (_totalUsers, _totalInvested, _totalWithdrawn, balanceOfCon);
    }
    
    //----------------------------------------
    function register(address _spon) external {
        require(users[_spon].totalInvest >= minInvest || _spon == topRefer, "invalid refer");
        User storage user = users[msg.sender];
        require(user.spon == address(0), "spon bonded");
        user.spon = _spon;
        users[_spon].f1++;
        refList[_spon].push(msg.sender);
        _totalGenUp(msg.sender);
        _totalUsers++;
        emit Register(msg.sender, _spon);
    }
    function invest(uint256 _iAmount) external {
        _invest(msg.sender, _iAmount);
        emit UserInvest(msg.sender, _iAmount);
    }
    function _invest(address _user, uint256 _amount) private {
        require(_amount >= minInvest  && _amount.mod(minInvest) == 0, "Minimum requirement required!");
        require(users[_user].spon != address(0), "register first");
        require(token.balanceOf(msg.sender) > 0, "TOKEN Balance need > 0!");

        uint256 _tokenPrice = getFilPrice();
        
        uint256 _tokenInvestAmount = _amount.mul(10**token.decimals()).div(_tokenPrice);
        require(_tokenInvestAmount > 0, "Invest amount need > 0!");
        
        if(_tokenInvestAmount > 0){
        token.transferFrom(msg.sender, address(this), _tokenInvestAmount);

        _investsOfUser[_user].push(Invest(_amount, block.timestamp, true));
        _totalInvested = _totalInvested.add(_amount);
        users[_user].totalInvest = users[_user].totalInvest.add(_amount);
        users[users[_user].spon].totalInvestF1 = users[users[_user].spon].totalInvestF1.add(_amount);
        users[users[_user].spon].f1Act++;
        _totalInvestTreeUp(_user, _amount);
        }   
    }

    //---------------------------
    function setProfitPercent(uint256 _percent) public onlyAdmin {
        _profitSetList.push(Profit(_percent, block.timestamp, msg.sender));
    }
    function getLastPercent() public view returns (Profit memory){
        require(_profitSetList.length > 0, "Percents list is empty!");
        // Profit storage _p = _profitSetList[_profitSetList.length - 1];
        return _profitSetList[_profitSetList.length - 1]; 
    }
    function getListPercent() public view returns ( Profit[] memory _lp){
        _lp = _profitSetList;
        return _lp;
    }
    function getAveragePercent(uint256 timeStart) public view returns (uint256){
        require(_profitSetList.length > 0, "Percents list is empty!");
        // First set;
        uint256 _totalDay = 0;
        uint256 _totalPercent = 0;
        uint256 _sTime = 0;
        if(_profitSetList.length > 1){
            for (uint i = 0; i < _profitSetList.length; i++) {
                if(_profitSetList[i].time >= timeStart){
                    _sTime = _profitSetList[i].time;
                    _totalPercent = _profitSetList[i].percent;

                    // Only run when length >= 2;
                    uint256 _timeSpace = (_profitSetList[i].time.sub(_sTime)).div(timeStep);
                    if(_timeSpace >= 1 && i < _profitSetList.length.sub(1)){
                        _totalDay += _timeSpace;
                        _totalPercent += _profitSetList[i.sub(1)].percent.mul(_timeSpace);

                        _sTime = _profitSetList[i].time;
                    }
                    
                    // Day / 1Set of last;
                    if(block.timestamp > _sTime && i == _profitSetList.length.sub(1)){
                        _timeSpace = (block.timestamp.sub(_sTime)).div(timeStep);
                        if(_timeSpace >= 1){
                            _totalDay += _timeSpace;
                            _totalPercent += _profitSetList[i].percent.mul(_timeSpace);
                        }else {
                            _totalPercent = _profitSetList[i].percent;
                        }
                    }
                }
            }
            return (_totalPercent.mul(baseDivider).div(_totalDay));
        }else {
            _totalPercent = _profitSetList[0].percent;
            return (_totalPercent.mul(baseDivider).div(1));
        }
    }
    function getFilPrice() public view returns (uint256){
        (,/*uint80 roundID*/ int price /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,,,) = priceFeed.latestRoundData();
        return uint256(price * 10**10);
    }

    //----------------------------------------
    function _totalGenUp(address _fromAdd) private {
        User storage u = users[_fromAdd];
        address upline = u.spon;
        if (upline != address(0)) {
            users[upline].totalGen++;
            _totalGenUp(upline);
        }
    }
    function _totalInvestTreeUp(address _fromAdd, uint256 _investAmount) private {
        User storage u = users[_fromAdd];
        address upline = u.spon;
        if (upline != address(0) && _investAmount > 0) {
            users[upline].totalInvestTree = users[upline].totalInvestTree.add(_investAmount);
            _checkStarAndUp(upline);
            _totalInvestTreeUp(upline, _investAmount);
        }
    }
    function _checkStarAndUp(address _addr) private returns (uint256 star){
        star = 0;
        if(users[_addr].star == 0){
            if(users[_addr].totalInvest >= minInvest && users[_addr].totalInvestTree >= 30000e18 && users[_addr].f1Act >= 5){
                star = 1;
                users[_addr].star = star;
                users[users[_addr].spon].f1StarAddr.push(_addr);
                starNum[_addr] = star;
            }
        }else {
            if(users[_addr].f1StarAddr.length > 0){
                uint256 s1;
                uint256 s2;
                uint256 s3;
                uint256 s4;
                uint256 s5;
                for (uint256 i = 0; i < users[_addr].f1StarAddr.length; i++) {
                   if(starNum[users[_addr].f1StarAddr[i]] ==1) s1++;
                   if(starNum[users[_addr].f1StarAddr[i]] ==2) s2++;
                   if(starNum[users[_addr].f1StarAddr[i]] ==3) s3++;
                   if(starNum[users[_addr].f1StarAddr[i]] ==4) s4++;
                   if(starNum[users[_addr].f1StarAddr[i]] ==5) s5++;
                }
                if(s1 == 3) star = 2;
                if(s2 == 3) star = 3;
                if(s3 == 3 && s2 == 1) star = 4;
                if(s4 == 3 && s3 == 1) star = 5;
            }
            users[_addr].star = star;
            starNum[_addr] = star;
        }
    }
    function _getPercentByGen(uint8 _gen)  private view returns(uint256 _p) {
        _p = 0;
        if(_gen == 1) _p = comPerProfit[0];
        if(_gen == 2) _p = comPerProfit[1];
        if(_gen >= 3 && _gen < 9) _p = comPerProfit[2];
        if(_gen >= 9 && _gen < 16) _p = comPerProfit[3];
        if(_gen >= 16 && _gen < 20) _p = comPerProfit[4];
    }
    function _getMaxGenBy(uint256 f1, uint256 v) private pure returns (uint8 _g) {
        _g = 0;
        if(f1 == 1) _g = 1;
        if(f1 == 2 && v >= 1000e18) _g = 2;
        if(f1 == 3 && v >= 5000e18) _g = 8;
        if(f1 == 4 && v >= 10000e18) _g = 15;
        if(f1 == 5 && v >= 10000e18) _g = 20;
    }
    function _comMatchingUpZip(uint256 _amount, address _fromAddr, uint8 _genOld) private view returns (uint256 _comAmount) {
        address upline = users[_fromAddr].spon;
        uint8 _gen = _genOld;
        uint8 _genZip = 0;
        if(users[upline].totalInvest >= minInvest && _genZip >= 1){
            _gen = _genOld + 1;
            uint8 _genMax = _getMaxGenBy(users[upline].f1Act, users[upline].totalInvestTree);
       
            uint256 _percentByGen = _getPercentByGen(_gen);
            _comAmount = _percentByGen.mul(_amount).div(100);

            if (_gen <= _genMax && _percentByGen > 0 && _comAmount > 0 && upline != address(0)) {
                users[upline].wCom.add(_comAmount);
                users[upline].totalIncome.add(_comAmount);
            }
        }else {
            _genZip++;
        }
         
        // Run Next gen up;
        if (_gen <= 20 && upline != address(0)){
            _comMatchingUpZip(_amount, upline, _gen);
        }
    }

    //----------------------------------------
    function _getUserInvestTotalAve(address uAddr) private view returns (uint256 totalAve) {
        require(users[uAddr].totalInvest > 0, "No investment yet!");
        uint256 _t = 0;
        for (uint256 i = 0; i < _investsOfUser[uAddr].length; i++) {
            if(_investsOfUser[uAddr][i].isRun){
                _t = _t.add(_investsOfUser[uAddr][i].amount);
            }
        }
        totalAve = _t.div(_investsOfUser[uAddr].length);
    }
    function getUserInvestNum(address _uAddr) public view returns (uint256) {
        return _investsOfUser[_uAddr].length;
    }
    function getUserInvest(address _uAddr) public view returns (Invest[] memory) {
       return _investsOfUser[_uAddr];
    }
    function getUserInvestTotal(address uAddr) public view returns (uint256) {
       return users[uAddr].totalInvest;
    }
    function getUserCheckpoint(address _addr) public view returns (uint256) {
        return users[_addr].checkPoint;
    }
    function getUserMaxOutCheck(address _addr) public view returns (uint256 _max){
        uint256 _tAve = _getUserInvestTotalAve(_addr);
        if(users[_addr].totalInvestF1 >= 1000e18){
            _max = _tAve.mul(250).div(100);
        }else {
            if(_tAve >= investPacks[0] && _tAve <= investPacks[1]){
            _max = _tAve.mul(150).div(100);
            }
            if(_tAve > investPacks[1] && _tAve <= investPacks[2]){
                _max = _tAve.mul(180).div(100);
            }
            if(_tAve > investPacks[2] && _tAve <= investPacks[3]){
                _max = _tAve.mul(200).div(100);
            }
        }
    }

    //----------------------------------------
    function withdrawProfit(uint256 fromTime) public {
        require(users[msg.sender].totalIncome <= getUserMaxOutCheck(msg.sender), "Request exceeds maxout!");
        uint256 _dayT = (block.timestamp.sub(fromTime)).div(timeStep);
        uint256  _percentAve = getAveragePercent(fromTime);
        uint256 _myInvestAve = _getUserInvestTotalAve(msg.sender);
        
        require(_dayT >= 0, "Number of day need > 0!");
        require(_myInvestAve >= 0, "There is no investment!");

        uint256 _profitTotal = _dayT.mul(_percentAve).mul(_myInvestAve).div(baseDivider);
        require(_profitTotal >= minWithdraw, "Requirement exceeds minimum allowed");
        // uint256 contractBalance = IBEP20(usdt).balanceOf(address(this));
        uint256 _contractBalance = token.balanceOf(address(this));
        require(_contractBalance > 0, "Balance of contract need > 0!");
        if (_contractBalance >= _profitTotal) {

            uint256 _tokenPrice = getFilPrice();
            token.transfer(msg.sender, _profitTotal.mul(10**token.decimals()).div(_tokenPrice));

            users[msg.sender].checkPoint = block.timestamp;
            users[msg.sender].totalIncome = users[msg.sender].totalIncome.add(_profitTotal);
            users[msg.sender].totalWithdraw = users[msg.sender].totalWithdraw.add(_profitTotal);
            _totalWithdrawn = _totalWithdrawn.add(_profitTotal);

            _comMatchingUpZip(_profitTotal, msg.sender, 0);

            emit Withdraw(msg.sender, _profitTotal);
        }
    }
    function withdrawCom(uint256 _amount) public {
        require(users[msg.sender].totalIncome <= getUserMaxOutCheck(msg.sender), "Request exceeds maxout!");
        require(_amount >= minWithdraw, "Requirement exceeds minimum allowed");
        uint256 _comW = users[msg.sender].wCom;
        require(_amount <= _comW, "Amount exceeds withdrawable");
        
        uint256 _tokenPrice = getFilPrice();
        token.transfer(msg.sender, _amount.mul(10**token.decimals()).div(_tokenPrice));

        users[msg.sender].totalWithdraw += _amount;
        _totalWithdrawn = _totalWithdrawn.add(_amount);
        
        emit Withdraw(msg.sender, _amount);
    }
}