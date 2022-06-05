/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: MIT
/**
 *Official Wrapped TRM (WTRM) of TetherMoon (testnet)
*/
pragma solidity =0.8.4;

contract WRBA {
    string public name = "Wrapped Roburna";
    string public symbol = "WRBA";
    uint8 public decimals = 18;
    address payable WrappedTRM = payable(address(this));

    event Approval(address indexed src, address indexed guy, uint amount);
    event Transfer(address indexed src, address indexed dst, uint amount);
    event Deposit(address indexed dst, uint amount);
    event Withdrawal(address indexed src, uint amount);
    event Received(address, uint);
    event ReceivedFallback(address, uint);

    mapping (address => uint256) public  balanceOf;
    mapping (address => mapping (address => uint)) public allowance;
    
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    constructor(uint8 _dec){
        decimals = _dec;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    
    fallback() external payable {
        deposit();
        emit ReceivedFallback(_msgSender(), msg.value);
    }
    
    receive() external payable {
        deposit();
        emit Received(_msgSender(), msg.value);
    }

    function deposit() public payable {
        balanceOf[_msgSender()] += msg.value;
        emit Transfer(address(0), _msgSender(), msg.value);
        emit Deposit(_msgSender(), msg.value);
    }

    function withdraw(uint amount) public {
        require(balanceOf[_msgSender()] >= amount);
        balanceOf[_msgSender()] -= amount;
        payable(_msgSender()).transfer(amount);
        emit Withdrawal(_msgSender(), amount);
    }

    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    function approve(address guy, uint amount) public returns (bool) {
        allowance[_msgSender()][guy] = amount;
        emit Approval(_msgSender(), guy, amount);
        return true;
    }

    function transfer(address dst, uint amount) public returns (bool) {
        return transferFrom(_msgSender(), dst, amount);
    }

    function transferFrom(address src, address dst, uint amount)
    public
    returns (bool)
    {
        require(balanceOf[src] >= amount);

        if (src != _msgSender() && allowance[src][_msgSender()] != type(uint).max) {
            require(allowance[src][_msgSender()] >= amount);
            allowance[src][_msgSender()] -= amount;
        }

        balanceOf[src] -= amount;
        balanceOf[dst] += amount;

        emit Transfer(src, dst, amount);

        return true;
    }
}