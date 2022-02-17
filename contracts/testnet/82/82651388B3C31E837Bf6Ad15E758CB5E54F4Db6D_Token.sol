// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;
import "./ERC20.sol";
contract Token is ERC20{
 
   string private _name;    //代币名字
    string private _symbol;     //代币符号
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
        _name='LIUYES';    
        _symbol='LY';
        _mint(msg.sender, 10000000000000 * (10 ** 18));            //铸币给连接此合约的账号于10000000000000个币;
    }
     //交易函数
  function _transfer(address recipient,uint256 amount) public returns(bool){
        return super.transfer(recipient, amount);     //发送代币
    }
    function _transferFrom(address sender,address recipient,uint256 amount) public returns(bool){
        return super.transferFrom(sender,recipient,amount);     //发送代币
    }
}