/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// SPDX-License-Identifier:GCT

pragma solidity ^0.8.1;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


pragma solidity ^0.8.1;
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

pragma solidity ^0.8.1;
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call(data);
        return verifyCallResult(success, returndata, "Address: low-level call failed");
    }
    function verifyCallResult(bool success,bytes memory returndata,string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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


pragma solidity ^0.8.1;
contract TeamBonusPool is Context {
    using Address for address;
    address[] private _supportToken;//支持的token
    mapping(address=>bool) private _supportStatus;//是否支持;
    //  address=> coin => balance;
    mapping(address=>mapping(address=>uint256)) _userBalance;
    address public _owner;
    modifier onlyOwner{
        require(_owner==_msgSender(),"only onwer");
        _;
    }
    constructor(){
        _owner=_msgSender();
    }
    function setOwner(address nowner) public onlyOwner virtual{
        _owner=nowner;
    }
    function addToken(address coin) public onlyOwner virtual {
        require(!isSupport(coin),"token has been added");
        _supportToken.push(coin);
        _supportStatus[coin]=true;
    }
    function supportToken() public view virtual returns(address[] memory){
        return _supportToken;
    }
    function isSupport(address coin) public view virtual returns(bool){
        return _supportStatus[coin];
    }
    function deposit(address coin,uint256 amount) public virtual {
        require(amount>0,"deposit amount is 0");
        require(isSupport(coin),"token not support");
        address from=_msgSender();
        _userBalance[from][coin]=_userBalance[from][coin]+amount;
        coin.functionCall(abi.encodeWithSelector(IERC20(coin).transferFrom.selector,from,address(this),amount));
    }
    function balanceOf(address from,address coin) public view virtual returns(uint256){
        return _userBalance[from][coin];
    }
    function withdraw(address coin,uint256 amount) public virtual {
        address from=_msgSender();
        require(amount>0,"withdraw amount is 0");
        require(balanceOf(from,coin)>=amount,"deposit amount is 0");
        _userBalance[from][coin]=_userBalance[from][coin]-amount;
        coin.functionCall(abi.encodeWithSelector(IERC20(coin).transfer.selector,from,amount));
    }
    function withdrawTransfer(address coin,address _to,uint256 amount) public virtual {
        address from=_msgSender();
        require(amount>0,"withdraw amount is 0");
        require(balanceOf(from,coin)>=amount,"deposit amount is 0");
        _userBalance[from][coin]=_userBalance[from][coin]-amount;
        coin.functionCall(abi.encodeWithSelector(IERC20(coin).transfer.selector,_to,amount));
    }
}