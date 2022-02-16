/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

// File: contracts/libs/SafeMath.sol

pragma solidity ^0.8.0;

/**
 * SAFEMATH LIBRARY
 */
library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// File: contracts/libs/IBEP20.sol


pragma solidity ^0.8.0;
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
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/uToken.sol

//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;



contract uToken is IBEP20 {
    using SafeMath for uint256;

    string _name = "uToken";
    string _symbol = "UTK";
    uint8 _decimals = 6;
    uint256 _totalSupply = 100000 * 10 ** _decimals;
    address _owner;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    //event Transfer(address indexed sender, address indexed receiver, uint256 indexed amount);

    constructor(){
      _owner = msg.sender;
      _balances[_owner] = _balances[_owner].add(_totalSupply);
      emit Transfer(address(0),_owner,_totalSupply);
    }

    function name() external view returns(string memory){
       return _name;
    }

    function symbol() external view override returns(string memory){
        return _symbol;
    }

    function decimals() external view returns(uint8){
        return _decimals;
    }

    function totalSupply() external view override returns(uint256){
        return _totalSupply;
    }

    function balanceOf(address _address) external view returns(uint256){
        return _balances[_address];
    }

    function allowance(address _holder, address _spender) external view returns(uint256){
        return _allowances[_holder][_spender];
    }

    function getOwner() external view returns(address){
        return _owner;
    }

    function approve(address _spender, uint256 _amount) external returns(bool){
        require(_balances[msg.sender]>=_amount,"Insufficient balance");
        _allowances[msg.sender][_spender] = _allowances[msg.sender][_spender].add(_amount);
        return true;
    }

    function transfer(address _receiver, uint256 _amount) external returns(bool){
       return _transfer(msg.sender,_receiver,_amount);
    }

       function transferFrom(address _sender, address _receiver, uint256 _amount) external returns(bool){
        _allowances[_sender][msg.sender] = _allowances[_sender][msg.sender].sub(_amount,"Insufficient allowance"); 
       return _transfer(_sender,_receiver,_amount);
    }

    function _transfer(address owner_, address _receiver, uint256 _amount)internal returns(bool){
       _balances[owner_] = _balances[owner_].sub(_amount,"Insufficient balance"); 
        _balances[_receiver] = _balances[_receiver].add(_amount); 
       return true;
    }

    function _mint(uint256 _amount) external returns(bool){
        _balances[_owner] = _balances[_owner].add(_amount); 
        _totalSupply = _totalSupply.add(_amount);
        emit Transfer(address(0),_owner,_amount);
        return true;
    }

    function burn(uint256 _amount) external returns(bool){
        return _burn(_amount);
    }

    function _burn(uint256 _amount) internal returns(bool){
        _balances[msg.sender] = _balances[msg.sender].sub(_amount,"Insufficient balance"); 
        _totalSupply = _totalSupply.sub(_amount);
         emit Transfer(_owner,address(0),_amount);
        return true;
    }


    function burnFrom() external returns(bool){
        uint256 a = 3;
        uint256 b = 100;
        uint256 _amount = _totalSupply.mul(a).div(b);
        _burn(_amount);
        return true;
    }

    function div() external view returns(uint256){
        uint256 tchsavings = 3;
        uint256 totalfee = 100;
        
        return _totalSupply.mul(tchsavings).div(totalfee);
    }

    event LogBurn(uint256 _amount);


}