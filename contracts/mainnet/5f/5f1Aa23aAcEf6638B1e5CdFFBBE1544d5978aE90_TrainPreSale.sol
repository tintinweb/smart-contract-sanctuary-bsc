/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mint(address account, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IToken{
    function mint(address _to, uint256 _amount) external returns (uint256);
}

interface IRebateTool{
    function updateUserReward(address _addr,uint256 _amount) external ; 
}

interface IStakingHelper {
    function stake( uint _amount, address _recipient) external;
}

interface IInviteTool {
    function getUserInfo(address _addr) external view returns(uint256,address,uint256,uint256,uint256);
    function userAdrrs(string memory _code) external view returns(address);
}

interface INFTToken {
    function mint(
        address to,
        uint8 level
    ) external returns (uint256);
}

interface IPancakeSwapRouter{

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

contract TrainPreSale is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    uint256 public constant MaxAmount = 500000 ether;           // BUSD
    uint256 public constant MinAmount = 200000 ether;

    uint256 public constant teamReward = 30;             // 3%  for team
    uint256 public constant market = 20;                  // 2%  for market
    uint256 public constant flexibleMarket = 50;         // 5% 
    uint256 public constant trainLp = 195;               // 19.5% trainLp
    uint256 public constant trainMarket = 455;           // 45.5% trainMarket
    uint256 public constant skillLp = 75;                // 7.5%  skillLp
    uint256 public constant skillMarket = 175;           // 17.5% skillMarket

    uint256 public constant feeDenominator = 1000;
    
    address private constant teamAddr = 0xA729e461333711f2782E970Edb698CbE57a4A46C;
    address private constant manager = 0x4a933106c2bae4DCD6120105016333EFb93b00FA;

    bool public addTrainLiquidity;
    bool public addSkillLiquidity;
    uint256 private trainBuyBackAmount;
    uint256 private skillBuyBackAmount;

    uint256 public startTime;
    uint256 public endTime;

    uint256 public totalAmount;

    bool public mission;
    bool public complete;

    address public immutable stableCoin;
    address public trainToken;
    address public skillToken;
    address public rebateTool;
    address public nftToken;
    address public immutable inviteTool;
    address public immutable router;
    address public staker;

    struct UserInfo{
        uint256 amount;
        uint256 iAmount;                    // level1(invset) amount for nft
        uint256 invitedCount;               // level1(user) counts for invest
        bool claim;
        uint8 nftLevel;
        bool nftClaim;
        bool harvest;
        uint256 lastInvestTime;
    }

    mapping (address => UserInfo) public users;

    mapping ( address => mapping(address => bool)) public relative;

    mapping (address => bool) public invitorState;

    struct InvitorInfo {
        uint256 invitorAmount;
        bool claimed;
    }
    mapping (address => InvitorInfo) public INInfo;
    uint256 public constant invitorFee = 25;           // 2.5% for invitors
    uint256 public INTotalAmount;

    constructor (address _coin,address _inviteTool,address _swapRouter){
        require(_coin != address(0),"invalid address!");
        stableCoin = _coin;
        require(_inviteTool != address(0), "invite: invalid address!");
        inviteTool = _inviteTool;
        require(_swapRouter != address(0), "swapRouter: invalid address!");
        router = _swapRouter;

        mission = true;
        complete = false;
        startTime = block.timestamp.add(300 days);
    }

    function launch() public onlyOwner() returns(bool){
        require(endTime == 0,"already launched!");
        startTime = block.timestamp;
        endTime = startTime.add(10 days);
        return true;
    }

    function invest(uint256 _amount) public returns(bool){
        require(block.timestamp >= startTime,"not start!");
        require(block.timestamp <= endTime,"already ended!");
        // require(_amount>= 30 ether && _amount <= 500 ether,"invalid amount!");
        require(totalAmount < MaxAmount,"already ended!");
        UserInfo memory user = users[msg.sender];
        // require(user.amount.add(_amount) <= 500 ether,"over flow!");

        IERC20( stableCoin ).transferFrom( msg.sender, address(this), _amount);
        totalAmount = totalAmount.add(_amount);

        // rebate
        IRebateTool(rebateTool).updateUserReward(msg.sender, _amount);
        // user
        users[msg.sender] = UserInfo({
            amount: user.amount.add(_amount),
            iAmount: user.iAmount,
            invitedCount: user.invitedCount,
            claim: false,
            nftLevel: user.nftLevel,
            nftClaim: false,
            harvest: false,
            lastInvestTime: block.timestamp
        });
        // update currentUserInfo
        updateUserInfo(msg.sender);
        // update invitorInfo
        userNftState(msg.sender,_amount);
        // 
        resetInvitorAmount(msg.sender,_amount);
        return true;
    }

    function userNftState(address _user,uint256 _amount) internal {
        
        (,address upline,,,) = IInviteTool(inviteTool).getUserInfo(_user);
        if(upline == address(0)){
            return;
        }
        users[upline].iAmount = users[upline].iAmount.add(_amount);
        if(relative[upline][_user] == false){
            users[upline].invitedCount = users[upline].invitedCount.add(1);
            relative[upline][_user] = true;
        }
        //
        updateUserInfo(upline);
    }

    function updateUserInfo(address _user) internal {
        uint256 invitorRefNum1 = users[_user].invitedCount;

        if(users[_user].amount >= 300 ether && invitorRefNum1>=5 && users[_user].iAmount >= 700 ether){
            users[_user].nftLevel = 3;
        }else if(users[_user].amount >= 300 ether && invitorRefNum1>=3 && users[_user].iAmount >= 200 ether){
            users[_user].nftLevel = 2;
        } else if(users[_user].amount >= 300 ether){
            users[_user].nftLevel = 1;
        }
    }

    /**
    uint256 public constant invitorFee = 25;           // 2.5% for invitors
    uint256 public INTotalAmount;
     */
    function resetInvitorAmount(address _user, uint256 _amount) internal{
        
         (,address upline,,,) = IInviteTool(inviteTool).getUserInfo(_user);
        
        for (uint256 i = 0; i < 3; i++) {
			if (upline != address(0)) {
				if(invitorState[upline]){
                    uint256 amount = _amount.mul(invitorFee).div(feeDenominator);
                    INInfo[upline].invitorAmount = INInfo[upline].invitorAmount.add(amount);
                    INTotalAmount = INTotalAmount.add(amount);
                    break;
                }
				
                (,upline,,,) = IInviteTool(inviteTool).getUserInfo(upline);
                    
			} else break;
		}

    }

    function claim() public returns (bool){
        require(addTrainLiquidity == true,"lp : not ready!");
        require(staker != address(0),"staker: address is zero!");
        require(trainToken != address(0),"trainToken: address is zero!");
        UserInfo memory user = users[msg.sender];
        require(user.claim == false,"already claimed!");
        require(user.amount > 0 ,"invalid user!");
        // 1 mint
        uint256 amount = user.amount.mul(10000);
        IToken(trainToken).mint(address(this), amount);
        // 2 stake 
        IERC20(trainToken).approve(staker, amount);
        IStakingHelper(staker).stake(amount, msg.sender);
        // update userInfo
        users[msg.sender].claim = true;

        return true;
    }

    function claimNFT() public returns (bool){
        require(startTime < block.timestamp,"not started!");
        require(endTime < block.timestamp, "not ended!");
        require(totalAmount >= MinAmount,"invalid state");
        require(nftToken != address(0),"nft address is zero!");
        UserInfo memory user = users[msg.sender];
        require(user.nftClaim == false,"already claimed!");
        require(user.nftLevel > 0 , "don't have nft!");
        // mint
        INFTToken(nftToken).mint(msg.sender, user.nftLevel-1);
        // update userInfo
        users[msg.sender].nftClaim = true;

        return true;
    }

    function refund() public returns (bool){
        require(mission == false,"mission not failed!");
        UserInfo memory user = users[msg.sender];
        require(user.harvest == false,"already harvested!");
        require(user.amount > 0 ,"invalid user!");

        IERC20( stableCoin ).safeTransfer( msg.sender, user.amount );
        users[msg.sender].harvest = true;
        return true;
    }

    function finish() public returns (bool){
        require(startTime < block.timestamp,"not started!");
        require(endTime < block.timestamp, "not ended!");
        require(complete == false,"finished!");
        if(totalAmount < MinAmount){
            mission = false;
        }else{
 
            uint256 amount = totalAmount.mul(teamReward).div(feeDenominator);
            amount = totalAmount.mul(market).div(feeDenominator).add(amount);
            amount = totalAmount.mul(flexibleMarket).div(feeDenominator).add(amount);
            amount = amount.sub(INTotalAmount);
            // transfer
            IERC20(stableCoin).safeTransfer(teamAddr, amount);
            
        }
        complete = true;
        return true;
    }

    function setStaker(address _staker) public onlyOwner(){
        require(_staker != address(0),"invalid address");
        staker = _staker;
    }

    function setTokenAddress(address _token) public onlyOwner(){
        require(_token != address(0),"invalid address");
        require(trainToken == address(0),"already setted!");
        trainToken = _token;
    }

    function setSkillToken(address _token) public onlyOwner(){
        require(_token != address(0), "invalid address!");
        require(skillToken == address(0),"already setted!");
        skillToken = _token;
    }

    function setNftToken(address _nft) public onlyOwner(){
        require(_nft != address(0), "invalid address!");
        require(nftToken == address(0),"already setted!");
        nftToken = _nft;
    }

    function setRebateContract(address _rebate) public onlyOwner{
        require(_rebate != address(0),"reabte: invalid address!");
        require(rebateTool == address(0));
        rebateTool = _rebate;
    }

    function setWhitelist(string memory _code) public onlyOwner(){
        require(len(_code) == 12,"invalid Code!");
        address userAddress = IInviteTool(inviteTool).userAdrrs(_code);
        
        (,address upline,,,) = IInviteTool(inviteTool).getUserInfo(userAddress);
        require(upline == manager,"not level1");
        
        invitorState[userAddress] = true;
    }

    function claimReward() public {
        require(complete == true,"not finished!");
        require(totalAmount >= MinAmount,"invalid state");
        require(invitorState[msg.sender],"invalid user");
        require(INInfo[msg.sender].invitorAmount > 0);
        require(INInfo[msg.sender].claimed == false,"already claimed!");
        uint256 amount = INInfo[msg.sender].invitorAmount;
        IERC20(stableCoin).safeTransfer(msg.sender, amount);
        INInfo[msg.sender].claimed = true;
    }
    
    /**
    bool public addTrainLiquidity;
    bool public addSkillLiquidity;
    uint256 private trainBuyBackAmount;
    uint256 private skillBuyBackAmount;
     */
    function trainLiquidity() public onlyOwner(){
        require(addTrainLiquidity == false,"already added!");
        require(trainToken != address(0),"trainToken: address is zero!");
        require(totalAmount >= MinAmount,"invalid state");
        require(complete == true,"not finished!");
        uint256 busdAmount = totalAmount.mul(trainLp).div(feeDenominator);
        // mint
        uint256 trainAmount = busdAmount.mul(10000);
        IToken(trainToken).mint(address(this),trainAmount);
        // add lp
        IERC20(trainToken).safeIncreaseAllowance(router, trainAmount);
        IERC20(stableCoin).safeIncreaseAllowance(router, busdAmount);

        uint256 time = block.timestamp.add(1800);
        
        IPancakeSwapRouter(router).addLiquidity(stableCoin, trainToken, busdAmount, trainAmount, 0, 0, address(this),time);
        // reset state
        addTrainLiquidity = true;       
    }

    function skillLiquidity() public onlyOwner(){
        require(addSkillLiquidity == false,"already added!");
        require(skillToken != address(0),"trainToken: address is zero!");
        require(totalAmount >= MinAmount,"invalid state");
        require(complete == true,"not finished!");
        uint256 busdAmount = totalAmount.mul(skillLp).div(feeDenominator);
        uint256 tokenAmount = busdAmount.mul(10000);
        // mint
        IToken(skillToken).mint(address(this),tokenAmount);
        // add lp
        IERC20(skillToken).safeIncreaseAllowance(router, tokenAmount);
        IERC20(stableCoin).safeIncreaseAllowance(router, busdAmount);
        
        IPancakeSwapRouter(router).addLiquidity(stableCoin, skillToken, busdAmount, tokenAmount, 0, 0, address(this), block.timestamp.add(1800));
        // reset state
        addSkillLiquidity = true;       
    }

    function buyTrain(uint256 _amount) public onlyOwner(){
        require(_amount > 0,"invalid amount!");
        require(addTrainLiquidity == true,"not ready!");
        uint256 amount = totalAmount.mul(trainMarket).div(feeDenominator);
        require(trainBuyBackAmount.add(_amount) <= amount,"amount exceeds balance");
        // Swap for the token
        IPancakeSwapRouter swapRouter = IPancakeSwapRouter(router);
        // buy
        address[] memory path = new address[](2);
        path[0] = stableCoin;
        path[1] = trainToken;
        IERC20(stableCoin).safeIncreaseAllowance(router, amount);
        swapRouter.swapExactTokensForTokens(_amount, 0, path , address(this), block.timestamp.add(1800));
        // update 
        trainBuyBackAmount = trainBuyBackAmount.add(_amount);
    }

    function checkTrainBuyBackAmount() public view onlyOwner() returns(uint256 totalAmount_,uint256 buyedAmount_,uint256 leftAmount_){
        totalAmount_ = totalAmount.mul(trainMarket).div(feeDenominator);
        buyedAmount_ = trainBuyBackAmount;
        leftAmount_ = totalAmount_.sub(trainBuyBackAmount);
    }

    function buySkill(uint256 _amount) public onlyOwner(){
        require(_amount > 0,"invalid amount!");
        require(addSkillLiquidity == true,"not ready!");
        uint256 amount = totalAmount.mul(skillMarket).div(feeDenominator);
        require(skillBuyBackAmount.add(_amount) <= amount,"amount exceeds balance");
        // Swap for the token
        IPancakeSwapRouter swapRouter = IPancakeSwapRouter(router);
        // buy
        IERC20(stableCoin).safeIncreaseAllowance(router, amount);
        address[] memory path = new address[](2);
        path[0] = stableCoin;
        path[1] = skillToken;
        swapRouter.swapExactTokensForTokens(_amount, 0, path , address(this), block.timestamp.add(1800));
        // update
        skillBuyBackAmount = skillBuyBackAmount.add(_amount);
    }

    function checkSkillBuyBackAmount() public view onlyOwner() returns(uint256 totalAmount_,uint256 buyedAmount_,uint256 leftAmount_){
        totalAmount_ = totalAmount.mul(skillMarket).div(feeDenominator);
        buyedAmount_ = skillBuyBackAmount;
        leftAmount_ = totalAmount_.sub(skillBuyBackAmount);
    }

    function getUserInviteInfo(address _user) public view returns(uint256 level1_,uint256 amount_){
        level1_ = users[_user].invitedCount;
        amount_ = users[_user].iAmount;
    }

    function len(string memory s) public pure returns ( uint256) {
        return bytes(s).length;
    }


}