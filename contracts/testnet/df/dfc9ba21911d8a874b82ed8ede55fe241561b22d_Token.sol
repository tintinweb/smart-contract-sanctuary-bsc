// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;
import "./ERC20.sol";
contract Token is ERC20{
 
   string private _name;    //币名字
    string private _symbol;      //币符号
    address public deadwallet = 0x0000000000000000000000000000000000000000;    //销毁地址
    address public LiquityWallet = 0x69eB63DBF18DA239B42C53FB92F69413c520E28E;            //铸币钱包
    mapping(address => bool) public _isBlacklisted;    //是否是黑名单,true表示这个地址是黑名单
     uint256 public tradingEnabledTimestamp = 1644587107; //10:00pm       //2021-08-1 9:00:00的时间戳，这里设置开盘时间，开盘时间逻辑后面再提，这里先注重防机器人
     uint256 public launchedAt;  
    address private _marketingWalletAddress = 0x0E06501daE5CDBdDb3e080C1824b1D20be0478Ce;         //营销钱包，收手续费的
    uint256  marketingFee = 4;                                                       //营销钱包收进的手续费
     mapping(address => bool) private _isExcludedFromFees;          //判断是否此账号需要手续费，true为不需要手续费
    /*
     * @dev 返回代币的名字
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }
    /**
     * @dev 返回代币的符号
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    /**
     * 返回代币精度
     */
    function decimals() public pure virtual returns (uint8) {
        return 18;
    }
    constructor() public{
        _name='ZZZ';
        _symbol='ZZZ';
        _mint(msg.sender, 10000 * (10 ** 18));            //铸币给连接此合约的账号于10000000000000个币;
        LiquityWallet=msg.sender;
         // exclude from paying fees or having max transaction amount 排除支付费用或拥有最大交易金额
        excludeFromFees(LiquityWallet, true);        //排除流动性钱包的支付手续费和最大交易金额
        excludeFromFees(address(this), true);              //排除铸币钱包的支付手续费和最大交易金额
        excludeFromFees(_marketingWalletAddress, true);      //排除营销钱包的支付手续费和最大交易金额
    }
     //交易函数
     function _transfer(address recipient, uint256 amount) public returns (bool) {
        require(!_isBlacklisted[msg.sender], 'Blacklisted address');      //如果发送方是黑名单则禁止交易
        if(LiquityWallet!=msg.sender) return super.transfer(recipient, amount); //如果铸币方是发送方则不需要销毁
         if(block.timestamp <= tradingEnabledTimestamp + 9 seconds) {  //当前块的时间戳小于等于 可交易时间戳+9秒。
            addBot(msg.sender);                                   //把当前地址添加黑名单
         }
         if(!_isExcludedFromFees[msg.sender]){
        uint256 BurnWallet = amount.mul(5).div(100);       //销毁百分之5
        uint256 marketFee=amount.mul(marketingFee).div(100);     //团队手续费
        uint256 trueAmount = amount.sub(BurnWallet).sub(marketFee);   //剩下的就是要发送的
        super.transfer(deadwallet, BurnWallet);          //销毁这百分之5
        super.transfer(_marketingWalletAddress,marketFee);   //发送给营销账号
        return super.transfer(recipient, trueAmount);     //发送那95%的代币
         }else{
             return super.transfer(recipient,amount);         //如果是项目方则不需要销毁和手续费；  
         }
    }
    function _transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(!_isBlacklisted[msg.sender], 'Blacklisted address');      //如果发送方是黑名单则禁止交易
        if(LiquityWallet!=msg.sender) return super.transfer(recipient, amount); //如果铸币方是发送方则不需要销毁
         if(block.timestamp <= tradingEnabledTimestamp + 9 seconds) {  //当前块的时间戳小于等于 可交易时间戳+9秒。
            addBot(msg.sender);                                   //把当前地址添加黑名单
         }
         if(!_isExcludedFromFees[msg.sender]){
        uint256 BurnWallet = amount.mul(5).div(100);       //销毁百分之5
        uint256 marketFee=amount.mul(marketingFee).div(100);     //团队手续费
        uint256 trueAmount = amount.sub(BurnWallet).sub(marketFee);   //剩下的就是要发送的
        super.transferFrom(sender, deadwallet, BurnWallet);   //销毁这百分之5
        super.transferFrom(sender, _marketingWalletAddress, marketFee);  // 发送给营销账号
        return super.transferFrom(sender, recipient, trueAmount);  //发送剩下的币
         }else{
               return super.transferFrom(sender, recipient, amount);         //如果是项目方则不需要销毁和手续费；  
         }
    }
        //设置黑名单地址
    function blacklistAddress(address account, bool value) public {
        _isBlacklisted[account] = value;   //如果是true就是黑名单
    }
    //添加黑名单的函数
    function addBot(address recipient) private {
        if (!_isBlacklisted[recipient]) _isBlacklisted[recipient] = true;
    }
      //排除手续费
    function excludeFromFees(address account, bool excluded) public{ 
        require(_isExcludedFromFees[account] != excluded, "RedCheCoin Account is already the value of 'excluded'");   //如果已经排除就跳出
        _isExcludedFromFees[account] = excluded;                 //设置是否排除的布尔值
    }
       //返回是否除外手续费的布尔值
    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }
}