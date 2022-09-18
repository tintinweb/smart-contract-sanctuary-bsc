/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

pragma solidity 0.5.16;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
    
}


interface IPancakeRouter {
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract TdyIdo{
    
    using SafeMath for uint;
    
    address private admin;//管理员 
    uint private totalRaiseAmount;//总募集 
    uint private alreadyRaiseAmount;//已募集 
    
    //开启超募 
    bool private openExceed;
    //开关 
    bool private open;
    uint private usdtPrice = 16*10**18;
    uint private releaseTimeLength;
    
    address public USDT = address(0x55d398326f99059fF775485246999027B3197955);
    address public FWT = address(0xE45F702f38F99B3C3d8d8463C4C19C4D3CF89589);
    address public TDY = address(0x0c48A56F9cb75d32524803E329788bbc60E1bd58);
    address public USDT_FWT_PAIR_ADDRESS = address(0x3c1F80FD6D4e8b4171D0f90728097C8CeD37317f);
    address public PANCAKE_ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    
    address private usdtTo = address(0x94172b3f32db4439ad2146fBFd29F21c471Cf8E2);
    address private fwtTo;
    
    mapping(address => uint) raiseAmount;//用户自己募集数量 
    mapping(address => uint) raiseTime;//用户自己募集时间 
    mapping(address => uint) receiveAmount;//已领取
    
    mapping(address => uint) raiseCount;//管理员添加次数 
    mapping(address => mapping(uint => uint)) raiseAmounts;//每次管理员添加数量 
    mapping(address => mapping(uint => uint)) raiseTimes;//每次管理员添加时间 
    
    constructor() public {
        admin = msg.sender;
    }
    
    modifier isAdmin(){
        require(msg.sender == admin, 'FORBIDDEN');
        _;
    }
    
    modifier checkedRaise(uint amount){
        require(open, 'not open');
        require(releaseTimeLength > 0, 'NOT_SETTING_TIME_LENGTH');
        require(openExceed || alreadyRaiseAmount.add(amount) < totalRaiseAmount, 'Exceed total');
        _;
    }
    
    function calc(uint tdyAmount) public view returns(uint usdtAmountIn, uint fwtAmountIn){
        require(tdyAmount > 0, 'tdyAmount > 0');
        usdtAmountIn = tdyAmount*usdtPrice/10**18;
        (uint112 reserve0, uint112 reserve1,) = IPancakePair(USDT_FWT_PAIR_ADDRESS).getReserves();
        fwtAmountIn = reserve1 * usdtAmountIn*3/10 / reserve0;
    }
    
    function isUserRaise(address account) public view returns(bool success){
        success = raiseAmount[account] > 0;
    }
    
    function raise(uint tdyAmount) external checkedRaise(tdyAmount){
        require(!isUserRaise(msg.sender), 'Participated raise');
        (uint usdtAmountIn, uint fwtAmountIn) = calc(tdyAmount);
        IBEP20(USDT).transferFrom(msg.sender, usdtTo, usdtAmountIn);
        if (fwtTo == address(0)){
            IBEP20(FWT).transferFrom(msg.sender, address(this), fwtAmountIn);
            IBEP20(FWT).burn(fwtAmountIn);
        }else{
            IBEP20(FWT).transferFrom(msg.sender, fwtTo, fwtAmountIn);
        }
        raiseAmount[msg.sender] = tdyAmount;
        raiseTime[msg.sender] = block.timestamp;
        alreadyRaiseAmount = alreadyRaiseAmount.add(tdyAmount);
    }
    
    function getUserRaiseAmount(address account) external view returns (uint tAmount, uint releasedAmount){
        (tAmount, releasedAmount) = _getUserRaiseAmount(account);
    }
    
    function _getUserRaiseAmount(address account) internal view returns (uint tAmount, uint releasedAmount){
        tAmount = raiseAmount[account];
        uint rt = raiseTime[account];
        releasedAmount = block.timestamp.sub(rt) >= releaseTimeLength ? tAmount : tAmount.mul(block.timestamp.sub(rt)).div(releaseTimeLength);
    }
    
    function getAdminRaiseToUserAmount(address account) external view returns (uint){
        return raiseAmounts[account][0];
    }
    
    function getAdminRaiseToUserReleasedAmount(address account) external view returns(uint tAmount, uint releasedAmount){
        (tAmount, releasedAmount) = _getAdminRaiseToUserReleasedAmount(account);
    }
    
    function _getAdminRaiseToUserReleasedAmount(address account) internal view returns(uint tAmount, uint releasedAmount){
        uint count = raiseCount[account];
        tAmount = raiseAmounts[account][0];
        for (uint i = 0 ; i < count ; i++){
            uint ra = raiseAmounts[account][count+1];
            uint rt = raiseTimes[account][count+1];
            uint rar = block.timestamp.sub(rt) >= releaseTimeLength ? ra : ra.mul(block.timestamp.sub(rt)).div(releaseTimeLength);
            releasedAmount = releasedAmount.add(rar);
        }
    }
    
    function getReceiveTdy(address account) external view returns (uint){
        return receiveAmount[account];
    }
    
    function receiveTdy(uint amount) external{
        _receiveTdy(amount);
    }
    
    function _receiveTdy(uint amount) internal{
        (, uint releasedAmountUser) = _getUserRaiseAmount(msg.sender);
        (, uint releasedAmountAdmin) = _getAdminRaiseToUserReleasedAmount(msg.sender);
        uint releasedAmount = releasedAmountUser.add(releasedAmountAdmin);
        require(releasedAmount >= receiveAmount[msg.sender].add(amount), 'released amount Insufficient');
        IBEP20(TDY).transfer(msg.sender, amount);
        receiveAmount[msg.sender] = receiveAmount[msg.sender].add(amount);
    }
    function addRaise(address account, uint amount) external isAdmin{
        uint count = raiseCount[account] + 1;
        raiseCount[account] = count;
        raiseAmounts[account][0] = raiseAmounts[account][0].add(amount);
        raiseAmounts[account][count] = amount;
        raiseTimes[account][count] = block.timestamp;
    }
    
    function getAdmin() external view returns(address){
        return admin;
    }
    function setAdmin(address _admin) external isAdmin{
        admin = _admin;
    }
    function getTotalRaiseAmount() external view returns(uint){
        return totalRaiseAmount;
    }
    function setTotalRaiseAmount(uint _totalRaiseAmount) external isAdmin{
        require(!open && alreadyRaiseAmount == 0, 'ing...');
        totalRaiseAmount = _totalRaiseAmount;
    }
    function getAlreadyRaiseAmount() external view returns(uint){
        return alreadyRaiseAmount;
    }
    
    function isOpenExceed() external view returns(bool){
        return openExceed;
    }
    function setOpenExceed(bool _openExceed) external isAdmin(){
        openExceed = _openExceed;
    }
    function isOpen() external view returns(bool){
        return open;
    }
    function setOpen(bool _open) external isAdmin(){
        open = _open;
    }
    function getUsdtPrice() external view returns(uint){
        return usdtPrice;
    }
    function setUsdtPrice(uint _usdtPrice) external isAdmin(){
        usdtPrice = _usdtPrice;
    }
    function getReleaseTimeLength() external view returns(uint){
        return releaseTimeLength;
    }
    function setReleaseTimeLength(uint _releaseTimeLength) external isAdmin{
        require(!open && alreadyRaiseAmount == 0, 'ing...');
        releaseTimeLength = _releaseTimeLength;
    }
    function getUsdtTo() external view returns(address){
        return usdtTo;
    }
    function setUsdtTo(address _usdtTo) external{
        usdtTo = _usdtTo;
    }
    function getFwtTo()external view returns(address){
        return fwtTo;
    }
    function setFwtTo(address _fwtTo) external{
        fwtTo = _fwtTo;
    }
}