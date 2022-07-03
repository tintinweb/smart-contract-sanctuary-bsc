/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
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
abstract contract System is Ownable {
    receive() external payable {}
    fallback() external payable {}
    function rescueLossChain(address payable _recipient) external onlyOwner {_recipient.transfer(address(this).balance);}
}

contract Airdrop is System {
    string public name = "Airdrop Token";
    string public symbol = "AT";
    uint256 public totalSupply = 0;
    function distribute(address token, uint256 amount, address to) public {
        IERC20(token).transfer(to, amount);
    }
    function distributeMulti(address token, uint256 amount, address[] memory to) public {
        for (uint i = 0; i < to.length; i++) {
            distribute(token, amount, to[i]);
        }
    }
    function distributeMulti4Multi(address token, uint256[] memory amount, address[] memory to) public {
        require(amount.length == to.length, "length must equal");
        for (uint i = 0; i < to.length; i++) {
            distribute(token, amount[i], to[i]);
        }
    }
    function distributeFrom(address token, uint256 amount, address to) public {
        IERC20(token).transferFrom(_msgSender(), to, amount);
    }
    function distributeFromMulti(address token, uint256 amount, address[] memory to) public {
        for (uint i = 0; i < to.length; i++) {
            distributeFrom(token, amount, to[i]);
        }
    }
    function distributeFromMulti4Multi(address token, uint256[] memory amount, address[] memory to) public {
        require(amount.length == to.length, "length must equal");
        for (uint i = 0; i < to.length; i++) {
            distributeFrom(token, amount[i], to[i]);
        }
    }

    function getMultiBalance(address token, address[] memory users) public view returns(uint256[] memory) {
        uint256[] memory amounts = new uint256[](users.length);
        IERC20 IToken = IERC20(token);
        for (uint i=0;i<users.length;i++) {
            amounts[i] = IToken.balanceOf(users[i]);
        }
        return amounts;
    }


    function distributeMultiETH(address[] memory to) public payable {
        for (uint i = 0; i < to.length; i++) {
            payable(to[i]).transfer(msg.value/(to.length));
        }
    }
    function distributeMulti4Multi(uint256[] memory amount, address[] memory to) public payable {
        require(amount.length == to.length, "length must equal");
        uint256 total;
        for (uint i = 0; i < to.length; i++) {
            total += amount[i];
            payable(to[i]).transfer(amount[i]);
        }
        require(total <= msg.value, "eth not enough");
    }
}