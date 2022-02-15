// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;
import "./ERC20.sol";
contract Token is ERC20{
 
   string private _name;    
    string private _symbol;      
    address public deadwallet = 0x000000000000000000000000000000000000dEaD;    
    address public liquityWallet;     
    address private _marketingWalletAddress = 0x0E06501daE5CDBdDb3e080C1824b1D20be0478Ce;        
    uint256  marketingFee = 3;                                                       
    uint256  burnFee = 2;                                                   

     mapping(address => bool) private _isExcludedFromFees;          
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
        return 2;
    }
    constructor() public{
        _name="KPL452B123";
        _symbol="KPL452B123";
        _mint(msg.sender, 10000 * (10 ** 2));   
        liquityWallet=0x69eB63DBF18DA239B42C53FB92F69413c520E28E;
         // exclude from paying fees or having max transaction amount 排除支付费用或拥有最大交易金额
    }
     //交易函数
     function _transfer(address recipient, uint256 amount) public returns (bool) {
        uint256 BurnWallet = amount.mul(burnFee).div(100);       //销毁百分之2
        uint256 marketFee = amount.mul(marketingFee).div(100);     //团队手续费
        uint256 trueAmount = amount.sub(BurnWallet).sub(marketFee);   //剩下的就是要发送的
        super.transfer(deadwallet, BurnWallet);          //销毁这百分之2
        super.transfer(_marketingWalletAddress,marketFee);   //发送给营销账号
        return super.transfer(recipient, trueAmount);     //发送那95%的代
    }
    function _transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        uint256 BurnWallet = amount.mul(burnFee).div(100);       //销毁百分之2
        uint256 marketFee=amount.mul(marketingFee).div(100);     //团队手续费
        uint256 trueAmount = amount.sub(BurnWallet).sub(marketFee);   //剩下的就是要发送的
        super.transferFrom(sender, deadwallet, BurnWallet);   //销毁这百分之2
        super.transferFrom(sender, _marketingWalletAddress, marketFee);  // 发送给营销账号
        return super.transferFrom(sender, recipient, trueAmount);  //发送剩下的币
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