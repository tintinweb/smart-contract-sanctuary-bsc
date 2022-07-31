/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
            address sender,
            address recipient,
            uint256 amount
    ) external returns (bool);

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

        function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

        library SafeMathInt {
        int256 private constant MIN_INT256 = int256(1) << 255;
        int256 private constant MAX_INT256 = ~(int256(1) << 255);

        /**
         * @dev Multiplies two int256 variables and fails on overflow.
         */
        function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
        }

        /**
         * @dev Division of two int256 variables and fails on overflow.
         */
        function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
        }

        /**
         * @dev Subtracts two int256 variables and fails on overflow.
         */
        function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
        }

        /**
         * @dev Adds two int256 variables and fails on overflow.
         */
        function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
        }

        /**
         * @dev Converts to absolute value, and fails on overflow.
         */
        function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
        }


        function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
        }
        }

        library SafeMathUint {
        function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
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

        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

        constructor() {
        _transferOwnership(_msgSender());
        }

        function owner() public view virtual returns (address) {
        return _owner;
        }

        modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
        }

        function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
        }

        function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
        }

        function getTime() public view returns (uint256) {
        return block.timestamp;
        }

        function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
        }
        }


        contract IDO is Ownable{
        using SafeMath for uint256;

        mapping(address=>uint256) public investors;
        mapping(address=>uint256) public investorsUsdt;
        mapping(address=>uint256) public bossMembers;
        address[] public investorAddrs;
        mapping(address=>address) public boss;
        address private _idoWallet = 0xB988F861A670310614091450897fE60378f1adD2;
        address private _usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
        IERC20 usdtToken = IERC20(_usdtAddress);
        //当前阶段
        uint256 public currentLevelUsdt ;
        //一阶段
        uint256 public oneLevelUsdt = 1 * 10 ** 18;

        //二阶段
        uint256 public twoLevelUsdt = 2 * 10 ** 18;
        //IDO 5LOVE
        uint256 public returnedTokenAmount = 5 * 10 ** 18;
      
        //1000*25 + 1000*31  私募总量
        uint256 public maxUsdts;

          //邀请费率
        uint256 public inviteReward = 10;

        // 代币合约地址
        address public returnedTokenAddress;

        address public marketWallet;

        bool public idoEnd = false;

        constructor(){
        marketWallet = 0xB988F861A670310614091450897fE60378f1adD2;
        investors[marketWallet] = 1;
        currentLevelUsdt =  oneLevelUsdt;
        maxUsdts = (1000 * oneLevelUsdt + 1000 * twoLevelUsdt) * 10 ** 18;
        }

        function setLevelUsedt(uint256  _oneLevelUsdt,uint256 _twoLevelUsdt) external  onlyOwner{
                oneLevelUsdt = _oneLevelUsdt;
                twoLevelUsdt = _twoLevelUsdt;
                currentLevelUsdt  = oneLevelUsdt;
                maxUsdts =  (1000 * oneLevelUsdt + 1000 * twoLevelUsdt) * 10 ** 18;
        }
        function setMarketWallet(address _maketWallet) external onlyOwner {
        marketWallet = _maketWallet;
        }
        function setIdoWallet(address _iWallet) external onlyOwner {
        _idoWallet = _iWallet;
        }
        function setMaxUsdts(uint256 _maxUsdts) external onlyOwner {
        maxUsdts = _maxUsdts;
        }
        function setInvestorReward(uint256 _iReward) external onlyOwner {
        inviteReward = _iReward;
        }
        function setRewardTokenAmount(uint256 _iRewardAmount) external onlyOwner {
        returnedTokenAmount = _iRewardAmount;
        }

        function setTokenAddress(address _tokenAddress) external onlyOwner {
        returnedTokenAddress = _tokenAddress;
        }

        function getInvestors() external view returns(address[] memory){
        return investorAddrs;
        }

        event invest(address indexed newAddress);

        function balanceOfToken(address _user) external view returns(uint256){
        return investors[_user];
        }
        function myInvestor(address _user) external view returns(uint256){
        return investorsUsdt[_user];
        }
        function myTeam(address _user) external view returns(uint256){
        return bossMembers[_user];
        }

        uint256 private unlocked = 1;
        modifier lock() {
        require(unlocked == 1, "Fstswap: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
        }

        function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
        size := extcodesize(account)
        }
        return size > 0;
        }

        function withDrawToken() external {
        require(idoEnd, "IDO is not end");
        require(!isContract(msg.sender), "invest only for wallet address ");
        require(investors[msg.sender] > 0, " Zero token ");

        IERC20(returnedTokenAddress).approve(msg.sender, investors[msg.sender]);
        uint256 withdrawValue = investors[msg.sender];
        investors[msg.sender] = 0;
        IERC20(returnedTokenAddress).transfer(msg.sender, withdrawValue);

        }

        function withDrawUsdt() external onlyOwner{
        if (address(this).balance > 0) {
        payable(msg.sender).transfer(address(this).balance);
        }
        }
        function withDrawLeftToken() external onlyOwner{
        IERC20(returnedTokenAddress).approve(msg.sender, IERC20(returnedTokenAddress).balanceOf(address(this)));
        IERC20(returnedTokenAddress).transfer(msg.sender, IERC20(returnedTokenAddress).balanceOf(address(this)));
        }

        function setEndStatus(bool end) external onlyOwner {
        idoEnd = end;
        }

        function setMaxIDO(uint256 _maxUsdts) external onlyOwner{
        maxUsdts = _maxUsdts;
        }

        function investIDO(address _boss) external payable lock {
        //默认一阶段
        currentLevelUsdt =  oneLevelUsdt;
        //二阶段 
        if(address(this).balance >= oneLevelUsdt * 1000  &&   address(this).balance <  maxUsdts  ){
        currentLevelUsdt =  twoLevelUsdt;
        }
       // console.log("received %s's Usdt is %d", msg.sender, msg.value);
        require(!idoEnd, "IDO is just ended");
        require(msg.value == currentLevelUsdt, "Wrong ido Usdt amount!");
        require(_boss!= address(0), "Empty boss!");
        require(investors[_boss] > 0, "Invalid invitor");
        require(_boss != msg.sender, "Invalid invitor");
        require(investors[msg.sender] == 0, "Already invested!");
        require(!isContract(msg.sender), "invest only for wallet address ");
        require(address(this).balance <= maxUsdts, "IDO ended");


        uint256 balance = usdtToken.balanceOf(msg.sender);
        require(balance >= currentLevelUsdt,"Insufficient account balance");


        investors[msg.sender] += returnedTokenAmount;
        investorsUsdt[msg.sender] += currentLevelUsdt;
        bossMembers[_boss] += 1;
        investorAddrs.push(msg.sender);

        boss[msg.sender] = _boss;
        // distribute the reward 
        usdtToken.transferFrom(msg.sender, _boss, currentLevelUsdt.mul(inviteReward).div(100));
        usdtToken.transferFrom(msg.sender, _idoWallet, currentLevelUsdt.mul(100 - inviteReward).div(100));
        // payable(_boss).transfer(msg.value.mul(inviteReward).div(100));
        // payable(_idoWallet).transfer(msg.value.mul(100 - inviteReward).div(100));
        emit invest(msg.sender);
        }
        }