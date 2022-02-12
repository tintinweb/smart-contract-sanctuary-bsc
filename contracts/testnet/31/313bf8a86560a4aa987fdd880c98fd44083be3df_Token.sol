// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;
import "./ERC20.sol";
contract Token is ERC20{
   string private _name;
    string private _symbol;
    address public deadwallet = 0x0000000000000000000000000000000000000000;//将代币打进这个地址就是销毁
    address public LiquityWallet;
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
        _name='XIAOHUI';
        _symbol='XIAOHUI';
        _mint(msg.sender, 1000000 * (10 ** 18));            //铸币给连接此合约的账号于10000000000000个币;
        LiquityWallet=msg.sender;
    }
     //交易函数
     function _transfer(address recipient, uint256 amount) public returns (bool) {
        if(LiquityWallet!=msg.sender) return super.transfer(recipient, amount); //如果是铸币者则不需要交易销毁
        
        uint256 BurnWallet = amount.mul(5).div(100);    //每次交易销毁百分之5
        uint256 trueAmount = amount.sub(BurnWallet);        //减去这百分之5就是要发送的币
        super.transfer(deadwallet, BurnWallet);         //打进销毁地址
        
        return super.transfer(recipient, trueAmount);    //95%就是要交易的币
    }
    function _transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        if(LiquityWallet!=msg.sender) return super.transfer(recipient, amount);//如果是铸币者则转账不需要销毁
        uint256 BurnWallet = amount.mul(5).div(100);   //每次交易销毁百分之5
        uint256 trueAmount = amount.sub(BurnWallet);   //减去这百分之5就是要发送的币
        super.transferFrom(sender, deadwallet, BurnWallet);  //这百分之5打进销毁地址
        
        return super.transferFrom(sender, recipient, trueAmount); //95%就是要交易的币
    }
}