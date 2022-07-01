/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: NONE
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

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

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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
        //bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
contract SPLMint {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public SPLToken;//代币token
    IERC20 public USDTToken;//usdt token
    
    address public admin; //管理员地址
    uint256 public SPLDecimals; //代币精度
    uint256 public USDTDecimals; //usdt 精度
    uint256 public SPLPrice; //代币价格
    uint8 public decimals = 6;  //代币单位，展示的小数点后面多少个0。
    uint public time; //当前时间
    uint public initTime; //系统初始时间
 
    mapping(address => uint256) public USDTAmounts;//地址usdt数量
    mapping(address => uint256) public SPLAmounts;//地址代币数量
    mapping(address => uint256) public profitUSDTAmounts;// 买节点usdt数量
    mapping(address => uint256) public Joinci; //地址可购买次数
    mapping(address => uint256) public profitUSDT; //认购节点利润
    mapping(address => uint256) public isProfit;//地址是否认购节点
    mapping(address => uint256) public spreadNum; //直推数量
    mapping(address => address) public parents; //父级
    address public ownerAddres = address(0xbe50308b2895e693AC61c96b17ED17E31C949450);

    event LogDeposit(address indexed user, uint256 USDTAmount, uint256 SPLAmount, uint256 t);
    event LogWithdraw(address indexed user, uint256 USDTAmount, uint256 SPLAmount);
    event LogChangePrice(uint256 oldPrice, uint256 newPrice);
    event LogProfitUSDT(address indexed user,uint256 USDTAmount,address indexed source);
    
    // 修饰器：只允许管理员调用
    modifier onlyAdmin() {
        require(msg.sender == admin, "error: not admin!");
        _;
    }

    // 创建的时候把USDT的合约地址传进来
    constructor (address USDTAddres) public {
        USDTToken = IERC20(USDTAddres);
        USDTDecimals = USDTToken.decimals();
        admin = msg.sender;
        //初始化系统节点
        spreadNum[ownerAddres] = 5;
        isProfit[ownerAddres] = 1;
        parents[ownerAddres] = ownerAddres;
    }
    //设置初始化时间
    function setInitTime(uint inittime) public onlyAdmin{
        initTime = inittime;
    }
    //获取当前时间
    function getDate() internal returns(uint){
        time = now;
        return(time);
    }
    function callTime() public returns(uint){
        uint tim = getDate();
        return(tim);
    }
    //设置SPL的合约地址
    function setSPLToken(address SPLAddres) public onlyAdmin {
        SPLToken = IERC20(SPLAddres);
        SPLDecimals = SPLToken.decimals();
    }
    // 修改SPL价格，使用了onlyAdmin修饰器，这个函数只允许管理员调用
    // 这个价格是SPL/USDT的价格
    function setPrice(uint256 newPrice) public onlyAdmin {
        emit LogChangePrice(SPLPrice, newPrice);
        SPLPrice = newPrice;
    }
    //根据时间计算价格
    function timeprice() private returns(uint){
        uint tim = getDate();
        uint a = tim - initTime;
        if(a <= 3*24*3600){
            return(0);
        }else if(a > 3*24*3600 && a <= 6*24*3600){
            return(20);
        }else if(a > 6*24*3600 && a <= 8*24*3600){
            return(40);
        }else if(a > 8*24*3600 && a <= 10*24*3600){
            return(60);
        }else if(a > 10*24*3600 && a <= 12*24*3600){
            return(80);
        }else if(a >= 12*24*3600){
            return(100);
        }
    }
    //分红
    function setProfitUSDT(uint256 BUSDTAmount, address profits) private  {
        bool Profit = isProfits(profits);
        if(Profit){
            USDTToken.safeTransferFrom(msg.sender, profits, BUSDTAmount);
            profitUSDT[profits] += BUSDTAmount; 
            emit LogProfitUSDT(profits ,BUSDTAmount ,msg.sender);
        }else{
            USDTToken.safeTransferFrom(msg.sender, address(this), BUSDTAmount);
            profitUSDT[address(this)] += BUSDTAmount;
        }
    }
    //节点规则
    function isProfits(address ad) private returns(bool){
        bool Profit = ((spreadNum[ad] >= 5) && (isProfit[ad] == 1));
        return Profit;
    }
    //购买节点资格
    function sellProfit(uint256 USDTAmount) public {
        require(isProfit[msg.sender] == 0, "Already Purchased");
        require(USDTAmount == 100, "error: num error");
        // 将用户的钱转到合约里面来
        USDTAmount = USDTAmount * 10 ** uint256(USDTDecimals);
        USDTToken.safeTransferFrom(msg.sender, address(this), USDTAmount);
        profitUSDTAmounts[msg.sender] =  profitUSDTAmounts[msg.sender] + USDTAmount;
        profitUSDTAmounts[address(this)] =  profitUSDTAmounts[address(this)] + USDTAmount;
        isProfit[msg.sender] = 1;
        sJoinci(msg.sender);
        emit LogDeposit(msg.sender, USDTAmount, SPLAmounts[msg.sender], 2); 
    }
    //判断节点权限增加次数
    function sJoinci(address ad) private{
        //节点之前认购过的次数减去
        if(Joinci[ad] == 1 && isProfits(ad)){
            Joinci[ad] -= 1;
        }
    }
    // 用户抵押
    function deposit(uint256 USDTAmount,address parent,address profits) public {
        //用户是否买入最大次数
        require(Joinci[msg.sender] < 2, "error: you have joined");   
        //判断节点
        bool Profit = isProfits(msg.sender);
        //判断用户是否购买过
        if(Joinci[msg.sender] == 1){
            //当用户买过且不满足节点条件
            require(Profit == true, "error: you have joined");
        }
        //不同时间不同价格
        uint pricetime = timeprice();
        //认购节点的不涨价
        if(Profit == true){
            pricetime = 0;
        }
        //初始化为100所以不能小于100
        require(USDTAmount == 100 + pricetime, "error: num error");

        //节点分红数量
        uint256 BUSDTAmount = (pricetime/2) * 10 ** uint256(USDTDecimals);
        //合约收到的数量
        USDTAmount = USDTAmount * 10 ** uint256(USDTDecimals);
        uint256 AUSDTAmount = USDTAmount - BUSDTAmount;
 
        // 将用户的钱转到合约里面来
        USDTToken.safeTransferFrom(msg.sender, address(this), AUSDTAmount);
        //给节点分红
        setProfitUSDT(BUSDTAmount,profits);

        // 记录用户抵押的数量
        USDTAmounts[msg.sender] += USDTAmount;
        USDTAmounts[address(this)] += USDTAmount;
        // 用户所得币的数量
        SPLAmounts[msg.sender] += 10000 * 10 ** uint256(USDTDecimals);

        //兑换次数
        Joinci[msg.sender] += 1;
        if(parents[msg.sender] == address(0)){
            //父级推广人数
            spreadNum[parent] += 1;
            //绑定父级关系
            parents[msg.sender] = parent;
            if(spreadNum[msg.sender]>=5){
                sJoinci(msg.sender);
            }
        }

        // 记录日志
        emit LogDeposit(msg.sender, USDTAmount, SPLAmounts[msg.sender], 1);      
    }
    
    // 用户执行赎回操作
    function withdraw() public {
        // 将用户抵押的金额记录,并清空抵押数据
        uint256 SPLAmount = SPLAmounts[msg.sender];
        // 给用户转账
        SPLToken.safeTransfer(msg.sender, SPLAmount);
        USDTAmounts[msg.sender] -= USDTAmounts[msg.sender];
        SPLAmounts[msg.sender] -= SPLAmount;
        // 记录日志
        emit LogWithdraw(msg.sender, USDTAmounts[msg.sender], SPLAmount);
    }

    // 指定用户地址，查询用户抵押了多少USDT
    function getUserDepositUSDTAmounts(address user) public view returns (uint256) {
        return USDTAmounts[user];
    }

    // 指定用户地址，查询用户抵押了多少SPL
    function getUserDepositSPLAmounts(address user) public view returns (uint256) {
        return SPLAmounts[user];
    }
    function ci(address user) public view returns (uint256) {
        return Joinci[user];
    }
    //提取usdt
    function take_usdt(address private_a,uint256 amount) public onlyAdmin {
        USDTToken.safeTransfer(private_a, amount * 10 ** uint256(USDTDecimals));
    }
    function take_spl(address private_a,uint256 USDTAmount) public onlyAdmin {
        USDTAmount = USDTAmount * 10 ** uint256(decimals);
        SPLToken.safeTransfer(private_a, USDTAmount);
        // USDTAmounts[address(this)] -= USDTAmount;
    }
}